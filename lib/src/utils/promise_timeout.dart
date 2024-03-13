part of dslink.utils;

Future awaitWithTimeout(Future future, int timeoutMs,
    {Function? onTimeout,
    Function? onSuccessAfterTimeout,
    Function? onErrorAfterTimeout}) {
  var completer = Completer<dynamic>();

  var timer = Timer(Duration(milliseconds: timeoutMs), () {
    if (!completer.isCompleted) {
      if (onTimeout != null) {
        onTimeout();
      }
      completer.completeError(Exception('Future timeout before complete'));
    }
  });
  future.then((dynamic t) {
    if (completer.isCompleted) {
      if (onSuccessAfterTimeout != null) {
        onSuccessAfterTimeout(t);
      }
    } else {
      timer.cancel();
      completer.complete(t);
    }
  }).catchError((dynamic err) {
    if (completer.isCompleted) {
      if (onErrorAfterTimeout != null) {
        onErrorAfterTimeout(err);
      }
    } else {
      timer.cancel();
      completer.completeError(err);
    }
  });

  return completer.future;
}
