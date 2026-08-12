import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/chat/data/chat_partner_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// STORY-018 P6 DEC-3: `firebase-auth.strategy.ts` verifies a real Firebase
/// ID token and the backend has no dev auth bypass, so any capture that
/// needs live backend state must sign in for real before the preview app
/// renders. Optional: called from `main()` before `runApp`.
///
/// Reads `--dart-define=PREVIEW_EMAIL=` / `--dart-define=PREVIEW_PASSWORD=`.
/// No credential is committed anywhere — both are supplied at `flutter run`
/// time only. When either is unset, this is a no-op and today's
/// unauthenticated preview behaviour is unchanged.
///
/// STORY-020 `architecture/solution.md` §7 (Authorized Write-Scope Extension —
/// Preview Harness): the Firebase sign-in alone leaves `BackendUserIdStore`
/// and `ChatPartnerStore` empty, so `ChatScreen` crashed on
/// `backendUserId!` and, once that was fixed, still suppressed
/// `GhostStateRow` because the preview builds it directly and bypasses
/// `ChatEntryGate`, the only caller of `refreshFromServer()`. The backend
/// sync below is the authorized public-API equivalent of the sync
/// `AuthRepository` performs after a real sign-in.
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
  try {
    final response = await getIt<CupidApi>().dio.post<Object?>('/auth/login');
    getIt<BackendUserIdStore>().updateFromLoginResponse(response.data);
    await getIt<ChatPartnerStore>().refreshFromServer();
  } catch (error) {
    // Non-fatal by design: this runs awaited before `runApp`, so an
    // unreachable backend must degrade the session-scoped screens only,
    // never block the other preview screens from rendering.
    debugPrint('bootstrapPreviewSession: backend sync skipped ($error)');
  }
}
