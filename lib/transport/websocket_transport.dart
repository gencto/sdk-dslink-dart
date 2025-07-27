import 'dart:async';
import 'dart:io';

import 'package:dsalink/core/transport_contract.dart';
import 'package:dsalink/utils/logger.dart';
import 'package:logging/logging.dart';

class WebSocketTransport with LoggerMixin implements ITransport {

  WebSocketTransport(this.url);
  late WebSocket _socket;
  final String url;
  final _controller = StreamController<String>.broadcast();
  bool _isConnected = false;
  int _messagesSent = 0;
  int _messagesReceived = 0;

  @override
  Future<void> connect() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      DsLogger.logConnection(
        'attempting',
        url,
        component: 'WebSocketTransport',
        metadata: {
          'protocol': 'websocket',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      _socket = await WebSocket.connect(url);
      _isConnected = true;
      
      _socket.listen(
        (data) {
          _messagesReceived++;
          logDebug('Received WebSocket message: ${data.toString().length} bytes');
          _controller.add(data as String);
        },
        onError: (e) {
          _isConnected = false;
          DsLogger.logError(
            'WebSocket stream error',
            e,
            component: 'WebSocketTransport',
            context: {
              'url': url,
              'messagesSent': _messagesSent,
              'messagesReceived': _messagesReceived,
            },
          );
          _controller.addError(e as Object);
        },
        onDone: () {
          _isConnected = false;
          DsLogger.logConnection(
            'closed',
            url,
            level: Level.WARNING,
            component: 'WebSocketTransport',
            metadata: {
              'messagesSent': _messagesSent,
              'messagesReceived': _messagesReceived,
            },
          );
          _controller.close();
        },
      );
      
      stopwatch.stop();
      
      DsLogger.logConnection(
        'established',
        url,
        component: 'WebSocketTransport',
        metadata: {
          'protocol': 'websocket',
          'connectionTime': stopwatch.elapsedMilliseconds,
        },
      );
      
      DsLogger.logPerformance(
        'WebSocket connection',
        stopwatch.elapsed,
        component: 'WebSocketTransport',
        context: {
          'url': url,
        },
      );
      
    } catch (error, stackTrace) {
      _isConnected = false;
      stopwatch.stop();
      
      DsLogger.logError(
        'WebSocket connection failed',
        error,
        stackTrace: stackTrace,
        component: 'WebSocketTransport',
        context: {
          'url': url,
          'attemptDuration': stopwatch.elapsedMilliseconds,
        },
      );
      
      rethrow;
    }
  }

  @override
  Future<String> send(String message) async {
    if (!_isConnected) {
      const errorMessage = 'Cannot send message: WebSocket not connected';
      logError(errorMessage);
      throw StateError(errorMessage);
    }
    
    try {
      final messageSize = message.length;
      logDebug('Sending WebSocket message: $messageSize bytes');
      
      _socket.add(message);
      _messagesSent++;
      
      logDebug('Message sent successfully');
      return 'sent';
      
    } catch (error, stackTrace) {
      DsLogger.logError(
        'Failed to send WebSocket message',
        error,
        stackTrace: stackTrace,
        component: 'WebSocketTransport',
        context: {
          'url': url,
          'messageSize': message.length,
          'messagesSent': _messagesSent,
        },
      );
      
      rethrow;
    }
  }

  @override
  Stream<String> get onMessage => _controller.stream;

  @override
  void close() {
    try {
      logInfo('Closing WebSocket connection');
      
      if (_isConnected) {
        unawaited(_socket.close());
        _isConnected = false;
        
        DsLogger.logConnection(
          'closed_requested',
          url,
          component: 'WebSocketTransport',
          metadata: {
            'messagesSent': _messagesSent,
            'messagesReceived': _messagesReceived,
          },
        );
      }
      
    } catch (error, stackTrace) {
      DsLogger.logError(
        'Error closing WebSocket connection',
        error,
        stackTrace: stackTrace,
        component: 'WebSocketTransport',
        context: {
          'url': url,
        },
      );
    }
  }
  
  /// Get connection statistics
  Map<String, dynamic> getStats() => {
      'isConnected': _isConnected,
      'messagesSent': _messagesSent,
      'messagesReceived': _messagesReceived,
      'url': url,
    };
}
