part of dslink.client;

/// a client link for both http and ws
class HttpClientLink extends ClientLink {
  final Completer<Requester> _onRequesterReadyCompleter =
      Completer<Requester>();
  Completer _onConnectedCompleter = Completer();

  Future<Requester> get onRequesterReady => _onRequesterReadyCompleter.future;

  Future? get onConnected => _onConnectedCompleter.future;

  String? remotePath;

  late final String dsId;
  final String? home;
  final String? token;
  @override
  final PrivateKey privateKey;

  String? tokenHash;

  @override
  Requester? requester;
  @override
  Responder? responder;

  bool useStandardWebSocket = true;
  late final bool strictTls;

  @override
  String? logName;

  late ECDH _nonce;

  @override
  ECDH get nonce => _nonce;

  WebSocketConnection? _wsConnection;

  late String salt;

  @override
  void updateSalt(String salt) {
    this.salt = salt;
  }

  String? _wsUpdateUri;

  final String? _conn;

  bool enableAck = false;

  Map? linkData;

  /// formats sent to broker
  List formats = <String>['msgpack', 'json'];

  /// format received from broker
  String format = 'json';

  HttpClientLink(this._conn, String dsIdPrefix, PrivateKey privateKey,
      {NodeProvider? nodeProvider,
      bool isRequester = true,
      bool isResponder = true,
      Requester? overrideRequester,
      Responder? overrideResponder,
      this.strictTls = false,
      this.home,
      this.token,
      this.linkData,
      List? formats})
      : privateKey = privateKey,
        dsId = '${Path.escapeName(dsIdPrefix)}${privateKey.publicKey.qHash64}' {
    if (isRequester) {
      if (overrideRequester != null) {
        requester = overrideRequester;
      } else {
        requester = Requester();
      }
    }

    if (formats == null &&
        const String.fromEnvironment('dsa.codec.formats') != '') {
      var formatString = const String.fromEnvironment('dsa.codec.formats');
      formats = formatString.split(',');
    }

    if (formats != null) {
      this.formats = formats;
    }

    if (isResponder) {
      if (overrideResponder != null) {
        responder = overrideResponder;
      } else if (nodeProvider != null) {
        responder = Responder(nodeProvider);
      }
    }

    if (token != null && token!.length > 16) {
      // pre-generate tokenHash
      var tokenId = token!.substring(0, 16);
      var hashStr = CryptoProvider.sha256(toUTF8('$dsId$token'));
      tokenHash = '&token=$tokenId$hashStr';
    }
  }

  int _connDelay = 0;

  void connDelay() {
    reconnectWSCount = 0;
    DsTimer.timerOnceAfter(connect, (_connDelay == 0 ? 20 : _connDelay * 500));
    if (_connDelay < 30) _connDelay++;
  }

  @override
  Future connect() async {
    if (_closed) {
      return;
    }

    lockCryptoProvider();
    DsTimer.timerCancel(initWebsocket);

    var headers = {
      'Content-Type': 'application/json',
    };

    var connUrl = '$_conn?dsId=${Uri.encodeComponent(dsId)}';
    if (home != null) {
      connUrl += '&home=$home';
    }
    if (tokenHash != null) {
      connUrl = '$connUrl$tokenHash';
    }
    var connUri = Uri.parse(connUrl);
    logger.info(formatLogMessage('Connecting to $_conn'));

    try {
      var handshakePayload = jsonEncode({
        'publicKey': privateKey.publicKey.qBase64,
        'isRequester': requester != null,
        'isResponder': responder != null,
        'formats': formats,
        'version': DSA_VERSION,
        'enableWebSocketCompression': true,
        if (linkData != null) 'linkData': linkData,
      });

      http.Response response = await http
          .post(connUri, headers: headers, body: handshakePayload)
          .timeout(Duration(minutes: 1));

      if (response.statusCode == 301 || response.statusCode == 302) {
        var newUrl = response.headers['location'];
        if (newUrl != null) {
          response = await http.post(Uri.parse(newUrl),
              headers: headers, body: handshakePayload);
        } else {
          logger.finest(
              formatLogMessage('Handshake Response: ${response.statusCode}'));
        }
      }

      if (response.statusCode != 200) {
        logger.warning(
            'Handshake failed with status code: ${response.statusCode}');
        return;
      }

      var serverConfig = jsonDecode(response.body);
      logger.finest(formatLogMessage('Handshake Response: $serverConfig'));

      salt = serverConfig['salt'];

      String? tempKey = serverConfig['tempKey'];
      if (tempKey == null) {
        _nonce = const DummyECDH();
      } else {
        _nonce = await privateKey.getSecret(tempKey);
      }

      enableAck = serverConfig.containsKey('version');
      remotePath = serverConfig['path'];

      if (serverConfig['wsUri'] is String) {
        _wsUpdateUri =
            '${connUri.resolve(serverConfig['wsUri'])}?dsId=${Uri.encodeComponent(dsId)}'
                .replaceFirst('http', 'ws');
        if (home != null) {
          _wsUpdateUri = '$_wsUpdateUri&home=$home';
        }
      }

      if (serverConfig['format'] is String) {
        format = serverConfig['format'];
      }

      await initWebsocket(false);
    } catch (e, stackTrace) {
      logger.warning('Client socket crashed: $e\n$stackTrace');
      connDelay();
    }
  }

