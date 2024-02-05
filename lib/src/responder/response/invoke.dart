part of dslink.responder;

typedef OnInvokeClosed = void Function(InvokeResponse response);
typedef OnInvokeSend = void Function(InvokeResponse response, Map m);

/// return true if params are valid
typedef OnReqParams = bool Function(InvokeResponse resp, Map m);

class _InvokeResponseUpdate {
  String? status;
  List? columns;
  List? updates;
  Map? meta;

  _InvokeResponseUpdate(this.status, this.updates, this.columns, this.meta);
}

class InvokeResponse extends Response {
  final LocalNode parentNode;
  final LocalNode? node;
  final String name;

  InvokeResponse(Responder responder, int rid, this.parentNode, this.node, this.name)
      : super(responder, rid, 'invoke');

  List<_InvokeResponseUpdate> pendingData = [];

  bool _hasSentColumns = false;

  /// update data for the responder stream
  void updateStream(List updates,
      {List? columns, String streamStatus = StreamStatus.open,
        Map? meta, bool autoSendColumns = true}) {
    if (meta != null && meta['mode'] == 'refresh') {
      pendingData.length = 0;
    }

    if (!_hasSentColumns) {
      if (columns == null &&
        autoSendColumns &&
        node != null &&
        node?.configs[r'$columns'] is List) {
        columns = node!.configs[r'$columns'] as List?;
      }
    }

    if (columns != null) {
      _hasSentColumns = true;
    }

    pendingData.add(
      _InvokeResponseUpdate(streamStatus, updates, columns, meta)
    );
    prepareSending();
  }

  OnReqParams? onReqParams;
  /// new parameter from the requester
  void updateReqParams(Map m) {
    if (onReqParams != null) {
      onReqParams!(this, m);
    }
  }

  @override
  void startSendingData(int currentTime, int waitingAckId) {
    _pendingSending = false;
    if (_err != null) {
      responder.closeResponse(rid, response: this, error: _err!);
      if (_sentStreamStatus == StreamStatus.closed) {
        _close();
      }
      return;
    }

    for (var update in pendingData) {
      List<Map<String, dynamic>>? outColumns;
      if (update.columns != null) {
        outColumns = TableColumn.serializeColumns(update.columns!);
      }

      responder.updateResponse(
        this,
        update.updates,
        streamStatus: update.status,
        columns: outColumns,
        meta: update.meta, handleMap: (m) {
        if (onSendUpdate != null) {
          onSendUpdate!(this, m);
        }
      });

      if (_sentStreamStatus == StreamStatus.closed) {
        _close();
        break;
      }
    }
    pendingData.length = 0;
  }

  /// close the request from responder side and also notify the requester
  @override
  void close([DSError? err]) {
    if (err != null) {
      _err = err;
    }
    if (pendingData.isNotEmpty) {
      pendingData.last.status = StreamStatus.closed;
    } else {
      pendingData.add(
        _InvokeResponseUpdate(StreamStatus.closed, null, null, null)
      );
      prepareSending();
    }
  }

  DSError? _err;

  OnInvokeClosed? onClose;
  OnInvokeSend? onSendUpdate;

  @override
  void _close() {
    if (onClose != null) {
      onClose!(this);
    }
  }

  /// for the broker trace action
  @override
  ResponseTrace getTraceData([String change = '+']) {
    return ResponseTrace(parentNode.path, 'invoke', rid, change, name);
  }
}
