part of dslink.requester;

/// request class handles raw response from responder
/// Represents a request made by the requester.
///
/// This class encapsulates the necessary information for a request,
/// including the requester instance, request ID, request data,
/// and a callback for updating the request status.
class Request {
  final Requester requester;
  final int rid;
  final Map? data;

  /// The callback function for updating the request status.
  final RequestUpdater updater;
  final bool _isClosed = false;
  bool get isClosed => _isClosed;

  Request(this.requester, this.rid, this.updater, this.data);

  String streamStatus = StreamStatus.initialize;

  /// Resends the data if the previous sending failed.
  ///
  /// This method adds the data to the send list of the requester
  /// to be resent later.
  void resend() {
    requester.addToSendList(data!);
  }

  /// Adds request parameters to the send list.
  ///
  /// This method adds the request ID and parameters to the send list
  /// of the requester to be sent later.
  void addReqParams(Map m) {
    requester.addToSendList(<String, dynamic>{'rid': rid, 'params': m});
  }

  void _update(Map m) {
    if (m['stream'] is String) {
      streamStatus = m['stream'];
    }
    List? updates;
    List? columns;
    Map? meta;
    if (m['updates'] is List) {
      updates = m['updates'];
    }
    if (m['columns'] is List) {
      columns = m['columns'];
    }
    if (m['meta'] is Map) {
      meta = m['meta'];
    }
    // remove the request from global Map
    if (streamStatus == StreamStatus.closed) {
      requester._requests.remove(rid);
    }
    DSError? error;
    if (m.containsKey('error') && m['error'] is Map) {
      error = DSError.fromMap(m['error']);
      requester._errorController.add(error);
    }

    updater.onUpdate(streamStatus, updates, columns, meta, error);
  }

  /// Closes the request and finishes the data.
  ///
  /// This method sets the stream status to "closed" and calls the
  /// updater callback with the updated status and optional error.
  void _close([DSError? error]) {
    if (streamStatus != StreamStatus.closed) {
      streamStatus = StreamStatus.closed;
      updater.onUpdate(StreamStatus.closed, null, null, null, error);
    }
  }

  /// Closes the request from the client side.
  ///
  /// This method is used to close the request from the client side.
  /// It will also be called later from the requester.
  void close() {
    requester.closeRequest(this);
  }
}
