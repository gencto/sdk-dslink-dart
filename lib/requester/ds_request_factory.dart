import 'package:dsalink/models/ds_request.dart';
import 'package:dsalink/models/invoke_request.dart';
import 'package:dsalink/models/list_request.dart';
import 'package:dsalink/models/remove_request.dart';
import 'package:dsalink/models/set_request.dart';
import 'package:dsalink/models/subscribe_request.dart';
import 'package:dsalink/models/unsubscribe_request.dart';

class DsRequestFactory {
  DsRequestFactory._();
  static DsRequest fromDto(Map<String, dynamic> json) {
    final method = json['method']?.toLowerCase();

    switch (method) {
      case 'list':
        return ListRequest.fromJson(json);
      case 'set':
        return SetRequest.fromJson(json);
      case 'invoke':
        return InvokeRequest.fromJson(json);
      case 'remove':
        return RemoveRequest.fromJson(json);
      case 'subscribe':
        return SubscribeRequest.fromJson(json);
      case 'unsubscribe':
        return UnsubscribeRequest.fromJson(json);
      default:
        throw UnsupportedError("Unsupported method: $method");
    }
  }
}
