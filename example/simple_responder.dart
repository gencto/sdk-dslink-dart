import 'dart:async';

import 'package:dsalink/dsalink.dart';

main(List<String> args) async {
  var link = LinkProvider(
    ['--broker', 'http://127.0.0.1:8080/conn'],
    'Example-',
    profiles: {TesterNode.isType: (String path) => TesterNode(path)},
  );

  link.addNode('/Test_node', TesterNode.def());

  link.init();
  updates(ValueUpdate update) {
    link.updateValue('/MyNum', update.value);
    link.saveAsync();
  }

  link.connect();
  link.updateValue('/MyNum', 'test2');
  var requester = await link.onRequesterReady;
  requester.subscribe('/sys/dataInPerSecond', (update) => updates(update));
}

class TesterNode extends SimpleNode {
  static const String isType = 'testerNode';
  static const String pathName = 'Test_Node';

  static Map def() => NodeBuilder.action()
      .profile(isType)
      .name('Test Node')
      .invokable('write')
      .param('test', 'bool')
      .build();

  TesterNode(String path) : super(path);

  @override
  Future<Map> onInvoke(Map params) async {
    throw Exception("That's broken");
  }
}
