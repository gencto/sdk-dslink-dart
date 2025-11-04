part of dsalink.common;

/// A fluent builder for creating DSA node configurations.
///
/// The NodeBuilder provides a type-safe, readable way to construct node
/// configurations using method chaining. It eliminates magic strings and
/// provides better IDE support with autocomplete.
///
/// Example:
/// ```dart
/// // Create a simple value node
/// var config = NodeBuilder()
///   .type('number')
///   .writable()
///   .value(42)
///   .build();
///
/// // Create an action node
/// var actionConfig = NodeBuilder.action()
///   .param('input', 'string')
///   .param('count', 'int', defaultValue: 1)
///   .column('output', 'string')
///   .column('timestamp', 'string')
///   .build();
/// ```
class NodeBuilder {
  final Map<String, dynamic> _config = {};
  final List<Map<String, dynamic>> _params = [];
  final List<Map<String, dynamic>> _columns = [];

  /// Creates a new empty NodeBuilder.
  NodeBuilder();

  /// Creates a NodeBuilder for an action node.
  ///
  /// This is a convenience constructor that automatically sets
  /// invokable permission to 'read'.
  factory NodeBuilder.action() {
    return NodeBuilder().invokable('read');
  }

  /// Creates a NodeBuilder for a value node with the specified type.
  ///
  /// Example:
  /// ```dart
  /// var numberNode = NodeBuilder.value('number')
  ///   .writable()
  ///   .value(0)
  ///   .build();
  /// ```
  factory NodeBuilder.value(String type) {
    return NodeBuilder().type(type);
  }

  /// Sets the node type ($type).
  ///
  /// Common types: 'number', 'int', 'string', 'bool', 'array', 'map', 'dynamic'
  NodeBuilder type(String type) {
    _config[NodeConfigKeys.type] = type;
    return this;
  }

  /// Sets the node display name ($name).
  NodeBuilder name(String name) {
    _config[NodeConfigKeys.name] = name;
    return this;
  }

  /// Sets the node writable permission ($writable).
  ///
  /// If [permission] is not specified, defaults to 'write'.
  /// Use 'write', 'config', or 'never'.
  NodeBuilder writable([String permission = 'write']) {
    _config[NodeConfigKeys.writable] = permission;
    return this;
  }

  /// Sets the node invokable permission ($invokable).
  ///
  /// If [permission] is not specified, defaults to 'read'.
  /// Use 'read', 'write', 'config', or 'never'.
  NodeBuilder invokable([String permission = 'read']) {
    _config[NodeConfigKeys.invokable] = permission;
    return this;
  }

  /// Sets the node profile ($is).
  ///
  /// Example: `profile('myProfile')` or `profile('/defs/profile/customProfile')`
  NodeBuilder profile(String profileName) {
    _config[NodeConfigKeys.is_] = profileName;
    return this;
  }

  /// Marks the node as hidden ($hidden = true).
  NodeBuilder hidden() {
    _config[NodeConfigKeys.hidden] = true;
    return this;
  }

  /// Sets the result type for action nodes ($result).
  ///
  /// Use 'values', 'table', or 'stream'.
  NodeBuilder resultType(String type) {
    _config[NodeConfigKeys.result] = type;
    return this;
  }

  /// Adds a parameter to an action node ($params).
  ///
  /// [name] - parameter name
  /// [type] - parameter type (e.g., 'string', 'number', 'int', 'bool')
  /// [defaultValue] - optional default value
  /// [placeholder] - optional placeholder text
  /// [description] - optional parameter description
  ///
  /// Example:
  /// ```dart
  /// builder
  ///   .param('username', 'string', placeholder: 'Enter username')
  ///   .param('age', 'int', defaultValue: 18)
  ///   .param('active', 'bool', defaultValue: true);
  /// ```
  NodeBuilder param(
    String name,
    String type, {
    dynamic defaultValue,
    String? placeholder,
    String? description,
  }) {
    var paramDef = <String, dynamic>{
      'name': name,
      'type': type,
    };

    if (defaultValue != null) {
      paramDef['default'] = defaultValue;
    }
    if (placeholder != null) {
      paramDef['placeholder'] = placeholder;
    }
    if (description != null) {
      paramDef['description'] = description;
    }

    _params.add(paramDef);
    return this;
  }

