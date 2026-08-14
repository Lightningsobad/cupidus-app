import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
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
  AuthRepository({
    required this._gateway,
    required this._api,
    required this._signOut,
    BackendUserIdStore? backendUserIdStore,
    AuthHistoryStore? authHistoryStore,
  }) : _backendUserIdStore = backendUserIdStore,
       _authHistoryStore = authHistoryStore;

  final FirebaseSignInGateway _gateway;
  final CupidApi _api;

  /// STORY-004 room-key contract (`architecture/solution.md` §2
  /// `backendUserId`): populated from the `POST /auth/login` /
  /// `POST /auth/register` response body. Optional so existing callers that
  /// do not yet wire realtime keep working unchanged.
  final BackendUserIdStore? _backendUserIdStore;

  /// REQ-002 STORY-001 ADR-3 marker writer. Optional for the same reason as
  /// [_backendUserIdStore]: existing call sites keep working unchanged.
  final AuthHistoryStore? _authHistoryStore;

  /// `CupidSession.signOut()` (AC4 teardown: Firebase sign-out + ordered
  /// `SessionScopedStore.clearOnSignOut()`), injected rather than imported
  /// directly — `package:cupid_mobile/core/auth/**` construction needs a
  /// live/mocked `FirebaseAuth` this phase's write scope cannot add (same
  /// constraint documented on `SessionGateCubit`).
  final Future<void> Function() _signOut;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _gateway.signInWithEmail(email: email, password: password);
    await _onAuthenticated(email);
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
    await _onAuthenticated(email);
    await _syncBackendProfile();
  }

  Future<void> signInWithGoogle() async {
    await _gateway.signInWithGoogle();
    await _onAuthenticated(null);
    await _syncBackendProfile();
  }

  Future<void> signInWithApple() async {
    await _gateway.signInWithApple();
    await _onAuthenticated(null);
    await _syncBackendProfile();
  }

  Future<void> signInWithFacebook() async {
    await _gateway.signInWithFacebook();
    await _onAuthenticated(null);
    await _syncBackendProfile();
  }

  /// Runs after the Firebase leg succeeds and before [_syncBackendProfile],
  /// so a backend-sync network failure cannot lose the fact that this device
  /// authenticated (ADR-3). The social gateways return no email, so the
  /// session-expired login prefill is left empty rather than stale.
  Future<void> _onAuthenticated(String? email) async {
    await _authHistoryStore?.markAuthenticated(email: email);
  }

  Future<void> sendEmailVerification() => _gateway.sendEmailVerification();

  Future<void> sendPasswordResetEmail(String email) =>
      _gateway.sendPasswordResetEmail(email);

  Future<bool> reloadEmailVerified() => _gateway.reloadEmailVerified();

  /// AC4 sign-out: delegates to the injected [_signOut] teardown (see field
  /// dartdoc). Callers (e.g. [SignOutCubit]) never touch `CupidSession`
  /// directly, matching this repository's existing seam pattern for
  /// [_gateway].
  Future<void> signOut() => _signOut();

  /// `POST /auth/login`, falling back to `POST /auth/register` on a 404
  /// (`architecture/solution.md` section 2). Rethrows the mapped
  /// [CupidApiFailure] (set on `DioException.error` by
  /// `CupidErrorInterceptor`) rather than the raw [DioException], so callers
  /// only ever catch [CupidApiFailure] or [CupidAuthFailure].
  ///
  /// Reads the response body from the shared [Dio] instance directly instead
  /// of the generated `authControllerLogin`/`authControllerRegister` calls:
  /// the OpenAPI spec declares no response schema for either endpoint, so the
  /// generated client types the return `Response<void>` and the backend
  /// `User.id` (STORY-004 room-key contract) is unreachable through it.
  Future<void> _syncBackendProfile() async {
    try {
      final response = await _api.dio.post<Object?>('/auth/login');
      _backendUserIdStore?.updateFromLoginResponse(response.data);
    } on DioException catch (e) {
      final failure = e.error;
      if (failure is HttpStatusFailure && failure.statusCode == 404) {
        final response = await _api.dio.post<Object?>('/auth/register');
        _backendUserIdStore?.updateFromLoginResponse(response.data);
        return;
      }
      throw failure ?? const UnexpectedFailure();
    }
  }
}
