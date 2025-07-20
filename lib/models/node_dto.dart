import 'package:freezed_annotation/freezed_annotation.dart';

part 'node_dto.freezed.dart';
part 'node_dto.g.dart';

@freezed
class NodeDTO with _$NodeDTO {
  const factory NodeDTO({
    required String name,
    dynamic value,
    Map<String, dynamic>? attributes,
    bool? action,
    List<NodeDTO>? children,
  }) = _NodeDTO;

  factory NodeDTO.fromJson(Map<String, dynamic> json) =>
      _$NodeDTOFromJson(json);
}
