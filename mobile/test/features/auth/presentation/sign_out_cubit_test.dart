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
  group('SignOutCubit', () {
    test('emits idle, in-progress, then success on a successful teardown', () async {
      var callCount = 0;
      final cubit = SignOutCubit(
        repository: _repositoryWithSignOut(() async {
          callCount++;
        }),
      );
      addTearDown(cubit.close);

      expect(cubit.state, isA<SignOutIdle>());

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(<Matcher>[isA<SignOutInProgress>(), isA<SignOutSuccess>()]),
      );

      await cubit.signOut();
      await expectation;

      expect(callCount, 1);
    });

    test('emits failed with the thrown failure when teardown throws', () async {
      final failure = Exception('boom');
      final cubit = SignOutCubit(
        repository: _repositoryWithSignOut(() => Future<void>.error(failure)),
      );
      addTearDown(cubit.close);

      SignOutFailed? failedState;
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(<Matcher>[
          isA<SignOutInProgress>(),
          predicate<SignOutState>((state) {
            failedState = state as SignOutFailed;
            return true;
          }),
        ]),
      );

      await cubit.signOut();
      await expectation;

      expect(failedState?.failure, same(failure));
    });
  });
}
