part of dslink.nodes;

class DsaJsonNode extends SimpleNode {
  DsaJsonNode(String path, [SimpleNodeProvider? provider]) :
      super(path, provider);

  dynamic _json;

  void init(dynamic value) {
    load(buildNodeMap(value));
    _json = value;
  }

  void updateJsonValue(dynamic input) {
    if (input is! Map) {
      updateValue(input);
      _json = input;

      var type = _guessType(input);

      var lastType = configs[r'$type'] as String?;

      if (lastType != type) {
        configs[r'$type'] = type;
        updateList(r'$type');
      }

      return;
    }

    clearValue();
    var differ = JsonDiffer(
      json.encode(_json),
      json.encode(input)
    );

    var fullDiff = differ.diff();

    void apply(DiffNode diff, DsaJsonNode? node) {
      for (var key in diff.added.keys.cast<String>()) {
        var name = NodeNamer.createName(key);
        provider.addNode(
          '${node?.path}/$name',
          buildNodeMap(diff.added[key])
        );
        node?.updateList(r'$is');
      }

      for (var key in diff.removed.keys.cast<String>()) {
        var name = NodeNamer.createName(key);

        provider.removeNode('${node?.path}/$name');
      }

      for (var key in diff.changed.keys.cast<String>()) {
        var name = NodeNamer.createName(key);

        var child = node?.getChild(name) as DsaJsonNode?;

        if (child == null) {
          child = provider.addNode(
            '${node?.path}/$name',
            buildNodeMap(diff.changed[key]?[1])
          ) as DsaJsonNode?;
        } else {
          child.updateJsonValue(diff.changed[key]?[1]);
        }
      }

      for (var key in diff.node.keys.cast<String>()) {
        var name = NodeNamer.createName(key);

        var child = node?.getChild(name) as DsaJsonNode?;

        child ??= provider.addNode('${node?.path}/$name', buildNodeMap(<String, dynamic>{})) as DsaJsonNode?;

        apply(diff.node[key]!, child);
      }
    }

    apply(fullDiff, this);

    _json = input;
  }

  @override
  void load(Map m) {
    super.load(m);

    if (m['?json'] != null) {
      init(m['?json']);
    }

    if (m['?_json'] != null) {
      updateJsonValue(m['?_json']);
    }
  }

  @override
  Map save() {
    var data = super.save();
    data['?json'] = _json;
    return data;
  }

  static String _guessType(dynamic input) {
    if (input is String) {
      return 'string';
    } else if (input is num) {
      return 'number';
    } else if (input is bool) {
      return 'bool';
    } else {
      return 'dynamic';
    }
  }

  static Map<String, dynamic> buildNodeMap(dynamic input) {
    Map<String, dynamic> create(dynamic value) {
      if (value is Map) {
        var m = <String, dynamic>{
          r'$is': 'json'
        };

        for (String key in value.keys) {
          m[NodeNamer.createName(key)] = create(value[key]);
        }

        return m;
      } else if (value is List && value.every((dynamic e) => e is Map || e is List)) {
        var m = <String, dynamic>{};
        for (var i = 0; i < value.length; i++) {
          m[i.toString()] = create(value[i]);
        }
        return m;
      } else {
        return <String, dynamic>{
          r'$is': 'json',
          r'$type': _guessType(value),
          '?_json': value
        };
      }
    }

    return create(input);
  }
}
