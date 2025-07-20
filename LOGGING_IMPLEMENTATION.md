# DSALink SDK - Logging Best Practices Implementation

## Overview

This document outlines the comprehensive logging best practices implemented in the DSALink SDK. The implementation provides structured, configurable, and production-ready logging capabilities that follow industry standards.

## Key Features

### 🏗️ **Structured Logging Architecture**
- **Centralized Logger Management**: `DsLogger` class provides unified access to logging functionality
- **Component-Based Logging**: Each component has its own logger instance for better traceability
- **Structured Context**: All log messages include relevant context and metadata
- **Performance Metrics**: Built-in performance logging with timing and metrics

### 🔧 **Configuration Management**
- **Environment-Based Configuration**: Automatically adapts to development, production, and debug environments
- **Runtime Configuration**: Dynamic configuration changes without restarts
- **Environment Variables**: Supports configuration via environment variables
- **Preset Configurations**: Ready-to-use configurations for different scenarios

### 📊 **Advanced Logging Capabilities**
- **Request/Response Correlation**: Track requests through the entire lifecycle with unique IDs
- **Security Event Logging**: Specialized logging for authentication, authorization, and security events
- **Connection Logging**: Detailed connection lifecycle tracking
- **Error Context**: Rich error logging with stack traces and contextual information

## Implementation Details

### Core Components

#### 1. **DsLogger** (`lib/utils/logger.dart`)
The main logging utility class that provides:

```dart
// Basic logging
DsLogger.getLogger('ComponentName').info('Message');

// Performance logging
DsLogger.logPerformance('Operation', duration, context: {...});

// Connection logging
DsLogger.logConnection('established', 'wss://example.com', metadata: {...});

// Request/Response logging
DsLogger.logRequest('GET', '/path', requestId: 'req_123');
DsLogger.logResponse('GET', '/path', requestId: 'req_123', duration: duration);

// Error logging
DsLogger.logError('Error message', error, stackTrace: stackTrace, context: {...});

// Security logging
DsLogger.logSecurity('Authentication', 'User login', context: {...});

// Configuration logging
DsLogger.logConfig('setting', 'oldValue', 'newValue');
```

#### 2. **LoggingConfig** (`lib/utils/logging_config.dart`)
Configuration management for logging behavior:

```dart
// Environment-based configuration
LoggingManager.configureFromEnvironment();

// Preset configurations
LoggingManager.configureForDevelopment();
LoggingManager.configureForProduction();
LoggingManager.configureForDebug();
LoggingManager.configureForTesting();

// Custom configuration
final config = LoggingConfig(
  level: Level.INFO,
  enableConsoleOutput: true,
  enablePerformanceLogging: true,
);
LoggingManager.configure(config);
```

#### 3. **LoggerMixin** (`lib/utils/logger.dart`)
Mixin for easy integration into any class:

```dart
class MyService with LoggerMixin {
  void performOperation() {
    logInfo('Starting operation');
    try {
      // ... operation logic
      logInfo('Operation completed successfully');
    } catch (error, stackTrace) {
      logError('Operation failed', error, stackTrace);
      rethrow;
    }
  }
}
```

### Environment Configuration

The logging system supports configuration via environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `DSALINK_LOG_LEVEL` | Log level (FINEST, FINE, INFO, WARNING, SEVERE, OFF) | INFO |
| `DSALINK_LOG_CONSOLE` | Enable console output (true/false) | true |
| `DSALINK_LOG_DEVELOPER` | Enable developer log (true/false) | true |
| `DSALINK_LOG_PERFORMANCE` | Enable performance logging (true/false) | true |
| `DSALINK_LOG_REQUESTS` | Enable request/response logging (true/false) | true |
| `DSALINK_LOG_CONNECTIONS` | Enable connection logging (true/false) | true |
| `DSALINK_LOG_SECURITY` | Enable security logging (true/false) | true |
| `DSALINK_LOG_DISABLED_LOGGERS` | Comma-separated list of loggers to disable | - |
| `DSALINK_DEBUG` | Enable debug mode (true/false) | false |

### Integration Examples

#### WebSocket Responder
```dart
class WebSocketResponder with LoggerMixin {
  Future<void> start() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      logInfo('Starting WebSocket responder');
      
      DsLogger.logSecurity('Handshake initiated', 'Performing handshake...');
      // ... handshake logic
      
      DsLogger.logConnection('established', wsUri.toString());
      // ... connection logic
      
      DsLogger.logPerformance('WebSocket responder startup', stopwatch.elapsed);
      
    } catch (error, stackTrace) {
      DsLogger.logError('Failed to start WebSocket responder', error, 
        stackTrace: stackTrace, context: {...});
      rethrow;
    }
  }
}
```

