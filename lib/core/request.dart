class DsRequest {
  DsRequest({required this.method, required this.params});
  
  final String method;
  final Map<String, dynamic> params;
}
