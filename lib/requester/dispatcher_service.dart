import 'package:dsalink/models/ds_request.dart';
import 'package:dsalink/models/invoke_request.dart';
import 'package:dsalink/models/list_request.dart';
import 'package:dsalink/models/remove_request.dart';
import 'package:dsalink/models/set_request.dart';
import 'package:dsalink/models/subscribe_request.dart';
import 'package:dsalink/models/unsubscribe_request.dart';
import 'package:dsalink/utils/logger.dart';
import 'package:logging/logging.dart';

class DispatcherService with LoggerMixin {
  int _requestCounter = 0;
  
  String _generateRequestId() {
    return 'req_${++_requestCounter}_${DateTime.now().millisecondsSinceEpoch}';
  }

  void dispatch(DsRequest request) {
    final requestId = _generateRequestId();
    final stopwatch = Stopwatch()..start();
    
    try {
      logInfo('Dispatching request: ${request.runtimeType}', null, null);
      
      switch (request.runtimeType) {
        case ListRequest _:
          _handleList(request as ListRequest, requestId, stopwatch);
        case InvokeRequest _:
          _handleInvoke(request as InvokeRequest, requestId, stopwatch);
        case SetRequest _:
          _handleSet(request as SetRequest, requestId, stopwatch);
        case RemoveRequest _:
          _handleRemove(request as RemoveRequest, requestId, stopwatch);
        case SubscribeRequest _:
          _handleSubscribe(request as SubscribeRequest, requestId, stopwatch);
        case UnsubscribeRequest _:
          _handleUnsubscribe(request as UnsubscribeRequest, requestId, stopwatch);
        default:
          stopwatch.stop();
          DsLogger.logError(
            'Unknown request type received',
            'Unsupported request type: ${request.runtimeType}',
            component: 'DispatcherService',
            context: {
              'requestId': requestId,
              'requestType': request.runtimeType.toString(),
              'duration': stopwatch.elapsedMilliseconds,
            },
          );
          throw UnsupportedError("Unknown request type: ${request.runtimeType}");
      }
    } catch (error, stackTrace) {
      stopwatch.stop();
      DsLogger.logError(
        'Request dispatch failed',
        error,
        stackTrace: stackTrace,
        component: 'DispatcherService',
        context: {
          'requestId': requestId,
          'requestType': request.runtimeType.toString(),
          'duration': stopwatch.elapsedMilliseconds,
        },
      );
      rethrow;
    }
  }

  void _handleList(ListRequest req, String requestId, Stopwatch stopwatch) {
    DsLogger.logRequest(
      'LIST',
      req.path,
      requestId: requestId,
      component: 'DispatcherService',
    );
    
    // Simulate processing time for demonstration
    // In real implementation, this would handle the actual list operation
    
    stopwatch.stop();
    DsLogger.logResponse(
      'LIST',
      req.path,
      requestId: requestId,
      duration: stopwatch.elapsed,
      success: true,
      component: 'DispatcherService',
    );
  }

  void _handleInvoke(InvokeRequest req, String requestId, Stopwatch stopwatch) {
    DsLogger.logRequest(
      'INVOKE',
      req.path,
      requestId: requestId,
      params: req.params,
      component: 'DispatcherService',
    );
    
    stopwatch.stop();
    DsLogger.logResponse(
      'INVOKE',
      req.path,
      requestId: requestId,
      duration: stopwatch.elapsed,
      success: true,
      component: 'DispatcherService',
    );
  }

  void _handleSet(SetRequest req, String requestId, Stopwatch stopwatch) {
    DsLogger.logRequest(
      'SET',
      req.path,
      requestId: requestId,
      params: {'value': req.value},
      component: 'DispatcherService',
    );
    
    stopwatch.stop();
    DsLogger.logResponse(
      'SET',
      req.path,
      requestId: requestId,
      duration: stopwatch.elapsed,
      success: true,
      component: 'DispatcherService',
    );
  }

  void _handleRemove(RemoveRequest req, String requestId, Stopwatch stopwatch) {
    DsLogger.logRequest(
      'REMOVE',
      req.path,
      requestId: requestId,
      component: 'DispatcherService',
    );
    
    stopwatch.stop();
    DsLogger.logResponse(
      'REMOVE',
      req.path,
      requestId: requestId,
      duration: stopwatch.elapsed,
      success: true,
      component: 'DispatcherService',
    );
  }

  void _handleSubscribe(SubscribeRequest req, String requestId, Stopwatch stopwatch) {
    final paths = req.paths.map((p) => p.path).toList();
    
    DsLogger.logRequest(
      'SUBSCRIBE',
      'multiple_paths',
      requestId: requestId,
      params: {'paths': paths},
      component: 'DispatcherService',
    );
    
    stopwatch.stop();
    DsLogger.logResponse(
      'SUBSCRIBE',
      'multiple_paths',
      requestId: requestId,
      duration: stopwatch.elapsed,
      success: true,
      result: {'subscribedPaths': paths.length},
      component: 'DispatcherService',
    );
  }

  void _handleUnsubscribe(UnsubscribeRequest req, String requestId, Stopwatch stopwatch) {
    DsLogger.logRequest(
      'UNSUBSCRIBE',
      'multiple_sids',
      requestId: requestId,
      params: {'sids': req.sids},
      component: 'DispatcherService',
    );
    
    stopwatch.stop();
    DsLogger.logResponse(
      'UNSUBSCRIBE',
      'multiple_sids',
      requestId: requestId,
      duration: stopwatch.elapsed,
      success: true,
      result: {'unsubscribedSids': req.sids.length},
      component: 'DispatcherService',
    );
  }
}
