import 'dart:async';

import 'package:dsalink/node/ds_node.dart';

class ValueNode extends DsNode {
  dynamic _value;
  final StreamController<dynamic> _controller = StreamController<dynamic>.broadcast();
  
  // Performance optimization: Cache the last value to avoid unnecessary updates
  dynamic _lastEmittedValue;
  
  // Performance optimization: Debounce rapid value changes
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 50);

  ValueNode(super.name, this._value) {
    _lastEmittedValue = _value;
  }

  @override
  dynamic get value => _value;

  @override
  set value(dynamic newValue) {
    // Performance optimization: Only update if value actually changed
    if (_value == newValue) return;
    
    _value = newValue;
    
    // Performance optimization: Debounce rapid changes to prevent spam
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      // Only emit if the value is still different from last emitted
      if (_lastEmittedValue != _value) {
        _lastEmittedValue = _value;
        if (!_controller.isClosed) {
          _controller.add(_value);
        }
      }
    });
  }

  Stream<dynamic> get onValueChanged => _controller.stream;

  // Performance optimization: Dispose method to clean up resources
  void dispose() {
    _debounceTimer?.cancel();
    _controller.close();
  }

  // Performance optimization: Force immediate value update (bypass debouncing)
  void forceUpdate() {
    _debounceTimer?.cancel();
    if (_lastEmittedValue != _value) {
      _lastEmittedValue = _value;
      if (!_controller.isClosed) {
        _controller.add(_value);
      }
    }
  }

  // Performance optimization: Check if node has pending updates
  bool get hasPendingUpdate => _debounceTimer?.isActive == true;
}

class ReadOnlyValueNode extends ValueNode {
  ReadOnlyValueNode(super.name, super.initialValue) {
    setAttribute('@writable', 'never');
  }
}
