import 'package:dslink/dslink.dart';
import 'package:dslink/worker.dart';

late LinkProvider link;

void main(List<String> args) async {
  // Process the arguments and initializes the default nodes.
  link = LinkProvider(['--broker', 'http://dsa.gencto.uk/conn', '--log', 'debug'], 'CounterWorker-',
      defaultNodes: <String, dynamic>{
        'Counter': {
          r'$type': 'number', // The type of the node is a number.
          r'$writable': 'write', // This node's value can be set by a requester.
          '?value': 0 // The default counter value.
        }
      },
      encodePrettyJson: true);

  // Connect to the broker.
  await link.connect();

  var counterNode = link['/Counter'];
  counterNode?.subscribe((update) => link.save());

  var worker = await createWorker(counterWorker).init();
  worker.addMethod('increment', (dynamic _) {
    counterNode?.updateValue((counterNode.lastValueUpdate?.value as int) + 1);
  });
}

void counterWorker(Worker worker) async {
  var socket = await worker.init();
  Scheduler.every(Interval.ONE_SECOND, () async {
    await socket.callMethod('increment');
  });
}
