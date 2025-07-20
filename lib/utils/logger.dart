import 'dart:developer' as developer;
import 'dart:io';

/// Log levels supported by the DSALink logger
enum LogLevel {
  trace(0, 'TRACE', '🔍'),
  debug(1, 'DEBUG', '🐛'),
  info(2, 'INFO', '📘'),
  warn(3, 'WARN', '⚠️'),
  error(4, 'ERROR', '❌'),
  fatal(5, 'FATAL', '💀');

  const LogLevel(this.value, this.name, this.emoji);

  final int value;
  final String name;
  final String emoji;

  bool operator >=(LogLevel other) => value >= other.value;
  bool operator <=(LogLevel other) => value <= other.value;
  bool operator >(LogLevel other) => value > other.value;
  bool operator <(LogLevel other) => value < other.value;
}

/// Logger configuration options
class LoggerConfig {
  /// Minimum log level to output
  final LogLevel level;

  /// Whether to include timestamps
  final bool includeTimestamp;

  /// Whether to include the calling location (file:line)
  final bool includeLocation;

  /// Whether to use colored output (when supported)
  final bool useColors;

  /// Whether to use emojis in log output
  final bool useEmojis;

  /// Custom log format function
  final String Function(LogEntry entry)? customFormatter;

  /// Output sink for logs (defaults to stdout/stderr)
  final IOSink? outputSink;

  /// Whether to enable structured logging (JSON format)
  final bool structuredLogging;

  const LoggerConfig({
    this.level = LogLevel.info,
    this.includeTimestamp = true,
    this.includeLocation = false,
    this.useColors = true,
    this.useEmojis = true,
    this.customFormatter,
    this.outputSink,
    this.structuredLogging = false,
  });

  /// Development configuration - more verbose
  static const dev = LoggerConfig(
    level: LogLevel.debug,
    includeLocation: true,
    includeTimestamp: true,
  );

  /// Production configuration - less verbose, structured
  static const production = LoggerConfig(
    level: LogLevel.info,
    includeLocation: false,
    includeTimestamp: true,
    structuredLogging: true,
    useEmojis: false,
  );

  /// Minimal configuration for CI/testing
  static const minimal = LoggerConfig(
    level: LogLevel.warn,
    includeTimestamp: false,
    includeLocation: false,
    useColors: false,
    useEmojis: false,
  );
}

/// Represents a single log entry
class LogEntry {
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final String? category;
  final Map<String, dynamic>? context;
  final Object? error;
  final StackTrace? stackTrace;
  final String? location;

  const LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    this.category,
    this.context,
    this.error,
    this.stackTrace,
    this.location,
  });

  /// Convert to JSON for structured logging
  Map<String, dynamic> toJson() => {
        'level': level.name,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        if (category != null) 'category': category,
        if (context != null) 'context': context,
        if (error != null) 'error': error.toString(),
        if (stackTrace != null) 'stackTrace': stackTrace.toString(),
        if (location != null) 'location': location,
      };
}

/// Main logger class for DSALink SDK
class DSALogger {
  static DSALogger? _instance;
  static LoggerConfig _config = const LoggerConfig();

  /// Get the singleton logger instance
  static DSALogger get instance => _instance ??= DSALogger._();

  DSALogger._();

  /// Configure the global logger
  static void configure(LoggerConfig config) {
    _config = config;
  }

  /// Get current configuration
  static LoggerConfig get config => _config;

  /// Create a categorized logger
  static DSALogger category(String category) {
    final logger = DSALogger._();
    logger._category = category;
    return logger;
  }

  String? _category;

  /// Log a trace message (most verbose)
  void trace(String message, {Map<String, dynamic>? context}) {
    _log(LogLevel.trace, message, context: context);
  }

  /// Log a debug message
  void debug(String message, {Map<String, dynamic>? context}) {
    _log(LogLevel.debug, message, context: context);
  }

  /// Log an info message
  void info(String message, {Map<String, dynamic>? context}) {
    _log(LogLevel.info, message, context: context);
  }

  /// Log a warning message
  void warn(String message, {Map<String, dynamic>? context}) {
    _log(LogLevel.warn, message, context: context);
  }

