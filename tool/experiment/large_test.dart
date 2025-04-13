import 'dart:async';
import 'dart:math';

import 'package:dsalink/dsalink.dart';
import 'package:dsalink/nodes.dart';

late LinkProvider link;

int current = 0;

void main() {
  link = LinkProvider(
    ['--broker', 'https://127.0.0.1/conn'],
    'Large-1',
    defaultNodes: <String, dynamic>{
      'Generate': {
        r'$invokable': 'write',
        r'$is': 'generate',
        r'$params': [
          {'name': 'count', 'type': 'number', 'default': 50},
        ],
      },
      'Reduce': {
        r'$invokable': 'write',
        r'$is': 'reduce',
        r'$params': [
          {'name': 'target', 'type': 'number', 'default': 1},
        ],
      },
      'Tick_Rate': {
        r'$name': 'Tick Rate',
        r'$type': 'number',
        r'$writable': 'write',
        '?value': 300,
      },
      'RNG_Maximum': {
        r'$name': 'Maximum Random Number',
        r'$type': 'number',
        r'$writable': 'write',
        '?value': max,
      },
    },
    profiles: {
      'generate':
          (String path) => SimpleActionNode(path, (Map params) {
            int count = params['count'] ?? 50;
            generate(count);
          }),
      'reduce':
          (String path) => SimpleActionNode(path, (Map params) {
            int target = params['target'] ?? 1;
            for (var name
                in link['/']!.children.keys
                    .where((it) => it.startsWith('Node_'))
                    .toList()) {
              link.removeNode('/$name');
            }
            generate(target);
          }),
      'test': (String path) {
        late CallbackNode node;

        node = CallbackNode(
          path,
          onCreated: () {
            nodes.add(node);
          },
          onRemoving: () {
            nodes.remove(node);
          },
        );

        return node;
      },
    },
  );

  link.onValueChange('/Tick_Rate').listen((ValueUpdate u) {
    if (schedule != null) {
      schedule?.cancel();
      schedule = null;
    }

    schedule = Scheduler.every(
      Interval.forMilliseconds(u.value as int),
      update,
    );
  });

  link.onValueChange('/RNG_Maximum').listen((ValueUpdate u) {
    max = u.value as int;
  });

  link.connect();

  schedule = Scheduler.every(Interval.THREE_HUNDRED_MILLISECONDS, update);
}

Timer? schedule;
int max = 100;

void update() {
  nodes.forEach((node) {
    var l = link['${node.path}/RNG/Value'];
    if (l!.hasSubscriber) {
      l.updateValue(random.nextInt(max));
    }
  });
}

Random random = Random();
List<SimpleNode> nodes = [];

void generate(int count) {
  for (var i = 1; i <= count; i++) {
    link.addNode('/Node_$i', <String, dynamic>{
      r'$is': 'test',
      r'$name': 'Node $i',
      'Values': {
        'String_Value': {
          r'$name': 'String Value',
          r'$type': 'string',
          r'$writable': 'write',
          '?value': 'Hello World',
        },
        'Number_Value': {
          r'$name': 'Number Value',
          r'$type': 'number',
          r'$writable': 'write',
          '?value': 5.0,
        },
        'Integer_Value': {
          r'$name': 'Integer Value',
          r'$type': 'number',
          r'$writable': 'write',
          '?value': 5,
        },
      },
      'RNG': {
        'Value': {r'$type': 'number', '?value': 0.0},
      },
    });
    current++;
  }
}
