import 'dart:async';

import 'package:dslink/dslink.dart';

late LinkProvider link;
late int lastNum;
late SimpleNode valueNode;

void main() {
  var defaultNodes = <String, dynamic>{
    'node': {r'$type': 'string'}
  };

  link = LinkProvider(
      ['-b', 'dev.sviteco.ua/conn', '--log', 'finest'], 'streamset-req',
      defaultNodes: defaultNodes, isResponder: false, isRequester: true);
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
        rawreq
            .addReqParams(<String, dynamic>{'Path': '/data/m1', 'Value': ++i});
      });
    }

    req
        ?.invoke(
            '/data/streamingSet',
            <String, dynamic>{'Path': '/data/m1', 'Value': 0},
            Permission.CONFIG,
            fetchReq)
        .listen((update) {
      print(update.updates);
    });
  });
}
