import 'package:dslink/client.dart';
import 'package:dslink/responder.dart';
import 'dart:async';
import 'dart:math';

late SimpleNodeProvider nodeProvider;

class OpenLockerAction extends SimpleNode {
  OpenLockerAction(String path) : super(path);

  @override
  Object onInvoke(Map params) {
    nodeProvider.updateValue('${path}ed', true);
    return {'value': 'a'};
  }
}

class ChangeLocker extends SimpleNode {
  ChangeLocker(String path) : super(path);

  @override
  Object onInvoke(Map params) {
    if (params['value'] is bool) {
      nodeProvider.updateValue('${path}ed', params['value']);
    }
    return {'value': 'a'};
  }
}

void main() {
  var key = PrivateKey.loadFromString(
      't5YRKgaZyhXNNberpciIoYzz3S1isttspwc4QQhiaVk BJ403K-ND1Eau8UJA7stsYI2hdgiOKhNVDItwg7sS6MfG2iSRGqM2UodSF0mb8GbD8s2OAukQ03DFLULw72bklo');

  var profiles = <String, NodeFactory>{
    'openLocker': (String path) {
      return OpenLockerAction(path);
    },
    'changeLocker': (String path) {
      return ChangeLocker(path);
    },
  };

  nodeProvider = SimpleNodeProvider(<String, dynamic>{
    'locker1': {
      r'$is': 'locker',
      'open': {
        // an action to open the door
        r'$invokable': 'read',
        r'$is': 'openLocker'
      },
      'opened': {
        // the open status value
        r'$type': 'bool',
        '?value': false
      }
    },
    'locker2': {
      r'$is': 'locker',
      'open': {
        // an action to open the door
        r'$invokable': 'read',
        r'$params': [
          {'name': 'value', 'type': 'bool', 'default': true}
        ],
        r'$is': 'changeLocker'
      },
      'opened': {
        // the open status value
        r'$type': 'bool',
        '?value': false
      },
      'test': {
        // the open status value
        r'$type': 'map',
        '?value': {
          'a': 'hello',
          'b': [1, 2, 3],
          'c': {'d': 'hi', 'e': 3}
        }
      }
    }
  }, profiles);

  var rng = Random();
  HttpClientLink('https://dsa.gencto.uk/conn', 'locker-', key,
          isResponder: true, nodeProvider: nodeProvider)
      .connect();
  Timer.periodic(Duration(seconds: 2), (v) {
    nodeProvider.updateValue('/locker2/test', {
      'a': 'hello',
      'b': [1, 2, 3],
      'c': {'d': 'hi', 'e': rng.nextInt(500)}
    });
  });
}
