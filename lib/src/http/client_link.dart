part of dslink.client;

/// a client link for both http and ws
class HttpClientLink extends ClientLink {
  Completer<Requester> _onRequesterReadyCompleter = new Completer<Requester>();
  Completer _onConnectedCompleter = new Completer();

  Future<Requester> get onRequesterReady => _onRequesterReadyCompleter.future;

  Future? get onConnected => _onConnectedCompleter.future;

  String? remotePath;

  late final String dsId;
  final String? home;
  final String? token;
  final PrivateKey privateKey;

  String? tokenHash;

  Requester? requester;
  Responder? responder;

  bool useStandardWebSocket = true;
  late final bool strictTls;

  @override
  String? logName;

  late ECDH _nonce;

  ECDH get nonce => _nonce;

  WebSocketConnection? _wsConnection;

  late String salt;

  updateSalt(String salt) {
    this.salt = salt;
  }

  String? _wsUpdateUri;

  String? _conn;

  bool enableAck = false;

  Map? linkData;

  /// formats sent to broker
  List formats = ['msgpack', 'json'];

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
        requester = new Requester();
      }
    }

    if (formats == null &&
        const String.fromEnvironment("dsa.codec.formats") != '') {
      var formatString = const String.fromEnvironment("dsa.codec.formats");
      formats = formatString.split(",");
    }

    if (formats != null) {
      this.formats = formats;
    }

    if (isResponder) {
      if (overrideResponder != null) {
        responder = overrideResponder;
      } else if (nodeProvider != null) {
        responder = new Responder(nodeProvider);
      }
    }

    if (token != null && token!.length > 16) {
      // pre-generate tokenHash
      String tokenId = token!.substring(0, 16);
      String hashStr = CryptoProvider.sha256(toUTF8('$dsId$token'));
      tokenHash = '&token=$tokenId$hashStr';
    }
  }

  int _connDelay = 0;

  connDelay() {
    reconnectWSCount = 0;
    DsTimer.timerOnceAfter(connect, (_connDelay == 0 ? 20 : _connDelay * 500));
    if (_connDelay < 30) _connDelay++;
  }

  connect() async {
    if (_closed) {
      return;
    }

    lockCryptoProvider();
    DsTimer.timerCancel(initWebsocket);

    HttpClient client = new HttpClient();

    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      logger.info(formatLogMessage('Bad certificate for $host:$port'));
      logger.finest(formatLogMessage(
          'Cert Issuer: ${cert.issuer}, ' + 'Subject: ${cert.subject}'));
      return !strictTls;
    };

    String connUrl = '$_conn?dsId=${Uri.encodeComponent(dsId)}';
    if (home != null) {
      connUrl = '$connUrl&home=$home';
    }
    if (tokenHash != null) {
      connUrl = '$connUrl$tokenHash';
    }
    Uri connUri = Uri.parse(connUrl);
    logger.info(formatLogMessage("Connecting to ${_conn}"));

    // TODO: This runZoned is due to a bug in the DartVM
    // https://github.com/dart-lang/sdk/issues/31275
    // When it is fixed, we should go back to a regular try-catch
    try {
      runZoned(() async {
        await () async {
          HttpClientRequest request = await client.postUrl(connUri);
          Map requestJson = {
            'publicKey': privateKey.publicKey.qBase64,
            'isRequester': requester != null,
            'isResponder': responder != null,
            'formats': formats,
            'version': DSA_VERSION,
            'enableWebSocketCompression': true
          };

          if (linkData != null) {
            requestJson['linkData'] = linkData;
          }

          logger.finest(formatLogMessage("Handshake Request: ${requestJson}"));
          logger.fine(formatLogMessage("ID: ${dsId}"));

          request.add(toUTF8(DsJson.encode(requestJson)));
          HttpClientResponse response = await request.close();
          List<int> merged = await response.fold(<int>[], foldList);
          String rslt = const Utf8Decoder().convert(merged);
          Map serverConfig = DsJson.decode(rslt);

          logger
              .finest(formatLogMessage("Handshake Response: ${serverConfig}"));
          //read salt
          salt = serverConfig['salt'];

          String? tempKey = serverConfig['tempKey'];
          if (tempKey == null) {
            // trusted client, don't do ECDH handshake
            _nonce = const DummyECDH();
          } else {
            _nonce = await privateKey.getSecret(tempKey);
          }
          // server start to support version since 1.0.4
          // and this is the version ack is added
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
        }().timeout(new Duration(minutes: 1), onTimeout: () {
          client.close(force: true);
          throw new TimeoutException(
              'Connection to $_conn', const Duration(minutes: 1));
        });
        await initWebsocket(false);
      });
    } catch (e, s) {
      if (logger.level <= Level.FINER) {
        logger.warning("Client socket crashed: $e $s");
      } else {
        logger.warning("Client socket crashed: $e");
      }
      client.close();
      connDelay();
    }
  }

  int _wsDelay = 0;

  int reconnectWSCount = 0;
  initWebsocket([bool reconnect = true]) async {
    if (_closed) return;

    reconnectWSCount++;
    if (reconnectWSCount > 10) {
      // if reconnected ws for more than 10 times, do a clean reconnct
      connDelay();
      return;
    }

    try {
      var hashSalt = _nonce.hashSalt(salt);
      String wsUrl = '$_wsUpdateUri&auth=${hashSalt}&format=$format';
      if (tokenHash != null) {
        wsUrl = '$wsUrl$tokenHash';
      }

      var socket = await HttpHelper.connectToWebSocket(wsUrl,
          useStandardWebSocket: useStandardWebSocket);

      _wsConnection = new WebSocketConnection(socket,
          clientLink: this,
          enableTimeout: true,
          enableAck: enableAck,
          useCodec: DsCodec.getCodec(format));

      logger.info(formatLogMessage("Connected"));
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
        _wsConnection?.onRequesterReady.then((channel) {
          requester!.connection = channel;
          if (!_onRequesterReadyCompleter.isCompleted) {
            _onRequesterReadyCompleter.complete(requester);
          }
        });
      }

      _wsConnection?.onDisconnected.then((connection) {
        initWebsocket();
      });
    } catch (error, stack) {
      logger.fine(
          formatLogMessage("Error while initializing WebSocket"), error, stack);
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

  void close() {
    if (_closed) return;
    _onConnectedCompleter = new Completer();
    _closed = true;
    if (_wsConnection != null) {
      _wsConnection?.close();
      _wsConnection = null;
    }
  }
}

Future<PrivateKey> getKeyFromFile(String path) async {
  var file = new File(path);

  PrivateKey key;
  if (!file.existsSync()) {
    key = await PrivateKey.generate();
    file.createSync(recursive: true);
    file.writeAsStringSync(key.saveToString());
  } else {
    key = new PrivateKey.loadFromString(file.readAsStringSync());
  }

  return key;
}
