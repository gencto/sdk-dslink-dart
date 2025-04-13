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

For documentation, see [this page](http://iot-dsa.github.io/docs/sdks/dart/).
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
dart path/to/link.dart # Start a link that connects to a broker at http://127.0.0.1:8080/conn
dart path/to/link.dart --broker http://my.broker:8080/conn # Start a link that connects to the specified broker.
```

## Links

- [DSA Site](http://iot-dsa.org/)
- [DSA Wiki](https://github.com/IOT-DSA/docs/wiki)
- [Documentation](http://iot-dsa.github.io/docs/sdks/dart/)
