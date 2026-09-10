import 'package:cupid_mobile/core/auth/cupid_session.dart';
import 'package:cupid_mobile/core/auth/jwt_token_provider.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  group('BackendUserIdStore cold-start rehydration (P10)', () {
    test('resolve() returns the persisted id when RAM is empty, calling the '
        'reader only once for two consecutive resolve() calls', () async {
      var readCount = 0;
      final store = BackendUserIdStore(
        readPersistedUserId: () async {
          readCount++;
          return 'persisted-user-1';
        },
      );

      expect(await store.resolve(), 'persisted-user-1');
      expect(await store.resolve(), 'persisted-user-1');
      expect(readCount, 1);
    });

    test('the in-RAM value wins over the persisted value', () async {
      final store = BackendUserIdStore(
        readPersistedUserId: () async => 'persisted-user-2',
      )..updateFromLoginResponse({'id': 'ram-user-2'});

      expect(await store.resolve(), 'ram-user-2');
    });

    test('resolve() returns null and does not cache when the reader returns '
        'null', () async {
      final store = BackendUserIdStore(readPersistedUserId: () async => null);

      expect(await store.resolve(), isNull);
      expect(store.backendUserId, isNull);
    });

    test('resolve() returns null and does not cache when the reader returns '
        'an empty string', () async {
      final store = BackendUserIdStore(readPersistedUserId: () async => '');

      expect(await store.resolve(), isNull);
      expect(store.backendUserId, isNull);
    });

    test(
        'sign-out teardown invariant with real collaborators: resolve() '
        'rehydrates the persisted id before signOut() and returns null after',
        () async {
      SharedPreferences.setMockInitialValues({
        'cupid_user_id': 'persisted-user-3',
      });
      final tokenProvider = JwtTokenProvider();
      final session = CupidSession(tokenProvider: tokenProvider, firebaseAuth: null);
      final store = BackendUserIdStore(
        readPersistedUserId: tokenProvider.getSavedUserId,
      );
      session.registerScopedStore(store);

      expect(await store.resolve(), 'persisted-user-3');

      await session.signOut();

      expect(await store.resolve(), isNull);
    });
  });
}
