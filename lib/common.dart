/// Shared APIs between all DSA Components.
library dsalink.common;

import 'dart:async';
import 'dart:collection';

import 'requester.dart';
import 'responder.dart';
import 'src/crypto/pk.dart';
import 'utils.dart';

part 'src/common/connection_channel.dart';
part 'src/common/connection_handler.dart';
part 'src/common/default_defs.dart';
part 'src/common/node.dart';
part 'src/common/permission.dart';
part 'src/common/table.dart';
part 'src/common/value.dart';

abstract class Connection {
  ConnectionChannel get requesterChannel;

  ConnectionChannel get responderChannel;

  /// trigger when requester channel is Ready
  Future<ConnectionChannel> get onRequesterReady;

  /// return true if it's authentication error
  Future<bool> get onDisconnected;

  /// notify the connection channel need to send data
  void requireSend();

  /// send a connection command
  void addConnCommand(String key, Object value);

  /// close the connection
  void close();

  DsCodec codec = DsCodec.defaultCodec;

  ListQueue<ConnectionAckGroup> pendingAcks = ListQueue<ConnectionAckGroup>();

  void ack(int ackId) {
    ConnectionAckGroup? findAckGroup;
    for (var ackGroup in pendingAcks) {
      if (ackGroup.ackId == ackId) {
        findAckGroup = ackGroup;
        break;
      } else if (ackGroup.ackId < ackId) {
        findAckGroup = ackGroup;
      }
    }

    if (findAckGroup != null) {
      var ts = (DateTime.now()).millisecondsSinceEpoch;
      late ConnectionAckGroup ackGroup;
      do {
        ackGroup = pendingAcks.removeFirst();
        ackGroup.ackAll(ackId, ts);
      } while (ackGroup != findAckGroup);
    }
  }
}

/// generate message right before sending to get the latest update
/// return messages and the processors that need ack callback
class ProcessorResult {
  List<Map> messages;
  List<ConnectionProcessor> processors;

  ProcessorResult(this.messages, this.processors);
}

class ConnectionAckGroup {
  int ackId;
  int startTime;
  int? expectedAckTime;
  List<ConnectionProcessor> processors;

  ConnectionAckGroup(this.ackId, this.startTime, this.processors);

  void ackAll(int ackid, int time) {
    for (var processor in processors) {
      processor.ackReceived(ackId, startTime, time);
    }
  }
}

abstract class ConnectionChannel {
  /// raw connection need to handle error and resending of data, so it can only send one map at a time
  /// a new getData function will always overwrite the previous one;
  /// requester and responder should handle the merging of methods
  void sendWhenReady(ConnectionHandler handler);

  /// receive data from method stream
  Stream<List> get onReceive;

  /// whether the connection is ready to send and receive data
  bool get isReady;

  bool get connected;

  Future<ConnectionChannel> get onDisconnected;

  Future<ConnectionChannel> get onConnected;
}

/// Base Class for Links
abstract class BaseLink {
  Requester? get requester;

  Responder? get responder;

  ECDH? get nonce;

  /// trigger when requester channel is Ready
  Future<Requester?> get onRequesterReady;

  void close();
}

/// Base Class for Server Link implementations.
abstract class ServerLink extends BaseLink {
  /// dsId or username
  String get dsId;

  String? get session;

  PublicKey? get publicKey;

  @override
  void close();
}

/// Base Class for Client Link implementations.
abstract class ClientLink extends BaseLink {
  PrivateKey get privateKey;

  void updateSalt(String salt);

  String? get logName => null;

  String formatLogMessage(String msg) {
    if (logName != null) {
      return '[$logName] $msg';
    }
    return msg;
  }

  void connect();
}

abstract class ServerLinkManager {
  String? getLinkPath(String dsId, String? token);

  /// return true if link is added
  bool addLink(ServerLink link);

  void onLinkDisconnected(ServerLink link);

  void removeLink(ServerLink link, String id);

  ServerLink? getLinkAndConnectNode(String dsId, {String sessionId = ''});

  Requester? getRequester(String dsId);

  Responder? getResponder(
    String dsId,
    NodeProvider nodeProvider, [
    String? sessionId = '',
    bool trusted = false,
  ]);

  void updateLinkData(String dsId, Map? m);
}

/// DSA Stream Status
class StreamStatus {
  /// Stream should be initialized.
  static const String initialize = 'initialize';

  /// Stream is open.
  static const String open = 'open';

  /// Stream is closed.
  static const String closed = 'closed';
}

class ErrorPhase {
  static const String request = 'request';
  static const String response = 'response';
}

class DSError {
  /// type of error
  String? type;
  String? detail;
  String? msg;
  String? path;
  String? phase;

  DSError(
    this.type, {
    this.msg,
    this.detail,
    this.path,
    this.phase = ErrorPhase.response,
  });

  DSError.fromMap(Map m) {
    if (m['type'] is String) {
      type = m['type'];
    }
    if (m['msg'] is String) {
      msg = m['msg'];
    }
    if (m['path'] is String) {
      path = m['path'];
    }
    if (m['phase'] is String) {
      phase = m['phase'];
    }
    if (m['detail'] is String) {
      detail = m['detail'];
    }
  }

  String getMessage() {
    if (msg != null) {
      return msg!;
    }
    if (type != null) {
      return capitalize(type!);
    }
    return 'Error';
  }

  String capitalize(String s) {
    return s[0].toUpperCase() + s.substring(1);
  }

  Map serialize() {
    var rslt = <String, dynamic>{};
    if (msg != null) {
      rslt['msg'] = msg;
    }
    if (type != null) {
      rslt['type'] = type;
    }
    if (path != null) {
      rslt['path'] = path;
    }
    if (phase == ErrorPhase.request) {
      rslt['phase'] = ErrorPhase.request;
    }
    if (detail != null) {
      rslt['detail'] = detail;
    }
    return rslt;
  }

  /// Represents a permission denied error.
  static final DSError PERMISSION_DENIED = DSError('permissionDenied');

  /// Represents an invalid method error.
  static final DSError INVALID_METHOD = DSError('invalidMethod');

  /// Represents a not implemented error.
  static final DSError NOT_IMPLEMENTED = DSError('notImplemented');

  /// Represents an invalid path error.
  static final DSError INVALID_PATH = DSError('invalidPath');

  /// Represents an invalid paths error.
  static final DSError INVALID_PATHS = DSError('invalidPaths');

  /// Represents an invalid value error.
  static final DSError INVALID_VALUE = DSError('invalidValue');

  /// Represents an invalid parameter error.
  static final DSError INVALID_PARAMETER = DSError('invalidParameter');

  /// Represents a disconnected error.
  static final DSError DISCONNECTED = DSError(
    'disconnected',
    phase: ErrorPhase.request,
  );

  /// Represents a failed error.
  static final DSError FAILED = DSError('failed');
}

/// Marks something as being unspecified.
const Unspecified unspecified = Unspecified();

/// Unspecified means that something has never been set.
class Unspecified {
  const Unspecified();
}
