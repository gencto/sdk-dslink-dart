part of dslink.utils;

/// a decoder class to decode malformed url encoded string
class UriComponentDecoder {
  static const int _SPACE = 0x20;
  static const int _PERCENT = 0x25;
  static const int _PLUS = 0x2B;

  static String decode(String text) {
    var codes = <int>[];
    var bytes = <int>[];
    var len = text.length;
    for (var i = 0; i < len; i++) {
      var codeUnit = text.codeUnitAt(i);
      if (codeUnit == _PERCENT) {
        if (i + 3 > text.length) {
          bytes.add(_PERCENT);
          continue;
        }
        var hexdecoded = _hexCharPairToByte(text, i + 1);
        if (hexdecoded > 0) {
          bytes.add(hexdecoded);
          i += 2;
        } else {
          bytes.add(_PERCENT);
        }
      } else {
        if (bytes.isNotEmpty) {
          codes.addAll(
              const Utf8Decoder(allowMalformed: true).convert(bytes).codeUnits);
          bytes.clear();
        }
        if (codeUnit == _PLUS) {
          codes.add(_SPACE);
        } else {
          codes.add(codeUnit);
        }
      }
    }

    if (bytes.isNotEmpty) {
      codes.addAll(const Utf8Decoder().convert(bytes).codeUnits);
      bytes.clear();
    }
    return String.fromCharCodes(codes);
  }

  static int _hexCharPairToByte(String s, int pos) {
    var byte = 0;
    for (var i = 0; i < 2; i++) {
      var charCode = s.codeUnitAt(pos + i);
      if (0x30 <= charCode && charCode <= 0x39) {
        byte = byte * 16 + charCode - 0x30;
      } else if ((charCode >= 0x41 && charCode <= 0x46) ||
          (charCode >= 0x61 && charCode <= 0x66)) {
        // Check ranges A-F (0x41-0x46) and a-f (0x61-0x66).
        charCode |= 0x20;
        byte = byte * 16 + charCode - 0x57;
      } else {
        return -1;
      }
    }
    return byte;
  }
}
