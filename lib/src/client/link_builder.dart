part of dsalink.client;

/// A fluent builder for [LinkProvider] configuration.
class LinkProviderBuilder {
  final List<String> _args;
  final String _prefix;
  
  bool _isRequester = false;
  bool _isResponder = true;
  String _command = 'link';
  Map<String, dynamic>? _defaultNodes;
  Map<String, NodeFactory>? _profiles;
  NodeProvider? _provider;
  bool _enableHttp = true;
  bool _encodePrettyJson = false;
  bool _autoInitialize = true;
  bool _strictOptions = false;
  bool _exitOnFailure = true;
  bool _loadNodesJson = true;
  bool _strictTls = false;
  String _defaultLogLevel = 'INFO';
  bool _savePrivateKey = true;
  Requester? _overrideRequester;
  Responder? _overrideResponder;
  DSAConfig? _linkData;
  CommandLineOptions? _commandLineOptions;

  LinkProviderBuilder(this._args, this._prefix);

  LinkProviderBuilder isRequester(bool value) {
    _isRequester = value;
    return this;
  }

  LinkProviderBuilder isResponder(bool value) {
    _isResponder = value;
    return this;
  }

  LinkProviderBuilder command(String value) {
    _command = value;
    return this;
  }

  LinkProviderBuilder defaultNodes(Map<String, dynamic> value) {
    _defaultNodes = value;
    return this;
  }

  LinkProviderBuilder profiles(Map<String, NodeFactory> value) {
    _profiles = value;
    return this;
  }

  LinkProviderBuilder provider(NodeProvider value) {
    _provider = value;
    return this;
  }

  LinkProviderBuilder enableHttp(bool value) {
    _enableHttp = value;
    return this;
  }

  LinkProviderBuilder encodePrettyJson(bool value) {
    _encodePrettyJson = value;
    return this;
  }

  LinkProviderBuilder autoInitialize(bool value) {
    _autoInitialize = value;
    return this;
  }

  LinkProviderBuilder strictOptions(bool value) {
    _strictOptions = value;
    return this;
  }

  LinkProviderBuilder exitOnFailure(bool value) {
    _exitOnFailure = value;
    return this;
  }

  LinkProviderBuilder loadNodesJson(bool value) {
    _loadNodesJson = value;
    return this;
  }

  LinkProviderBuilder strictTls(bool value) {
    _strictTls = value;
    return this;
  }

  LinkProviderBuilder logLevel(String value) {
    _defaultLogLevel = value;
    return this;
  }

  LinkProviderBuilder savePrivateKey(bool value) {
    _savePrivateKey = value;
    return this;
  }

  LinkProviderBuilder overrideRequester(Requester value) {
    _overrideRequester = value;
    return this;
  }

  LinkProviderBuilder overrideResponder(Responder value) {
    _overrideResponder = value;
    return this;
  }

  LinkProviderBuilder linkData(DSAConfig value) {
    _linkData = value;
    return this;
  }

  LinkProviderBuilder commandLineOptions(CommandLineOptions value) {
    _commandLineOptions = value;
    return this;
  }

  /// Build the [LinkProvider] instance.
  LinkProvider build() {
    return LinkProvider(
      _args,
      _prefix,
      isRequester: _isRequester,
      isResponder: _isResponder,
      command: _command,
      defaultNodes: _defaultNodes,
      profiles: _profiles,
      provider: _provider,
      enableHttp: _enableHttp,
      encodePrettyJson: _encodePrettyJson,
      autoInitialize: _autoInitialize,
      strictOptions: _strictOptions,
      exitOnFailure: _exitOnFailure,
      loadNodesJson: _loadNodesJson,
      strictTls: _strictTls,
      defaultLogLevel: _defaultLogLevel,
      savePrivateKey: _savePrivateKey,
      overrideRequester: _overrideRequester,
      overrideResponder: _overrideResponder,
      linkData: _linkData,
      commandLineOptions: _commandLineOptions,
    );
  }
}
