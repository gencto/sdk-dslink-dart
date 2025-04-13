part of dsalink.utils;

class BroadcastStreamController<T> implements StreamController<T> {
  late StreamController<T> _controller;
  late CachedStreamWrapper<T> _stream;
  @override
  Stream<T> get stream => _stream;

  Function? onStartListen;
  Function? onAllCancel;

  BroadcastStreamController([
    void Function()? onStartListen,
    void Function()? onAllCancel,
    void Function(Function(T value) callback)? onListen,
    bool sync = false,
  ]) {
    _controller = StreamController<T>(sync: sync);
    _stream = CachedStreamWrapper(
      _controller.stream.asBroadcastStream(
        onListen: _onListen,
        onCancel: _onCancel,
      ),
      onListen,
    );
    this.onStartListen = onStartListen;
    this.onAllCancel = onAllCancel;
  }

  /// whether there is listener or not
  bool _listening = false;

  /// whether _onStartListen is called
  bool _listenState = false;
  void _onListen(StreamSubscription<T> subscription) {
    if (!_listenState) {
      if (onStartListen != null) {
        onStartListen!();
      }
      _listenState = true;
    }
    _listening = true;
  }

  void _onCancel(StreamSubscription<T> subscription) {
    _listening = false;
    if (onAllCancel != null) {
      if (!_delayedCheckCanceling) {
        _delayedCheckCanceling = true;
        DsTimer.callLater(delayedCheckCancel);
      }
    } else {
      _listenState = false;
    }
  }

  bool _delayedCheckCanceling = false;
  void delayedCheckCancel() {
    _delayedCheckCanceling = false;
    if (!_listening && _listenState) {
      onAllCancel!();
      _listenState = false;
    }
  }

  @override
  void add(T t) {
    _controller.add(t);
    _stream.lastValue = t;
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _controller.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<T> source, {bool? cancelOnError = true}) {
    return _controller.addStream(source, cancelOnError: cancelOnError);
  }

  @override
  Future close() {
    return _controller.close();
  }

  @override
  Future get done => _controller.done;

  @override
  bool get hasListener => _controller.hasListener;

  @override
  bool get isClosed => _controller.isClosed;

  @override
  bool get isPaused => _controller.isPaused;

  @override
  StreamSink<T> get sink => _controller.sink;

  @override
  set onCancel(Function()? onCancelHandler) {
    throw ('BroadcastStreamController.onCancel not implemented');
  }

  @override
  set onListen(void Function()? onListenHandler) {
    throw ('BroadcastStreamController.onListen not implemented');
  }

  @override
  set onPause(void Function()? onPauseHandler) {
    throw ('BroadcastStreamController.onPause not implemented');
  }

  @override
  set onResume(void Function()? onResumeHandler) {
    throw ('BroadcastStreamController.onResume not implemented');
  }

  @override
  ControllerCancelCallback? get onCancel => null;
  @override
  ControllerCallback? get onListen => null;
  @override
  ControllerCallback? get onPause => null;
  @override
  ControllerCallback? get onResume => null;
}

class CachedStreamWrapper<T> extends Stream<T> {
  late T lastValue;

  final Stream<T> _stream;
  final Function? _onListen;
  CachedStreamWrapper(this._stream, this._onListen);

  @override
  Stream<T> asBroadcastStream({
    void Function(StreamSubscription<T> subscription)? onListen,
    void Function(StreamSubscription<T> subscription)? onCancel,
  }) {
    return this;
  }

  @override
  bool get isBroadcast => true;

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    if (_onListen != null && onData != null) {
      _onListen(onData);
    }

    return _stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
