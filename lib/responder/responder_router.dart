import 'dart:async';
import 'dart:convert';

import 'package:dsalink/core/transport_contract.dart';
import 'package:dsalink/node/ds_node.dart';
import 'package:dsalink/responder/subscriptions/subscription_manager.dart';

class ResponderRouter {

  ResponderRouter(this.root, this.transport)
    : _subscriptions = SubscriptionManager(transport);
  final DsNode root;
  final ITransport transport;
  final SubscriptionManager _subscriptions;

  Future<void> handle(String message) async {
    final decoded = jsonDecode(message);
    final method = decoded['method'] as String;
    final path = decoded['path'] as String;
    final params = decoded['params'] as Map<String, dynamic>? ?? {};
    final rid = decoded['rid'] as int?;

    try {
      final node = _getNodeByPath(path);
      if (node == null) {
        throw Exception('Node not found at path: $path');
      }

      switch (method) {
        case 'subscribe':
          _subscriptions.subscribe(path, rid!, node);
          await _sendSuccess({'subscribed': true}, rid);

        case 'unsubscribe':
          unawaited(_subscriptions.unsubscribe(path, rid!));
          await _sendSuccess({'unsubscribed': true}, rid);

        case 'invoke':
          if (!node.hasAction) {
            throw Exception('Node has no action');
          }
          final result = await node.invoke(params);
          await _sendSuccess(result, rid);

        case 'list':
          final children = node.children.values
              .map(
                (c) => {
                  'name': c.name,
                  'value': c.value,
                  'attributes': c.getSerializableAttributes(),
                },
              )
              .toList();

          await _sendSuccess({'children': children}, rid);
        case 'set':
          if (node.attributes['@writable'] == 'never') {
            await _sendError('Node is read-only', rid);
            return;
          }
          node.value = params['value'];
          await _sendSuccess({'value': node.value}, rid);
        default:
          await _sendError('Unknown method: $method', rid);
      }
    } catch (e) {
      await _sendError(e.toString(), decoded['rid'] as int?);
    }
  }

  DsNode? _getNodeByPath(String path) {
    final parts = path.split('/')..removeWhere((e) => e.isEmpty);
    DsNode? current = root;
    for (final part in parts) {
      current = current?.getChild(part);
      if (current == null) {
        return null;
      }
    }
    return current;
  }

  Future<void> _sendSuccess(data, int? rid) async {
    final msg = jsonEncode({'rid': rid, 'status': 'ok', 'data': data});
    await transport.send(msg);
  }

  Future<void> _sendError(String error, int? rid) async {
    final msg = jsonEncode({'rid': rid, 'status': 'error', 'message': error});
    await transport.send(msg);
  }
}
