import 'dart:async';
import 'dart:math';
import 'package:dslink/dslink.dart';

main(List<String> args) async {
  var link = LinkProvider(
      ['--broker', 'http://127.0.0.1:8080/conn'], 'Example-',
      profiles: {TesterNode.isType: (String path) => TesterNode(path)});

  var numGen = Random();
  var myNum = numGen.nextInt(50);

  var myNode = link.addNode('/MyNum', <String, dynamic>{
    r'$name': 'My Number',
    r'$type': 'num',
    r'?value': 'start',
  });

  link.addNode('/Test_node', TesterNode.def());

  link.init();
  updates(ValueUpdate update)  {
  link.updateValue('/MyNum', update.value);
  link.save();
}
  link.connect();
  link.updateValue('/MyNum', 'test2');
  var requester = await link.onRequesterReady;
  requester.subscribe(
      '/sys/dataInPerSecond', (update) => updates(update));
  

}

class TesterNode extends SimpleNode {
  static const String isType = 'testerNode';
  static const String pathName = 'Test_Node';

  static Map def() => <String, dynamic>{
        r'$is': isType,
        r'$name': 'Test Node',
        r'$invokable': 'write',
        r'$params': [
          {'name': 'test', 'type': 'bool'}
        ],
        r'$columns': <dynamic>[]
      };

  TesterNode(String path) : super(path);

  @override
  Future<Map> onInvoke(Map params) async {
    throw Exception("That's broken");
  }
}
