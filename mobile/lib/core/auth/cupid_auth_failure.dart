import 'package:firebase_auth/firebase_auth.dart';

/// The Firebase-origin failure contract (`architecture/solution.md` §2,
/// ADR-011c). Kept separate from `CupidApiFailure`: raw
/// `FirebaseAuthException` codes must never reach the UI, so every call site
/// in `mobile/lib/core/auth/` maps through [CupidAuthFailure.fromFirebase]
/// before returning to a feature layer.
sealed class CupidAuthFailure {
  const CupidAuthFailure();
}

/// The supplied email/password combination was rejected by Firebase
/// (`invalid-credential`, `wrong-password`, `user-not-found`, `invalid-email`).
class InvalidCredentialFailure extends CupidAuthFailure {
  const InvalidCredentialFailure();
}

/// Registration was attempted with an email already bound to an account.
class EmailAlreadyInUseFailure extends CupidAuthFailure {
  const EmailAlreadyInUseFailure();
}

/// Registration was attempted with a password Firebase considers too weak.
class WeakPasswordFailure extends CupidAuthFailure {
  const WeakPasswordFailure();
}

/// The session could not be renewed (`user-token-expired`, `user-disabled`,
/// `user-not-found` on refresh) and `CupidSession` has moved to `SignedOut`
/// (ADR-011c). UX §4b routes to `login` on this failure.
class SessionExpiredFailure extends CupidAuthFailure {
  const SessionExpiredFailure();
}

/// A Firebase call failed for network reasons (`network-request-failed`).
class AuthNetworkFailure extends CupidAuthFailure {
  const AuthNetworkFailure();
}

/// Any other Firebase-origin failure that does not fit a more specific case.
class UnexpectedAuthFailure extends CupidAuthFailure {
  const UnexpectedAuthFailure();
}

/// Maps a raw [FirebaseAuthException] to the closed [CupidAuthFailure] set
/// (`architecture/solution.md` §2).
extension CupidAuthFailureMapping on FirebaseAuthException {
  CupidAuthFailure toCupidAuthFailure() {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-email':
        return const InvalidCredentialFailure();
      case 'email-already-in-use':
        return const EmailAlreadyInUseFailure();
      case 'weak-password':
        return const WeakPasswordFailure();
      case 'user-token-expired':
      case 'user-disabled':
        return const SessionExpiredFailure();
      case 'network-request-failed':
        return const AuthNetworkFailure();
      default:
        return const UnexpectedAuthFailure();
    }
  }
}
