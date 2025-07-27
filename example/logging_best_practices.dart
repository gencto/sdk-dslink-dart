/// This example demonstrates logging best practices in the DSALink SDK.
///
/// Key Features:
/// - Structured logging with context
/// - Performance monitoring
/// - Error handling with proper logging
/// - Configuration management
/// - Different log levels for different environments
/// - Request/response correlation
/// - Security event logging
///
/// Run with: dart run example/logging_best_practices.dart
// ignore_for_file: avoid_print

library;

import 'dart:async';
import 'dart:math';

import 'package:dsalink/utils/logger.dart';
import 'package:dsalink/utils/logging_config.dart';
import 'package:logging/logging.dart';

void main() async {
  print('🚀 DSALink SDK - Logging Best Practices Example\n');

  // === 1. BASIC LOGGING SETUP ===
  print('1. Setting up logging configuration...');
  await demonstrateLoggingSetup();

  // === 2. STRUCTURED LOGGING ===
  print('\n2. Demonstrating structured logging...');
  await demonstrateStructuredLogging();

  // === 3. PERFORMANCE MONITORING ===
  print('\n3. Demonstrating performance monitoring...');
  await demonstratePerformanceLogging();

  // === 4. ERROR HANDLING ===
  print('\n4. Demonstrating error handling and logging...');
  await demonstrateErrorLogging();

  // === 5. REQUEST/RESPONSE CORRELATION ===
  print('\n5. Demonstrating request/response correlation...');
  await demonstrateRequestResponseLogging();

  // === 6. SECURITY LOGGING ===
  print('\n6. Demonstrating security event logging...');
  await demonstrateSecurityLogging();

  // === 7. CONFIGURATION LOGGING ===
  print('\n7. Demonstrating configuration logging...');
  await demonstrateConfigurationLogging();

  // === 8. CLASS-BASED LOGGING ===
  print('\n8. Demonstrating class-based logging with LoggerMixin...');
  await demonstrateClassBasedLogging();

  print('\n✅ All logging examples completed successfully!');
  print(
    '\n📝 Check your console output to see the structured logging in action.',
  );
  print(
    '💡 In production, configure logging appropriately for your environment.',
  );
}

/// Demonstrates how to set up logging for different environments
Future<void> demonstrateLoggingSetup() async {
  print('   Setting up development logging...');
  LoggingManager.configureForDevelopment();

  final logger = DsLogger.getLogger('SetupExample')
    ..info('Development logging configuration applied');

  // Show current configuration
  print('   Current configuration:');
  print('   ${LoggingManager.currentConfig.describe()}');

  // Demonstrate different environment configurations
  print('   Testing different environment configurations...');

  LoggingManager.configureForProduction();
  logger.warning('This is what production logging looks like');

  LoggingManager.configureForDebug();
  logger.fine('This is debug-level logging (very verbose)');

  // Reset to development for the rest of the examples
  LoggingManager.configureForDevelopment();
}

/// Demonstrates structured logging with context and metadata
Future<void> demonstrateStructuredLogging() async {
  DsLogger.getLogger('StructuredLogging')
  // Simple structured log
  .info('User action performed');

  // Connection logging with metadata
  DsLogger.logConnection(
    'established',
    'wss://broker.example.com:8080/ws',
    component: 'WebSocketClient',
    metadata: {
      'protocol': 'websocket',
      'version': '1.3',
      'clientId': 'client_12345',
      'timestamp': DateTime.now().toIso8601String(),
    },
  );

  // Connection failure
  DsLogger.logConnection(
    'failed',
    'wss://unreachable.example.com/ws',
    level: Level.SEVERE,
    component: 'WebSocketClient',
    metadata: {
      'reason': 'Connection timeout',
      'retryAttempt': 3,
      'timeout': 5000,
    },
  );
}

/// Demonstrates performance monitoring and metrics logging
Future<void> demonstratePerformanceLogging() async {
  final logger = DsLogger.getLogger('PerformanceExample')
    // Simulate a complex operation
    ..info('Starting complex data processing operation...');

  final stopwatch = Stopwatch()..start();

  // Simulate work with multiple phases
  await simulateProcessingPhase(
    'Data loading',
    const Duration(milliseconds: 120),
  );
  await simulateProcessingPhase(
    'Data validation',
    const Duration(milliseconds: 80),
  );
  await simulateProcessingPhase(
    'Data transformation',
    const Duration(milliseconds: 200),
  );
  await simulateProcessingPhase(
    'Data persistence',
    const Duration(milliseconds: 150),
  );

  stopwatch.stop();

  // Log the overall performance
  DsLogger.logPerformance(
    'Complete data processing pipeline',
    stopwatch.elapsed,
    component: 'DataProcessor',
    context: {
      'recordsProcessed': 1000,
      'phases': 4,
      'averageRecordTime': stopwatch.elapsedMicroseconds / 1000,
    },
  );

  logger.info('Complex operation completed successfully');
}

