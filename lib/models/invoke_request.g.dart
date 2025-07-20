// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoke_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvokeRequestImpl _$$InvokeRequestImplFromJson(Map<String, dynamic> json) =>
    _$InvokeRequestImpl(
      rid: (json['rid'] as num).toInt(),
      path: json['path'] as String,
      params: json['params'] as Map<String, dynamic>?,
      permit: json['permit'] as String?,
    );

Map<String, dynamic> _$$InvokeRequestImplToJson(_$InvokeRequestImpl instance) =>
    <String, dynamic>{
      'rid': instance.rid,
      'path': instance.path,
      'params': instance.params,
      'permit': instance.permit,
    };
