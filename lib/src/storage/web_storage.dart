library dsalink.storage.web;

import 'dart:async';
import 'dart:html';

import '../../common.dart';
import '../../responder.dart';
import '../../utils.dart';

class WebResponderStorage extends ISubscriptionResponderStorage {
  Map<String, WebNodeStorage> values = <String, WebNodeStorage>{};

  final String prefix;

  @override
  String? responderPath;

  WebResponderStorage([this.prefix = 'dsaValue:']);

  @override
  ISubscriptionNodeStorage getOrCreateValue(String path) {
    if (values.containsKey(path)) {
      return values[path]!;
    }
    var value = WebNodeStorage(path, prefix, this);
    values[path] = value;
    return value;
  }

  @override
  Future<List<ISubscriptionNodeStorage>> load() async {
    var rslt = <ISubscriptionNodeStorage>[];
    for (var key in window.localStorage.keys) {
      if (key.startsWith(prefix)) {
        var path = key.substring(prefix.length);
        var value = WebNodeStorage(path, prefix, this);
        value.load();
        if (value._cachedValue != null) {
          values[path] = value;
          rslt.add(value);
        }
      }
    }
    return Future<List<ISubscriptionNodeStorage>>.value(rslt);
  }

  @override
  void destroyValue(String path) {
    if (values.containsKey(path)) {
      values[path]?.destroy();
      values.remove(path);
    }
  }

  @override
  void destroy() {
    values.forEach((String path, WebNodeStorage value) {
      value.destroy();
    });
    values.clear();
  }
}

class WebNodeStorage extends ISubscriptionNodeStorage {
  late String storePath;

  WebNodeStorage(String path, String prefix, WebResponderStorage storage)
    : super(path, storage) {
    storePath = '$prefix$path';
  }

  /// add data to List of values
  @override
  void addValue(ValueUpdate value) {
    qos = 3;
    value.storedData = '${DsaJson.encode(value.toMap())}\n';
    if (window.localStorage.containsKey(storePath)) {
      window.localStorage[storePath] =
          (window.localStorage[storePath] ?? '') + value.storedData.toString();
    } else {
      window.localStorage[storePath] = value.storedData.toString();
    }
  }

  @override
  void setValue(Iterable<ValueUpdate> removes, ValueUpdate newValue) {
    qos = 2;
    newValue.storedData = ' ${DsaJson.encode(newValue.toMap())}\n';
    // add a space when qos = 2
    window.localStorage[storePath] = newValue.storedData.toString();
  }

  @override
  void removeValue(ValueUpdate value) {
    // do nothing, it's done in valueRemoved
  }

  @override
  void valueRemoved(Iterable<ValueUpdate> updates) {
    window.localStorage[storePath] = updates.map((v) => v.storedData).join();
  }

  @override
  void clear(int qos) {
    if (qos == 3) {
      window.localStorage[storePath] = '';
    } else {
      window.localStorage[storePath] = ' ';
    }
  }

  @override
  void destroy() {
    window.localStorage.remove(storePath);
  }

  List<ValueUpdate>? _cachedValue;

  void load() {
    var str = window.localStorage[storePath];
    if (str == null) {
      return;
    }
    var strs = str.split('\n');
    if (str.startsWith(' ')) {
      // where there is space, it's qos 2
      qos = 2;
    } else {
      qos = 3;
    }
    var rslt = <ValueUpdate>[];
    for (var s in strs) {
      if (s.length < 18) {
        // a valid data is always 18 bytes or more
        continue;
      }

      try {
        Map m = DsaJson.decode(s);
        var value = ValueUpdate(m['value'], ts: m['ts'], meta: m);
        rslt.add(value);
      } catch (err) {}
    }
    _cachedValue = rslt;
  }

  @override
  List<ValueUpdate> getLoadedValues() {
    return _cachedValue ?? [];
  }
}
