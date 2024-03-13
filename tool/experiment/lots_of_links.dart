import 'package:dslink/dslink.dart';
import 'package:dslink/worker.dart';

int workers = 20; // Number of Workers

void main() async {
  var pool = createWorkerPool(workers, linkWorker); // Create a Worker Pool
  await pool.init(); // Initialize the Worker Pool
  await pool.divide('spawn',
      1000); // Divide 1000 calls to "spawn" over all the workers, which is 50 links per worker.
}

void linkWorker(Worker worker) async {
  spawnLink(int i) async {
    updateLogLevel('OFF');
    var link = LinkProvider([], 'Worker-$i-',
        defaultNodes: <String, dynamic>{
          // Create a Link Provider
          'string': {
            // Just a value so that things aren't empty.
            r'$name': 'String Value',
            r'$type': 'string',
            '?value': 'Hello World'
          }
        },
        autoInitialize: false);

    link.configure(); // Configure the Link
    link.init(); // Initialize the Link
    await link.connect().then((dynamic _) {
      print('Link #$i Connected.');
    }); // Connect to the Broker
  }

  await worker.init(methods: {
    // Initialize the Worker, and add a "spawn" method.
    'spawn': (dynamic i) {
      spawnLink(i);
    }
  });
}
