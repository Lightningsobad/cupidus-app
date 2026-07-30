import 'package:firebase_auth/firebase_auth.dart';

import '../network/cupid_auth_token_provider.dart';

/// The `auth` slot's real token source (ADR-011a). `refreshAccessToken()` is
/// `currentUser?.getIdToken(true)` — a Firebase SDK force-refresh, never an
/// HTTP call, because the backend exposes no refresh or token-exchange
/// endpoint (`architecture/solution.md` §1).
class FirebaseIdTokenProvider implements CupidAuthTokenProvider {
  FirebaseIdTokenProvider(this._auth);

  final FirebaseAuth _auth;

  @override
  Future<String?> readAccessToken() => _auth.currentUser?.getIdToken() ??
      Future<String?>.value();

  @override
  Future<String?> refreshAccessToken() =>
      _auth.currentUser?.getIdToken(true) ?? Future<String?>.value();
}
