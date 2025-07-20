// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unsubscribe_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UnsubscribeRequestImpl _$$UnsubscribeRequestImplFromJson(
  Map<String, dynamic> json,
) => _$UnsubscribeRequestImpl(
  rid: (json['rid'] as num).toInt(),
  sids: (json['sids'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
);

Map<String, dynamic> _$$UnsubscribeRequestImplToJson(
  _$UnsubscribeRequestImpl instance,
) => <String, dynamic>{'rid': instance.rid, 'sids': instance.sids};