  int _wsDelay = 0;

  int reconnectWSCount = 0;
  Future<void> initWebsocket([bool reconnect = true]) async {
    if (_closed) return;

    reconnectWSCount++;
    if (reconnectWSCount > 10) {
      // if reconnected ws for more than 10 times, do a clean reconnct
      connDelay();
      return;
    }

    try {
      var hashSalt = _nonce.hashSalt(salt);
      var wsUrl = '$_wsUpdateUri&auth=$hashSalt&format=$format';
      if (tokenHash != null) {
        wsUrl = '$wsUrl$tokenHash';
      }

      var socket = await HttpHelper.connectToWebSocket(wsUrl,
          useStandardWebSocket: useStandardWebSocket);

      _wsConnection = WebSocketConnection(socket,
          clientLink: this,
          enableTimeout: true,
          enableAck: enableAck,
          useCodec: DsCodec.getCodec(format));

      logger.info(formatLogMessage('Connected'));
      if (!_onConnectedCompleter.isCompleted) {
        _onConnectedCompleter.complete();
      }

      // Reset delays, we've successfully connected.
      _connDelay = 0;
      _wsDelay = 0;

      if (responder != null) {
        responder!.connection = _wsConnection?.responderChannel;
      }

      if (requester != null) {
        await _wsConnection?.onRequesterReady.then((channel) {
          requester!.connection = channel;
          if (!_onRequesterReadyCompleter.isCompleted) {
            _onRequesterReadyCompleter.complete(requester);
          }
        });
      }

      await _wsConnection?.onDisconnected.then((connection) {
        initWebsocket();
      });
    } catch (error, stack) {
      logger.fine(
          formatLogMessage('Error while initializing WebSocket'), error, stack);
      if (error is WebSocketException &&
          (error.message
                  .contains('not upgraded to websocket') // error from dart
              ||
              error.message.contains('(401)') // error from nodejs
          )) {
        connDelay();
      } else if (reconnect) {
        DsTimer.timerOnceAfter(
            initWebsocket, _wsDelay == 0 ? 20 : _wsDelay * 500);
        if (_wsDelay < 30) _wsDelay++;
      }
    }
  }

  bool _closed = false;

  @override
  void close() {
    if (_closed) return;
    _onConnectedCompleter = Completer();
    _closed = true;
    if (_wsConnection != null) {
      _wsConnection?.close();
      _wsConnection = null;
    }
  }
}

Future<PrivateKey> getKeyFromFile(String path) async {
  var file = File(path);

  PrivateKey key;
  if (!file.existsSync()) {
    key = await PrivateKey.generate();
    file.createSync(recursive: true);
    file.writeAsStringSync(key.saveToString());
  } else {
    key = PrivateKey.loadFromString(file.readAsStringSync());
  }

  return key;
}
