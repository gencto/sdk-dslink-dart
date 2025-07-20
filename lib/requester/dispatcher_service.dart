import 'dart:developer' as developer;

import 'package:dsalink/models/ds_request.dart';
import 'package:dsalink/models/invoke_request.dart';
import 'package:dsalink/models/list_request.dart';
import 'package:dsalink/models/remove_request.dart';
import 'package:dsalink/models/set_request.dart';
import 'package:dsalink/models/subscribe_request.dart';
import 'package:dsalink/models/unsubscribe_request.dart';

// Performance optimization: Use typedef for handlers to enable caching
typedef RequestHandler<T extends DsRequest> = void Function(T request);

class DispatcherService {
  // Performance optimization: Pre-computed dispatch table
  late final Map<Type, RequestHandler<DsRequest>> _handlers;
  
  // Performance optimization: Enable/disable logging for production
  static bool loggingEnabled = false;
  
  DispatcherService() {
    _handlers = <Type, RequestHandler<DsRequest>>{
      ListRequest: (req) => _handleList(req as ListRequest),
      InvokeRequest: (req) => _handleInvoke(req as InvokeRequest),
      SetRequest: (req) => _handleSet(req as SetRequest),
      RemoveRequest: (req) => _handleRemove(req as RemoveRequest),
      SubscribeRequest: (req) => _handleSubscribe(req as SubscribeRequest),
      UnsubscribeRequest: (req) => _handleUnsubscribe(req as UnsubscribeRequest),
    };
  }

  void dispatch(DsRequest request) {
    final handler = _handlers[request.runtimeType];
    if (handler != null) {
      handler(request);
    } else {
      throw UnsupportedError("Unknown request type: ${request.runtimeType}");
    }
  }

  void _handleList(ListRequest req) {
    _log("📘 Handling LIST for path: ${req.path}");
  }

  void _handleInvoke(InvokeRequest req) {
    _log("🔁 Handling INVOKE at ${req.path} with params: ${req.params}");
  }

  void _handleSet(SetRequest req) {
    _log("💾 Handling SET at ${req.path} to value: ${req.value}");
  }

  void _handleRemove(RemoveRequest req) {
    _log("❌ Handling REMOVE at ${req.path}");
  }

  void _handleSubscribe(SubscribeRequest req) {
    _log("📡 Handling SUBSCRIBE to paths: ${req.paths.map((p) => p.path)}");
  }

  void _handleUnsubscribe(UnsubscribeRequest req) {
    _log("🔕 Handling UNSUBSCRIBE for sids: ${req.sids}");
  }

  // Performance optimization: Centralized logging that can be disabled
  void _log(String message) {
    if (loggingEnabled) {
      // Use developer.log instead of print for better performance in production
      developer.log(message, name: 'DispatcherService');
    }
  }

  // Performance optimization: Batch dispatch for multiple requests
  void dispatchBatch(List<DsRequest> requests) {
    for (final request in requests) {
      try {
        dispatch(request);
      } catch (e) {
        _log("Error dispatching ${request.runtimeType}: $e");
      }
    }
  }
}
