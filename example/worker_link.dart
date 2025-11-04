import 'package:dsalink/dsalink.dart';
import 'package:dsalink/worker.dart';

late LinkProvider link;

void main(List<String> args) async {
  // Process the arguments and initializes the default nodes.
  // Using NodeBuilder for cleaner, type-safe node configuration
  link = LinkProvider(
    ['--broker', 'http://127.0.0.1:8080/conn', '--log', 'debug'],
    'CounterWorker-',
    defaultNodes: <String, dynamic>{
      'Counter': NodeBuilder.value('number')
          .writable() // This node's value can be set by a requester.
          .value(0) // The default counter value.
          .build(),
    },
    encodePrettyJson: true,
  );

  // Connect to the broker.
  await link.connect();

  var counterNode = link['/Counter'];
  counterNode?.subscribe((update) => link.saveAsync());

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
