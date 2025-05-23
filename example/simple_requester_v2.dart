import 'package:dsalink/dsalink.dart';
import 'package:dsalink/nodes.dart';

LinkProvider? link;

void main(List<String> args) async {
  link = LinkProvider(
    ['--broker', 'http://127.0.0.1:8080/conn'],
    'Requester-s',
    defaultNodes: <String, dynamic>{
      'Get': {
        r'$is': 'get',
        r'$invokable': 'read',
        r'$params': [
          {'name': 'node', 'type': 'string'},
        ],
        r'$result': 'table',
        r'$columns': [
          {'name': 'key', 'type': 'string'},
          {'name': 'value', 'type': 'dynamic'},
        ],
      },
      'List': {
        r'$is': 'list',
        r'$invokable': 'read',
        r'$params': [
          {'name': 'node', 'type': 'string'},
          {'name': 'excludeActions', 'type': 'bool', 'default': false},
          {'name': 'findChildren', 'type': 'bool', 'default': false},
        ],
        r'$result': 'table',
        r'$columns': [
          {'name': 'name', 'type': 'string'},
          {'name': 'path', 'type': 'string'},
          {'name': 'configs', 'type': 'map'},
          {'name': 'attributes', 'type': 'map'},
          {'name': 'hasChildren', 'type': 'bool', 'default': false},
        ],
      },
    },
    isRequester: true,
    profiles: {
      'get':
          (String path) => SimpleActionNode(path, (Map params) async {
            String path = params['node'];
            var update = await link!.requester!.list(path).first;
            var list = <dynamic>[];
            for (var key in update.node.configs.keys) {
              list.add(<String, dynamic>{
                'key': key,
                'value': update.node.configs[key],
              });
            }

            for (var key in update.node.attributes.keys) {
              list.add({'key': key, 'value': update.node.attributes[key]});
            }

            for (var key in update.node.children.keys) {
              list.add({
                'key': key,
                'value': update.node.children[key]?.getSimpleMap(),
              });
            }

            return list;
          }, link?.provider as SimpleNodeProvider?),
      'list':
          (String path) => SimpleActionNode(path, (Map params) async {
            String path = params['node'];
            var update = await link?.requester?.list(path).first;
            var list = <dynamic>[];
            for (var key in update!.node.children.keys) {
              var value = update.node.children[key];

              if (value!.configs.containsKey(r'$invokable') &&
                  params['excludeActions'] == true) {
                continue;
              }

              bool doesHaveChildren = false;

              var pm = '${update.node.remotePath}/${key}';

              if (pm.startsWith('//')) {
                pm = pm.substring(1);
              }

              if (params['findChildren'] == true) {
                doesHaveChildren = await doesNodeHaveChildren(pm);
              }

              list.add({
                'name': key,
                'path': pm,
                'configs': value.configs,
                'attributes': value.attributes,
                'hasChildren': doesHaveChildren,
              });
            }

            return list;
          }, link!.provider as SimpleNodeProvider?),
    },
    autoInitialize: false,
    encodePrettyJson: true,
  );
  UpdateLogLevel('debug');
  link?.init();
  link?.connect();
}

Future<bool> doesNodeHaveChildren(String path) async {
  RequesterListUpdate? update = await link?.requester?.list(path).first;
  return update?.node.children.isNotEmpty ?? false;
}
