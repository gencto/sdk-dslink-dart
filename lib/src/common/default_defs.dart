part of dsalink.common;

Map defaultProfileMap = <String, dynamic>{
  'node': <String, dynamic>{},
  'static': <String, dynamic>{},
  'getHistory': <String, dynamic>{
    // Add explicit type here
    r'$invokable': 'read',
    r'$result': 'table',
    r'$params': [
      {'name': 'Timerange', 'type': 'string', 'editor': 'daterange'},
      {
        'name': 'Interval',
        'type': 'enum',
        'editor': BuildEnumType([
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
          '1S',
        ]),
      },
      {
        'name': 'Rollup',
        'type': BuildEnumType([
          'avg',
          'min',
          'max',
          'sum',
          'first',
          'last',
          'and',
          'or',
          'count',
          'auto',
        ]),
      },
    ],
    r'$columns': [
      {'name': 'timestamp', 'type': 'time'},
      {'name': 'value', 'type': 'dynamic'},
    ],
  },
};