#### Request Dispatcher
```dart
class DispatcherService with LoggerMixin {
  void dispatch(DsRequest request) {
    final requestId = _generateRequestId();
    final stopwatch = Stopwatch()..start();
    
    DsLogger.logRequest('INVOKE', request.path, requestId: requestId);
    
    try {
      // ... handle request
      
      DsLogger.logResponse('INVOKE', request.path, 
        requestId: requestId, duration: stopwatch.elapsed, success: true);
        
    } catch (error, stackTrace) {
      DsLogger.logError('Request failed', error, 
        stackTrace: stackTrace, context: {'requestId': requestId});
    }
  }
}
```

## Best Practices Implemented

### 1. **Structured Logging**
- All log messages include relevant context and metadata
- Consistent format across all components
- Machine-readable log entries for automated processing

### 2. **Performance Monitoring**
- Built-in timing measurements for critical operations
- Context-aware performance metrics
- Automatic performance degradation detection

### 3. **Error Handling**
- Comprehensive error context capture
- Stack trace preservation
- Error correlation with operations

### 4. **Security Logging**
- Dedicated security event tracking
- Authentication and authorization logging
- Audit trail maintenance

### 5. **Request Correlation**
- Unique request IDs for end-to-end tracing
- Request/response lifecycle tracking
- Cross-component correlation

### 6. **Configuration Management**
- Environment-specific configurations
- Runtime configuration updates
- Logging level management

## Testing

Comprehensive test coverage includes:

- Logger initialization and configuration
- LoggerMixin functionality
- Structured logging methods
- Environment configuration parsing
- Log level filtering
- Performance logging accuracy
- Error logging with context

Run tests with:
```bash
dart test test/logging_test.dart
```

## Examples

### Development Setup
```dart
import 'package:dsalink/utils/logging_config.dart';

void main() {
  // Quick development setup
  LoggingManager.configureForDevelopment();
  
  // Your application code here
}
```

### Production Setup
```dart
import 'package:dsalink/utils/logging_config.dart';

void main() {
  // Production configuration
  LoggingManager.configureForProduction();
  
  // Your application code here
}
```

### Custom Configuration
```dart
import 'package:dsalink/utils/logging_config.dart';

void main() {
  // Custom configuration
  final config = LoggingConfig(
    level: Level.WARNING,
    enableConsoleOutput: false,
    enablePerformanceLogging: true,
    disabledLoggers: ['VerboseComponent'],
  );
  LoggingManager.configure(config);
  
  // Your application code here
}
```

## Migration Guide

### From Print Statements
**Before:**
```dart
print('🔄 Connecting to WebSocket: $wsUri');
```

**After:**
```dart
DsLogger.logConnection('connecting', wsUri.toString(), 
  component: 'WebSocketResponder');
```

### From Simple Logging
**Before:**
```dart
logger.info('Request completed');
```

**After:**
```dart
DsLogger.logResponse('GET', '/path', 
  requestId: requestId, 
  duration: stopwatch.elapsed, 
  success: true);
```

## Benefits

### 🔍 **Improved Debugging**
- Rich context in every log message
- Request correlation across components
- Performance bottleneck identification

### 🛡️ **Enhanced Security**
- Comprehensive audit trails
- Security event monitoring
- Authentication/authorization tracking

### 📈 **Better Monitoring**
- Performance metrics collection
- Error rate tracking
- System health indicators

### 🎯 **Production Ready**
- Environment-specific configurations
- Minimal performance overhead
- Structured data for log aggregation

## File Structure

```
lib/
├── utils/
│   ├── logger.dart                 # Core logging utilities
│   └── logging_config.dart         # Configuration management
├── websocket/
│   └── websocket_responder.dart    # Updated with logging
├── transport/
│   └── websocket_transport.dart    # Updated with logging
├── responder/
│   └── responder_service.dart      # Updated with logging
└── requester/
    └── dispatcher_service.dart     # Updated with logging

example/
├── logging_best_practices.dart     # Comprehensive logging examples
├── stream_update_node.dart         # Updated with logging
└── node_serializer.dart           # Updated with logging

test/
└── logging_test.dart              # Comprehensive test suite
```

## Dependencies

- `logging: ^1.2.0` - Core Dart logging framework

## Conclusion

The logging implementation in the DSALink SDK provides a robust, scalable, and production-ready foundation for observability. It follows industry best practices while being easy to use and configure for different environments and use cases.

The structured approach ensures that logs are not just debugging aids but valuable data sources for monitoring, security, and performance analysis in production systems.