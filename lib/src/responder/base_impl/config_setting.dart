part of dsalink.responder;

class ConfigSetting {
  final String name;
  final String type;

  /// need permission to read
  final Object? defaultValue;

  /// whether broker need to maintain the change of config value when ds link is offline
  // bool maintain

  ConfigSetting(this.name, this.type, {this.defaultValue});
  ConfigSetting.fromMap(this.name, Map m)
    : type = m.containsKey('type') ? m['type'] : 'string',
      defaultValue = m.containsKey('default') ? m['default'] : null;

  DSError? setConfig(Object value, LocalNodeImpl node, Responder responder) {
    if (node.configs[name] != value) {
      node.configs[name] = value;
      node.updateList(name);
    }
    return null;
  }

  DSError? removeConfig(LocalNodeImpl node, Responder responder) {
    if (node.configs.containsKey(name)) {
      node.configs.remove(name);
      node.updateList(name);
    }
    return null;
  }
}

class Configs {
  static const Map _globalConfigs = <String, dynamic>{
    r'$is': {'type': 'profile'},
    r'$interface': {'type': 'interface'},

    /// list of permissions
    r'$permissions': {
      'type': 'list',
      'require': Permission.CONFIG,
      'writable': Permission.CONFIG,
    },

    /// the display name
    r'$name': {'type': 'string'},

    /// type of subscription stream
    r'$type': {'type': 'type'},

    /// permission needed to invoke
    r'$invokable': {'type': 'permission', 'default': 'read'},

    /// permission needed to set
    r'$writable': {'type': 'permission', 'default': 'never'},

    /// config settings, only used by profile nodes
    r'$settings': {'type': 'map'},

    /// params of invoke method
    r'$params': {'type': 'list'},

    /// stream columns of invoke method
    r'$columns': {'type': 'list'},

    /// stream meta of invoke method
    r'$streamMeta': {'type': 'list'},
    // not serializable
  };

  static final Configs global = Configs()..load(_globalConfigs);
  static final ConfigSetting defaultConfig = ConfigSetting.fromMap(
    '',
    const <dynamic, dynamic>{},
  );

  static Object? getConfig(String name, Node? profile) {
    if (global.configs.containsKey(name)) {
      return global.configs[name];
    }
    if (profile is DefinitionNode && profile.configs.containsKey(name)) {
      return profile.configs[name];
    }
    return defaultConfig;
  }

  Map<String, ConfigSetting> configs = {};
  void load(Map inputs) {
    inputs.forEach((name, dynamic m) {
      if (m is Map) {
        configs[name] = ConfigSetting.fromMap(name, m);
      }
    });
  }
}
