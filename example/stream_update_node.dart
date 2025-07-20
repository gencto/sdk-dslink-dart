import 'dart:async';

import 'package:dsalink/node/value_node.dart';
import 'package:dsalink/utils/logger.dart';
import 'package:dsalink/utils/logging_config.dart';
import 'package:logging/logging.dart';

void main() async {
  // Initialize logging system for the example
  LoggingManager.configureForDevelopment();
  
  final logger = DsLogger.getLogger('StreamUpdateExample');
  logger.info('🚀 Starting stream update node example');
  
  try {
    // Create CPU usage stream with logging
    final cpuStream = Stream.periodic(
      const Duration(seconds: 2),
      (i) {
        final value = (20 + i % 40).toDouble();
        DsLogger.logPerformance(
          'CPU monitoring cycle',
          Duration(milliseconds: 100), // Simulated monitoring time
          component: 'CPUMonitor',
          context: {'cycle': i, 'value': value},
        );
        return value;
      },
    );

    final cpuNode = ValueNode.streamed(
      'cpu_usage',
      cpuStream,
      initialValue: 20.0,
      attributes: {'@type': 'number', '@unit': '%'},
    );

    cpuNode.onValueChanged.listen((value) {
      logger.info('CPU Usage updated: $value%');
      
      // Log performance warnings for high CPU usage
      if (value > 80) {
        logger.warning('High CPU usage detected: $value%');
      }
    });

    // Temperature stream with enhanced logging
    logger.info('Creating temperature monitoring stream');
    
    final tempStream = Stream.periodic(
      const Duration(milliseconds: 200),
      (i) {
        logger.fine('Temperature reading cycle $i');
        return i;
      },
    ).take(10);

    // Create a debounce transformer with logging
    final debounced = StreamTransformer<int, int>.fromBind((stream) {
      Timer? timer;
      final controller = StreamController<int>();
      int lastValue = 0;

      stream.listen(
        (data) {
          logger.fine('Temperature data received: $data');
          timer?.cancel();
          timer = Timer(const Duration(seconds: 10), () {
            logger.info('Temperature value debounced: $data (was $lastValue)');
            controller.add(data);
            lastValue = data;
          });
        },
        onError: (error, stackTrace) {
          DsLogger.logError(
            'Error in temperature stream',
            error,
            stackTrace: stackTrace,
            component: 'TemperatureMonitor',
          );
        },
        onDone: () {
          logger.info('Temperature stream completed');
          controller.close();
        },
      );

      return controller.stream;
    });

    final tempNode = ValueNode.streamed(
      'temp',
      tempStream,
      transformer: debounced,
      attributes: {'@type': 'number'},
    );

    // Log node creation
    logger.info('Temperature node created: ${tempNode.logContext}');
    
    // Set up value change monitoring with context logging
    tempNode.onValueChanged.listen((value) {
      logger.info('Temperature updated to: $value');
    });

    // Simulate running for a while
    logger.info('Example running... Press Ctrl+C to stop');
    
    // Log system stats periodically
    Timer.periodic(Duration(seconds: 5), (timer) {
      logger.info('System stats - CPU Node: ${cpuNode.logContext}, Temp Node: ${tempNode.logContext}');
    });
    
  } catch (error, stackTrace) {
    DsLogger.logError(
      'Failed to initialize stream update example',
      error,
      stackTrace: stackTrace,
      component: 'StreamUpdateExample',
    );
    
    logger.severe('Example failed to start. Exiting.');
    rethrow;
  }
}
