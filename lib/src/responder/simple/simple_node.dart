part of dslink.responder;

typedef NodeFactory = LocalNode Function(String path);
typedef SimpleNodeFactory = SimpleNode? Function(String? path);
typedef IconResolver = Future<ByteData> Function(String name);

/// A simple table result.
/// This is used to return simple tables from an action.
class SimpleTableResult {
  /// Table Columns
  List? columns;

  /// Table Rows
  List? rows;

  SimpleTableResult([this.rows, this.columns]);
}

abstract class WaitForMe {
  Future get onLoaded;
}

/// An Asynchronous Table Result
/// This can be used to return asynchronous tables from actions.
class AsyncTableResult {
  /// Invoke Response.
  InvokeResponse? response;

  /// Table Columns
  List? columns;

  /// Table Rows
  List? rows;

  /// Stream Status
  String status = StreamStatus.open;

  /// Table Metadata
  Map? meta;

  /// Handler for when this is closed.
  OnInvokeClosed? onClose;

  AsyncTableResult([this.columns]);

  /// Updates table rows to [rows].
  /// [stat] is the stream status.
  /// [meta] is the action result metadata.
  void update(List rows, [String? stat, Map? meta]) {
    if (this.rows == null) {
      this.rows = rows;
    } else {
      this.rows?.addAll(rows);
    }
    this.meta = meta;
    if (stat != null) {
      status = stat;
    }

    if (response == null) {
      Future(write);
    } else {
      write();
    }
  }

  /// Write this result to the result given by [resp].
  void write([InvokeResponse? resp]) {
    if (resp != null) {
      if (response == null) {
        response = resp;
      } else {
        logger.warning('can not use same AsyncTableResult twice');
      }
    }

    if (response != null &&
        (rows != null || meta != null || status == StreamStatus.closed)) {
      response?.updateStream(rows!,
          columns: columns, streamStatus: status, meta: meta);
      rows = null;
      columns = null;
    }
  }

  /// Closes this response.
  void close() {
    if (response != null) {
      response?.close();
    } else {
      status = StreamStatus.closed;
    }
  }
}

/// A Live-Updating Table
class LiveTable {
  final List<TableColumn>? columns;
  final List<LiveTableRow>? rows;

  LiveTable.create(this.columns, this.rows);

  factory LiveTable([List<TableColumn>? columns]) {
    return LiveTable.create(columns ?? [], []);
  }

  void onRowUpdate(LiveTableRow row) {
    if (_resp != null) {
      _resp?.updateStream(<dynamic>[
        row.values
      ], meta: <String, String>{
        'modify': 'replace ${row.index}-${row.index}'
      });
    }
  }

  void doOnClose(Function f) {
    _onClose.add(f);
  }

  final List<Function> _onClose = [];

  LiveTableRow createRow(List<dynamic>? values, {bool ready = true}) {
    values ??= <dynamic>[];
    var row = LiveTableRow(this, values);
    row.index = rows!.length;
    rows?.add(row);
    if (ready && _resp != null) {
      _resp?.updateStream(<dynamic>[row.values],
          meta: <String, String>{'mode': 'append'});
    }
    return row;
  }

  void clear() {
    rows?.length = 0;
    if (_resp != null) {
      _resp?.updateStream(<dynamic>[],
          meta: <String, String>{'mode': 'refresh'}, columns: <dynamic>[]);
    }
  }

  void refresh([int idx = -1]) {
    if (_resp != null) {
      _resp?.updateStream(getCurrentState(),
          columns: columns?.map((x) {
            return x.getData();
          }).toList(),
          streamStatus: StreamStatus.open,
          meta: <String, String>{'mode': 'refresh'});
    }
  }

  void reindex() {
    var i = 0;
    for (var row in rows!) {
      row.index = i;
      i++;
    }
  }

  void override() {
    refresh();
  }

  void resend() {
    sendTo(_resp!);
  }

  void sendTo(InvokeResponse resp) {
    _resp = resp;

    _resp?.onClose = (r) {
      close(true);
    };

    if (autoStartSend) {
      resp.updateStream(getCurrentState(),
          columns: columns?.map((x) {
            return x.getData();
          }).toList(),
          streamStatus: StreamStatus.open,
          meta: <String, String>{'mode': 'refresh'});
    }
  }

