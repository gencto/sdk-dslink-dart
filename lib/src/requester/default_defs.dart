part of dsalink.requester;

// TODO: merge with defaultProfileMap in common lib
class DefaultDefNodes {
  static final Map<String, Map<String, Object>> _defaultDefs = {
    'node': {},
    'static': {},
    'getHistory': {
      r'$invokable': 'read',
      r'$result': 'table',
      r'$params': [
        {'name': 'Timerange', 'type': 'string', 'editor': 'daterange'},
        {
          'name': 'Interval',
          'type': 'enum',
          'default': 'none',
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
          'default': 'none',
          'type': BuildEnumType([
            'none',
            'avg',
            'min',
            'max',
            'sum',
            'first',
            'last',
            'count',
            'delta',
          ]),
        },
      ],
      r'$columns': [
        {'name': 'timestamp', 'type': 'time'},
        {'name': 'value', 'type': 'dynamic'},
      ],
    },
  };

  static final Map<String, Node> nameMap = () {
    var rslt = <String, Node>{};
    _defaultDefs.forEach((k, m) {
      var path = '/defs/profile/$k';
      var node = RemoteDefNode(path);
      m.forEach((String n, Object v) {
        if (n.startsWith(r'$')) {
          node.configs[n] = v;
        } else if (n.startsWith('@')) {
          node.attributes[n] = v;
        }
      });
      node.listed = true;
      rslt[k] = node;
    });
    return rslt;
  }();

  static final Map<String, Node> pathMap = () {
    var rslt = <String, Node>{};
    nameMap.forEach((k, node) {
      if (node is RemoteNode) {
        rslt[node.remotePath] = node;
      }
    });
    return rslt;
  }();
}
