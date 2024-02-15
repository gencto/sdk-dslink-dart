part of dslink.requester;

typedef RequestConsumer<T> = T Function(Request request);

abstract class RequestUpdater {
  void onUpdate(String status, List? updates, List? columns, Map? meta, DSError? error);
  void onDisconnect();
  void onReconnect();
}

class RequesterUpdate {
  final String? streamStatus;

  RequesterUpdate(this.streamStatus);
}

class Requester extends ConnectionHandler {
  Map<int, Request> _requests = <int, Request>{};

  /// caching of nodes
  final RemoteNodeCache nodeCache;

  late SubscribeRequest _subscription;

  Requester([RemoteNodeCache? cache])
      : nodeCache = cache ?? RemoteNodeCache() {
    _subscription = SubscribeRequest(this, 0);
    _requests[0] = _subscription;
  }

  int get subscriptionCount {
    return _subscription.subscriptions.length;
  }

  int get openRequestCount {
    return _requests.length;
  }

  @override
  void onData(List list) {
    for (Object resp in list) {
      if (resp is Map) {
        _onReceiveUpdate(resp);
      }
    }
  }

  void _onReceiveUpdate(Map m) {
    if (m['rid'] is int && _requests.containsKey(m['rid'])) {
      _requests[m['rid']]?._update(m);
    }
  }

  final StreamController<DSError> _errorController =
    StreamController<DSError>.broadcast();

  Stream<DSError> get onError => _errorController.stream;

  int lastRid = 0;
  int getNextRid() {
    do {
      if (lastRid < 0x7FFFFFFF) {
        ++lastRid;
      } else {
        lastRid = 1;
      }
    } while (_requests.containsKey(lastRid));
    return lastRid;
  }

  @override
  ProcessorResult getSendingData(int currentTime, int waitingAckId) {
    var rslt = super.getSendingData(currentTime, waitingAckId);
    return rslt;
  }

  Request? sendRequest(Map m, RequestUpdater updater) =>
    _sendRequest(m, updater);

  Request? _sendRequest(Map m, RequestUpdater? updater) {
    m['rid'] = getNextRid();
    Request? req;
    if (updater != null) {
      req = Request(this, lastRid, updater, m);
      _requests[lastRid] = req;
    }
    addToSendList(m);
    return req;
  }

  bool isNodeCached(String path) {
    return nodeCache.isNodeCached(path);
  }

  ReqSubscribeListener subscribe(String path, Function(ValueUpdate update) callback,
      [int qos = 0]) {
    var node = nodeCache.getRemoteNode(path);
    node._subscribe(this, callback, qos);
    return ReqSubscribeListener(this, path, callback);
  }

  Stream<ValueUpdate> onValueChange(String path, [int qos = 0]) {
    ReqSubscribeListener? listener;
    late StreamController<ValueUpdate> controller;
    var subs = 0;
    controller = StreamController<ValueUpdate>.broadcast(onListen: () {
      subs++;
      listener ??= subscribe(path, (ValueUpdate update) {
          controller.add(update);
        }, qos);
    }, onCancel: () {
      subs--;
      if (subs == 0) {
        listener?.cancel();
        listener = null;
      }
    });
    return controller.stream;
  }

  Future<ValueUpdate> getNodeValue(String path, {Duration? timeout}) {
    var c = Completer<ValueUpdate>();
    ReqSubscribeListener? listener;
    Timer? to;
    listener = subscribe(path, (ValueUpdate update) {
      if (!c.isCompleted) {
        c.complete(update);
      }

      if (listener != null) {
        listener?.cancel();
        listener = null;
      }
      if (to != null && to!.isActive) {
        to?.cancel();
        to = null;
      }
    });
    if (timeout != null && timeout > Duration.zero) {
      to = Timer(timeout, () {
        listener?.cancel();
        listener = null;

        c.completeError(TimeoutException('failed to receive value', timeout));
      });
    }
    return c.future;
  }

  Future<RemoteNode> getRemoteNode(String path) {
    var c = Completer<RemoteNode>();
    StreamSubscription? sub;
    sub = list(path).listen((update) {
      if (!c.isCompleted) {
        c.complete(update.node);
      }

      if (sub != null) {
        sub.cancel();
      }
    }, onError: (dynamic e, StackTrace stack) {
      if (!c.isCompleted) {
        c.completeError(e, stack);
      }
    }, cancelOnError: true);
    return c.future;
  }

  void unsubscribe(String path, Function(ValueUpdate update) callback) {
    var node = nodeCache.getRemoteNode(path);
    node._unsubscribe(this, callback);
  }

  Stream<RequesterListUpdate> list(String path) {
    var node = nodeCache.getRemoteNode(path);
    return node._list(this);
  }

  Stream<RequesterInvokeUpdate> invoke(String path, [Map params = const {},
      int maxPermission = Permission.CONFIG, RequestConsumer? fetchRawReq]) {
    var node = nodeCache.getRemoteNode(path);
    return node._invoke(params, this, maxPermission, fetchRawReq);
  }

  Future<RequesterUpdate> set(String path, Object? value,
      [int maxPermission = Permission.CONFIG]) {
    return SetController(this, path, value, maxPermission).future;
  }

  Future<RequesterUpdate> remove(String path) {
    return RemoveController(this, path).future;
  }

  /// close the request from requester side and notify responder
  void closeRequest(Request request) {
    if (_requests.containsKey(request.rid)) {
      if (request.streamStatus != StreamStatus.closed) {
        addToSendList(<String, dynamic>{'method': 'close', 'rid': request.rid});
      }
      _requests.remove(request.rid);
      request._close();
    }
  }

  bool _connected = false;

  @override
  void onDisconnected() {
    if (!_connected) return;
    _connected = false;

    var newRequests = <int, Request>{};
    newRequests[0] = _subscription;
    _requests.forEach((n, req) {
      if (req.rid <= lastRid && req.updater is! ListController) {
        req._close(DSError.DISCONNECTED);
      } else {
        newRequests[req.rid] = req;
        req.updater.onDisconnect();
      }
    });
    _requests = newRequests;
  }

  @override
  void onReconnected() {
    if (_connected) return;
    _connected = true;

    super.onReconnected();

    _requests.forEach((n, req) {
      req.updater.onReconnect();
      req.resend();
    });
  }
}
