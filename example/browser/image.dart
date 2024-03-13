import 'package:dslink/browser.dart';

import 'dart:html';
import 'dart:typed_data';

late LinkProvider link;
late Requester requester;
late ImageElement image;

void main() async {
  image = querySelector('#image') as ImageElement;

  var brokerUrl = await BrowserUtils.fetchBrokerUrlFromPath(
      'broker_url', 'http://localhost:8080/conn');

  link = LinkProvider(brokerUrl, 'ImageDisplay-', isRequester: true);

  await link.connect();
  requester = (await link.onRequesterReady)!;
  window.onHashChange.listen((event) {
    setup(window.location.hash.substring(1));
  });

  setup(window.location.hash.isNotEmpty
      ? window.location.hash.substring(1)
      : '/data/image');
}

void setup(String path) {
  print('Displaying Image from $path');

  if (listener != null) {
    listener?.cancel();
    listener = null;
  }

  listener = requester.subscribe(path, handleValueUpdate, 0);
}

String? url;

void handleValueUpdate(ValueUpdate update) {
  if (update.value == null) {
    return;
  }

  if (url != null) {
    Url.revokeObjectUrl(url!);
  }

  var data = update.value! as ByteData;
  var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

  var blob = Blob(<Uint8List>[bytes], 'image/jpeg');

  url = image.src = Url.createObjectUrl(blob);
}

ReqSubscribeListener? listener;
