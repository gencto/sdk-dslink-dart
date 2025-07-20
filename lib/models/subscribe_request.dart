import 'package:dsalink/models/ds_request.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscribe_request.freezed.dart';
part 'subscribe_request.g.dart';

@freezed
class SubscribePath with _$SubscribePath {
  const factory SubscribePath({
    required String path,
    required int sid,
    int? qos,
  }) = _SubscribePath;

  factory SubscribePath.fromJson(Map<String, dynamic> json) =>
      _$SubscribePathFromJson(json);
}

@freezed
class SubscribeRequest with _$SubscribeRequest implements DsRequest {
  const factory SubscribeRequest({
    required int rid,
    required List<SubscribePath> paths,
  }) = _SubscribeRequest;

  factory SubscribeRequest.fromJson(Map<String, dynamic> json) =>
      _$SubscribeRequestFromJson(json);
}
