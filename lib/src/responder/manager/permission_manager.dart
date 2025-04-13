part of dsalink.responder;

abstract class IPermissionManager {
  int getPermission(String? path, Responder resp);
}

class DummyPermissionManager implements IPermissionManager {
  @override
  int getPermission(String? path, Responder resp) {
    return Permission.CONFIG;
  }
}
