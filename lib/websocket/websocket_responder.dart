import 'package:dsalink/node/ds_node.dart';
import 'package:dsalink/responder/responder_service.dart';
import 'package:dsalink/transport/websocket_transport.dart';
import 'package:dsalink/utils/logger.dart';
import 'package:dsalink/websocket/handshake_client.dart';

class WebSocketResponder {
  final String brokerBaseUrl;
  final String linkName;
  final String token;
  final DsNode root;

  static final _logger = DSALogger.category('WebSocketResponder');

  WebSocketResponder({
    required this.brokerBaseUrl,
    required this.linkName,
    required this.token,
    required this.root,
  });

  Future<void> start() async {
    final handshakeClient = HandshakeClient(
      brokerUrl: brokerBaseUrl,
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
