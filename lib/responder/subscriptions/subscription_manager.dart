import 'dart:async';
import 'dart:convert';

import 'package:dsalink/core/transport_contract.dart';
import 'package:dsalink/node/ds_node.dart';
import 'package:dsalink/node/value_node.dart';

class SubscriptionManager {
  final ITransport transport;

  final Map<String, List<int>> _subscribers = <String, List<int>>{};
  final Map<String, StreamSubscription<dynamic>> _activeStreams = <String, StreamSubscription<dynamic>>{};
  
  // Performance optimization: Batch updates to reduce transport overhead
  final Map<String, dynamic> _pendingUpdates = <String, dynamic>{};
  Timer? _batchTimer;
  static const Duration _batchDelay = Duration(milliseconds: 16); // ~60fps

  SubscriptionManager(this.transport);

  void subscribe(String path, int rid, DsNode node) {
    _subscribers.putIfAbsent(path, () => <int>[]).add(rid);

    if (!_activeStreams.containsKey(path) && node is ValueNode) {
      final sub = node.onValueChanged.listen((value) {
        _scheduleUpdate(path, value);
      });
      _activeStreams[path] = sub;
    }
  }

  void unsubscribe(String path, int rid) {
    final rids = _subscribers[path];
    if (rids == null) return;

    rids.remove(rid);
    if (rids.isEmpty) {
      _subscribers.remove(path);
      // Performance fix: Properly cancel subscriptions to prevent memory leaks
      final subscription = _activeStreams.remove(path);
      subscription?.cancel();
    }
  }

  // Performance optimization: Batch updates to reduce transport calls
  void _scheduleUpdate(String path, dynamic value) {
    _pendingUpdates[path] = value;
    
    _batchTimer?.cancel();
    _batchTimer = Timer(_batchDelay, _processBatchedUpdates);
  }

  void _processBatchedUpdates() {
    if (_pendingUpdates.isEmpty) return;
    
    final updates = <Map<String, dynamic>>[];
    
    for (final entry in _pendingUpdates.entries) {
      final path = entry.key;
      final value = entry.value;
      final rids = _subscribers[path];
      
      if (rids != null && rids.isNotEmpty) {
        for (final rid in rids) {
          updates.add({
            'rid': rid, 
            'method': 'update', 
            'path': path, 
            'value': value
          });
        }
      }
    }
    
    if (updates.isNotEmpty) {
      // Send batched updates in a single message
      _sendBatchedUpdates(updates);
    }
    
    _pendingUpdates.clear();
  }

  Future<void> _sendBatchedUpdates(List<Map<String, dynamic>> updates) async {
    // Performance optimization: Send as batch array instead of individual messages
    final batchMessage = jsonEncode({'type': 'batch', 'updates': updates});
    await transport.send(batchMessage);
  }

  // Fallback for individual updates (maintain backward compatibility)
  Future<void> _sendUpdate(int rid, String path, dynamic value) async {
    final msg = {'rid': rid, 'method': 'update', 'path': path, 'value': value};
    await transport.send(jsonEncode(msg));
  }

  // Performance optimization: Cleanup method to prevent memory leaks
  void dispose() {
    _batchTimer?.cancel();
    for (final subscription in _activeStreams.values) {
      subscription.cancel();
    }
    _activeStreams.clear();
    _subscribers.clear();
    _pendingUpdates.clear();
  }
}