/// Simulates a processing phase with timing
Future<void> simulateProcessingPhase(
  String phaseName,
  Duration duration,
) async {
  final phaseStopwatch = Stopwatch()..start();

  // Simulate processing time
  await Future.delayed(duration);

  phaseStopwatch.stop();

  DsLogger.logPerformance(
    phaseName,
    phaseStopwatch.elapsed,
    component: 'DataProcessor',
    context: {'phase': phaseName, 'recordsInPhase': 250},
  );
}

/// Demonstrates comprehensive error handling and logging
Future<void> demonstrateErrorLogging() async {
  final logger = DsLogger.getLogger('ErrorHandling');

  // Example 1: Simple error with context
  try {
    throw Exception('Simulated network error');
  } on Exception catch (error, stackTrace) {
    DsLogger.logError(
      'Network operation failed',
      error,
      stackTrace: stackTrace,
      component: 'NetworkClient',
      context: {
        'operation': 'fetch_user_data',
        'userId': 'user_12345',
        'endpoint': '/api/users/12345',
        'retryAttempt': 1,
      },
    );
  }

  // Example 2: Validation error
  try {
    validateUserInput({'email': 'invalid-email'});
  } on Exception catch (error, stackTrace) {
    DsLogger.logError(
      'User input validation failed',
      error,
      stackTrace: stackTrace,
      component: 'Validator',
      context: {
        'validationType': 'email',
        'inputLength': 13,
        'operation': 'user_registration',
      },
    );
  }

  // Example 3: Timeout error
  try {
    await simulateTimeoutOperation();
  } on TimeoutException catch (error, stackTrace) {
    DsLogger.logError(
      'Operation timed out',
      error,
      stackTrace: stackTrace,
      component: 'TimeoutHandler',
      context: {
        'operation': 'database_query',
        'timeout': 5000,
        'query': 'SELECT * FROM users WHERE status = active',
      },
    );
  }

  logger.info('Error handling examples completed');
}

/// Demonstrates request/response correlation logging
Future<void> demonstrateRequestResponseLogging() async {
  final random = Random();

  // Simulate multiple concurrent requests
  final futures = List.generate(3, (index) async {
    final requestId = 'req_${DateTime.now().millisecondsSinceEpoch}_$index';
    final path = '/api/data/$index';
    final params = {'filter': 'active', 'limit': 10 + index * 5};

    // Log the request
    DsLogger.logRequest(
      'GET',
      path,
      requestId: requestId,
      params: params,
      component: 'ApiClient',
    );

    // Simulate processing time
    final processingTime = Duration(milliseconds: 50 + random.nextInt(200));
    await Future.delayed(processingTime);

    // Simulate success/failure
    final success = random.nextBool();

    if (success) {
      // Log successful response
      DsLogger.logResponse(
        'GET',
        path,
        requestId: requestId,
        duration: processingTime,
        result: {'count': 10 + index * 5, 'page': 1},
        component: 'ApiClient',
      );
    } else {
      // Log failed response
      DsLogger.logResponse(
        'GET',
        path,
        requestId: requestId,
        duration: processingTime,
        success: false,
        level: Level.WARNING,
        component: 'ApiClient',
      );
    }

    return requestId;
  });

  final completedRequests = await Future.wait(futures);

  DsLogger.getLogger(
    'RequestResponse',
  ).info('Completed ${completedRequests.length} correlated requests');
}

/// Demonstrates security event logging
Future<void> demonstrateSecurityLogging() async {
  // Authentication events
  DsLogger.logSecurity(
    'Authentication',
    'User login attempt',
    level: Level.INFO,
    component: 'AuthService',
    context: {
      'userId': 'user_12345',
      'method': 'password',
      'ip': '192.168.1.100',
      'userAgent': 'DSALink SDK v3.0.0',
      'timestamp': DateTime.now().toIso8601String(),
    },
  );

  // Successful authentication
  DsLogger.logSecurity(
    'Authentication',
    'User login successful',
    level: Level.INFO,
    component: 'AuthService',
    context: {
      'userId': 'user_12345',
      'sessionId': 'sessionId_${DateTime.now().millisecondsSinceEpoch}',
      'roles': ['user', 'device_manager'],
    },
  );

  // Failed authentication
  DsLogger.logSecurity(
    'Authentication',
    'User login failed - invalid credentials',
    component: 'AuthService',
    context: {
      'userId': 'user_67890',
      'reason': 'invalid_password',
      'attemptCount': 3,
      'ip': '192.168.1.100',
    },
  );

  // Authorization events
  DsLogger.logSecurity(
    'Authorization',
    'Access denied to protected resource',
    component: 'AuthorizationService',
    context: {
      'userId': 'user_12345',
      'resource': '/admin/users',
      'requiredRole': 'admin',
      'userRoles': ['user', 'device_manager'],
    },
  );

  // Token events
  DsLogger.logSecurity(
    'Token',
    'Access token expired',
    level: Level.INFO,
    component: 'TokenService',
    context: {
      'userId': 'user_12345',
      'tokenType': 'access_token',
      'expiryTime': DateTime.now()
          .subtract(const Duration(minutes: 1))
          .toIso8601String(),
    },
  );
}

