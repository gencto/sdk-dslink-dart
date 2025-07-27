import 'package:freezed_annotation/freezed_annotation.dart';

part 'action_parameter.freezed.dart';
part 'action_parameter.g.dart';

@freezed
class ActionParameter with _$ActionParameter {
  const factory ActionParameter({
    required String name,
    required String type,
    String? editor,
    defaultValue,
    min,
    max,
    List<dynamic>? enumValues,
  }) = _ActionParameter;

  factory ActionParameter.fromJson(Map<String, dynamic> json) =>
      _$ActionParameterFromJson(json);
}
