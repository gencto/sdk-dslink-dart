import 'package:dsalink/models/ds_request.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoke_request.freezed.dart';
part 'invoke_request.g.dart';

@freezed
class InvokeRequest with _$InvokeRequest implements DsRequest {
  const factory InvokeRequest({
    required int rid,
    required String path,
    Map<String, dynamic>? params,
    String? permit,
  }) = _InvokeRequest;

  factory InvokeRequest.fromJson(Map<String, dynamic> json) =>
      _$InvokeRequestFromJson(json);
}
