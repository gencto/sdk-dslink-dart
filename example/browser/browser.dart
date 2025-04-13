import 'package:dsalink/browser.dart';
import 'package:dsalink/common.dart';
import 'package:dsalink/nodes.dart';
import 'package:dsalink/utils.dart';
import 'package:web/web.dart'
    show
        HTMLAudioElement,
        MouseEvent,
        document,
        window,
        HTMLElement,
        EventListener;

late LinkProvider link;

final Map<String, String> TRANSITION_TIMES = {
  'Instant': '0s',
  '250ms': '0.25s',
  '500ms': '0.5s',
  '1s': '1s',
  '2s': '2s',
};

Map DEFAULT_NODES = <String, dynamic>{
  'User_Agent': {
    r'$name': 'User Agent',
    r'$type': 'string',
    '?value': window.navigator.userAgent,
  },
  'Page_Color': {
    // Page Background Color
    r'$name': 'Page Color',
    r'$type': 'color',
    r'$writable': 'write',
    '?value': 'blue',
  },
  'Page_Gradient': {
    r'$name': 'Page Gradient',
    r'$type': 'gradient',
    r'$writable': 'write',
    '?value': 'none',
  },
  'Page_Color_Transition_Time': {
    r'$name': 'Page Color Transition Time',
    r'$type': TRANSITION_ENUM,
    r'$writable': 'write',
    '?value': '1s',
  },
  'Text': {
    // Text Message
    r'$name': 'Text',
    r'$type': 'string',
    r'$writable': 'write',
    '?value': 'Hello World',
  },
  'Text_Size_Transition_Time': {
    r'$name': 'Text Size Transition Time',
    r'$type': TRANSITION_ENUM,
    r'$writable': 'write',
    '?value': '1s',
  },
  'Text_Color_Transition_Time': {
    r'$name': 'Text Color Transition Time',
    r'$type': TRANSITION_ENUM,
    r'$writable': 'write',
    '?value': '1s',
  },
  'Text_Color': {
    // Text Color
    r'$name': 'Text Color',
    r'$type': 'color',
    r'$writable': 'write',
    '?value': 'white',
  },
  'Text_Font': {
    r'$name': 'Text Font',
    r'$type': BuildEnumType([
      'Arial',
      'Arial Black',
      'Comic Sans MS',
      'Courier New',
      'Georgia',
      'Impact',
      'Times New Roman',
      'Trebuchet MS',
    ]),
    r'$writable': 'write',
    '?value': 'Arial',
  },
  'Text_Rotation': {
    r'$name': 'Text Rotation',
    r'$type': 'number',
    r'$writable': 'write',
    '?value': 0.0,
  },
  'Text_Size': {
    r'$name': 'Text Size',
    r'$type': 'number',
    r'$writable': 'write',
    '?value': 72,
  },
  'Click': {
    'ID': {r'$type': 'number', '?value': 0},
    'X': {r'$type': 'number', '?value': 0.0},
    'Y': {r'$type': 'number', '?value': 0.0},
  },
  'Text_Hovering': {
    // If the user is currently hovering over the text.
    r'$name': 'Hovering over Text',
    r'$type': 'bool',
    '?value': false,
  },
  'Mouse': {
    // Mouse-related stuff.
    'X': {
      // Mouse X position.
      r'$type': 'number',
      '?value': 0.0,
    },
    'Y': {
      // Mouse y position.
      r'$type': 'number',
      '?value': 0.0,
    },
    'Down': {r'$type': 'bool', '?value': false},
  },
  'Play_Sound': {
    // An action to play a sound.
    r'$name': 'Play Sound',
    r'$is': 'playSound',
    r'$invokable': 'write',
    r'$params': [
      {'name': 'url', 'type': 'string'},
    ],
  },
  'Stop_Sound': {
    r'$name': 'Stop Sound',
    r'$is': 'stopSound',
    r'$invokable': 'write',
  },
};

final String TRANSITION_ENUM = BuildEnumType(TRANSITION_TIMES.keys);

HTMLElement? bodyElement = document.querySelector('#body') as HTMLElement?;
HTMLElement? textElement = document.querySelector('#text') as HTMLElement?;

HTMLAudioElement? audio;

