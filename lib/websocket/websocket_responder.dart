import 'package:dsalink/node/ds_node.dart';
import 'package:dsalink/responder/responder_service.dart';
import 'package:dsalink/transport/websocket_transport.dart';
import 'package:dsalink/websocket/handshake_client.dart';

class WebSocketResponder {
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
    final handshakeClient = HandshakeClient(
      brokerUrl: brokerBaseUrl,
      linkName: linkName,
      token: token,
    );

    print('🔐 Performing handshake...');
    final wsUri = await handshakeClient.performHandshake();

    print('🔄 Connecting to WebSocket: $wsUri');
    final transport = WebSocketTransport(wsUri.toString());

    final responder = ResponderService(transport, root);
    await responder.start();

    print('✅ DSLink Responder connected & running!');
  }
}
