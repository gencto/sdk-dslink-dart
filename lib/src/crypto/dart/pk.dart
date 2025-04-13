library dsalink.pk.dart;

import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:math' as Math;
import 'dart:isolate';

import 'package:pointycastle/block/aes.dart';

import '../pk.dart';
import '../../../utils.dart';
import '../big_int_utils.dart';

import 'package:pointycastle/ecc/curves/secp256r1.dart';
import 'package:pointycastle/api.dart' hide PublicKey, PrivateKey;
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_generators/ec_key_generator.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/random/block_ctr_random.dart';

part 'isolate.dart';

/// hard code the EC curve data here, so the compiler don"t have to register all curves
ECDomainParameters get _secp256r1 => ECCurve_secp256r1();

class DartCryptoProvider implements CryptoProvider {
  static final DartCryptoProvider INSTANCE = DartCryptoProvider();
  @override
  final DSRandomImpl random = DSRandomImpl();

  ECPrivateKey? _cachedPrivate;
  ECPublicKey? _cachedPublic;
  int _cachedTime = -1;

  @override
  Future<ECDH> assign(PublicKey? publicKeyRemote, ECDH? old) async {
    if (ECDHIsolate.running) {
      if (old is ECDHImpl) {
        return ECDHIsolate._sendRequest(
          publicKeyRemote,
          old._ecPrivateKey.d!.toRadixString(16),
        );
      } else {
        return ECDHIsolate._sendRequest(publicKeyRemote, null);
      }
    }
    var ts = (DateTime.now()).millisecondsSinceEpoch;

    /// reuse same ECDH server pair for up to 1 minute
    if (_cachedPrivate == null ||
        ts - _cachedTime > 60000 ||
        (old is ECDHImpl && old._ecPrivateKey == _cachedPrivate)) {
      var gen = ECKeyGenerator();
      var rsapars = ECKeyGeneratorParameters(_secp256r1);
      var params = ParametersWithRandom(rsapars, DSRandomImpl());
      gen.init(params);
      var pair = gen.generateKeyPair();
      _cachedPrivate = pair.privateKey as ECPrivateKey?;
      _cachedPublic = pair.publicKey as ECPublicKey?;
      _cachedTime = ts;
    }

    PublicKeyImpl? publicKeyRemoteImpl;

    if (publicKeyRemote is! PublicKeyImpl) {
      throw 'Not a PublicKeyImpl: $publicKeyRemoteImpl';
    } else {
      publicKeyRemoteImpl = publicKeyRemote;
    }

    var Q2 = publicKeyRemoteImpl.ecPublicKey.Q! * _cachedPrivate?.d!;
    return ECDHImpl(_cachedPrivate!, _cachedPublic!, Q2!);
  }

  @override
  Future<ECDH> getSecret(PublicKey publicKeyRemote) async {
    if (ECDHIsolate.running) {
      return ECDHIsolate._sendRequest(publicKeyRemote, '');
    }
    var gen = ECKeyGenerator();
    var rsapars = ECKeyGeneratorParameters(_secp256r1);
    var params = ParametersWithRandom(rsapars, random);
    gen.init(params);
    var pair = gen.generateKeyPair();

    PublicKeyImpl? publicKeyRemoteImpl;

    if (publicKeyRemote is! PublicKeyImpl) {
      throw 'Not a PublicKeyImpl: $publicKeyRemoteImpl';
    } else {
      publicKeyRemoteImpl = publicKeyRemote;
    }

    var Q2 = publicKeyRemoteImpl.ecPublicKey.Q! * pair.privateKey.d;
    return ECDHImpl(pair.privateKey, pair.publicKey, Q2!);
  }

  @override
  Future<PrivateKey> generate() async {
    return generateSync();
  }

  @override
  PrivateKey generateSync() {
    var gen = ECKeyGenerator();
    var rsapars = ECKeyGeneratorParameters(_secp256r1);
    var params = ParametersWithRandom(rsapars, random);
    gen.init(params);
    var pair = gen.generateKeyPair();
    return PrivateKeyImpl(pair.privateKey, pair.publicKey as ECPublicKey?);
  }

  @override
  PrivateKey loadFromString(String str) {
    if (str.contains(' ')) {
      List ss = str.split(' ');
      var d = readBytes(Base64.decode(ss[0])!);
      var pri = ECPrivateKey(d, _secp256r1);
      var Q = _secp256r1.curve.decodePoint(Base64.decode(ss[1]) as List<int>);
      var pub = ECPublicKey(Q, _secp256r1);
      return PrivateKeyImpl(pri, pub);
    } else {
      var decode = Base64.decode(str);
      var d = readBytes(decode!);
      var pri = ECPrivateKey(d, _secp256r1);
      return PrivateKeyImpl(pri);
    }
  }

  @override
  PublicKey getKeyFromBytes(Uint8List bytes) {
    var Q = _secp256r1.curve.decodePoint(bytes);
    return PublicKeyImpl(ECPublicKey(Q, _secp256r1));
  }

  @override
  String base64_sha256(Uint8List bytes) {
    var sha256 = SHA256Digest();
    var hashed = sha256.process(Uint8List.fromList(bytes));
    return Base64.encode(hashed);
  }
}

class ECDHImpl extends ECDH {
  @override
  String get encodedPublicKey =>
      Base64.encode(_ecPublicKey.Q!.getEncoded(false));

