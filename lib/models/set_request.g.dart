// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SetRequestImpl _$$SetRequestImplFromJson(Map<String, dynamic> json) =>
    _$SetRequestImpl(
      rid: (json['rid'] as num).toInt(),
      path: json['path'] as String,
      value: json['value'],
      permit: json['permit'] as String?,
    );

Map<String, dynamic> _$$SetRequestImplToJson(_$SetRequestImpl instance) =>
    <String, dynamic>{
      'rid': instance.rid,
      'path': instance.path,
      'value': instance.value,
      'permit': instance.permit,
    };