/// Demonstrates configuration change logging
Future<void> demonstrateConfigurationLogging() async {
  final logger = DsLogger.getLogger('Configuration');

  // Simulate configuration changes
  DsLogger.logConfig('logLevel', 'INFO', 'DEBUG', component: 'LoggingSystem');

  DsLogger.logConfig('maxConnections', 100, 150, component: 'ConnectionPool');

  DsLogger.logConfig('enableSsl', false, true, component: 'SecuritySettings');

  DsLogger.logConfig(
    'retryTimeout',
    const Duration(seconds: 5),
    const Duration(seconds: 10),
    component: 'NetworkSettings',
  );

  logger.info('Configuration logging examples completed');
}

/// Demonstrates class-based logging using LoggerMixin
Future<void> demonstrateClassBasedLogging() async {
  final processor = DataProcessor();
  final networkClient = NetworkClient();
  final cacheManager = CacheManager();

  await processor.processData(['item1', 'item2', 'item3']);
  await networkClient.fetchData('https://api.example.com/data');
  await cacheManager.cacheItem('key1', 'value1');

  print('   Class-based logging completed successfully');
}

// === HELPER FUNCTIONS AND CLASSES ===

void validateUserInput(Map<String, dynamic> input) {
  final email = input['email'] as String?;
  if (email == null || !email.contains('@')) {
    throw ArgumentError('Invalid email format: $email');
  }
}

Future<void> simulateTimeoutOperation() async {
  await Future.delayed(const Duration(milliseconds: 100));
  throw TimeoutException('Operation timed out', const Duration(seconds: 5));
}

/// Example class demonstrating LoggerMixin usage
class DataProcessor with LoggerMixin {
  Future<void> processData(List<String> items) async {
    logInfo('Starting data processing for ${items.length} items');

    final stopwatch = Stopwatch()..start();

    try {
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        logDebug('Processing item: $item');

        // Simulate processing
        await Future.delayed(const Duration(milliseconds: 50));

        if (item == 'item2') {
          logWarning('Item requires special handling: $item');
        }
      }

      stopwatch.stop();
      logInfo('''
         Data processing completed successfully 
         in ${stopwatch.elapsedMilliseconds}ms 
         ''');
    } catch (error, stackTrace) {
      stopwatch.stop();
      logError('Data processing failed', error, stackTrace);
      rethrow;
    }
  }
}

/// Example network client with comprehensive logging
class NetworkClient with LoggerMixin {
  int _requestCount = 0;

  Future<Map<String, dynamic>> fetchData(String url) async {
    final requestId =
        'net_${++_requestCount}_${DateTime.now().millisecondsSinceEpoch}';
    final stopwatch = Stopwatch()..start();

    try {
      logInfo('Initiating network request to $url');

      DsLogger.logRequest(
        'GET',
        url,
        requestId: requestId,
        component: 'NetworkClient',
      );

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 150));

      final responseData = {
        'status': 'success',
        'data': ['item1', 'item2', 'item3'],
        'timestamp': DateTime.now().toIso8601String(),
      };

      stopwatch.stop();

      DsLogger.logResponse(
        'GET',
        url,
        requestId: requestId,
        duration: stopwatch.elapsed,
        result: {'itemCount': 3},
        component: 'NetworkClient',
      );

      logInfo('Network request completed successfully');
      return responseData;
    } catch (error, stackTrace) {
      stopwatch.stop();

      DsLogger.logResponse(
        'GET',
        url,
        requestId: requestId,
        duration: stopwatch.elapsed,
        success: false,
        level: Level.SEVERE,
        component: 'NetworkClient',
      );

      logError('Network request failed', error, stackTrace);
      rethrow;
    }
  }
}

/// Example cache manager with performance logging
class CacheManager with LoggerMixin {
  final Map<String, dynamic> _cache = {};

  // ignore: type_annotate_public_apis
  Future<void> cacheItem(String key, value) async {
    final stopwatch = Stopwatch()..start();

    try {
      logDebug('Caching item with key: $key');

      // Simulate cache operation
      await Future.delayed(const Duration(milliseconds: 10));

      _cache[key] = value;

      stopwatch.stop();

      DsLogger.logPerformance(
        'Cache set operation',
        stopwatch.elapsed,
        component: 'CacheManager',
        context: {
          'key': key,
          'cacheSize': _cache.length,
          'valueType': value.runtimeType.toString(),
        },
      );

      logInfo('Item cached successfully: $key');
    } catch (error, stackTrace) {
      stopwatch.stop();
      logError('Failed to cache item: $key', error, stackTrace);
      rethrow;
    }
  }
}
