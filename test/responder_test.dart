import 'dart:async';
import 'dart:convert';

import 'package:dsalink/core/transport_contract.dart';
import 'package:dsalink/node/action_node.dart';
import 'package:dsalink/node/ds_node.dart';
import 'package:dsalink/node/value_node.dart';
import 'package:dsalink/responder/responder_router.dart';
import 'package:test/test.dart';

class TestTransport implements ITransport {
  final _controller = StreamController<String>();
  final List<String> sentMessages = [];

  @override
  Future<void> connect() async {}

  @override
  Future<String> send(String message) async {
    sentMessages.add(message);
    return 'ok';
  }

  @override
  Stream<String> get onMessage => _controller.stream;

  void simulateRequest(String json) => _controller.add(json);

  @override
  void close() {}
}

void main() {
  test('Responder handles invoke correctly', () async {
    final root = DsNode('root');
    root.addChild(ActionNode('echo', (params) async => params['msg']));

    final transport = TestTransport();
    final router = ResponderRouter(root, transport);

    await router.handle(
      '{"rid":1,"method":"invoke","path":"/echo","params":{"msg":"hi"}}',
    );

    expect(transport.sentMessages.length, 1);
    expect(transport.sentMessages[0], contains('"status":"ok"'));
    expect(transport.sentMessages[0], contains('"hi"'));
  });

  test('subscribe triggers updates', () async {
    final valueNode = ValueNode('temperature', 20);
    final root = DsNode('root')..addChild(valueNode);

    final transport = TestTransport();
    final router = ResponderRouter(root, transport);

    await router.handle(
      jsonEncode({
        'rid': 100,
        'method': 'subscribe',
        'path': '/temperature',
        'params': {},
      }),
    );

    valueNode.updateValue(21);

    await Future.delayed(const Duration(seconds: 1));

    final found = transport.sentMessages.any((msg) => msg.contains('21'));
    expect(found, isTrue);
  });

  test('list returns node metadata', () async {
    final root = DsNode('root');
    final node = ValueNode('voltage', 220)
      ..setAttribute('@type', 'number')
      ..setAttribute('@unit', 'V');
    root.addChild(node);

    final transport = TestTransport();
    final router = ResponderRouter(root, transport);

    await router.handle(jsonEncode({'rid': 2, 'method': 'list', 'path': '/'}));

    final response = transport.sentMessages.last;
    expect(response, contains('"@type":"number"'));
    expect(response, contains('"@unit":"V"'));
  });
}
