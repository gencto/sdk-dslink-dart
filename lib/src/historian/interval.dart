part of dslink.historian;

const Map<List<String>, int> _intervalTypes = {
  ['ms', 'millis', 'millisecond', 'milliseconds']: 1,
  ['s', 'second', 'seconds']: 1000,
  ['m', 'min', 'minute', 'minutes']: 60000,
  ['h', 'hr', 'hour', 'hours']: 3600000,
  ['d', 'day', 'days']: 86400000,
  ['wk', 'week', 'weeks']: 604800000,
  ['n', 'month', 'months']: 2628000000,
  ['year', 'years', 'y']: 31536000000
};

List<String>? __intervalAllTypes;

List<String>? get _intervalAllTypes {
  if (__intervalAllTypes == null) {
    __intervalAllTypes = _intervalTypes.keys.expand((key) => key).toList();
    __intervalAllTypes?.sort();
  }
  return __intervalAllTypes;
}

final RegExp _intervalPattern =
    RegExp("^(\\d*?.?\\d*?)(${_intervalAllTypes?.join('|')})\$");

int parseInterval(String? input) {
  if (input == null) {
    return 0;
  }

  /// Sanitize Input
  input = input.trim().toLowerCase().replaceAll(' ', '');

  if (input == 'none') {
    return 0;
  }

  if (input == 'default') {
    return 0;
  }

  if (!_intervalPattern.hasMatch(input)) {
    throw FormatException('Bad Interval Syntax: $input');
  }

  var match = _intervalPattern.firstMatch(input);
  var multiplier = num.parse(match![1]!);
  var typeName = match[2];
  var typeKey = _intervalTypes.keys.firstWhere((x) => x.contains(typeName));
  var type = _intervalTypes[typeKey];
  return (multiplier * type!).round();
}
