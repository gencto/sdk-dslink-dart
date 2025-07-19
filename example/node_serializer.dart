import 'dart:convert';

import 'package:dsalink/node/node_serializer.dart';
import 'package:dsalink/utils/json_config_loader.dart';

Future<void> main() async {
  const rawJson = '''
  {
    "name": "root",
    "children": [
      {
        "name": "temperature",
        "value": 21.5,
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

  final map = jsonDecode(rawJson) as Map<String, dynamic>;
  final root = NodeSerializer.fromJson(map);

  final jsonOut = jsonEncode(root.toJson());
  print('🧾 Exported JSON:\n$jsonOut');

  final config = await JsonConfigLoader.loadFromFile(
    './example/link_tree.json',
  );

  final root2 = NodeSerializer.fromJson(config);
  print('🌲 Tree loaded from file');

  final jsonOut2 = root2.toJson();
  await JsonConfigLoader.saveToFile('./example/output_tree.json', jsonOut2);
  print('💾 Tree exported to output_tree.json');
}
