// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:dsalink/browser_client.dart';
import 'package:dsalink/src/crypto/pk.dart';
import 'package:web/web.dart';

import '../sample_responder.dart';

void main() {
  document.querySelector('#output')?.textContent = 'Your Dart app is running.';

  var key = PrivateKey.loadFromString(
    'M6S41GAL0gH0I97Hhy7A2-icf8dHnxXPmYIRwem03HE',
  );

  var link = BrowserECDHLink(
    'http://127.0.0.1/conn',
    'test-browser-responder-',
    key,
    isResponder: true,
    nodeProvider: TestNodeProvider(),
  );

  link.connect();
}
