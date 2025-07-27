import 'package:dsalink/node/action_node.dart';
import 'package:dsalink/node/ds_node.dart';
import 'package:dsalink/node/node_builder.dart';
import 'package:dsalink/node/value_node.dart';
import 'package:test/test.dart';

void main() {
  test('Node tree creation', () {
    final root = DsNode('root');
    final child = ValueNode('temperature', 25.5);

    root.addChild(child);

    expect(root.getChild('temperature'), isNotNull);
    expect(root.getChild('temperature')?.value, equals(25.5));
  });

  test('Invoke action node', () async {
    final node = ActionNode('hello', (params) async => "Hello, ${params['name']}!");

    final result = await node.invoke({'name': 'World'});
    expect(result, 'Hello, World!');
  });

  test('NodeBuilder builds tree correctly', () {
    final tree = NodeBuilder('root')
        .addChild(NodeBuilder('status').withValue('OK').withType('string'))
        .addChild(NodeBuilder('run').onInvoke((_) async => 'running...'))
        .build();

    final status = tree.getChild('status');
    expect(status?.value, equals('OK'));
    expect(status?.attributes['@type'], equals('string'));

    final run = tree.getChild('run');
    expect(run?.hasAction, isTrue);
  });
}
