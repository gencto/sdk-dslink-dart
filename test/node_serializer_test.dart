import 'dart:convert';

import 'package:dsalink/models/node_dto.dart';
import 'package:dsalink/node/node_serializer.dart';
import 'package:test/test.dart';

void main() {
  test('Serialize & deserialize full node tree', () {
    const jsonInput = '''
    {
      "name": "root",
      "children": [
        {
          "name": "temperature",
          "value": 22.5,
          "attributes": {
            "@type": "number",
            "@unit": "°C"
          }
        },
        {
          "name": "echo",
          "action": true
        }
      ]
    }
    ''';

    final dto = NodeDTO.fromJson(jsonDecode(jsonInput) as Map<String, dynamic>);

    final node = NodeSerializer.fromDTO(dto);

    final exportedDTO = NodeSerializer.toDTO(node);
    final jsonOut = jsonEncode(exportedDTO.toJson());

    print('🔄 Output JSON: $jsonOut');

    expect(exportedDTO.name, equals('root'));
    expect(exportedDTO.children?.length, 2);
    expect(exportedDTO.children?.first.name, equals('temperature'));
    expect(exportedDTO.children?.last.action, isTrue);
  });
}
