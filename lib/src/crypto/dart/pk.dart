library dslink.pk.dart;

import "dart:async";
import "dart:convert";
import "dart:collection";
import "dart:typed_data";
import "dart:math" as Math;
import "dart:isolate";




import "package:pointycastle/block/aes.dart";

import "../pk.dart";
import "../../../utils.dart";
import '../big_int_utils.dart';

import 'package:pointycastle/ecc/curves/secp256r1.dart';
import 'package:pointycastle/api.dart' hide PublicKey, PrivateKey;
import 'package:pointycastle/ecc/api.dart';
import "package:pointycastle/digests/sha256.dart";
import "package:pointycastle/key_generators/ec_key_generator.dart";
import "package:pointycastle/key_generators/api.dart";
import "package:pointycastle/random/block_ctr_random.dart";


part "isolate.dart";

/// hard code the EC curve data here, so the compiler don"t have to register all curves
ECDomainParameters get _secp256r1 => ECCurve_secp256r1();

class DartCryptoProvider implements CryptoProvider {
  static final DartCryptoProvider INSTANCE = new DartCryptoProvider();
  final DSRandomImpl random = new DSRandomImpl();

  ECPrivateKey? _cachedPrivate;
  ECPublicKey? _cachedPublic;
  int _cachedTime = -1;

  Future<ECDH> assign(PublicKey publicKeyRemote, ECDH old) async {
    if (ECDHIsolate.running) {
      if (old is ECDHImpl) {
        return ECDHIsolate._sendRequest(
            publicKeyRemote, old._ecPrivateKey.d!.toRadixString(16));
      } else {
        return ECDHIsolate._sendRequest(publicKeyRemote, null);
      }
    }
    int ts = (new DateTime.now()).millisecondsSinceEpoch;

    /// reuse same ECDH server pair for up to 1 minute
    if (_cachedPrivate == null ||
        ts - _cachedTime > 60000 ||
        (old is ECDHImpl && old._ecPrivateKey == _cachedPrivate)) {
      var gen = new ECKeyGenerator();
      var rsapars = new ECKeyGeneratorParameters(_secp256r1);
      var params = new ParametersWithRandom(rsapars, DSRandomImpl());
      gen.init(params);
      var pair = gen.generateKeyPair();
      _cachedPrivate = pair.privateKey as ECPrivateKey?;
      _cachedPublic = pair.publicKey as ECPublicKey?;
      _cachedTime = ts;
    }

    PublicKeyImpl? publicKeyRemoteImpl;

    if (publicKeyRemote is! PublicKeyImpl) {
      throw "Not a PublicKeyImpl: ${publicKeyRemoteImpl}";
    } else {
      publicKeyRemoteImpl = publicKeyRemote;
    }

    var Q2 = publicKeyRemoteImpl.ecPublicKey.Q! * _cachedPrivate?.d!;
    return new ECDHImpl(_cachedPrivate!, _cachedPublic!, Q2!);
  }

  Future<ECDH> getSecret(PublicKey publicKeyRemote) async {
    if (ECDHIsolate.running) {
      return ECDHIsolate._sendRequest(publicKeyRemote, "");
    }
    var gen = new ECKeyGenerator();
    var rsapars = new ECKeyGeneratorParameters(_secp256r1);
    var params = new ParametersWithRandom(rsapars, random);
    gen.init(params);
    var pair = gen.generateKeyPair()
      as AsymmetricKeyPair<ECPublicKey, ECPrivateKey>;

    PublicKeyImpl? publicKeyRemoteImpl;

    if (publicKeyRemote is! PublicKeyImpl) {
      throw "Not a PublicKeyImpl: ${publicKeyRemoteImpl}";
    } else {
      publicKeyRemoteImpl = publicKeyRemote;
    }

    var Q2 = publicKeyRemoteImpl.ecPublicKey.Q! * pair.privateKey.d;
    return new ECDHImpl(pair.privateKey, pair.publicKey, Q2!);
  }

