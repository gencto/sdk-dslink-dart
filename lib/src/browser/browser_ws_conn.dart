part of dsalink.browser_client;



class WebSocketConnection extends Connection {
  late PassiveChannel _responderChannel;

  @override
  ConnectionChannel get responderChannel => _responderChannel;

  late PassiveChannel _requesterChannel;

  @override
  ConnectionChannel get requesterChannel => _requesterChannel;

  final Completer<ConnectionChannel> _onRequestReadyCompleter =
      Completer<ConnectionChannel>();

  @override
  Future<ConnectionChannel> get onRequesterReady =>
      _onRequestReadyCompleter.future;

  final Completer<bool> _onDisconnectedCompleter = Completer<bool>();
  @override
  Future<bool> get onDisconnected => _onDisconnectedCompleter.future;

  final ClientLink clientLink;

  final WebSocket socket;

  Function? onConnect;

  /// clientLink is not needed when websocket works in server link
  WebSocketConnection(
    this.socket,
    this.clientLink, {
    this.onConnect,
    bool enableAck = false,
    DsCodec? useCodec,
  }) {
    if (useCodec != null) {
      codec = useCodec;
    }

    if (!enableAck) {
      nextMsgId = -1;
    }
    socket.binaryType = 'arraybuffer';
    _responderChannel = PassiveChannel(this);
    _requesterChannel = PassiveChannel(this);
    socket.onMessage.listen(_onData, onDone: _onDone);
    socket.onClose.listen(_onDone);
    socket.onOpen.listen(_onOpen);
    // TODO, when it's used in client link, wait for the server to send {allowed} before complete this
    _onRequestReadyCompleter.complete(Future.value(_requesterChannel));

    pingTimer = Timer.periodic(const Duration(seconds: 20), onPingTimer);
  }

  Timer? pingTimer;

  int _dataReceiveTs = DateTime.now().millisecondsSinceEpoch;
  int _dataSentTs = DateTime.now().millisecondsSinceEpoch;

  void onPingTimer(Timer? t) {
    var currentTs = DateTime.now().millisecondsSinceEpoch;
    if (currentTs - _dataReceiveTs >= 65000) {
      // close the connection if no message received in the last 65 seconds
      close();
      return;
    }

    if (currentTs - _dataSentTs > 21000) {
      // add message if no data was sent in the last 21 seconds
      addConnCommand(null, null);
    }
  }

  @override
  void requireSend() {
    if (!_sending) {
      _sending = true;
      DsTimer.callLater(_send);
    }
  }

  // sometimes setTimeout and setInterval is not run due to browser throttling
  void checkBrowserThrottling() {
    var currentTs = DateTime.now().millisecondsSinceEpoch;
    if (currentTs - _dataSentTs > 25000) {
      logger.finest('Throttling detected');
      // timer is supposed to be run every 20 seconds, if that passes 25 seconds, force it to run
      onPingTimer(null);
      if (_sending) {
        _send();
      }
    }
  }

  bool _opened = false;
  bool get opened => _opened;

  void _onOpen(Event e) {
    logger.info('Connected');
    _opened = true;
    if (onConnect != null) {
      onConnect!();
    }
    _responderChannel.updateConnect();
    _requesterChannel.updateConnect();
    socket.send('{}' as dynamic);
    requireSend();
  }

  /// special server command that need to be merged into message
  /// now only 2 possible value, salt, allowed
  Map? _msgCommand;

  /// add server command, will be called only when used as server connection
  @override
  void addConnCommand(String? key, Object? value) {
    _msgCommand ??= <dynamic, dynamic>{};
    if (key != null) {
      _msgCommand![key] = value;
    }
    requireSend();
  }

