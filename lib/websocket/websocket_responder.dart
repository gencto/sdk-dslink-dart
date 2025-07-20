import 'dart:async';
import 'dart:developer' as developer;

import 'package:dsalink/core/transport_contract.dart';
import 'package:dsalink/node/ds_node.dart';
import 'package:dsalink/responder/responder_router.dart';
import 'package:dsalink/transport/websocket_transport.dart';
import 'package:dsalink/utils/logger.dart';
import 'package:dsalink/websocket/handshake_client.dart';

class WebSocketResponder {
  final String brokerUrl;
  final String linkName;
  final String token;
  final DsNode rootNode;

  // Performance optimization: Enable/disable logging for production
  static bool loggingEnabled = true;
  
  // Performance optimization: Track performance metrics
  int _messagesProcessed = 0;
  DateTime? _startTime;

  static final _logger = DSALogger.category('WebSocketResponder');

  WebSocketResponder({
    required this.brokerUrl,
    required this.linkName,
    required this.token,
    required this.rootNode,
  });

  Future<void> start() async {
    _startTime = DateTime.now();
    
    _log('🔐 Performing handshake...');
    final handshakeClient = HandshakeClient(
      brokerUrl: brokerUrl,
      linkName: linkName,
      token: token,
    );
    
    _logger.info('Performing handshake with broker', context: {
      'brokerUrl': brokerBaseUrl,
      'linkName': linkName,
    });
    
    try {
      final wsUri = await handshakeClient.performHandshake();

      _logger.info('Connecting to WebSocket', context: {
        'wsUri': wsUri.toString(),
      });
      
      final transport = WebSocketTransport(wsUri.toString());
      final responder = ResponderService(transport, root);
      await responder.start();

      _logger.info('DSLink Responder connected & running successfully');
    } catch (error, stackTrace) {
      _logger.error('Failed to start WebSocket responder', 
        error: error, 
        stackTrace: stackTrace,
        context: {
          'brokerUrl': brokerBaseUrl,
          'linkName': linkName,
        }
      );
      rethrow;
    }
  }
}
