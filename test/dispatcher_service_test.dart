import 'package:dsalink/models/dsa_request.dart';
import 'package:dsalink/models/invoke_request.dart';
import 'package:dsalink/models/list_request.dart';
import 'package:dsalink/models/remove_request.dart';
import 'package:dsalink/models/set_request.dart';
import 'package:dsalink/models/subscribe_request.dart';
import 'package:dsalink/models/unsubscribe_request.dart';
import 'package:dsalink/requester/dispatcher_service.dart';
import 'package:test/test.dart';

void main() {
  group('DispatcherService', () {
    final dispatcher = DispatcherService();

    test('handles DsaRequest correctly', () {
      const req = DsaRequest(rid: 1, method: 'list', path: '/test');

      expect(() => dispatcher.dispatch(req), throwsA(isA<UnsupportedError>()));
    });

    test('handles ListRequest correctly', () {
      const req = ListRequest(rid: 1, path: '/test');

      expect(() => dispatcher.dispatch(req), throwsA(isA<UnsupportedError>()));
    });

    test('handles InvokeRequest correctly', () {
      const req = InvokeRequest(rid: 1, path: '/test');
      expect(() => dispatcher.dispatch(req), throwsA(isA<UnsupportedError>()));
    });

    test('handles SetRequest correctly', () {
      const req = SetRequest(rid: 1, path: '/test', value: 1);
      expect(() => dispatcher.dispatch(req), throwsA(isA<UnsupportedError>()));
    });

    test('handles RemoveRequest correctly', () {
      const req = RemoveRequest(rid: 1, path: '/test');
      expect(() => dispatcher.dispatch(req), throwsA(isA<UnsupportedError>()));
    });

    test('handles SubscribeRequest correctly', () {
      const req = SubscribeRequest(
        rid: 1,
        paths: [SubscribePath(path: '/test', sid: 1)],
      );
      expect(() => dispatcher.dispatch(req), throwsA(isA<UnsupportedError>()));
    });

    test('handles UnsubscribeRequest correctly', () {
      const req = UnsubscribeRequest(rid: 1, sids: [100, 101]);

      expect(() => dispatcher.dispatch(req), throwsA(isA<UnsupportedError>()));
    });
  });
}