  void _onData(MessageEvent e) {
    logger.fine('onData:');
    _dataReceiveTs = DateTime.now().millisecondsSinceEpoch;
    Map m;
    if (e.data is ByteBuffer) {
      try {
        var bytes = (e.data as ByteBuffer).asUint8List();

        m = codec.decodeBinaryFrame(bytes)!;
        logger.fine('$m');
        checkBrowserThrottling();

        if (m['salt'] is String) {
          clientLink.updateSalt(m['salt']);
        }
        var needAck = false;
        if (m['responses'] is List && (m['responses'] as List).isNotEmpty) {
          needAck = true;
          // send responses to requester channel
          _requesterChannel.onReceiveController.add(m['responses']);
        }

        if (m['requests'] is List && (m['requests'] as List).isNotEmpty) {
          needAck = true;
          // send requests to responder channel
          _responderChannel.onReceiveController.add(m['requests']);
        }
        if (m['ack'] is int) {
          ack(m['ack']);
        }
        if (needAck) {
          Object? msgId = m['msg'];
          if (msgId != null) {
            addConnCommand('ack', msgId);
          }
        }
      } catch (err, stack) {
        logger.severe('error in onData', err, stack);
        close();
        return;
      }
    } else if (e.data is String) {
      try {
        m = codec.decodeStringFrame(e.data as String)!;
        logger.fine('$m');
        checkBrowserThrottling();

        var needAck = false;
        if (m['responses'] is List && (m['responses'] as List).isNotEmpty) {
          needAck = true;
          // send responses to requester channel
          _requesterChannel.onReceiveController.add(m['responses']);
        }

        if (m['requests'] is List && (m['requests'] as List).isNotEmpty) {
          needAck = true;
          // send requests to responder channel
          _responderChannel.onReceiveController.add(m['requests']);
        }
        if (m['ack'] is int) {
          ack(m['ack']);
        }
        if (needAck) {
          Object? msgId = m['msg'];
          if (msgId != null) {
            addConnCommand('ack', msgId);
          }
        }
      } catch (err) {
        logger.severe(err);
        close();
        return;
      }
    }
  }

  int nextMsgId = 1;

  bool _sending = false;
  void _send() {
    _sending = false;
    if (socket.readyState != WebSocket.OPEN) {
      return;
    }
    logger.fine('browser sending');
    var needSend = false;
    Map? m;
    if (_msgCommand != null) {
      m = _msgCommand;
      needSend = true;
      _msgCommand = null;
    } else {
      m = <dynamic, dynamic>{};
    }

    var pendingAck = <ConnectionProcessor>[];

    var ts = (DateTime.now()).millisecondsSinceEpoch;
    var rslt = _responderChannel.getSendingData(ts, nextMsgId);
    if (rslt != null) {
      if (rslt.messages.isNotEmpty) {
        m?['responses'] = rslt.messages;
        needSend = true;
      }
      if (rslt.processors.isNotEmpty) {
        pendingAck.addAll(rslt.processors);
      }
    }
    rslt = _requesterChannel.getSendingData(ts, nextMsgId);
    if (rslt != null) {
      if (rslt.messages.isNotEmpty) {
        m?['requests'] = rslt.messages;
        needSend = true;
      }
      if (rslt.processors.isNotEmpty) {
        pendingAck.addAll(rslt.processors);
      }
    }

    if (needSend) {
      if (nextMsgId != -1) {
        if (pendingAck.isNotEmpty) {
          pendingAcks.add(ConnectionAckGroup(nextMsgId, ts, pendingAck));
        }
        m?['msg'] = nextMsgId;
        if (nextMsgId < 0x7FFFFFFF) {
          ++nextMsgId;
        } else {
          nextMsgId = 1;
        }
      }

      logger.fine('send: $m');
      var encoded = codec.encodeFrame(m!);
      if (encoded is List<int>) {
        encoded = ByteDataUtil.list2Uint8List(encoded);
      }
      try {
        socket.send(encoded as dynamic);
      } catch (e) {
        logger.severe('Unable to send on socket', e);
        close();
      }
      _dataSentTs = DateTime.now().millisecondsSinceEpoch;
    }
  }

  bool _authError = false;
  void _onDone([Object? o]) {
    if (o is CloseEvent) {
      var e = o;
      if (e.code == 1006) {
        _authError = true;
      }
    }

    logger.fine('socket disconnected');

    if (!_requesterChannel.onReceiveController.isClosed) {
      _requesterChannel.onReceiveController.close();
    }

    if (!_requesterChannel.onDisconnectController.isCompleted) {
      _requesterChannel.onDisconnectController.complete(_requesterChannel);
    }

    if (!_responderChannel.onReceiveController.isClosed) {
      _responderChannel.onReceiveController.close();
    }

    if (!_responderChannel.onDisconnectController.isCompleted) {
      _responderChannel.onDisconnectController.complete(_responderChannel);
    }

    if (!_onDisconnectedCompleter.isCompleted) {
      _onDisconnectedCompleter.complete(_authError);
    }
    if (pingTimer != null) {
      pingTimer!.cancel();
    }
  }

  @override
  void close() {
    if (socket.readyState == WebSocket.OPEN ||
        socket.readyState == WebSocket.CONNECTING) {
      socket.close();
    }
    _onDone();
  }
}
