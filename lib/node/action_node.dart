import 'package:dsalink/node/ds_node.dart';
import 'package:dsalink/node/node_action.dart';

class ActionNode extends DsNode {
  ActionNode(super.name, Future<dynamic> Function(Map<String, dynamic>) handler)
    : super(action: _WrapperAction(handler));
}

class _WrapperAction implements NodeAction {
  _WrapperAction(this.handler);
  final Future<dynamic> Function(Map<String, dynamic>) handler;

  @override
  Future<dynamic> invoke(Map<String, dynamic> params, DsNode context) =>
      handler(params);
}
