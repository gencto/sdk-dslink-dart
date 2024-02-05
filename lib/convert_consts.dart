library util.consts;

import 'dart:math' as Math;
import 'dart:convert';
import 'package:pointycastle/export.dart' hide PublicKey, PrivateKey;
import 'dart:typed_data';

const double_NAN = double.nan;
const double_NEGATIVE_INFINITY = double.negativeInfinity;
const double_INFINITY = double.infinity;
const Math_PI = Math.pi;
const double_MAX_FINITE = double.maxFinite;
const Math_E = Math.e;
const Math_LN2 = Math.ln2;
const Math_LN10 = Math.ln10;
const Math_LOG2E = Math.log2e;
const Math_LOG10E = Math.log10e;
const Math_SQRT2 = Math.sqrt2;
const Math_SQRT1_2 = Math.sqrt1_2;
const JSON = json;
const BASE64 = base64;
const UTF8 = utf8;
const Duration_ZERO = Duration.zero;

void socketJoinMulticast(Object socket, Object group, [Object? interface]) {
  //socket.joinMulticast(group, interface);
}

List<int> bigIntegerToByteArray(BigInt data) {
  return _bigIntToByteArray(data);
}

String bigIntegerToRadix(BigInt value, int radix) {
  return value.toRadixString(radix);
}

dynamic newBigInteger([dynamic a, dynamic b, dynamic c]) {
  if (a is num && b == null && c == null) {
    return BigInt.from(a);
  }
  if (a is String && b is int) {
    return BigInt.parse(a, radix: b);
  }
  return null;
}

dynamic newBigIntegerFromBytes(int signum, List<int> magnitude) {
  return _bytesToBigInt(magnitude);
}

List<int> _bigIntToByteArray(BigInt data) {
  String str;
  var neg = false;
  if (data < BigInt.zero) {
    str = (~data).toRadixString(16);
    neg = true;
  } else {
    str = data.toRadixString(16);
  }
  var p = 0;
  var len = str.length;
  var blen = (len + 1) ~/ 2;
  var boff = 0;
  List<int> bytes;
  if (neg) {
    if (len & 1 == 1) {
      p = -1;
    }
    var byte0 = ~int.parse(str.substring(0, p + 2), radix: 16);
    if (byte0 < -128) byte0 += 256;
    if (byte0 >= 0) {
      boff = 1;
      bytes = List<int>.filled(blen + 1, 0);
      bytes[0] = -1;
      bytes[1] = byte0;
    } else {
      bytes = List<int>.filled(blen, 0);
      ;
      bytes[0] = byte0;
    }
    for (var i = 1; i < blen; ++i) {
      var byte =
          ~int.parse(str.substring(p + (i << 1), p + (i << 1) + 2), radix: 16);
      if (byte < -128) byte += 256;
      bytes[i + boff] = byte;
    }
  } else {
    if (len & 1 == 1) {
      p = -1;
    }
    var byte0 = int.parse(str.substring(0, p + 2), radix: 16);
    if (byte0 > 127) byte0 -= 256;
    if (byte0 < 0) {
      boff = 1;
      bytes = List<int>.filled(blen + 1, 0);
      bytes[0] = 0;
      bytes[1] = byte0;
    } else {
      bytes = List<int>.filled(blen, 0);
      ;
      bytes[0] = byte0;
    }
    for (var i = 1; i < blen; ++i) {
      var byte =
          int.parse(str.substring(p + (i << 1), p + (i << 1) + 2), radix: 16);
      if (byte > 127) byte -= 256;
      bytes[i + boff] = byte;
    }
  }

  var b = <int>[];
  bytes.forEach((dynamic e) {
    b.insert(0, e);
  });
  return b;
}

