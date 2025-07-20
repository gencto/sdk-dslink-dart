/// Performance configuration for DSALink SDK
/// 
/// This class centralizes all performance-related settings to allow
/// easy tuning and optimization for different deployment scenarios.
class PerformanceConfig {
  PerformanceConfig._();

  // JSON Processing Optimizations
  static const int jsonCompressionThreshold = 1024; // bytes
  static const int maxJsonCacheSize = 1000;
  static const int largePayloadThreshold = 1024; // bytes for isolate parsing

  // Streaming and Batching
  static const Duration batchUpdateDelay = Duration(milliseconds: 16); // ~60fps
  static const Duration valueChangeDebounce = Duration(milliseconds: 50);
  static const int maxBatchSize = 100;

  // Connection and Transport
  static const int maxReconnectAttempts = 3;
  static const Duration reconnectDelay = Duration(seconds: 2);
  static const int messageQueueSize = 100;
  static const int compressionThreshold = 1024;

  // Memory Management
  static const int maxPathCacheSize = 1000;
  static const Duration cacheCleanupInterval = Duration(minutes: 10);
  static const int maxSubscriptionHistory = 100;

  // Logging and Monitoring
  static const bool enableProductionLogging = false;
  static const int performanceLogInterval = 1000; // messages
  static const bool enableMetricsCollection = true;

  // Code Generation Optimizations
  static const bool enableFreezer = true;
  static const bool enableJsonSerialization = true;
  static const bool enableToStringGeneration = false; // Saves space
  static const bool enableCopyWith = false; // Saves space if not needed
  static const bool enableFromJsonGeneration = true;

  // Node Management
  static const int maxChildNodes = 1000;
  static const int maxNodeDepth = 20;
  static const Duration nodeCleanupInterval = Duration(minutes: 5);

  /// Environment-specific configurations
  static Map<String, dynamic> getConfigForEnvironment(String environment) {
    switch (environment.toLowerCase()) {
      case 'production':
        return {
          'logging': false,
          'compression': true,
          'batching': true,
          'caching': true,
          'metrics': false,
        };
      case 'development':
        return {
          'logging': true,
          'compression': false,
          'batching': true,
          'caching': true,
          'metrics': true,
        };
      case 'testing':
        return {
          'logging': false,
          'compression': false,
          'batching': false,
          'caching': false,
          'metrics': false,
        };
      default:
        return getConfigForEnvironment('development');
    }
  }

  /// Apply environment configuration
  static void applyEnvironmentConfig(String environment) {
    final config = getConfigForEnvironment(environment);
    
    // This would set various static flags throughout the application
    // Implementation would depend on how each component reads configuration
    
    // Example implementation:
    // LoggingConfig.enabled = config['logging'] as bool;
    // CompressionConfig.enabled = config['compression'] as bool;
    // etc.
  }
}