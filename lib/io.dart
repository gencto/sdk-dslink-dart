/// dsalink SDK IO Utilities
library dsalink.io;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dsalink/utils.dart';
import 'package:path/path.dart' as pathlib;

const bool _tcpNoDelay = bool.fromEnvironment(
  'dsa.io.tcpNoDelay',
  defaultValue: true,
);

/// Read raw text from stdin.
Stream<String> readStdinText() {
  return const Utf8Decoder().bind(stdin);
}

/// Read each line from stdin.
Stream<String> readStdinLines() {
  var stream = readStdinText();

  return const LineSplitter().bind(stream);
}

/// Helpers for working with HTTP
class HttpHelper {
  /// Main HTTP Client
  static HttpClient client = HttpClient();

  /// Creates an [HttpClientRequest] with the given parameters.
  /// [method] is the HTTP method.
  /// [url] is the URL to make the request to.
  /// [headers] specifies additional headers to set.
  static Future<HttpClientRequest> createRequest(
    String method,
    String url, {
    Map<String, String>? headers,
  }) async {
    var request = await client.openUrl(method, Uri.parse(url));
    if (headers != null) {
      headers.forEach(request.headers.set);
    }
    return request;
  }

  /// Reads the entire [response] as a list of bytes.
  static Future<List<int>> readBytesFromResponse(
    HttpClientResponse response,
  ) async {
    return await response.fold([], (a, b) {
      a.addAll(b);
      return a;
    });
  }

  /// Fetches the specified [url] from HTTP.
  /// If [headers] is specified, the headers will be added onto the request.
  static Future<String> fetchUrl(
    String url, {
    Map<String, String>? headers,
  }) async {
    var request = await createRequest('GET', url, headers: headers);
    var response = await request.close();
    return const Utf8Decoder().convert(await readBytesFromResponse(response));
  }

  /// Fetches the specified [url] from HTTP as json.
  /// If [headers] is specified, the headers will be added onto the request.
  static Future<dynamic> fetchJSON(
    String url, {
    Map<String, String>? headers,
  }) async {
    return const JsonDecoder().convert(await fetchUrl(url, headers: headers));
  }

  static const String _webSocketGUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';

  static const bool enableStandardWebSocket =
      bool.fromEnvironment('calzone.build', defaultValue: false) ||
      bool.fromEnvironment('websocket.standard', defaultValue: true);

