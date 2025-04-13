part of dslink.historian;

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
      pn = _link.addNode(tp, <String, dynamic>{
        r'$name': inputPath,
        r'$is': 'watchPath',
        r'$publish': true,
        r'$type': 'dynamic',
        r'$path': inputPath
      }) as WatchPathNode;
      _link.save();
    } else {
      pn = node;
    }

    pn.doUpdate(ValueUpdate(val, ts: ts));
  }
}
