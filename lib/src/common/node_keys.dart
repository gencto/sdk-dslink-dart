part of dsalink.common;

/// Standard DSA node configuration keys.
///
/// These constants provide type-safe access to node configuration properties
/// that start with the '$' prefix in the DSA protocol.
///
/// Example usage:
/// ```dart
/// node.configs[NodeConfigKeys.type] = 'number';
/// node.configs[NodeConfigKeys.writable] = 'write';
/// ```
abstract class NodeConfigKeys {
  /// Node type configuration ($type)
  static const String type = r'$type';

  /// Node writability configuration ($writable)
  static const String writable = r'$writable';

  /// Action invokability configuration ($invokable)
  static const String invokable = r'$invokable';

  /// Action parameters configuration ($params)
  static const String params = r'$params';

  /// Action result columns configuration ($columns)
  static const String columns = r'$columns';

  /// Node profile reference ($is)
  static const String is_ = r'$is';

  /// Node display name ($name)
  static const String name = r'$name';

  /// Hidden node flag ($hidden)
  static const String hidden = r'$hidden';

  /// Action result type ($result)
  static const String result = r'$result';

  /// Node permissions ($permissions)
  static const String permissions = r'$permissions';

  /// Base path for profile resolution ($base)
  static const String base = r'$base';

  /// Disconnected timestamp ($disconnectedTs)
  static const String disconnectedTs = r'$disconnectedTs';

  /// Node mixin configurations ($mixin)
  static const String mixin = r'$mixin';

  /// Node settings ($settings)
  static const String settings = r'$settings';

  /// Node permission level ($permission)
  static const String permission = r'$permission';
}

/// Standard DSA node attribute keys.
///
/// These constants provide type-safe access to node attributes
/// that start with the '@' prefix in the DSA protocol.
///
/// Example usage:
/// ```dart
/// node.attributes[NodeAttributeKeys.icon] = 'temperature';
/// node.attributes[NodeAttributeKeys.unit] = 'celsius';
/// ```
abstract class NodeAttributeKeys {
  /// Node icon attribute (@icon)
  static const String icon = '@icon';

  /// Value unit attribute (@unit)
  static const String unit = '@unit';

  /// Node description (@description)
  static const String description = '@description';

  /// Node help text (@help)
  static const String help = '@help';

  /// Priority attribute (@priority)
  static const String priority = '@priority';
}

/// Standard DSA value key.
///
/// Example usage:
/// ```dart
/// var nodeData = {
///   NodeValueKey.value: 42,
/// };
/// ```
abstract class NodeValueKey {
  /// Node current value (?value)
  static const String value = '?value';
}
