import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/auth/cupid_auth.dart';
import 'firebase_sign_in_gateway.dart';

/// The production [FirebaseSignInGateway] (REQ-002 STORY-001 ADR-7).
///
/// Placement deviates from the REQ-001 rule that restricted provider-plugin
/// imports to `mobile/lib/core/auth/`: REQ-002 `architecture/solution.md` §5
/// and phase P0's Write Scope both place this file in
/// `features/auth/data/`. Recorded in that phase's `test-results.md`.
///
/// Every method funnels through [_guard], so callers only ever see a
/// [CupidAuthFailure] — never a `FirebaseAuthException`,
/// `GoogleSignInException`, `SignInWithAppleException`, or raw
/// `PlatformException`.
class FirebaseAuthSignInGateway implements FirebaseSignInGateway {
  FirebaseAuthSignInGateway(this._auth);

  final FirebaseAuth _auth;

  bool _googleInitialized = false;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) => _guard(
    () => _auth.signInWithEmailAndPassword(email: email, password: password),
  );

  @override
  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) => _guard(() async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (displayName != null && displayName.isNotEmpty) {
      await credential.user?.updateDisplayName(displayName);
    }
  });

  @override
  Future<void> signInWithGoogle() => _guard(() async {
    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize();
      _googleInitialized = true;
    }
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const UnexpectedAuthFailure();
    }
    await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
  });

  @override
  Future<void> signInWithApple() => _guard(() async {
    final apple = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final identityToken = apple.identityToken;
    if (identityToken == null) {
      throw const UnexpectedAuthFailure();
    }
    await _auth.signInWithCredential(
      OAuthProvider('apple.com').credential(
        idToken: identityToken,
        accessToken: apple.authorizationCode,
      ),
    );
  });

  @override
  Future<void> signInWithFacebook() => _guard(() async {
    // `LoginTracking.limited` (the plugin default) returns an OIDC token that
    // `FacebookAuthProvider.credential` cannot consume.
    final result = await FacebookAuth.instance.login(
      loginTracking: LoginTracking.enabled,
    );
    final token = result.accessToken;
    if (result.status != LoginStatus.success || token == null) {
      throw const UnexpectedAuthFailure();
    }
    await _auth.signInWithCredential(
      FacebookAuthProvider.credential(token.tokenString),
    );
  });

  @override
  Future<void> sendEmailVerification() =>
      _guard(() => _requireUser().sendEmailVerification());

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email));

  @override
  Future<bool> reloadEmailVerified() => _guard(() async {
    await _requireUser().reload();
    return _auth.currentUser?.emailVerified ?? false;
  });

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw const SessionExpiredFailure();
    }
    return user;
  }

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on CupidAuthFailure {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw e.toCupidAuthFailure();
    } on GoogleSignInException {
      throw const UnexpectedAuthFailure();
    } on SignInWithAppleException {
      throw const UnexpectedAuthFailure();
    } on PlatformException {
      throw const UnexpectedAuthFailure();
    }
  }
}