  Future<PrivateKey> generate() async {
    return generateSync();
  }

  PrivateKey generateSync() {
    var gen = new ECKeyGenerator();
    var rsapars = new ECKeyGeneratorParameters(_secp256r1);
    var params = new ParametersWithRandom(rsapars, random);
    gen.init(params);
    var pair = gen.generateKeyPair();
    return new PrivateKeyImpl(pair.privateKey as ECPrivateKey, pair.publicKey as ECPublicKey?);
  }

  PrivateKey loadFromString(String str) {
    if (str.contains(" ")) {
      List ss = str.split(" ");
      var d = readBytes(Base64.decode(ss[0])!);
      ECPrivateKey pri = new ECPrivateKey(d, _secp256r1);
      var Q = _secp256r1.curve.decodePoint(Base64.decode(ss[1]) as List<int>);
      ECPublicKey pub = new ECPublicKey(Q, _secp256r1);
      return new PrivateKeyImpl(pri, pub);
    } else {
      var decode = Base64.decode(str);
      var d = readBytes(decode!);
      ECPrivateKey pri = new ECPrivateKey(d, _secp256r1);
      return new PrivateKeyImpl(pri);
    }
  }

  PublicKey getKeyFromBytes(Uint8List bytes) {
    ECPoint? Q = _secp256r1.curve.decodePoint(bytes);
    return new PublicKeyImpl(new ECPublicKey(Q, _secp256r1));
  }

  String base64_sha256(Uint8List bytes) {
    SHA256Digest sha256 = new SHA256Digest();
    Uint8List hashed = sha256.process(new Uint8List.fromList(bytes));
    return Base64.encode(hashed);
  }
}

class ECDHImpl extends ECDH {
  String get encodedPublicKey => Base64.encode(_ecPublicKey.Q!.getEncoded(false));

  late Uint8List bytes;

  ECPrivateKey _ecPrivateKey;
  ECPublicKey _ecPublicKey;

  ECDHImpl(this._ecPrivateKey, this._ecPublicKey, ECPoint Q2) {
    //var Q2 = _ecPublicKeyRemote.Q * _ecPrivateKey.d;
    bytes = bigintToUint8List(Q2.x!.toBigInteger()!);
    if (bytes.length > 32) {
      bytes = bytes.sublist(bytes.length - 32);
    } else if (bytes.length < 32) {
      var newbytes = new Uint8List(32);
      int dlen = 32 - bytes.length;
      for (int i = 0; i < bytes.length; ++i) {
        newbytes[i + dlen] = bytes[i];
      }
      for (int i = 0; i < dlen; ++i) {
        newbytes[i] = 0;
      }
      bytes = newbytes;
    }
  }

  String hashSalt(String salt) {
    List<int> encoded = utf8.encode(salt);
    Uint8List raw = new Uint8List(encoded.length + bytes.length);
    int i;
    for (i = 0; i < encoded.length; i++) {
      raw[i] = encoded[i];
    }

    for (var x = 0; x < bytes.length; x++) {
      raw[i] = bytes[x];
      i++;
    }
    SHA256Digest sha256 = new SHA256Digest();
    var hashed = sha256.process(raw);
    return Base64.encode(hashed);
  }
}

class PublicKeyImpl extends PublicKey {
  static final BigInt publicExp = BigInt.from(65537);

  ECPublicKey ecPublicKey;
  late String qBase64;
  late String qHash64;

  PublicKeyImpl(this.ecPublicKey) {
    Uint8List bytes = ecPublicKey.Q!.getEncoded(false);
    qBase64 = Base64.encode(bytes);
    SHA256Digest sha256 = new SHA256Digest();
    qHash64 = Base64.encode(sha256.process(bytes));
  }
}

