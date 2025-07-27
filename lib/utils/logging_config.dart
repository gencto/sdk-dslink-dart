import 'dart:io';

import 'package:dsalink/utils/logger.dart';
import 'package:logging/logging.dart';

/// Configuration class for managing logging settings
class LoggingConfig {
  const LoggingConfig({
    this.level = Level.INFO,
    this.enableConsoleOutput = true,
    this.enableDeveloperLog = true,
    this.enablePerformanceLogging = true,
    this.enableRequestResponseLogging = true,
    this.enableConnectionLogging = true,
    this.enableSecurityLogging = true,
    this.disabledLoggers = const [],
  });

  /// Create configuration based on environment
  factory LoggingConfig.fromEnvironment() {
    final env = Platform.environment;

    // Determine log level from environment
    var level = Level.INFO;
    final levelStr = env['DSALINK_LOG_LEVEL']?.toUpperCase();
    switch (levelStr) {
      case 'ALL':
        level = Level.ALL;
      case 'FINEST':
        level = Level.FINEST;
      case 'FINER':
        level = Level.FINER;
      case 'FINE':
        level = Level.FINE;
      case 'CONFIG':
        level = Level.CONFIG;
      case 'INFO':
        level = Level.INFO;
      case 'WARNING':
        level = Level.WARNING;
      case 'SEVERE':
        level = Level.SEVERE;
      case 'OFF':
        level = Level.OFF;
    }

    // Check if we're in debug/development mode
    final isDevelopment =
        env['DART_ENV'] == 'development' ||
        env['FLUTTER_ENV'] == 'development' ||
        env['DSALINK_DEBUG'] == 'true';

    // In development, enable more verbose logging
    if (isDevelopment && level == Level.INFO) {
      level = Level.FINE;
    }

    return LoggingConfig(
      level: level,
      enableConsoleOutput: _parseBool(env['DSALINK_LOG_CONSOLE'], true),
      enableDeveloperLog: _parseBool(env['DSALINK_LOG_DEVELOPER'], true),
      enablePerformanceLogging: _parseBool(
        env['DSALINK_LOG_PERFORMANCE'],
        true,
      ),
      enableRequestResponseLogging: _parseBool(
        env['DSALINK_LOG_REQUESTS'],
        true,
      ),
      enableConnectionLogging: _parseBool(env['DSALINK_LOG_CONNECTIONS'], true),
      enableSecurityLogging: _parseBool(env['DSALINK_LOG_SECURITY'], true),
      disabledLoggers: _parseList(env['DSALINK_LOG_DISABLED_LOGGERS']),
    );
  }

  /// Create a production-optimized configuration
  factory LoggingConfig.production() => const LoggingConfig(
    level: Level.WARNING,
    enableConsoleOutput: false,
    enablePerformanceLogging: false,
    enableRequestResponseLogging: false,
  );

  /// Create a development-optimized configuration
  factory LoggingConfig.development() => const LoggingConfig(level: Level.FINE);

  /// Create a debug configuration with maximum verbosity
  factory LoggingConfig.debug() => const LoggingConfig(level: Level.ALL);

  /// Create a silent configuration for testing
  factory LoggingConfig.silent() => const LoggingConfig(
    level: Level.OFF,
    enableConsoleOutput: false,
    enableDeveloperLog: false,
    enablePerformanceLogging: false,
    enableRequestResponseLogging: false,
    enableConnectionLogging: false,
    enableSecurityLogging: false,
  );
  final Level level;
  final bool enableConsoleOutput;
  final bool enableDeveloperLog;
  final bool enablePerformanceLogging;
  final bool enableRequestResponseLogging;
  final bool enableConnectionLogging;
  final bool enableSecurityLogging;
  final List<String> disabledLoggers;

  /// Apply this configuration to the logging system
  void apply() {
    DsLogger.initialize(
      level: level,
      enableConsoleOutput: enableConsoleOutput,
      enableDeveloperLog: enableDeveloperLog,
    );

    // Disable specific loggers if configured
    for (final loggerName in disabledLoggers) {
      final logger = DsLogger.getLogger(loggerName);
      logger.level = Level.OFF;
    }
  }

  /// Get a description of the current configuration
  String describe() =>
      '''
LoggingConfig:
  Level: ${level.name}
  Console Output: $enableConsoleOutput
  Developer Log: $enableDeveloperLog
  Performance Logging: $enablePerformanceLogging
  Request/Response Logging: $enableRequestResponseLogging
  Connection Logging: $enableConnectionLogging
  Security Logging: $enableSecurityLogging
  Disabled Loggers: ${disabledLoggers.isEmpty ? 'None' : disabledLoggers.join(', ')}
''';

  /// Parse boolean from environment variable
  static bool _parseBool(String? value, bool defaultValue) {
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true' || value == '1';
  }

  /// Parse list from environment variable (comma-separated)
  static List<String> _parseList(String? value) {
    if (value == null || value.isEmpty) return [];
    return value
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Copy configuration with modifications
  LoggingConfig copyWith({
    Level? level,
    bool? enableConsoleOutput,
    bool? enableDeveloperLog,
    bool? enablePerformanceLogging,
    bool? enableRequestResponseLogging,
    bool? enableConnectionLogging,
    bool? enableSecurityLogging,
    List<String>? disabledLoggers,
  }) => LoggingConfig(
    level: level ?? this.level,
    enableConsoleOutput: enableConsoleOutput ?? this.enableConsoleOutput,
    enableDeveloperLog: enableDeveloperLog ?? this.enableDeveloperLog,
    enablePerformanceLogging:
        enablePerformanceLogging ?? this.enablePerformanceLogging,
    enableRequestResponseLogging:
        enableRequestResponseLogging ?? this.enableRequestResponseLogging,
    enableConnectionLogging:
        enableConnectionLogging ?? this.enableConnectionLogging,
    enableSecurityLogging: enableSecurityLogging ?? this.enableSecurityLogging,
    disabledLoggers: disabledLoggers ?? this.disabledLoggers,
  );
}

/// Global logging configuration manager
class LoggingManager {
  static LoggingConfig? _currentConfig;

  /// Get the current logging configuration
  static LoggingConfig get currentConfig =>
      _currentConfig ?? LoggingConfig.fromEnvironment();

  /// Initialize logging with the specified configuration
  static void configure(LoggingConfig config) {
    _currentConfig = config;
    config.apply();

    final logger = DsLogger.getLogger('LoggingManager');
    logger.info(
      'Logging system initialized with configuration:\n${config.describe()}',
    );
  }

  /// Initialize with environment-based configuration
  static void configureFromEnvironment() {
    configure(LoggingConfig.fromEnvironment());
  }

  /// Quickly configure for development
  static void configureForDevelopment() {
    configure(LoggingConfig.development());
  }

  /// Quickly configure for production
  static void configureForProduction() {
    configure(LoggingConfig.production());
  }

  /// Quickly configure for debugging
  static void configureForDebug() {
    configure(LoggingConfig.debug());
  }

  /// Quickly configure for testing
  static void configureForTesting() {
    configure(LoggingConfig.silent());
  }

  /// Update the current configuration
  static void updateConfig(LoggingConfig Function(LoggingConfig) updater) {
    final newConfig = updater(currentConfig);
    configure(newConfig);
  }

  /// Enable verbose logging temporarily
  static void enableVerboseLogging() {
    updateConfig((config) => config.copyWith(level: Level.FINE));
  }

  /// Disable logging temporarily
  static void disableLogging() {
    updateConfig((config) => config.copyWith(level: Level.OFF));
  }
}
