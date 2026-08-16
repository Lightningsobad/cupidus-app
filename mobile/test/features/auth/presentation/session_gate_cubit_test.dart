import 'dart:async';

import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:cupid_mobile/features/auth/presentation/session_gate_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> _token({bool forceRefresh = false}) async => 'id-token';

Future<String?> _throwingToken({bool forceRefresh = false}) async =>
    throw StateError('user-token-expired');

void main() {
  late StreamController<CupidSessionState> sessionState;
  late AuthHistoryStore store;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    sessionState = StreamController<CupidSessionState>();
    store = AuthHistoryStore();
  });

  tearDown(() => sessionState.close());

  SessionGateCubit buildCubit({
    Future<String?> Function({bool forceRefresh})? idToken,
    Duration idTokenTimeout = const Duration(seconds: 3),
  }) {
    return SessionGateCubit(
      sessionState: sessionState.stream,
      idToken: idToken ?? _token,
      authHistoryStore: store,
      idTokenTimeout: idTokenTimeout,
    );
  }

  group('ADR-4 resolution table', () {
    test('unknown holds the Checking state', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      sessionState.add(const CupidSessionUnknown());
      await pumpEventQueue();

      expect(cubit.state, isA<SessionGateChecking>());
    });

    test('signed-in with a readable token resolves to authenticated', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      final emitted = expectLater(
        cubit.stream,
        emits(isA<SessionGateAuthenticated>()),
      );
      sessionState.add(const CupidSessionSignedIn(uid: 'uid-1'));

      await emitted;
    });

    test('signed-in with a timed-out token read stays optimistic', () async {
      final cubit = buildCubit(
        idToken: ({bool forceRefresh = false}) =>
            Future<String?>.delayed(const Duration(seconds: 5), () => 'late'),
        idTokenTimeout: const Duration(milliseconds: 10),
      );
      addTearDown(cubit.close);

      final emitted = expectLater(
        cubit.stream,
        emits(isA<SessionGateAuthenticated>()),
      );
      sessionState.add(const CupidSessionSignedIn(uid: 'uid-1'));

      await emitted;
    });

    test('signed-in with a rejected refresh resolves to session-expired',
        () async {
      final cubit = buildCubit(idToken: _throwingToken);
      addTearDown(cubit.close);

      final emitted = expectLater(
        cubit.stream,
        emits(
          isA<SessionGateSessionExpired>().having(
            (state) => state.prefillEmail,
            'prefillEmail',
            'alice@example.com',
          ),
        ),
      );
      sessionState.add(
        const CupidSessionSignedIn(uid: 'uid-1', email: 'alice@example.com'),
      );

      await emitted;
    });

    test('signed-out with a history marker resolves to session-expired (AC2)',
        () async {
      await store.markAuthenticated(email: 'alice@example.com');
      final cubit = buildCubit();
      addTearDown(cubit.close);

      final emitted = expectLater(
        cubit.stream,
        emits(
          isA<SessionGateSessionExpired>().having(
            (state) => state.prefillEmail,
            'prefillEmail',
            'alice@example.com',
          ),
        ),
      );
      sessionState.add(const CupidSessionSignedOut());

      await emitted;
    });

    test('signed-out without a history marker resolves to welcome (AC3)',
        () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      final emitted = expectLater(
        cubit.stream,
        emits(isA<SessionGateUnauthenticated>()),
      );
      sessionState.add(const CupidSessionSignedOut());

      await emitted;
    });
  });

  test('resolving signed-in self-heals a missing history marker (N1)',
      () async {
    expect(await store.hasPreviousSession(), isFalse);
    final cubit = buildCubit();
    addTearDown(cubit.close);

    final emitted = expectLater(
      cubit.stream,
      emits(isA<SessionGateAuthenticated>()),
    );
    sessionState.add(
      const CupidSessionSignedIn(uid: 'uid-1', email: 'alice@example.com'),
    );
    await emitted;

    expect(await store.hasPreviousSession(), isTrue);
    expect(await store.lastEmail(), 'alice@example.com');
  });

  test('a deliberate sign-out teardown returns the gate to welcome', () async {
    await store.markAuthenticated(email: 'alice@example.com');
    await store.clearOnSignOut();
    final cubit = buildCubit();
    addTearDown(cubit.close);

    final emitted = expectLater(
      cubit.stream,
      emits(isA<SessionGateUnauthenticated>()),
    );
    sessionState.add(const CupidSessionSignedOut());

    await emitted;
  });

  test('the signed-out path never reads an id token (ADR-011h)', () async {
    await store.markAuthenticated(email: 'alice@example.com');
    var tokenReads = 0;
    final cubit = buildCubit(
      idToken: ({bool forceRefresh = false}) async {
        tokenReads++;
        return 'id-token';
      },
    );
    addTearDown(cubit.close);

    final emitted = expectLater(
      cubit.stream,
      emits(isA<SessionGateSessionExpired>()),
    );
    sessionState.add(const CupidSessionSignedOut());
    await emitted;

    expect(tokenReads, 0);
  });
}
