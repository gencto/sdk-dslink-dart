# DSALink SDK for Dart

DSALink SDK for Dart

## Getting Started

### Prerequisites

- [Git](https://git-scm.com/downloads)
- [Dart SDK](https://www.dartlang.org/downloads/)

### Install

```bash
pub global activate -sgit https://github.com/gencto/sdk-dsalink-dart.git # Globally install the DSA Broker
```

### Start a Broker

```bash
dsbroker # If you have the pub global executable path setup.
pub global run dsbroker:broker # If you do not have the pub global executable path setup.
```

You can edit the server configuration using `broker.json`. For more information about broker configuration, see [this page](https://github.com/IOT-DSA/sdk-dsalink-dart/wiki/Configuring-a-Broker).

### Create a Link

For documentation, see [this page](https://iot-dsa.github.io/docs/sdks/dart/).
For more examples, see [this page](https://github.com/IOT-DSA/sdk-dsalink-dart/tree/master/example).

```dart
import "package:dsalink/dsalink.dart";

LinkProvider link;

main(List<String> args) async {
  // Process the arguments and initializes the default nodes.
  link = new LinkProvider(args, "Simple-", defaultNodes: {
    "Message": {
      r"$type": "string", // The type of the node is a string.
      r"$writable": "write", // This node's value can be set by a responder link.
      "?value": "Hello World" // The default message value.
    }
  });

  // Connect to the broker.
  link.connect();

  // Save the message when it changes.
  link.onValueChange("/Message").listen((_) => link.save());
}
```

### Start a Link

```bash
dart path/to/link.dart # Start a link that connects to a broker at https://127.0.0.1:8443/conn
dart path/to/link.dart --broker https://my.broker:8443/conn # Start a link that connects to the specified broker.
```

## Logging

The DSALink SDK includes a comprehensive logging system with best practices built-in:

### Basic Usage

```dart
import "package:dsalink/utils/logger.dart";

// Use the global logger
final logger = DSALogger.instance;
logger.info('Application started');
logger.error('Something went wrong', error: exception, stackTrace: stackTrace);

// Or use convenience functions
logInfo('Quick info message');
logError('Quick error message', error: exception);
```

### Categorized Logging

```dart
// Create category-specific loggers
final webSocketLogger = DSALogger.category('WebSocket');
final responderLogger = DSALogger.category('Responder');

webSocketLogger.info('Connection established');
responderLogger.debug('Processing request', context: {
  'requestId': '123',
  'path': '/nodes/sensor',
});
```

### Configuration

```dart
// Development - verbose with location info
DSALogger.configure(LoggerConfig.dev);

// Production - structured JSON logging
DSALogger.configure(LoggerConfig.production);

// Custom configuration
DSALogger.configure(const LoggerConfig(
  level: LogLevel.info,
  includeTimestamp: true,
  structuredLogging: false,
  useColors: true,
));
```

### Log Levels

- `trace` - Most verbose, for detailed debugging
- `debug` - Debug information
- `info` - General information
- `warn` - Warning messages
- `error` - Error conditions
- `fatal` - Critical errors

### Features

- **Structured Logging**: JSON format for production systems
- **Contextual Information**: Attach metadata to log entries
- **Performance Optimized**: Early filtering and efficient formatting
- **Environment Aware**: Different configs for dev/prod/test
- **IDE Integration**: Uses `dart:developer` for better tooling support
- **Categorization**: Organize logs by component/module
- **Error Handling**: Proper error and stack trace logging

See `example/logging_example.dart` for comprehensive usage examples.

## Links

- [DSA Site](https://dsa.gencto.uk/)
- [DSA Wiki](https://github.com/IOT-DSA/docs/wiki)
- [Documentation](https://iot-dsa.github.io/docs/sdks/dart/)