  void close([bool isFromRequester = false]) {
    while (_onClose.isNotEmpty) {
      _onClose.removeAt(0)();
    }

    if (!isFromRequester) {
      _resp?.close();
    }
  }

  List getCurrentState([int from = -1]) {
    var rw = rows;
    if (from != -1) {
      rw = rw?.sublist(from);
    }
    return rw!.map((x) => x.values).toList();
  }

  InvokeResponse? get response => _resp;
  InvokeResponse? _resp;

  bool autoStartSend = true;
}

class LiveTableRow {
  final LiveTable table;
  final List<dynamic> values;

  int index = -1;

  LiveTableRow(this.table, this.values);

  void setValue(int idx, dynamic value) {
    if (idx > values.length - 1) {
      values.length += 1;
    }
    values[idx] = value;
    table.onRowUpdate(this);
  }

  void delete() {
    table.rows?.remove(this);
    var idx = index;
    table.refresh(idx);
    table.reindex();
  }
}

/// Interface for node providers that are serializable.
abstract class SerializableNodeProvider {
  /// Initialize the node provider.
  void init([Map m, Map<String, NodeFactory> profiles]);

  /// Save the node provider to a map.
  Map save();

  /// Persist the node provider.
  void persist([bool now = false]);
}

/// Interface for node providers that are mutable.
abstract class MutableNodeProvider {
  /// Updates the value of the node at [path] to the given [value].
  void updateValue(String path, Object value);

  /// Adds a node at the given [path] that is initialized with the given data in [m].
  LocalNode? addNode(String path, Map m);

  /// Removes the node specified at [path].
  void removeNode(String path);
  // Add a profile to the node provider.
  void addProfile(String name, NodeFactory factory);
}

class SysGetIconNode extends SimpleNode {
  SysGetIconNode(String path, [SimpleNodeProvider? provider])
      : super(path, provider!) {
    configs.addAll(<String, dynamic>{
      r'$invokable': 'read',
      r'$params': [
        {'name': 'Icon', 'type': 'string'}
      ],
      r'$columns': [
        {'name': 'Data', 'type': 'binary'}
      ],
      r'$result': 'table'
    });
  }

  @override
  Future<List<List<ByteData>>> onInvoke(Map params) async {
    String name = params['Icon'];
    var resolver = provider._iconResolver;

    var data = await resolver!(name);

    return [
      [data]
    ];
  }
}

