import 'dart:developer' as developer;

import 'package:logging/logging.dart';

/// Logger utility class that implements best practices for the DSALink SDK
class DsLogger {
  DsLogger._();

  static final Map<String, Logger> _loggers = {};
  static bool _isInitialized = false;

  /// Initialize the logging system with the specified level
  static void initialize({
    Level level = Level.INFO,
    bool enableConsoleOutput = true,
    bool enableDeveloperLog = true,
  }) {
    if (_isInitialized) return;

    Logger.root.level = level;

    if (enableConsoleOutput || enableDeveloperLog) {
      Logger.root.onRecord.listen((record) {
        final message = _formatLogMessage(record);

        if (enableConsoleOutput) {
          print(message);
        }

        if (enableDeveloperLog) {
          developer.log(
            record.message,
            time: record.time,
            level: _mapLogLevel(record.level),
            name: record.loggerName,
            error: record.error,
            stackTrace: record.stackTrace,
          );
        }
      });
    }

    _isInitialized = true;
  }

  /// Get a logger for the specified component/class
  static Logger getLogger(String name) => _loggers.putIfAbsent(name, () => Logger(name));

  /// Get a logger for a specific class type
  static Logger getLoggerForType<T>() => getLogger(T.toString());

  /// Log performance metrics
  static void logPerformance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? context,
    String? component,
  }) {
    final logger = getLogger(component ?? 'Performance');
    final contextStr = context != null ? ' | Context: $context' : '';
    logger.info(
      '⏱️ $operation completed in ${duration.inMilliseconds}ms$contextStr',
    );
  }

  /// Log connection events with structured data
  static void logConnection(
    String event,
    String endpoint, {
    Level level = Level.INFO,
    Map<String, dynamic>? metadata,
    String? component,
  }) {
    final logger = getLogger(component ?? 'Connection');
    final metadataStr = metadata != null ? ' | Metadata: $metadata' : '';
    logger.log(level, '🔗 Connection $event: $endpoint$metadataStr');
  }

  /// Log request/response cycles with correlation IDs
  static void logRequest(
    String method,
    String path, {
    String? requestId,
    Map<String, dynamic>? params,
    Level level = Level.INFO,
    String? component,
  }) {
    final logger = getLogger(component ?? 'Request');
    final idStr = requestId != null ? ' [$requestId]' : '';
    final paramsStr = params != null ? ' | Params: $params' : '';
    logger.log(level, '📤 $method $path$idStr$paramsStr');
  }

  /// Log responses with timing and status
  static void logResponse(
    String method,
    String path, {
    String? requestId,
    Duration? duration,
    bool success = true,
    result,
    Level level = Level.INFO,
    String? component,
  }) {
    final logger = getLogger(component ?? 'Response');
    final idStr = requestId != null ? ' [$requestId]' : '';
    final durationStr = duration != null
        ? ' | ${duration.inMilliseconds}ms'
        : '';
    final statusIcon = success ? '✅' : '❌';
    final resultStr = result != null ? ' | Result: $result' : '';
    logger.log(level, '$statusIcon $method $path$idStr$durationStr$resultStr');
  }

  /// Log errors with context and stack traces
  static void logError(
    String message,
    error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String? component,
  }) {
    final logger = getLogger(component ?? 'Error');
    final contextStr = context != null ? ' | Context: $context' : '';
    logger.severe('❌ $message$contextStr', error, stackTrace);
  }

  /// Log configuration changes
  static void logConfig(
    String setting,
    oldValue,
    newValue, {
    String? component,
  }) {
    final logger = getLogger(component ?? 'Config');
    logger.info('⚙️ Config changed: $setting from $oldValue to $newValue');
  }

  /// Log security events
  static void logSecurity(
    String event,
    String details, {
    Level level = Level.WARNING,
    Map<String, dynamic>? context,
    String? component,
  }) {
    final logger = getLogger(component ?? 'Security');
    final contextStr = context != null ? ' | Context: $context' : '';
    logger.log(level, '🔐 Security: $event - $details$contextStr');
  }

  /// Format log messages consistently
  static String _formatLogMessage(LogRecord record) {
    final timestamp = record.time.toIso8601String();
    final level = record.level.name.padRight(7);
    final logger = record.loggerName.padRight(20);

    var message = '[$timestamp] $level [$logger] ${record.message}';

    if (record.error != null) {
      message += '\nError: ${record.error}';
    }

    if (record.stackTrace != null) {
      message += '\nStackTrace:\n${record.stackTrace}';
    }

    return message;
  }

  /// Map logging levels to developer log levels
  static int _mapLogLevel(Level level) {
    if (level >= Level.SEVERE) return 1000;
    if (level >= Level.WARNING) return 900;
    if (level >= Level.INFO) return 800;
    if (level >= Level.CONFIG) return 700;
    if (level >= Level.FINE) return 500;
    if (level >= Level.FINER) return 400;
    if (level >= Level.FINEST) return 300;
    return 0;
  }
}

/// Mixin to add logging capabilities to any class
mixin LoggerMixin {
  late final Logger _logger = DsLogger.getLoggerForType();

  Logger get logger => _logger;

  void logDebug(String message, [error, StackTrace? stackTrace]) {
    _logger.fine(message, error, stackTrace);
  }

  void logInfo(String message, [error, StackTrace? stackTrace]) {
    _logger.info(message, error, stackTrace);
  }

  void logWarning(String message, [error, StackTrace? stackTrace]) {
    _logger.warning(message, error, stackTrace);
  }

  void logError(String message, [error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }
}

/// Extension to add logging context to any object
extension LogContext on Object {
  String get logContext => '$runtimeType@${hashCode.toRadixString(16)}';
}
