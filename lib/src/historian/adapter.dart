part of dsalink.historian;

abstract class HistorianAdapter {
  Future<HistorianDatabaseAdapter> getDatabase(Map config);

  List<Map> getCreateDatabaseParameters();
}

abstract class HistorianDatabaseAdapter {
  Future<HistorySummary> getSummary(String? group, String path);
  Future store(List<ValueEntry> entries);
  Stream<ValuePair> fetchHistory(String group, String path, TimeRange range);
  Future purgePath(String group, String path, TimeRange range);
  Future purgeGroup(String group, TimeRange range);

  Future close();

  void addWatchPathExtensions(WatchPathNode node) {}
  void addWatchGroupExtensions(WatchGroupNode node) {}
}
