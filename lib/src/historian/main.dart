part of dsalink.historian;

FutureOr<void> historianMain(
  List<String> args,
  String name,
  HistorianAdapter adapter,
) {
  _historian = adapter;

  _link = LinkProvider(
    args,
    '$name-',
    isRequester: true,
    autoInitialize: false,
    nodes: <String, dynamic>{
      'addDatabase': NodeBuilder.action()
          .name('Add Database')
          .invokable('write')
          .profile('addDatabase')
          .param('Name', 'string', placeholder: 'HistoryData')
          .build()
        ..addAll({
          r'$params': [
            {'name': 'Name', 'type': 'string', 'placeholder': 'HistoryData'},
            ...adapter.getCreateDatabaseParameters(),
          ],
        }),
    },
    profiles: {
      'createWatchGroup': (String path) => CreateWatchGroupNode(path),
      'addDatabase': (String path) => AddDatabaseNode(path),
      'addWatchPath': (String path) => AddWatchPathNode(path),
      'watchGroup': (String path) => WatchGroupNode(path),
      'watchPath': (String path) => WatchPathNode(path),
      'database': (String path) => DatabaseNode(path),
      'delete':
          (String path) => DeleteActionNode.forParent(
            path,
            _link.provider as MutableNodeProvider,
            onDelete: () async {
              await _link.saveAsync();
            },
          ),
      'purgePath': (String path) => PurgePathNode(path),
      'purgeGroup': (String path) => PurgeGroupNode(path),
      'publishValue': (String path) => PublishValueAction(path),
    },
    encodePrettyJson: true,
  );
  _link.init();
  _link.connect();
}
