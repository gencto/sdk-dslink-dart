import 'package:dsalink/utils/logger.dart';
import 'package:dsalink/utils/logging_config.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  group('Logger Tests', () {
    setUp(Logger.root.clearListeners);

    test('DsLogger initialization works correctly', () {
      expect(DsLogger.initialize, returnsNormally);
      expect(() => DsLogger.getLogger('TestLogger'), returnsNormally);
    });

    test('LoggerMixin provides logging capabilities', () {
      final testClass = TestClassWithLogger();

      expect(() => testClass.logInfo('Test info message'), returnsNormally);
      expect(
        () => testClass.logWarning('Test warning message'),
        returnsNormally,
      );
      expect(() => testClass.logError('Test error message'), returnsNormally);
      expect(() => testClass.logDebug('Test debug message'), returnsNormally);
    });

    test('Structured logging methods work correctly', () {
      LoggingManager.configureForTesting();

      expect(
        () => DsLogger.logPerformance(
          'Test operation',
          const Duration(milliseconds: 100),
          context: {'key': 'value'},
        ),
        returnsNormally,
      );

      expect(
        () => DsLogger.logConnection(
          'test_event',
          'test_endpoint',
          metadata: {'protocol': 'websocket'},
        ),
        returnsNormally,
      );

      expect(
        () => DsLogger.logRequest(
          'GET',
          '/test/path',
          requestId: 'test-123',
          params: {'param1': 'value1'},
        ),
        returnsNormally,
      );

      expect(
        () => DsLogger.logResponse(
          'GET',
          '/test/path',
          requestId: 'test-123',
          duration: const Duration(milliseconds: 50),
        ),
        returnsNormally,
      );

      expect(
        () => DsLogger.logError(
          'Test error',
          Exception('Test exception'),
          context: {'operation': 'test'},
        ),
        returnsNormally,
      );

      expect(
        () => DsLogger.logSecurity(
          'Authentication',
          'User login attempt',
          context: {'userId': 'test-user'},
        ),
        returnsNormally,
      );

      expect(
        () => DsLogger.logConfig('testSetting', 'oldValue', 'newValue'),
        returnsNormally,
      );
    });

    test('LoggingConfig environment parsing works', () {
      final config = LoggingConfig.fromEnvironment();
      expect(config, isA<LoggingConfig>());
      expect(config.level, isA<Level>());
    });

    test('LoggingConfig presets work correctly', () {
      final prodConfig = LoggingConfig.production();
      expect(prodConfig.level, equals(Level.WARNING));
      expect(prodConfig.enableConsoleOutput, isFalse);

      final devConfig = LoggingConfig.development();
      expect(devConfig.level, equals(Level.FINE));
      expect(devConfig.enableConsoleOutput, isTrue);

      final debugConfig = LoggingConfig.debug();
      expect(debugConfig.level, equals(Level.ALL));

      final silentConfig = LoggingConfig.silent();
      expect(silentConfig.level, equals(Level.OFF));
    });

    test('LoggingManager configuration methods work', () {
      expect(LoggingManager.configureForDevelopment, returnsNormally);
      expect(LoggingManager.configureForProduction, returnsNormally);
      expect(LoggingManager.configureForDebug, returnsNormally);
      expect(LoggingManager.configureForTesting, returnsNormally);

      expect(LoggingManager.currentConfig, isA<LoggingConfig>());
    });

    test('LoggingManager update configuration works', () {
      LoggingManager.configureForTesting();
      final initialLevel = LoggingManager.currentConfig.level;

      LoggingManager.updateConfig(
        (config) => config.copyWith(level: Level.WARNING),
      );
      expect(LoggingManager.currentConfig.level, equals(Level.WARNING));
      expect(LoggingManager.currentConfig.level, isNot(equals(initialLevel)));
    });

    test('Logger captures messages at appropriate levels', () {
      final capturedLogs = <LogRecord>[];
      LoggingManager.configureForDebug();

      // Enable hierarchical logging to allow setting levels on non-root loggers
      Logger.root.level = Level.ALL;

      Logger.root.onRecord.listen(capturedLogs.add);

      final logger = DsLogger.getLogger('TestCapture');

      logger.finest('Finest message');
      logger.fine('Fine message');
      logger.info('Info message');
      logger.warning('Warning message');
      logger.severe('Severe message');

      expect(capturedLogs.length, greaterThanOrEqualTo(5));
      expect(capturedLogs.any((log) => log.level == Level.FINEST), isTrue);
      expect(capturedLogs.any((log) => log.level == Level.SEVERE), isTrue);
    });

    test('LogContext extension works', () {
      final testObject = TestClassWithLogger();
      final context = testObject.logContext;

      expect(context, contains('TestClassWithLogger'));
      expect(context, contains('@'));
    });

    test('Performance logging includes timing information', () {
      final capturedLogs = <LogRecord>[];
      LoggingManager.configureForDebug();

      Logger.root.onRecord.listen(capturedLogs.add);

      DsLogger.logPerformance(
        'Test operation',
        const Duration(milliseconds: 250),
        context: {'operation': 'unit_test'},
      );

      final perfLog = capturedLogs.firstWhere(
        (log) => log.message.contains('Test operation'),
        orElse: () => throw StateError('Performance log not found'),
      );

      expect(perfLog.message, contains('250ms'));
      expect(perfLog.message, contains('⏱️'));
    });

    test('Error logging includes stack traces when provided', () {
      final capturedLogs = <LogRecord>[];
      LoggingManager.configureForDebug();

      Logger.root.onRecord.listen(capturedLogs.add);

      final testError = Exception('Test error');
      final testStack = StackTrace.current;

      DsLogger.logError(
        'Test error occurred',
        testError,
        stackTrace: testStack,
        context: {'test': true},
      );

      final errorLog = capturedLogs.firstWhere(
        (log) => log.level == Level.SEVERE,
        orElse: () => throw StateError('Error log not found'),
      );

      expect(errorLog.error, equals(testError));
      expect(errorLog.stackTrace, equals(testStack));
      expect(errorLog.message, contains('Test error occurred'));
    });
  });
}

/// Test class that uses the LoggerMixin
class TestClassWithLogger with LoggerMixin {
  void performTestOperation() {
    logInfo('Performing test operation');
  }

  void handleError() {
    try {
      throw Exception('Test exception');
    } catch (error, stackTrace) {
      logError('Operation failed', error, stackTrace);
    }
  }
}
