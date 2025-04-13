/// Main dsalink API for Browsers
library dsalink.browser;

import 'dart:async';
import 'dart:typed_data';

import 'package:dsalink/browser_client.dart';
import 'package:dsalink/common.dart';
import 'package:dsalink/requester.dart';
import 'package:dsalink/responder.dart';
import 'package:dsalink/src/crypto/pk.dart';
import 'package:dsalink/utils.dart' show Base64, ByteDataUtil, DsaJson;
import 'package:http/http.dart' as http;

/// dsalink Provider for the Browser
class LinkProvider {
  BrowserECDHLink? link;
  Map? defaultNodes;
  Map<String, NodeFactory>? profiles;
  bool loadNodes;
  NodeProvider? provider;
  DataStorage? dataStore;
  late PrivateKey privateKey;
  String brokerUrl;
  String prefix;
  bool isRequester;
  bool isResponder;
  String? token;

  LinkProvider(
    this.brokerUrl,
    this.prefix, {
    this.defaultNodes,
    this.profiles,
    this.provider,
    this.dataStore,
    this.loadNodes = false,
    this.isRequester = true,
    this.isResponder = true,
    this.token,
  }) {
    dataStore ??= LocalDataStorage.INSTANCE;
  }

  bool _initCalled = false;

  Future init() async {
    if (_initCalled) {
      return;
    }

    _initCalled = true;

    if (provider == null) {
      provider = SimpleNodeProvider(null, profiles);
      (provider as SimpleNodeProvider).setPersistFunction(save);
    }

    if (loadNodes && provider is SerializableNodeProvider) {
      if (!(await dataStore!.has('dsa_nodes'))) {
        (provider as SerializableNodeProvider).init(defaultNodes!);
      } else {
        Map decoded = DsaJson.decode(await dataStore!.get('dsa_nodes'));

        (provider as SerializableNodeProvider).init(decoded);
      }
    } else {
      (provider as SerializableNodeProvider).init(defaultNodes!);
    }

    // move the waiting part of init into a later frame
    // we need to make sure provider is created at the first frame
    // not affected by any async code
    await initLinkWithPrivateKey();
  }

  Future initLinkWithPrivateKey() async {
    privateKey = (await getPrivateKey(storage: dataStore))!;
    link = BrowserECDHLink(
      brokerUrl,
      prefix,
      privateKey,
      nodeProvider: provider,
      isRequester: isRequester,
      isResponder: isResponder,
      token: token,
    );
  }

  Future resetSavedNodes() async {
    await dataStore!.remove('dsa_nodes');
  }

  Stream<ValueUpdate> onValueChange(String path, {int cacheLevel = 1}) {
    RespSubscribeListener? listener;
    StreamController<ValueUpdate>? controller;
    var subs = 0;
    controller = StreamController<ValueUpdate>.broadcast(
      onListen: () {
        subs++;
        listener ??= this[path]!.subscribe((ValueUpdate update) {
          controller?.add(update);
        }, cacheLevel);
      },
      onCancel: () {
        subs--;
        if (subs == 0) {
          listener!.cancel();
          listener = null;
        }
      },
    );
    return controller.stream;
  }

  Future save() async {
    if (provider is! SerializableNodeProvider) {
      return;
    }

    await dataStore?.store(
      'dsa_nodes',
      DsaJson.encode((provider as SerializableNodeProvider).save()),
    );
  }

  /// Remote Path of Responder
  //String get remotePath => link.remotePath;

  void syncValue(String path) {
    var n = this[path];
    n!.updateValue(n.lastValueUpdate?.value, force: true);
  }

  Future connect() {
    Future run() {
      link?.connect();
      return link!.onConnected;
    }

    if (!_initCalled) {
      return init().then<void>((dynamic _) => run());
    } else {
      return run();
    }
  }

  void close() {
    if (link != null) {
      link!.close();
      link = null;
    }
  }

  LocalNode? getNode(String path) {
    return provider?.getNode(path);
  }

  LocalNode? addNode(String path, Map m) {
    if (provider is! MutableNodeProvider) {
      throw Exception('Unable to Modify Node Provider: It is not mutable.');
    }
    return (provider as MutableNodeProvider).addNode(path, m);
  }

  void removeNode(String path) {
    if (provider is! MutableNodeProvider) {
      throw Exception('Unable to Modify Node Provider: It is not mutable.');
    }
    (provider as MutableNodeProvider).removeNode(path);
  }

  void updateValue(String path, dynamic value) {
    if (provider is! MutableNodeProvider) {
      throw Exception('Unable to Modify Node Provider: It is not mutable.');
    }
    (provider as MutableNodeProvider).updateValue(path, value);
  }

  dynamic val(String path, [dynamic value = unspecified]) {
    if (value is Unspecified) {
      return this[path]?.lastValueUpdate?.value;
    } else {
      updateValue(path, value);
      return value;
    }
  }

  LocalNode? operator [](String path) => provider![path];

  Requester? get requester => link?.requester;

  Future<Requester>? get onRequesterReady => link?.onRequesterReady;

  LocalNode? operator ~() => this['/'];
}

class BrowserUtils {
  static Future<String> fetchBrokerUrlFromPath(
    String path,
    String otherwise,
  ) async {
    try {
      final response = await http.get(Uri.parse(path));
      if (response.statusCode == 200) {
        return response.body.trim();
      }
    } catch (e) {
      return otherwise;
    }
    return otherwise;
  }

  static String createBinaryUrl(
    ByteData input, {
    String type = 'application/octet-stream',
  }) {
    var data = ByteDataUtil.toUint8List(input);
    return 'data:$type;base64,${Base64.encode(data)}';
  }
}
