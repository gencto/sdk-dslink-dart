import 'dart:async';
import 'dart:developer' as developer;

import 'package:dsalink/core/transport_contract.dart';
import 'package:dsalink/node/ds_node.dart';
import 'package:dsalink/responder/responder_router.dart';
import 'package:dsalink/transport/websocket_transport.dart';
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

    final wsUri = await handshakeClient.performHandshake();
    _log('🔄 Connecting to WebSocket: $wsUri');

    final transport = WebSocketTransport(wsUri.toString());
    await transport.connect();

    final router = ResponderRouter(rootNode, transport);

    // Performance optimization: Track message processing rate
    transport.onMessage.listen((message) {
      _messagesProcessed++;
      router.handle(message);
      
      // Log performance stats every 1000 messages
      if (_messagesProcessed % 1000 == 0) {
        _logPerformanceStats();
      }
    });

    _log('✅ DSLink Responder connected & running!');
  }

  // Performance optimization: Centralized logging that can be disabled
  void _log(String message) {
    if (loggingEnabled) {
      // Use developer.log instead of print for better performance in production
      developer.log(message, name: 'WebSocketResponder');
    }
  }

  // Performance optimization: Track and log performance metrics
  void _logPerformanceStats() {
    if (_startTime != null && loggingEnabled) {
      final duration = DateTime.now().difference(_startTime!);
      final messagesPerSecond = _messagesProcessed / duration.inSeconds;
      _log('📊 Performance: ${messagesPerSecond.toStringAsFixed(2)} messages/sec, Total: $_messagesProcessed');
    }
  }

  // Performance optimization: Get current performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    final uptime = _startTime != null ? DateTime.now().difference(_startTime!) : Duration.zero;
    return {
      'messagesProcessed': _messagesProcessed,
      'uptimeSeconds': uptime.inSeconds,
      'messagesPerSecond': _messagesProcessed / (uptime.inSeconds == 0 ? 1 : uptime.inSeconds),
      'startTime': _startTime?.toIso8601String(),
    };
  }
}