class SimpleNodeProvider extends NodeProviderImpl
    implements SerializableNodeProvider, MutableNodeProvider {
  /// Global instance.
  /// This is by default always the first instance of [SimpleNodeProvider].
  static SimpleNodeProvider? instance;

  ExecutableFunction? _persist;
  IconResolver? _iconResolver;

  /// All the nodes in this node provider.
  @override
  final Map<String, LocalNode> nodes = <String, LocalNode>{};

  final List<SimpleNodeFactory> _resolverFactories = [];

  @override
  LocalNode? getNode(String path) {
    return _getNode(path);
  }

  void setIconResolver(IconResolver resolver) {
    _iconResolver = resolver;

    nodes['/sys/getIcon'] = SysGetIconNode('/sys/getIcon', this);
  }

  LocalNode? _getNode(String? path, {bool allowStubs = false}) {
    if (nodes.containsKey(path)) {
      var node = nodes[path] as SimpleNode;
      if (allowStubs || node._stub == false) {
        return node;
      }
    }

    if (_resolverFactories.isNotEmpty) {
      for (var f in _resolverFactories) {
        var node = f(path);
        if (node != null) {
          return node;
        }
      }
    }

    return null;
  }

  /// Gets a node at the given [path] if it exists.
  /// If it does not exist, create a new node and return it.
  ///
  /// When [addToTree] is false, the node will not be inserted into the node provider.
  /// When [init] is false, onCreated() is not called.
  @override
  LocalNode getOrCreateNode(String path,
      [bool addToTree = true, bool init = true]) {
    var node = _getNode(path, allowStubs: true);

    if (node != null) {
      if (addToTree) {
        Path? po = Path(path);
        if (!po.isRoot) {
          var parent = getNode(po.parentPath);

          if (parent != null && !parent.children.containsKey(po.name)) {
            parent.addChild(po.name, node);
            parent.listChangeController.add(po.name);
            node.listChangeController.add(r'$is');
          }
        }

        if (node is SimpleNode) {
          node._stub = false;
        }
      }

      return node;
    }

    if (addToTree) {
      return createNode(path, init);
    } else {
      node = SimpleNode(path, this).._stub = true;
      nodes[path] = node;
      return node;
    }
  }

  /// Checks if this provider has the node at [path].
  bool hasNode(String path) {
    var node = nodes[path] as SimpleNode?;

    if (node == null) {
      return false;
    }

    if (node.isStubNode == true) {
      return false;
    }

    return true;
  }

  void registerResolver(SimpleNodeFactory factory) {
    if (!_resolverFactories.contains(factory)) {
      _resolverFactories.add(factory);
    }
  }

  void unregisterResolver(SimpleNodeFactory factory) {
    _resolverFactories.remove(factory);
  }

  @override
  void addProfile(String name, NodeFactory factory) {
    _profiles[name] = factory;
  }

  /// Sets the function that persists the nodes.
  void setPersistFunction(ExecutableFunction doPersist) {
    _persist = doPersist;
  }

  /// Persist the nodes in this provider.
  /// If you are not using a LinkProvider, then call [setPersistFunction] to set
  /// the function that is called to persist.
  @override
  void persist([bool now = false]) {
    if (now) {
      if (_persist == null) {
        return;
      }

      _persist!();
    } else {
      Future.delayed(const Duration(seconds: 5), () {
        if (_persist == null) {
          return;
        }

        _persist!();
      });
    }
  }

  /// Creates a node at [path].
  /// If a node already exists at this path, an exception is thrown.
  /// If [init] is false, onCreated() is not called.
  SimpleNode createNode(String path, [bool init = true]) {
    var p = Path(path);
    var existing = nodes[path];

    if (existing != null) {
      if (existing is SimpleNode) {
        if (existing._stub != true) {
          throw Exception('Node at $path already exists.');
        } else {
          existing._stub = false;
        }
      } else {
        throw Exception('Node at $path already exists.');
      }
    }

    var node =
        existing == null ? SimpleNode(path, this) : existing as SimpleNode;
    nodes[path] = node;

    if (init) {
      node.onCreated();
    }

    SimpleNode? pnode;

    if (p.parentPath != '') {
      pnode = getNode(p.parentPath) as SimpleNode;
    }

    if (pnode != null) {
      pnode.children[p.name] = node;
      pnode.onChildAdded(p.name, node);
      pnode.updateList(p.name);
    }

    return node;
  }

  /// Creates a [SimpleNodeProvider].
  /// If [m] and optionally [profiles] is specified,
  /// the provider is initialized with these values.
  SimpleNodeProvider([Map? m, Map<String, NodeFactory>? profiles]) {
    // by default, the first SimpleNodeProvider is the static instance
    instance ??= this;

    root = SimpleNode('/', this);
    nodes['/'] = root;
    defs = SimpleHiddenNode('/defs', this);
    nodes[defs!.path] = defs!;
    sys = SimpleHiddenNode('/sys', this);
    nodes[sys!.path] = sys!;

    init(m, profiles);
  }

  /// Root node
  late SimpleNode root;

  /// defs node
  SimpleHiddenNode? defs;

  /// sys node
  SimpleHiddenNode? sys;

  @override
  void init([Map? m, Map<String, NodeFactory>? profiles]) {
    if (profiles != null) {
      if (profiles.isNotEmpty) {
        _profiles.addAll(profiles);
      } else {
        _profiles = profiles;
      }
    }

    if (m != null) {
      root.load(m);
    }
  }

  Map<String, NodeFactory> get profileMap => _profiles;

  @override
  Map save() {
    return root.save();
  }

  @override
  void updateValue(String path, Object? value) {
    var node = getNode(path);
    node?.updateValue(value);
  }

  /// Sets the given [node] to the given [path].
  void setNode(String path, SimpleNode node, {bool registerChildren = false}) {
    if (path == '/' || !path.startsWith('/')) return null;
    var p = Path(path);
    var pnode = getNode(p.parentPath) as SimpleNode?;

    nodes[path] = node;

    node.onCreated();

    if (pnode != null) {
      pnode.children[p.name] = node;
      pnode.onChildAdded(p.name, node);
      pnode.updateList(p.name);
    }

    if (registerChildren) {
      for (var c in node.children.values.cast<SimpleNode>()) {
        setNode(c.path, c);
      }
    }
  }

  @override
  LocalNode? addNode(String path, Map m) {
    if (path == '/' || !path.startsWith('/')) return null;

    var p = Path(path);
    var oldNode = _getNode(path, allowStubs: true) as SimpleNode?;

    var pnode = getNode(p.parentPath) as SimpleNode?;
    SimpleNode? node;

    if (pnode != null) {
      node = pnode.onLoadChild(p.name, m, this);
    }

    if (node == null) {
      String? profile = m[r'$is'];
      if (_profiles.containsKey(profile)) {
        node = _profiles[profile]!(path) as SimpleNode?;
      } else {
        node = getOrCreateNode(path, true, false) as SimpleNode?;
      }
    }

    if (oldNode != null) {
      logger.fine('Found old node for $path: Copying subscriptions.');

      for (var func in oldNode.callbacks.keys) {
        node?.subscribe(func, oldNode.callbacks[func]!);
      }

      if (node is SimpleNode) {
        try {
          node._listChangeController = oldNode._listChangeController;
          node._listChangeController?.onStartListen = () {
            node?.onStartListListen();
          };
          node._listChangeController?.onAllCancel = () {
            node?.onAllListCancel();
          };
        } catch (e) {}

        if (node._hasListListener) {
          node.onStartListListen();
        }
      }
    }

    nodes[path] = node!;
    node.load(m);
    node.onCreated();

    if (pnode != null) {
      pnode.addChild(p.name, node);
      pnode.onChildAdded(p.name, node);
      pnode.updateList(p.name);
    }

    node.updateList(r'$is');

    if (oldNode != null) {
      oldNode.updateList(r'$is');
    }

    return node;
  }

  @override
  void removeNode(String path, {bool recurse = true}) {
    if (path == '/' || !path.startsWith('/')) return;
    var node = getNode(path) as SimpleNode?;

    if (node == null) {
      return;
    }

    if (recurse) {
      var base = path;
      if (!base.endsWith('/')) {
        base += '/';
      }

      var baseSlashFreq = countCharacterFrequency(base, '/');

      var targets = nodes.keys.where((String x) {
        return x.startsWith(base) &&
            baseSlashFreq == countCharacterFrequency(x, '/');
      }).toList();

      for (var target in targets) {
        removeNode(target);
      }
    }

    var p = Path(path);
    var pnode = getNode(p.parentPath) as SimpleNode?;
    node.onRemoving();
    node.removed = true;

    if (pnode != null) {
      pnode.children.remove(p.name);
      pnode.onChildRemoved(p.name, node);
      pnode.updateList(p.name);
    }

    if (node.callbacks.isEmpty && !node._hasListListener) {
      nodes.remove(path);
    } else {
      node._stub = true;
    }
  }

  Map<String, NodeFactory> _profiles = <String, NodeFactory>{};

  /// Permissions
  @override
  IPermissionManager permissions = DummyPermissionManager();

  /// Creates a responder with the given [dsId].
  @override
  Responder createResponder(String? dsId, String sessionId) {
    return Responder(this, dsId);
  }

  @override
  String toString({bool showInstances = false}) {
    var buff = StringBuffer();

    void doNode(LocalNode node, [int depth = 0]) {
      var p = Path(node.path);
      buff.write("${'  ' * depth}- ${p.name}");

      if (showInstances) {
        buff.write(': $node');
      }

      buff.writeln();
      for (var child in node.children.values) {
        doNode(child as LocalNode, depth + 1);
      }
    }

    doNode(root);
    return buff.toString().trim();
  }
}