  /// Custom WebSocket Connection logic.
  static Future<WebSocket> connectToWebSocket(
    String url, {
    Iterable<String>? protocols,
    Map<String, dynamic>? headers,
    HttpClient? httpClient,
    bool? useStandardWebSocket,
  }) async {
    Uri? uri = Uri.parse(url);

    useStandardWebSocket ??= enableStandardWebSocket;

    if (useStandardWebSocket == true && uri.scheme != 'wss') {
      return await awaitWithTimeout(
        WebSocket.connect(url, protocols: protocols, headers: headers),
        60000,
        onSuccessAfterTimeout: (WebSocket socket) {
          socket.close();
        },
      );
    }

    if (uri.scheme != 'ws' && uri.scheme != 'wss') {
      throw WebSocketException("Unsupported URL scheme '${uri.scheme}'");
    }

    var random = Random();
    // Generate 16 random bytes.
    var nonceData = Uint8List(16);
    for (var i = 0; i < 16; i++) {
      nonceData[i] = random.nextInt(256);
    }
    var nonce = base64.encode(nonceData);

    var port = uri.port;
    if (port == 0) {
      port = uri.scheme == 'wss' ? 443 : 80;
    }

    uri = Uri(
      scheme: uri.scheme == 'wss' ? 'https' : 'http',
      userInfo: uri.userInfo,
      host: uri.host,
      port: port,
      path: uri.path,
      query: uri.query,
    );

    var _client =
        httpClient ??
        (HttpClient()..badCertificateCallback = (a, b, c) => true);

    return _client
        .openUrl('GET', uri)
        .then((HttpClientRequest request) async {
          if (uri?.userInfo != null && uri!.userInfo.isNotEmpty) {
            // If the URL contains user information use that for basic
            // authorization.
            var auth = base64.encode(utf8.encode(uri.userInfo));
            request.headers.set(HttpHeaders.authorizationHeader, 'Basic $auth');
          }
          if (headers != null) {
            headers.forEach(
              (field, dynamic value) => request.headers.add(field, value),
            );
          }
          // Setup the initial handshake.
          request.headers
            ..set(HttpHeaders.connectionHeader, 'Upgrade')
            ..set(HttpHeaders.upgradeHeader, 'websocket')
            ..set('Sec-WebSocket-Key', nonce)
            ..set('Cache-Control', 'no-cache')
            ..set('Sec-WebSocket-Version', '13');
          if (protocols != null) {
            request.headers.add('Sec-WebSocket-Protocol', protocols.toList());
          }
          return request.close();
        })
        .then((response) {
          return response;
        })
        .then((HttpClientResponse response) {
          void error(String message) {
            // Flush data.
            response.detachSocket().then((Socket socket) {
              socket.destroy();
            });
            throw WebSocketException(message);
          }

          if (response.statusCode != HttpStatus.switchingProtocols ||
              response.headers[HttpHeaders.connectionHeader] == null ||
              !response.headers[HttpHeaders.connectionHeader]!.any(
                (value) => value.toLowerCase() == 'upgrade',
              ) ||
              response.headers
                      .value(HttpHeaders.upgradeHeader)!
                      .toLowerCase() !=
                  'websocket') {
            error("Connection to '$uri' was not upgraded to websocket");
          }
          var accept = response.headers.value('Sec-WebSocket-Accept');
          if (accept == null) {
            error("Response did not contain a 'Sec-WebSocket-Accept' header");
          }
          var expectedAccept =
              sha1.convert('$nonce$_webSocketGUID'.codeUnits).bytes;
          List<int> receivedAccept = base64.decode(accept!);
          if (expectedAccept.length != receivedAccept.length) {
            error("Response header 'Sec-WebSocket-Accept' is the wrong length");
          }
          for (var i = 0; i < expectedAccept.length; i++) {
            if (expectedAccept[i] != receivedAccept[i]) {
              error("Bad response 'Sec-WebSocket-Accept' header");
            }
          }
          var protocol = response.headers.value('Sec-WebSocket-Protocol');
          return response.detachSocket().then((socket) {
            socket.setOption(SocketOption.tcpNoDelay, _tcpNoDelay);
            return WebSocket.fromUpgradedSocket(
              socket,
              protocol: protocol,
              serverSide: false,
            );
          });
        })
        .timeout(
          Duration(minutes: 1),
          onTimeout: () {
            _client.close(force: true);
            throw WebSocketException('timeout');
          },
        );
  }

  static Future<WebSocket> upgradeToWebSocket(
    HttpRequest request, [
    Function(List<String> protocols)? protocolSelector,
    bool? useStandardWebSocket,
  ]) {
    useStandardWebSocket ??= enableStandardWebSocket;

    if (useStandardWebSocket) {
      return WebSocketTransformer.upgrade(
        request,
        protocolSelector: protocolSelector,
      );
    }

    var response = request.response;
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      // Send error response.
      response
        ..statusCode = HttpStatus.badRequest
        ..close();
      return Future.error(
        WebSocketException('Invalid WebSocket upgrade request'),
      );
    }

