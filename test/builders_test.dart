import 'package:test/test.dart';
import 'package:dsalink/query.dart';
import 'package:dsalink/client.dart';

void main() {
  group('QueryBuilder', () {
    test('builds simple list query', () {
      final query = QueryBuilder().list('/data').build();
      expect(query, equals('list /data'));
    });

    test('builds piped list | subscribe query', () {
      final query = QueryBuilder()
          .list('/data/sensor')
          .subscribe()
          .build();
      expect(query, equals('list /data/sensor | subscribe'));
    });

    test('toString returns build()', () {
      final builder = QueryBuilder().list('/test');
      expect(builder.toString(), equals(builder.build()));
    });
  });

  group('LinkProviderBuilder', () {
    test('builds LinkProvider with custom settings', () {
      final provider = LinkProvider.builder(['--broker', 'http://test:8080'], 'test-prefix')
          .isRequester(true)
          .isResponder(false)
          .logLevel('FINE')
          .exitOnFailure(false)
          .autoInitialize(false)
          .build();

      expect(provider.prefix, equals('test-prefix'));
      expect(provider.isRequester, isTrue);
      expect(provider.isResponder, isFalse);
      expect(provider.defaultLogLevel, equals('FINE'));
      expect(provider.exitOnFailure, isFalse);
    });
  });
}
