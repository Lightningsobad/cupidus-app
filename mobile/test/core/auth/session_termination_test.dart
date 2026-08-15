import 'package:cupid_mobile/core/auth/session_termination.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/auth/data/auth_repository.dart';
import 'package:cupid_mobile/features/auth/data/firebase_sign_in_gateway.dart';
import 'package:cupid_mobile/features/auth/presentation/sign_out_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

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

AuthRepository _repositoryWithSignOut(Future<void> Function() signOut) =>
    AuthRepository(
      gateway: _UnusedGateway(),
      api: CupidApiClient.create(),
      signOut: signOut,
    );

void main() {
  group('SessionTerminationNotifier', () {
    test('broadcasts to every listener', () async {
      final notifier = SessionTerminationNotifier();
      addTearDown(notifier.dispose);

      final first = notifier.stream.first;
      final second = notifier.stream.first;
      notifier.emit(SessionTerminationReason.refreshFailed);

      expect(await first, SessionTerminationReason.refreshFailed);
      expect(await second, SessionTerminationReason.refreshFailed);
    });

    test('emitting after dispose is a no-op rather than a throw', () async {
      final notifier = SessionTerminationNotifier();
      await notifier.dispose();

      expect(
        () => notifier.emit(SessionTerminationReason.userInitiated),
        returnsNormally,
      );
    });
  });

  group('SignOutCubit termination signal (AC5 ordering)', () {
    test('emits userInitiated only after teardown has completed', () async {
      final notifier = SessionTerminationNotifier();
      addTearDown(notifier.dispose);

      var teardownDone = false;
      var teardownDoneWhenSignalled = false;
      notifier.stream.listen((_) => teardownDoneWhenSignalled = teardownDone);

      final cubit = SignOutCubit(
        repository: _repositoryWithSignOut(() async {
          await Future<void>.delayed(Duration.zero);
          teardownDone = true;
        }),
        sessionTermination: notifier,
      );
      addTearDown(cubit.close);

      final signal = notifier.stream.first;
      await cubit.signOut();

      expect(await signal, SessionTerminationReason.userInitiated);
      expect(teardownDoneWhenSignalled, isTrue);
      expect(cubit.state, isA<SignOutSuccess>());
    });

    test('emits nothing when teardown fails', () async {
      final notifier = SessionTerminationNotifier();
      addTearDown(notifier.dispose);

      final reasons = <SessionTerminationReason>[];
      notifier.stream.listen(reasons.add);

      final cubit = SignOutCubit(
        repository: _repositoryWithSignOut(
          () => Future<void>.error(Exception('boom')),
        ),
        sessionTermination: notifier,
      );
      addTearDown(cubit.close);

      await cubit.signOut();
      await pumpEventQueue();

      expect(cubit.state, isA<SignOutFailed>());
      expect(reasons, isEmpty);
    });
  });
}
