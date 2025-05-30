part of dsalink.utils;

/// difference from crypto lib CryptoUtils.bytesToBase64:
/// 1) default to url filename safe base64
/// 2) allow byte array to have negative int -128 ~ -1
/// 3) custom line size and custom padding space
class Base64 {
  static const int PAD = 61; // '='
  static const int CR = 13; // '\r'
  static const int LF = 10; // '\n'
  static const int SP = 32; // ' '
  static const int PLUS = 43; // '+'
  static const int SLASH = 47; // '/'

  static const String _encodeTable =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';

  /// Lookup table used for finding Base 64 alphabet index of a given byte.
  /// -2 : Outside Base 64 alphabet.
  /// -1 : '\r' or '\n'
  /// 0 : = (Padding character).
  /// >=0 : Base 64 alphabet index of given byte.
  static final List<int> _decodeTable =
      (() {
        var table = List<int>.filled(256, 0);
        table.fillRange(0, 256, -2);
        var charCodes = _encodeTable.codeUnits;
        var len = charCodes.length;
        for (var i = 0; i < len; ++i) {
          table[charCodes[i]] = i;
        }
        table[PLUS] = 62;
        table[SLASH] = 63;
        table[CR] = -1;
        table[LF] = -1;
        table[SP] = -1;
        table[LF] = -1;
        table[PAD] = 0;
        return table;
      })();

  static String encodeString(
    String content, [
    int lineSize = 0,
    int paddingSpace = 0,
  ]) {
    return Base64.encode(toUTF8(content), lineSize, paddingSpace);
  }

  static String decodeString(String? input) {
    return const Utf8Decoder().convert(decode(input) as List<int>);
  }

  static String encode(
    List<int> bytes, [
    int lineSize = 0,
    int paddingSpace = 0,
  ]) {
    var len = bytes.length;
    if (len == 0) {
      return '';
    }
    // Size of 24 bit chunks.
    final remainderLength = len.remainder(3);
    final chunkLength = len - remainderLength;
    // Size of base output.
    var outputLen =
        ((len ~/ 3) * 4) + ((remainderLength > 0) ? 4 : 0) + paddingSpace;
    // Add extra for line separators.
    var lineSizeGroup = lineSize >> 2;
    if (lineSizeGroup > 0) {
      outputLen +=
          ((outputLen - 1) ~/ (lineSizeGroup << 2)) * (1 + paddingSpace);
    }
    var out = List<int>.filled(outputLen, 0);

    // Encode 24 bit chunks.
    int j = 0, i = 0, c = 0;
    for (var i = 0; i < paddingSpace; ++i) {
      out[j++] = SP;
    }
    while (i < chunkLength) {
      var x =
          (((bytes[i++] % 256) << 16) & 0xFFFFFF) |
          (((bytes[i++] % 256) << 8) & 0xFFFFFF) |
          (bytes[i++] % 256);
      out[j++] = _encodeTable.codeUnitAt(x >> 18);
      out[j++] = _encodeTable.codeUnitAt((x >> 12) & 0x3F);
      out[j++] = _encodeTable.codeUnitAt((x >> 6) & 0x3F);
      out[j++] = _encodeTable.codeUnitAt(x & 0x3f);
      // Add optional line separator for each 76 char output.
      if (lineSizeGroup > 0 && ++c == lineSizeGroup && j < outputLen - 2) {
        out[j++] = LF;
        for (var i = 0; i < paddingSpace; ++i) {
          out[j++] = SP;
        }
        c = 0;
      }
    }

    // If input length if not a multiple of 3, encode remaining bytes and
    // add padding.
    if (remainderLength == 1) {
      var x = bytes[i] % 256;
      out[j++] = _encodeTable.codeUnitAt(x >> 2);
      out[j++] = _encodeTable.codeUnitAt((x << 4) & 0x3F);
      //     out[j++] = PAD;
      //     out[j++] = PAD;
      return String.fromCharCodes(out.sublist(0, outputLen - 2));
    } else if (remainderLength == 2) {
      var x = bytes[i] % 256;
      var y = bytes[i + 1] % 256;
      out[j++] = _encodeTable.codeUnitAt(x >> 2);
      out[j++] = _encodeTable.codeUnitAt(((x << 4) | (y >> 4)) & 0x3F);
      out[j++] = _encodeTable.codeUnitAt((y << 2) & 0x3F);
      //     out[j++] = PAD;
      return String.fromCharCodes(out.sublist(0, outputLen - 1));
    }

    return String.fromCharCodes(out);
  }

  static Uint8List? decode(String? input) {
    if (input == null) {
      return null;
    }
    var len = input.length;
    if (len == 0) {
      return Uint8List(0);
    }

    // Count '\r', '\n' and illegal characters, For illegal characters,
    // throw an exception.
    var extrasLen = 0;
    for (var i = 0; i < len; i++) {
      var c = _decodeTable[input.codeUnitAt(i)];
      if (c < 0) {
        extrasLen++;
        if (c == -2) {
          return null;
        }
      }
    }

    var lenmis = (len - extrasLen) % 4;
    if (lenmis == 2) {
      input = '$input==';
      len += 2;
    } else if (lenmis == 3) {
      input = '$input=';
      len += 1;
    } else if (lenmis == 1) {
      return null;
    }

    // Count pad characters.
    var padLength = 0;
    for (var i = len - 1; i >= 0; i--) {
      var currentCodeUnit = input.codeUnitAt(i);
      if (_decodeTable[currentCodeUnit] > 0) break;
      if (currentCodeUnit == PAD) padLength++;
    }
    var outputLen = (((len - extrasLen) * 6) >> 3) - padLength;
    var out = Uint8List(outputLen);

    for (int i = 0, o = 0; o < outputLen;) {
      // Accumulate 4 valid 6 bit Base 64 characters into an int.
      var x = 0;
      for (var j = 4; j > 0;) {
        var c = _decodeTable[input.codeUnitAt(i++)];
        if (c >= 0) {
          x = ((x << 6) & 0xFFFFFF) | c;
          j--;
        }
      }
      out[o++] = x >> 16;
      if (o < outputLen) {
        out[o++] = (x >> 8) & 0xFF;
        if (o < outputLen) out[o++] = x & 0xFF;
      }
    }
    return out;
  }
}
