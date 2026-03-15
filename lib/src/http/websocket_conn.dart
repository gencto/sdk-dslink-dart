library dsalink.http.websocket;

import 'dart:async';
import 'dart:io';

import '../../common.dart';
import '../../utils.dart';

import 'package:logging/logging.dart';

class WebSocketConnection extends Connection {
  late PassiveChannel _responderChannel;

  @override
  ConnectionChannel get responderChannel => _responderChannel;

  late PassiveChannel _requesterChannel;

  @override
  ConnectionChannel get requesterChannel => _requesterChannel;

  Completer<ConnectionChannel> onRequestReadyCompleter =
      Completer<ConnectionChannel>();

  @override
  Future<ConnectionChannel> get onRequesterReady =>
      onRequestReadyCompleter.future;

  final Completer<bool> _onDisconnectedCompleter = Completer<bool>();

  @override
  Future<bool> get onDisconnected => _onDisconnectedCompleter.future;

  final ClientLink? clientLink;

  final WebSocket socket;

  bool _onDoneHandled = false;

  /// clientLink is not needed when websocket works in server link
  WebSocketConnection(
    this.socket, {
    this.clientLink,
    bool enableTimeout = false,
    bool enableAck = true,
    DsCodec? useCodec,
  }) {
    if (useCodec != null) {
      codec = useCodec;
    }
    _responderChannel = PassiveChannel(this, true);
    _requesterChannel = PassiveChannel(this, true);
    socket.listen(
      onData,
      onDone: _onDone,
      onError: (dynamic err) {
        logger.warning(
          formatLogMessage('Error listening to socket'),
          err,
        );
        _responderChannel.updateError('Socket error', err);
        _requesterChannel.updateError('Socket error', err);
      },
    );
    socket.add(codec.blankData);
    if (!enableAck) {
      nextMsgId = -1;
    }

    if (enableTimeout) {
      pingTimer = Timer.periodic(const Duration(seconds: 20), onPingTimer);
    }
    // TODO(rinick): when it's used in client link, wait for the server to send {allowed} before complete this
  }

  Timer? pingTimer;

  /// set to true when data is sent, reset the flag every 20 seconds
  /// since the previous ping message will cause the next 20 seoncd to have a message
  /// max interval between 2 ping messages is 40 seconds
  bool _dataSent = false;

  /// add this count every 20 seconds, set to 0 when receiving data
  /// when the count is 3, disconnect the link (>=60 seconds)
  int _dataReceiveCount = 0;

  static bool throughputEnabled = false;

  static int dataIn = 0;
  static int messageIn = 0;
  static int dataOut = 0;
  static int messageOut = 0;
  static int frameIn = 0;
  static int frameOut = 0;

  void onPingTimer(Timer t) {
    if (_dataReceiveCount >= 3) {
      logger.finest('close stale connection');
      close();
      return;
    }

    _dataReceiveCount++;

    if (_dataSent) {
      _dataSent = false;
      return;
    }
    addConnCommand(null, null);
  }

  @override
  void requireSend() {
    if (!_sending) {
      _sending = true;
      DsTimer.callLater(_send);
    }
  }

  /// special server command that need to be merged into message
  /// now only 2 possible value, salt, allowed
  DSAConfig? _serverCommand;

  /// add server command, will be called only when used as server connection
  @override
  void addConnCommand(String? key, Object? value) {
    _serverCommand ??= DSAConfig();
    if (key != null) {
      _serverCommand![key] = value;
    }

    requireSend();
  }

  void onData(dynamic data) {
    if (throughputEnabled) {
      frameIn++;
    }

    if (_onDisconnectedCompleter.isCompleted) {
      return;
    }
    if (!onRequestReadyCompleter.isCompleted) {
      onRequestReadyCompleter.complete(_requesterChannel);
    }
    _dataReceiveCount = 0;
    DSAMessage? m;
    if (data is List<int>) {
      try {
        final decoded = codec.decodeBinaryFrame(data);
        if (decoded != null) {
          m = DSAMessage.from(decoded);
        }
        if (logger.isLoggable(Level.FINEST)) {
          logger.finest(formatLogMessage('receive: $m'));
        }
      } catch (err, stack) {
        logger.fine(
          formatLogMessage(
            'Failed to decode binary data in WebSocket Connection',
          ),
          err,
          stack,
        );
        close();
        return;
      }

      if (throughputEnabled) {
        dataIn += data.length;
      }

      data = null;

      var needAck = false;
      if (m?.containsKey('responses') == true && m!['responses'] is List) {
        final responsesList = m['responses'] as List;
        if (responsesList.isNotEmpty) {
          needAck = true;
          // send responses to requester channel
          _requesterChannel.onReceiveController.add(
              responsesList.map((e) => DSAMessage.from(e as Map)).toList());

          if (throughputEnabled) {
            messageIn += responsesList.length;
          }
        }
      }

      if (m?.containsKey('requests') == true && m!['requests'] is List) {
        final requestsList = m['requests'] as List;
        if (requestsList.isNotEmpty) {
          needAck = true;
          // send requests to responder channel
          _responderChannel.onReceiveController.add(
              requestsList.map((e) => DSAMessage.from(e as Map)).toList());

          if (throughputEnabled) {
            messageIn += requestsList.length;
          }
        }
      }

      if (m?['ack'] is int) {
        ack(m?['ack']);
      }

      if (needAck) {
        Object? msgId = m?['msg'];
        if (msgId != null) {
          addConnCommand('ack', msgId);
        }
      }
    } else if (data is String) {
      try {
        final decoded = codec.decodeStringFrame(data);
        if (decoded != null) {
          m = DSAMessage.from(decoded);
        }
        if (logger.isLoggable(Level.FINEST)) {
          logger.finest(formatLogMessage('receive: $m'));
        }
      } catch (err, stack) {
        logger.severe(
          formatLogMessage(
            'Failed to decode string data from WebSocket Connection',
          ),
          err,
          stack,
        );
        close();
        return;
      }

      if (throughputEnabled) {
        dataIn += data.length;
      }

      if (m?['salt'] is String && clientLink != null) {
        clientLink?.updateSalt(m?['salt']);
      }

      var needAck = false;
      if (m?.containsKey('responses') == true && m!['responses'] is List) {
        final responsesList = m['responses'] as List;
        if (responsesList.isNotEmpty) {
          needAck = true;
          // send responses to requester channel
          _requesterChannel.onReceiveController.add(
              responsesList.map((e) => DSAMessage.from(e as Map)).toList());
          if (throughputEnabled) {
            for (final resp in responsesList) {
              if (resp is Map && resp['updates'] is List) {
                int len = (resp['updates'] as List).length;
                if (len > 0) {
                  messageIn += len;
                } else {
                  messageIn += 1;
                }
              } else {
                messageIn += 1;
              }
            }
          }
        }
      }

      if (m?.containsKey('requests') == true && m!['requests'] is List) {
        final requestsList = m['requests'] as List;
        if (requestsList.isNotEmpty) {
          needAck = true;
          // send requests to responder channel
          _responderChannel.onReceiveController.add(
              requestsList.map((e) => DSAMessage.from(e as Map)).toList());
          if (throughputEnabled) {
            messageIn += requestsList.length;
          }
        }
      }
      if (m?['ack'] is int) {
        ack(m?['ack']);
      }
      if (needAck) {
        Object? msgId = m?['msg'];
        if (msgId != null) {
          addConnCommand('ack', msgId);
        }
      }
    }
  }

