abstract class ITransport {
  Future<void> connect();
  Future<String> send(String message);
  Stream<String> get onMessage;
  void close();
}
