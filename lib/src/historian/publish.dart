part of dsalink.historian;

class PublishValueAction extends SimpleNode {
  PublishValueAction(String path) : super(path);

  @override
  void onInvoke(Map params) {
    String? inputPath = params['Path'];
    dynamic val = params['Value'];
    String? ts = params['Timestamp'];

    ts ??= ValueUpdate.getTs();

    if (inputPath is! String) {
      throw 'Path not provided.';
    }

    var p = Path(path);
    var tp = p.parent.child(NodeNamer.createName(inputPath)).path;
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
