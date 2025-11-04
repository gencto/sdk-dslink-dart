import 'dart:async';

import 'package:dsalink/dsalink.dart';
import 'package:dsalink/worker.dart';

late LinkProvider? link;
late WorkerPool? workerPool;

// Функція для обробки даних у робочому процесі
void dataProcessingWorker(Worker worker) async {
  var socket = await worker.init();
  var workerId = worker.get('workerId');

  print('Worker $workerId initialized');

  // Додаємо метод для обробки даних
  socket.addMethod('processData', (dynamic data) {
    print('Worker $workerId received task: ${data['input']}');
    var startTime = DateTime.now();

    // Імітуємо важку обробку даних
    return Future.delayed(Duration(seconds: 1), () {
      var endTime = DateTime.now();
      var processingTime = endTime.difference(startTime).inMilliseconds;

      print('Worker $workerId completed task in ${processingTime}ms');

      return {
        'processed': true,
        'workerId': workerId,
        'result': 'Processed data: ${data['input']}',
        'timestamp': endTime.toIso8601String(),
        'processingTime': processingTime,
      };
    });
  });

  // Обробка сесій для потокової передачі даних
  socket.sessions.listen((session) async {
    print('Worker $workerId received session: ${session.id}');

    // Отримуємо початкові дані
    var data = session.initialMessage;
    if (data['type'] == 'stream') {
      // Відправляємо дані кожні 500 мс
      Timer.periodic(Duration(milliseconds: 500), (timer) {
        if (session.isClosed) {
          timer.cancel();
          return;
        }

        var now = DateTime.now();
        session.send({
          'processed': true,
          'workerId': workerId,
          'result': 'Stream data: ${data['data']} at ${now.toIso8601String()}',
          'timestamp': now.toIso8601String(),
          'processingTime': 0,
        });
      });
    }
  });
}

void main(List<String> args) async {
  // Ініціалізуємо пул воркерів
  workerPool = createWorkerPool(4, dataProcessingWorker);
  await workerPool?.init();

  // Додаємо моніторинг воркерів
  workerPool?.onMessageReceivedHandler = (workerId, message) {
    print('Message from worker $workerId: $message');
  };

  // Process the arguments and initializes the default nodes.
  // Using NodeBuilder for cleaner, type-safe node configuration
  link = LinkProvider(
    ['--broker', 'https://dmk.sviteco.ua/conn'],
    'Actions-',
    defaultNodes: <String, dynamic>{
      'message': NodeBuilder.value('string')
          .name('Message')
          .writable()
          .value('Hello World')
          .child(
            'reset',
            NodeBuilder.action()
                .name('Reset')
                .profile('reset')
                .invokable('write')
                .resultType('values')
                .build(),
          )
          .child(
            'add',
            NodeBuilder.action()
                .name('Add')
                .profile('add')
                .invokable('write')
                .param('name', 'string')
                .resultType('values')
                .build(),
          )
          .child(
            'process',
            NodeBuilder.action()
                .name('Process Data')
                .profile('process')
                .invokable('read')
                .param('data', 'string')
                .resultType('stream')
                .column('processed', 'bool')
                .column('workerId', 'number')
                .column('result', 'string')
                .column('timestamp', 'string')
                .column('processingTime', 'number')
                .build(),
          )
          .build(),
    },
    profiles: {
      'reset': (String path) => ResetNode(path),
      'add': (String path) => ControllerNode(path),
      'process': (String path) => ProcessNode(path),
    },
    encodePrettyJson: true,
    defaultLogLevel: 'DEBUG',
  );

  // Connect to the broker.
  link?.init();

  await link?.connect();
  UpdateLogLevel('debug');
}

// A simple node that resets the message value.
class ResetNode extends SimpleNode {
  ResetNode(String path, [SimpleNodeProvider? provider])
    : super(path, provider) {
    print('========= CREATE RESET =========');
  }

  @override
  Future<Map> onInvoke(Map params) async {
    link!.updateValue('/message', 'Hello World');
    return <String, dynamic>{};
  }
}

class ControllerNode extends SimpleNode {
  ControllerNode(String path, [SimpleNodeProvider? provider])
    : super(path, provider) {
    print('========= CREATE CONTROLLER =========');
  }

  @override
  void onInvoke(Map params) {
    // Using NodeBuilder for cleaner, type-safe node configuration
    link?.addNode(
      ('/' + params['name']).toString(),
      NodeBuilder()
          .name(params['name'])
          .writable()
          .child(
            'reset',
            NodeBuilder.action()
                .name('Reset')
                .profile('reset')
                .invokable('write')
                .resultType('values')
                .build(),
          )
          .child(
            'add',
            NodeBuilder.action()
                .name('Add')
                .profile('add')
                .invokable('write')
                .param('name', 'string')
                .resultType('values')
                .build(),
          )
          .child(
            'process',
            NodeBuilder.action()
                .name('Process Data')
                .profile('process')
                .invokable('read')
                .param('data', 'string')
                .resultType('stream')
                .column('processed', 'bool')
                .column('workerId', 'number')
                .column('result', 'string')
                .column('timestamp', 'string')
                .column('processingTime', 'number')
                .build(),
          )
          .build(),
    );
  }
}

// Новий клас для обробки даних через воркери
class ProcessNode extends SimpleNode {
  ProcessNode(String path, [SimpleNodeProvider? provider])
    : super(path, provider);

  @override
  Future<Map> onInvoke(Map params) async {
    if (workerPool == null) {
      throw Exception('Worker pool not initialized');
    }

    try {
      // Отримуємо дані для обробки
      final data = params['data'] as String;

      // Створюємо сесію для отримання неперервного потоку даних
      final session = await workerPool!.createSession({
        'type': 'stream',
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Створюємо StreamController для передачі даних
      final controller = StreamController<Map>();

      // Підписуємося на повідомлення від воркера
      session.messages.listen((message) {
        if (message is Map) {
          controller.add({
            'processed': message['processed'] ?? true,
            'workerId': message['workerId'],
            'result': message['result'],
            'timestamp': message['timestamp'],
            'processingTime': message['processingTime'],
          });
        }
      });

      // Повертаємо початковий результат з посиланням на потік
      return {'stream': controller.stream, 'session': session.id};
    } catch (e) {
      print('Error processing data stream: $e');
      rethrow;
    }
  }
}
