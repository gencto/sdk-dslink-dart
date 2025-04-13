part of dsalink.common;

class PassiveChannel implements ConnectionChannel {
  final StreamController<List> onReceiveController = StreamController<List>();
  @override
  Stream<List> get onReceive => onReceiveController.stream;

  // List<Function> _processors = [];

  final Connection? conn;

  PassiveChannel(this.conn, [this.connected = false]);

  ConnectionHandler? handler;
  @override
  void sendWhenReady(ConnectionHandler handler) {
    this.handler = handler;
    conn?.requireSend();
  }

  ProcessorResult? getSendingData(int currentTime, int waitingAckId) {
    if (handler != null) {
      var rslt = handler!.getSendingData(currentTime, waitingAckId);
      //handler = null;
      return rslt;
    }
    return null;
  }

  bool _isReady = false;
  @override
  bool get isReady => _isReady;
  set isReady(bool val) {
    _isReady = val;
  }

  @override
  bool connected = true;

  final Completer<ConnectionChannel> onDisconnectController =
      Completer<ConnectionChannel>();
  @override
  Future<ConnectionChannel> get onDisconnected => onDisconnectController.future;

  final Completer<ConnectionChannel> onConnectController =
      Completer<ConnectionChannel>();
  @override
  Future<ConnectionChannel> get onConnected => onConnectController.future;

  void updateConnect() {
    if (connected) return;
    connected = true;
    onConnectController.complete(this);
  }
}
