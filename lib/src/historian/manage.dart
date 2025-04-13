part of dslink.historian;

class CreateWatchGroupNode extends SimpleNode {
  CreateWatchGroupNode(String path)
      : super(path, _link.provider as SimpleNodeProvider?);

  @override
  void onInvoke(Map params) async {
    String name = params['Name'];
    var realName = NodeNamer.createName(name);

    var p = Path(path);

    _link.addNode('${p.parentPath}/$realName',
        <String, dynamic>{r'$is': 'watchGroup', r'$name': name});
    _link.save();
  }
}

class AddDatabaseNode extends SimpleNode {
  AddDatabaseNode(String path)
      : super(path, _link.provider as SimpleNodeProvider?);

  @override
  void onInvoke(Map params) async {
    String name = params['Name'];
    var realName = NodeNamer.createName(name);

    _link.addNode('/$realName', <String, dynamic>{
      r'$is': 'database',
      r'$name': name,
      r'$$db_config': params
    });
    _link.save();
  }
}

class AddWatchPathNode extends SimpleNode {
  AddWatchPathNode(String path) : super(path);

  @override
  void onInvoke(Map params) async {
    String wp = params['Path'];
    var rp = NodeNamer.createName(wp);
    var p = Path(path);
    var targetPath = '${p.parentPath}/$rp';
    var node = await _link.requester?.getRemoteNode(wp);
    _link.addNode(targetPath, <String, dynamic>{
      r'$name': wp,
      r'$path': wp,
      r'$is': 'watchPath',
      r'$type': node?.configs[r'$type']
    });

    _link.save();
  }
}

class PurgePathNode extends SimpleNode {
  PurgePathNode(String path) : super(path);

  @override
  Future<void> onInvoke(Map params) async {
    var tr = parseTimeRange(params['timeRange']);
    if (tr == null) {
      return;
    }

    var watchPathNode = _link[Path(path).parentPath] as WatchPathNode;
    await watchPathNode.group?.db?.database?.purgePath(
        watchPathNode.group!._watchName!, watchPathNode.valuePath!, tr);
  }
}

class PurgeGroupNode extends SimpleNode {
  PurgeGroupNode(String path) : super(path);

  @override
  Future<void> onInvoke(Map params) async {
    var tr = parseTimeRange(params['timeRange']);
    if (tr == null) {
      return;
    }

    var watchGroupNode = _link[Path(path).parentPath] as WatchGroupNode;
    await watchGroupNode.db?.database
        ?.purgeGroup(watchGroupNode._watchName!, tr);
  }
}
