import 'package:dsalink/models/ds_request.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'unsubscribe_request.freezed.dart';
part 'unsubscribe_request.g.dart';

@freezed
class UnsubscribeRequest with _$UnsubscribeRequest implements DsRequest {
  const factory UnsubscribeRequest({
    required int rid,
    required List<int> sids,
  }) = _UnsubscribeRequest;

  factory UnsubscribeRequest.fromJson(Map<String, dynamic> json) =>
      _$UnsubscribeRequestFromJson(json);
}
