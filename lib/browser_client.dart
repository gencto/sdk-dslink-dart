/// Base API for DSA in the Browser
library dslink.browser_client;

import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'common.dart';
import 'utils.dart';
import 'requester.dart';
import 'responder.dart';

import 'src/crypto/pk.dart';

part 'src/browser/browser_user_link.dart';
part 'src/browser/browser_ecdh_link.dart';
part 'src/browser/browser_ws_conn.dart';

/// A Storage System for DSA Data
abstract class DataStorage {
  /// Get a key's value.
  Future<String> get(String key);

  /// Check if a key is stored.
  Future<bool> has(String key);

  /// Remove the specified key.
  Future<String> remove(String key);

  /// Store a key value pair.
  Future store(String key, String value);
}

/// A Synchronous Storage System for DSA Data
abstract class SynchronousDataStorage {
  /// Get a key's value.
  String getSync(String key);

  /// Check if a key is stored.
  bool hasSync(String key);

  /// Remove the specified key.
  String removeSync(String key);

  /// Store a key value pair.
  void storeSync(String key, String value);
}

/// Storage for DSA in Local Storage
class LocalDataStorage extends DataStorage implements SynchronousDataStorage {
  static final LocalDataStorage INSTANCE = LocalDataStorage();

  LocalDataStorage();

  @override
  Future<String> get(String key) async => window.localStorage[key] ?? '';

  @override
  Future<bool> has(String key) async => window.localStorage.containsKey(key);

  @override
  Future store(String key, String value) {
    window.localStorage[key] = value;
    return Future<void>.value();
  }

  @override
  Future<String> remove(String key) async {
    return window.localStorage.remove(key) ?? '';
  }

  @override
  String removeSync(String key) {
    return window.localStorage.remove(key)!;
  }

  @override
  void storeSync(String key, String value) {
    window.localStorage[key] = value;
  }

  @override
  bool hasSync(String key) => window.localStorage.containsKey(key);

  @override
  String getSync(String key) => window.localStorage[key] ?? '';
}

PrivateKey? _cachedPrivateKey;
/// Get a Private Key using the specified storage strategy.
/// If [storage] is not specified, it uses the [LocalDataStorage] class.
Future<PrivateKey?> getPrivateKey({DataStorage? storage}) async {
  if (_cachedPrivateKey != null) {
    return _cachedPrivateKey;
  }

  storage ??= LocalDataStorage.INSTANCE;

  var keyPath = 'dsa_key:${window.location.pathname}';
  String? keyLockPath = 'dsa_key_lock:${window.location.pathname}';
  var randomToken = '${DateTime.now().millisecondsSinceEpoch}'
    ' ${DSRandom.instance.nextUint16()}'
    ' ${DSRandom.instance.nextUint16()}';

  var hasKeyPath = false;

  if (storage is SynchronousDataStorage) {
    hasKeyPath = (storage as SynchronousDataStorage).hasSync(keyPath);
  } else {
    hasKeyPath = await storage.has(keyPath);
  }

  if (hasKeyPath) {
    if (storage is SynchronousDataStorage) {
      (storage as SynchronousDataStorage).storeSync(keyLockPath, randomToken);
    } else {
      await storage.store(keyLockPath, randomToken);
    }

    await Future<void>.delayed(const Duration(milliseconds: 20));
    String existingToken;
    String existingKey;

    if (storage is SynchronousDataStorage) {
      existingToken = (storage as SynchronousDataStorage).getSync(keyLockPath);
      existingKey = (storage as SynchronousDataStorage).getSync(keyPath);
    } else {
      existingToken = await storage.get(keyLockPath);
      existingKey = await storage.get(keyPath);
    }

    if (existingToken == randomToken) {
      if (storage is LocalDataStorage) {
        _startStorageLock(keyLockPath, randomToken);
      }
      _cachedPrivateKey = PrivateKey.loadFromString(existingKey);
      return _cachedPrivateKey;
    } else {
      // use temp key, don't lock it;
      keyLockPath = null;
    }
  }

  _cachedPrivateKey = await PrivateKey.generate();

  if (keyLockPath != null) {
    if (storage is SynchronousDataStorage) {
      (storage as SynchronousDataStorage).storeSync(keyPath, _cachedPrivateKey!.saveToString());
      (storage as SynchronousDataStorage).storeSync(keyLockPath, randomToken);
    } else {
      await storage.store(keyPath, _cachedPrivateKey!.saveToString());
      await storage.store(keyLockPath, randomToken);
    }

    if (storage is LocalDataStorage) {
      _startStorageLock(keyLockPath, randomToken);
    }
  }

  return _cachedPrivateKey;
}

void _startStorageLock(String lockKey, String lockToken) {
  void onStorage(StorageEvent e) {
    if (e.key == lockKey) {
      window.localStorage[lockKey] = lockToken;
    }
  }
  window.onStorage.listen(onStorage);
}