import 'dart:async';

import 'package:dsalink/dsalink.dart';
import 'package:dsalink/src/storage/simple_storage.dart';

late LinkProvider link;
late int lastNum;
LocalNode? valueNode;

Future<void> main() async {
  var defaultNodes = <String, dynamic>{
    'node': {r'$type': 'string'},
  };

  var storage = SimpleResponderStorage('storage');

  var storedNodes = await storage.load();

  link = LinkProvider(
    ['-b', 'https://127.0.0.1/conn', '--log', 'finest'],
    'qos-resp',
    defaultNodes: defaultNodes,
  );

  if (link.link == null) {
    // initialization failed
    return;
  }

  link.link?.responder?.initStorage(storage, storedNodes);

  valueNode = link.getNode('/node');

  Timer.periodic(Duration(seconds: 1), (t) {
    var d = DateTime.now();
    valueNode?.updateValue('${d.hour}:${d.minute}:${d.second}');
  });

  await link.connect();
}
