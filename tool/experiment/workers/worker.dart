import 'package:dslink/utils.dart' show Scheduler;
import 'package:dslink/worker.dart';

void main(List<String> args, Map message) async {
  var worker = buildWorkerForScript(message);
  var socket = await worker
      .init(methods: {'hello': (dynamic _) => print('Hello World')});

  print('Worker Started');

  await Scheduler.after(Duration(seconds: 2), () {
    socket.callMethod('stop');
  });
}
