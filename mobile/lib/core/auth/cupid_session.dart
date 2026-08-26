import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../network/cupid_auth_token_provider.dart';
import 'jwt_token_provider.dart';

/// Registration hook for any store holding authenticated data
abstract interface class SessionScopedStore {
  Future<void> clearOnSignOut();
}

/// The session state driving the splash gate and the forced re-auth route
sealed class CupidSessionState {
  const CupidSessionState();
}

/// No auth state has resolved yet.
class CupidSessionUnknown extends CupidSessionState {
  const CupidSessionUnknown();
}

/// No user is signed in.
class CupidSessionSignedOut extends CupidSessionState {
  const CupidSessionSignedOut();
}

/// A user is signed in.
class CupidSessionSignedIn extends CupidSessionState {
  const CupidSessionSignedIn({required this.uid, this.email});

  final String uid;
  final String? email;
}

/// The single public session surface. Supports JWT auth and fallback Firebase session.
class CupidSession {
  CupidSession({
    JwtTokenProvider? tokenProvider,
    fb.FirebaseAuth? firebaseAuth,
  })  : _tokenProvider = tokenProvider ?? JwtTokenProvider(),
        _firebaseAuth = firebaseAuth {
    _init();
  }

  final JwtTokenProvider _tokenProvider;
  final fb.FirebaseAuth? _firebaseAuth;
  final List<SessionScopedStore> _scopedStores = [];
  final StreamController<CupidSessionState> _stateController =
      StreamController<CupidSessionState>.broadcast();
  final StreamController<String?> _tokenChangeController =
      StreamController<String?>.broadcast();

  CupidSessionState _currentState = const CupidSessionUnknown();

  CupidSessionState get currentState => _currentState;

  CupidAuthTokenProvider get tokenProvider => _tokenProvider;

  Future<void> _init() async {
    final token = await _tokenProvider.readAccessToken();
    final userId = await _tokenProvider.getSavedUserId();
    final email = await _tokenProvider.getSavedEmail();

    if (token != null && userId != null) {
      _currentState = CupidSessionSignedIn(uid: userId, email: email);
    } else if (_firebaseAuth?.currentUser != null) {
      final user = _firebaseAuth!.currentUser!;
      _currentState = CupidSessionSignedIn(uid: user.uid, email: user.email);
    } else {
      _currentState = const CupidSessionSignedOut();
    }
    _stateController.add(_currentState);
  }

  /// Drives the splash gate and navigation.
  Stream<CupidSessionState> get state async* {
    yield _currentState;
    yield* _stateController.stream;
  }

  Future<String?> idToken({bool forceRefresh = false}) => forceRefresh
      ? _tokenProvider.refreshAccessToken()
      : _tokenProvider.readAccessToken();

  Stream<String?> get idTokenStream => _tokenChangeController.stream;

  void registerScopedStore(SessionScopedStore store) {
    _scopedStores.add(store);
  }

  /// Set authenticated session with JWT token
  Future<void> setSession({
    required String token,
    required String email,
    required String userId,
  }) async {
    await _tokenProvider.saveSession(
      token: token,
      email: email,
      userId: userId,
    );
    _currentState = CupidSessionSignedIn(uid: userId, email: email);
    _stateController.add(_currentState);
    _tokenChangeController.add(token);
  }

  /// Sign-out and teardown scoped stores
  Future<void> signOut() async {
    await _tokenProvider.clearSession();
    try {
      await _firebaseAuth?.signOut();
    } catch (_) {}

    _currentState = const CupidSessionSignedOut();
    _stateController.add(_currentState);
    _tokenChangeController.add(null);

    for (final store in _scopedStores) {
      await store.clearOnSignOut();
    }
  }
}
