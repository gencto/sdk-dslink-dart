part of dslink.requester;

class ReqSubscribeListener implements StreamSubscription<dynamic> {
  ValueUpdateCallback? callback;
  Requester requester;
  String path;

  ReqSubscribeListener(this.requester, this.path, this.callback);

  @override
  Future<void> cancel() {
    if (callback != null) {
      requester.unsubscribe(path, callback!);
      callback = null;
    }
    return Future.value();
  }

  @override
  Future<E> asFuture<E>([E? futureValue]) => Future.value(futureValue);

  @override
  bool get isPaused => false;

  @override
  void onData(void Function(dynamic)? handleData) {}

  @override
  void onDone(void Function()? handleDone) {}

  @override
  void onError(Function? handleError) {}

  @override
  void pause([Future<void>? resumeSignal]) {}

  @override
  void resume() {}
}

/// only a place holder for reconnect and disconnect
/// real logic is in SubscribeRequest itself
class SubscribeController implements RequestUpdater {
  SubscribeRequest? request;

  SubscribeController();

  @override
  void onDisconnect() {
    // TODO: implement onDisconnect
  }

  @override
  void onReconnect() {
    // TODO: implement onReconnect
  }

  @override
  void onUpdate(String? status, List? updates, List? columns, Map? meta,
      DSError? error) {
    // do nothing
  }
}

class SubscribeRequest extends Request implements ConnectionProcessor {
  int lastSid = 0;

  int getNextSid() {
    do {
      if (lastSid < 0x7FFFFFFF) {
        ++lastSid;
      } else {
        lastSid = 1;
      }
    } while (subscriptionIds.containsKey(lastSid));
    return lastSid;
  }

  final Map<String, ReqSubscribeController> subscriptions =
    <String, ReqSubscribeController>{};

  final Map<int, ReqSubscribeController> subscriptionIds =
    <int, ReqSubscribeController>{};

  SubscribeRequest(Requester requester, int rid)
      : super(requester, rid, SubscribeController(), null) {
    (updater as SubscribeController).request = this;
  }

  @override
  void resend() {
    prepareSending();
  }

  @override
  void _close([DSError? error]) {
    if (subscriptions.isNotEmpty) {
      _changedPaths.addAll(subscriptions.keys);
    }
    _waitingAckCount = 0;
    _lastWatingAckId = -1;
    _sendingAfterAck = false;
  }

  @override
  void _update(Map m) {
    List? updates = m['updates'];
    if (updates is List) {
      for (Object update in updates) {
        String? path;
        var sid = -1;
        Object value;
        late String ts;
        late Map meta;
        if (update is Map) {
          if (update['ts'] is String) {
            path = update['path'];
            ts = update['ts'];
            if (update['path'] is String) {
              path = update['path'];
            } else if (update['sid'] is int) {
              sid = update['sid'];
            } else {
              continue; // invalid response
            }
          }
          value = update['value'];
          meta = update;
        } else if (update is List && update.length > 2) {
          if (update[0] is String) {
            path = update[0];
          } else if (update[0] is int) {
            sid = update[0];
          } else {
            continue; // invalid response
          }
          value = update[1];
          ts = update[2];
        } else {
          continue; // invalid response
        }

        ReqSubscribeController? controller;
        if (path != null) {
          controller = subscriptions[path];
        } else if (sid > -1) {
          controller = subscriptionIds[sid];
        }

        if (controller != null) {
          var valueUpdate = ValueUpdate(value, ts: ts, meta: meta);
          controller.addValue(valueUpdate);
        }
      }
    }
  }

  HashSet<String> _changedPaths = HashSet<String>();

  void addSubscription(ReqSubscribeController controller, int level) {
    var path = controller.node.remotePath;
    subscriptions[path] = controller;
    subscriptionIds[controller.sid] = controller;
    prepareSending();
    _changedPaths.add(path);
  }

  void removeSubscription(ReqSubscribeController controller) {
    var path = controller.node.remotePath;
    if (subscriptions.containsKey(path)) {
      toRemove[subscriptions[path]!.sid] = subscriptions[path]!;
      prepareSending();
    } else if (subscriptionIds.containsKey(controller.sid)) {
      logger.severe(
          'unexpected remoteSubscription in the requester, sid: ${controller
              .sid}');
    }
  }

