import 'package:dsalink/models/action_parameter.dart';
import 'package:dsalink/node/action_node.dart';
import 'package:dsalink/node/ds_node.dart';
import 'package:dsalink/node/value_node.dart';

typedef ActionHandler = Future<dynamic> Function(Map<String, dynamic> params);

class NodeBuilder {
  NodeBuilder(this.name);
  
  final String name;
  dynamic value;
  final Map<String, dynamic> attributes = {};
  ActionHandler? action;
  final List<NodeBuilder> _children = [];
  List<ActionParameter>? _params;

  NodeBuilder withValue(val) {
    value = val;
    return this;
  }

  NodeBuilder withType(String type) {
    attributes['@type'] = type;
    return this;
  }

  NodeBuilder withUnit(String unit) {
    attributes['@unit'] = unit;
    return this;
  }

  NodeBuilder writable() {
    attributes['@writable'] = 'write';
    return this;
  }

  NodeBuilder withAttribute(String key, val) {
    attributes[key] = val;
    return this;
  }

  NodeBuilder onInvoke(ActionHandler handler) {
    action = handler;
    return this;
  }

  NodeBuilder addChild(NodeBuilder child) {
    _children.add(child);
    return this;
  }

  DsNode build() {
    late DsNode node;

    if (action != null) {
      node = ActionNode(name, action!);
    } else if (value != null) {
      node = ValueNode(name, value);
    } else {
      node = DsNode(name);
    }

    for (final entry in attributes.entries) {
      node.setAttribute(entry.key, entry.value);
    }

    for (final childBuilder in _children) {
      node.addChild(childBuilder.build());
    }

    if (_params != null) {
      node.setAttribute('@params', _params!.map((p) => p.toJson()).toList());
    }

    return node;
  }

  NodeBuilder withParams(List<ActionParameter> params) {
    _params = params;
    return this;
  }
}
