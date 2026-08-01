import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackendUserIdStore.updateFromLoginResponse', () {
    test('caches the backend User.id from an /auth/login-shaped body', () {
      final store = BackendUserIdStore();

      store.updateFromLoginResponse({'id': 'backend-user-1', 'email': 'a@b.c'});

      expect(store.backendUserId, 'backend-user-1');
    });

    test('resolve() returns the cached id for the injected resolver contract',
        () async {
      final store = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'backend-user-2'});

      expect(await store.resolve(), 'backend-user-2');
    });

    test('resolve() returns null before any successful sync', () async {
      final store = BackendUserIdStore();

      expect(await store.resolve(), isNull);
    });

    test('raises RealtimeRoomKeyUnavailableFailure when id is absent, never '
        'falling back to any other identifier in the body', () {
      final store = BackendUserIdStore();

      expect(
        () => store.updateFromLoginResponse({'uid': 'firebase-uid-1'}),
        throwsA(isA<RealtimeRoomKeyUnavailableFailure>()),
      );
      expect(store.backendUserId, isNull);
    });

    test('raises RealtimeRoomKeyUnavailableFailure for a null body', () {
      final store = BackendUserIdStore();

      expect(
        () => store.updateFromLoginResponse(null),
        throwsA(isA<RealtimeRoomKeyUnavailableFailure>()),
      );
    });

    test('raises RealtimeRoomKeyUnavailableFailure when id is an empty '
        'string', () {
      final store = BackendUserIdStore();

      expect(
        () => store.updateFromLoginResponse({'id': ''}),
        throwsA(isA<RealtimeRoomKeyUnavailableFailure>()),
      );
    });
  });

  group('BackendUserIdStore.clearOnSignOut', () {
    test('clears the cached room key so a second user never inherits it',
        () async {
      final store = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'backend-user-3'});

      await store.clearOnSignOut();

      expect(store.backendUserId, isNull);
      expect(await store.resolve(), isNull);
    });
  });
}
