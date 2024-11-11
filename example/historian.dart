import 'package:dslink/historian.dart';

void main(List<String> args) {
  historianMain(['--broker', 'https://localhost:443/conn', '--log', 'debug'],
      'history', HA());
}

class HA extends HistorianAdapter {
  @override
  List<Map> getCreateDatabaseParameters() {
    return [];
  }

  @override
  Future<HistorianDatabaseAdapter> getDatabase(Map config) {
    return Future.delayed(Duration(seconds: 1), () => Postgres());
  }
}

class Postgres extends HistorianDatabaseAdapter {
  @override
  Future close() {
    return 'close connection' as dynamic;
  }

  @override
  Stream<ValuePair> fetchHistory(String group, String path, TimeRange range) {
    return Stream.periodic(Duration(seconds: 1),
        (count) => ValuePair('2020-02-02T01:01:0$count', count)).take(5);
  }

  @override
  Future<HistorySummary> getSummary(String? group, String path) {
    return Future.delayed(
        Duration(seconds: 1),
        () => HistorySummary(first: ValuePair('2020-02-02T01:01:02', 2),
            last: ValuePair('2020-02-02T01:01:01', 1)));
  }

  @override
  Future purgeGroup(String group, TimeRange range) {
    return Future.delayed(Duration(seconds: 1));
  }

  @override
  Future purgePath(String group, String path, TimeRange range) {
    return Future.delayed(Duration(seconds: 1));
  }

  @override
  Future store(List<ValueEntry> entries) {
    return Future.delayed(Duration(seconds: 1));
  }
}
