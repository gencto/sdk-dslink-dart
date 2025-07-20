import 'dart:convert';
import 'dart:isolate';

import 'package:dsalink/core/transport_contract.dart';
import 'package:dsalink/node/ds_node.dart';
import 'package:dsalink/responder/subscriptions/subscription_manager.dart';

class ResponderRouter {
  final DsNode root;
  final ITransport transport;
  final SubscriptionManager _subscriptions;
  
  // Performance optimization: Cache for frequently accessed JSON strings
  final Map<String, String> _responseCache = <String, String>{};
  static const int _maxCacheSize = 1000;

  ResponderRouter(this.root, this.transport)
    : _subscriptions = SubscriptionManager(transport);

  Future<void> handle(String message) async {
    // Performance optimization: Use async JSON parsing for large payloads
    final decoded = await _parseJsonAsync(message);
    final method = decoded['method'] as String;
    final path = decoded['path'] as String;
    final params = decoded['params'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final rid = decoded['rid'] as int?;

    try {
      final node = _getNodeByPath(path);
      if (node == null) throw Exception("Node not found at path: $path");

      switch (method) {
        case 'subscribe':
          _subscriptions.subscribe(path, rid!, node);
          await _sendCachedResponse({'subscribed': true}, rid, 'subscribe_success');

        case 'unsubscribe':
          _subscriptions.unsubscribe(path, rid!);
          await _sendCachedResponse({'unsubscribed': true}, rid, 'unsubscribe_success');

        case 'invoke':
          if (!node.hasAction) throw Exception("Node has no action");
          final result = await node.invoke(params);
          await _sendSuccess(result, rid);

        case 'list':
          // Performance optimization: Use StringBuffer for concatenation
          final childrenList = <Map<String, dynamic>>[];
          for (final child in node.children.values) {
            childrenList.add({
              'name': child.name,
              'value': child.value,
              'attributes': child.getSerializableAttributes(),
            });
          }

          await _sendSuccess({'children': childrenList}, rid);
          
        case 'set':
          if (node.attributes['@writable'] == 'never') {
            await _sendError('Node is read-only', rid);
            return;
          }
          node.value = params['value'];
          await _sendSuccess({'value': node.value}, rid);
          
        default:
          await _sendError("Unknown method: $method", rid);
      }
    } catch (e) {
      await _sendError(e.toString(), decoded['rid'] as int?);
    }
  }

  // Performance optimization: Cache frequent path lookups
  static final Map<String, List<String>> _pathCache = <String, List<String>>{};
  
  DsNode? _getNodeByPath(String path) {
    final parts = _pathCache[path] ??= path.split('/')..removeWhere((e) => e.isEmpty);
    DsNode? current = root;
    for (final part in parts) {
      current = current?.getChild(part);
      if (current == null) return null;
    }
    return current;
  }

  // Performance optimization: Async JSON parsing to avoid blocking
  Future<Map<String, dynamic>> _parseJsonAsync(String message) async {
    if (message.length > 1024) {
      // For large payloads, parse in isolate to avoid blocking main thread
      return await Isolate.run(() => jsonDecode(message) as Map<String, dynamic>);
    }
    return jsonDecode(message) as Map<String, dynamic>;
  }

  // Performance optimization: Cache common responses
  Future<void> _sendCachedResponse(Map<String, dynamic> data, int? rid, String cacheKey) async {
    String msg;
    final fullCacheKey = '${cacheKey}_$rid';
    
    if (_responseCache.containsKey(fullCacheKey)) {
      msg = _responseCache[fullCacheKey]!;
    } else {
      msg = jsonEncode({'rid': rid, 'status': 'ok', 'data': data});
      
      // Manage cache size
      if (_responseCache.length >= _maxCacheSize) {
        _responseCache.clear();
      }
      _responseCache[fullCacheKey] = msg;
    }
    
    await transport.send(msg);
  }

  Future<void> _sendSuccess(dynamic data, int? rid) async {
    final msg = jsonEncode({'rid': rid, 'status': 'ok', 'data': data});
    await transport.send(msg);
  }

  Future<void> _sendError(String error, int? rid) async {
    final msg = jsonEncode({'rid': rid, 'status': 'error', 'message': error});
    await transport.send(msg);
  }
}
