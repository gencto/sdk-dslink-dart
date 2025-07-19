class DsResponse<T> {
  final String status;
  final T? data;
  final String? error;

  DsResponse({required this.status, this.data, this.error});
}
