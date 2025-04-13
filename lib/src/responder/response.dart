part of dsalink.responder;

class Response implements ConnectionProcessor {
  final Responder responder;
  final int rid;
  String? type;
  String _sentStreamStatus = StreamStatus.initialize;

  String get sentStreamStatus => _sentStreamStatus;

  Response(this.responder, this.rid, [this.type]);

  /// close the request from responder side and also notify the requester
  void close([DSError? err]) {
    _sentStreamStatus = StreamStatus.closed;
    responder.closeResponse(rid, error: err, response: this);
  }

  /// close the response now, no need to send more response update
  void _close() {}

  void prepareSending() {
    if (!_pendingSending) {
      _pendingSending = true;
      responder.addProcessor(this);
    }
  }

  bool _pendingSending = false;

  @override
  void startSendingData(int currentTime, int waitingAckId) {
    _pendingSending = false;
  }

  @override
  void ackReceived(int receiveAckId, int startTime, int currentTime) {
    // TODO: implement ackReceived
  }

  /// for the broker trace action
  ResponseTrace? getTraceData([String change = '+']) {
    return null;
  }
}
