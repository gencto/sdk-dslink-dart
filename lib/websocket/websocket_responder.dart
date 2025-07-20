import 'package:dsalink/node/ds_node.dart';
import 'package:dsalink/responder/responder_service.dart';
import 'package:dsalink/transport/websocket_transport.dart';
import 'package:dsalink/websocket/handshake_client.dart';
import 'package:dsalink/utils/logger.dart';
import 'package:logging/logging.dart';

class WebSocketResponder with LoggerMixin {
  final String brokerBaseUrl;
  final String linkName;
  final String token;
  final DsNode root;

  WebSocketResponder({
    required this.brokerBaseUrl,
    required this.linkName,
    required this.token,
    required this.root,
  });

  Future<void> start() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      logInfo('Starting WebSocket responder',
        null, 
        null
      );
      
      final handshakeClient = HandshakeClient(
        brokerUrl: brokerBaseUrl,
        linkName: linkName,
        token: token,
      );

      DsLogger.logSecurity(
        'Handshake initiated',
        'Performing handshake with broker: $brokerBaseUrl',
        component: 'WebSocketResponder',
        context: {
          'linkName': linkName,
          'brokerUrl': brokerBaseUrl,
        },
      );
      
      final wsUri = await handshakeClient.performHandshake();

      DsLogger.logConnection(
        'connecting',
        wsUri.toString(),
        component: 'WebSocketResponder',
        metadata: {
          'linkName': linkName,
          'protocol': 'websocket',
        },
      );
      
      final transport = WebSocketTransport(wsUri.toString());
      final responder = ResponderService(transport, root);
      
      await responder.start();
      
      stopwatch.stop();
      
      DsLogger.logConnection(
        'established',
        wsUri.toString(),
        component: 'WebSocketResponder',
        metadata: {
          'linkName': linkName,
          'protocol': 'websocket',
          'startupTime': stopwatch.elapsedMilliseconds,
        },
      );
      
      DsLogger.logPerformance(
        'WebSocket responder startup',
        stopwatch.elapsed,
        component: 'WebSocketResponder',
        context: {
          'linkName': linkName,
          'brokerUrl': brokerBaseUrl,
        },
      );
      
      logInfo('DSLink Responder connected & running successfully');
    } catch (error, stackTrace) {
      stopwatch.stop();
      
      DsLogger.logError(
        'Failed to start WebSocket responder',
        error,
        stackTrace: stackTrace,
        component: 'WebSocketResponder',
        context: {
          'linkName': linkName,
          'brokerUrl': brokerBaseUrl,
          'attemptDuration': stopwatch.elapsedMilliseconds,
        },
      );
      
      rethrow;
    }
  }
}
