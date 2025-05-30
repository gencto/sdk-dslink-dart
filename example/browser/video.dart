// import 'dart:async';
// import 'dart:html';
// import 'dart:js';
// import 'dart:typed_data';

// import 'package:dsalink/browser.dart';
// import 'package:dsalink/requester.dart';

// late LinkProvider link;
// late Requester requester;
// late VideoElement video;
// late JsObject videoObject;

// String codec = 'video/webm; codecs="vorbis, vp8"';

// void main() async {
//   //updateLogLevel("ALL");
//   video = querySelector('#video') as VideoElement;
//   videoObject = JsObject.fromBrowserObject(video);

//   var brokerUrl = await BrowserUtils.fetchBrokerUrlFromPath(
//     'broker_url',
//     'http://localhost:8080/conn',
//   );

//   link = LinkProvider(
//     brokerUrl,
//     'VideoDisplay-',
//     isRequester: true,
//     isResponder: false,
//   );

//   await link.connect();
//   requester = (await link.onRequesterReady)!;

//   String getHash() {
//     if (window.location.hash.isEmpty) {
//       return '';
//     }
//     var h = window.location.hash.substring(1);
//     if (h.startsWith('mpeg4:')) {
//       codec = 'video/mp4; codecs="avc1.42E01E, mp4a.40.2"';
//       h = h.substring('mpeg4:'.length);
//     }
//     return h;
//   }

//   window.onHashChange.listen((event) {
//     setup(getHash());
//   });

//   await setup(getHash().isNotEmpty ? getHash() : '/downstream/File/video');
// }

// FutureOr<void> setup(String path) async {
//   print('Displaying Video from $path');

//   var sizePath = path + '/size';
//   var getChunkPath = path + '/readBinaryChunk';

//   var size = (await requester.getNodeValue(sizePath)).value as int;

//   print('Video Size: $size bytes');

//   var source = MediaSource();

//   source.addEventListener('sourceopen', (e) async {
//     CHUNK_COUNT = (size / 512000).round();
//     var chunkSize = (size / CHUNK_COUNT).ceil();

//     print('Chunk Size: $chunkSize bytes');

//     var buff = source.addSourceBuffer(codec);
//     for (var i = 0; i < CHUNK_COUNT; ++i) {
//       var start = chunkSize * i;
//       var end = start + chunkSize;
//       var update =
//           await requester.invoke(getChunkPath, <String, dynamic>{
//             'start': start,
//             'end': start + chunkSize,
//           }).first;

//       Map map = update.updates?[0];
//       ByteData data = map['data'];

//       print('Chunk #$i');

//       print('$start-$end');

//       if (i + 1 == CHUNK_COUNT) {
//         source.endOfStream();
//       } else {
//         buff.appendBuffer(data.buffer);
//       }

//       await buff.on['updateend'].first;
//     }

//     source.endOfStream();
//   });

//   video.src = Url.createObjectUrlFromSource(source);
//   video.autoplay = true;
//   await video.play();
// }

// int CHUNK_COUNT = 200;
