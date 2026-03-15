part of dsalink.historian;

class DatabaseNode extends SimpleNode {
  Map<dynamic, dynamic>? config;
  HistorianDatabaseAdapter? database;
  Completer<void>? _dbReadyCompleter;

  DatabaseNode(String path) : super(path) {
    _dbReadyCompleter = Completer<void>();
  }

  @override
  void onCreated() {
    Future(() async {
      config = configs[r'$$db_config'] as Map<dynamic, dynamic>?;
      while (removed != true) {
        try {
          database = await _historian.getDatabase(config!);
          _dbReadyCompleter?.complete();
          break;
        } catch (e, stack) {
          logger.severe('Failed to connect to database for $path', e, stack);
          await Future<void>.delayed(const Duration(seconds: 5));
        }
      }

      if (removed == true) {
        try {
          await database?.close();
        } catch (e) {}
        return;
      }

      _link.addNode(
        '$path/createWatchGroup',
        NodeBuilder.action()
            .name('Add Watch Group')
            .profile('createWatchGroup')
            .invokable('write')
            .param('Name', 'string')
            .build(),
      );

      _link.addNode(
        '$path/delete',
        NodeBuilder.action()
            .name('Delete')
            .invokable('write')
            .profile('delete')
            .build(),
      );
    });
  }

  @override
  void onRemoving() {
    if (database != null) {
      database?.close();
    }
  }

  Future<void> waitForDatabaseReady() async {
    return _dbReadyCompleter?.future ?? Future.value();
  }
}

class WatchPathNode extends SimpleNode {
  String? valuePath;
  WatchGroupNode? group;
  bool isPublishOnly = false;

  WatchPathNode(String path) : super(path);

  @override
  void onCreated() async {
    var rp = configs[r'$path'] as String?;

    rp ??= configs[r'$value_path'] as String?;

    if (configs[r'$publish'] == true) {
      isPublishOnly = true;
    }

    valuePath = rp!;
    group = _link[Path(path).parentPath] as WatchGroupNode?;

    var groupName = group?._watchName;

    _link.addNode(
      '$path/lwv',
      NodeBuilder.value('dynamic')
          .name('Last Written Value')
          .build(),
    );

    _link.addNode(
      '$path/startDate',
      NodeBuilder.value('string')
          .name('Start Date')
          .build(),
    );

    _link.addNode(
      '$path/endDate',
      NodeBuilder.value('string')
          .name('End Date')
          .build(),
    );

    if (children['enabled'] == null) {
      _link.addNode(
        '$path/enabled',
        NodeBuilder.value('bool')
            .name('Enabled')
            .value(true)
            .writable()
            .build(),
      );
    }

    if (group?.db?.database == null) {
      await group?.db?.waitForDatabaseReady();
    }

    var summary = await group?.db?.database?.getSummary(groupName, valuePath!);

    if (summary?.first != null) {
      _link.updateValue('$path/startDate', summary?.first?.timestamp);
      isStartDateFilled = true;
    }

    if (summary?.last != null) {
      var update = ValueUpdate(
        summary?.last!.value,
        ts: summary?.last!.timestamp,
      );
      _link.updateValue('$path/lwv', update);
      updateValue(update);
    }

    timer = Scheduler.safeEvery(const Duration(seconds: 1), () async {
      await storeBuffer();
    });

    var ghn = GetHistoryNode('$path/getHistory');
    addChild('getHistory', ghn);
    (_link.provider as SimpleNodeProvider).setNode(ghn.path, ghn);
    updateList('getHistory');

    _link.addNode(
      '$path/purge',
      NodeBuilder.action()
          .name('Purge')
          .invokable('write')
          .profile('purgePath')
          .param('timeRange', 'string', editor: 'daterange')
          .build(),
    );

    _link.addNode(
      '$path/delete',
      NodeBuilder.action()
          .name('Delete')
          .invokable('write')
          .profile('delete')
          .build(),
    );

    _link.onValueChange('$path/enabled').listen((ValueUpdate update) {
      if (update.value == true) {
        sub();
      } else {
        if (valueSub != null) {
          valueSub?.cancel();
          valueSub = null;
        }
      }
    });

    if (_link.val('$path/enabled') == true) {
      sub();
    }

    group?.db?.database?.addWatchPathExtensions(this);
  }

