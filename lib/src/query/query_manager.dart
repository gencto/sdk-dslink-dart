part of dsalink.query;

class BrokerQueryManager {
  NodeProvider provider;

  BrokerQueryManager(this.provider);

  BrokerQueryCommand? parseList(List str) {
    // TODO: implement this
    return null;
  }

  BrokerQueryCommand? parseDql(String str) {
    if (str.startsWith('[')) {
      return parseList(DsaJson.decode(str));
    }
    // TODO: implement full dql spec
    // this is just a temp quick parser for basic /data node query
    var commands = str.split('|').map((x) => x.trim()).toList();
    BrokerQueryCommand? currentCommand;

    for (var cmd in commands) {
      if (cmd.startsWith('list ')) {
        var path = cmd.substring(5).trim();
        var listcommand = QueryCommandList(path, this);
        currentCommand = _getOrAddCommand(listcommand);
      } else if (cmd == 'subscribe') {
        if (currentCommand == null) return null;
        var subcommand = QueryCommandSubscribe(this);
        subcommand.base = currentCommand;
        currentCommand = _getOrAddCommand(subcommand);
      }
      if (currentCommand == null) return null;
    }
    return currentCommand;
  }

  final Map<String, BrokerQueryCommand> _dict = <String, BrokerQueryCommand>{};

  BrokerQueryCommand? _getOrAddCommand(BrokerQueryCommand command) {
    var key = command.getQueryId();
    if (_dict.containsKey(key)) {
      return _dict[key];
    }
    try {
      command.init();
    } catch (err) {
      command.destroy();
      return null;
    }

    // add to base command's next
    if (command.base != null) {
      command.base?.addNext(command);
    } else if (command is QueryCommandList) {
      // all list command start from root node
      command.updateFromBase(<dynamic>[
        [provider.getNode('/'), '+'],
      ]);
    }
    _dict[key] = command;
    return command;
  }
}
