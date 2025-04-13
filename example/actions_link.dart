import 'package:dslink/dslink.dart';

late LinkProvider? link;

void main(List<String> args) async {
  // Process the arguments and initializes the default nodes.
  link = LinkProvider(['--broker', 'http://127.0.0.1:8080/conn'], 'Actions-',
      defaultNodes: <String, dynamic>{
        'message': {
          r'$name': 'Message', // The pretty name of this node.
          r'$type': 'string', // The type of the node is a string.
          r'$writable': 'write', // This node's value can be set by a requester.
          '?value': 'Hello World', // The default message value.
          'reset': {
            // An action on the message node.
            r'$name': 'Reset', // The pretty name of this action.
            r'$is': 'reset', // This node takes on the 'reset' profile.
            r'$invokable':
                'write', // Invoking this action requires write permissions.
            r'$params':
                <dynamic>[], // This action does not have any parameters.
            r'$result': 'values', // This action returns a single row of values.
            r'$columns':
                <dynamic>[] // This action does not return any actual values.
          },
          'add': {
            // An action on the message node.
            r'$name': 'Add', // The pretty name of this action.
            r'$is': 'add', // This node takes on the 'reset' profile.
            r'$invokable':
                'write', // Invoking this action requires write permissions.
            r'$params': [
              {'name': 'name', 'type': 'string'},
            ], // This action does not have any parameters.
            r'$result': 'values', // This action returns a single row of values.
            r'$columns':
                <dynamic>[] // This action does not return any actual values.
          }
        }
      },
      profiles: {
        'reset': (String path) => ResetNode(path),
        'add': (String path) => ControllerNode(
            path) // The reset profile should use this function to create the node object.
      },
      encodePrettyJson: true,
      defaultLogLevel: 'DEBUG');

  // Connect to the broker.
  link?.init();

  await link?.connect();
  updateLogLevel('debug');

  // Save the message when it changes.
  // if (link != null && link!.valuePersistenceEnabled) {
  //   link?.onValueChange("/message").listen((update) => link?.save());
  // }
}

// A simple node that resets the message value.
class ResetNode extends SimpleNode {
  ResetNode(String path, [SimpleNodeProvider? provider])
      : super(path, provider) {
    print('========= CREATE RESET =========');
  }

  @override
  Future<Map> onInvoke(Map params) async {
    link!.updateValue('/message', 'Hello World');
    // Update the value of the message node.

    return <String, dynamic>{}; // Return an empty row of values.
  }
}

class ControllerNode extends SimpleNode {
  ControllerNode(String path, [SimpleNodeProvider? provider])
      : super(path, provider) {
    print('========= CREATE CONTROLLER =========');
  }
  @override
  void onInvoke(Map params) {
    link?.addNode(('/' + params['name']).toString(), <String, dynamic>{
      r'$name': params['name'],
      r'$writable': 'write',
      'reset': {
        // An action on the message node.
        r'$name': 'Reset', // The pretty name of this action.
        r'$is': 'reset', // This node takes on the 'reset' profile.
        r'$invokable':
            'write', // Invoking this action requires write permissions.
        r'$params': <dynamic>[], // This action does not have any parameters.
        r'$result': 'values', // This action returns a single row of values.
        r'$columns':
            <dynamic>[] // This action does not return any actual values.
      },
      'add': {
        // An action on the message node.
        r'$name': 'Add', // The pretty name of this action.
        r'$is': 'add', // This node takes on the 'reset' profile.
        r'$invokable':
            'write', // Invoking this action requires write permissions.
        r'$params': [
          {'name': 'name', 'type': 'string'},
        ], // This action does not have any parameters.
        r'$result': 'values', // This action returns a single row of values.
        r'$columns':
            <dynamic>[] // This action does not return any actual values.
      }
    });
  }
}
