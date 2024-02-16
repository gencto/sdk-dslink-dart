/// Common Utilities for DSA Components
library dslink.utils;

import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:math';

import 'package:logging/logging.dart';
import 'package:msgpack_dart/msgpack_dart.dart';

part 'src/utils/base64.dart';
part 'src/utils/timer.dart';
part 'src/utils/stream_controller.dart';
part 'src/utils/codec.dart';
part 'src/utils/dslink_json.dart';
part 'src/utils/list.dart';
part 'src/utils/uri_component.dart';
part 'src/utils/promise_timeout.dart';

typedef ExecutableFunction();
typedef T Producer<T>();
typedef Taker<T>(T value);
typedef TwoTaker<A, B>(A a, B b);

/// The DSA Version
const String DSA_VERSION = '1.1.2';

Logger? _logger;

bool? _DEBUG_MODE;

List<int> foldList(List<int> a, List<int> b) {
  return a..addAll(b);
}

// Count the frequency of the character [char] in the string [input].
int countCharacterFrequency(String input, String char) {
  var c = char.codeUnitAt(0);

  return input.codeUnits.where((u) => c == u).length;
}

/// Gets if we are in checked mode.
bool get DEBUG_MODE {
  if (_DEBUG_MODE != null) {
    return _DEBUG_MODE!;
  }

  try {
    assert(false);
    _DEBUG_MODE = false;
  } catch (e) {
    _DEBUG_MODE = true;
  }
  return _DEBUG_MODE!;
}

class DSLogUtils {
  static void withLoggerName(String name, Function() handler) {
    return runZoned(handler, zoneValues: {'dsa.logger.name': name});
  }

  static void withSequenceNumbers(Function() handler) {
    return runZoned(handler, zoneValues: {'dsa.logger.sequence': true});
  }

  static void withNoLoggerName(Function() handler) {
    return runZoned(handler, zoneValues: {'dsa.logger.show_name': false});
  }

  static void withInlineErrorsDisabled(Function() handler) {
    return runZoned(handler, zoneValues: {'dsa.logger.inline_errors': false});
  }

  static void withLoggerOff(Function() handler) {
    return runZoned(handler, zoneValues: {'dsa.logger.print': false});
  }
}

const bool _isJavaScript = identical(1, 1.0);

bool _getLogSetting(LogRecord record, String name,
    [bool defaultValue = false]) {
  if (record.zone?[name] is bool) {
    return record.zone?[name];
  }

  if (!_isJavaScript) {
    bool? env = bool.fromEnvironment(name, defaultValue: defaultValue);
    return env;
  }

  return defaultValue;
}

/// Fetches the logger instance.
Logger get logger {
  if (_logger != null) {
    return _logger!;
  }

  hierarchicalLoggingEnabled = true;
  _logger = Logger('DSA');

  _logger?.onRecord.listen((record) {
    var lines = record.message.split('\n');
    var inlineErrors =
        _getLogSetting(record, 'dsa.logger.inline_errors', true);

    var enableSequenceNumbers =
        _getLogSetting(record, 'dsa.logger.sequence', false);

    if (inlineErrors) {
      if (record.error != null) {
        lines.addAll(record.error.toString().split('\n'));
      }

      if (record.stackTrace != null) {
        lines.addAll(record.stackTrace
            .toString()
            .split('\n')
            .where((x) => x.isNotEmpty)
            .toList());
      }
    }

    String? rname = record.loggerName;

    if (record.zone?['dsa.logger.name'] is String) {
      rname = record.zone?['dsa.logger.name'];
    }

    var showTimestamps =
        _getLogSetting(record, 'dsa.logger.show_timestamps', false);

    if (!_getLogSetting(record, 'dsa.logger.show_name', true)) {
      rname = null;
    }

    for (var line in lines) {
      var msg = '';

      if (enableSequenceNumbers) {
        msg += '[${record.sequenceNumber}]';
      }

      if (showTimestamps) {
        msg += '[${record.time}]';
      }

      msg += '[${record.level.name}]';

      if (rname != null) {
        msg += '[${rname}]';
      }

      msg += ' ';
      msg += line;

      if (_getLogSetting(record, 'dsa.logger.print', true)) {
        print(msg);
      }
    }

    if (!inlineErrors) {
      if (record.error != null) {
        print(record.error);
      }

      if (record.stackTrace != null) {
        print(record.stackTrace);
      }
    }
  });

  updateLogLevel(const String.fromEnvironment('dsa.logger.default_level',
      defaultValue: 'INFO'));

  return _logger!;
}

