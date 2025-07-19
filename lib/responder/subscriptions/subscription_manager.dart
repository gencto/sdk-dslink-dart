import 'dart:async';
import 'dart:convert';

import 'package:dsalink/core/transport_contract.dart';
import 'package:dsalink/node/ds_node.dart';
import 'package:dsalink/node/value_node.dart';

class SubscriptionManager {
  final ITransport transport;

  final Map<String, List<int>> _subscribers = {};
  final Map<String, StreamSubscription> _activeStreams = {};

  SubscriptionManager(this.transport);

  void subscribe(String path, int rid, DsNode node) {
    _subscribers.putIfAbsent(path, () => []).add(rid);

    if (!_activeStreams.containsKey(path) && node is ValueNode) {
      final sub = node.onValueChanged.listen((value) {
        final rids = _subscribers[path]!;
        for (final rid in rids) {
          _sendUpdate(rid, path, value);
        }
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
      _activeStreams.remove(path)?.cancel();
    }
  }

  Future<void> _sendUpdate(int rid, String path, dynamic value) async {
    final msg = {'rid': rid, 'method': 'update', 'path': path, 'value': value};
    await transport.send(jsonEncode(msg));
  }
}
