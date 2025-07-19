import 'dart:async';
import 'dart:io';

import 'package:dsalink/core/transport_contract.dart';

class WebSocketTransport implements ITransport {
  late WebSocket _socket;
  final String url;
  final _controller = StreamController<String>.broadcast();

  WebSocketTransport(this.url);

  @override
  Future<void> connect() async {
    _socket = await WebSocket.connect(url);
    _socket.listen(
      (data) => _controller.add(data as String),
      onError: (e) => _controller.addError(e as Object),
      onDone: _controller.close,
    );
  }

  @override
  Future<String> send(String message) async {
    _socket.add(message);
    return await Future.value("sent");
  }

  @override
  Stream<String> get onMessage => _controller.stream;

  @override
  void close() {
    _socket.close();
  }
}