/// Updates the log level to the level specified [name].
void updateLogLevel(String name) {
  name = name.trim().toUpperCase();

  if (name == 'DEBUG') {
    name = 'ALL';
  }

  var levels = <String, Level>{};
  for (var l in Level.LEVELS) {
    levels[l.name] = l;
  }

  var l = levels[name];

  if (l != null) {
    logger.level = l;
  }
}

class Interval {
  static final Interval ONE_MILLISECOND = Interval.forMilliseconds(1);
  static final Interval TWO_MILLISECONDS = Interval.forMilliseconds(2);
  static final Interval FOUR_MILLISECONDS = Interval.forMilliseconds(4);
  static final Interval EIGHT_MILLISECONDS = Interval.forMilliseconds(8);
  static final Interval SIXTEEN_MILLISECONDS = Interval.forMilliseconds(16);
  static final Interval THIRTY_MILLISECONDS = Interval.forMilliseconds(30);
  static final Interval FIFTY_MILLISECONDS = Interval.forMilliseconds(50);
  static final Interval ONE_HUNDRED_MILLISECONDS =
      Interval.forMilliseconds(100);
  static final Interval TWO_HUNDRED_MILLISECONDS =
      Interval.forMilliseconds(200);
  static final Interval THREE_HUNDRED_MILLISECONDS =
      Interval.forMilliseconds(300);
  static final Interval QUARTER_SECOND = Interval.forMilliseconds(250);
  static final Interval HALF_SECOND = Interval.forMilliseconds(500);
  static final Interval ONE_SECOND = Interval.forSeconds(1);
  static final Interval TWO_SECONDS = Interval.forSeconds(2);
  static final Interval THREE_SECONDS = Interval.forSeconds(3);
  static final Interval FOUR_SECONDS = Interval.forSeconds(4);
  static final Interval FIVE_SECONDS = Interval.forSeconds(5);
  static final Interval ONE_MINUTE = Interval.forMinutes(1);

  final Duration duration;

  const Interval(this.duration);

  Interval.forMilliseconds(int ms) : this(Duration(milliseconds: ms));
  Interval.forSeconds(int seconds) : this(Duration(seconds: seconds));
  Interval.forMinutes(int minutes) : this(Duration(minutes: minutes));
  Interval.forHours(int hours) : this(Duration(hours: hours));

  int get inMilliseconds => duration.inMilliseconds;
}

abstract class Disposable {
  void dispose();
}

class FunctionDisposable extends Disposable {
  final ExecutableFunction? function;

  FunctionDisposable(this.function);

  @override
  void dispose() {
    if (function != null) {
      function!();
    }
  }
}

/// Schedule Tasks
class Scheduler {
  static Timer get currentTimer => Zone.current['dslink.scheduler.timer'];

  static void cancelCurrentTimer() {
    currentTimer.cancel();
  }

  static Timer every(dynamic interval, Function() action) {
    Duration duration;

    if (interval is Duration) {
      duration = interval;
    } else if (interval is int) {
      duration = Duration(milliseconds: interval);
    } else if (interval is Interval) {
      duration = interval.duration;
    } else {
      throw Exception('Invalid Interval: $interval');
    }

    return Timer.periodic(duration, (Timer timer) async {
      runZoned<void>(action, zoneValues: {'dslink.scheduler.timer': timer});
    });
  }

