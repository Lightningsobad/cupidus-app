import 'package:firebase_auth/firebase_auth.dart';

/// STORY-018 P6 DEC-3: `firebase-auth.strategy.ts` verifies a real Firebase
/// ID token and the backend has no dev auth bypass, so any capture that
/// needs live backend state must sign in for real before the preview app
/// renders. Optional: called from `main()` before `runApp`.
///
/// Reads `--dart-define=PREVIEW_EMAIL=` / `--dart-define=PREVIEW_PASSWORD=`.
/// No credential is committed anywhere — both are supplied at `flutter run`
/// time only. When either is unset, this is a no-op and today's
/// unauthenticated preview behaviour is unchanged.
Future<void> bootstrapPreviewSession() async {
  const String email = String.fromEnvironment('PREVIEW_EMAIL');
  const String password = String.fromEnvironment('PREVIEW_PASSWORD');
  if (email.isEmpty || password.isEmpty) {
    return;
  }
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}
