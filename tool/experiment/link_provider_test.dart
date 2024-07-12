import 'package:dslink/dslink.dart';
import 'package:dslink/utils.dart' show ByteDataUtil, DsTimer;

import 'dart:async';
import 'dart:math' as Math;

late LinkProvider link;
int lastNum = 0;
late SimpleNode addNode;
late SimpleNode rootNode;

class AddNodeAction extends SimpleNode {
  AddNodeAction(String path) : super(path);

  @override
  Object onInvoke(Map params) {
    addNode.configs[r'$lastNum'] = ++lastNum;

    var nodeName = '/node%2F_$lastNum';
    link.addNode(nodeName, <String, dynamic>{
      r'$type': 'bool[disable,enable]',
      r'$is': 'rng',
      '@unit': 'hit',
      '?value': '123.456', //ByteDataUtil.fromList([1,2,3,1,2,3]),
      'remove': {
        // an action to delete the node
        r'$is': 'removeSelfAction',
        r'$invokable': 'write',
      },
      r'$writable': 'write',
      r'$placeholder': 'abcc',
    });
    link.save(); // save json

    var tableRslt = AsyncTableResult();
    void closed(InvokeResponse resp) {
      print('closed');
    }

    var tcount = 0;
    tableRslt.onClose = closed;
    tableRslt.columns = <List<Map<String, String>>>[
      <Map<String, String>>[
        {'name': 'a'}
      ]
    ];
    Timer.periodic(Duration(milliseconds: 50), (Timer t) {
      if (tcount++ > 5) {
        tableRslt.close();
        t.cancel();
        return;
      }
      tableRslt.update(
          <List<int>>[
            [1],
            [2]
          ],
          StreamStatus.initialize,
          <String, dynamic>{'a': 'abc'});
    });
    return tableRslt; //new SimpleTableResult([['0'], ['1']], [{"name":"name"}]);
  }
}

class RemoveSelfAction extends SimpleNode {
  RemoveSelfAction(String path) : super(path);

  @override
  Object? onInvoke(Map params) {
    List p = path!.split('/')..removeLast();
    var parentPath = p.join('/');
    link.removeNode(parentPath);
    link.save();
    return null;
  }
}

class RngNode extends SimpleNode {
  RngNode(String path) : super(path);

  static Math.Random rng = Math.Random();

  @override
  void onCreated() {
    //updateValue(rng.nextDouble());
  }

  void updateRng() {
    if (!removed) {
      updateValue(ByteDataUtil.fromList([1, 2, 3, 1, 2, 3]));
      DsTimer.timerOnceAfter(updateRng, 1000);
    }
  }
}

void main() {
  var defaultNodes = <String, dynamic>{
    'defs': {
      'profile': {
        'addNodeAction': {
          r'$params': {
            'name': {
              'type': 'string',
              'placeholder': 'ccc',
              'description': 'abcd',
              'default': 123
            },
            'source': {'type': 'string', 'editor': 'password'},
            'destination': {'type': 'string'},
            'queueSize': {'type': 'string'},
            'pem': {'type': 'string'},
            'filePrefix': {'type': 'bool[disable,enable]'},
            'copyToPath': {'type': 'enum[a,b,c]'}
          },
          //r'$columns':[{'name':'name','type':'string'}],
          r'$lastNum': 0,
          r'$result': 'stream'
        }
      }
    },
    'add': {
      r'$is': 'addNodeAction',
      r'$invokable': 'write',
    }
  };

  var profiles = <String, NodeFactory>{
    'addNodeAction': (String path) {
      return AddNodeAction(path);
    },
    'removeSelfAction': (String path) {
      return RemoveSelfAction(path);
    },
    'rng': (String path) {
      return RngNode(path);
    }
  };

  link = LinkProvider(
      ['-b', 'dev.gencto.uk/conn', '--log', 'finest'], 'rick-resp-',
      defaultNodes: defaultNodes,
      profiles: profiles /*, home:'dgSuper'*/,
      linkData: <String, dynamic>{'a': 1});
  if (link.link == null) {
    // initialization failed
    return;
  }

  addNode = link.getNode('/add') as SimpleNode;
  rootNode = link.getNode('/') as SimpleNode;
  lastNum = (addNode.configs[r'$lastNum'] ?? 0) as int;

  var node = link.provider?.getOrCreateNode('/testpoint');
  node?.load(<String, dynamic>{r'$type': 'number', '?value': 1});

  link.connect();
}
