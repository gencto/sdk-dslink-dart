part of dsalink.historian;

class CreateWatchGroupNode extends SimpleNode {
  CreateWatchGroupNode(String path)
    : super(path, _link.provider as SimpleNodeProvider?);

  @override
  void onInvoke(DSAConfig params) async {
    String name = params.getString('Name');
    var realName = NodeNamer.createName(name);

    var path = Path(this.path);

    _link.addNode(
      '${path.parentPath}/$realName',
      NodeBuilder()
          .profile('watchGroup')
          .name(name)
          .build(),
    );
    _link.saveAsync();
  }
}

class AddDatabaseNode extends SimpleNode {
  AddDatabaseNode(String path)
    : super(path, _link.provider as SimpleNodeProvider?);

  @override
  void onInvoke(DSAConfig params) async {
    String name = params.getString('Name');
    var realName = NodeNamer.createName(name);

    final nodeConfig = NodeBuilder()
        .profile('database')
        .name(name)
        .build();

    // Add custom db config
    nodeConfig[r'$$db_config'] = params;

    _link.addNode('/$realName', nodeConfig);
    await _link.saveAsync();
  }
}

class AddWatchPathNode extends SimpleNode {
  AddWatchPathNode(String path) : super(path);

  @override
  void onInvoke(DSAConfig params) async {
    String wp = params.getString('Path');
    var rp = NodeNamer.createName(wp);
    var pathObj = Path(path);
    var targetPath = '${pathObj.parentPath}/$rp';
    var node = await _link.requester?.getRemoteNode(wp);

    final nodeConfig = NodeBuilder()
        .name(wp)
        .profile('watchPath')
        .type(node?.configs[NodeConfigKeys.type])
        .build();

    // Add custom path config
    nodeConfig[r'$path'] = wp;

    _link.addNode(targetPath, nodeConfig);
    _link.saveAsync();
  }
}

class PurgePathNode extends SimpleNode {
  PurgePathNode(String path) : super(path);

  @override
  Future<void> onInvoke(DSAConfig params) async {
    var tr = parseTimeRange(params.getString('timeRange'));
    if (tr == null) {
      return;
    }

    var watchPathNode = _link[Path(path).parentPath] as WatchPathNode;
    await watchPathNode.group?.db?.database?.purgePath(
      watchPathNode.group!._watchName!,
      watchPathNode.valuePath!,
      tr,
    );
  }
}

class PurgeGroupNode extends SimpleNode {
  PurgeGroupNode(String path) : super(path);

  @override
  Future<void> onInvoke(DSAConfig params) async {
    var tr = parseTimeRange(params.getString('timeRange'));
    if (tr == null) {
      return;
    }

    var watchGroupNode = _link[Path(path).parentPath] as WatchGroupNode;
    await watchGroupNode.db?.database?.purgeGroup(
      watchGroupNode._watchName!,
      tr,
    );
  }
}
