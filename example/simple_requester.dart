import 'package:dsalink/dsalink.dart';

late LinkProvider link;

void main(List<String> args) async {
  link = LinkProvider(
    ['--broker', 'https://127.0.0.1/conn'],
    'Simple-Requester-', // dsalink Prefix
    defaultLogLevel: 'DEBUG',
    isResponder: false,
    isRequester: true, // We are just a requester.
  );

  await link.connect(); // Connect to the broker.
  var requester =
      await link.onRequesterReady; // Wait for the requester to be ready.

  await for (RequesterListUpdate update in requester.list('/')) {
    // List the nodes in /
    print("- ${update.node.children.keys.join(", ")}");
  } // This will not end until you break the for loop. Whenever a node is added or removed to/from the given path, it will receive an update.
}
