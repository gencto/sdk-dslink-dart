import 'dart:html';
import 'package:dslink/src/crypto/pk.dart';
import 'package:dslink/browser_client.dart';
import 'package:dslink/responder.dart';
import 'package:dslink/common.dart';

// load private ECDH key
// this can be replaced with other authentication method if it's implemented in broker
PrivateKey key = PrivateKey.loadFromString(
  'J7wbaV2z-HDVDau2WrOf6goPgbZnj0xamPid1MNOuVc BC7EZK44i85VUr5LleLsLP-Bu6MkK2IbZWVHXBaUQlRKmfkT_488BW-KwOgoize4gaRVF1i0NarPeLgCXM6pGrE');

late SimpleNodeProvider nodeProvider;

class OpenLockerAction extends SimpleNode {
  OpenLockerAction(String path) : super(path);

  @override
  Object onInvoke(Map params) {
    nodeProvider.updateValue('${path}ed', true);
    return {'value':'a'};
  }
}

class ChangeLocker extends SimpleNode {
  ChangeLocker(String path) : super(path);

  @override
  Object onInvoke(Map params) {
    if (params['value'] is bool) {
      nodeProvider.updateValue('${path}ed', params['value']);
    }
    return {'value':'a'};
  }
}

void main() {
  var profiles = <String, NodeFactory>{
    'openLocker':(String path) {
      return OpenLockerAction(path);
    },
    'changeLocker':(String path) {
      return ChangeLocker(path);
    },
  };

  nodeProvider = SimpleNodeProvider(<String, dynamic>{
    'locker1': {
      r'$is':'locker',
      'open': { // an action to open the door
        r'$invokable': 'read',
        r'$function': 'openLocker'
      },
      'opened': { // the open status value
        r'$type': 'bool',
        '?value': false
      }
    },
    'locker2': {
      r'$is':'locker',
      'open': { // an action to open the door
        r'$invokable': 'read',
        r'$params':[{'name':'value', 'type':'bool'}],
        r'$function': 'changeLocker'
      },
      'opened': { // the open status value
        r'$type': 'bool',
        '?value': false
      }
    }
  }, profiles);

  // add locker at runtime
  nodeProvider.addNode('/locker3', <String, dynamic>{
    r'$is':'locker',
    'open': { // an action to open the door
      r'$invokable': 'read',
      r'$params':[{'name':'value', 'type':'bool'}],
      r'$function': 'openLocker'
    },
    'opened': { // the open status value
      r'$type': 'bool',
      '?value': false
    }
  });

  BrowserECDHLink(
    'http://localhost:8080/conn', 'locker-', key, isResponder: true,
    nodeProvider: nodeProvider)
    .connect();

  initUI();
}

void initUI() {
  // update label
  nodeProvider.getNode('/locker1/opened')?.subscribe((ValueUpdate update) {
    document
      .querySelector('#opentext1')
      ?.text = update.value == true ? 'Opened' : 'Closed';
  });
  nodeProvider.getNode('/locker2/opened')?.subscribe((ValueUpdate update) {
    document
      .querySelector('#opentext2')
      ?.text = update.value == true ? 'Opened' : 'Closed';
  });
  // buttons
  document
    .querySelector('#openbtn1')
    ?.onClick
    .listen((e) => nodeProvider.updateValue('/locker1/opened', true));
  document
    .querySelector('#closebtn1')
    ?.onClick
    .listen((e) => nodeProvider.updateValue('/locker1/opened', false));
  document
    .querySelector('#openbtn2')
    ?.onClick
    .listen((e) => nodeProvider.updateValue('/locker2/opened', true));
  document
    .querySelector('#closebtn2')
    ?.onClick
    .listen((e) => nodeProvider.updateValue('/locker2/opened', false));
}