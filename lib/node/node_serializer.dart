import 'package:dsalink/node/ds_node.dart';
import 'package:dsalink/node/node_builder.dart';

class NodeSerializer {
  NodeSerializer._();

  static DsNode fromJson(Map<String, dynamic> json) {
    final builder = NodeBuilder(json['name'] as String);

    if (json.containsKey('value')) {
      builder.withValue(json['value']);
    }

    final attrs = json['attributes'] as Map<String, dynamic>? ?? {};
    for (final entry in attrs.entries) {
      builder.withAttribute(entry.key, entry.value);
    }

    if (json['action'] == true) {
      builder.onInvoke((params) async {
        return {'info': 'This is a placeholder action for "${json['name']}"'};
      });
    }

    final children = json['children'] as List<dynamic>? ?? [];
    for (final child in children) {
      final childNode = fromJson(child as Map<String, dynamic>);
      final childBuilder = NodeBuilder(childNode.name);
      for (final attr in childNode.attributes.entries) {
        childBuilder.withAttribute(attr.key, attr.value);
      }
      builder.addChild(childBuilder);
    }

    return builder.build();
  }
}
