import 'package:dsalink/models/ds_request.dart';
import 'package:dsalink/models/invoke_request.dart';
import 'package:dsalink/models/list_request.dart';
import 'package:dsalink/models/remove_request.dart';
import 'package:dsalink/models/set_request.dart';
import 'package:dsalink/models/subscribe_request.dart';
import 'package:dsalink/models/unsubscribe_request.dart';

class DispatcherService {
  void dispatch(DsRequest request) {
    switch (request.runtimeType) {
      case ListRequest _:
        _handleList(request as ListRequest);
      case InvokeRequest _:
        _handleInvoke(request as InvokeRequest);
      case SetRequest _:
        _handleSet(request as SetRequest);
      case RemoveRequest _:
        _handleRemove(request as RemoveRequest);
      case SubscribeRequest _:
        _handleSubscribe(request as SubscribeRequest);
      case UnsubscribeRequest _:
        _handleUnsubscribe(request as UnsubscribeRequest);

      default:
        throw UnsupportedError("Unknown request type: ${request.runtimeType}");
    }
  }

  void _handleList(ListRequest req) {
    print("📘 Handling LIST for path: ${req.path}");
  }

  void _handleInvoke(InvokeRequest req) {
    print("🔁 Handling INVOKE at ${req.path} with params: ${req.params}");
  }

  void _handleSet(SetRequest req) {
    print("💾 Handling SET at ${req.path} to value: ${req.value}");
  }

  void _handleRemove(RemoveRequest req) {
    print("❌ Handling REMOVE at ${req.path}");
  }

  void _handleSubscribe(SubscribeRequest req) {
    print("📡 Handling SUBSCRIBE to paths: ${req.paths.map((p) => p.path)}");
  }

  void _handleUnsubscribe(UnsubscribeRequest req) {
    print("🔕 Handling UNSUBSCRIBE for sids: ${req.sids}");
  }
}
