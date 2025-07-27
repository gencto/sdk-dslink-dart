import 'package:dsalink/models/node_dto.dart';
import 'package:dsalink/node/ds_node.dart';
import 'package:dsalink/node/node_builder.dart';

class NodeSerializer {
  NodeSerializer._();

  static NodeBuilder builderFromDTO(NodeDTO dto) {
    final builder = NodeBuilder(dto.name);

    if (dto.value != null) {
      builder.withValue(dto.value);
    }

    if (dto.attributes != null) {
      for (final entry in dto.attributes!.entries) {
        builder.withAttribute(entry.key, entry.value);
      }
    }

    if (dto.action == true) {
      builder.onInvoke(
        (params) async => {'info': 'Invoke on ${dto.name}', 'params': params},
      );
    }

    if (dto.children != null) {
      for (final child in dto.children!) {
        builder.addChild(builderFromDTO(child));
      }
    }

    return builder;
  }

  static DsNode fromDTO(NodeDTO dto) => builderFromDTO(dto).build();

  static NodeDTO toDTO(DsNode node) => NodeDTO(
      name: node.name,
      value: node.value,
      attributes: node.attributes.isEmpty ? null : node.attributes,
      action: node.hasAction ? true : null,
      children: node.children.isEmpty
          ? null
          : node.children.values.map(toDTO).toList(),
    );
}
