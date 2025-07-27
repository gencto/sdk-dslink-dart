class DsResponse<T> {
  DsResponse({required this.status, this.data, this.error});

  final String status;
  final T? data;
  final String? error;
}
