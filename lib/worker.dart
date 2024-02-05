/// API for distributing work across multiple independent isolates.
library dslink.worker;

import 'dart:async';
import 'dart:isolate';

import 'package:dslink/utils.dart' show generateBasicId, logger,
  ExecutableFunction,
  Taker;

export 'package:dslink/utils.dart' show Taker;

typedef WorkerFunction = void Function(Worker worker);

WorkerSocket createWorker(
  WorkerFunction function, {
    Map<String, dynamic>? metadata
  }) {
  var receiver = ReceivePort();
  var socket = WorkerSocket.master(receiver);
  var errorReceiver = ReceivePort();
  Isolate.spawn(function, Worker(receiver.sendPort, metadata), onError: errorReceiver.sendPort).then((x) {
    socket._isolate = x;
  });
  errorReceiver.listen((dynamic data){
    logger.severe(data);
  });
  return socket;
}

WorkerSocket createFakeWorker(WorkerFunction function,
    {Map<String, dynamic>? metadata}) {
  var receiver = ReceivePort();
  var socket = WorkerSocket.master(receiver);
  Timer.run(() {
    var w = Worker(receiver.sendPort, metadata);
    w._master = socket;
    function(w);
  });
  return socket;
}

Worker buildWorkerForScript(Map<String, dynamic>? data) {
  SendPort? port;
  Map<String, dynamic>? metadata;

  if (data?['port'] is SendPort) {
    port = data?['port'];
  }

  if (data?['metadata'] is Map<String, dynamic>) {
    metadata = data?['metadata'] as Map<String, dynamic>;
  }

  return Worker(port, metadata);
}

WorkerSocket createWorkerScript(dynamic script,
    {List<String>? args, Map<String, dynamic>? metadata}) {
  var receiver = ReceivePort();
  var socket = WorkerSocket.master(receiver);
  Uri uri;

  if (script is Uri) {
    uri = script;
  } else if (script is String) {
    uri = Uri.parse(script);
  } else {
    throw ArgumentError.value(
        script, 'script', 'should be either a Uri or a String.');
  }

  Isolate.spawnUri(uri, [], {'port': receiver.sendPort, 'metadata': metadata})
      .then((x) {
    socket._isolate = x;
  });
  return socket;
}

WorkerPool createWorkerScriptPool(int count, Uri uri,
    {Map<String, dynamic>? metadata}) {
  var workers = <WorkerSocket>[];
  for (var i = 1; i <= count; i++) {
    workers.add(createWorkerScript(uri,
      metadata: <String, dynamic>{
        'workerId': i
      }..addAll(metadata ?? <String, dynamic>{})
    ));
  }
  return WorkerPool(workers);
}

WorkerPool createWorkerPool(int count, WorkerFunction function,
    {Map<String, dynamic>? metadata}) {
  var workers = <WorkerSocket>[];
  for (var i = 1; i <= count; i++) {
    workers.add(
      createWorker(function, metadata: <String, dynamic>{
        'workerId': i
      }..addAll(metadata ?? <String, dynamic>{})));
  }
  return WorkerPool(workers);
}

class WorkerPool {
  final List<WorkerSocket> sockets;
  final Map<String, Taker> _methods = {};

  WorkerPool(this.sockets) {
    resync();
  }

  Function? onMessageReceivedHandler;

  Future waitFor() {
    return Future.wait<void>(sockets.map((it) => it.waitFor()).toList());
  }

  Future stop() {
    return Future.wait<void>(sockets.map((it) => it.stop()).toList());
  }

  Future ping() {
    return Future.wait<void>(sockets.map((it) => it.ping()).toList());
  }

  void reduceWorkers(int count) async {
    if (sockets.length > count) {
      var toRemove = sockets.length - count;
      var socks = sockets
        .skip(count)
        .take(toRemove)
        .toList();
      for (var sock in socks) {
        await sock.close();
        sock.kill();
        sockets.remove(sock);
      }
    }
  }

