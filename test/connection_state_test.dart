import 'package:test/test.dart';
import 'package:dsalink/common.dart';

void main() {
  group('ConnectionState', () {
    test('DisconnectedState properties', () {
      const state = DisconnectedState();
      expect(state.isDisconnected, isTrue);
      expect(state.isConnected, isFalse);
      expect(state.isConnecting, isFalse);
      expect(state.isError, isFalse);
      expect(state.toString(), equals('Disconnected'));
    });

    test('ConnectingState properties', () {
      const state = ConnectingState();
      expect(state.isDisconnected, isFalse);
      expect(state.isConnected, isFalse);
      expect(state.isConnecting, isTrue);
      expect(state.isError, isFalse);
      expect(state.toString(), equals('Connecting'));
    });

    test('ConnectedState properties', () {
      final now = DateTime.now();
      final state = ConnectedState(now);
      expect(state.isDisconnected, isFalse);
      expect(state.isConnected, isTrue);
      expect(state.isConnecting, isFalse);
      expect(state.isError, isFalse);
      expect(state.connectedAt, equals(now));
      expect(state.toString(), contains('Connected (since'));
    });

    test('ConnectionErrorState properties', () {
      final error = Exception('Failed');
      final state = ConnectionErrorState('Socket error', error);
      expect(state.isDisconnected, isFalse);
      expect(state.isConnected, isFalse);
      expect(state.isConnecting, isFalse);
      expect(state.isError, isTrue);
      expect(state.message, equals('Socket error'));
      expect(state.error, equals(error));
      expect(state.toString(), contains('ConnectionError: Socket error'));
    });

    test('Pattern matching with when', () {
      ConnectionState state = const DisconnectedState();
      
      String result = state.when(
        disconnected: () => 'offline',
        connecting: () => 'wait',
        connected: (at) => 'online',
        connectionError: (msg, err) => 'error',
      );
      expect(result, equals('offline'));

      state = ConnectedState(DateTime.now());
      result = state.when(
        disconnected: () => 'offline',
        connecting: () => 'wait',
        connected: (at) => 'online',
        connectionError: (msg, err) => 'error',
      );
      expect(result, equals('online'));
    });
  });
}
