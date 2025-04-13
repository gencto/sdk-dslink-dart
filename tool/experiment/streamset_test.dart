import 'dart:async';

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
    'streamset-req',
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
    Request rawreq;
    void fetchReq(Request v) {
      rawreq = v;
      var i = 0;
      Timer.periodic(Duration(seconds: 1), (Timer t) {
        rawreq.addReqParams(<String, dynamic>{
          'Path': '/downstream/streamset-req/node',
          'Value': ++i,
        });
      });
    }

    req
        ?.invoke(
          '/downstream/streamset-req/node',
          <String, dynamic>{
            'Path': '/downstream/streamset-req/node',
            'Value': 0,
          },
          Permission.CONFIG,
          fetchReq,
        )
        .listen((update) {
          print(update.updates);
        });
  });
}
