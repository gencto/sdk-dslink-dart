part of dslink.requester;

class SetController implements RequestUpdater {
  final Completer<RequesterUpdate> completer = Completer<RequesterUpdate>();
  Future<RequesterUpdate> get future => completer.future;
  final Requester requester;
  final String path;
  final Object? value;
  // Request? _request;

  SetController(this.requester, this.path, this.value,
      [int maxPermission = Permission.CONFIG]) {
    var reqMap = <String, dynamic>{
      'method': 'set',
      'path': path,
      'value': value
    };

    if (maxPermission != Permission.CONFIG) {
      reqMap['permit'] = Permission.names[maxPermission];
    }

    //_request =
    requester._sendRequest(reqMap, this);
  }

  @override
  void onUpdate(
      String? status, List? updates, List? columns, Map? meta, DSError? error) {
    // TODO implement error
    completer.complete(RequesterUpdate(status));
  }

  @override
  void onDisconnect() {}

  @override
  void onReconnect() {}
}