/// A Simple Node Implementation
/// A flexible node implementation that should fit most use cases.
class SimpleNode extends LocalNodeImpl {
  @override
  final SimpleNodeProvider provider;

  static AESEngine? _encryptEngine;
  static KeyParameter? _encryptParams;
  static void initEncryption(String key) {
    _encryptEngine = AESEngine();
    _encryptParams =
        KeyParameter(Uint8List.fromList(utf8.encode(key).sublist(48, 80)));
  }

  /// encrypt the string and prefix the value with '\u001Bpw:'
  /// so it's compatible with old plain text password
  static String encryptString(String str) {
    if (str == '') {
      return '';
    }
    _encryptEngine?.reset();
    _encryptEngine?.init(true, _encryptParams!);

    var utf8bytes = Uint8List.fromList(utf8.encode(str));
    var block = Uint8List((utf8bytes.length + 31) ~/ 32 * 32);
    block.setRange(0, utf8bytes.length, utf8bytes);
    return '\u001Bpw:${Base64.encode(_encryptEngine!.process(block))}';
  }

  static String decryptString(String str) {
    if (str.startsWith('\u001Bpw:')) {
      _encryptEngine?.reset();
      _encryptEngine?.init(false, _encryptParams!);
      var rslt = utf8
          .decode(_encryptEngine!.process(Base64.decode(str.substring(4))!));
      var pos = rslt.indexOf('\u0000');
      if (pos >= 0) rslt = rslt.substring(0, pos);
      return rslt;
    } else if (str.length == 22) {
      // a workaround for the broken password database, need to be removed later
      // 22 is the length of a AES block after base64 encoding
      // encoded password should always be 24 or more bytes, and a plain 22 bytes password is rare
      try {
        _encryptEngine?.reset();
        _encryptEngine?.init(false, _encryptParams!);
        var rslt = utf8.decode(_encryptEngine!.process(Base64.decode(str)!));
        var pos = rslt.indexOf('\u0000');
        if (pos >= 0) rslt = rslt.substring(0, pos);
        return rslt;
      } catch (err) {
        return str;
      }
    } else {
      return str;
    }
  }

