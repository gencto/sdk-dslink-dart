part of dslink.responder;

typedef InvokeCallback = InvokeResponse Function(Map params,
    Responder responder, InvokeResponse response, LocalNode? parentNode);

/// definition nodes are serializable node that won"t change
/// the only change will be a global upgrade
class DefinitionNode extends LocalNodeImpl {
  @override
  final NodeProvider provider;

  DefinitionNode(String path, this.provider) : super(path) {
    configs[r'$is'] = 'static';
  }

  InvokeCallback? _invokeCallback;

  void setInvokeCallback(InvokeCallback callback) {
    _invokeCallback = callback;
  }

  @override
  InvokeResponse invoke(Map params, Responder responder,
      InvokeResponse response, Node? parentNode,
      [int maxPermission = Permission.CONFIG]) {
    if (_invokeCallback == null) {
      return response..close(DSError.NOT_IMPLEMENTED);
    }

    var parentPath = parentNode is LocalNode ? parentNode.path : null;

    var permission =
        responder.nodeProvider.permissions.getPermission(parentPath, responder);

    if (maxPermission < permission) {
      permission = maxPermission;
    }

    if (getInvokePermission() <= permission) {
      _invokeCallback!(params, responder, response, parentNode as LocalNode?);
      return response;
    } else {
      return response..close(DSError.PERMISSION_DENIED);
    }
  }
}
