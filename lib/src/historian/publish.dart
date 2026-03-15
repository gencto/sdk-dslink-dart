part of dsalink.historian;

class PublishValueAction extends SimpleNode {
  PublishValueAction(String path) : super(path);

  @override
  void onInvoke(DSAConfig params) {
    String inputPath = params.getString('Path');
    dynamic val = params['Value'];
    String? ts = params['Timestamp'] as String?;

    ts ??= ValueUpdate.getTs();

    if (inputPath.isEmpty) {
      throw 'Path not provided.';
    }

    var pathObj = Path(path);
    var tp = pathObj.parent.child(NodeNamer.createName(inputPath)).path;
    var node = _link[tp] as SimpleNode;

    WatchPathNode pn;
    if (node is! WatchPathNode) {
      final nodeConfig = NodeBuilder()
          .name(inputPath)
          .profile('watchPath')
          .type('dynamic')
          .build();

      // Add custom configs not in NodeBuilder
      nodeConfig[r'$publish'] = true;
      nodeConfig[r'$path'] = inputPath;

      pn = _link.addNode(tp, nodeConfig) as WatchPathNode;
      _link.saveAsync();
    } else {
      pn = node;
    }

    pn.doUpdate(ValueUpdate(val, ts: ts));
  }
}