  bool _stub = false;

  /// Is this node a stub node?
  /// Stub nodes are nodes which are stored in the tree, but are not actually
  /// part of their parent.
  bool get isStubNode => _stub;

  SimpleNode(String path, [SimpleNodeProvider? nodeprovider])
      : provider = nodeprovider ?? SimpleNodeProvider.instance!,
        super(path);

  /// Marks a node as being removed.
  bool removed = false;

  /// Marks this node as being serializable.
  /// If true, this node can be serialized into a JSON file and then loaded back.
  /// If false, this node can't be serialized into a JSON file.
  bool serializable = true;

  /// Load this node from the provided map as [m].
  @override
  void load(Map m) {
    if (_loaded) {
      configs.clear();
      attributes.clear();
      children.clear();
    }
    String childPathPre;
    if (path == '/') {
      childPathPre = '/';
    } else {
      childPathPre = '$path/';
    }

    m.forEach((key, dynamic value) {
      if (key.startsWith('?')) {
        if (key == '?value') {
          updateValue(value);
        }
      } else if (key.startsWith(r'$')) {
        if (_encryptEngine != null &&
            key.startsWith(r'$$') &&
            value is String) {
          configs[key] = decryptString(value);
        } else {
          configs[key] = value;
        }
      } else if (key.startsWith('@')) {
        attributes[key] = value;
      } else if (value is Map) {
        var childPath = '$childPathPre$key';
        provider.addNode(childPath, value);
      }
    });
    _loaded = true;
  }

  /// Save this node into a map.
  Map save() {
    Map rslt = <String, dynamic>{};
    configs.forEach((str, dynamic val) {
      if (_encryptEngine != null &&
          val is String &&
          str.startsWith(r'$$') &&
          str.endsWith('password')) {
        rslt[str] = encryptString(val);
      } else {
        rslt[str] = val;
      }
    });

    attributes.forEach((str, val) {
      rslt[str] = val;
    });

    if (_lastValueUpdate != null && _lastValueUpdate?.value != null) {
      rslt['?value'] = _lastValueUpdate?.value;
    }

    children.forEach((str, Node? node) {
      if (node is SimpleNode && node.serializable == true) {
        rslt[str] = node.save();
      }
    });

    return rslt;
  }

