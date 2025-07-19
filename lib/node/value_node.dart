import 'dart:async';

import 'package:dsalink/node/ds_node.dart';

class ValueNode extends DsNode {
  final _controller = StreamController<dynamic>.broadcast();

  ValueNode(super.name, dynamic initialValue) : super(value: initialValue);

  void updateValue(dynamic newValue) {
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

    node._streamSubscription = boundStream.listen((val) {
      node.updateValue(val);
    });

    return node;
  }

  StreamSubscription? _streamSubscription;
}

class ReadOnlyValueNode extends ValueNode {
  ReadOnlyValueNode(super.name, super.initialValue) {
    setAttribute('@writable', 'never');
  }
}
