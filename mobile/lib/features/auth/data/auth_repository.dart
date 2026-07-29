import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:dio/dio.dart';

import 'firebase_sign_in_gateway.dart';

/// `architecture/solution.md` section 2 `AuthRepository` contract. Each
/// social/email sign-in completes Firebase first (via [FirebaseSignInGateway]
/// so this file never imports `firebase_auth` directly, per section 4
/// "Boundaries And Ownership"), then calls `POST /auth/login`, falling back
/// to `POST /auth/register` on the documented 404 `User not registered`, so
/// the backend profile row exists. The generated [CupidApi]'s `Dio` already
/// carries the current Firebase ID token via the `auth` slot interceptor, so
/// no token is threaded through here.
class AuthRepository {
  AuthRepository({required this._gateway, required this._api});

  final FirebaseSignInGateway _gateway;
  final CupidApi _api;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _gateway.signInWithEmail(email: email, password: password);
    await _syncBackendProfile();
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await _gateway.registerWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
    await _syncBackendProfile();
  }

  Future<void> signInWithGoogle() async {
    await _gateway.signInWithGoogle();
    await _syncBackendProfile();
  }

  Future<void> signInWithApple() async {
    await _gateway.signInWithApple();
    await _syncBackendProfile();
  }

  Future<void> signInWithFacebook() async {
    await _gateway.signInWithFacebook();
    await _syncBackendProfile();
  }

  Future<void> sendEmailVerification() => _gateway.sendEmailVerification();

  Future<void> sendPasswordResetEmail(String email) =>
      _gateway.sendPasswordResetEmail(email);

  Future<bool> reloadEmailVerified() => _gateway.reloadEmailVerified();

  /// `POST /auth/login`, falling back to `POST /auth/register` on a 404
  /// (`architecture/solution.md` section 2). Rethrows the mapped
  /// [CupidApiFailure] (set on `DioException.error` by
  /// `CupidErrorInterceptor`) rather than the raw [DioException], so callers
  /// only ever catch [CupidApiFailure] or [CupidAuthFailure].
  Future<void> _syncBackendProfile() async {
    try {
      await _api.getEpic1AuthApi().authControllerLogin();
    } on DioException catch (e) {
      final failure = e.error;
      if (failure is HttpStatusFailure && failure.statusCode == 404) {
        await _api.getEpic1AuthApi().authControllerRegister();
        return;
      }
      throw failure ?? const UnexpectedFailure();
    }
  }
}
