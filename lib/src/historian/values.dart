part of dsalink.historian;

class HistorySummary {
  final ValuePair? first;
  final ValuePair? last;

  HistorySummary({this.first, this.last});
}

class ValuePair {
  final String timestamp;
  final dynamic value;

  DateTime get time => DateTime.parse(timestamp);

  ValuePair(this.timestamp, this.value);

  List toRow() {
    return <dynamic>[timestamp, value];
  }
}

class TimeRange {
  final DateTime start;
  final DateTime? end;

  TimeRange(this.start, this.end);

  Duration get duration => end!.difference(start);

  bool isWithin(DateTime time) {
    var valid = (time.isAfter(start) || time.isAtSameMomentAs(start));
    if (end != null) {
      valid = valid && (time.isBefore(end!) || time.isAtSameMomentAs(end!));
    }
    return valid;
  }
}

class ValueEntry {
  final String group;
  final String path;
  final String timestamp;
  final dynamic value;

  ValueEntry(this.group, this.path, this.timestamp, this.value);

  ValuePair asPair() {
    return ValuePair(timestamp, value);
  }

  DateTime get time => DateTime.parse(timestamp);
}

TimeRange? parseTimeRange(String? input) {
  TimeRange? tr;
  if (input != null) {
    var l = input.split('/');
    var start = DateTime.parse(l[0]);
    var end = DateTime.parse(l[1]);

    tr = TimeRange(start, end);
  }
  return tr;
}
