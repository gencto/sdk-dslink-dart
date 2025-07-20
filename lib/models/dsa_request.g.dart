// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dsa_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DsaRequestImpl _$$DsaRequestImplFromJson(Map<String, dynamic> json) =>
    _$DsaRequestImpl(
      rid: (json['rid'] as num).toInt(),
      method: json['method'] as String,
      path: json['path'] as String?,
      params: json['params'] as Map<String, dynamic>?,
      value: json['value'],
      paths: json['paths'] as List<dynamic>?,
      sids: json['sids'] as List<dynamic>?,
      permit: json['permit'] as String?,
    );

Map<String, dynamic> _$$DsaRequestImplToJson(_$DsaRequestImpl instance) =>
    <String, dynamic>{
      'rid': instance.rid,
      'method': instance.method,
      'path': instance.path,
      'params': instance.params,
      'value': instance.value,
      'paths': instance.paths,
      'sids': instance.sids,
      'permit': instance.permit,
    };