class PrivateKeyImpl implements PrivateKey {
  late PublicKey publicKey;
  ECPrivateKey ecPrivateKey;
  ECPublicKey? ecPublicKey;

  PrivateKeyImpl(this.ecPrivateKey, [this.ecPublicKey]) {
    if (ecPublicKey == null) {
      ecPublicKey = new ECPublicKey(_secp256r1.G * ecPrivateKey.d, _secp256r1);
    }
    publicKey = new PublicKeyImpl(ecPublicKey!);
  }

  String saveToString() {
    return "${Base64.encode(bigIntToBytes(ecPrivateKey.d!))} ${publicKey.qBase64}";
  }

  Future<ECDHImpl> getSecret(String key) async {
    ECPoint? p = ecPrivateKey.parameters!.curve.decodePoint(Base64.decode(key)!)!;
    ECPublicKey publicKey = new ECPublicKey(p, _secp256r1);
    var Q2 = publicKey.Q! * ecPrivateKey.d;
    return new ECDHImpl(ecPrivateKey, ecPublicKey!, Q2!);
  }
}

/// random number generator
class DSRandomImpl implements DSRandom, SecureRandom {
  bool get needsEntropy => true;

  late BlockCtrRandom _delegate;
  late AESEngine _aes;

  String get algorithmName => _delegate.algorithmName;

  DSRandomImpl([int seed = -1]) {
    _aes = AESEngine();
    _delegate = new BlockCtrRandom(_aes);
    // use the native prng, but still need to use randmize to add more seed later
    Math.Random r = new Math.Random();
    final keyBytes = [
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256)
    ];
    final key = new KeyParameter(new Uint8List.fromList(keyBytes));
    r = new Math.Random((new DateTime.now()).millisecondsSinceEpoch);
    final iv = new Uint8List.fromList([
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256)
    ]);
    final params = new ParametersWithIV<CipherParameters>(key, iv);
    _delegate.seed(params);
  }

  void seed(CipherParameters params) {
    if (params is ParametersWithIV<CipherParameters>) {
      _delegate.seed(params);
    } else {
      throw "${params} is not a ParametersWithIV implementation.";
    }
  }

  void addEntropy(String str) {
    List<int> utf = const Utf8Encoder().convert(str);
    int length2 = (utf.length).ceil() * 16;
    if (length2 > utf.length) {
      utf = utf.toList();
      while (length2 > utf.length) {
        utf.add(0);
      }
    }

    final bytes = new Uint8List.fromList(utf);

    final out = new Uint8List(16);
    for (var offset = 0; offset < bytes.lengthInBytes;) {
      var len = _aes.processBlock(bytes, offset, out, 0);
      offset += len;
    }
  }

  int nextUint8() {
    return _delegate.nextUint8();
  }

  @override
  int nextUint16() {
    return _delegate.nextUint16();
  }

  @override
  BigInt nextBigInteger(int bitLength) {
    return _delegate.nextBigInteger(bitLength);
  }

  @override
  Uint8List nextBytes(int count) {
    return _delegate.nextBytes(count);
  }

  @override
  int nextUint32() {
    return _delegate.nextUint32();
  }
}

String bytes2hex(List<int> bytes) {
  var result = new StringBuffer();
  for (var part in bytes) {
    result.write("${part < 16 ? "0" : ""}${part.toRadixString(16)}");
  }
  return result.toString();
}

/// BigInt.toByteArray contains negative values, so we need a different version
/// this version also remove the byte for sign, so it's not able to serialize negative number
Uint8List bigintToUint8List(BigInt input) {
  List<int> rslt = bigIntToBytes(input);
  if (rslt.length > 32 && rslt[0] == 0){
    rslt = rslt.sublist(1);
  }
  int len = rslt.length;
  for (int i = 0; i < len; ++i) {
    if (rslt[i] < 0) {
      rslt[i] &= 0xff;
    }
  }
  return new Uint8List.fromList(rslt);
}
