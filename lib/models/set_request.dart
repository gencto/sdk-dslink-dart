import 'package:dsalink/models/ds_request.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'set_request.freezed.dart';
part 'set_request.g.dart';

@freezed
class SetRequest with _$SetRequest implements DsRequest {
  const factory SetRequest({
    required int rid,
    required String path,
    required dynamic value,
    String? permit,
  }) = _SetRequest;

  factory SetRequest.fromJson(Map<String, dynamic> json) =>
      _$SetRequestFromJson(json);
}