  void resizeFunctionWorkers(int count, WorkerFunction function,
    {Map<String, dynamic>? metadata}) async {
    if (sockets.length < count) {
      for (var i = sockets.length + 1; i <= count; i++) {
        var sock = createWorker(function, metadata: <String, dynamic>{
          'workerId': i
        }..addAll(metadata ?? <String, dynamic>{}));
        sock._pool = this;
        sock.onReceivedMessageHandler = (dynamic msg) {
          if (onMessageReceivedHandler != null) {
            onMessageReceivedHandler!(i, msg);
          }
        };
        await sock.init();
        sockets.add(sock);
      }
    } else {
      reduceWorkers(count);
    }
  }

  void send(dynamic data) {
    forEach((socket) => socket.send(data));
  }

  void listen(void Function(int worker,dynamic event) handler) {
    var i = 0;
    for (var worker in sockets) {
      var id = i;
      worker.listen((dynamic e) {
        handler(id, e);
      });
      i++;
    }
  }

  Future<WorkerPool> init() =>
      Future.wait(sockets.map((it) => it.init()).toList()).then((_) => this);

  void forEach(void Function(WorkerSocket socket) handler) {
    sockets.forEach(handler);
  }

  void addMethod(String name, Taker handler) {
    _methods[name] = handler;
  }

  Future<List<dynamic>> callMethod(String name, [dynamic argument]) {
    return Future
        .wait<void>(sockets.map((it) => it.callMethod(name, argument)).toList());
  }

  Future<dynamic> divide(String name, int count,
      {dynamic Function()? next, dynamic Function(List<dynamic> inputs)? collect}) async {
    if (next == null) {
      var i = 0;
      next = () {
        return i++;
      };
    }

    var futures = <Future>[];
    for (var i = 1; i <= count; i++) {
      dynamic input = next();
      futures.add(getAvailableWorker().callMethod(name, input));
    }

    var outs = await Future.wait<void>(futures);

    return collect != null ? await collect(outs) : outs;
  }

  Future<WorkerSession> createSession([dynamic initialMessage]) {
    return getAvailableWorker().createSession(initialMessage);
  }

  final StreamController<WorkerSession> _sessionController =
      StreamController<WorkerSession>.broadcast();
  Stream<WorkerSession> get sessions {
    if (!_sessionListened) {
      sockets.forEach((x) => _sessionController.addStream(x.sessions));
      _sessionListened = true;
    }
    return _sessionController.stream;
  }

  bool _sessionListened = false;

  Future<dynamic> distribute(String name, [dynamic argument]) {
    return getAvailableWorker().callMethod(name, argument);
  }

  void resetDistributionCache() {
    for (var i in _workCounts.keys.toList()) {
      _workCounts[i] = 0;
    }
  }

  int getAvailableWorkerId() {
    var ids = _workCounts.keys.toList();
    ids.sort((a, b) => _workCounts[a]!.compareTo(_workCounts[b]!));
    var best = ids.first;
    _workCounts[best] = _workCounts[best]! + 1;
    return best;
  }

  WorkerSocket getAvailableWorker() {
    return workerAt(getAvailableWorkerId());
  }

  void resync() {
    for (var i = 0; i < sockets.length; i++) {
      _workCounts[i] = 0;
      sockets[i]._pool = this;
      sockets[i].onReceivedMessageHandler = (dynamic msg) {
        if (onMessageReceivedHandler != null) {
          onMessageReceivedHandler!(i, msg);
        }
      };
    }
  }

  final Map<int, int> _workCounts = {};

  WorkerSocket workerAt(int id) => sockets[id];
  WorkerSocket operator [](int id) => workerAt(id);
}

class Worker {
  final SendPort? port;
  final Map<String, dynamic> metadata;

  Worker(this.port, [Map<String, dynamic>? meta])
      : metadata = meta ?? <String, dynamic>{};

  WorkerSocket createSocket() {
    var sock = WorkerSocket.worker(port!);
    if (_master != null) {
      sock._master = _master;
      _master?._targetWorker = sock;
    }
    return sock;
  }

  Future<WorkerSocket> init({Map<String, Taker>? methods}) async =>
      await createSocket().init(methods: methods);

