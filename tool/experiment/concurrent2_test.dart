/// this is a modified version of the original test_concurrent.dart
/// it gives the broker more time to handler handshake and not blocking network traffic
import 'dart:math';

import 'package:args/args.dart';
import 'package:dsalink/dsalink.dart';
import 'package:dsalink/utils.dart';
import 'package:logging/logging.dart';

class TestNodeProvider extends NodeProvider {
  late TestNode onlyNode;
  TestNodeProvider() {
    onlyNode = TestNode('/', this);
  }

  @override
  LocalNode? getNode(String? path) {
    return onlyNode;
  }

  @override
  IPermissionManager permissions = DummyPermissionManager();
  @override
  Responder createResponder(String? dsId, String sessionId) {
    return Responder(this, dsId);
  }

  @override
  LocalNode getOrCreateNode(String path, [bool addToTree = true]) {
    return onlyNode;
  }
}

class TestNode extends LocalNodeImpl {
  @override
  NodeProvider provider;
  TestNode(String path, this.provider) : super(path) {
    configs[r'$is'] = 'node';
    configs[r'$test'] = 'hello world';
    configs[r'$type'] = 'number';
    children['node'] = this;
  }
}

int pairCount = 10;
String broker = 'https://127.0.0.1/conn';
Stopwatch? stopwatch;
Random random = Random();

String prefix = '';
Future<void> main() async {
  var argp = ArgParser();
  argp.addOption(
    'pairs',
    abbr: 'p',
    help: 'Number of Link Pairs',
    defaultsTo: '10',
    valueHelp: 'pairs',
  );
  argp.addOption(
    'broker',
    abbr: 'b',
    help: 'Broker Url',
    defaultsTo: 'https://127.0.0.1/conn',
    valueHelp: 'broker',
  );
  argp.addOption(
    'prefix',
    abbr: 'f',
    help: 'Prefix on dsalink Id',
    defaultsTo: '',
    valueHelp: 'previx',
  );

  var opts = argp.parse(['https://127.0.0.1/conn']);

  try {
    pairCount = int.parse(opts['pairs']);
  } catch (e) {
    print('Invalid Number of Pairs.');
    return;
  }
  try {
    broker = opts['broker'];
  } catch (e) {
    print('Invalid broker');
    return;
  }
  prefix = opts['prefix'];

  logger.level = Level.WARNING;

  stopwatch = Stopwatch();

  await createLinks();
  await createLinks();
}

bool onCreatedRun = false;

void onCreated() {
  if (onCreatedRun) return;
  onCreatedRun = true;

  var mm = 0;
  var ready = false;

  Scheduler.every(Interval.TWO_SECONDS, () {
    if (connectedCount != pairCount) {
      mm++;

      if (mm == 2) {
        print('$connectedCount of $pairCount link pairs are ready.');
        mm = 0;
      }

      return;
    }

    if (!ready) {
      print(
        'All link pairs are now ready. Subscribing requesters to values and starting value updates.',
      );
      ready = true;
    }

    var pi = 1;

    while (pi <= 5) {
      var rpc = getRandomPair();
      var n = random.nextInt(5000);
      changeValue(n, rpc);
      pi++;
    }
  });
}

int getRandomPair() {
  return random.nextInt(pairCount - 1) + 1;
}

void changeValue(dynamic value, int idx) {
  (pairs[idx][2] as TestNodeProvider).getNode('/node')?.updateValue(value);
}

Future<void> createLinks() async {
  print('Creating $pairCount link pairs.');
  while (true) {
    createLinkPair();
    if (pairIndex > pairCount) {
      onCreated();
      return;
    }
  }
}

List pairs = <dynamic>[null];
int pairIndex = 1;

PrivateKey key = PrivateKey.loadFromString(
  '9zaOwGO2iXimn4RXTNndBEpoo32qFDUw72d8mteZP9I BJSgx1t4pVm8VCs4FHYzRvr14BzgCBEm8wJnMVrrlx1u1dnTsPC0MlzAB1LhH2sb6FXnagIuYfpQUJGT_yYtoJM',
);

void createLinkPair() async {
  var provider = TestNodeProvider();
  var linkResp = HttpClientLink(
    broker,
    '$prefix-resp-$pairIndex-',
    key,
    isRequester: false,
    isResponder: true,
    nodeProvider: provider,
  );

  var linkReq = HttpClientLink(
    broker,
    '$prefix-req--$pairIndex-',
    key,
    isRequester: true,
  );
  linkReq.connect();

  pairs.add([linkResp, linkReq, provider]);

  var mine = pairIndex;

  changeValue(0, pairIndex);
  pairIndex++;

  await linkResp.connect();
  print('Link Pair $mine is now ready.');
  connectedCount++;
  linkReq.requester!.subscribe(
    '/conns/$prefix-resp-$mine/node',
    (ValueUpdate val) {},
  );
}

int connectedCount = 0;
