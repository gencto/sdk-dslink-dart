import 'package:dsalink/models/ds_request.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'remove_request.freezed.dart';
part 'remove_request.g.dart';

@freezed
class RemoveRequest with _$RemoveRequest implements DsRequest {
  const factory RemoveRequest({required int rid, required String path}) =
      _RemoveRequest;

  factory RemoveRequest.fromJson(Map<String, dynamic> json) =>
      _$RemoveRequestFromJson(json);
}
