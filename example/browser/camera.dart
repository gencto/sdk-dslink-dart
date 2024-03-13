import 'package:dslink/browser.dart';

import 'dart:html';
import 'dart:typed_data';
import 'package:dslink/convert_consts.dart';

late LinkProvider link;
late MediaStream stream;
late VideoElement video;
late CanvasElement canvas;
late String url;
late int width = 320;
late int height = 0;
late bool streaming = false;

void main() async {
  video = (querySelector('#video') as VideoElement?)!;
  canvas = (querySelector('#canvas') as CanvasElement?)!;
  stream = await window.navigator.getUserMedia(video: true);

  url = Url.createObjectUrlFromStream(stream);

  video.src = url;
  await video.play();

  video.onCanPlay.listen((e) {
    if (!streaming) {
      height = video.videoHeight ~/ (video.videoWidth / width);

      if (height.isNaN) {
        height = width ~/ (4 / 3);
      }

      video.width = width;
      video.height = height;
      canvas.width = width;
      canvas.height = height;
      streaming = true;
    }
  });

  var brokerUrl = await BrowserUtils.fetchBrokerUrlFromPath(
      'broker_url', 'http://localhost:8080/conn');

  link = LinkProvider(brokerUrl, 'Webcam-', defaultNodes: <String, dynamic>{
    'Image': {r'$type': 'binary'}
  });

  await link.connect();

  Scheduler.every(Interval.forMilliseconds(16 * 4), () {
    takePicture();
  });
}

void takePicture() {
  var context = canvas.getContext('2d') as CanvasRenderingContext2D;
  if (width != 0 && height != 0) {
    canvas.width = width;
    canvas.height = height;
    context.drawImage(video, 0, 0);

    updateImage();
  } else {
    clearPicture();
  }
}

void clearPicture() {
  var context = canvas.getContext('2d') as CanvasRenderingContext2D;
  context.fillStyle = '#AAA';
  context.fillRect(0, 0, canvas.width!, canvas.height!);
  updateImage();
}

void updateImage() {
  link.val('/Image', captureImage());
}

ByteData captureImage() {
  var stopwatch = Stopwatch();
  stopwatch.start();
  var dataUrl = canvas.toDataUrl('image/webp', 0.2);
  stopwatch.stop();
  var bytes =
      BASE64.decode(dataUrl.substring('data:image/webp;base64,'.length));
  var data = ByteDataUtil.fromList(bytes);
  print('Took ${stopwatch.elapsedMilliseconds} to create image.');
  return data;
}
