import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/auth/data/auth_repository.dart';
import 'package:cupid_mobile/features/auth/data/firebase_sign_in_gateway.dart';
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

void main() {
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
