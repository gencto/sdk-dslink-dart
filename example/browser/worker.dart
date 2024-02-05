import 'package:dslink/worker.dart';

void main() async {
  var worker = await createWorker(transformStringWorker).init();
  print(await worker.callMethod('transform', 'Hello World'));
}

void transformStringWorker(Worker worker) async {
  await worker.init(methods: {
    'transform': (/*String*/ dynamic input) => input.toLowerCase()
  });
}