part of dslink.historian;

FutureOr<void> historianMain(
    List<String> args, String name, HistorianAdapter adapter) {
  _historian = adapter;

  _link = LinkProvider(args, '$name-',
      isRequester: true,
      autoInitialize: false,
      nodes: <String, dynamic>{
        'addDatabase': {
          r'$name': 'Add Database',
          r'$invokable': 'write',
          r'$params': [
            {'name': 'Name', 'type': 'string', 'placeholder': 'HistoryData'},
            ...adapter.getCreateDatabaseParameters()
          ],
          r'$is': 'addDatabase'
        }
      },
      profiles: {
        'createWatchGroup': (String path) => CreateWatchGroupNode(path),
        'addDatabase': (String path) => AddDatabaseNode(path),
        'addWatchPath': (String path) => AddWatchPathNode(path),
        'watchGroup': (String path) => WatchGroupNode(path),
        'watchPath': (String path) => WatchPathNode(path),
        'database': (String path) => DatabaseNode(path),
        'delete': (String path) => DeleteActionNode.forParent(
                path, _link.provider as MutableNodeProvider, onDelete: () {
              _link.save();
            }),
        'purgePath': (String path) => PurgePathNode(path),
        'purgeGroup': (String path) => PurgeGroupNode(path),
        'publishValue': (String path) => PublishValueAction(path)
      },
      encodePrettyJson: true);
  _link.init();
  _link.connect();
}
