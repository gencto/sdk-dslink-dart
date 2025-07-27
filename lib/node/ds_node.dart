import 'package:dsalink/node/node_action.dart';

class DsNode {
  DsNode(this.name, {this.value, this.action});
  final String name;
  DsNode? parent;
  final Map<String, DsNode> children = {};
  final Map<String, dynamic> attributes = {};
  dynamic value;
  NodeAction? action;

  String get path {
    if (parent == null) {
      return '/$name';
    }
    return '${parent!.path}/$name';
  }

  void addChild(DsNode node) {
    node.parent = this;
    children[node.name] = node;
  }

  void removeChild(String name) {
    children[name]?.dispose();
    children.remove(name);
  }

  DsNode? getChild(String name) => children[name];

  bool get hasAction => action != null;

  void setAttribute(String key, val) {
    attributes[key] = val;
  }

  Map<String, dynamic> getSerializableAttributes() {
    final map = <String, dynamic>{};
    for (final entry in attributes.entries) {
      if (entry.key.startsWith('@')) {
        map[entry.key] = entry.value;
      }
    }
    return map;
  }

  Future<dynamic> invoke(Map<String, dynamic> params) {
    if (action != null) {
      return action!.invoke(params, this);
    }
    throw Exception("Node '$path' has no action.");
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    if (value != null) 'value': value,
    if (attributes.isNotEmpty) 'attributes': attributes,
    if (hasAction) 'action': true,
    if (children.isNotEmpty)
      'children': children.values.map((c) => c.toJson()).toList(),
  };

  void dispose() {}
}
