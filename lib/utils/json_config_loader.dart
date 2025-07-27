import 'dart:convert';

import 'package:universal_io/io.dart';

class JsonConfigLoader {
  JsonConfigLoader._();

  static Future<Map<String, dynamic>> loadFromFile(String path) async {
    final file = File(path);

    if (!file.existsSync()) {
      throw Exception('Config file not found: $path');
    }

    final content = await file.readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }

  static Future<void> saveToFile(String path, Map<String, dynamic> data) async {
    final file = File(path);
    await file.writeAsString(jsonEncode(data), flush: true);
  }
}
