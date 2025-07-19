import 'dart:convert';

import 'package:dsalink/core/request.dart';
import 'package:dsalink/core/response.dart';
import 'package:dsalink/core/transport_contract.dart';

class RequesterService {
  final ITransport transport;

  RequesterService(this.transport);

  Future<DsResponse<T>> sendRequest<T>(DsRequest request) async {
    final jsonRequest = jsonEncode({
      'method': request.method,
      'params': request.params,
    });

    await transport.send(jsonRequest);

    final response = await transport.onMessage.first;
    final parsed = jsonDecode(response);

    return DsResponse<T>(
      status: parsed['status'] as String,
      data: parsed['data'] as T?,
      error: parsed['error'] as String?,
    );
  }
}
