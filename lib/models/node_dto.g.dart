// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NodeDTOImpl _$$NodeDTOImplFromJson(Map<String, dynamic> json) =>
    _$NodeDTOImpl(
      name: json['name'] as String,
      value: json['value'],
      attributes: json['attributes'] as Map<String, dynamic>?,
      action: json['action'] as bool?,
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => NodeDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$NodeDTOImplToJson(_$NodeDTOImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
      'attributes': instance.attributes,
      'action': instance.action,
      'children': instance.children,
    };
