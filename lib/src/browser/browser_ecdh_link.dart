part of dslink.browser_client;

/// a client link for websocket
class BrowserECDHLink extends ClientLink {
  final Completer<Requester> _onRequesterReadyCompleter =
      Completer<Requester>();
  Completer _onConnectedCompleter = Completer<void>();

  Future get onConnected => _onConnectedCompleter.future;

  @override
  Future<Requester> get onRequesterReady => _onRequesterReadyCompleter.future;

  final String dsId;
  final String? token;

  @override
  final Requester? requester;
  @override
  final Responder? responder;
  @override
  final PrivateKey privateKey;

  late ECDH _nonce;

  @override
  ECDH get nonce => _nonce;

  WebSocketConnection? _wsConnection;

  bool enableAck = false;

  late String salt;

  @override
  void updateSalt(String salt) {
    this.salt = salt;
  }

  late String _wsUpdateUri;
  String _conn;
  String? tokenHash;

  /// formats sent to broker
  List<String> formats = ['msgpack', 'json'];

  /// format received from broker
  String format = 'json';

  BrowserECDHLink(this._conn, String dsIdPrefix, PrivateKey privateKey,
      {NodeProvider? nodeProvider,
      bool isRequester = true,
      bool isResponder = true,
      this.token,
      List<String>? formats})
      : privateKey = privateKey,
        dsId = '$dsIdPrefix${privateKey.publicKey.qHash64}',
        requester = isRequester ? Requester() : null,
        responder = (isResponder && nodeProvider != null)
            ? Responder(nodeProvider)
            : null {
    if (!_conn.contains('://')) {
      _conn = 'http://$_conn';
    }
    if (token != null && token!.length > 16) {
      // pre-generate tokenHash
      var tokenId = token!.substring(0, 16);
      var hashStr = CryptoProvider.sha256(toUTF8('$dsId$token'));
      tokenHash = '&token=$tokenId$hashStr';
    }
    if (formats != null) {
      this.formats = formats;
    }
    if (window.location.hash.contains('dsa_json')) {
      formats = ['json'];
    }
  }

  int _connDelay = 1;

  @override
  void connect() async {
    if (_closed) return;
    lockCryptoProvider();
    var connUrl = '$_conn?dsId=$dsId';
    if (tokenHash != null) {
      connUrl = '$connUrl$tokenHash';
    }
    var connUri = Uri.parse(connUrl);
    logger.info('Connecting: $connUri');
    try {
      Map requestJson = <String, dynamic>{
        'publicKey': privateKey.publicKey.qBase64,
        'isRequester': requester != null,
        'isResponder': responder != null,
        'formats': formats,
        'version': DSA_VERSION,
        'enableWebSocketCompression': true
      };
      var request = await HttpRequest.request(connUrl,
          method: 'POST',
          withCredentials: false,
          mimeType: 'application/json',
          sendData: DsJson.encode(requestJson));
      Map serverConfig = DsJson.decode(request.responseText ?? '');
      //read salt
      salt = serverConfig['salt'];

      String tempKey = serverConfig['tempKey'];
      _nonce = await privateKey.getSecret(tempKey);

      if (serverConfig['wsUri'] is String) {
        _wsUpdateUri = '${connUri.resolve(serverConfig['wsUri'])}?dsId=$dsId'
            .replaceFirst('http', 'ws');
        if (tokenHash != null) {
          _wsUpdateUri = '$_wsUpdateUri$tokenHash';
        }
      }

      // server start to support version since 1.0.4
      // and this is the version ack is added
      enableAck = serverConfig.containsKey('version');
      if (serverConfig['format'] is String) {
        format = serverConfig['format'];
      }
      initWebsocket(false);
      _connDelay = 1;
      _wsDelay = 1;
    } catch (err) {
      DsTimer.timerOnceAfter(connect, _connDelay * 1000);
      if (_connDelay < 60) _connDelay++;
    }
  }

  int _wsDelay = 1;

  void initWebsocket([bool reconnect = true]) {
    if (_closed) return;
    var wsUrl = '$_wsUpdateUri&auth=${_nonce.hashSalt(salt)}&format=$format';
    var socket = WebSocket(wsUrl);
    _wsConnection =
        WebSocketConnection(socket, this, enableAck: enableAck, onConnect: () {
      if (!_onConnectedCompleter.isCompleted) {
        _onConnectedCompleter.complete();
      }
    }, useCodec: DsCodec.getCodec(format));

    if (responder != null) {
      responder!.connection = _wsConnection!.responderChannel;
    }

    if (requester != null) {
      _wsConnection!.onRequesterReady.then((channel) {
        if (_closed) return;
        requester!.connection = channel;
        if (!_onRequesterReadyCompleter.isCompleted) {
          _onRequesterReadyCompleter.complete(requester);
        }
      });
    }
    _wsConnection!.onDisconnected.then((authError) {
      logger.info('Disconnected');
      if (_closed) return;

      if (_wsConnection!._opened) {
        _wsDelay = 1;
        if (authError) {
          connect();
        } else {
          initWebsocket(false);
        }
      } else if (reconnect) {
        if (authError) {
          connect();
        } else {
          DsTimer.timerOnceAfter(initWebsocket, _wsDelay * 1000);
          if (_wsDelay < 60) _wsDelay++;
        }
      } else {
        _wsDelay = 5;
        DsTimer.timerOnceAfter(initWebsocket, 5000);
      }
    });
  }

  bool _closed = false;

  @override
  void close() {
    _onConnectedCompleter = Completer<void>();
    if (_closed) return;
    _closed = true;
    if (_wsConnection != null) {
      _wsConnection!.close();
      _wsConnection = null;
    }
  }
}