  /// Handles the invoke method from the internals of the responder.
  /// Use [onInvoke] to handle when a node is invoked.
  @override
  InvokeResponse invoke(
      Map params, Responder responder, InvokeResponse response, Node parentNode,
      [int maxPermission = Permission.CONFIG]) {
    Object? rslt;
    try {
      rslt = onInvoke(params);
    } catch (e, stack) {
      var error = DSError('invokeException', msg: e.toString());
      try {
        error.detail = stack.toString();
      } catch (e) {}
      response.close(error);
      return response;
    }

    dynamic rtype = 'values';
    if (configs.containsKey(r'$result')) {
      rtype = configs[r'$result'];
    }

    if (rslt == null) {
      // Create a default result based on the result type
      if (rtype == 'values') {
        rslt = <dynamic>{};
      } else if (rtype == 'table') {
        rslt = <dynamic>[];
      } else if (rtype == 'stream') {
        rslt = <dynamic>[];
      }
    }

    if (rslt is Iterable) {
      response.updateStream(rslt.toList(), streamStatus: StreamStatus.closed);
    } else if (rslt is Map) {
      var columns = <dynamic>[];
      var out = <dynamic>[];
      for (var x in rslt.keys) {
        columns.add(<String, dynamic>{'name': x, 'type': 'dynamic'});
        out.add(rslt[x]);
      }

      response.updateStream(<dynamic>[out],
          columns: columns, streamStatus: StreamStatus.closed);
    } else if (rslt is SimpleTableResult) {
      response.updateStream(rslt.rows!,
          columns: rslt.columns, streamStatus: StreamStatus.closed);
    } else if (rslt is AsyncTableResult) {
      (rslt).write(response);
      response.onClose = (var response) {
        if ((rslt as AsyncTableResult).onClose != null) {
          (rslt).onClose!(response);
        }
      };
      return response;
    } else if (rslt is Table) {
      response.updateStream(rslt.rows,
          columns: rslt.columns, streamStatus: StreamStatus.closed);
    } else if (rslt is Stream) {
      var r = AsyncTableResult();

      response.onClose = (var response) {
        if (r.onClose != null) {
          r.onClose!(response);
        }
      };

      var stream = rslt;

      if (rtype == 'stream') {
        StreamSubscription? sub;

        r.onClose = (_) {
          if (sub != null) {
            sub.cancel();
          }
        };

        sub = stream.listen((dynamic v) {
          if (v is TableMetadata) {
            r.meta = v.meta;
            return;
          } else if (v is TableColumns) {
            r.columns = v.columns.map((x) => x.getData()).toList();
            return;
          }

          if (v is Iterable) {
            r.update(v.toList(), StreamStatus.open);
          } else if (v is Map) {
            dynamic meta;
            if (v.containsKey('__META__')) {
              meta = v['__META__'];
            }
            r.update(<dynamic>[v], StreamStatus.open, meta);
          } else {
            throw Exception('Unknown Value from Stream');
          }
        }, onDone: () {
          r.close();
        }, onError: (dynamic e, StackTrace stack) {
          var error = DSError('invokeException', msg: e.toString());
          try {
            error.detail = stack.toString();
          } catch (e) {}
          response.close(error);
        }, cancelOnError: true);
        r.write(response);
        return response;
      } else {
        var list = <dynamic>[];
        StreamSubscription? sub;

        r.onClose = (_) {
          if (sub != null) {
            sub.cancel();
          }
        };

        sub = stream.listen((dynamic v) {
          if (v is TableMetadata) {
            r.meta = v.meta;
            return;
          } else if (v is TableColumns) {
            r.columns = v.columns.map((x) => x.getData()).toList();
            return;
          }

          if (v is Iterable) {
            list.addAll(v);
          } else if (v is Map) {
            list.add(v);
          } else {
            throw Exception('Unknown Value from Stream');
          }
        }, onDone: () {
          r.update(list);
          r.close();
        }, onError: (dynamic e, StackTrace stack) {
          var error = DSError('invokeException', msg: e.toString());
          try {
            error.detail = stack.toString();
          } catch (e) {}
          response.close(error);
        }, cancelOnError: true);
      }
      r.write(response);
      return response;
    } else if (rslt is Future) {
      AsyncTableResult? r = AsyncTableResult();

      response.onClose = (var response) {
        if (r?.onClose != null) {
          r?.onClose!(response);
        }
      };

      rslt.then((dynamic value) {
        if (value is LiveTable) {
          r = null;
          value.sendTo(response);
        } else if (value is Stream) {
          var stream = value;
          StreamSubscription? sub;

          r?.onClose = (_) {
            if (sub != null) {
              sub.cancel();
            }
          };

          sub = stream.listen((dynamic v) {
            if (v is TableMetadata) {
              r?.meta = v.meta;
              return;
            } else if (v is TableColumns) {
              r?.columns = v.columns.map((x) => x.getData()).toList();
              return;
            }

            if (v is Iterable) {
              r?.update(v.toList());
            } else if (v is Map) {
              Map? meta;
              if (v.containsKey('__META__')) {
                meta = v['__META__'];
              }
              r?.update(<dynamic>[v], StreamStatus.open, meta);
            } else {
              throw Exception('Unknown Value from Stream');
            }
          }, onDone: () {
            r?.close();
          }, onError: (dynamic e, StackTrace stack) {
            var error = DSError('invokeException', msg: e.toString());
            try {
              error.detail = stack.toString();
            } catch (e) {}
            response.close(error);
          }, cancelOnError: true);
        } else if (value is Table) {
          var table = value;
          r?.columns = table.columns.map((x) => x.getData()).toList();
          r?.update(table.rows, StreamStatus.closed, table.meta);
          r?.close();
        } else {
          r?.update(value is Iterable ? value.toList() : <dynamic>[value]);
          r?.close();
        }
      }).catchError((dynamic e, StackTrace stack) {
        var error = DSError('invokeException', msg: e.toString());
        try {
          error.detail = stack.toString();
        } catch (e) {}
        response.close(error);
      });
      r?.write(response);
      return response;
    } else if (rslt is LiveTable) {
      rslt.sendTo(response);
    } else {
      response.close();
    }

    return response;
  }

