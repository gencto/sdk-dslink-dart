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

#### Using NodeBuilder (Recommended)

The modern, type-safe way to create nodes using the fluent NodeBuilder API:

```dart
import "package:dsalink/dsalink.dart";

LinkProvider link;

main(List<String> args) async {
  // Process the arguments and initializes the default nodes.
  link = LinkProvider(args, "Simple-", defaultNodes: {
    "Message": NodeBuilder.value('string')
      .name('Message')
      .writable()
      .value('Hello World')
      .icon('message')
      .build(),
  });

  // Connect to the broker.
  await link.connect();

  // Save the message when it changes (using async version).
  link.onValueChange("/Message").listen((_) => link.saveAsync());
}
```

**Benefits of NodeBuilder:**
- Type-safe configuration with IDE autocomplete
- Eliminates typos in magic strings like `r'$type'`, `r'$writable'`
- Cleaner, more readable code with method chaining
- Backwards compatible - builds standard `Map<String, dynamic>` configs

**NodeBuilder Examples:**

```dart
// Simple value node
var temperatureNode = NodeBuilder.value('number')
  .name('Temperature')
  .writable()
  .value(23.5)
  .unit('°C')
  .icon('temperature')
  .build();

// Action node with parameters and results
var sendEmailAction = NodeBuilder.action()
  .name('Send Email')
  .invokable('write')
  .param('to', 'string', placeholder: 'user@example.com')
  .param('subject', 'string')
  .param('body', 'string')
  .column('success', 'bool')
  .column('messageId', 'string')
  .build();

// Node with nested actions
var messageNode = NodeBuilder.value('string')
  .name('Message')
  .writable()
  .value('Hello')
  .child('reset', NodeBuilder.action()
    .name('Reset')
    .invokable('write')
    .build())
  .build();
```

#### Traditional Map-Based Approach

You can still use the traditional map-based approach if needed:

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
  link.onValueChange("/Message").listen((_) => link.saveAsync());
}
```

### Start a Link

```bash
dart path/to/link.dart # Start a link that connects to a broker at https://127.0.0.1:8443/conn
dart path/to/link.dart --broker https://my.broker:8443/conn # Start a link that connects to the specified broker.
```

## Links

- [DSA Site](https://dsa.gencto.uk/)
- [DSA Wiki](https://github.com/IOT-DSA/docs/wiki)
- [Documentation](https://iot-dsa.github.io/docs/sdks/dart/)
