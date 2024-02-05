part of dslink.utils;

typedef _Encoder = Object? Function(Object? input);
typedef _Reviver = Object? Function(Object? key, Object? input);

class BinaryData {
  /// used when only partial data is received
  /// don"t merge them before it's finished
  List<ByteData>? mergingList;

  ByteData? bytes;

  BinaryData(ByteData bytes) {
    this.bytes = bytes;
  }

  BinaryData.fromList(List<int> list) {
    bytes = ByteDataUtil.fromList(list);
  }
}

abstract class DsCodec {
  static final Map<String, DsCodec> _codecs = {
    'json': DsJson.instance,
    'msgpack': DsMsgPackCodecImpl.instance
  };

  static final DsCodec defaultCodec = DsJson.instance;

  static void register(String? name, DsCodec? codec) {
    if (name != null && codec != null) {
      _codecs[name] = codec;
    }
  }

  static DsCodec getCodec(String name) {
    var rslt = _codecs[name];
    if (rslt == null) {
      return defaultCodec;
    }
    return rslt;
  }

  Object? _blankData;

  Object? get blankData {
    _blankData ??= encodeFrame(<String, dynamic>{});
    return _blankData;
  }

  /// output String or List<int>
  Object? encodeFrame(Map val);

  /// input can be String or List<int>
  Map? decodeStringFrame(String input);

  Map? decodeBinaryFrame(List<int> input);
}

abstract class DsJson {
  static DsJsonCodecImpl instance = DsJsonCodecImpl();

  static String encode(Object val, {bool pretty = false}) {
    return instance.encodeJson(val, pretty: pretty);
  }

  /// Decodes a string using the instance's `decodeJson` method.
  ///
  /// Returns the decoded value.
  static dynamic decode(String str) {
    return instance.decodeJson(str);
  }

  String encodeJson(Object val, {bool pretty = false});

  dynamic decodeJson(String str);
}

class DsJsonCodecImpl extends DsCodec implements DsJson {
  static dynamic _safeEncoder(dynamic value) {
    return null;
  }

  JsonEncoder encoder = JsonEncoder(_safeEncoder);

  JsonDecoder decoder = JsonDecoder();
  JsonEncoder? _prettyEncoder;

  /// Decodes a JSON string into a dynamic object.
  ///
  /// The [str] parameter is the JSON string to be decoded.
  /// Returns the decoded dynamic object.
  @override
  dynamic decodeJson(String str) {
    return decoder.convert(str);
  }

  @override
  String encodeJson(val, {bool pretty = false}) {
    JsonEncoder? e = encoder;
    if (pretty) {
      _prettyEncoder ??= encoder = JsonEncoder.withIndent('  ', _safeEncoder);
      e = _prettyEncoder;
    }
    return e!.convert(val);
  }

  JsonDecoder? _unsafeDecoder;

  @override
  Map? decodeBinaryFrame(List<int> bytes) {
    return decodeStringFrame(const Utf8Decoder().convert(bytes));
  }

  @override
  Map? decodeStringFrame(String str) {
    _reviver ??= (key, value) {
        if (value is String && value.startsWith('\u001Bbytes:')) {
          try {
            return ByteDataUtil.fromUint8List(
                Base64.decode(value.substring(7))!);
          } catch (err) {
            return null;
          }
        }
        return value;
      };

    _unsafeDecoder ??= JsonDecoder(_reviver);

    Map? result = _unsafeDecoder?.convert(str);
    return result;
  }

  _Reviver? _reviver;
  _Encoder? _encoder;

  @override
  Object? encodeFrame(Object val) {
    _encoder ??= (value) {
        if (value is ByteData) {
          return '\u001Bbytes:${Base64.encode(ByteDataUtil.toUint8List(value))}';
        }
        return null;
      };

    JsonEncoder? c;

    _unsafeEncoder ??= JsonEncoder(_encoder);
    c = _unsafeEncoder;

    var result = c?.convert(val);
    return result;
  }

  JsonEncoder? _unsafeEncoder;
}

class DsMsgPackCodecImpl extends DsCodec {
  static DsMsgPackCodecImpl instance = DsMsgPackCodecImpl();

  @override
  Map decodeBinaryFrame(List<int> input) {
    var data = ByteDataUtil.list2Uint8List(input);

    _unpacker = Deserializer(data);

    Object rslt = _unpacker?.decode();
    if (rslt is Map) {
      return rslt;
    }
    return <String, dynamic>{};
  }

  Deserializer? _unpacker;

  @override
  Map decodeStringFrame(String input) {
    // not supported
    return <String, dynamic>{};
  }

  @override
  Object? encodeFrame(Map val) {
    return serialize(val);
  }
}
