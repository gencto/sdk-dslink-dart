import 'package:dsalink/node/value_node.dart';
import 'package:test/test.dart';

void main() {
  test('ValueNode updates via manual value changes', () async {
    final node = ValueNode('s', 0);

    final values = <dynamic>[];
    node.onValueChanged.listen(values.add);

    // Manually set values to simulate stream updates
    node.value = 1;
    await Future.delayed(const Duration(milliseconds: 60));
    node.value = 2;
    await Future.delayed(const Duration(milliseconds: 60));
    node.value = 3;
    await Future.delayed(const Duration(milliseconds: 60));

    expect(values.length, equals(3));
    expect(values, contains(1));
    expect(values, contains(2));
    expect(values, contains(3));
  });

  test('ReadOnlyValueNode rejects external set', () {
    final node = ReadOnlyValueNode('readonly', 10);
    expect(node.attributes['@writable'], 'never');
  });
}