  ReqSubscribeListener? valueSub;

  void sub() {
    if (!isPublishOnly) {
      if (valueSub != null) {
        valueSub?.cancel();
        valueSub = null;
      }

      valueSub = _link.requester?.subscribe(valuePath!, (ValueUpdate update) {
        doUpdate(update);
      });
    }
  }

  void doUpdate(ValueUpdate update) {
    updateValue(update);
    buffer.add(update);
  }

  ValueEntry asValueEntry(ValueUpdate update) {
    return ValueEntry(group!._watchName!, valuePath!, update.ts!, update.value);
  }

  bool isStartDateFilled = false;

  FutureOr<void> storeBuffer() async {
    var entries = buffer.map(asValueEntry).toList();

    if (entries.isNotEmpty) {
      try {
        if (!isStartDateFilled) {
          _link.updateValue('$path/startDate', entries.first.timestamp);
        }

        _link.updateValue('$path/lwv', entries.last.value);
        _link.updateValue('$path/endDate', entries.last.timestamp);
      } catch (e) {}
    }
    buffer.clear();
    await group?.storeValues(entries);
  }

  @override
  void onRemoving() {
    if (timer != null) {
      timer?.dispose();
    }

    storeBuffer();

    while (onRemoveCallbacks.isNotEmpty) {
      onRemoveCallbacks.removeAt(0)();
    }
  }

  @override
  Map save() {
    var out = super.save();
    out.remove('lwv');
    out.remove('startDate');
    out.remove('endDate');
    out.remove('getHistory');
    out.remove('publish');

    while (onSaveCallbacks.isNotEmpty) {
      onSaveCallbacks.removeAt(0)(out);
    }

    return out;
  }

  List<Function> onSaveCallbacks = [];
  List<Function> onRemoveCallbacks = [];

  List<ValueUpdate> buffer = [];
  Disposable? timer;

  Stream<ValuePair>? fetchHistory(TimeRange range) {
    return group?.fetchHistory(valuePath!, range);
  }
}

class WatchGroupNode extends SimpleNode {
  DatabaseNode? db;
  String? _watchName;

  WatchGroupNode(String path)
    : super(path, _link.provider as SimpleNodeProvider?);

  @override
  void onCreated() {
    var p = Path(path);
    db = _link[p.parentPath] as DatabaseNode?;
    _watchName = configs[NodeConfigKeys.name] as String?;

    _watchName ??= NodeNamer.decodeName(p.name);

    _link.addNode(
      '$path/addWatchPath',
      NodeBuilder.action()
          .name('Add Watch Path')
          .invokable('write')
          .profile('addWatchPath')
          .param('Path', 'string')
          .build(),
    );

    _link.addNode(
      '$path/publish',
      NodeBuilder.action()
          .name('Publish')
          .invokable('write')
          .profile('publishValue')
          .param('Path', 'string')
          .param('Value', 'dynamic')
          .param('Timestamp', 'string')
          .build(),
    );

    _link.addNode(
      '$path/delete',
      NodeBuilder.action()
          .name('Delete')
          .invokable('write')
          .profile('delete')
          .build(),
    );

    _link.addNode(
      '$path/purge',
      NodeBuilder.action()
          .name('Purge')
          .invokable('write')
          .profile('purgeGroup')
          .param('timeRange', 'string', editor: 'daterange')
          .build(),
    );

    Future(() async {
      await db?.waitForDatabaseReady();
      db?.database?.addWatchGroupExtensions(this);
    });
  }

  @override
  void onRemoving() {
    while (onRemoveCallbacks.isNotEmpty) {
      onRemoveCallbacks.removeAt(0)();
    }
    super.onRemoving();
  }

  Stream<ValuePair>? fetchHistory(String path, TimeRange range) {
    return db?.database!.fetchHistory(name, path, range);
  }

  Future? storeValues(List<ValueEntry> entries) {
    return db?.database!.store(entries);
  }

  List<Function> onRemoveCallbacks = [];
}