  dynamic get(String key) => metadata[key];
  bool has(String key) => metadata.containsKey(key);

  WorkerSocket? _master;
}

typedef Future<T> WorkerMethod<T>([dynamic argument]);

class WorkerSocket extends Stream<dynamic> implements StreamSink<dynamic> {
  static WorkerSocket? globalSocket;

  final ReceivePort receiver;
  late SendPort _sendPort;

  WorkerSocket.master(this.receiver) : isWorker = false {
    receiver.listen(handleData);
  }

  WorkerSocket.worker(SendPort port)
      : _sendPort = port,
        receiver = ReceivePort(),
        isWorker = true {
    _sendPort.send({'t': 'send_port', 'port': receiver.sendPort});

    receiver.listen(handleData);
  }

  Function? onReceivedMessageHandler;

  WorkerPool? _pool;

  WorkerSession? getRemoteSession(String id) => _remoteSessions[id];

  WorkerSession? getLocalSession(String id) => _ourSessions[id];

  void handleData(dynamic msg) {
    if (onReceivedMessageHandler != null) {
      onReceivedMessageHandler!(msg);
    }

    if (msg == null || msg is! Map) {
      return;
    }

    String? type = msg['t'];

    type ??= msg['type'];

    if (type == null) {
      return;
    }

    if (type == 'send_port') {
      _sendPort = msg['port'];
      if (!_readyCompleter.isCompleted) {
        _readyCompleter.complete();
      }
    } else if (type == 'data') {
      _controller.add(msg['d']);
    } else if (type == 'error') {
      _controller.addError(msg['e']);
    } else if (type == 'ping') {
      _sendPort.send(<String, dynamic>{
        't': 'pong',
        'i': msg['i']
      });
    } else if (type == 'pong') {
      String id = msg['i'];
      if (_pings.containsKey(id)) {
        _pings[id]?.complete();
        _pings.remove(id);
      }
    } else if (type == 'req') {
      _handleRequest(msg['n'], msg['i'], msg['a']);
    } else if (type == 'res') {
      String id = msg['i'];
      dynamic result = msg['r'];
      dynamic err = msg['e'];
      if (err != null) {
        if (_responseHandlers.containsKey(id)) {
          _responseHandlers.remove(id)?.completeError(
              err,
              StackTrace.fromString(msg['s'])
          );
        } else {
          throw Exception('Invalid Request ID: $id');
        }
      } else {
        if (_responseHandlers.containsKey(id)) {
          _responseHandlers.remove(id)?.complete(result);
        } else {
          throw Exception('Invalid Request ID: $id');
        }
      }
    } else if (type == 'stop') {
      if (!_stopCompleter.isCompleted) {
        _stopCompleter.complete();
      }
      _sendPort.send({'t': 'stopped'});
    } else if (type == 'stopped') {
      if (!_stopCompleter.isCompleted) {
        _stopCompleter.complete();
      }
    } else if (type == 'session.created') {
      String id = msg['s'];
      _remoteSessions[id] = _WorkerSession(this, id, false, msg['n']);
      _sendPort.send({'t': 'session.ready', 's': id});
      _sessionController.add(_remoteSessions[id]!);
    } else if (type == 'session.ready') {
      String id = msg['s'];
      if (_sessionReady.containsKey(id)) {
        _sessionReady[id]?.complete();
        _sessionReady.remove(id);
      }
    } else if (type == 'session.data') {
      String id = msg['s'];
      if (_ourSessions.containsKey(id)) {
        (_ourSessions[id] as _WorkerSession)._messages.add(msg['d']);
      } else if (_remoteSessions.containsKey(id)) {
        (_remoteSessions[id] as _WorkerSession)._messages.add(msg['d']);
      }
    } else if (type == 'session.done') {
      String id = msg['s'];
      if (_ourSessions.containsKey(id)) {
        var c = (_ourSessions[id] as _WorkerSession)._doneCompleter;
        if (!c.isCompleted) {
          c.complete();
        }
        _ourSessions.remove(id);
      } else if (_remoteSessions.containsKey(id)) {
        var c = (_remoteSessions[id] as _WorkerSession)._doneCompleter;
        if (!c.isCompleted) {
          c.complete();
        }
        _remoteSessions.remove(id);
      }
    } else {
      throw Exception('Unknown message: $msg');
    }
  }

