import 'package:dsalink/core/transport_contract.dart';
import 'package:dsalink/node/ds_node.dart';
import 'package:dsalink/responder/responder_router.dart';

class ResponderService {
  final ITransport transport;
  final DsNode root;
  late final ResponderRouter _router;

  ResponderService(this.transport, this.root) {
    _router = ResponderRouter(root, transport);
  }

  Future<void> start() async {
    await transport.connect();
    transport.onMessage.listen((msg) async {
      await _router.handle(msg);
    });
  }
}
