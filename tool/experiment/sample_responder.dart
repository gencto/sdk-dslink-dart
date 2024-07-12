library dslink.test.sampleresponder;

import 'package:dslink/responder.dart';
import 'package:dslink/common.dart';
import 'dart:async';

class TestNodeProvider extends NodeProvider {
  late TestNode onlyNode;

  TestNodeProvider() {
    onlyNode = TestNode('/', this);
  }

  @override
  LocalNode? getNode(String? path) {
    return onlyNode;
  }

  @override
  IPermissionManager permissions = DummyPermissionManager();

  @override
  Responder createResponder(String? dsId, String sessionId) {
    return Responder(this, dsId);
  }

  @override
  LocalNode getOrCreateNode(String path, [bool addToTree = true]) {
    return onlyNode;
  }
}

class TestNode extends LocalNodeImpl {
  @override
  NodeProvider provider;

  TestNode(String path, this.provider) : super(path) {
    Timer.periodic(const Duration(seconds: 5), updateTime);
    configs[r'$is'] = 'node';
    configs[r'$test'] = 'hello world';
  }

  int count = 0;

  void updateTime(Timer t) {
    updateValue(count++);
  }

  @override
  bool get exists => true;

  @override
  InvokeResponse invoke(
      Map params, Responder responder, InvokeResponse response, Node parentNode,
      [int maxPermission = Permission.CONFIG]) {
    response.updateStream(
        <List<dynamic>>[
          <int>[1, 2]
        ],
        streamStatus: StreamStatus.closed,
        columns: <List<Map<String, String>>>[
          <Map<String, String>>[
            <String, String>{'name': 'v1', 'type': 'number'},
            <String, String>{'name': 'v2', 'type': 'number'}
          ]
        ]);

    return response;
  }
}
