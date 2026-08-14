import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:cupid_mobile/features/auth/data/firebase_auth_sign_in_gateway.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUser implements User {
  _FakeUser({this.verifiedAfterReload = false});

  final bool verifiedAfterReload;
  bool reloaded = false;
  Object? sendVerificationError;

  @override
  bool get emailVerified => reloaded && verifiedAfterReload;

  @override
  Future<void> reload() async {
    reloaded = true;
  }

  @override
  Future<void> sendEmailVerification([
    ActionCodeSettings? actionCodeSettings,
  ]) async {
    if (sendVerificationError != null) {
      throw sendVerificationError!;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeFirebaseAuth implements FirebaseAuth {
  _FakeFirebaseAuth({this.error, this.user});

  final Object? error;
  final User? user;

  @override
  User? get currentUser => user;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) => Future<UserCredential>.error(error ?? _unconfigured);

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) => Future<UserCredential>.error(error ?? _unconfigured);

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) => error == null ? Future<void>.value() : Future<void>.error(error!);

  static final StateError _unconfigured = StateError('no error configured');

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  group('signInWithEmail', () {
    test('maps wrong-password to InvalidCredentialFailure', () {
      final gateway = FirebaseAuthSignInGateway(
        _FakeFirebaseAuth(error: FirebaseAuthException(code: 'wrong-password')),
      );

      expect(
        gateway.signInWithEmail(email: 'a@b.c', password: 'x'),
        throwsA(isA<InvalidCredentialFailure>()),
      );
    });

    test('maps network-request-failed to AuthNetworkFailure', () {
      final gateway = FirebaseAuthSignInGateway(
        _FakeFirebaseAuth(
          error: FirebaseAuthException(code: 'network-request-failed'),
        ),
      );

      expect(
        gateway.signInWithEmail(email: 'a@b.c', password: 'x'),
        throwsA(isA<AuthNetworkFailure>()),
      );
    });

    test('maps a raw PlatformException to UnexpectedAuthFailure', () {
      final gateway = FirebaseAuthSignInGateway(
        _FakeFirebaseAuth(error: PlatformException(code: 'channel-error')),
      );

      expect(
        gateway.signInWithEmail(email: 'a@b.c', password: 'x'),
        throwsA(isA<UnexpectedAuthFailure>()),
      );
    });
  });

  group('registerWithEmail', () {
    test('maps email-already-in-use to EmailAlreadyInUseFailure', () {
      final gateway = FirebaseAuthSignInGateway(
        _FakeFirebaseAuth(
          error: FirebaseAuthException(code: 'email-already-in-use'),
        ),
      );

      expect(
        gateway.registerWithEmail(email: 'a@b.c', password: 'x'),
        throwsA(isA<EmailAlreadyInUseFailure>()),
      );
    });

    test('maps weak-password to WeakPasswordFailure', () {
      final gateway = FirebaseAuthSignInGateway(
        _FakeFirebaseAuth(error: FirebaseAuthException(code: 'weak-password')),
      );

      expect(
        gateway.registerWithEmail(email: 'a@b.c', password: 'x'),
        throwsA(isA<WeakPasswordFailure>()),
      );
    });
  });

  group('sendPasswordResetEmail', () {
    test('maps invalid-email to InvalidCredentialFailure', () {
      final gateway = FirebaseAuthSignInGateway(
        _FakeFirebaseAuth(error: FirebaseAuthException(code: 'invalid-email')),
      );

      expect(
        gateway.sendPasswordResetEmail('nope'),
        throwsA(isA<InvalidCredentialFailure>()),
      );
    });

    test('maps an unrecognised code to UnexpectedAuthFailure', () {
      final gateway = FirebaseAuthSignInGateway(
        _FakeFirebaseAuth(error: FirebaseAuthException(code: 'quota-exceeded')),
      );

      expect(
        gateway.sendPasswordResetEmail('a@b.c'),
        throwsA(isA<UnexpectedAuthFailure>()),
      );
    });

    test('completes when Firebase accepts the request', () {
      final gateway = FirebaseAuthSignInGateway(_FakeFirebaseAuth());

      expect(gateway.sendPasswordResetEmail('a@b.c'), completes);
    });
  });

  group('current-user operations', () {
    test('sendEmailVerification without a user throws SessionExpiredFailure', () {
      final gateway = FirebaseAuthSignInGateway(_FakeFirebaseAuth());

      expect(
        gateway.sendEmailVerification(),
        throwsA(isA<SessionExpiredFailure>()),
      );
    });

    test('reloadEmailVerified without a user throws SessionExpiredFailure', () {
      final gateway = FirebaseAuthSignInGateway(_FakeFirebaseAuth());

      expect(
        gateway.reloadEmailVerified(),
        throwsA(isA<SessionExpiredFailure>()),
      );
    });

    test('reloadEmailVerified reports the flag refreshed by reload()', () async {
      final user = _FakeUser(verifiedAfterReload: true);
      final gateway = FirebaseAuthSignInGateway(
        _FakeFirebaseAuth(user: user),
      );

      expect(user.emailVerified, isFalse);
      await expectLater(gateway.reloadEmailVerified(), completion(isTrue));
      expect(user.reloaded, isTrue);
    });

    test('reloadEmailVerified stays false for an unverified user', () {
      final gateway = FirebaseAuthSignInGateway(
        _FakeFirebaseAuth(user: _FakeUser()),
      );

      expect(gateway.reloadEmailVerified(), completion(isFalse));
    });

    test('sendEmailVerification maps a Firebase error to CupidAuthFailure', () {
      final user = _FakeUser()
        ..sendVerificationError = FirebaseAuthException(
          code: 'user-token-expired',
        );
      final gateway = FirebaseAuthSignInGateway(
        _FakeFirebaseAuth(user: user),
      );

      expect(
        gateway.sendEmailVerification(),
        throwsA(isA<SessionExpiredFailure>()),
      );
    });
  });
}
