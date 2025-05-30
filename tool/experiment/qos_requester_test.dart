import 'package:dsalink/dsalink.dart';

late LinkProvider link;
late int lastNum;
late SimpleNode valueNode;

void main() {
  var defaultNodes = <String, dynamic>{
    'node': {r'$type': 'string'},
  };

  link = LinkProvider(
    ['-b', '127.0.0.1/conn', '--log', 'finest'],
    'qos-req',
    defaultNodes: defaultNodes,
    isResponder: true,
    isRequester: true,
  );
  if (link.link == null) {
    // initialization failed
    return;
  }

  link.connect();
  link.onRequesterReady.then((Requester? req) {
    req?.subscribe('/downstream/qos-resp/node', (update) {
      print(update.value);
    }, 3);
  });
}
