import 'package:dsalink/node/ds_node.dart';

abstract class NodeAction {
  Future<dynamic> invoke(Map<String, dynamic> params, DsNode context);
}
