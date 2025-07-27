import 'dart:async';
import 'dart:convert';

import 'package:dsalink/core/transport_contract.dart';
import 'package:dsalink/node/ds_node.dart';
import 'package:dsalink/node/value_node.dart';

class SubscriptionManager {
  SubscriptionManager(this.transport);

  final ITransport transport;

  final Map<String, List<int>> _subscribers = {};
  final Map<String, StreamSubscription> _activeStreams = {};

  void subscribe(String path, int rid, DsNode node) {
    _subscribers.putIfAbsent(path, () => []).add(rid);

    if (!_activeStreams.containsKey(path) && node is ValueNode) {
      // ignore: cancel_subscriptions
      final sub = node.onValueChanged.listen((value) {
        final rids = _subscribers[path]!;
        for (final rid in rids) {
          unawaited(_sendUpdate(rid, path, value));
        }
      });
      _activeStreams[path] = sub;
    }
  }

  Future<void> unsubscribe(String path, int rid) async {
    final rids = _subscribers[path];
    if (rids == null) {
      return;
    }

    rids.remove(rid);
    if (rids.isEmpty) {
      _subscribers.remove(path);
      await _activeStreams.remove(path)?.cancel();
    }
  }

  Future<void> _sendUpdate(int rid, String path, value) async {
    final msg = {'rid': rid, 'method': 'update', 'path': path, 'value': value};
    await transport.send(jsonEncode(msg));
  }
}
