/// The seam between [AuthRepository] and Firebase credential sign-in.
///
/// `architecture/solution.md` section 4 "Boundaries And Ownership" restricts
/// `package:firebase_auth`, `package:google_sign_in`,
/// `package:sign_in_with_apple`, and `package:flutter_facebook_auth` imports
/// to `mobile/lib/core/auth/`. `AuthRepository` lives in
/// `mobile/lib/features/auth/data/` (per the same section's "Affected
/// Components And Layers"), so it cannot import those packages directly to
/// perform credential sign-in. This interface is the boundary-compliant seam:
/// it is declared here (no restricted imports needed for method signatures)
/// and implemented by a concrete `core/auth/` class that is out of this
/// phase's write scope — see the STORY-003 P4 completion report for the
/// exact follow-up needed to supply and register that implementation.
///
/// Every method throws a `CupidAuthFailure`
/// (`package:cupid_mobile/core/auth/cupid_auth.dart`) on failure, never a raw
/// `FirebaseAuthException`, so this file and its callers need no Firebase
/// import to handle errors.
abstract interface class FirebaseSignInGateway {
  Future<void> signInWithEmail({required String email, required String password});

  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signInWithGoogle();

  Future<void> signInWithApple();

  Future<void> signInWithFacebook();

  Future<void> sendEmailVerification();

  Future<void> sendPasswordResetEmail(String email);

  /// Reloads the current Firebase user and returns the refreshed
  /// `emailVerified` flag (ADR-011e inbox-wait polling).
  Future<bool> reloadEmailVerified();
}
