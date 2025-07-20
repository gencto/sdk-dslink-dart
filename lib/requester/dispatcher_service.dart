import 'package:dsalink/models/ds_request.dart';
import 'package:dsalink/models/invoke_request.dart';
import 'package:dsalink/models/list_request.dart';
import 'package:dsalink/models/remove_request.dart';
import 'package:dsalink/models/set_request.dart';
import 'package:dsalink/models/subscribe_request.dart';
import 'package:dsalink/models/unsubscribe_request.dart';
import 'package:dsalink/utils/logger.dart';

class DispatcherService {
  static final _logger = DSALogger.category('DispatcherService');

  void dispatch(DsRequest request) {
    _logger.debug('Dispatching request', context: {
      'requestType': request.runtimeType.toString(),
    });

    try {
      switch (request.runtimeType) {
        case ListRequest _:
          _handleList(request as ListRequest);
        case InvokeRequest _:
          _handleInvoke(request as InvokeRequest);
        case SetRequest _:
          _handleSet(request as SetRequest);
        case RemoveRequest _:
          _handleRemove(request as RemoveRequest);
        case SubscribeRequest _:
          _handleSubscribe(request as SubscribeRequest);
        case UnsubscribeRequest _:
          _handleUnsubscribe(request as UnsubscribeRequest);

        default:
          _logger.error('Unknown request type', context: {
            'requestType': request.runtimeType.toString(),
          });
          throw UnsupportedError("Unknown request type: ${request.runtimeType}");
      }
    } catch (error, stackTrace) {
      _logger.error('Error handling request', 
        error: error, 
        stackTrace: stackTrace,
        context: {
          'requestType': request.runtimeType.toString(),
        }
      );
      rethrow;
    }
  }

  void _handleList(ListRequest req) {
    _logger.info("Handling LIST request", context: {
      'path': req.path,
    });
  }

  void _handleInvoke(InvokeRequest req) {
    _logger.info("Handling INVOKE request", context: {
      'path': req.path,
      'params': req.params,
    });
  }

  void _handleSet(SetRequest req) {
    _logger.info("Handling SET request", context: {
      'path': req.path,
      'value': req.value,
    });
  }

  void _handleRemove(RemoveRequest req) {
    _logger.info("Handling REMOVE request", context: {
      'path': req.path,
    });
  }

  void _handleSubscribe(SubscribeRequest req) {
    _logger.info("Handling SUBSCRIBE request", context: {
      'paths': req.paths.map((p) => p.path).toList(),
    });
  }

  void _handleUnsubscribe(UnsubscribeRequest req) {
    _logger.info("Handling UNSUBSCRIBE request", context: {
      'sids': req.sids,
    });
  }
}
