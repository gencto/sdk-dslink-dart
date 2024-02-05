part of dslink.utils;

final class TimerFunctions extends LinkedListEntry<TimerFunctions> {
  /// for better performance, use a low accuracy timer, ts50 is the floor of ts/50
  final int ts50;
  final List<Function> _functions = [];

  TimerFunctions(this.ts50);

  void add(Function foo) {
    if (!_functions.contains(foo)) {
      _functions.add(foo);
    }
  }

  void remove(Function foo) {
    _functions.remove(foo);
  }
}

class DsTimer {
  static int millisecondsSinceEpoch() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static Future waitAndRun(Duration time, Function() action) {
    return Future<void>.delayed(time, action);
  }

  // TODO: does it need to use another hashset for quick search?
  static List<Function> _callbacks = [];

  //static Map<Function, int> _timerCallbacks = new Map<Function, int>();

  static void _startTimer() {
    Timer.run(_dsLoop);
    _pending = true;
  }

  static void callLater(Function callback) {
    if (!_pending) {
      _startTimer();
    }
    _callbacks.add(callback);
  }

//  /// call the function and remove it from the pending listh
//  static void callNow(Function callback) {
//    if (_callbacks.contains(callback)) {
//      _callbacks.remove(callback);
//    }
//    callback();
//  }
//
//  static void cancel(Function callback) {
//    if (_callbacks.contains(callback)) {
//      _callbacks.remove(callback);
//    }
//  }

  static final LinkedList<TimerFunctions> _pendingTimer =
      LinkedList<TimerFunctions>();
  static final Map<int, TimerFunctions> _pendingTimerMap =
      <int, TimerFunctions>{};
  static final Map<Function, TimerFunctions> _functionsMap =
      <Function, TimerFunctions>{};

  static TimerFunctions _getTimerFunctions(int time50) {
    var tf = _pendingTimerMap[time50];

    if (tf != null) {
      return tf;
    }

    tf = TimerFunctions(time50);
    _pendingTimerMap[time50] = tf;
    TimerFunctions? it;
    if (_pendingTimer.isNotEmpty) {
      it = _pendingTimer.first;
    }

    while (it != null) {
      if (it.ts50 > time50) {
        it.insertBefore(tf);
        break;
      } else if (it.next != _pendingTimer && it.next != it) {
        it = it.next;
      } else {
        it = null;
      }
    }

    if (it == null) {
      _pendingTimer.add(tf);
    }

    if (!_pending) {
      _startTimer();
    }
    return tf;
  }

  static TimerFunctions? _removeTimerFunctions(int time50) {
    if (_pendingTimer.isNotEmpty && _pendingTimer.first.ts50 <= time50) {
      var rslt = _pendingTimer.first;
      _pendingTimerMap.remove(rslt.ts50);
      rslt.unlink();
      for (var fun in rslt._functions) {
        _functionsMap.remove(fun);
        try{
          fun();
        } catch(err,stack) {
          print('callback error; $err\n$stack');
        }
      }
      return rslt;
    }
    return null;
  }

  static int _lastTimeRun = -1;

  /// do nothing if the callback is already in the list and will get called after 0 ~ N ms
  static void timerOnceBefore(Function callback, int ms) {
    var desiredTime50 =
        (((DateTime.now()).millisecondsSinceEpoch + ms) / 50).ceil();
    if (_functionsMap.containsKey(callback)) {
      var existTf = _functionsMap[callback]!;
      if (existTf.ts50 <= desiredTime50) {
        return;
      } else {
        existTf.remove(callback);
      }
    }

    if (desiredTime50 <= _lastTimeRun) {
      callLater(callback);
      return;
    }
    var tf = _getTimerFunctions(desiredTime50);
    tf.add(callback);
    _functionsMap[callback] = tf;
  }

  /// do nothing if the callback is already in the list and will get called after N or more ms
  static void timerOnceAfter(Function callback, int ms) {
    var desiredTime50 =
        (((DateTime.now()).millisecondsSinceEpoch + ms) / 50).ceil();
    if (_functionsMap.containsKey(callback)) {
      var existTf = _functionsMap[callback]!;
      if (existTf.ts50 >= desiredTime50) {
        return;
      } else {
        existTf.remove(callback);
      }
    }
    if (desiredTime50 <= _lastTimeRun) {
      callLater(callback);
      return;
    }
    var tf = _getTimerFunctions(desiredTime50);
    tf.add(callback);
    _functionsMap[callback] = tf;
  }

  /// do nothing if the callback is already in the list and will get called after M to N ms
  static void timerOnceBetween(Function callback, int after, int before) {
    var desiredTime50_0 =
        (((DateTime.now()).millisecondsSinceEpoch + after) / 50).ceil();
    var desiredTime50_1 =
        (((DateTime.now()).millisecondsSinceEpoch + before) / 50).ceil();
    if (_functionsMap.containsKey(callback)) {
      var existTf = _functionsMap[callback]!;
      if (existTf.ts50 >= desiredTime50_0 && existTf.ts50 <= desiredTime50_1) {
        return;
      } else {
        existTf.remove(callback);
      }
    }
    if (desiredTime50_1 <= _lastTimeRun) {
      callLater(callback);
      return;
    }
    var tf = _getTimerFunctions(desiredTime50_1);
    tf.add(callback);
    _functionsMap[callback] = tf;
  }

  static void timerCancel(Function callback) {
    // TODO: what if timerCancel is called from another timer of group?
    var existTf = _functionsMap[callback];

    if (existTf != null) {
      existTf.remove(callback);
    }
  }

  static bool _pending = false;
  static bool _looping = false;
  static bool _mergeCycle = false;

  static void _dsLoop() {
    _pending = false;
    _looping = true;

    var runnings = _callbacks;

    _callbacks = [];

    for (var f in runnings) {
      try{
        f();
      } catch(err,stack) {
        print('callback error; $err\n$stack');
      }
    }

    var currentTime = (DateTime.now()).millisecondsSinceEpoch;
    _lastTimeRun = (currentTime / 50).floor();
    while (_removeTimerFunctions(_lastTimeRun) != null) {
      // run the timer functions, empty loop
    }

    _looping = false;
    if (_mergeCycle) {
      _mergeCycle = false;
      _dsLoop();
    }

    if (_pendingTimer.isNotEmpty) {
      if (!_pending) {
        if (timerTs50 != _pendingTimer.first.ts50) {
          timerTs50 = _pendingTimer.first.ts50;
          if (timerTimer != null && timerTimer!.isActive) {
            timerTimer?.cancel();
          }
          var duration = Duration(milliseconds: timerTs50 * 50 + 1 - currentTime);
          timerTimer = Timer(duration, _startTimer);
        }
      }
    } else if (timerTimer != null) {
      if (timerTimer!.isActive) {
        timerTimer?.cancel();
      }
      timerTimer = null;
    }
  }

  static int timerTs50 = -1;
  static Timer? timerTimer;

  // don't wait for the timer, run it now
  static void runNow() {
    if (_looping) {
      _mergeCycle = true;
    } else {
      _dsLoop();
    }
  }
}