  /// Log an error message
  void error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace, context: context);
  }

  /// Log a fatal error message
  void fatal(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    _log(LogLevel.fatal, message, error: error, stackTrace: stackTrace, context: context);
  }

  /// Log with custom level
  void log(LogLevel level, String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    _log(level, message, error: error, stackTrace: stackTrace, context: context);
  }

  /// Internal logging method
  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    // Early return if log level is below threshold
    if (level < _config.level) return;

    final now = DateTime.now();
    String? location;

    // Extract location information if enabled
    if (_config.includeLocation) {
      location = _extractLocation();
    }

    final entry = LogEntry(
      level: level,
      message: message,
      timestamp: now,
      category: _category,
      context: context,
      error: error,
      stackTrace: stackTrace,
      location: location,
    );

    final formattedMessage = _config.customFormatter?.call(entry) ?? _formatMessage(entry);

    // Use developer.log for better IDE integration and performance
    developer.log(
      formattedMessage,
      time: now,
      level: level.value,
      name: _category ?? 'DSALink',
      error: error,
      stackTrace: stackTrace,
    );

    // Also output to configured sink if specified
    if (_config.outputSink != null) {
      _config.outputSink!.writeln(formattedMessage);
    }
  }

  /// Format a log message according to configuration
  String _formatMessage(LogEntry entry) {
    if (_config.structuredLogging) {
      return _formatStructured(entry);
    } else {
      return _formatHumanReadable(entry);
    }
  }

  /// Format as JSON for structured logging
  String _formatStructured(LogEntry entry) {
    // For simplicity, we'll use a basic JSON-like format
    // In production, consider using a proper JSON library
    final json = entry.toJson();
    final parts = <String>[];
    
    for (final MapEntry(:key, :value) in json.entries) {
      if (value != null) {
        parts.add('"$key":"${value.toString().replaceAll('"', '\\"')}"');
      }
    }
    
    return '{${parts.join(',')}}';
  }

  /// Format for human-readable output
  String _formatHumanReadable(LogEntry entry) {
    final buffer = StringBuffer();

    // Timestamp
    if (_config.includeTimestamp) {
      buffer.write('[${_formatTimestamp(entry.timestamp)}] ');
    }

    // Level with emoji and/or colors
    if (_config.useEmojis) {
      buffer.write('${entry.level.emoji} ');
    }
    
    if (_config.useColors && stdout.hasTerminal) {
      buffer.write(_colorizeLevel(entry.level));
    } else {
      buffer.write('[${entry.level.name}]');
    }

    // Category
    if (entry.category != null) {
      buffer.write(' ${entry.category}:');
    }

    // Location
    if (entry.location != null) {
      buffer.write(' (${entry.location})');
    }

    // Message
    buffer.write(' ${entry.message}');

    // Context
    if (entry.context != null && entry.context!.isNotEmpty) {
      buffer.write(' ${entry.context}');
    }

    // Error
    if (entry.error != null) {
      buffer.write('\n  Error: ${entry.error}');
    }

    // Stack trace (truncated for readability)
    if (entry.stackTrace != null) {
      final stackLines = entry.stackTrace.toString().split('\n');
      final relevantLines = stackLines.take(5).join('\n  ');
      buffer.write('\n  Stack: $relevantLines');
      if (stackLines.length > 5) {
        buffer.write('\n  ... ${stackLines.length - 5} more lines');
      }
    }

    return buffer.toString();
  }

  /// Format timestamp
  String _formatTimestamp(DateTime timestamp) {
    return timestamp.toIso8601String().substring(11, 23); // HH:mm:ss.mmm
  }

  /// Colorize log level for terminal output
  String _colorizeLevel(LogLevel level) {
    const reset = '\x1B[0m';
    const colors = {
      LogLevel.trace: '\x1B[37m', // White
      LogLevel.debug: '\x1B[36m', // Cyan
      LogLevel.info: '\x1B[32m',  // Green
      LogLevel.warn: '\x1B[33m',  // Yellow
      LogLevel.error: '\x1B[31m', // Red
      LogLevel.fatal: '\x1B[35m', // Magenta
    };
    
    final color = colors[level] ?? '';
    return '$color[${level.name}]$reset';
  }

  /// Extract calling location (simplified)
  String? _extractLocation() {
    try {
      final stack = StackTrace.current.toString();
      final lines = stack.split('\n');
      
      // Skip internal logger frames
      for (final line in lines) {
        if (!line.contains('logger.dart') && !line.contains('dart:developer')) {
          final match = RegExp(r'#\d+\s+.*\s\((.+):(\d+):\d+\)').firstMatch(line);
          if (match != null) {
            final file = match.group(1)?.split('/').last ?? '';
            final lineNum = match.group(2) ?? '';
            return '$file:$lineNum';
          }
        }
      }
    } catch (_) {
      // Ignore errors in location extraction
    }
    return null;
  }
}

/// Convenience functions for global logging
final _logger = DSALogger.instance;

void logTrace(String message, {Map<String, dynamic>? context}) => _logger.trace(message, context: context);
void logDebug(String message, {Map<String, dynamic>? context}) => _logger.debug(message, context: context);
void logInfo(String message, {Map<String, dynamic>? context}) => _logger.info(message, context: context);
void logWarn(String message, {Map<String, dynamic>? context}) => _logger.warn(message, context: context);
void logError(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) => 
    _logger.error(message, error: error, stackTrace: stackTrace, context: context);
void logFatal(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) => 
    _logger.fatal(message, error: error, stackTrace: stackTrace, context: context);