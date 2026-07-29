import 'dart:async';

import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The `splash` screen's auth-check outcomes (`ux/uiux-spec.md` section 3).
sealed class SessionGateState {
  const SessionGateState();
}

/// The auth-check has not resolved yet — `splash` stays on its existing
/// bobbing-dots animation (section 3: "No spinner is added ... beyond its
/// existing ... animation").
class SessionGateChecking extends SessionGateState {
  const SessionGateChecking();
}

/// No stored session: navigate to `welcome`.
class SessionGateUnauthenticated extends SessionGateState {
  const SessionGateUnauthenticated();
}

/// A valid session was found, or a non-forced token read/refresh succeeded
/// (or timed out — ADR-011h treats a timeout as optimistic success):
/// navigate directly to Home.
class SessionGateAuthenticated extends SessionGateState {
  const SessionGateAuthenticated();
}

/// A stored session exists but the refresh token itself is invalid, expired,
/// or revoked: route to `login`'s session-expired variant (section 4b),
/// distinct from [SessionGateUnauthenticated].
class SessionGateSessionExpired extends SessionGateState {
  const SessionGateSessionExpired({this.prefillEmail});

  /// Last-known signed-in email, used as a courtesy autofill on the
  /// session-expired `login` variant (section 4b) when available.
  final String? prefillEmail;
}

/// Drives the `splash` auth-check gate (`ux/uiux-spec.md` section 3) from
/// [CupidSession.state]/[CupidSession.idToken]. Depends on the stream and
/// function directly (rather than a whole [CupidSession]) so tests can drive
/// it with a plain `StreamController<CupidSessionState>` and a fake token
/// reader — [CupidSessionState] and its subtypes are plain Dart classes with
/// no Firebase dependency, but constructing a real [CupidSession] needs a
/// live/mocked `FirebaseAuth`, which this phase's write scope cannot add.
/// Never issues an HTTP request (ADR-011h): a non-forced token read is
/// bounded by [idTokenTimeout] and treated as success on timeout, so a slow
/// network never blocks the splash dwell.
class SessionGateCubit extends Cubit<SessionGateState> {
  SessionGateCubit({
    required Stream<CupidSessionState> sessionState,
    required this._idToken,
    this.idTokenTimeout = const Duration(seconds: 3),
  }) : super(const SessionGateChecking()) {
    _subscription = sessionState.listen(_onSessionState);
  }

  final Future<String?> Function({bool forceRefresh}) _idToken;
  final Duration idTokenTimeout;
  late final StreamSubscription<CupidSessionState> _subscription;

  Future<void> _onSessionState(CupidSessionState sessionState) async {
    switch (sessionState) {
      case CupidSessionUnknown():
        return;
      case CupidSessionSignedOut():
        if (!isClosed) emit(const SessionGateUnauthenticated());
      case CupidSessionSignedIn(:final email):
        await _resolveSignedIn(email);
    }
  }

  Future<void> _resolveSignedIn(String? email) async {
    try {
      // Non-forced read per ADR-011h; a timeout is optimistic success, a
      // thrown refresh failure (user-token-expired/user-disabled/
      // user-not-found) is the section-4b session-expired case. No
      // `onTimeout` callback is passed: its return type is checked against
      // the future's *reified* type argument at runtime, which narrows to
      // non-nullable `String` whenever an `idToken` implementation never
      // actually returns null, making `() => null` an unreliable fallback.
      // Catching `TimeoutException` instead sidesteps that check entirely.
      await _idToken().timeout(idTokenTimeout);
      if (!isClosed) emit(const SessionGateAuthenticated());
    } on TimeoutException {
      if (!isClosed) emit(const SessionGateAuthenticated());
    } catch (_) {
      if (!isClosed) emit(SessionGateSessionExpired(prefillEmail: email));
    }
  }

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
