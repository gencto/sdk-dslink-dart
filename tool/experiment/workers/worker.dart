import 'package:dsalink/utils.dart' show Scheduler;
import 'package:dsalink/worker.dart';

void main(List<String> args, Map message) async {
  var worker = buildWorkerForScript(message);
  var socket = await worker.init(
    methods: {'hello': (dynamic _) => print('Hello World')},
  );

  print('Worker Started');

  await Scheduler.after(Duration(seconds: 2), () {
    socket.callMethod('stop');
  });
}
