part of dsalink.common;

/// Extension methods for better developer experience

/// Extensions for Map<String, dynamic> (DSA configs and messages)
extension DSAMapExtensions on Map<String, dynamic> {
  /// Get typed value from DSA config
  /// Returns null if key doesn't exist or value is not of type T
  T? getTyped<T>(String key) {
    final value = this[key];
    return value is T ? value : null;
  }

  /// Check if all required keys exist
  bool hasAll(Iterable<String> keys) => keys.every(containsKey);

  /// Get nested value using dot notation
  /// Example: getNestedValue('config.database.host')
  dynamic getNestedValue(String path) {
    final parts = path.split('.');
    dynamic current = this;

    for (final part in parts) {
      if (current is Map) {
        current = current[part];
      } else {
        return null;
      }
    }

    return current;
  }

  /// Safe string getter with default value
  String getString(String key, {String defaultValue = ''}) {
    return getTyped<String>(key) ?? defaultValue;
  }

  /// Safe int getter with default value
  int getInt(String key, {int defaultValue = 0}) {
    return getTyped<int>(key) ?? defaultValue;
  }

  /// Safe bool getter with default value
  bool getBool(String key, {bool defaultValue = false}) {
    return getTyped<bool>(key) ?? defaultValue;
  }

  /// Safe double getter with default value
  double getDouble(String key, {double defaultValue = 0.0}) {
    return getTyped<double>(key) ?? defaultValue;
  }

  /// Get list with type safety
  List<T>? getList<T>(String key) {
    final value = this[key];
    if (value is! List) return null;
    return value.whereType<T>().toList();
  }

  /// Get map with type safety
  Map<String, dynamic>? getMap(String key) {
    return getTyped<Map<String, dynamic>>(key);
  }
}

/// Extensions for String (DSA paths and names)
extension DSAStringExtensions on String {
  /// Regular Expression for invalid characters in DSA paths.
  static final RegExp _invalidChar = RegExp(r'[\\\?\*|"<>:]');

  /// Check if string is valid DSA path
  bool get isValidDSAPath {
    return !_invalidChar.hasMatch(this) && startsWith('/');
  }

  /// Escape string for DSA system
  String get escapedForDSA => Path.escapeName(this);

  /// Get display name from path
  String get displayName => Node.getDisplayName(this);

  /// Check if path is a config key (starts with $)
  bool get isConfigKey => startsWith(r'$');

  /// Check if path is an attribute key (starts with @)
  bool get isAttributeKey => startsWith('@');

  /// Check if path is a value key (starts with ?)
  bool get isValueKey => startsWith('?');

  /// Remove leading slash if exists
  String get withoutLeadingSlash {
    return startsWith('/') ? substring(1) : this;
  }

  /// Ensure path starts with /
  String get withLeadingSlash {
    return startsWith('/') ? this : '/$this';
  }

  /// Get parent path
  /// Example: '/a/b/c' -> '/a/b'
  String? get parentPath {
    if (this == '/' || !contains('/')) return null;
    final lastSlash = lastIndexOf('/');
    if (lastSlash <= 0) return '/';
    return substring(0, lastSlash);
  }

  /// Get node name from path
  /// Example: '/a/b/c' -> 'c'
  String get nodeName {
    if (this == '/') return '';
    final lastSlash = lastIndexOf('/');
    return substring(lastSlash + 1);
  }
}

/// Extensions for Stream
extension DSAStreamExtensions<T> on Stream<T> {
  /// Take with timeout, throws TimeoutException on timeout
  Stream<T> withTimeout(Duration duration) {
    return timeout(duration);
  }

  /// First value matching predicate with timeout
  Future<T> firstWhereWithTimeout(
    bool Function(T) test, {
    required Duration timeout,
    T Function()? orElse,
  }) async {
    return this
        .timeout(timeout)
        .firstWhere(test, orElse: orElse ?? () => throw StateError('No element'));
  }
}

/// Extensions for List
extension DSAListExtensions<T> on List<T> {
  /// Safe get element at index
  T? getAt(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Get first element or null
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last element or null
  T? get lastOrNull => isEmpty ? null : last;
}
