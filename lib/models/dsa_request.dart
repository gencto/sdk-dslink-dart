import 'package:dsalink/models/ds_request.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dsa_request.freezed.dart';
part 'dsa_request.g.dart';

@freezed
class DsaRequest with _$DsaRequest implements DsRequest {
  const factory DsaRequest({
    required int rid,
    required String method,
    String? path,
    Map<String, dynamic>? params,
    value,
    List<dynamic>? paths,
    List<dynamic>? sids,
    String? permit,
  }) = _DsaRequest;

  factory DsaRequest.fromJson(Map<String, dynamic> json) =>
      _$DsaRequestFromJson(json);
}