    Future<WebSocket> upgrade(String? protocol) {
      // Send the upgrade response.
      response
        ..statusCode = HttpStatus.switchingProtocols
        ..headers.add(HttpHeaders.connectionHeader, 'Upgrade')
        ..headers.add(HttpHeaders.upgradeHeader, 'websocket');
      var key = request.headers.value('Sec-WebSocket-Key')!;
      var accept = base64.encode(
        sha1.convert('$key$_webSocketGUID'.codeUnits).bytes,
      );
      response.headers.add('Sec-WebSocket-Accept', accept);
      if (protocol != null) {
        response.headers.add('Sec-WebSocket-Protocol', protocol);
      }
      response.headers.contentLength = 0;
      return response.detachSocket().then((socket) {
        socket.setOption(SocketOption.tcpNoDelay, _tcpNoDelay);
        return WebSocket.fromUpgradedSocket(
          socket,
          protocol: protocol,
          serverSide: true,
        );
      });
    }

    var protocols = request.headers['Sec-WebSocket-Protocol'];
    if (protocols != null && protocolSelector != null) {
      // The suggested protocols can be spread over multiple lines, each
      // consisting of multiple protocols. To unify all of them, first join
      // the lists with ', ' and then tokenize.
      protocols = HttpHelper.tokenizeFieldValue(protocols.join(', '));
      return Future(
        () => protocolSelector(protocols!)
            .then((dynamic protocol) {
              if (!protocols!.contains(protocol)) {
                throw WebSocketException(
                  'Selected protocol is not in the list of available protocols',
                );
              }
              return protocol;
            })
            .catchError((dynamic error) {
              response
                ..statusCode = HttpStatus.internalServerError
                ..close();
              throw error;
            })
            .then((dynamic result) {
              if (result is String) {
                return upgrade(result);
              }
              return null;
            })
            .then((WebSocket socket) {
              return socket;
            }),
      );
    } else {
      return upgrade(null);
    }
  }

  static List<String> tokenizeFieldValue(String headerValue) {
    var tokens = <String>[];
    var start = 0;
    var index = 0;
    while (index < headerValue.length) {
      if (headerValue[index] == ',') {
        tokens.add(headerValue.substring(start, index));
        start = index + 1;
      } else if (headerValue[index] == ' ' || headerValue[index] == '\t') {
        start++;
      }
      index++;
    }
    tokens.add(headerValue.substring(start, index));
    return tokens;
  }
}

/// Generates a random socket port.
Future<int> getRandomSocketPort() async {
  var server = await ServerSocket.bind(InternetAddress.loopbackIPv4.address, 0);
  var port = server.port;
  await server.close();
  return port;
}

final _separator = pathlib.separator;

Future<File> _safeWriteBase(
  File targetFile,
  dynamic content,
  Future<File> Function(File file, dynamic content) writeFunction, {
  bool verifyJson = false,
}) async {
  final tempDirectory = await Directory.current.createTemp();
  final targetFileName = pathlib.basename(targetFile.path);

  var tempFile = File('${tempDirectory.path}$_separator$targetFileName');
  tempFile = await writeFunction(tempFile, content);
  var canOverwriteOriginalFile = true;

  if (verifyJson) {
    final readContent = await tempFile.readAsString();
    try {
      json.decode(readContent);
    } on FormatException catch (e, s) {
      canOverwriteOriginalFile = false;
      logger.severe(
        "Couldn't parse JSON after trying to write ${targetFile.path}",
        e,
        s,
      );
    }
  }

  if (canOverwriteOriginalFile) {
    tempFile = await tempFile.rename(targetFile.absolute.path);
    await tempDirectory.delete();
    return tempFile;
  } else {
    logger.severe(
      "${targetFile.path} wasn't saved, the original will be preserved",
    );
    return targetFile;
  }
}

Future<File> safeWriteAsString(
  File targetFile,
  String content, {
  bool verifyJson = false,
}) async {
  return _safeWriteBase(
    targetFile,
    content,
    (File f, dynamic content) => f.writeAsString(content, flush: true),
    verifyJson: verifyJson,
  );
}

Future<File> safeWriteAsBytes(
  File targetFile,
  List<int> content, {
  bool verifyJson = false,
}) async {
  return _safeWriteBase(
    targetFile,
    content,
    (File f, dynamic content) => f.writeAsBytes(content, flush: true),
    verifyJson: verifyJson,
  );
}
