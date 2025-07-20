import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dsalink/core/transport_contract.dart';

class WebSocketTransport implements ITransport {
  late WebSocket _socket;
  final String url;
  final StreamController<String> _controller = StreamController<String>.broadcast();
  
  // Performance optimization: Message compression for large payloads
  static const int _compressionThreshold = 1024; // Compress messages larger than 1KB
  bool _compressionEnabled = false;
  
  // Performance optimization: Connection pooling and reconnection logic
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 3;
  static const Duration _reconnectDelay = Duration(seconds: 2);
  
  // Performance optimization: Message queue for offline scenarios
  final List<String> _messageQueue = <String>[];
  static const int _maxQueueSize = 100;

  WebSocketTransport(this.url) {
    // Enable compression for larger payloads
    _compressionEnabled = true;
  }

  @override
  Future<void> connect() async {
    try {
      _socket = await WebSocket.connect(
        url,
        // Performance optimization: Configure compression
        compression: _compressionEnabled ? CompressionOptions.compressionDefault : CompressionOptions.compressionOff,
      );
      
      _isConnected = true;
      _reconnectAttempts = 0;
      
      // Process any queued messages
      await _processQueuedMessages();
      
      _socket.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );
    } catch (e) {
      _isConnected = false;
      await _handleReconnection();
      rethrow;
    }
  }

  void _onMessage(dynamic data) {
    if (data is String) {
      _controller.add(data);
    } else if (data is List<int>) {
      // Handle binary/compressed data
      try {
        final decompressed = _decompressMessage(Uint8List.fromList(data));
        _controller.add(decompressed);
      } catch (e) {
        _controller.addError('Failed to decompress message: $e');
      }
    }
  }

  void _onError(dynamic error) {
    _isConnected = false;
    _controller.addError(error as Object);
    _handleReconnection();
  }

  void _onDone() {
    _isConnected = false;
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _handleReconnection();
    } else {
      _controller.close();
    }
  }

  Future<void> _handleReconnection() async {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      await Future.delayed(_reconnectDelay);
      try {
        await connect();
      } catch (e) {
        // Will retry in next cycle
      }
    }
  }

  @override
  Future<String> send(String message) async {
    if (!_isConnected) {
      // Queue message for later sending
      if (_messageQueue.length < _maxQueueSize) {
        _messageQueue.add(message);
        return 'queued';
      } else {
        throw Exception('WebSocket not connected and message queue is full');
      }
    }

    try {
      // Performance optimization: Compress large messages
      if (_compressionEnabled && message.length > _compressionThreshold) {
        final compressed = _compressMessage(message);
        _socket.add(compressed);
      } else {
        _socket.add(message);
      }
      return 'sent';
    } catch (e) {
      _isConnected = false;
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> _processQueuedMessages() async {
    while (_messageQueue.isNotEmpty && _isConnected) {
      final message = _messageQueue.removeAt(0);
      try {
        await send(message);
      } catch (e) {
        // Re-queue the message if send fails
        _messageQueue.insert(0, message);
        break;
      }
    }
  }

  // Performance optimization: Message compression methods
  Uint8List _compressMessage(String message) {
    final bytes = utf8.encode(message);
    return Uint8List.fromList(gzip.encode(bytes));
  }

  String _decompressMessage(Uint8List compressedData) {
    final decompressed = gzip.decode(compressedData);
    return utf8.decode(decompressed);
  }

  @override
  Stream<String> get onMessage => _controller.stream;

  @override
  void close() {
    _isConnected = false;
    _messageQueue.clear();
    _socket.close();
    _controller.close();
  }

  // Performance optimization: Add connection status and stats
  bool get isConnected => _isConnected;
  int get queuedMessageCount => _messageQueue.length;
  int get reconnectAttempts => _reconnectAttempts;
}
