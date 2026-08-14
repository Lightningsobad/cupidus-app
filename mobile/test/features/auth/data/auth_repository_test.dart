import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/auth/data/auth_repository.dart';
import 'package:cupid_mobile/features/auth/data/firebase_sign_in_gateway.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _UnusedGateway implements FirebaseSignInGateway {
  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) => throw UnimplementedError();

  @override
  Future<void> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<void> signInWithApple() => throw UnimplementedError();

  @override
  Future<void> signInWithFacebook() => throw UnimplementedError();

  @override
  Future<void> sendEmailVerification() => throw UnimplementedError();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      throw UnimplementedError();

  @override
  Future<bool> reloadEmailVerified() => throw UnimplementedError();
}

/// Succeeds on every Firebase leg so the tests can observe what
/// [AuthRepository] does after the gateway returns.
class _SucceedingGateway implements FirebaseSignInGateway {
  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithFacebook() async {}

  @override
  Future<void> sendEmailVerification() => throw UnimplementedError();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      throw UnimplementedError();

  @override
  Future<bool> reloadEmailVerified() => throw UnimplementedError();
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => _handler(options);
}

CupidApi _apiWithStatus(int statusCode) {
  final api = CupidApiClient.create();
  api.dio.httpClientAdapter = _FakeHttpClientAdapter(
    (options) async => ResponseBody.fromString(
      jsonEncode({'id': 'user-1'}),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    ),
  );
  return api;
}

AuthRepository _repository(CupidApi api, AuthHistoryStore historyStore) {
  return AuthRepository(
    gateway: _SucceedingGateway(),
    api: api,
    signOut: () async {},
    authHistoryStore: historyStore,
  );
}

void main() {
  group('AuthRepository auth-history marker (ADR-3)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('email sign-in records the marker and the prefill email', () async {
      final store = AuthHistoryStore();
      await _repository(_apiWithStatus(200), store).signInWithEmail(
        email: 'alice@example.com',
        password: 'pw',
      );

      expect(await store.hasPreviousSession(), isTrue);
      expect(await store.lastEmail(), 'alice@example.com');
    });

    test('email registration records the marker and the prefill email',
        () async {
      final store = AuthHistoryStore();
      await _repository(_apiWithStatus(200), store).registerWithEmail(
        email: 'bob@example.com',
        password: 'pw',
      );

      expect(await store.hasPreviousSession(), isTrue);
      expect(await store.lastEmail(), 'bob@example.com');
    });

    test('every social entry point records the marker', () async {
      for (final signIn in <Future<void> Function(AuthRepository)>[
        (repo) => repo.signInWithGoogle(),
        (repo) => repo.signInWithApple(),
        (repo) => repo.signInWithFacebook(),
      ]) {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final store = AuthHistoryStore();

        await signIn(_repository(_apiWithStatus(200), store));

        expect(await store.hasPreviousSession(), isTrue);
        expect(await store.lastEmail(), isNull);
      }
    });

    test('marks before the backend sync, so a sync failure cannot lose it',
        () async {
      final store = AuthHistoryStore();
      final repository = _repository(_apiWithStatus(500), store);

      await expectLater(
        repository.signInWithEmail(email: 'alice@example.com', password: 'pw'),
        throwsA(isA<CupidApiFailure>()),
      );
      expect(await store.hasPreviousSession(), isTrue);
      expect(await store.lastEmail(), 'alice@example.com');
    });
  });

  group('AuthRepository.signOut', () {
    test('delegates exactly once to the injected teardown callback', () async {
      var callCount = 0;
      final repository = AuthRepository(
        gateway: _UnusedGateway(),
        api: CupidApiClient.create(),
        signOut: () async {
          callCount++;
        },
      );

      await repository.signOut();

      expect(callCount, 1);
    });

    test('rethrows a teardown failure without wrapping it', () async {
      final failure = Exception('boom');
      final repository = AuthRepository(
        gateway: _UnusedGateway(),
        api: CupidApiClient.create(),
        signOut: () => Future<void>.error(failure),
      );

      await expectLater(repository.signOut(), throwsA(same(failure)));
    });
  });
}
