import 'package:dsalink/core/transport_contract.dart';
import 'package:dsalink/node/ds_node.dart';
import 'package:dsalink/responder/responder_router.dart';
import 'package:dsalink/utils/logger.dart';

class ResponderService with LoggerMixin {

  ResponderService(this.transport, this.root) {
    _router = ResponderRouter(root, transport);
    logInfo('ResponderService initialized with root node: ${root.logContext}');
  }
  final ITransport transport;
  final DsNode root;
  late final ResponderRouter _router;
  int _messagesHandled = 0;

  Future<void> start() async {
    final stopwatch = Stopwatch()..start();

    try {
      logInfo('Starting ResponderService');

      await transport.connect();

      transport.onMessage.listen(
        (msg) async {
          _messagesHandled++;
          final messageStopwatch = Stopwatch()..start();

          try {
            logDebug('Processing incoming message: ${msg.length} characters');
            await _router.handle(msg);

            messageStopwatch.stop();
            logDebug(
              'Message processed successfully in ${messageStopwatch.elapsedMilliseconds}ms',
            );
          } catch (error, stackTrace) {
            messageStopwatch.stop();
            DsLogger.logError(
              'Failed to handle incoming message',
              error,
              stackTrace: stackTrace,
              component: 'ResponderService',
              context: {
                'messageLength': msg.length,
                'messagesHandled': _messagesHandled,
                'processingTime': messageStopwatch.elapsedMilliseconds,
              },
            );
          }
        },
        onError: (error, stackTrace) {
          DsLogger.logError(
            'Error in message stream',
            error,
            stackTrace: stackTrace as StackTrace?,
            component: 'ResponderService',
            context: {'messagesHandled': _messagesHandled},
          );
        },
        onDone: () {
          logInfo(
            'Message stream closed. Total messages handled: $_messagesHandled',
          );
        },
      );

      stopwatch.stop();

      DsLogger.logPerformance(
        'ResponderService startup',
        stopwatch.elapsed,
        component: 'ResponderService',
        context: {'rootNode': root.logContext},
      );

      logInfo('ResponderService started successfully');
    } catch (error, stackTrace) {
      stopwatch.stop();

      DsLogger.logError(
        'Failed to start ResponderService',
        error,
        stackTrace: stackTrace,
        component: 'ResponderService',
        context: {
          'startupDuration': stopwatch.elapsedMilliseconds,
          'rootNode': root.logContext,
        },
      );

      rethrow;
    }
  }

  /// Get service statistics
  Map<String, dynamic> getStats() => {'messagesHandled': _messagesHandled, 'rootNode': root.logContext};
}
