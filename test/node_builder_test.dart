import 'package:dsalink/common.dart';
import 'package:test/test.dart';

void main() {
  group('NodeBuilder', () {
    group('Basic Construction', () {
      test('empty builder creates empty config', () {
        final config = NodeBuilder().build();
        expect(config, isA<Map<String, dynamic>>());
        expect(config, isEmpty);
      });

      test('value factory sets type correctly', () {
        final config = NodeBuilder.value('string').build();
        expect(config[r'$type'], equals('string'));
      });

      test('action factory sets invokable to read', () {
        final config = NodeBuilder.action().build();
        expect(config[r'$invokable'], equals('read'));
      });
    });

    group('Type Configuration', () {
      test(r'type() sets $type config', () {
        final config = NodeBuilder().type('number').build();
        expect(config[r'$type'], equals('number'));
      });

      test('type() can be chained', () {
        final config = NodeBuilder()
            .type('string')
            .name('Test')
            .build();
        expect(config[r'$type'], equals('string'));
        expect(config[r'$name'], equals('Test'));
      });
    });

    group('Name Configuration', () {
      test(r'name() sets $name config', () {
        final config = NodeBuilder().name('My Node').build();
        expect(config[r'$name'], equals('My Node'));
      });
    });

    group('Permissions', () {
      test(r'writable() sets $writable with default permission', () {
        final config = NodeBuilder().writable().build();
        expect(config[r'$writable'], equals('write'));
      });

      test('writable() accepts custom permission', () {
        final config = NodeBuilder().writable('config').build();
        expect(config[r'$writable'], equals('config'));
      });

      test(r'invokable() sets $invokable with default permission', () {
        final config = NodeBuilder().invokable().build();
        expect(config[r'$invokable'], equals('read'));
      });

      test('invokable() accepts custom permission', () {
        final config = NodeBuilder().invokable('write').build();
        expect(config[r'$invokable'], equals('write'));
      });
    });

    group('Parameters', () {
      test('param() adds parameter without default', () {
        final config = NodeBuilder()
            .param('name', 'string')
            .build();
        expect(config[r'$params'], isA<List>());
        expect(config[r'$params'], hasLength(1));
        expect(config[r'$params'][0]['name'], equals('name'));
        expect(config[r'$params'][0]['type'], equals('string'));
        expect(config[r'$params'][0], isNot(contains('default')));
      });

      test('param() adds parameter with default value', () {
        final config = NodeBuilder()
            .param('count', 'number', defaultValue: 42)
            .build();
        expect(config[r'$params'][0]['default'], equals(42));
      });

      test('param() adds parameter with placeholder', () {
        final config = NodeBuilder()
            .param('email', 'string', placeholder: 'user@example.com')
            .build();
        expect(config[r'$params'][0]['placeholder'], equals('user@example.com'));
      });

      test('param() adds parameter with description', () {
        final config = NodeBuilder()
            .param('age', 'number', description: 'User age in years')
            .build();
        expect(config[r'$params'][0]['description'], equals('User age in years'));
      });

      test('param() can chain multiple parameters', () {
        final config = NodeBuilder()
            .param('firstName', 'string')
            .param('lastName', 'string')
            .param('age', 'number')
            .build();
        expect(config[r'$params'], hasLength(3));
        expect(config[r'$params'][0]['name'], equals('firstName'));
        expect(config[r'$params'][1]['name'], equals('lastName'));
        expect(config[r'$params'][2]['name'], equals('age'));
      });
    });

    group('Columns', () {
      test('column() adds result column', () {
        final config = NodeBuilder()
            .column('result', 'string')
            .build();
        expect(config[r'$columns'], isA<List>());
        expect(config[r'$columns'], hasLength(1));
        expect(config[r'$columns'][0]['name'], equals('result'));
        expect(config[r'$columns'][0]['type'], equals('string'));
      });

      test('column() can chain multiple columns', () {
        final config = NodeBuilder()
            .column('id', 'number')
            .column('name', 'string')
            .column('active', 'bool')
            .build();
        expect(config[r'$columns'], hasLength(3));
        expect(config[r'$columns'][0]['name'], equals('id'));
        expect(config[r'$columns'][1]['name'], equals('name'));
        expect(config[r'$columns'][2]['name'], equals('active'));
      });
    });

    group('Attributes', () {
      test('value() sets ?value', () {
        final config = NodeBuilder().value('test').build();
        expect(config['?value'], equals('test'));
      });

      test('value() accepts null', () {
        final config = NodeBuilder().value(null).build();
        expect(config['?value'], isNull);
      });

      test('value() accepts numbers', () {
        final config = NodeBuilder().value(42).build();
        expect(config['?value'], equals(42));
      });

      test('icon() sets @icon attribute', () {
        final config = NodeBuilder().icon('my-icon').build();
        expect(config['@icon'], equals('my-icon'));
      });

      test('unit() sets @unit attribute', () {
        final config = NodeBuilder().unit('°C').build();
        expect(config['@unit'], equals('°C'));
      });

      test('description() sets @description attribute', () {
        final config = NodeBuilder()
            .description('Temperature sensor')
            .build();
        expect(config['@description'], equals('Temperature sensor'));
      });
    });

    group('Profile and Result', () {
      test(r'profile() sets $is config', () {
        final config = NodeBuilder().profile('customProfile').build();
        expect(config[r'$is'], equals('customProfile'));
      });

      test(r'hidden() sets $hidden config', () {
        final config = NodeBuilder().hidden().build();
        expect(config[r'$hidden'], isTrue);
      });

      test(r'resultType() sets $result config', () {
        final config = NodeBuilder().resultType('stream').build();
        expect(config[r'$result'], equals('stream'));
      });
    });

    group('Child Nodes', () {
      test('child() adds child node', () {
        final config = NodeBuilder()
            .child('action', {'r\$name': 'My Action'})
            .build();
        expect(config['action'], isA<Map>());
        expect(config['action']['r\$name'], equals('My Action'));
      });

      test('child() can add multiple children', () {
        final config = NodeBuilder()
            .child('reset', {'r\$invokable': 'write'})
            .child('start', {'r\$invokable': 'read'})
            .build();
        expect(config['reset'], isNotNull);
        expect(config['start'], isNotNull);
      });

      test('child() can nest NodeBuilder configs', () {
        final config = NodeBuilder()
            .child(
              'action',
              NodeBuilder.action()
                  .name('Execute')
                  .invokable('write')
                  .build(),
            )
            .build();
        expect(config['action'][r'$name'], equals('Execute'));
        expect(config['action'][r'$invokable'], equals('write'));
      });
    });

    group('Complex Scenarios', () {
      test('creates complete value node', () {
        final config = NodeBuilder.value('number')
            .name('Temperature')
            .writable('write')
            .value(23.5)
            .unit('°C')
            .icon('temperature')
            .description('Room temperature sensor')
            .build();

        expect(config[r'$type'], equals('number'));
        expect(config[r'$name'], equals('Temperature'));
        expect(config[r'$writable'], equals('write'));
        expect(config['?value'], equals(23.5));
        expect(config['@unit'], equals('°C'));
        expect(config['@icon'], equals('temperature'));
        expect(config['@description'], equals('Room temperature sensor'));
      });

      test('creates complete action node', () {
        final config = NodeBuilder.action()
            .name('Send Email')
            .invokable('write')
            .param('to', 'string', placeholder: 'user@example.com')
            .param('subject', 'string')
            .param('body', 'string', description: 'Email body content')
            .column('success', 'bool')
            .column('messageId', 'string')
            .profile('sendEmail')
            .build();

        expect(config[r'$name'], equals('Send Email'));
        expect(config[r'$invokable'], equals('write'));
        expect(config[r'$params'], hasLength(3));
        expect(config[r'$columns'], hasLength(2));
        expect(config[r'$is'], equals('sendEmail'));
      });

      test('creates action with stream results', () {
        final config = NodeBuilder.action()
            .name('Monitor')
            .invokable('read')
            .resultType('stream')
            .column('timestamp', 'string')
            .column('value', 'number')
            .build();

        expect(config[r'$result'], equals('stream'));
        expect(config[r'$columns'], hasLength(2));
      });

      test('creates node with nested actions', () {
        final config = NodeBuilder.value('string')
            .name('Message')
            .writable()
            .value('Hello')
            .child(
              'reset',
              NodeBuilder.action()
                  .name('Reset')
                  .invokable('write')
                  .build(),
            )
            .child(
              'clear',
              NodeBuilder.action()
                  .name('Clear')
                  .invokable('write')
                  .build(),
            )
            .build();

        expect(config[r'$name'], equals('Message'));
        expect(config['reset'][r'$name'], equals('Reset'));
        expect(config['clear'][r'$name'], equals('Clear'));
      });
    });

    group('Constants Usage', () {
      test('uses NodeConfigKeys constants internally', () {
        final config = NodeBuilder()
            .type('string')
            .name('Test')
            .build();

        // Verify the keys match NodeConfigKeys
        expect(config.keys, contains(NodeConfigKeys.type));
        expect(config.keys, contains(NodeConfigKeys.name));
      });

      test('uses NodeAttributeKeys constants internally', () {
        final config = NodeBuilder()
            .icon('test-icon')
            .unit('kg')
            .build();

        // Verify the keys match NodeAttributeKeys
        expect(config.keys, contains(NodeAttributeKeys.icon));
        expect(config.keys, contains(NodeAttributeKeys.unit));
      });

      test('uses NodeValueKey constant internally', () {
        final config = NodeBuilder()
            .value('test')
            .build();

        // Verify the key matches NodeValueKey
        expect(config.keys, contains(NodeValueKey.value));
      });
    });
  });
}
