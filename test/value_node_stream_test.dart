import 'package:dsalink/node/value_node.dart';
import 'package:test/test.dart';

void main() {
  test('streamed ValueNode updates via stream', () async {
    final stream = Stream.fromIterable([1, 2, 3]);
    final node = ValueNode.streamed('s', stream);

    final values = <dynamic>[];
    node.onValueChanged.listen(values.add);

    await Future.delayed(const Duration(milliseconds: 100));

    expect(values, equals([1, 2, 3]));
  });

  test('ReadOnlyValueNode rejects external set', () {
    final node = ReadOnlyValueNode('readonly', 10);
    expect(node.attributes['@writable'], 'never');
  });
}