  /// This is called when this node is invoked.
  /// You can return the following types from this method:
  /// - [Iterable]
  /// - [Map]
  /// - [Table]
  /// - [Stream]
  /// - [SimpleTableResult]
  /// - [AsyncTableResult]
  ///
  /// You can also return a future that resolves to one (like if the method is async) of the following types:
  /// - [Stream]
  /// - [Iterable]
  /// - [Map]
  /// - [Table]
  dynamic onInvoke(Map params) {
    return null;
  }

  /// Gets the parent node of this node.
  SimpleNode get parent =>
      provider.getNode(Path(path).parentPath) as SimpleNode;

  /// Callback used to accept or reject a value when it is set.
  /// Return true to reject the value, and false to accept it.
  bool onSetValue(dynamic val) => false;

  /// Callback used to accept or reject a value of a config when it is set.
  /// Return true to reject the value, and false to accept it.
  bool onSetConfig(String name, dynamic value) => false;

  /// Callback used to accept or reject a value of an attribute when it is set.
  /// Return true to reject the value, and false to accept it.
  bool onSetAttribute(String name, dynamic value) => false;

  // Callback used to notify a node that it is being subscribed to.
  void onSubscribe() {}

  // Callback used to notify a node that a subscribe has unsubscribed.
  void onUnsubscribe() {}

  /// Callback used to notify a node that it was created.
  /// This is called after a node is deserialized as well.
  void onCreated() {}

  /// Callback used to notify a node that it is about to be removed.
  void onRemoving() {}

  /// Callback used to notify a node that one of it's children has been removed.
  void onChildRemoved(String name, Node node) {}

  /// Callback used to notify a node that a child has been added to it.
  void onChildAdded(String name, Node node) {}

  @override
  RespSubscribeListener subscribe(ValueUpdateCallback callback, [int qos = 0]) {
    onSubscribe();
    return super.subscribe(callback, qos);
  }

  @override
  void unsubscribe(ValueUpdateCallback callback) {
    onUnsubscribe();
    super.unsubscribe(callback);
  }

  /// Callback to override how a child of this node is loaded.
  /// If this method returns null, the default strategy is used.
  SimpleNode? onLoadChild(String name, Map data, SimpleNodeProvider provider) {
    return null;
  }

  /// Creates a child with the given [name].
  /// If [m] is specified, the node is loaded with that map.
  SimpleNode createChild(String name, [Map? m]) {
    var tp = Path(path).child(name).path;
    return provider.addNode(tp, m ?? <String, dynamic>{}) as SimpleNode;
  }

  /// Gets the name of this node.
  /// This is the last component of this node's path.
  String get name => Path(path).name;

  /// Gets the current display name of this node.
  /// This is the $name config. If it does not exist, then null is returned.
  String? get displayName => configs[r'$name'] as String?;

  /// Sets the display name of this node.
  /// This is the $name config. If this is set to null, then the display name is removed.
  set displayName(String? value) {
    if (value == null) {
      configs.remove(r'$name');
    } else {
      configs[r'$name'] = value;
    }

    updateList(r'$name');
  }

  /// Gets the current value type of this node.
  /// This is the $type config. If it does not exist, then null is returned.
  String get type => configs[r'$type'] as String;