  /// Adds a result column to an action node ($columns).
  ///
  /// [name] - column name
  /// [type] - column type (e.g., 'string', 'number', 'int', 'bool')
  ///
  /// Example:
  /// ```dart
  /// builder
  ///   .column('id', 'string')
  ///   .column('count', 'number')
  ///   .column('timestamp', 'string');
  /// ```
  NodeBuilder column(String name, String type) {
    _columns.add({
      'name': name,
      'type': type,
    });
    return this;
  }

  /// Sets the initial value of the node (?value).
  ///
  /// Example:
  /// ```dart
  /// NodeBuilder.value('number').value(42).build();
  /// NodeBuilder.value('string').value('Hello').build();
  /// ```
  NodeBuilder value(dynamic value) {
    _config[NodeValueKey.value] = value;
    return this;
  }

  /// Adds an attribute to the node (@attribute).
  ///
  /// Example:
  /// ```dart
  /// builder
  ///   .attribute('icon', 'temperature')
  ///   .attribute('unit', 'celsius');
  /// ```
  NodeBuilder attribute(String name, dynamic value) {
    if (!name.startsWith('@')) {
      name = '@$name';
    }
    _config[name] = value;
    return this;
  }

  /// Sets the icon attribute (@icon).
  ///
  /// Convenience method for `attribute('icon', iconName)`.
  NodeBuilder icon(String iconName) {
    return attribute(NodeAttributeKeys.icon, iconName);
  }

  /// Sets the unit attribute (@unit).
  ///
  /// Convenience method for `attribute('unit', unitName)`.
  NodeBuilder unit(String unitName) {
    return attribute(NodeAttributeKeys.unit, unitName);
    }

  /// Sets the description attribute (@description).
  NodeBuilder description(String text) {
    return attribute(NodeAttributeKeys.description, text);
  }

  /// Adds a child node definition.
  ///
  /// [name] - child node name
  /// [childConfig] - child node configuration (can be from another NodeBuilder)
  ///
  /// Example:
  /// ```dart
  /// var parent = NodeBuilder()
  ///   .child('temperature', NodeBuilder.value('number').value(20).build())
  ///   .child('humidity', NodeBuilder.value('number').value(65).build())
  ///   .build();
  /// ```
  NodeBuilder child(String name, Map<String, dynamic> childConfig) {
    _config[name] = childConfig;
    return this;
  }

  /// Merges additional configuration directly.
  ///
  /// Use this for advanced configurations not covered by builder methods.
  ///
  /// Example:
  /// ```dart
  /// builder.merge({
  ///   r'$customConfig': 'customValue',
  ///   r'$advanced': {'nested': 'data'}
  /// });
  /// ```
  NodeBuilder merge(Map<String, dynamic> config) {
    _config.addAll(config);
    return this;
  }

  /// Builds and returns the final node configuration as a Map.
  ///
  /// This method finalizes the configuration by adding params and columns
  /// if they were defined, and returns the complete configuration map.
  ///
  /// The returned map can be used with:
  /// - `LinkProvider.addNode(path, config)`
  /// - `SimpleNode.load(config)`
  /// - Node definition in defaultNodes
  Map<String, dynamic> build() {
    var result = Map<String, dynamic>.from(_config);

    if (_params.isNotEmpty) {
      result[NodeConfigKeys.params] = _params;
    }

    if (_columns.isNotEmpty) {
      result[NodeConfigKeys.columns] = _columns;
    }

    return result;
  }

  /// Builds the configuration and converts it to JSON string.
  ///
  /// Useful for debugging or serialization.
  String toJson({bool pretty = false}) {
    return DsaJson.encode(build(), pretty: pretty);
  }
}
