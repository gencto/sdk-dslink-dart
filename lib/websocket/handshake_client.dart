import 'dart:convert';
import 'dart:io';

class HandshakeClient {

  HandshakeClient({
    required this.brokerUrl,
    required this.linkName,
    required this.token,
  });
  final String brokerUrl;
  final String linkName;
  final String token;

  Future<Uri> performHandshake() async {
    final handshakeUri = Uri.parse('$brokerUrl/conn');

    final payload = jsonEncode({
      'name': linkName,
      'token': token,
      'linkData': {
        'sdk': 'dart',
        'version': '1.0.0',
        'os': Platform.operatingSystem,
      },
    });

    final response = await HttpClient().postUrl(handshakeUri).then((req) {
      req.headers.contentType = ContentType.json;
      req.write(payload);
      return req.close();
    });

    final result = await response.transform(utf8.decoder).join();

    if (result.trim().isEmpty) {
      throw Exception(
        'Handshake failed: empty response body from $handshakeUri',
      );
    }

    late dynamic json;
    try {
      json = jsonDecode(result);
    } catch (e) {
      throw FormatException('Handshake failed: invalid JSON. Body: $result');
    }

    if (json['wsUri'] == null) {
      throw Exception('Handshake failed: wsUri missing in response: $json');
    }

    return Uri.parse(json['wsUri'] as String);
  }
}