void main() async {
  var brokerUrl = await BrowserUtils.fetchBrokerUrlFromPath(
    'broker_url',
    'https://127.0.0.1/conn',
  );
  link = LinkProvider(
    brokerUrl,
    'Browser-',
    defaultNodes: DEFAULT_NODES,
    profiles: {
      'playSound':
          (String path) => SimpleActionNode(path, (Map params) {
            if (audio != null) {
              audio?.pause();
              audio = null;
            }

            audio = HTMLAudioElement();
            audio?.src = params['url'];
            audio?.play();
          }),
      'stopSound':
          (String path) => SimpleActionNode(path, (Map params) {
            if (audio != null) {
              audio?.pause();
              audio = null;
            }
          }),
    },
  );

  await $.init();

  for (var key in DEFAULT_NODES.keys) {
    if (!link['/']!.children.containsKey(key)) {
      $.addNode(key, DEFAULT_NODES[key]);
    }
  }

  $.onValueChange('/Page_Color').listen((ValueUpdate? update) async {
    // Wait for background color changes.
    var color = update!.value as String?;
    if (color != null) {
      bodyElement
        ?..style.removeProperty('background')
        ..style.backgroundColor = color;
    }
    await $.save();
  });

  $.onValueChange('/Text_Color').listen((ValueUpdate update) async {
    // Wait for text color changes.
    var color = update.value as String;
    try {
      color =
          "#${int.parse(update.value as String).toRadixString(16).padLeft(6, '0')}";
    } catch (e) {
      logger.warning('Invalid color value: $color');
    }
    textElement
      ?..style.color = color
      ..offsetHeight; // Trigger Re-flow
    await $.save();
  });

  $.onValueChange('/Page_Gradient').listen((ValueUpdate update) {
    if (update.value == 'none') {
      return;
    }

    if (update.value == null) {
      $.val('/Page_Gradient', 'none');
      return;
    }

    var x = update.value as String;
    bodyElement
      ?..style.removeProperty('background-color')
      ..style.background = 'linear-gradient($x)';
  });

  $.onValueChange('/Text').listen((ValueUpdate update) async {
    // Wait for message changes.
    var text = update.value as String?;
    if (text != null) {
      textElement
        ?..innerText = text
        ..offsetHeight; // Trigger Re-flow
    }
    await $.save();
  });

  $.onValueChange('/Text_Rotation').listen((ValueUpdate update) async {
    textElement?.style.transform = 'rotate(${update.value}deg';
    await $.save();
  });

  $.onValueChange('/Page_Color_Transition_Time').listen((
    ValueUpdate update,
  ) async {
    var n = update.value;

    if (TRANSITION_TIMES.containsKey(n)) {
      n = TRANSITION_TIMES[n];
    }

    bodyElement?.style.transition = 'background-color $n';

    await $.save();
  });

  $.onValueChange('/Text_Font').listen((ValueUpdate update) async {
    textElement
      ?..style.fontFamily = '"' + (update.value as String) + '"'
      ..offsetHeight;
    await $.save();
  });

  $.onValueChange('/Text_Size').listen((ValueUpdate update) async {
    textElement
      ?..style.fontSize = '${update.value}px'
      ..offsetHeight;
    await $.save();
  });

  $.onValueChange('/Page_Color_Transition_Time').listen((
    ValueUpdate update,
  ) async {
    var n = update.value;

    if (TRANSITION_TIMES.containsKey(n)) {
      n = TRANSITION_TIMES[n];
    }

    bodyElement?.style.transition = 'background-color $n';

    await $.save();
  });

  $.onValueChange('/Text_Size_Transition_Time').listen((
    ValueUpdate update,
  ) async {
    var n = update.value;

    if (TRANSITION_TIMES.containsKey(n)) {
      n = TRANSITION_TIMES[n];
    }

    textElement?.style.transition = 'font-size $n';

    await $.save();
  });

  $.onValueChange('/Text_Color_Transition_Time').listen((
    ValueUpdate update,
  ) async {
    var n = update.value;

    if (TRANSITION_TIMES.containsKey(n)) {
      n = TRANSITION_TIMES[n];
    }

    textElement?.style.transition = 'color $n';

    await $.save();
  });

  bodyElement?.addEventListener(
    'click',
    (event) {
          // Update Click Information
          $.val(
            '/Click/ID',
            (link['/Click/ID']?.lastValueUpdate?.value as int) + 1,
          );
          $.val('/Click/X', (event as MouseEvent).pageX);
          $.val('/Click/Y', (event).pageY);
        }
        as EventListener,
  );

  textElement?.addEventListener(
    'mouseenter',
    ((event) => $.val('/Text_Hovering', true)) as EventListener,
  );
  textElement?.addEventListener(
    'mouseleave',
    ((event) => $.val('/Text_Hovering', false)) as EventListener,
  );

  bodyElement?.addEventListener(
    'mousemove',
    (event) {
          $.val('/Mouse/X', (event as MouseEvent).pageX);
          $.val('/Mouse/Y', (event).pageY);
        }
        as EventListener,
  );

  bodyElement?.addEventListener(
    'mousedown',
    (_) {
          $.val('/Mouse/Down', true);
        }
        as EventListener,
  );

  bodyElement?.addEventListener(
    'mouseup',
    (_) {
          $.val('/Mouse/Down', false);
        }
        as EventListener,
  );

  // Re-sync Values to trigger subscribers.
  [
    '/Page_Color_Transition_Time',
    '/Text_Color_Transition_Time',
    '/Text_Size_Transition_Time',
    '/Page_Color',
    '/Page_Gradient',
    '/Text_Color',
    '/Text',
    '/Text_Font',
    '/Text_Size',
  ].forEach($.syncValue);

  await $.connect();
}

LinkProvider get $ => link;
