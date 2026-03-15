part of dsalink.common;

/// Type-safe wrapper for DSA configuration and parameter maps.
/// Provides compile-time type safety while maintaining lazy Map access.
class DSAConfig implements Map<String, dynamic> {
  final Map<String, dynamic> _data;

  DSAConfig([Map<String, dynamic>? data]) : _data = data ?? {};

  DSAConfig.from(Map data) : _data = Map<String, dynamic>.from(data);

  /// Access underlying map value
  @override
  dynamic operator [](Object? key) => _data[key];

  /// Set underlying map value
  @override
  void operator []=(String key, dynamic value) => _data[key] = value;

  /// Check if key exists
  @override
  bool containsKey(Object? key) => _data.containsKey(key);

  /// Check if value exists
  @override
  bool containsValue(Object? value) => _data.containsValue(value);

  /// Get all keys
  @override
  Iterable<String> get keys => _data.keys;

  /// Get all values
  @override
  Iterable<dynamic> get values => _data.values;

  /// Get all entries
  @override
  Iterable<MapEntry<String, dynamic>> get entries => _data.entries;

  /// Get raw map (for serialization)
  Map<String, dynamic> toMap() => _data;

  /// Iterate over entries
  @override
  void forEach(void Function(String key, dynamic value) action) {
    _data.forEach(action);
  }

  @override
  String toString() => _data.toString();

  @override
  void addAll(Map<String, dynamic> other) => _data.addAll(other);

  @override
  void addEntries(Iterable<MapEntry<String, dynamic>> newEntries) =>
      _data.addEntries(newEntries);

  @override
  Map<RK, RV> cast<RK, RV>() => _data.cast<RK, RV>();

  @override
  void clear() => _data.clear();

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  int get length => _data.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(String, dynamic) convert) =>
      _data.map(convert);

  @override
  dynamic putIfAbsent(String key, dynamic Function() ifAbsent) =>
      _data.putIfAbsent(key, ifAbsent);

  @override
  dynamic remove(Object? key) => _data.remove(key);

  @override
  void removeWhere(bool Function(String, dynamic) test) =>
      _data.removeWhere(test);

  @override
  dynamic update(String key, dynamic Function(dynamic) update,
          {dynamic Function()? ifAbsent}) =>
      _data.update(key, update, ifAbsent: ifAbsent);

  @override
  void updateAll(dynamic Function(String, dynamic) update) =>
      _data.updateAll(update);
}

/// Type-safe wrapper for DSA protocol messages (requests/responses).
/// Provides compile-time type safety while maintaining lazy Map access.
class DSAMessage implements Map<String, dynamic> {
  final Map<String, dynamic> _data;

  DSAMessage([Map<String, dynamic>? data]) : _data = data ?? {};

  DSAMessage.from(Map data) : _data = Map<String, dynamic>.from(data);

  /// Access underlying map value
  @override
  dynamic operator [](Object? key) => _data[key];

  /// Set underlying map value
  @override
  void operator []=(String key, dynamic value) => _data[key] = value;

  /// Check if key exists
  @override
  bool containsKey(Object? key) => _data.containsKey(key);

  /// Check if value exists
  @override
  bool containsValue(Object? value) => _data.containsValue(value);

  /// Get all keys
  @override
  Iterable<String> get keys => _data.keys;

  /// Get all values
  @override
  Iterable<dynamic> get values => _data.values;

  /// Get all entries
  @override
  Iterable<MapEntry<String, dynamic>> get entries => _data.entries;

  /// Get raw map (for serialization)
  Map<String, dynamic> toMap() => _data;

  /// Iterate over entries
  @override
  void forEach(void Function(String key, dynamic value) action) {
    _data.forEach(action);
  }

  @override
  String toString() => _data.toString();

  @override
  void addAll(Map<String, dynamic> other) => _data.addAll(other);

  @override
  void addEntries(Iterable<MapEntry<String, dynamic>> newEntries) =>
      _data.addEntries(newEntries);

  @override
  Map<RK, RV> cast<RK, RV>() => _data.cast<RK, RV>();

  @override
  void clear() => _data.clear();

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  int get length => _data.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(String, dynamic) convert) =>
      _data.map(convert);

  @override
  dynamic putIfAbsent(String key, dynamic Function() ifAbsent) =>
      _data.putIfAbsent(key, ifAbsent);

  @override
  dynamic remove(Object? key) => _data.remove(key);

  @override
  void removeWhere(bool Function(String, dynamic) test) =>
      _data.removeWhere(test);

  @override
  dynamic update(String key, dynamic Function(dynamic) update,
          {dynamic Function()? ifAbsent}) =>
      _data.update(key, update, ifAbsent: ifAbsent);

  @override
  void updateAll(dynamic Function(String, dynamic) update) =>
      _data.updateAll(update);
}

/// Command line options
typedef CommandLineOptions = Map<String, dynamic>;
