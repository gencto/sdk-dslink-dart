import 'package:dsalink/dsalink.dart';

late LinkProvider? link;

void main(List<String> args) async {
  // Process the arguments and initializes the default nodes.
  // Using NodeBuilder for cleaner, type-safe node configuration
  link = LinkProvider(
    ['--broker', 'https://127.0.0.1/conn'],
    'Actions-',
    defaultNodes: <String, dynamic>{
      'message': NodeBuilder.value('string')
          .name('Message') // The pretty name of this node.
          .writable() // This node's value can be set by a requester.
          .value('Hello World') // The default message value.
          .child(
            'reset',
            NodeBuilder.action()
                .name('Reset')
                .profile('reset')
                .invokable('write')
                .resultType('values')
                .build(),
          )
          .child(
            'add',
            NodeBuilder.action()
                .name('Add')
                .profile('add')
                .invokable('write')
                .param('name', 'string')
                .resultType('values')
                .build(),
          )
          .build(),
    },
    profiles: {
      'reset': (String path) => ResetNode(path),
      'add':
          (String path) => ControllerNode(
            path,
          ), // The reset profile should use this function to create the node object.
    },
    encodePrettyJson: true,
    defaultLogLevel: 'DEBUG',
  );

  // Connect to the broker.
  link?.init();

  await link?.connect();
  UpdateLogLevel('debug');

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
    // Using NodeBuilder for cleaner, type-safe node configuration
    link?.addNode(
      ('/' + params['name']).toString(),
      NodeBuilder()
          .name(params['name'])
          .writable()
          .child(
            'reset',
            NodeBuilder.action()
                .name('Reset')
                .profile('reset')
                .invokable('write')
                .resultType('values')
                .build(),
          )
          .child(
            'add',
            NodeBuilder.action()
                .name('Add')
                .profile('add')
                .invokable('write')
                .param('name', 'string')
                .resultType('values')
                .build(),
          )
          .build(),
    );
  }
}
