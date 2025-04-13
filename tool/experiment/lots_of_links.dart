import 'package:dsalink/dsalink.dart';
import 'package:dsalink/worker.dart';

int workers = 10; // Number of Workers

void main() async {
  var pool = createWorkerPool(workers, linkWorker); // Create a Worker Pool
  await pool.init(); // Initialize the Worker Pool
  await pool.divide(
    'spawn',
    10,
  ); // Divide 10 calls to "spawn" over all the workers, which is 50 links per worker.
}

void linkWorker(Worker worker) async {
  spawnLink(int i) async {
    UpdateLogLevel('OFF');
    var link = LinkProvider(
      ['-b', '127.0.0.1/conn', '--log', 'finest'],
      'Worker-$i-',
      defaultNodes: <String, dynamic>{
        // Create a Link Provider
        'string': {
          // Just a value so that things aren't empty.
          r'$name': 'String Value',
          r'$type': 'string',
          '?value': 'Hello World',
        },
      },
      autoInitialize: false,
    );

    link.configure(); // Configure the Link
    link.init(); // Initialize the Link
    await link.connect().then((dynamic _) {
      print('Link #$i Connected.');
    }); // Connect to the Broker
  }

  await worker.init(
    methods: {
      // Initialize the Worker, and add a "spawn" method.
      'spawn': (dynamic i) {
        spawnLink(i);
      },
    },
  );
}
