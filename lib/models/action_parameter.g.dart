// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActionParameterImpl _$$ActionParameterImplFromJson(
  Map<String, dynamic> json,
) => _$ActionParameterImpl(
  name: json['name'] as String,
  type: json['type'] as String,
  editor: json['editor'] as String?,
  defaultValue: json['defaultValue'],
  min: json['min'],
  max: json['max'],
  enumValues: json['enumValues'] as List<dynamic>?,
);

Map<String, dynamic> _$$ActionParameterImplToJson(
  _$ActionParameterImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'type': instance.type,
  'editor': instance.editor,
  'defaultValue': instance.defaultValue,
  'min': instance.min,
  'max': instance.max,
  'enumValues': instance.enumValues,
};
