part of dsalink.browser_client;

/// a client link for both http and ws
class BrowserUserLink extends ClientLink {
  final Completer<Requester> _onRequesterReadyCompleter =
      Completer<Requester>();

  @override
  Future<Requester> get onRequesterReady => _onRequesterReadyCompleter.future;

  static String session =
      DSRandom.instance.nextUint16().toRadixString(16) +
      DSRandom.instance.nextUint16().toRadixString(16) +
      DSRandom.instance.nextUint16().toRadixString(16) +
      DSRandom.instance.nextUint16().toRadixString(16);
  @override
  final Requester? requester;
  @override
  final Responder? responder;

  @override
  final ECDH nonce = const DummyECDH();
  @override
  late PrivateKey privateKey;

  WebSocketConnection? _wsConnection;

  bool enableAck;

  static const Map<String, int> saltNameMap = {'salt': 0, 'saltS': 1};

  @override
  void updateSalt(String salt) {
    // TODO: implement updateSalt
  }

  late String wsUpdateUri;
  String format = 'json';

  BrowserUserLink({
    NodeProvider? nodeProvider,
    bool isRequester = true,
    bool isResponder = true,
    required this.wsUpdateUri,
    this.enableAck = false,
    String? format,
  }) : requester = isRequester ? Requester() : null,
       responder =
           (isResponder && nodeProvider != null)
               ? Responder(nodeProvider)
               : null {
    if (wsUpdateUri.startsWith('http')) {
      wsUpdateUri = 'ws${wsUpdateUri.substring(4)}';
    }

    if (format != null) {
      this.format = format;
    }

    if (window.location.hash.contains('dsa_json')) {
      this.format = 'json';
    }
  }

  @override
  void connect() {
    lockCryptoProvider();
    initWebsocket(false);
  }

  int _wsDelay = 1;

  void initWebsocket([bool reconnect = true]) {
    var socket = WebSocket('$wsUpdateUri?session=$session&format=$format');
    _wsConnection = WebSocketConnection(
      socket,
      this,
      enableAck: enableAck,
      useCodec: DsCodec.getCodec(format),
    );

    if (responder != null) {
      responder!.connection = _wsConnection!.responderChannel;
    }

    if (requester != null) {
      _wsConnection!.onRequesterReady.then((channel) {
        requester!.connection = channel;
        if (!_onRequesterReadyCompleter.isCompleted) {
          _onRequesterReadyCompleter.complete(requester);
        }
      });
    }
    _wsConnection!.onDisconnected.then((connection) {
      logger.info('Disconnected');
      if (_wsConnection == null) {
        // connection is closed
        return;
      }
      if (_wsConnection!._opened) {
        _wsDelay = 1;
        initWebsocket(false);
      } else if (reconnect) {
        DsTimer.timerOnceAfter(initWebsocket, _wsDelay * 1000);
        if (_wsDelay < 60) _wsDelay++;
      } else {
        _wsDelay = 5;
        DsTimer.timerOnceAfter(initWebsocket, 5000);
      }
    });
  }

  void reconnect() {
    if (_wsConnection != null) {
      _wsConnection!.socket.close();
    }
  }

  @override
  void close() {
    if (_wsConnection != null) {
      _wsConnection!.close();
      _wsConnection = null;
    }
  }
}
