part of dslink.responder;

/// a responder for one connection
class Responder extends ConnectionHandler {
  /// reqId can be a dsId or a user name
  String? reqId;

  int maxCacheLength = ConnectionProcessor.defaultCacheSize;

  ISubscriptionResponderStorage? storage;

  /// max permisison of the remote requester, this requester won't be able to do anything with higher
  /// permission even when other permission setting allows it to.
  /// This feature allows reverse proxy to override the permission for each connection with url parameter
  int maxPermission = Permission.CONFIG;

  void initStorage(
      ISubscriptionResponderStorage s, List<ISubscriptionNodeStorage>? nodes) {
    if (storage != null) {
      storage?.destroy();
    }
    storage = s;
    if (storage != null && nodes != null) {
      for (var node in nodes) {
        var values = node.getLoadedValues();
        var localnode = nodeProvider.getOrCreateNode(node.path, false);
        var controller =
            _subscription.add(node.path, localnode, -1, node.qos!);
        if (values.isNotEmpty) {
          controller.resetCache(values);
        }
      }
    }
  }

  /// list of permission group
  List<String>? groups = [];
  void updateGroups(List<String> vals, [bool ignoreId = false]) {
    if (ignoreId) {
      groups = vals.where((str) => str != '').toList();
    } else {
      groups = [reqId!, ...vals.where((str) => str != '')];
    }
  }

  final Map<int, Response> _responses = <int, Response>{};

  int get openResponseCount {
    return _responses.length;
  }

  int get subscriptionCount {
    return _subscription.subscriptions.length;
  }

  late SubscribeResponse _subscription;

  /// caching of nodes
  final NodeProvider nodeProvider;

  Responder(this.nodeProvider, [this.reqId]) {
    _subscription = SubscribeResponse(this, 0);
    _responses[0] = _subscription;
    // TODO: load reqId
    if (reqId != null) {
      groups = [reqId!];
    }
  }

  Response addResponse(Response response,
      [Path? path, Object? parameters]) {
    if (response._sentStreamStatus != StreamStatus.closed) {
      _responses[response.rid] = response;
      if (_traceCallbacks != null) {
        var update = response.getTraceData();
        for (var callback in _traceCallbacks!) {
          callback(update!);
        }
      }
    } else {
      if (_traceCallbacks != null) {
        var update =
            response.getTraceData(''); // no logged change is needed
        for (var callback in _traceCallbacks!) {
          callback(update!);
        }
      }
    }
    return response;
  }

  void traceResponseRemoved(Response response) {
    var update = response.getTraceData('-');
    for (var callback in _traceCallbacks!) {
      callback(update!);
    }
  }

  bool disabled = false;
  @override
  void onData(List list) {
    if (disabled) {
      return;
    }
    for (Object resp in list) {
      if (resp is Map) {
        _onReceiveRequest(resp);
      }
    }
  }

  void _onReceiveRequest(Map m) {
    Object? method = m['method'];
    if (m['rid'] is int) {
      if (method == null) {
        updateInvoke(m);
        return;
      } else {
        if (_responses.containsKey(m['rid'])) {
          if (method == 'close') {
            close(m);
          }
          // when rid is invalid, nothing needs to be sent back
          return;
        }

        switch (method) {
          case 'list':
            list(m);
            return;
          case 'subscribe':
            subscribe(m);
            return;
          case 'unsubscribe':
            unsubscribe(m);
            return;
          case 'invoke':
            invoke(m);
            return;
          case 'set':
            set(m);
            return;
          case 'remove':
            remove(m);
            return;
        }
      }
    }
    closeResponse(m['rid'], error: DSError.INVALID_METHOD);
  }

  /// close the response from responder side and notify requester
  void closeResponse(int rid, {Response? response, DSError? error}) {
    if (response != null) {
      if (_responses[response.rid] != response) {
        // this response is no longer valid
        return;
      }
      response._sentStreamStatus = StreamStatus.closed;
      rid = response.rid;
    }
    var m = <String, dynamic>{'rid': rid, 'stream': StreamStatus.closed};
    if (error != null) {
      m['error'] = error.serialize();
    }
    _responses.remove(rid);
    addToSendList(m);
  }

  void updateResponse(Response response, List? updates,
      {String? streamStatus,
      List<dynamic>? columns,
      Map? meta,
      void Function(Map m)? handleMap}) {
    if (_responses[response.rid] == response) {
      Map m = <String, dynamic>{'rid': response.rid};
      if (streamStatus != null && streamStatus != response._sentStreamStatus) {
        response._sentStreamStatus = streamStatus;
        m['stream'] = streamStatus;
      }

      if (columns != null) {
        m['columns'] = columns;
      }

      if (updates != null) {
        m['updates'] = updates;
      }

      if (meta != null) {
        m['meta'] = meta;
      }

      if (handleMap != null) {
        handleMap(m);
      }

      addToSendList(m);
      if (response._sentStreamStatus == StreamStatus.closed) {
        _responses.remove(response.rid);
        if (_traceCallbacks != null) {
          traceResponseRemoved(response);
        }
      }
    }
  }

