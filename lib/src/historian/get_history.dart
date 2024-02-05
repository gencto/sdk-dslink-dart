part of dslink.historian;

class GetHistoryNode extends SimpleNode {
  GetHistoryNode(String path) : super(path, _link!.provider as SimpleNodeProvider?) {
    configs[r'$is'] = 'getHistory';
    configs[r'$name'] = 'Get History';
    configs[r'$invokable'] = 'read';
    configs[r'$params'] = [
      {
        'name': 'Timerange',
        'type': 'string',
        'editor': 'daterange'
      },
      {
        'name': 'Interval',
        'type': 'enum',
        'editor': buildEnumType([
          'default',
          'none',
          '1Y',
          '3N',
          '1N',
          '1W',
          '1D',
          '12H',
          '6H',
          '4H',
          '3H',
          '2H',
          '1H',
          '30M',
          '15M',
          '10M',
          '5M',
          '1M',
          '30S',
          '15S',
          '10S',
          '5S',
          '1S'
        ]),
        'default': 'default'
      },
      {
        'name': 'Rollup',
        'type': buildEnumType([
          'none',
          'avg',
          'min',
          'max',
          'sum',
          'first',
          'last',
          'count'
        ])
      },
      {
        'name': 'Real Time',
        'type': 'bool',
        'default': false
      },
      {
        'name': 'Batch Size',
        'type': 'number',
        'default': 0
      }
    ];

    configs[r'$columns'] = [
      {
        'name': 'timestamp',
        'type': 'time'
      },
      {
        'name': 'value',
        'type': 'dynamic'
      }
    ];

    configs[r'$result'] = 'stream';
  }

  @override
  FutureOr<void> onInvoke(Map params) async* {
    String range = params['Timerange'];
    String rollupName = params['Rollup'];
    var rollupFactory = _rollups[rollupName];
    var rollup = rollupFactory == null ? null : rollupFactory();
    var interval = Duration(
      milliseconds: parseInterval(params['Interval']));
    num? batchSize = params['Batch Size'];

    batchSize ??= 0;

    var batchCount = batchSize.toInt();

    var tr = parseTimeRange(range);
    if (params['Real Time'] == true) {
      tr = TimeRange(tr!.start, null);
    }

    try {
      var pairs = calculateHistory(
        tr!,
        interval,
        rollup!
      );

      if (params['Real Time'] == true) {
        await for (ValuePair pair in pairs) {
          yield [pair.toRow()];
        }
      } else {
        var count = 0;
        var buffer = <List<dynamic>>[];

        await for (ValuePair row in pairs) {
          count++;
          buffer.add(row.toRow());
          if (count != 0 && count == batchCount) {
            yield buffer;
            buffer = [];
            count = 0;
          }
        }

        if (buffer.isNotEmpty) {
          yield buffer;
          buffer.length = 0;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Stream<ValuePair> fetchHistoryData(TimeRange range) {
    var p = Path(path!);
    var mn = p.parent;
    var pn = _link![mn.path] as WatchPathNode;

    return pn.fetchHistory(range) as Stream<ValuePair>;
  }

  Stream<ValuePair> calculateHistory(TimeRange range,
    Duration interval,
    Rollup rollup) async* {
    if (interval.inMilliseconds <= 0) {
      yield* fetchHistoryData(range);
      return;
    }

    var lastTimestamp = -1;
    var totalTime = 0;

    ValuePair? result;

    await for (ValuePair pair in fetchHistoryData(range)) {
      rollup.add(pair.value);
      if (lastTimestamp != -1) {
        totalTime += pair.time.millisecondsSinceEpoch - lastTimestamp;
      }
      lastTimestamp = pair.time.millisecondsSinceEpoch;
      if (totalTime >= interval.inMilliseconds) {
        totalTime = 0;
        result = ValuePair(
          DateTime.fromMillisecondsSinceEpoch(
            lastTimestamp
          ).toIso8601String(),
          rollup.value
        );
        yield result;
        result = null;
        rollup.reset();
      }
    }

    if (result != null) {
      yield result;
    }
  }
}