import "package:dslink/dslink.dart";

late LinkProvider link;

main(List<String> args) async {
  link = new LinkProvider(
    ['--broker', 'http://localhost:8080/conn',],
    "Simple-Requester-", // DSLink Prefix
    defaultLogLevel: "DEBUG",
    isResponder: false,
    isRequester: true, // We are just a requester.
  );

  link.connect(); // Connect to the broker.
  Requester? requester =
      await link.onRequesterReady; // Wait for the requester to be ready.

  await for (RequesterListUpdate update in requester!.list("/data")) {
    // List the nodes in /
    for (var n in update.node.children.values) {
      var newN = n as RemoteNode;
      print(newN.remotePath);
      // Print the path of each node.
    }
  } // This will not end until you break the for loop. Whenever a node is added or removed to/from the given path, it will receive an update.
}