  void list(Map m) {
    var path = Path.getValidNodePath(m['path']);
    if (path != null && path.isAbsolute) {
      int rid = m['rid'];

      _getNode(path, (LocalNode node) {
        addResponse(ListResponse(this, rid, node), path);
      }, (dynamic e, dynamic stack) {
        var error = DSError('nodeError',
            msg: e.toString(), detail: stack.toString());
        closeResponse(m['rid'], error: error);
      });
    } else {
      closeResponse(m['rid'], error: DSError.INVALID_PATH);
    }
  }

  void subscribe(Map m) {
    if (m['paths'] is List) {
      for (Object p in m['paths']) {
        late String pathstr;
        var qos = 0;
        var sid = -1;
        if (p is Map) {
          if (p['path'] is String) {
            pathstr = p['path'];
          } else {
            continue;
          }
          if (p['sid'] is int) {
            sid = p['sid'];
          } else {
            continue;
          }
          if (p['qos'] is int) {
            qos = p['qos'];
          }
        }
        var path = Path.getValidNodePath(pathstr);

        if (path != null && path.isAbsolute) {
          _getNode(path, (LocalNode node) {
            _subscription.add(path.path, node, sid, qos);
            closeResponse(m['rid']);
          }, (dynamic e, dynamic stack) {
            var error = DSError('nodeError',
                msg: e.toString(), detail: stack.toString());
            closeResponse(m['rid'], error: error);
          });
        } else {
          closeResponse(m['rid']);
        }
      }
    } else {
      closeResponse(m['rid'], error: DSError.INVALID_PATHS);
    }
  }

  void _getNode(Path p, Taker<LocalNode> func,
      [TwoTaker<dynamic, dynamic>? onError]) {
    try {
      var node = nodeProvider.getOrCreateNode(p.path, false);

      if (node is WaitForMe) {
        (node as WaitForMe).onLoaded.then((dynamic n) {
          if (n is LocalNode) {
            node = n;
          }
          func(node);
        }).catchError((dynamic e, StackTrace stack) {
          if (onError != null) {
            onError(e, stack);
          }
        });
      } else {
        func(node);
      }
    } catch (e, stack) {
      if (onError != null) {
        onError(e, stack);
      } else {
        rethrow;
      }
    }
  }

  void unsubscribe(Map m) {
    if (m['sids'] is List) {
      for (Object sid in m['sids']) {
        if (sid is int) {
          _subscription.remove(sid);
        }
      }
      closeResponse(m['rid']);
    } else {
      closeResponse(m['rid'], error: DSError.INVALID_PATHS);
    }
  }

  void invoke(Map m) {
    var path = Path.getValidNodePath(m['path']);
    if (path != null && path.isAbsolute) {
      int rid = m['rid'];
      var parentNode =
          nodeProvider.getOrCreateNode(path.parentPath, false);

      void doInvoke([LocalNode? overriden]) {
        var node =
            overriden ?? nodeProvider.getNode(path.path);
        if (node == null) {
          if (overriden == null) {
            node = parentNode.getChild(path.name) as LocalNode?;
            if (node == null) {
              closeResponse(m['rid'], error: DSError.PERMISSION_DENIED);
              return;
            }

            if (node is WaitForMe) {
              (node as WaitForMe).onLoaded.then((dynamic _) => doInvoke(node));
              return;
            } else {
              doInvoke(node);
              return;
            }
          } else {
            closeResponse(m['rid'], error: DSError.PERMISSION_DENIED);
            return;
          }
        }
        var permission =
            nodeProvider.permissions.getPermission(path.path, this);
        var maxPermit = Permission.parse(m['permit']);
        if (maxPermit < permission) {
          permission = maxPermit;
        }

        Map? params;

        if (m['params'] is Map) {
          params = <String, dynamic>{};
          (m['params'] as Map).forEach((key,dynamic value) {
            params![key.toString()] = value;
          });
        }

        params ??= <String, dynamic>{};

        if (node.getInvokePermission() <= permission) {
          node.invoke(
              params,
              this,
              addResponse(
                  InvokeResponse(this, rid, parentNode, node, path.name),
                  path,
                  params) as InvokeResponse,
              parentNode,
              permission);
        } else {
          closeResponse(m['rid'], error: DSError.PERMISSION_DENIED);
        }
      }

      if (parentNode is WaitForMe) {
        (parentNode as WaitForMe).onLoaded.then((dynamic _) {
          doInvoke();
        }).catchError((dynamic e, StackTrace stack) {
          var err = DSError('nodeError',
              msg: e.toString(), detail: stack.toString());
          closeResponse(m['rid'], error: err);
        });
      } else {
        doInvoke();
      }
    } else {
      closeResponse(m['rid'], error: DSError.INVALID_PATH);
    }
  }

