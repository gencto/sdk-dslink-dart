part of dsalink.common;

/// Represents the various states of a DSA connection.
/// 
/// Using a sealed class allows for exhaustive pattern matching to ensure
/// all possible connection states are handled by the application logic.
sealed class ConnectionState {
  const ConnectionState();

  /// Pattern match on the connection state
  R when<R>({
    required R Function() disconnected,
    required R Function() connecting,
    required R Function(DateTime connectedAt) connected,
    required R Function(String message, Object? error) connectionError,
  }) =>
      switch (this) {
        DisconnectedState() => disconnected(),
        ConnectingState() => connecting(),
        ConnectedState(:final connectedAt) => connected(connectedAt),
        ConnectionErrorState(:final message, :final error) => connectionError(message, error),
      };

  bool get isConnected => this is ConnectedState;
  bool get isDisconnected => this is DisconnectedState;
  bool get isConnecting => this is ConnectingState;
  bool get isError => this is ConnectionErrorState;
}

/// The connection is currently closed.
final class DisconnectedState extends ConnectionState {
  const DisconnectedState();
  @override
  String toString() => 'Disconnected';
}

/// The connection is in the process of being established.
final class ConnectingState extends ConnectionState {
  const ConnectingState();
  @override
  String toString() => 'Connecting';
}

/// The connection is successfully established and ready for data transfer.
final class ConnectedState extends ConnectionState {
  final DateTime connectedAt;
  ConnectedState(this.connectedAt);
  @override
  String toString() => 'Connected (since $connectedAt)';
}

/// An error occurred during connection or while connected.
final class ConnectionErrorState extends ConnectionState {
  final String message;
  final Object? error;
  ConnectionErrorState(this.message, [this.error]);
  @override
  String toString() => 'ConnectionError: $message${error != null ? ' ($error)' : ''}';
}
