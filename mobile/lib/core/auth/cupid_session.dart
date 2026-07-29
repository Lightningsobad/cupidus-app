import 'package:firebase_auth/firebase_auth.dart';

import '../network/cupid_auth_token_provider.dart';
import 'firebase_id_token_provider.dart';

/// Registration hook for any store holding authenticated data
/// (`architecture/solution.md` §2). Every store that must be cleared on
/// sign-out (AC4) registers here via [CupidSession.registerScopedStore]
/// rather than adding a second sign-out path.
abstract interface class SessionScopedStore {
  Future<void> clearOnSignOut();
}

/// The session state driving the splash gate (UX §3) and the forced
/// re-auth route (UX §4b).
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

/// The single public session surface (`architecture/solution.md` §2,
/// imported as `package:cupid_mobile/core/auth/cupid_auth.dart`).
/// `firebase_auth` is the only source of session truth — this class holds
/// no parallel hand-rolled session cache.
class CupidSession {
  CupidSession({FirebaseAuth? auth, CupidAuthTokenProvider? tokenProvider})
      : _auth = auth ?? FirebaseAuth.instance,
        _tokenProvider =
            tokenProvider ?? FirebaseIdTokenProvider(auth ?? FirebaseAuth.instance);

  final FirebaseAuth _auth;
  final CupidAuthTokenProvider _tokenProvider;
  final List<SessionScopedStore> _scopedStores = [];

  /// Drives the splash gate (UX §3) and the forced re-auth route (UX §4b).
  /// Starts at [CupidSessionUnknown] and then follows Firebase's own
  /// restored auth state — no network call is made (ADR-011b/h).
  Stream<CupidSessionState> get state async* {
    yield const CupidSessionUnknown();
    yield* _auth.authStateChanges().map(_toSessionState);
  }

  /// The R8 contract: STORY-004 calls this to populate
  /// `handshake.auth.token`. Never issues an HTTP request of its own
  /// (ADR-011a) — `forceRefresh` maps straight to the Firebase SDK.
  Future<String?> idToken({bool forceRefresh = false}) => forceRefresh
      ? _tokenProvider.refreshAccessToken()
      : _tokenProvider.readAccessToken();

  /// Emits on every token rotation. STORY-004 subscribes and re-handshakes
  /// on emit, since an ID token lives ~1 hour while a socket connection is
  /// long-lived (`architecture/solution.md` §2).
  Stream<String?> get idTokenStream => _auth
      .idTokenChanges()
      .asyncMap((user) => user?.getIdToken() ?? Future<String?>.value());

  /// Registers a store to be torn down, in registration order, on
  /// [signOut] (AC4).
  void registerScopedStore(SessionScopedStore store) {
    _scopedStores.add(store);
  }

  /// Firebase sign-out, then ordered [SessionScopedStore.clearOnSignOut]
  /// teardown (AC4).
  Future<void> signOut() async {
    await _auth.signOut();
    for (final store in _scopedStores) {
      await store.clearOnSignOut();
    }
  }

  CupidSessionState _toSessionState(User? user) {
    if (user == null) return const CupidSessionSignedOut();
    return CupidSessionSignedIn(uid: user.uid, email: user.email);
  }
}
