# Logging Best Practices for DSALink SDK

The DSALink SDK includes a comprehensive, production-ready logging system that follows industry best practices. This guide covers everything you need to know about effective logging in your DSA applications.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Core Concepts](#core-concepts)
3. [Configuration](#configuration)
4. [Log Levels](#log-levels)
5. [Structured Logging](#structured-logging)
6. [Categorized Logging](#categorized-logging)
7. [Error Handling](#error-handling)
8. [Performance Considerations](#performance-considerations)
9. [Best Practices](#best-practices)
10. [Examples](#examples)

## Quick Start

```dart
import 'package:dsalink/utils/logger.dart';

// Basic usage
final logger = DSALogger.instance;
logger.info('Application started');
logger.error('Something went wrong', error: exception);

// Or use convenience functions
logInfo('Quick info message');
logError('Quick error message', error: exception);
```

## Core Concepts

### Logger Architecture

The DSALink logger is built around several key concepts:

- **Singleton Pattern**: Global logger instance for consistency
- **Categorization**: Component-specific loggers for organization
- **Structured Logging**: Machine-readable JSON format support
- **Performance Optimization**: Early filtering and efficient formatting
- **IDE Integration**: Uses `dart:developer` for better tooling support

### Log Entry Structure

Each log entry contains:
- **Level**: Severity (trace, debug, info, warn, error, fatal)
- **Message**: Human-readable description
- **Timestamp**: When the event occurred
- **Category**: Component or module identifier
- **Context**: Additional structured data
- **Error**: Exception object (if applicable)
- **Stack Trace**: Call stack for debugging
- **Location**: File and line number (if enabled)

## Configuration

### Environment-Specific Configurations

```dart
// Development - verbose with location info
DSALogger.configure(LoggerConfig.dev);

// Production - structured, less verbose
DSALogger.configure(LoggerConfig.production);

// Testing - minimal output
DSALogger.configure(LoggerConfig.minimal);
```

### Custom Configuration

```dart
DSALogger.configure(const LoggerConfig(
  level: LogLevel.info,
  includeTimestamp: true,
  includeLocation: false,
  useColors: true,
  useEmojis: true,
  structuredLogging: false,
  customFormatter: myCustomFormatter,
  outputSink: myFileSink,
));
```

### Configuration Options

| Option | Description | Default | Dev | Production | Minimal |
|--------|-------------|---------|-----|------------|---------|
| `level` | Minimum log level | `info` | `debug` | `info` | `warn` |
| `includeTimestamp` | Show timestamps | `true` | `true` | `true` | `false` |
| `includeLocation` | Show file:line | `false` | `true` | `false` | `false` |
| `useColors` | Terminal colors | `true` | `true` | `true` | `false` |
| `useEmojis` | Emoji indicators | `true` | `true` | `false` | `false` |
| `structuredLogging` | JSON format | `false` | `false` | `true` | `false` |

## Log Levels

### Level Hierarchy

```
TRACE (0) - Most verbose, detailed debugging
DEBUG (1) - Debug information  
INFO  (2) - General information
WARN  (3) - Warning messages
ERROR (4) - Error conditions
FATAL (5) - Critical errors
```

### When to Use Each Level

#### TRACE
- Detailed function entry/exit
- Variable state changes
- Loop iterations
- Protocol-level debugging

```dart
logger.trace('Processing message', context: {
  'messageId': msg.id,
  'messageType': msg.type,
  'payloadSize': msg.payload.length,
});
```

#### DEBUG
- Configuration loading
- Connection establishment
- Request/response processing
- Component initialization

```dart
logger.debug('WebSocket connection established', context: {
  'endpoint': wsUri,
  'protocol': 'DSA',
});
```

#### INFO
- Application lifecycle events
- Successful operations
- Key business events
- Performance milestones

```dart
logger.info('Node subscription created', context: {
  'path': nodePath,
  'subscriberId': subId,
  'queueSize': queue.length,
});
```

#### WARN
- Deprecated API usage
- Recoverable errors
- Performance degradation
- Configuration issues

```dart
logger.warn('High memory usage detected', context: {
  'usedMemory': '850MB',
  'totalMemory': '1GB',
  'threshold': '80%',
});
```

#### ERROR
- Operation failures
- Network timeouts
- Data validation errors
- Unexpected conditions

```dart
logger.error('Failed to process request', 
  error: exception,
  stackTrace: stackTrace,
  context: {
    'requestId': req.id,
    'endpoint': req.path,
    'retryCount': retries,
  }
);
```

#### FATAL
- System crashes
- Critical resource exhaustion
- Security violations
- Unrecoverable errors

```dart
logger.fatal('Database connection pool exhausted',
  error: poolException,
  context: {
    'activeConnections': pool.active,
    'maxConnections': pool.max,
    'waitingRequests': pool.pending,
  }
);
```

## Structured Logging

### Benefits

- Machine-readable format
- Easy log aggregation
- Better querying capabilities
- Consistent structure

### JSON Format

```dart
DSALogger.configure(const LoggerConfig(structuredLogging: true));

logger.info('API request processed', context: {
  'method': 'POST',
  'path': '/api/nodes',
  'statusCode': 200,
  'responseTime': 150,
  'userAgent': 'DSALink/3.0.0',
  'requestId': 'req-123-456',
});

// Output: {"level":"INFO","message":"API request processed","timestamp":"2023-01-01T12:00:00.000","context":{"method":"POST","path":"/api/nodes",...}}
```

### Context Best Practices

```dart
// Good: Use meaningful keys and primitive values
logger.info('User authenticated', context: {
  'userId': user.id,
  'email': user.email,
  'roles': user.roles,
  'sessionId': session.id,
  'loginMethod': 'oauth',
});

// Avoid: Complex objects that don't serialize well
logger.info('User data', context: {
  'user': userObject, // This might not serialize properly
});
```

## Categorized Logging

### Creating Category Loggers

```dart
class WebSocketHandler {
  static final _logger = DSALogger.category('WebSocket');
  
  void handleConnection() {
    _logger.info('New connection established');
  }
}

class DatabaseService {
  static final _logger = DSALogger.category('Database');
  
  Future<void> connect() async {
    _logger.debug('Connecting to database');
    // ...
  }
}
```

### Category Naming Conventions

- Use PascalCase: `WebSocket`, `Database`, `AuthService`
- Be descriptive but concise
- Use hierarchical names for sub-components: `Transport.WebSocket`, `Storage.Cache`

## Error Handling

### Comprehensive Error Logging

```dart
Future<void> processRequest(Request request) async {
  final logger = DSALogger.category('RequestProcessor');
  
  try {
    logger.info('Processing request', context: {
      'requestId': request.id,
      'type': request.type,
      'priority': request.priority,
    });
    
    // Process request...
    
    logger.info('Request processed successfully', context: {
      'requestId': request.id,
      'duration': stopwatch.elapsedMilliseconds,
    });
  } catch (error, stackTrace) {
    logger.error(
      'Request processing failed',
      error: error,
      stackTrace: stackTrace,
      context: {
        'requestId': request.id,
        'type': request.type,
        'stage': 'validation', // Where it failed
        'inputSize': request.data.length,
      },
    );
    rethrow;
  }
}
```

### Error Context Guidelines

Include in error context:
- **Request/operation identifiers**
- **Input parameters** (sanitized)
- **Current state** information
- **Retry attempts** or previous errors
- **Resource usage** if relevant

## Performance Considerations

### Early Filtering

```dart
// The logger automatically filters based on configured level
// This trace call does nothing if level > trace
logger.trace('Expensive debug info: ${expensiveComputation()}');

// For expensive context creation, check level first
if (DSALogger.config.level <= LogLevel.debug) {
  logger.debug('Debug info', context: {
    'expensiveData': computeExpensiveDebugData(),
  });
}
```

### Performance Logging

```dart
Future<void> criticalOperation() async {
  final logger = DSALogger.category('Performance');
  final stopwatch = Stopwatch()..start();
  
  logger.debug('Starting critical operation');
  
  try {
    // Perform operation
    await performOperation();
    
    stopwatch.stop();
    logger.info('Operation completed', context: {
      'duration': '${stopwatch.elapsedMilliseconds}ms',
      'operation': 'data_processing',
      'recordsProcessed': records.length,
    });
  } catch (error) {
    stopwatch.stop();
    logger.error('Operation failed', 
      error: error,
      context: {
        'duration': '${stopwatch.elapsedMilliseconds}ms',
        'operation': 'data_processing',
        'recordsProcessed': records.length,
      }
    );
    rethrow;
  }
}
```

## Best Practices

### 1. Use Appropriate Log Levels

```dart
// Good: Informative but not verbose
logger.info('WebSocket connection established');

// Bad: Too verbose for normal operation
logger.info('Setting variable x to value 42');
```

### 2. Include Relevant Context

```dart
// Good: Provides actionable information
logger.warn('API rate limit approaching', context: {
  'currentRate': 45,
  'limit': 50,
  'timeWindow': '1 minute',
  'endpoint': '/api/data',
});

// Bad: Vague and unhelpful
logger.warn('Rate limit issue');
```

### 3. Log at Operation Boundaries

```dart
class DataProcessor {
  static final _logger = DSALogger.category('DataProcessor');
  
  Future<void> processData(List<DataItem> items) async {
    _logger.info('Starting data processing', context: {
      'itemCount': items.length,
      'batchId': batchId,
    });
    
    try {
      // Processing logic...
      
      _logger.info('Data processing completed', context: {
        'itemCount': items.length,
        'processedCount': processed.length,
        'errorCount': errors.length,
        'duration': stopwatch.elapsedMilliseconds,
      });
    } catch (error, stackTrace) {
      _logger.error('Data processing failed',
        error: error,
        stackTrace: stackTrace,
        context: {
          'itemCount': items.length,
          'processedCount': processed.length,
        }
      );
      rethrow;
    }
  }
}
```

### 4. Sanitize Sensitive Data

```dart
// Good: Log structure without sensitive content
logger.info('User login attempt', context: {
  'email': user.email.replaceAll(RegExp(r'(?<=.{2}).(?=.*@)'), '*'),
  'ipAddress': request.clientIp,
  'userAgent': request.userAgent,
});

// Bad: Logging sensitive information
logger.info('User login', context: {
  'email': user.email,
  'password': user.password, // Never log passwords!
});
```

### 5. Use Consistent Formatting

```dart
// Good: Consistent naming and structure
logger.info('Request started', context: {
  'requestId': req.id,
  'method': req.method,
  'path': req.path,
});

logger.info('Request completed', context: {
  'requestId': req.id,
  'statusCode': response.statusCode,
  'duration': duration,
});

// Bad: Inconsistent structure
logger.info('Starting request ${req.id}');
logger.info('Done with ${req.id}, took ${duration}ms, status: ${response.statusCode}');
```

## Examples

### Complete Component Example

```dart
import 'package:dsalink/utils/logger.dart';

class ConnectionManager {
  static final _logger = DSALogger.category('ConnectionManager');
  
  final Map<String, Connection> _connections = {};
  
  Future<Connection> createConnection(String endpoint) async {
    final connectionId = generateId();
    
    _logger.info('Creating connection', context: {
      'connectionId': connectionId,
      'endpoint': endpoint,
      'existingConnections': _connections.length,
    });
    
    try {
      final connection = await _establishConnection(endpoint);
      _connections[connectionId] = connection;
      
      _logger.info('Connection established', context: {
        'connectionId': connectionId,
        'endpoint': endpoint,
        'totalConnections': _connections.length,
        'connectionTime': connection.establishTime,
      });
      
      return connection;
    } catch (error, stackTrace) {
      _logger.error('Failed to establish connection',
        error: error,
        stackTrace: stackTrace,
        context: {
          'connectionId': connectionId,
          'endpoint': endpoint,
          'errorType': error.runtimeType.toString(),
        }
      );
      rethrow;
    }
  }
  
  void closeConnection(String connectionId) {
    final connection = _connections[connectionId];
    if (connection == null) {
      _logger.warn('Attempted to close non-existent connection', context: {
        'connectionId': connectionId,
        'existingConnections': _connections.keys.toList(),
      });
      return;
    }
    
    _logger.debug('Closing connection', context: {
      'connectionId': connectionId,
      'endpoint': connection.endpoint,
      'uptime': connection.uptime,
    });
    
    connection.close();
    _connections.remove(connectionId);
    
    _logger.info('Connection closed', context: {
      'connectionId': connectionId,
      'remainingConnections': _connections.length,
    });
  }
  
  Future<void> _establishConnection(String endpoint) async {
    // Implementation details...
  }
}
```

### Testing with Logger

```dart
import 'package:test/test.dart';
import 'package:dsalink/utils/logger.dart';

void main() {
  group('Logger Tests', () {
    setUp(() {
      // Use minimal config for testing
      DSALogger.configure(LoggerConfig.minimal);
    });
    
    test('should handle errors gracefully', () {
      final logger = DSALogger.category('Test');
      
      // This should not throw
      expect(() {
        logger.info('Test message', context: null);
        logger.error('Error message', error: null);
      }, returnsNormally);
    });
  });
}
```

## Migration from print() Statements

If you're migrating from `print()` statements:

```dart
// Before
print('🔐 Performing handshake...');
print('🔄 Connecting to WebSocket: $wsUri');
print('✅ DSLink Responder connected & running!');

// After
final logger = DSALogger.category('WebSocketResponder');
logger.info('Performing handshake with broker', context: {
  'brokerUrl': brokerBaseUrl,
  'linkName': linkName,
});
logger.info('Connecting to WebSocket', context: {
  'wsUri': wsUri.toString(),
});
logger.info('DSLink Responder connected & running successfully');
```

## Troubleshooting

### Common Issues

1. **No log output**: Check if log level is too high
2. **Performance issues**: Ensure expensive operations are guarded by level checks
3. **Missing context**: Verify context serialization works for your data types
4. **IDE integration**: Make sure you're using `dart:developer` output in your IDE

### Debug Configuration

```dart
// Enable verbose logging for debugging
DSALogger.configure(const LoggerConfig(
  level: LogLevel.trace,
  includeLocation: true,
  includeTimestamp: true,
  useColors: true,
  useEmojis: true,
));
```

This logging system provides a robust foundation for observability in your DSA applications. Use it consistently throughout your codebase for better debugging, monitoring, and maintenance.