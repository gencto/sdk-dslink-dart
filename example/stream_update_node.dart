import 'dart:async';

import 'package:dsalink/node/value_node.dart';

void main() async {
  final cpuStream = Stream.periodic(
    const Duration(seconds: 2),
    (i) => (20 + i % 40).toDouble(),
  );

  final cpuNode = ValueNode.streamed(
    'cpu_usage',
    cpuStream,
    initialValue: 20.0,
    attributes: {'@type': 'number', '@unit': '%'},
  );

  cpuNode.onValueChanged.listen((value) {
    print('🔄 CPU Usage: $value%');
  });

  final tempStream = Stream.periodic(
    const Duration(milliseconds: 200),
    (i) => i,
  ).take(10);

  // Create a debounce transformer
  final debounced = StreamTransformer<int, int>.fromBind((stream) {
    Timer? timer;
    final controller = StreamController<int>();

    stream.listen((data) {
      timer?.cancel();
      timer = Timer(const Duration(seconds: 10), () {
        controller.add(data);
      });
    });

    return controller.stream;
  });

  final node = ValueNode.streamed(
    'temp',
    tempStream,
    transformer: debounced,
    attributes: {'@type': 'number'},
  );
}
