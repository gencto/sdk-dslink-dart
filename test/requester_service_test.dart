import 'dart:async';

import 'package:dsalink/core/request.dart';
import 'package:dsalink/core/transport_contract.dart';
import 'package:dsalink/requester/requester_service.dart';
import 'package:test/test.dart';

class MockTransport implements ITransport {
  final _controller = StreamController<String>();

  @override
  Future<void> connect() async {}

  @override
  Future<String> send(String message) async {
    _controller.add('{"status":"ok","data":{"result":"hello"}}');
    return "mocked";
  }

  @override
  Stream<String> get onMessage => _controller.stream;

  @override
  void close() {}
}

void main() {
  test('Requester sends and receives response', () async {
    final requester = RequesterService(MockTransport());
    final response = await requester.sendRequest(
      DsRequest(method: 'sayHello', params: {}),
    );

    expect(response.status, 'ok');
    expect(response.data, contains('result'));
  });
}