  /// when nextMsgId = -1, ack is disabled
  int nextMsgId = 1;
  bool _sending = false;

  void _send() {
    if (!_sending) {
      return;
    }
    _sending = false;
    var needSend = false;
    DSAMessage m;
    if (_serverCommand != null) {
      m = DSAMessage(_serverCommand!.toMap());
      _serverCommand = null;
      needSend = true;
    } else {
      m = DSAMessage();
    }
    var pendingAck = <ConnectionProcessor>[];
    var ts = (DateTime.now()).millisecondsSinceEpoch;
    var rslt = _responderChannel.getSendingData(ts, nextMsgId);
    if (rslt != null) {
      if (rslt.messages.isNotEmpty) {
        m['responses'] = rslt.messages;
        needSend = true;
        if (throughputEnabled) {
          for (var resp in rslt.messages) {
            if (resp['updates'] is List) {
              int len = resp['updates'].length;
              if (len > 0) {
                messageOut += len;
              } else {
                messageOut += 1;
              }
            } else {
              messageOut += 1;
            }
          }
        }
      }
      if (rslt.processors.isNotEmpty) {
        pendingAck.addAll(rslt.processors);
      }
    }
    rslt = _requesterChannel.getSendingData(ts, nextMsgId);
    if (rslt != null) {
      if (rslt.messages.isNotEmpty) {
        m['requests'] = rslt.messages;
        needSend = true;
        if (throughputEnabled) {
          messageOut += rslt.messages.length;
        }
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
        m['msg'] = nextMsgId;
        if (nextMsgId < 0x7FFFFFFF) {
          ++nextMsgId;
        } else {
          nextMsgId = 1;
        }
      }
      addData(m);
      _dataSent = true;

      if (throughputEnabled) {
        frameOut++;
      }
    }
  }

  void addData(DSAMessage m) {
    var encoded = codec.encodeFrame(m);

    if (logger.isLoggable(Level.FINEST)) {
      logger.finest(formatLogMessage('send: $m'));
    }

    if (throughputEnabled) {
      if (encoded is String) {
        dataOut += encoded.length;
      } else if (encoded is List<int>) {
        dataOut += encoded.length;
      } else {
        logger.warning(formatLogMessage('invalid data frame'));
      }
    }
    try {
      socket.add(encoded);
    } catch (e) {
      logger.severe(formatLogMessage('Error writing to socket'), e);
      close();
    }
  }

  bool printDisconnectedMessage = true;

  void _onDone() {
    if (_onDoneHandled) {
      return;
    }

    _onDoneHandled = true;

    if (printDisconnectedMessage) {
      logger.info(formatLogMessage('Disconnected'));
    }

    if (!_requesterChannel.onReceiveController.isClosed) {
      _requesterChannel.onReceiveController.close();
    }

    _requesterChannel.updateDisconnected();

    if (!_responderChannel.onReceiveController.isClosed) {
      _responderChannel.onReceiveController.close();
    }

    _responderChannel.updateDisconnected();

    if (!_onDisconnectedCompleter.isCompleted) {
      _onDisconnectedCompleter.complete(false);
    }

    if (pingTimer != null) {
      pingTimer?.cancel();
    }
    _sending = false;
  }

  String formatLogMessage(String msg) {
    if (clientLink != null) {
      return clientLink!.formatLogMessage(msg);
    }

    if (logName != null) {
      return '[$logName] $msg';
    }
    return msg;
  }

  String? logName;

  @override
  void close() {
    if (socket.readyState == WebSocket.open ||
        socket.readyState == WebSocket.connecting) {
      socket.close();
    }
    _onDone();
  }
}
