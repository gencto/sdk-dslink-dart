library dslink.storage.simple;

import 'dart:async';
import 'dart:io';

import '../../responder.dart';
import '../../common.dart';
import '../../utils.dart';

void _ignoreError(Object obj) {}

class SimpleStorageManager implements IStorageManager {
  Map<String, SimpleResponderStorage> rsponders =
      <String, SimpleResponderStorage>{};
  late Directory dir;
  late Directory subDir;

  SimpleStorageManager(String path) {
    dir = Directory(path);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    subDir = Directory('$path/resp_subscription');
    if (!subDir.existsSync()) {
      subDir.createSync(recursive: true);
    }
  }

  @override
  ISubscriptionResponderStorage getOrCreateSubscriptionStorage(String rpath) {
    if (rsponders.containsKey(rpath)) {
      return rsponders[rpath]!;
    }
    var responder = SimpleResponderStorage(
        '${subDir.path}/${Uri.encodeComponent(rpath)}', rpath);
    rsponders[rpath] = responder;
    return responder;
  }

  @override
  void destroySubscriptionStorage(String rpath) {
    if (rsponders.containsKey(rpath)) {
      rsponders[rpath]?.destroy();
      rsponders.remove(rpath);
    }
  }

  void destroy() {
    rsponders.forEach((String rpath, SimpleResponderStorage responder) {
      responder.destroy();
    });
    rsponders.clear();
    values.forEach((String name, SimpleValueStorageBucket store) {
      store.destroy();
    });
    values.clear();
  }

  @override
  Future<List<List<ISubscriptionNodeStorage>>> loadSubscriptions() async {
    var loading = <Future<List<ISubscriptionNodeStorage>>>[];
    for (var entity in subDir.listSync()) {
      if (await FileSystemEntity.type(entity.path) ==
          FileSystemEntityType.directory) {
        var rpath = UriComponentDecoder.decode(entity.path
            .substring(entity.path.lastIndexOf(Platform.pathSeparator) + 1));
        var responder = SimpleResponderStorage(entity.path, rpath);
        rsponders[rpath] = responder;
        loading.add(responder.load());
      }
    }
    return Future.wait(loading);
  }

  Map<String, SimpleValueStorageBucket> values =
      <String, SimpleValueStorageBucket>{};

  @override
  IValueStorageBucket getOrCreateValueStorageBucket(String category) {
    if (values.containsKey(category)) {
      return values[category]!;
    }
    var store = SimpleValueStorageBucket(
        category, '${dir.path}/${Uri.encodeComponent(category)}');
    values[category] = store;
    return store;
  }

  @override
  void destroyValueStorageBucket(String category) {
    if (values.containsKey(category)) {
      values[category]?.destroy();
      values.remove(category);
    }
  }
}

class SimpleResponderStorage extends ISubscriptionResponderStorage {
  Map<String, SimpleNodeStorage> values = <String, SimpleNodeStorage>{};
  late Directory dir;
  @override
  late String responderPath;

  SimpleResponderStorage(String path, [String? responderPath]) {
    responderPath ??= UriComponentDecoder.decode(
        path.substring(path.lastIndexOf(Platform.pathSeparator) + 1));

    dir = Directory(path);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  @override
  ISubscriptionNodeStorage getOrCreateValue(String path) {
    if (values.containsKey(path)) {
      return values[path]!;
    }
    var value =
        SimpleNodeStorage(path, Uri.encodeComponent(path), dir.path, this);
    values[path] = value;
    return value;
  }

  @override
  Future<List<ISubscriptionNodeStorage>> load() async {
    var loading = <Future<ISubscriptionNodeStorage>>[];
    for (var entity in dir.listSync()) {
      var name = entity.path
          .substring(entity.path.lastIndexOf(Platform.pathSeparator) + 1);
      var path = UriComponentDecoder.decode(name);
      values[path] = SimpleNodeStorage(path, name, dir.path, this);
      loading.add(values[path]!.load());
    }
    return Future.wait(loading);
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
    values.forEach((String path, SimpleNodeStorage value) {
      value.destroy();
    });
    values.clear();
  }
}

class SimpleNodeStorage extends ISubscriptionNodeStorage {
  late File file;
  late String filename;

