part of dsalink.utils;

class DsalinkJSON {
  Map? _json;

  Map? get json => _json;

  String? name;
  String? version;
  String? description;
  String? main;
  Map? engines = <String, dynamic>{};
  Map<String, Map> configs = {};
  List<String>? getDependencies = [];

  DsalinkJSON();

  factory DsalinkJSON.from(Map? map) {
    var j = DsalinkJSON();
    j._json = map;
    j.name = map?['name'];
    j.version = map?['version'];
    j.description = map?['description'];
    j.main = map?['main'];
    j.engines = map?['engines'] as Map;
    j.configs = map?['configs'] as Map<String, Map>;
    j.getDependencies = map?['getDependencies'] as List<String>;
    return j;
  }

  void verify() {
    if (name == null) {
      throw Exception('dsalink Name is required.');
    }

    if (main == null) {
      throw Exception('dsalink Main Script is required.');
    }
  }

  Map save() {
    verify();

    var map = Map.from(_json ?? <String, dynamic>{});
    map['name'] = name;
    map['version'] = version;
    map['description'] = description;
    map['main'] = main;
    map['engines'] = engines;
    map['configs'] = configs;
    map['getDependencies'] = getDependencies;
    for (var key in map.keys.toList()) {
      if (map[key] == null) {
        map.remove(key);
      }
    }
    return map;
  }
}