  void updateInvoke(Map m) {
    int rid = m['rid'];
    if (_responses[rid] is InvokeResponse) {
      if (m['params'] is Map) {
        (_responses[rid] as InvokeResponse).updateReqParams(m['params']);
      }
    } else {
      closeResponse(m['rid'], error: DSError.INVALID_METHOD);
    }
  }

  void set(Map m) {
    var path = Path.getValidPath(m['path']);
    if (path == null || !path.isAbsolute) {
      closeResponse(m['rid'], error: DSError.INVALID_PATH);
      return;
    }

    if (!m.containsKey('value')) {
      closeResponse(m['rid'], error: DSError.INVALID_VALUE);
      return;
    }

    Object? value = m['value'];
    int rid = m['rid'];
    if (path.isNode) {
      _getNode(path, (LocalNode node) {
        var permission =
            nodeProvider.permissions.getPermission(node.path, this);
        var maxPermit = Permission.parse(m['permit']);
        if (maxPermit < permission) {
          permission = maxPermit;
        }

        if (node.getSetPermission() <= permission) {
          node.setValue(value as Object, this,
              addResponse(Response(this, rid, 'set'), path, value));
        } else {
          closeResponse(m['rid'], error: DSError.PERMISSION_DENIED);
        }
        closeResponse(m['rid']);
      }, (dynamic e, dynamic stack) {
        var error = DSError('nodeError',
            msg: e.toString(), detail: stack.toString());
        closeResponse(m['rid'], error: error);
      });
    } else if (path.isConfig) {
      LocalNode node;

      node = nodeProvider.getOrCreateNode(path.parentPath, false);

      var permission = nodeProvider.permissions.getPermission(node.path, this);
      if (permission < Permission.CONFIG) {
        closeResponse(m['rid'], error: DSError.PERMISSION_DENIED);
      } else {
        node.setConfig(path.name, value!, this,
            addResponse(Response(this, rid, 'set'), path, value));
      }
    } else if (path.isAttribute) {
      LocalNode node;

      node = nodeProvider.getOrCreateNode(path.parentPath, false);
      var permission = nodeProvider.permissions.getPermission(node.path, this);
      if (permission < Permission.WRITE) {
        closeResponse(m['rid'], error: DSError.PERMISSION_DENIED);
      } else {
        node.setAttribute(path.name, value!, this,
            addResponse(Response(this, rid, 'set'), path, value));
      }
    } else {
      // shouldn't be possible to reach here
      throw 'unexpected case';
    }
  }

  void remove(Map m) {
    var path = Path.getValidPath(m['path']);
    if (path == null || !path.isAbsolute) {
      closeResponse(m['rid'], error: DSError.INVALID_PATH);
      return;
    }
    int rid = m['rid'];
    if (path.isNode) {
      closeResponse(m['rid'], error: DSError.INVALID_METHOD);
    } else if (path.isConfig) {
      LocalNode node;

      node = nodeProvider.getOrCreateNode(path.parentPath, false);

      var permission = nodeProvider.permissions.getPermission(node.path, this);
      if (permission < Permission.CONFIG) {
        closeResponse(m['rid'], error: DSError.PERMISSION_DENIED);
      } else {
        node.removeConfig(
            path.name, this, addResponse(Response(this, rid, 'set'), path));
      }
    } else if (path.isAttribute) {
      LocalNode node;

      node = nodeProvider.getOrCreateNode(path.parentPath, false);
      var permission = nodeProvider.permissions.getPermission(node.path, this);
      if (permission < Permission.WRITE) {
        closeResponse(m['rid'], error: DSError.PERMISSION_DENIED);
      } else {
        node.removeAttribute(
            path.name, this, addResponse(Response(this, rid, 'set'), path));
      }
    } else {
      // shouldn't be possible to reach here
      throw 'unexpected case';
    }
  }

  void close(Map m) {
    if (m['rid'] is int) {
      int rid = m['rid'];
      if (_responses.containsKey(rid)) {
        _responses[rid]?._close();
        var resp = _responses.remove(rid);
        if (_traceCallbacks != null) {
          traceResponseRemoved(resp!);
        }
      }
    }
  }

  @override
  void onDisconnected() {
    clearProcessors();
    _responses.forEach((id, resp) {
      resp._close();
    });
    _responses.clear();
    _responses[0] = _subscription;
  }

  @override
  void onReconnected() {
    super.onReconnected();
  }

  List<ResponseTraceCallback>? _traceCallbacks;

  void addTraceCallback(ResponseTraceCallback _traceCallback) {
    _subscription.addTraceCallback(_traceCallback);
    _responses.forEach((int rid, Response response) {
      _traceCallback(response.getTraceData()!);
    });

    _traceCallbacks ??= [];

    _traceCallbacks!.add(_traceCallback);
  }

  void removeTraceCallback(ResponseTraceCallback _traceCallback) {
    _traceCallbacks!.remove(_traceCallback);
    if (_traceCallbacks!.isEmpty) {
      _traceCallbacks = null;
    }
  }
}
