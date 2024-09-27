import 'dart:async';
import 'package:influxdb_client/api.dart';
import 'package:dslink/historian.dart';

late InfluxDBClient client;
late WriteService writeApi;
late QueryService queryService;

void main(List<String> args) async {
  historianMain(['--broker', 'http://localhost:80/conn', '--log', 'debug'],
      'history', HA());
}

class HA extends HistorianAdapter {
  @override
  List<Map> getCreateDatabaseParameters() {
    return [
      {'name': 'url', 'type': 'string', 'default': 'http://localhost:8086'},
      {
        'name': 'token',
        'type': 'string',
        'default':
            'TRDX3sB8K3MW3iyZGz6qdIsV_ZfbLfafFX3q-BIIqPj-BeVPPu5PVLMgNNFceJxEoDfAmqtRqnzg72VRZ2mQLg=='
      },
      {'name': 'org', 'type': 'string', 'default': 'mydb'},
      {'name': 'bucket', 'type': 'string', 'default': 'mydb'}
    ];
  }

  @override
  Future<HistorianDatabaseAdapter> getDatabase(Map config) {
    return Future.value(
      InfluxDBAdapter(
        url: config['url'] as String,
        token: config['token'] as String,
        org: config['org'] as String,
        bucket: config['bucket'] as String,
      ),
    );
  }
}

class InfluxDBAdapter extends HistorianDatabaseAdapter {
  final String url;
  final String token;
  final String org;
  final String bucket;

  InfluxDBAdapter({
    required this.url,
    required this.token,
    required this.org,
    required this.bucket,
  }) {
    client = InfluxDBClient(
      url: url,
      token: token,
      org: org,
      bucket: bucket,
    );
    writeService = client.getWriteService();
    queryService = client.getQueryService();
  }

  late final InfluxDBClient client;
  late final WriteService writeService;
  late final QueryService queryService;

  void onCreated() {
    client = InfluxDBClient(
      url: url,
      token: token,
      org: org,
      bucket: bucket,
    );
    writeService = client.getWriteService();
    queryService = client.getQueryService();
  }

  @override
  Future close() async {
    client.close();
    return 'closed connection';
  }

  @override
  Stream<ValuePair> fetchHistory(
      String group, String path, TimeRange range) async* {
    var query = '''
from(bucket: "mydb")
    |> range(start: 2024-09-22T21:00:00.000Z, stop: 2024-09-23T20:59:59.999Z)
  |> filter(fn: (r) => r["_measurement"] == "dglux")
  |> filter(fn: (r) => r["_field"] == "/sys/dataOutPerSecond")
  |> filter(fn: (r) => r["sys"] == "perseq")
    ''';

    var result = await queryService.query(query);
    await for (var record in result) {
      yield ValuePair(record['_time'], record['_value']);
    }
  }

  @override
  Future<HistorySummary> getSummary(String? group, String path) async {
    var query = '''
from(bucket: "mydb")
    |> range(start: 2024-09-22T21:00:00.000Z, stop: 2024-09-23T20:59:59.999Z)
  |> filter(fn: (r) => r["_measurement"] == "dglux")
  |> filter(fn: (r) => r["_field"] == "/sys/dataOutPerSecond")
  |> filter(fn: (r) => r["sys"] == "perseq")
    ''';

    var result = await queryService.query(query);
    List<ValuePair?> arr = [];
    var res = HistorySummary(null, null);
    result.listen(
      (data) {
        arr.add(ValuePair(data['_time'], data['_value']));
      },
      onError: (error) {
        Error();
      },
      onDone: () {
        if (arr.isNotEmpty)
          res = HistorySummary(
            arr.first,
            arr.last,
          );
      },
    );
    return res;
  }

  @override
  Future purgeGroup(String group, TimeRange range) async {
    // InfluxDB does not have a direct delete feature like SQL
    return Future.delayed(Duration(seconds: 1));
  }

  @override
  Future purgePath(String group, String path, TimeRange range) async {
    // InfluxDB does not have a direct delete feature like SQL
    return Future.delayed(Duration(seconds: 1));
  }

  @override
  Future store(List<ValueEntry> entries) async {
    if (entries.isNotEmpty) {
      var points = entries.map((entry) {
        return Point('dglux')
            .addTag('sys', 'perseq')
            .addField(entry.path, int.parse(entry.value))
            .time(DateTime.now().toUtc());
      }).toList();

      await writeService.write(points);
    }
  }
}
