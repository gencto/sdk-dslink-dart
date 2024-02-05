part of dslink.requester;

/// A controller for removing a request.
///
/// This class implements the [RequestUpdater] interface and is responsible for handling the removal of a request.
/// It provides methods for updating the status of the request and handling disconnection and reconnection events.
class RemoveController implements RequestUpdater {
  final Completer<RequesterUpdate> completer = Completer<RequesterUpdate>();
  Future<RequesterUpdate> get future => completer.future;

  final Requester requester;
  final String path;
  // Request? _request;

  /// Creates a new [RemoveController] instance.
  ///
  /// The [requester] parameter is the requester object used to send the remove request.
  /// The [path] parameter is the path of the request to be removed.
  RemoveController(this.requester, this.path) {
    var reqMap = <String, dynamic>{'method': 'remove', 'path': path};

    //_request = 
    requester._sendRequest(reqMap, this);
  }

  /// Called when the request is updated.
  ///
  /// The [status] parameter represents the status of the request.
  /// The [updates] parameter contains the list of updates.
  /// The [columns] parameter contains the list of columns.
  /// The [meta] parameter contains the metadata.
  /// The [error] parameter represents any error that occurred during the update.
  @override
  void onUpdate(
      String? status, List? updates, List? columns, Map? meta, DSError? error) {
    // TODO implement error
    completer.complete(RequesterUpdate(status));
  }

  /// Called when the requester is disconnected.
  @override
  void onDisconnect() {}

  /// Called when the requester is reconnected.
  @override
  void onReconnect() {}
}
