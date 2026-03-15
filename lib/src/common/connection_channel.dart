part of dsalink.common;

class PassiveChannel implements ConnectionChannel {
  final StreamController<List<DSAMessage>> onReceiveController =
      StreamController<List<DSAMessage>>();
  @override
  Stream<List<DSAMessage>> get onReceive => onReceiveController.stream;

  // List<Function> _processors = [];

  final Connection? conn;

  PassiveChannel(this.conn, [bool connected = false]) : _state = connected ? ConnectedState(DateTime.now()) : const DisconnectedState();

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
  bool get connected => _state.isConnected;

  ConnectionState _state;
  @override
  ConnectionState get state => _state;

  final Completer<ConnectionChannel> onDisconnectController =
      Completer<ConnectionChannel>();
  @override
  Future<ConnectionChannel> get onDisconnected => onDisconnectController.future;

  final Completer<ConnectionChannel> onConnectController =
      Completer<ConnectionChannel>();
  @override
  Future<ConnectionChannel> get onConnected => onConnectController.future;

  void updateConnect() {
    if (_state.isConnected) return;
    _state = ConnectedState(DateTime.now());
    onConnectController.complete(this);
  }

  void updateDisconnected() {
    if (_state.isDisconnected) return;
    _state = const DisconnectedState();
    if (!onDisconnectController.isCompleted) {
      onDisconnectController.complete(this);
    }
  }

  void updateError(String message, [Object? error]) {
    _state = ConnectionErrorState(message, error);
    if (!onDisconnectController.isCompleted) {
      onDisconnectController.complete(this);
    }
  }
}