  final Map<int, Completer> _pings = {};

  final bool isWorker;

  bool get isMaster => !isWorker;

  Future waitFor() {
    if (isWorker) {
      return Future<void>.value();
    } else {
      return _readyCompleter.future;
    }
  }

  Future<WorkerSocket> init({Map<String, Taker>? methods}) {
    if (methods != null) {
      for (var key in methods.keys) {
        addMethod(key, methods[key]!);
      }
    }
    return waitFor().then((dynamic _) => this);
  }

  void addMethod(String name, Taker Taker) {
    _requestHandlers[name] = Taker;
  }

  WorkerSocket? _master;
  WorkerSocket? _targetWorker;

  Future callMethod(String name, [dynamic argument]) {
    if (isWorker && _master != null) {
      var handler = _master?._requestHandlers[name];
      handler ??= _master?._pool?._methods[name];

      dynamic result = handler!(argument);
      if (result is! Future) {
        return Future<void>.value(result);
      } else {
        return result;
      }
    } else if (_targetWorker != null) {
      var handler = _targetWorker?._requestHandlers[name];
      handler ??= _targetWorker?._pool?._methods[name];

      dynamic result = handler!(argument);
      if (result is! Future) {
        return Future<void>.value(result);
      } else {
        return result;
      }
    }

    var completer = Completer<void>();

    var rid = 0;
    while (_responseHandlers[rid] != null) {
      rid++;
    }

    _responseHandlers[rid] = completer;
    if (argument == null) {
      _sendPort.send(
          {'t': 'req', 'i': rid, 'n': name});
    } else {
      _sendPort.send(<String, dynamic>
          {'t': 'req', 'i': rid, 'n': name, 'a': argument});
    }
    return completer.future;
  }

  WorkerMethod<dynamic> getMethod(String name) =>
      ([dynamic argument]) => callMethod(name, argument);

  void _handleRequest(String name, int id,dynamic argument) async {
    try {
      if ((_pool != null && _pool!._methods.containsKey(name)) || _requestHandlers.containsKey(name)) {
        var handler = (_pool != null && _pool!._methods.containsKey(name)) ?
          _pool?._methods[name] :
          _requestHandlers[name];
        dynamic result = handler!(argument);
        if (result is Future) {
          result = await result;
        }

        if (result == null) {
          _sendPort.send({'t': 'res', 'i': id});
        } else {
          _sendPort.send(<String, dynamic>{'t': 'res', 'i': id, 'r': result});
        }
      } else {
        throw Exception('Invalid Method: $name');
      }
    } catch (e, stack) {
      _sendPort.send({
        't': 'res',
        'i': id,
        'e': e.toString(),
        's': stack.toString()
      });
    }
  }

  final Map<int, Completer> _responseHandlers = {};
  final Map<String, Taker> _requestHandlers = {};

  final Completer _readyCompleter = Completer<void>();

  int _pingId = 0;

  Future ping() {
    var completer = Completer<void>();
    _pings[_pingId] = completer;
    _sendPort.send({'t': 'ping', 'i': _pingId});
    _pingId++;
    return completer.future;
  }

  @override
  void add(dynamic event) {
    _sendPort.send(<String, dynamic>{'t': 'data', 'd': event});
  }

  void send(dynamic event) => add(event);

  @override
  void addError(errorEvent, [StackTrace? stackTrace]) {
    _sendPort.send({'t': 'error', 'e': errorEvent});
  }

  @override
  Future addStream(Stream stream) {
    return stream.listen((dynamic data) {
      add(data);
    }).asFuture<void>();
  }

  Future stop() => close();

