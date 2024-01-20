library dslink.test.sampleresponder;

import 'package:dslink/responder.dart';
import 'package:dslink/common.dart';
import 'dart:async';

class TestNodeProvider extends NodeProvider {
  late TestNode onlyNode;

  TestNodeProvider() {
    onlyNode = new TestNode('/', this);
  }

  LocalNode? getNode(String? path) {
    return onlyNode;
  }

  IPermissionManager permissions = new DummyPermissionManager();

  Responder createResponder(String? dsId, String sessionId) {
    return new Responder(this, dsId);
  }

  LocalNode getOrCreateNode(String path, [bool addToTree = true]) {
    return onlyNode;
  }
}

class TestNode extends LocalNodeImpl {
  NodeProvider provider;

  TestNode(String path, this.provider) : super(path) {
    new Timer.periodic(const Duration(seconds: 5), updateTime);
    configs[r'$is'] = 'node';
    configs[r'$test'] = 'hello world';
  }

  int count = 0;

  void updateTime(Timer t) {
    updateValue(count++);
  }

  bool get exists => true;

  @override
  InvokeResponse invoke(Map params,
    Responder responder,
    InvokeResponse response,
    Node parentNode,
    [int maxPermission = Permission.CONFIG]) {
    response.updateStream(
      [[1, 2]], streamStatus: StreamStatus.closed, columns: [{
      'name': 'v1',
      'type': 'number'
    }, {
      'name': 'v2',
      'type': 'number'
    }
    ]);
    return response;
  }
}