  Map<int, ReqSubscribeController> toRemove =
    <int, ReqSubscribeController>{};

  @override
  void startSendingData(int currentTime, int waitingAckId) {
    _pendingSending = false;

    if (waitingAckId != -1) {
      _waitingAckCount++;
      _lastWatingAckId = waitingAckId;
    }

    if (requester.connection == null) {
      return;
    }
    var toAdd = <Map>[];

    var processingPaths = _changedPaths;
    _changedPaths = HashSet<String>();
    for (var path in processingPaths) {
      if (subscriptions.containsKey(path)) {
        var sub = subscriptions[path]!;
        Map m = <String, dynamic>{'path': path, 'sid': sub.sid};
        if (sub.currentQos > 0) {
          m['qos'] = sub.currentQos;
        }
        toAdd.add(m);
      }
    }
    if (toAdd.isNotEmpty) {
      requester._sendRequest(<String, dynamic>{'method': 'subscribe', 'paths': toAdd}, null);
    }
    if (toRemove.isNotEmpty) {
      var removeSids = <int>[];
      toRemove.forEach((int sid, ReqSubscribeController sub) {
        if (sub.callbacks.isEmpty) {
          removeSids.add(sid);
          subscriptions.remove(sub.node.remotePath);
          subscriptionIds.remove(sub.sid);
          sub._destroy();
        }
      });
      requester._sendRequest(
          <String, dynamic>{'method': 'unsubscribe', 'sids': removeSids}, null);
      toRemove.clear();
    }
  }

  bool _pendingSending = false;
  int _waitingAckCount = 0;
  int _lastWatingAckId = -1;

  @override
  void ackReceived(int receiveAckId, int startTime, int currentTime) {
    if (receiveAckId == _lastWatingAckId) {
      _waitingAckCount = 0;
    } else {
      _waitingAckCount--;
    }

    if (_sendingAfterAck) {
      _sendingAfterAck = false;
      prepareSending();
    }
  }

  bool _sendingAfterAck = false;

  void prepareSending() {
    if (_sendingAfterAck) {
      return;
    }

    if (_waitingAckCount > ConnectionProcessor.ACK_WAIT_COUNT) {
      _sendingAfterAck = true;
      return;
    }

    if (!_pendingSending) {
      _pendingSending = true;
      requester.addProcessor(this);
    }
  }
}

class ReqSubscribeController {
  final RemoteNode node;
  final Requester requester;

  Map<Function, int> callbacks = <Function, int>{};
  int currentQos = -1;
  late int sid;

  ReqSubscribeController(this.node, this.requester) {
    sid = requester._subscription.getNextSid();
  }

  void listen(Function(ValueUpdate update) callback, int qos) {
    if (qos < 0 || qos > 3) {
      qos = 0;
    }
    var qosChanged = false;

    if (callbacks.containsKey(callback)) {
      callbacks[callback] = qos;
      qosChanged = updateQos();
    } else {
      callbacks[callback] = qos;
      if (qos > currentQos) {
        qosChanged = true;
        currentQos = qos;
      }
      if (_lastUpdate != null) {
        callback(_lastUpdate!);
      }
    }

    if (qosChanged) {
      requester._subscription.addSubscription(this, currentQos);
    }
  }

  void unlisten(Function(ValueUpdate update) callback) {
    if (callbacks.containsKey(callback)) {
      var cacheLevel = callbacks.remove(callback);
      if (callbacks.isEmpty) {
        requester._subscription.removeSubscription(this);
      } else if (cacheLevel == currentQos && currentQos > 1) {
        updateQos();
      }
    }
  }

  bool updateQos() {
    var maxQos = 0;

    for (var qos in callbacks.values) {
      maxQos = (qos > maxQos ? qos : maxQos);
    }

    if (maxQos != currentQos) {
      currentQos = maxQos;
      return true;
    }
    return false;
  }

  ValueUpdate? _lastUpdate;

  void addValue(ValueUpdate update) {
    _lastUpdate = update;
    for (var callback in callbacks.keys.toList()) {
      callback(_lastUpdate);
    }
  }

  void _destroy() {
    callbacks.clear();
    node._subscribeController = null;
  }
}