  SimpleNodeStorage(String path, this.filename, String parentPath,
      SimpleResponderStorage storage)
      : super(path, storage) {
    file = File('$parentPath/$filename');
  }

  /// add data to List of values
  @override
  void addValue(ValueUpdate value) {
    qos = 3;
    value.storedData = '${DsJson.encode(value.toMap())}\n';
    file.openSync(mode: FileMode.append)
      ..writeStringSync(value.storedData.toString())
      ..closeSync();
  }

  @override
  void setValue(Iterable<ValueUpdate> removes, ValueUpdate newValue) {
    qos = 2;
    newValue.storedData = ' ${DsJson.encode(newValue.toMap())}\n';
    // add a space when qos = 2
    file.writeAsStringSync(newValue.storedData.toString());
  }

  @override
  void removeValue(ValueUpdate value) {
    // do nothing, it's done in valueRemoved
  }

  @override
  void valueRemoved(Iterable<ValueUpdate> updates) {
    file.writeAsStringSync(updates.map((v) => v.storedData).join());
  }

  @override
  void clear(int qos) {
    if (qos == 3) {
      file.writeAsStringSync('');
    } else {
      file.writeAsStringSync(' ');
    }
  }

  @override
  void destroy() {
    // ignore: invalid_return_type_for_catch_error
    file.delete().catchError(_ignoreError);
  }

  late List<ValueUpdate> _cachedValue;

  Future<ISubscriptionNodeStorage> load() async {
    var str = file.readAsStringSync();
    var strs = str.split('\n');
    if (strs.length == 1 && str.startsWith(' ')) {
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
        Map m = DsJson.decode(s);
        var value = ValueUpdate(m['value'], ts: m['ts'], meta: m);
        rslt.add(value);
      } catch (err) {}
    }
    _cachedValue = rslt;
    return this;
  }

  @override
  List<ValueUpdate> getLoadedValues() {
    return _cachedValue;
  }
}

/// basic key/value pair storage
class SimpleValueStorageBucket implements IValueStorageBucket {
  String category;
  late Directory dir;

  SimpleValueStorageBucket(this.category, String path) {
    dir = Directory(path);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  @override
  IValueStorage getValueStorage(String key) {
    return SimpleValueStorage(this, key);
  }

  @override
  void destroy() {
    // ignore: invalid_return_type_for_catch_error
    dir.delete(recursive: true).catchError(_ignoreError);
  }

  @override
  Future<Map> load() async {
    Map rslt = <String, dynamic>{};
    for (var entity in dir.listSync()) {
      var name = UriComponentDecoder.decode(entity.path
          .substring(entity.path.lastIndexOf(Platform.pathSeparator) + 1));
      var f = File(entity.path);
      var str = f.readAsStringSync();
      try {
        rslt[name] = DsJson.decode(str);
      } catch (err) {
        logger.fine(err);
      }
    }
    return rslt;
  }
}

class SimpleValueStorage extends IValueStorage {
  @override
  String key;
  SimpleValueStorageBucket bucket;
  late File _file;

  SimpleValueStorage(this.bucket, this.key) {
    _file = File('${bucket.dir.path}/${Uri.encodeComponent(key)}');
  }
  bool _pendingSet = false;
  Object? _pendingValue;

  /// set the value, if previous setting is not finished, it will be set later
  @override
  void setValue(Object? value) {
    _pendingValue = value;
    if (_pendingSet) {
      return;
    }
    _pendingValue = null;
    _pendingSet = true;
    _file
        .writeAsString(DsJson.encode(value!))
        .then(onSetDone)
        .catchError(onSetDone);
  }

  void onSetDone(Object obj) {
    _pendingSet = false;
    if (_pendingValue != null) {
      setValue(_pendingValue!);
    }
  }

  @override
  void destroy() {
    _pendingValue = null;
    // ignore: invalid_return_type_for_catch_error
    _file.delete().catchError(_ignoreError);
  }

  @override
  Future getValueAsync() async {
    if (_pendingValue != null) {
      return _pendingValue;
    }
    try {
      return DsJson.decode(await _file.readAsString());
    } catch (err) {}
    return null;
  }
}
