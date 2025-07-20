import 'package:dsalink/models/ds_request.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'list_request.freezed.dart';
part 'list_request.g.dart';

@freezed
class ListRequest with _$ListRequest implements DsRequest {
  const factory ListRequest({required int rid, required String path}) =
      _ListRequest;

  factory ListRequest.fromJson(Map<String, dynamic> json) =>
      _$ListRequestFromJson(json);
}
