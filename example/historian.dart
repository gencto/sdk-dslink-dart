import 'dart:async';

import 'package:dsalink/historian.dart';
import 'package:influxdb_client/api.dart';

void main(List<String> args) {
  historianMain(
    ['--broker', 'https://127.0.0.1/conn', '--log', 'debug'],
    'history',
    HA(),
  );
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
            'TRDX3sB8K3MW3iyZGz6qdIsV_ZfbLfafFX3q-BIIqPj-BeVPPu5PVLMgNNFceJxEoDfAmqtRqnzg72VRZ2mQLg==',
      },
      {'name': 'org', 'type': 'string', 'default': 'mydb'},
      {'name': 'bucket', 'type': 'string', 'default': 'mydb'},
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
    client = InfluxDBClient(url: url, token: token, org: org, bucket: bucket);
    writeService = client.getWriteService();
    queryService = client.getQueryService();
  }

  late final InfluxDBClient client;
  late final WriteService writeService;
  late final QueryService queryService;

  void onCreated() {
    client = InfluxDBClient(url: url, token: token, org: org, bucket: bucket);
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
    String group,
    String path,
    TimeRange range,
  ) async* {
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
  Future<HistorySummary> getSummary(String? group, String path) {
    return Future.delayed(
      Duration(seconds: 1),
      () => HistorySummary(
        first: ValuePair('2020-02-02T01:01:02', 2),
        last: ValuePair('2020-02-02T01:01:01', 1),
      ),
    );
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
      var points =
          entries.map((entry) {
            return Point('dglux')
                .addTag('sys', 'perseq')
                .addField(entry.path, int.parse(entry.value))
                .time(DateTime.now().toUtc());
          }).toList();

      await writeService.write(points);
    }
  }
}