  /// Sets the value type of this node.
  /// This is the $type config. If this is set to null, then the value type is removed.
  set type(String? value) {
    if (value == null) {
      configs.remove(r'$type');
    } else {
      configs[r'$type'] = value;
    }

    updateList(r'$type');
  }

  /// Gets the current value of the $writable config.
  /// If it does not exist, then null is returned.
  String? get writable => configs[r'$writable'] as String?;

  /// Sets the value of the writable config.
  /// If this is set to null, then the writable config is removed.
  set writable(dynamic value) {
    if (value == null) {
      configs.remove(r'$writable');
    } else if (value is bool) {
      if (value) {
        configs[r'$writable'] = 'write';
      } else {
        configs.remove(r'$writable');
      }
    } else {
      configs[r'$writable'] = value.toString();
    }

    updateList(r'$writable');
  }

  /// Checks if this node has the specified config.
  bool hasConfig(String name) =>
      configs.containsKey(name.startsWith(r'$') ? name : '\$' + name);

  /// Checks if this node has the specified attribute.
  bool hasAttribute(String name) =>
      attributes.containsKey(name.startsWith('@') ? name : '@' + name);

  /// Remove this node from it's parent.
  void remove() {
    provider.removeNode(path);
  }

  /// Add this node to the given node.
  /// If [input] is a String, it is interpreted as a node path and resolved to a node.
  /// If [input] is a [SimpleNode], it will be attached to that.
  void attach(dynamic input, {String? name}) {
    name ??= this.name;

    if (input is String) {
      provider.getNode(input)?.addChild(name, this);
    } else if (input is SimpleNode) {
      input.addChild(name, this);
    } else {
      throw 'Invalid Input';
    }
  }

  /// Adds the given [node] as a child of this node with the given [name].
  @override
  void addChild(String name, Node node) {
    super.addChild(name, node);
    updateList(name);
  }

  /// Removes a child from this node.
  /// If [input] is a String, a child named with the specified [input] is removed.
  /// If [input] is a Node, the child that owns that node is removed.
  /// The name of the removed node is returned.
  @override
  String? removeChild(dynamic input) {
    var name = super.removeChild(input);
    if (name != null) {
      updateList(name);
    }
    return name;
  }

  @override
  Response? setAttribute(
      String name, dynamic value, Responder responder, Response? response) {
    if (onSetAttribute(name, value) != true) {
      // when callback returns true, value is rejected
      super.setAttribute(name, value, responder, response);
    }
    return response;
  }

  @override
  Response? setConfig(
      String name, dynamic value, Responder responder, Response? response) {
    if (onSetConfig(name, value) != true) {
      // when callback returns true, value is rejected
      super.setConfig(name, value, responder, response);
    }
    return response;
  }

  @override
  Response? setValue(dynamic value, Responder? responder, Response? response,
      [int maxPermission = Permission.CONFIG]) {
    if (onSetValue(value) != true) {
      // when callback returns true, value is rejected
      super.setValue(value, responder, response, maxPermission);
    }
    return response;
  }

  @override
  Object? operator [](String name) => get(name);

  @override
  operator []=(String name, value) {
    if (name.startsWith(r'$') || name.startsWith(r'@')) {
      if (name.startsWith(r'$')) {
        configs[name] = value;
      } else {
        attributes[name] = value;
      }
    } else {
      if (value is Node) {
        addChild(name, value);
      } else {
        throw ArgumentError('Invalid value type. Expected Node.');
      }
    }
  }
}

/// A hidden node.
class SimpleHiddenNode extends SimpleNode {
  SimpleHiddenNode(String path, SimpleNodeProvider provider)
      : super(path, provider) {
    configs[r'$hidden'] = true;
  }

  @override
  Map getSimpleMap() {
    var rslt = <String, dynamic>{r'$hidden': true};

    if (configs.containsKey(r'$is')) {
      rslt[r'$is'] = configs[r'$is'];
    }

    if (configs.containsKey(r'$type')) {
      rslt[r'$type'] = configs[r'$type'];
    }

    if (configs.containsKey(r'$name')) {
      rslt[r'$name'] = configs[r'$name'];
    }

    if (configs.containsKey(r'$invokable')) {
      rslt[r'$invokable'] = configs[r'$invokable'];
    }

    if (configs.containsKey(r'$writable')) {
      rslt[r'$writable'] = configs[r'$writable'];
    }
    return rslt;
  }
}
