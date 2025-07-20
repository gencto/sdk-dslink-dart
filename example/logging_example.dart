import 'dart:io';
import 'package:dsalink/utils/logger.dart';

/// Example demonstrating comprehensive logging practices in DSALink SDK
void main() async {
  print('=== DSALink Logger Examples ===\n');

  // Example 1: Basic logging with default configuration
  await basicLoggingExample();

  // Example 2: Categorized logging
  await categorizedLoggingExample();

  // Example 3: Different configurations for different environments
  await environmentConfigurationExample();

  // Example 4: Error handling with logging
  await errorHandlingExample();

  // Example 5: Structured logging
  await structuredLoggingExample();

  // Example 6: Performance logging
  await performanceLoggingExample();
}

/// Basic logging with default configuration
Future<void> basicLoggingExample() async {
  print('--- Basic Logging Example ---');
  
  // Use the global logger instance
  final logger = DSALogger.instance;
  
  logger.trace('This is a trace message (most verbose)');
  logger.debug('This is a debug message');
  logger.info('This is an info message');
  logger.warn('This is a warning message');
  logger.error('This is an error message');
  
  // Using convenience functions
  logInfo('Using convenience function for info');
  logWarn('Using convenience function for warning');
  
  print('');
}

/// Categorized logging for different components
Future<void> categorizedLoggingExample() async {
  print('--- Categorized Logging Example ---');
  
  // Create loggers for different components
  final websocketLogger = DSALogger.category('WebSocket');
  final responderLogger = DSALogger.category('Responder');
  final transportLogger = DSALogger.category('Transport');
  
  websocketLogger.info('WebSocket connection established');
  responderLogger.debug('Processing incoming request');
  transportLogger.trace('Raw message received', context: {
    'messageSize': 1024,
    'messageType': 'binary',
  });
  
  print('');
}

/// Different configurations for different environments
Future<void> environmentConfigurationExample() async {
  print('--- Environment Configuration Example ---');
  
  // Development configuration (verbose)
  print('Development mode:');
  DSALogger.configure(LoggerConfig.dev);
  logDebug('Debug info in development');
  logInfo('App starting in development mode');
  
  // Production configuration (structured, less verbose)
  print('\nProduction mode:');
  DSALogger.configure(LoggerConfig.production);
  logInfo('App starting in production mode');
  logDebug('This debug message won\'t appear in production');
  
  // Testing configuration (minimal)
  print('\nTesting mode:');
  DSALogger.configure(LoggerConfig.minimal);
  logInfo('This info message won\'t appear in testing');
  logWarn('Warning message in testing');
  
  // Custom configuration
  print('\nCustom configuration:');
  DSALogger.configure(const LoggerConfig(
    level: LogLevel.debug,
    includeTimestamp: true,
    includeLocation: true,
    useColors: true,
    useEmojis: true,
  ));
  
  final customLogger = DSALogger.category('CustomApp');
  customLogger.debug('Custom configured debug message');
  customLogger.info('Custom configured info message');
  
  print('');
}

/// Error handling with proper logging
Future<void> errorHandlingExample() async {
  print('--- Error Handling Example ---');
  
  // Reset to default config
  DSALogger.configure(const LoggerConfig());
  
  final logger = DSALogger.category('ErrorHandler');
  
  try {
    // Simulate some operation that might fail
    await simulateFailingOperation();
  } catch (error, stackTrace) {
    logger.error(
      'Operation failed',
      error: error,
      stackTrace: stackTrace,
      context: {
        'operation': 'simulateFailingOperation',
        'attemptNumber': 1,
        'userId': 'user123',
      },
    );
  }
  
  // Logging warnings for non-fatal issues
  logger.warn('Deprecated API usage detected', context: {
    'api': 'oldMethod',
    'replacement': 'newMethod',
    'deprecatedIn': '3.0.0',
  });
  
  print('');
}

/// Structured logging for machine-readable logs
Future<void> structuredLoggingExample() async {
  print('--- Structured Logging Example ---');
  
  // Configure for structured logging
  DSALogger.configure(const LoggerConfig(
    structuredLogging: true,
    useEmojis: false,
    useColors: false,
  ));
  
  final logger = DSALogger.category('API');
  
  logger.info('API request processed', context: {
    'method': 'POST',
    'path': '/api/nodes',
    'statusCode': 200,
    'responseTime': 150,
    'userAgent': 'DSALink/3.0.0',
    'requestId': 'req-123-456',
  });
  
  logger.error('Database connection failed', context: {
    'database': 'postgres',
    'host': 'localhost',
    'port': 5432,
    'timeout': 5000,
    'retryCount': 3,
  });
  
  print('');
}

/// Performance logging and monitoring
Future<void> performanceLoggingExample() async {
  print('--- Performance Logging Example ---');
  
  // Reset to readable config
  DSALogger.configure(const LoggerConfig(
    level: LogLevel.debug,
    structuredLogging: false,
  ));
  
  final logger = DSALogger.category('Performance');
  
  // Time a critical operation
  final stopwatch = Stopwatch()..start();
  
  logger.debug('Starting critical operation');
  
  // Simulate some work
  await Future.delayed(const Duration(milliseconds: 100));
  
  stopwatch.stop();
  
  logger.info('Critical operation completed', context: {
    'duration': '${stopwatch.elapsedMilliseconds}ms',
    'operation': 'data_processing',
  });
  
  // Log memory usage (in a real app, you'd get actual memory stats)
  logger.debug('Memory usage check', context: {
    'heapSize': '245MB',
    'usedMemory': '180MB',
    'availableMemory': '65MB',
  });
  
  // Log system metrics
  logger.trace('System metrics', context: {
    'cpuUsage': '15%',
    'networkLatency': '45ms',
    'activeConnections': 12,
  });
  
  print('');
}

/// Simulate a failing operation for error logging demo
Future<void> simulateFailingOperation() async {
  await Future.delayed(const Duration(milliseconds: 50));
  throw StateError('Network connection timeout');
}

/// Example of how to integrate logging in a real DSALink component
class ExampleDSAComponent {
  static final _logger = DSALogger.category('ExampleComponent');
  
  Future<void> initialize() async {
    _logger.info('Initializing DSA component');
    
    try {
      // Simulate initialization steps
      _logger.debug('Loading configuration');
      await Future.delayed(const Duration(milliseconds: 10));
      
      _logger.debug('Establishing connections');
      await Future.delayed(const Duration(milliseconds: 20));
      
      _logger.info('Component initialized successfully');
    } catch (error, stackTrace) {
      _logger.fatal(
        'Failed to initialize component',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  Future<void> processRequest(String requestType, Map<String, dynamic> data) async {
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    
    _logger.debug('Processing request', context: {
      'requestId': requestId,
      'type': requestType,
      'dataSize': data.length,
    });
    
    final stopwatch = Stopwatch()..start();
    
    try {
      // Simulate request processing
      await Future.delayed(const Duration(milliseconds: 30));
      
      stopwatch.stop();
      
      _logger.info('Request processed successfully', context: {
        'requestId': requestId,
        'type': requestType,
        'duration': '${stopwatch.elapsedMilliseconds}ms',
      });
    } catch (error, stackTrace) {
      stopwatch.stop();
      
      _logger.error(
        'Request processing failed',
        error: error,
        stackTrace: stackTrace,
        context: {
          'requestId': requestId,
          'type': requestType,
          'duration': '${stopwatch.elapsedMilliseconds}ms',
        },
      );
      rethrow;
    }
  }
}