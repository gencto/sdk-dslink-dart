part of dslink.utils;

class ByteDataUtil {
  static Uint8List list2Uint8List(List<int> input) {
    if (input is Uint8List) {
      return input;
    }
    return Uint8List.fromList(input);
  }
  
  static ByteData mergeBytes(List<ByteData> bytesList) {
    if (bytesList.length == 1) {
      return bytesList[0];
    }
    var totalLen = 0;
    for (var bytes in bytesList) {
      totalLen += bytes.lengthInBytes;
    }
    var output = ByteData(totalLen);
    var pos = 0;
    for (var bytes in bytesList) {
      output.buffer.asUint8List(pos).setAll(0, toUint8List(bytes));
      pos += bytes.lengthInBytes;
    }
    return output;
  }

  static ByteData fromUint8List(Uint8List uintsList) {
    return uintsList.buffer
        .asByteData(uintsList.offsetInBytes, uintsList.lengthInBytes);
  }

  static Uint8List toUint8List(ByteData bytes) {
    return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  }

  static ByteData fromList(List<int> input) {
    if (input is Uint8List) {
      return fromUint8List(input);
    }
    return fromUint8List(Uint8List.fromList(input));
  }
}
