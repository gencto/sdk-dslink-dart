part of dslink.pk.dart;

late ECPrivateKey _cachedPrivate;
late ECPublicKey _cachedPublic;
int _cachedTime = -1;
String? cachedPrivateStr;

List<dynamic> generate(List<int> publicKeyRemote, String oldPriKeyStr) {
  ECPoint? publicPointRemote = _secp256r1.curve.decodePoint(publicKeyRemote);
  late ECPrivateKey privateKey;
  late ECPublicKey publicKey;
  int ts = (new DateTime.now()).millisecondsSinceEpoch;
  if (cachedPrivateStr == null ||
      ts - _cachedTime > 60000 ||
      oldPriKeyStr == cachedPrivateStr ||
      oldPriKeyStr == '') {
    var gen = new ECKeyGenerator();
    var rsapars = new ECKeyGeneratorParameters(_secp256r1);
    var params = new ParametersWithRandom(rsapars,
        DSRandomImpl());
    gen.init(params);
    var pair = gen.generateKeyPair();
    privateKey = pair.privateKey as ECPrivateKey;
    publicKey = pair.publicKey as ECPublicKey;
    if (oldPriKeyStr != '') {
      _cachedPrivate = pair.privateKey as ECPrivateKey;
      _cachedPublic = pair.publicKey as ECPublicKey;
      _cachedTime = ts;
    }
  } else {
    privateKey = _cachedPrivate;
    publicKey = _cachedPublic;
  }

  var Q2 = publicPointRemote! * privateKey.d;
  return [
    bigIntToBytes(privateKey.d!),
    publicKey.Q?.getEncoded(false),
    Q2?.getEncoded(false)
  ];
}

void _processECDH(SendPort initialReplyTo) {
  var response = new ReceivePort();
  initialReplyTo.send(response.sendPort);
  response.listen((msg) {
    if (msg is List && msg.length == 2) {
      initialReplyTo.send(generate(msg[0] as List<int>, msg[1].toString()));
    }
  });
}

class ECDHIsolate {
  static bool get running => _ecdh_isolate != null;
  static Isolate? _ecdh_isolate;
  static start() async {
    if (_ecdh_isolate != null) return;
    var response = new ReceivePort();
    _ecdh_isolate = await Isolate.spawn(_processECDH, response.sendPort);
    response.listen(_processResult);
    _checkRequest();
  }

  static late SendPort _isolatePort;
  static void _processResult(message) {
    if (message is SendPort) {
      _isolatePort = message;
    } else if (message is List) {
      if (_waitingReq != null && message.length == 3) {
        var d1 = readBytes(message[0]! as Uint8List);
        var Q1 = _secp256r1.curve.decodePoint(message[1] as List<int>);
        var Q2 = _secp256r1.curve.decodePoint(message[2] as List<int>);
        var ecdh = new ECDHImpl(
            new ECPrivateKey(d1, _secp256r1), new ECPublicKey(Q1, _secp256r1),
            Q2!);
        _waitingReq?._completer.complete(ecdh);
        _waitingReq = null;
      }
    }
    _checkRequest();
  }

  static ECDHIsolateRequest? _waitingReq;
  static void _checkRequest() {
    if (_waitingReq == null && _requests.length > 0) {
      _waitingReq = _requests.removeFirst();
      _isolatePort.send([
        _waitingReq!.publicKeyRemote.ecPublicKey.Q?.getEncoded(false),
        _waitingReq?.oldPrivate
      ]);
    }
  }

  static ListQueue<ECDHIsolateRequest> _requests =
      new ListQueue<ECDHIsolateRequest>();

  /// when oldprivate is '', don't use cache
  static Future<ECDH> _sendRequest(
      PublicKey publicKeyRemote, String? oldprivate) {
    var req = new ECDHIsolateRequest(publicKeyRemote as PublicKeyImpl, oldprivate);
    _requests.add(req);
    _checkRequest();
    return req.future;
  }
}

class ECDHIsolateRequest {
  PublicKeyImpl publicKeyRemote;
  String? oldPrivate;

  ECDHIsolateRequest(this.publicKeyRemote, this.oldPrivate);

  Completer<ECDH> _completer = new Completer<ECDH>();
  Future<ECDH> get future => _completer.future;
}
