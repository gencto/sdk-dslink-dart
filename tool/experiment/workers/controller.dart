import 'package:dslink/worker.dart';

void main() async {
  late WorkerSocket worker;
  worker = await createWorkerScript('worker.dart')
      .init(methods: {'stop': (dynamic _) => worker.stop()});
  await worker.callMethod('hello');
}
