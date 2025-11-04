part of dsalink.common;

/// DSA protocol methods for request/response communication
///
/// Represents the available methods that can be invoked in DSA protocol.
/// This enum provides type safety and compile-time checking instead of
/// using string comparisons.
enum DSAMethod {
  /// List nodes and their children
  list,

  /// Subscribe to value updates
  subscribe,

  /// Unsubscribe from value updates
  unsubscribe,

  /// Invoke an action
  invoke,

  /// Set a node value
  set,

  /// Remove a node
  remove,

  /// Close a stream/request
  close;

  /// Parse DSA method from string
  ///
  /// Returns null if the string doesn't match any known method.
  /// This is used for backwards compatibility with string-based protocol.
  static DSAMethod? fromString(String? value) {
    if (value == null) return null;

    return switch (value) {
      'list' => DSAMethod.list,
      'subscribe' => DSAMethod.subscribe,
      'unsubscribe' => DSAMethod.unsubscribe,
      'invoke' => DSAMethod.invoke,
      'set' => DSAMethod.set,
      'remove' => DSAMethod.remove,
      'close' => DSAMethod.close,
      _ => null,
    };
  }

  /// Convert to protocol string
  ///
  /// Returns the string representation used in DSA protocol messages.
  String toProtocolString() => name;

  /// Check if method is a subscription-related method
  bool get isSubscriptionMethod =>
      this == DSAMethod.subscribe || this == DSAMethod.unsubscribe;

  /// Check if method modifies data
  bool get isMutationMethod =>
      this == DSAMethod.set || this == DSAMethod.remove;

  /// Check if method is read-only
  bool get isReadOnly =>
      this == DSAMethod.list ||
      this == DSAMethod.subscribe ||
      this == DSAMethod.unsubscribe;
}
