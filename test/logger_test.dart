import 'dart:io';
import 'package:test/test.dart';
import 'package:dsalink/utils/logger.dart';

void main() {
  group('DSALogger', () {
    setUp(() {
      // Reset logger configuration before each test
      DSALogger.configure(const LoggerConfig());
    });

    test('should create singleton instance', () {
      final logger1 = DSALogger.instance;
      final logger2 = DSALogger.instance;
      expect(identical(logger1, logger2), isTrue);
    });

    test('should create categorized loggers', () {
      final webSocketLogger = DSALogger.category('WebSocket');
      final responderLogger = DSALogger.category('Responder');
      
      expect(webSocketLogger, isA<DSALogger>());
      expect(responderLogger, isA<DSALogger>());
      expect(identical(webSocketLogger, responderLogger), isFalse);
    });

    test('should configure logger globally', () {
      const config = LoggerConfig(
        level: LogLevel.error,
        includeTimestamp: false,
        useColors: false,
      );
      
      DSALogger.configure(config);
      expect(DSALogger.config, equals(config));
    });

    test('should respect log level filtering', () {
      DSALogger.configure(const LoggerConfig(level: LogLevel.warn));
      
      final logger = DSALogger.instance;
      
      // These should not cause any output (we can't easily test this without mocking)
      logger.trace('trace message');
      logger.debug('debug message');
      logger.info('info message');
      
      // These should produce output
      logger.warn('warn message');
      logger.error('error message');
      logger.fatal('fatal message');
    });

    test('should handle different log levels correctly', () {
      expect(LogLevel.trace < LogLevel.debug, isTrue);
      expect(LogLevel.debug < LogLevel.info, isTrue);
      expect(LogLevel.info < LogLevel.warn, isTrue);
      expect(LogLevel.warn < LogLevel.error, isTrue);
      expect(LogLevel.error < LogLevel.fatal, isTrue);
      
      expect(LogLevel.fatal >= LogLevel.error, isTrue);
      expect(LogLevel.warn <= LogLevel.error, isTrue);
    });

    test('should create log entry with all properties', () {
      final now = DateTime.now();
      final context = {'key': 'value'};
      final error = Exception('test error');
      final stackTrace = StackTrace.current;
      
      final entry = LogEntry(
        level: LogLevel.error,
        message: 'test message',
        timestamp: now,
        category: 'TestCategory',
        context: context,
        error: error,
        stackTrace: stackTrace,
        location: 'test.dart:123',
      );
      
      expect(entry.level, equals(LogLevel.error));
      expect(entry.message, equals('test message'));
      expect(entry.timestamp, equals(now));
      expect(entry.category, equals('TestCategory'));
      expect(entry.context, equals(context));
      expect(entry.error, equals(error));
      expect(entry.stackTrace, equals(stackTrace));
      expect(entry.location, equals('test.dart:123'));
    });

    test('should convert log entry to JSON', () {
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'test message',
        timestamp: DateTime(2023, 1, 1, 12, 0, 0),
        category: 'Test',
        context: {'key': 'value'},
      );
      
      final json = entry.toJson();
      
      expect(json['level'], equals('INFO'));
      expect(json['message'], equals('test message'));
      expect(json['timestamp'], equals('2023-01-01T12:00:00.000'));
      expect(json['category'], equals('Test'));
      expect(json['context'], equals({'key': 'value'}));
    });

    group('LoggerConfig presets', () {
      test('dev config should be verbose', () {
        const config = LoggerConfig.dev;
        expect(config.level, equals(LogLevel.debug));
        expect(config.includeLocation, isTrue);
        expect(config.includeTimestamp, isTrue);
      });

      test('production config should be structured', () {
        const config = LoggerConfig.production;
        expect(config.level, equals(LogLevel.info));
        expect(config.structuredLogging, isTrue);
        expect(config.useEmojis, isFalse);
      });

      test('minimal config should be quiet', () {
        const config = LoggerConfig.minimal;
        expect(config.level, equals(LogLevel.warn));
        expect(config.includeTimestamp, isFalse);
        expect(config.useColors, isFalse);
        expect(config.useEmojis, isFalse);
      });
    });

    test('convenience functions should work', () {
      // These functions should not throw
      logTrace('trace message');
      logDebug('debug message');
      logInfo('info message');
      logWarn('warn message');
      logError('error message');
      logFatal('fatal message');
      
      logError('error with context', error: Exception('test'), context: {'key': 'value'});
    });

    test('logger should handle errors gracefully', () {
      final logger = DSALogger.category('Test');
      
      // Should not throw even with null or problematic data
      logger.info('message with null context', context: null);
      logger.error('error message', error: null, stackTrace: null);
      
      // Should handle complex context objects
      logger.debug('complex context', context: {
        'list': [1, 2, 3],
        'map': {'nested': 'value'},
        'number': 42,
        'boolean': true,
      });
    });

    test('should handle context serialization', () {
      final logger = DSALogger.category('Test');
      
      // Test with various data types in context
      logger.info('test message', context: {
        'string': 'value',
        'int': 42,
        'double': 3.14,
        'bool': true,
        'list': [1, 2, 3],
        'map': {'nested': 'data'},
        'null': null,
      });
    });

    test('log levels should have correct properties', () {
      expect(LogLevel.trace.value, equals(0));
      expect(LogLevel.trace.name, equals('TRACE'));
      expect(LogLevel.trace.emoji, equals('🔍'));
      
      expect(LogLevel.debug.value, equals(1));
      expect(LogLevel.debug.name, equals('DEBUG'));
      expect(LogLevel.debug.emoji, equals('🐛'));
      
      expect(LogLevel.info.value, equals(2));
      expect(LogLevel.info.name, equals('INFO'));
      expect(LogLevel.info.emoji, equals('📘'));
      
      expect(LogLevel.warn.value, equals(3));
      expect(LogLevel.warn.name, equals('WARN'));
      expect(LogLevel.warn.emoji, equals('⚠️'));
      
      expect(LogLevel.error.value, equals(4));
      expect(LogLevel.error.name, equals('ERROR'));
      expect(LogLevel.error.emoji, equals('❌'));
      
      expect(LogLevel.fatal.value, equals(5));
      expect(LogLevel.fatal.name, equals('FATAL'));
      expect(LogLevel.fatal.emoji, equals('💀'));
    });
  });
}