  late Uint8List bytes;

  final ECPrivateKey _ecPrivateKey;
  final ECPublicKey _ecPublicKey;

  ECDHImpl(this._ecPrivateKey, this._ecPublicKey, ECPoint Q2) {
    //var Q2 = _ecPublicKeyRemote.Q * _ecPrivateKey.d;
    bytes = bigintToUint8List(Q2.x!.toBigInteger()!);
    if (bytes.length > 32) {
      bytes = bytes.sublist(bytes.length - 32);
    } else if (bytes.length < 32) {
      var newbytes = Uint8List(32);
      var dlen = 32 - bytes.length;
      for (var i = 0; i < bytes.length; ++i) {
        newbytes[i + dlen] = bytes[i];
      }
      for (var i = 0; i < dlen; ++i) {
        newbytes[i] = 0;
      }
      bytes = newbytes;
    }
  }

  @override
  String hashSalt(String salt) {
    var encoded = utf8.encode(salt);
    var raw = Uint8List(encoded.length + bytes.length);
    int i;
    for (i = 0; i < encoded.length; i++) {
      raw[i] = encoded[i];
    }

    for (var x = 0; x < bytes.length; x++) {
      raw[i] = bytes[x];
      i++;
    }
    var sha256 = SHA256Digest();
    var hashed = sha256.process(raw);
    return Base64.encode(hashed);
  }
}

class PublicKeyImpl extends PublicKey {
  static final BigInt publicExp = BigInt.from(65537);

  ECPublicKey ecPublicKey;
  @override
  late String qBase64;
  @override
  late String qHash64;

  PublicKeyImpl(this.ecPublicKey) {
    var bytes = ecPublicKey.Q!.getEncoded(false);
    qBase64 = Base64.encode(bytes);
    var sha256 = SHA256Digest();
    qHash64 = Base64.encode(sha256.process(bytes));
  }
}

class PrivateKeyImpl implements PrivateKey {
  @override
  late PublicKey publicKey;
  ECPrivateKey ecPrivateKey;
  ECPublicKey? ecPublicKey;

  PrivateKeyImpl(this.ecPrivateKey, [this.ecPublicKey]) {
    ecPublicKey ??= ECPublicKey(_secp256r1.G * ecPrivateKey.d, _secp256r1);
    publicKey = PublicKeyImpl(ecPublicKey!);
  }

  @override
  String saveToString() {
    return '${Base64.encode(bigIntToBytes(ecPrivateKey.d!))} ${publicKey.qBase64}';
  }

  @override
  Future<ECDHImpl> getSecret(String key) async {
    ECPoint? p =
        ecPrivateKey.parameters!.curve.decodePoint(Base64.decode(key)!)!;
    var publicKey = ECPublicKey(p, _secp256r1);
    var Q2 = publicKey.Q! * ecPrivateKey.d;
    return ECDHImpl(ecPrivateKey, ecPublicKey!, Q2!);
  }
}

/// random number generator
class DSRandomImpl implements DSRandom, SecureRandom {
  @override
  bool get needsEntropy => true;

  late BlockCtrRandom _delegate;
  late AESEngine _aes;

  @override
  String get algorithmName => _delegate.algorithmName;

  DSRandomImpl([int seed = -1]) {
    _aes = AESEngine();
    _delegate = BlockCtrRandom(_aes);
    // use the native prng, but still need to use randmize to add more seed later
    var r = Math.Random();
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
      r.nextInt(256),
    ];
    final key = KeyParameter(Uint8List.fromList(keyBytes));
    r = Math.Random((DateTime.now()).millisecondsSinceEpoch);
    final iv = Uint8List.fromList([
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
      r.nextInt(256),
    ]);
    final params = ParametersWithIV<CipherParameters>(key, iv);
    _delegate.seed(params);
  }

  @override
  void seed(CipherParameters params) {
    if (params is ParametersWithIV<CipherParameters>) {
      _delegate.seed(params);
    } else {
      throw '$params is not a ParametersWithIV implementation.';
    }
  }

  @override
  void addEntropy(String str) {
    List<int> utf = const Utf8Encoder().convert(str);
    var length2 = (utf.length).ceil() * 16;
    if (length2 > utf.length) {
      utf = utf.toList();
      while (length2 > utf.length) {
        utf.add(0);
      }
    }

    final bytes = Uint8List.fromList(utf);

    final out = Uint8List(16);
    for (var offset = 0; offset < bytes.lengthInBytes;) {
      var len = _aes.processBlock(bytes, offset, out, 0);
      offset += len;
    }
  }

  @override
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
  var result = StringBuffer();
  for (var part in bytes) {
    result.write("${part < 16 ? "0" : ""}${part.toRadixString(16)}");
  }
  return result.toString();
}

/// BigInt.toByteArray contains negative values, so we need a different version
/// this version also remove the byte for sign, so it's not able to serialize negative number
Uint8List bigintToUint8List(BigInt input) {
  var rslt = bigIntToBytes(input);
  if (rslt.length > 32 && rslt[0] == 0) {
    rslt = rslt.sublist(1);
  }
  var len = rslt.length;
  for (var i = 0; i < len; ++i) {
    if (rslt[i] < 0) {
      rslt[i] &= 0xff;
    }
  }
  return Uint8List.fromList(rslt);
}
