/// DSA Broker Server
library dsalink.server;

import 'dart:io';

export 'src/crypto/pk.dart';

abstract class IRemoteRequester {
  /// user when the requester is proxied to another responder
  String get responderPath;
}

ContentType _jsonContentType = ContentType(
  'application',
  'json',
  charset: 'utf-8',
);

void updateResponseBeforeWrite(
  HttpRequest request, [
  int? statusCode = HttpStatus.ok,
  ContentType? contentType,
  bool noContentType = false,
]) {
  var response = request.response;

  if (statusCode != null) {
    response.statusCode = statusCode;
  }

  response.headers.set('Access-Control-Allow-Methods', 'POST, OPTIONS, GET');
  response.headers.set('Access-Control-Allow-Headers', 'Content-Type');
  var origin = request.headers.value('origin');

  if (request.headers.value('x-proxy-origin') != null) {
    origin = request.headers.value('x-proxy-origin');
  }

  origin ??= '*';

  response.headers.set('Access-Control-Allow-Origin', origin);

  if (!noContentType) {
    contentType ??= _jsonContentType;
    response.headers.contentType = contentType;
  }
}
