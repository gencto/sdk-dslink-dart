import 'dart:async';

import 'package:dsalink/node/ds_node.dart';

class ValueNode extends DsNode {

  ValueNode(super.name, initialValue) : super(value: initialValue);
  final _controller = StreamController<dynamic>.broadcast();

  void updateValue(newValue) {
    if (newValue != value) {
      value = newValue;
      _controller.add(value);
    }
  }

  Stream<dynamic> get onValueChanged => _controller.stream;

  @override
  void dispose() {
    _controller.close();
    _streamSubscription?.cancel();
  }

  static ValueNode streamed<T>(
    String name,
    Stream<T> stream, {
    T? initialValue,
    Map<String, dynamic>? attributes,
    StreamTransformer<T, dynamic>? transformer,
  }) {
    final node = ValueNode(name, initialValue);

    if (attributes != null) {
      for (final entry in attributes.entries) {
        node.setAttribute(entry.key, entry.value);
      }
    }

    final boundStream = transformer != null
        ? stream.transform(transformer)
        : stream;

    node._streamSubscription = boundStream.listen(node.updateValue);

    return node;
  }

  StreamSubscription? _streamSubscription;
}

class ReadOnlyValueNode extends ValueNode {
  ReadOnlyValueNode(super.name, super.initialValue) {
    setAttribute('@writable', 'never');
  }
}