  @override
  Future close() {
    _sendPort.send({'t': 'stop'});
    return _stopCompleter.future.then<void>((dynamic _) {
      if (isMaster) {
        receiver.close();
      } else {
        return Future.delayed(Duration(seconds: 1), () {
          receiver.close();
        });
      }
    });
  }

  Future<WorkerSession> createSession([dynamic initial]) async {
    var s = generateBasicId(length: 25);
    var session = _WorkerSession(this, s, true, initial);
    _sendPort.send(<String, dynamic>{'t': 'session.created', 's': s, 'n': initial});
    await ((_sessionReady[s] = Completer<void>.sync()).future);
    _ourSessions[s] = session;
    return session;
  }

  final Map<String, Completer> _sessionReady = {};
  final Map<String, WorkerSession> _ourSessions = {};
  final Map<String, WorkerSession> _remoteSessions = {};

  Stream<WorkerSession> get sessions => _sessionController.stream;

  final StreamController<WorkerSession> _sessionController =
      StreamController<WorkerSession>.broadcast();

  @override
  Future get done => _stopCompleter.future;

  final Completer _stopCompleter = Completer<void>();

  @override
  StreamSubscription listen(void Function(dynamic event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  bool kill() {
    receiver.close();
    if (_isolate != null) {
      _isolate?.kill();
      return true;
    } else {
      return false;
    }
  }

  Isolate? _isolate;

  final StreamController _controller = StreamController<void>.broadcast();
}

abstract class WorkerSession {
  dynamic get initialMessage;
  String get id;
  void send(dynamic data);
  Future close();
  Future get done;
  bool get isClosed;
  Stream get messages;
}

class _WorkerSession extends WorkerSession {
  final bool creator;
  @override
  final String id;
  final WorkerSocket _socket;

  final Completer _doneCompleter = Completer<void>.sync();
  final StreamController _messages = StreamController<void>();
  Stream? _messageBroadcast;

  _WorkerSession(this._socket, this.id, this.creator, this._initialMessage);

  @override
  Future close() {
    _socket._sendPort.send({'t': 'session.done', 's': id});
    Future(() {
      if (!_doneCompleter.isCompleted) {
        _doneCompleter.complete();
      }
      _socket._remoteSessions.remove(id);
      _socket._ourSessions.remove(id);
      _messages.close();
    });
    return done;
  }

  @override
  Future get done => _doneCompleter.future;

  @override
  Stream get messages {
    _messageBroadcast ??= _messages.stream.asBroadcastStream();

    return _messageBroadcast!;
  }

  @override
  void send(dynamic data) {
    _socket._sendPort.send(<String, dynamic>{'t': 'session.data', 's': id, 'd': data});
  }

  @override
  bool get isClosed => _doneCompleter.isCompleted;

  final dynamic _initialMessage;
  @override
  dynamic get initialMessage => _initialMessage;
}

class WorkerBuilder {
  final Map<String, Taker> hosts;
  final Map<String, Taker> slaves;

  WorkerBuilder._(this.hosts, this.slaves);

  factory WorkerBuilder() {
    return WorkerBuilder._({}, {});
  }

  WorkerBuilder host(String name,Function function) {
    if (function is ExecutableFunction) {
      function = (dynamic _) => function();
    }

    hosts[name] = function as dynamic Function(dynamic);
    return this;
  }

  WorkerBuilder slave(String name, Taker function) {
    slaves[name] = function;
    return this;
  }

  WorkerBuilder global(String name, Taker function) {
    hosts[name] = function;
    slaves[name] = function;
    return this;
  }

  Future<WorkerSocket> spawn([WorkerFunction? function]) async {
    function ??= defaultWorkerFunction;

    var meta = {
      'methods': slaves
    };

    return await createWorker(function, metadata: meta).init(methods: hosts);
  }

  static Future<WorkerSocket> defaultWorkerFunction(Worker worker) async {
    Map<String, WorkerMethod>? methods;

    if (worker.get('methods') is Map<String, WorkerMethod>) {
      methods = worker.get('methods') as Map<String, WorkerMethod>;
    }

    return await worker.init(methods: methods);
  }
}
