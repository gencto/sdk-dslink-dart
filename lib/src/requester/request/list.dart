part of dsalink.requester;

class RequesterListUpdate extends RequesterUpdate {
  /// this is only a list of changed fields
  /// when changes is null, means everything could have been changed
  List? changes;
  RemoteNode node;

  RequesterListUpdate(this.node, this.changes, String? streamStatus)
    : super(streamStatus);
}

class ListDefListener {
  final RemoteNode node;
  final Requester requester;

  late StreamSubscription listener;

  bool ready = false;

  ListDefListener(
    this.node,
    this.requester,
    void Function(RequesterListUpdate u) callback,
  ) {
    listener = requester.list(node.remotePath).listen((
      RequesterListUpdate update,
    ) {
      ready = update.streamStatus != StreamStatus.initialize;
      callback(update);
    });
  }

  void cancel() {
    listener.cancel();
  }
}

class ListController implements RequestUpdater, ConnectionProcessor {
  final RemoteNode node;
  final Requester requester;
  late BroadcastStreamController<RequesterListUpdate> _controller;

  Stream<RequesterListUpdate> get stream => _controller.stream;
  Request? request;

  ListController(this.node, this.requester) {
    _controller = BroadcastStreamController<RequesterListUpdate>(
      onStartListen,
      _onAllCancel,
      _onListen,
    );
  }

  bool get initialized {
    return request != null && request!.streamStatus != StreamStatus.initialize;
  }

  late String? disconnectTs;

  @override
  void onDisconnect() {
    disconnectTs = ValueUpdate.getTs();
    node.configs[r'$disconnectedTs'] = disconnectTs!;
    _controller.add(
      RequesterListUpdate(node, [r'$disconnectedTs'], request!.streamStatus),
    );
  }

  @override
  void onReconnect() {
    if (disconnectTs != null) {
      node.configs.remove(r'$disconnectedTs');
      disconnectTs = null;
      changes.add(r'$disconnectedTs');
    }
  }

  LinkedHashSet changes = LinkedHashSet<String>();

  @override
  void onUpdate(
    String streamStatus,
    List? updates,
    List? columns,
    Map? meta,
    DSError? error,
  ) {
    var reseted = false;
    // TODO implement error handling
    if (updates != null) {
      for (Object update in updates) {
        String name;
        late Object value;
        var removed = false;
        if (update is Map) {
          if (update['name'] is String) {
            name = update['name'];
          } else {
            continue; // invalid response
          }
          if (update['change'] == 'remove') {
            removed = true;
          } else {
            value = update['value'];
          }
        } else if (update is List) {
          if (update.isNotEmpty && update[0] is String) {
            name = update[0];
            if (update.length > 1) {
              value = update[1];
            }
          } else {
            continue; // invalid response
          }
        } else {
          continue; // invalid response
        }
        if (name.startsWith(r'$')) {
          if (!reseted &&
              (name == r'$is' ||
                  name == r'$base' ||
                  (name == r'$disconnectedTs' && value is String))) {
            reseted = true;
            node.resetNodeCache();
          }
          if (name == r'$is') {
            loadProfile(value as String);
          }
          changes.add(name);
          if (removed) {
            node.configs.remove(name);
          } else {
            node.configs[name] = value;
          }
        } else if (name.startsWith('@')) {
          changes.add(name);
          if (removed) {
            node.attributes.remove(name);
          } else {
            node.attributes[name] = value;
          }
        } else {
          changes.add(name);
          if (removed) {
            node.children.remove(name);
          } else if (value is Map) {
            // TODO, also wait for children $is
            node.children[name] =
                requester.nodeCache.updateRemoteChildNode(node, name, value)!;
          }
        }
      }
      if (request?.streamStatus != StreamStatus.initialize) {
        node.listed = true;
      }
      if (_pendingRemoveDef) {
        _checkRemoveDef();
      }
      onProfileUpdated();
    }
  }

  ListDefListener? _profileLoader;

  void loadProfile(String defName) {
    _ready = true;
    var defPath = defName;
    if (!defPath.startsWith('/')) {
      dynamic base = node.configs[r'$base'];
      if (base is String) {
        defPath = '$base/defs/profile/$defPath';
      } else {
        defPath = '/defs/profile/$defPath';
      }
    }
    if (node.profile is RemoteNode &&
        (node.profile as RemoteNode).remotePath == defPath) {
      return;
    }
    node.profile = requester.nodeCache.getDefNode(defPath, defName);
    if (defName == 'node') {
      return;
    }
    if ((node.profile is RemoteNode) && !(node.profile as RemoteNode).listed) {
      _ready = false;
      _profileLoader = ListDefListener(
        node.profile as RemoteNode,
        requester,
        _onProfileUpdate,
      );
    }
  }

  static const List _ignoreProfileProps = [
    r'$is',
    r'$permission',
    r'$settings',
  ];

  void _onProfileUpdate(RequesterListUpdate update) {
    if (_profileLoader == null) {
      logger.finest('warning, unexpected state of profile loading');
      return;
    }
    _profileLoader?.cancel();
    _profileLoader = null;
    changes.addAll(
      update.changes!.where((str) => !_ignoreProfileProps.contains(str)),
    );
    _ready = true;
    onProfileUpdated();
  }

  bool _ready = true;

  void onProfileUpdated() {
    if (_ready) {
      if (request?.streamStatus != StreamStatus.initialize) {
        _controller.add(
          RequesterListUpdate(node, changes.toList(), request!.streamStatus),
        );
        changes.clear();
      }
      if (request!.streamStatus == StreamStatus.closed) {
        _controller.close();
      }
    }
  }

  bool _pendingRemoveDef = false;

  void _checkRemoveDef() {
    _pendingRemoveDef = false;
  }

  void onStartListen() {
    if (request == null && !waitToSend) {
      waitToSend = true;
      requester.addProcessor(this);
    }
  }

  bool waitToSend = false;
  @override
  void startSendingData(int currentTime, int waitingAckId) {
    if (!waitToSend) {
      return;
    }
    request = requester._sendRequest(<String, dynamic>{
      'method': 'list',
      'path': node.remotePath,
    }, this);
    waitToSend = false;
  }

  @override
  void ackReceived(int receiveAckId, int startTime, int currentTime) {}

  void _onListen(Function(RequesterListUpdate update) callback) {
    if (_ready && request != null) {
      DsTimer.callLater(() {
        if (request == null) {
          return;
        }

        var changes = [];
        changes
          ..addAll(node.configs.keys)
          ..addAll(node.attributes.keys)
          ..addAll(node.children.keys);
        var update = RequesterListUpdate(node, changes, request!.streamStatus);
        callback(update);
      });
    }
  }

  void _onAllCancel() {
    _destroy();
  }

  void _destroy() {
    waitToSend = false;
    if (_profileLoader != null) {
      _profileLoader?.cancel();
      _profileLoader = null;
    }
    if (request != null) {
      requester.closeRequest(request!);
      request = null;
    }

    _controller.close();
    node._listController = null;
  }
}
