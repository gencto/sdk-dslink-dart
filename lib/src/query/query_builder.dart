part of dsalink.query;

/// Fluent builder for constructing DSA queries.
class QueryBuilder {
  final List<String> _commands = [];

  QueryBuilder();

  /// Start a list query on the specified path.
  QueryBuilder list(String path) {
    _commands.add('list $path');
    return this;
  }

  /// Add a subscribe command to the query pipeline.
  QueryBuilder subscribe() {
    _commands.add('subscribe');
    return this;
  }

  /// Build the final DQL query string.
  String build() => _commands.join(' | ');

  /// Parse the built query using the provided manager.
  BrokerQueryCommand? parse(BrokerQueryManager manager) {
    return manager.parseDql(build());
  }

  @override
  String toString() => build();
}