  static Disposable safeEvery(dynamic interval, Function() action) {
    Duration duration;

    if (interval is Duration) {
      duration = interval;
    } else if (interval is int) {
      duration = Duration(milliseconds: interval);
    } else if (interval is Interval) {
      duration = interval.duration;
    } else {
      throw Exception('Invalid Interval: $interval');
    }

    ExecutableFunction? schedule;
    Timer? timer;
    var disposed = false;
    schedule = () async {
      await action();
      if (!disposed) {
        Timer(duration, schedule!);
      }
    };

    timer = Timer(duration, schedule);

    return FunctionDisposable(() {
      if (timer != null) {
        timer.cancel();
      }
      disposed = true;
    });
  }

  static Future repeat(int times, Function() action) async {
    for (var i = 1; i <= times; i++) {
      await action();
    }
  }

  static Future tick(int times, Interval interval, Function() action) async {
    for (var i = 1; i <= times; i++) {
      await Future<void>.delayed(
          Duration(milliseconds: interval.inMilliseconds));
      await action();
    }
  }

  static void runLater(Function() action) {
    Timer.run(action);
  }

  static Future later(Function() action) {
    return Future<void>(action);
  }

  static Future<void> after(Duration duration, Function() action) {
    return Future<void>.delayed(duration, action);
  }

  static Timer runAfter(Duration duration, Function() action) {
    return Timer(duration, action);
  }
}

String buildEnumType(Iterable<String> values) => "enum[${values.join(",")}]";

List<String> parseEnumType(String type) {
  if (!type.startsWith('enum[') || !type.endsWith(']')) {
    throw FormatException('Invalid Enum Type');
  }
  return type
      .substring(4, type.length - 1)
      .split(',')
      .map((it) => it.trim())
      .toList();
}

List<Map> buildActionIO(Map<String, String> types) {
  return types.keys.map((it) => {'name': it, 'type': types[it]}).toList();
}

String generateBasicId({int length = 30}) {
  var r0 = Random();
  var buffer = StringBuffer();
  for (var i = 1; i <= length; i++) {
    var r = Random(
        r0.nextInt(0x70000000) + (DateTime.now()).millisecondsSinceEpoch);
    var n = r.nextInt(50);
    if (n >= 0 && n <= 32) {
      var letter = alphabet[r.nextInt(alphabet.length)];
      buffer.write(r.nextBool() ? letter.toLowerCase() : letter);
    } else if (n > 32 && n <= 43) {
      buffer.write(numbers[r.nextInt(numbers.length)]);
    } else if (n > 43) {
      buffer.write(specials[r.nextInt(specials.length)]);
    }
  }
  return buffer.toString();
}

String generateToken({int length = 50}) {
  var r0 = Random();
  var buffer = StringBuffer();
  for (var i = 1; i <= length; i++) {
    var r = Random(
        r0.nextInt(0x70000000) + (DateTime.now()).millisecondsSinceEpoch);
    if (r.nextBool()) {
      var letter = alphabet[r.nextInt(alphabet.length)];
      buffer.write(r.nextBool() ? letter.toLowerCase() : letter);
    } else {
      buffer.write(numbers[r.nextInt(numbers.length)]);
    }
  }
  return buffer.toString();
}

const List<String> alphabet = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z'
];

const List<int> numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

const List<String> specials = ['@', '=', '_', '+', '-', '!', '.'];

Uint8List toUTF8(String str) {
  var length = str.length;
  var bytes = Uint8List(length);
  for (var i = 0; i < length; i++) {
    var unit = str.codeUnitAt(i);
    if (unit >= 128) {
      return Uint8List.fromList(const Utf8Encoder().convert(str));
    }
    bytes[i] = unit;
  }
  return bytes;
}
