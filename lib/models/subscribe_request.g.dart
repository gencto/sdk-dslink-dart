// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribe_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscribePathImpl _$$SubscribePathImplFromJson(Map<String, dynamic> json) =>
    _$SubscribePathImpl(
      path: json['path'] as String,
      sid: (json['sid'] as num).toInt(),
      qos: (json['qos'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$SubscribePathImplToJson(_$SubscribePathImpl instance) =>
    <String, dynamic>{
      'path': instance.path,
      'sid': instance.sid,
      'qos': instance.qos,
    };

_$SubscribeRequestImpl _$$SubscribeRequestImplFromJson(
  Map<String, dynamic> json,
) => _$SubscribeRequestImpl(
  rid: (json['rid'] as num).toInt(),
  paths: (json['paths'] as List<dynamic>)
      .map((e) => SubscribePath.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$SubscribeRequestImplToJson(
  _$SubscribeRequestImpl instance,
) => <String, dynamic>{'rid': instance.rid, 'paths': instance.paths};
