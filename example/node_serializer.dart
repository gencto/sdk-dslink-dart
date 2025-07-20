import 'dart:convert';

import 'package:dsalink/models/node_dto.dart';
import 'package:dsalink/node/node_serializer.dart';
import 'package:dsalink/utils/json_config_loader.dart';
import 'package:dsalink/utils/logger.dart';
import 'package:dsalink/utils/logging_config.dart';

Future<void> main() async {
  // Initialize logging for the example
  LoggingManager.configureForDevelopment();
  final logger = DsLogger.getLogger('NodeSerializerExample');
  
  logger.info('Starting node serializer example');
  
  try {
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

    final stopwatch = Stopwatch()..start();
    
    logger.info('Parsing JSON configuration');
    final map = jsonDecode(rawJson) as Map<String, dynamic>;
    final root = NodeSerializer.fromDTO(NodeDTO.fromJson(map));

    final jsonOut = jsonEncode(root.toJson());
    stopwatch.stop();
    
    DsLogger.logPerformance(
      'JSON parsing and serialization',
      stopwatch.elapsed,
      component: 'NodeSerializer',
      context: {
        'inputSize': rawJson.length,
        'outputSize': jsonOut.length,
        'childCount': (map['children'] as List?)?.length ?? 0,
      },
    );
    
    logger.info('Exported JSON (${jsonOut.length} characters):\n$jsonOut');

    logger.info('Loading tree configuration from file');
    final configStopwatch = Stopwatch()..start();
    
    final config = await JsonConfigLoader.loadFromFile(
      './example/link_tree.json',
    );

    final root2 = NodeSerializer.fromDTO(NodeDTO.fromJson(config));
    configStopwatch.stop();
    
    DsLogger.logPerformance(
      'File loading and tree creation',
      configStopwatch.elapsed,
      component: 'JsonConfigLoader',
      context: {
        'fileName': 'link_tree.json',
        'nodeCount': _countNodes(config),
      },
    );
    
    logger.info('Tree loaded from file successfully');

    logger.info('Exporting tree to output file');
    final exportStopwatch = Stopwatch()..start();
    
    final jsonOut2 = root2.toJson();
    await JsonConfigLoader.saveToFile('./example/output_tree.json', jsonOut2);
    
    exportStopwatch.stop();
    
    DsLogger.logPerformance(
      'Tree export to file',
      exportStopwatch.elapsed,
      component: 'JsonConfigLoader',
      context: {
        'fileName': 'output_tree.json',
        'dataSize': jsonEncode(jsonOut2).length,
      },
    );
    
    logger.info('Tree exported to output_tree.json successfully');
    logger.info('Node serializer example completed successfully');
    
  } catch (error, stackTrace) {
    DsLogger.logError(
      'Node serializer example failed',
      error,
      stackTrace: stackTrace,
      component: 'NodeSerializerExample',
    );
    
    logger.severe('Example failed. See error details above.');
    rethrow;
  }
}

/// Helper function to count nodes in a configuration
int _countNodes(Map<String, dynamic> config) {
  int count = 1; // Count the root
  final children = config['children'] as List<dynamic>?;
  if (children != null) {
    for (final child in children) {
      if (child is Map<String, dynamic>) {
        count += _countNodes(child);
      }
    }
  }
  return count;
}
