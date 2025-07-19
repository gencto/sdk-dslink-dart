import 'package:dsalink/node/node_builder.dart';
import 'package:dsalink/websocket/websocket_responder.dart';

void main() async {
  final root = NodeBuilder('root')
      .addChild(NodeBuilder('status').withValue('OK').withType('string'))
      .addChild(
        NodeBuilder('hello').onInvoke((params) async {
          return 'Hi ${params['name']}';
        }),
      )
      .build();

  final responder = WebSocketResponder(
    brokerBaseUrl: 'http://localhost:8080',
    linkName: 'dart-responder',
    token: 'my-link-token',
    root: root,
  );

  await responder.start();
}