BigInt _bytesToBigInt(List<int> bytes) {
  BigInt read(int start, int end) {
    if (end - start <= 4) {
      var result = 0;
      for (var i = end - 1; i >= start; i--) {
        result = result * 256 + bytes[i];
      }
      return BigInt.from(result);
    }
    var mid = start + ((end - start) >> 1);
    var result =
        read(start, mid) + read(mid, end) * (BigInt.one << ((mid - start) * 8));
    return result;
  }

  if ((bytes[0] & 0x80) != 0) {
    bytes = Uint8List(1 + bytes.length)
      ..[0] = 0
      ..setRange(1, 1 + bytes.length, bytes);
  }

  return read(0, bytes.length);
}

const _MASK_16 = 0xFFFF;
const _MASK_32 = 0xFFFFFFFF;

int clip16(int x) => (x & _MASK_16);
int clip32(int x) => (x & _MASK_32);

abstract class SecureRandomBase implements SecureRandom {
  @override
  int nextUint16() {
    var b0 = nextUint8();
    var b1 = nextUint8();
    return clip16((b1 << 8) | b0);
  }

  @override
  int nextUint32() {
    var b0 = nextUint8();
    var b1 = nextUint8();
    var b2 = nextUint8();
    var b3 = nextUint8();
    return clip32((b3 << 24) | (b2 << 16) | (b1 << 8) | b0);
  }

  @override
  BigInt nextBigInteger(int bitLength) {
    return newBigIntegerFromBytes(1, _randomBits(bitLength));
  }

  @override
  Uint8List nextBytes(int count) {
    var bytes = Uint8List(count);
    for (var i = 0; i < count; i++) {
      bytes[i] = nextUint8();
    }
    return bytes;
  }

  List<int> _randomBits(int numBits) {
    if (numBits < 0) {
      throw ArgumentError('numBits must be non-negative');
    }

    var numBytes = (numBits + 7) ~/ 8; // avoid overflow
    var randomBits = Uint8List(numBytes);

    // Generate random bytes and mask out any excess bits
    if (numBytes > 0) {
      for (var i = 0; i < numBytes; i++) {
        randomBits[i] = nextUint8();
      }
      var excessBits = 8 * numBytes - numBits;
      randomBits[0] &= (1 << (8 - excessBits)) - 1;
    }
    return randomBits;
  }
}

/*
class BigInteger {

  factory BigInteger.fromBytes( int signum, List<int> magnitude ) {
    BigInt content = readBytes(magnitude);
    return new BigInteger.fromContent(content);
  }

  BigInteger([a, b, c]) {
    if (a != null) {
      if (a is num) {
        this.content = new BigInt.from(a);
      } else if (a is BigInt) {
        this.content = a;
      } else {
        this.content = BigInt.parse(a, radix: b);
      }
    }
  }

  factory BigInteger.fromContent(BigInt content) {
    return new BigInteger(content);
  }


  BigInt content;

  List<int> toByteArray() {
    return writeBigInt(content);
  }

  BigInteger modPow(BigInteger exponent, BigInteger modulus) {
    return new BigInteger.fromContent(this.content.modPow(exponent.content, modulus.content));
  }

  BigInteger and (BigInteger second) {
    return new BigInteger.fromContent(this.content & second.content);
  }


  static BigInt readBytes(List<int> bytes) {
    BigInt read(int start, int end) {
      if (end - start <= 4) {
        int result = 0;
        for (int i = start; i < end; i++) {
          result = result * 256 + bytes[i];
        }
        return new BigInt.from(result);
      }
      int mid = start + ((end - start) >> 1);
      var result = read(mid, end) + read(start, mid) * (BigInt.one << ((end - mid) * 8));
      return result;
    }
    return read(0, bytes.length);
  }

  static List<int> writeBigInt(BigInt number) {
    // Not handling negative numbers. Decide how you want to do that.
    int bytes = (number.bitLength + 7) >> 3;
    var b256 = new BigInt.from(256);
    var result = new List<int>(bytes);
    for (int i = 0; i < bytes; i++) {
      result[bytes - i - 1] = number.remainder(b256).toInt();
      number = number >> 8;
    }
    return result;
  }
}
*/