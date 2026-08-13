# STORY-001 test results

Flutter is not on `PATH` on this machine; all commands below were run with the
absolute SDK path `$HOME/flutter/bin/flutter`, from
`<worktree>/mobile`.

Worktree:
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-001`

## Phase P0 – `AuthRepository` reachability (ADR-7)

Date: 2026-08-13
Owner: Mobile Developer

### Commands

| # | Command | Result |
|---|---------|--------|
| 1 | `flutter pub get` | `Got dependencies!` (35 packages have newer versions incompatible with the declared constraints; no constraint was changed by this phase) |
| 2 | `flutter analyze lib/features/auth/data/firebase_auth_sign_in_gateway.dart lib/core/di/service_locator.dart test/features/auth/data/firebase_auth_sign_in_gateway_test.dart` | `No issues found! (ran in 3.4s)` |
| 3 | `flutter analyze lib test` | `78 issues found. (ran in 4.2s)` — all `info` severity, all pre-existing (`prefer_initializing_formals`, `use_null_aware_elements`, one `deprecated_member_use` on `SemanticsService.announce`). Zero attributable to this phase, confirmed by command 2. |
| 4 | `flutter test test/features/auth/` | `00:04 +30: All tests passed!` |
| 5 | `flutter test` (full suite, regression check on the DI change) | `+933: All tests passed!` |

Bare `flutter analyze` (no path argument) is **not** a usable gate in this
repository: it walks `build/ios/SourcePackages/checkouts/flutterfire/**`, a
vendored CocoaPods/SwiftPM checkout containing `cloud_firestore` examples that
are not part of this app and do not resolve. That produced ~200 errors before
this phase and is unrelated to it. Use `flutter analyze lib test`, as in
command 3.

### Files changed

| Path | Change |
|------|--------|
| `mobile/lib/features/auth/data/firebase_auth_sign_in_gateway.dart` | New. Concrete `FirebaseSignInGateway`. |
| `mobile/lib/core/di/service_locator.dart` | Registration only: `AuthRepository` lazy singleton appended at the end of `setupServiceLocator()`, plus two imports. |
| `mobile/test/features/auth/data/firebase_auth_sign_in_gateway_test.dart` | New. 12 error-mapping / current-user tests. |

`main_preview.dart` was not touched; its preview stub construction is
unchanged, per the phase file task 2.

### Acceptance criteria

| AC | Status | Evidence |
|----|--------|----------|
| `getIt<AuthRepository>()` resolves in a production build without throwing | MET | `registerLazySingleton<AuthRepository>` resolves `CupidApi`, `CupidSession`, and `BackendUserIdStore`, all registered earlier in the same function; the gateway takes `FirebaseAuth.instance`, and `main.dart` already initializes Firebase before `setupServiceLocator()`. |
| Email/password sign-in, registration, password reset, email verification, verification reload implemented against `firebase_auth`, not stubbed | MET | `signInWithEmailAndPassword`, `createUserWithEmailAndPassword` (+ `updateDisplayName`), `sendPasswordResetEmail`, `User.sendEmailVerification`, `User.reload`. |
| Provider errors surface as `CupidAuthFailure`, never a raw plugin exception | MET | Single `_guard` funnel maps `FirebaseAuthException` via the existing `toCupidAuthFailure()` extension, and `GoogleSignInException` / `SignInWithAppleException` / raw `PlatformException` to `UnexpectedAuthFailure`. Covered by commands 4-5. |
| `flutter analyze` clean; new test file passes | MET | Commands 2 and 4. |

### Test scope honoured

Unit/component only. No app install, no device/emulator/simulator launch, no
signing or store configuration touched, no e2e or integration-device run, no
live provider sign-in.

## Reported, not fixed

These are outside this story per ADR-7 ("The implementer must report — not fix
— any missing native configuration found"). Each blocks a social sign-in
button at tap time, not the launch-routing decision this story delivers.

Core Firebase itself is fine on both platforms: `main.dart` initializes from
`lib/firebase_options.dart`, not from the native service files, so email and
password auth needs nothing below. Each item below breaks exactly one social
button at tap time.

1. **Google, iOS — OAuth redirect URL scheme missing.**
   `ios/Runner/GoogleService-Info.plist` does carry `CLIENT_ID` and
   `REVERSED_CLIENT_ID`, but `ios/Runner/Info.plist` has no `CFBundleURLTypes`
   array at all, so the `REVERSED_CLIENT_ID` scheme the Google sign-in redirect
   comes back on is unregistered.
2. **Google, Android — `google-services.json` is never processed.**
   `mobile/android/app/google-services.json` exists and contains a
   `client_type: 3` web OAuth client, but the
   `com.google.gms.google-services` Gradle plugin is applied in neither
   `mobile/android/build.gradle.kts` nor `mobile/android/app/build.gradle.kts`.
   Without it, no `R.string.default_web_client_id` resource is generated, so
   `google_sign_in` 7.2.0 has no `serverClientId` on Android. The gateway calls
   `GoogleSignIn.instance.initialize()` with no explicit ids, relying on those
   native config paths; until one exists, `authenticate()` fails with
   `GoogleSignInExceptionCode.clientConfigurationError`, which the gateway
   surfaces as `UnexpectedAuthFailure`.
3. **Apple — capability absent, Android/Web options absent.** There is no
   `.entitlements` file anywhere under `mobile/ios/`, so the Sign In With Apple
   capability is not enabled. `getAppleIDCredential` is also called without
   `webAuthenticationOptions`, which `sign_in_with_apple` 8.1.0 requires on
   Android and Web (service id plus redirect URI).
4. **Apple — no nonce is sent.** Binding the Apple identity token to a
   per-attempt nonce needs a SHA-256 of the raw nonce, which needs the `crypto`
   package. `crypto` is not a declared dependency and this phase's
   Requirement Configuration Guide is `Update Required: NO`, so no dependency
   was added. Firebase accepts the credential without a nonce; adding one is a
   hardening follow-up, not a blocker.
5. **Facebook — not configured on either platform.** `ios/Runner/Info.plist`
   has no `FacebookAppID`, `FacebookClientToken`, `FacebookDisplayName`, or
   `fb<APP_ID>` URL scheme. On Android there is no `res/values/strings.xml` at
   all, and `android/app/src/main/AndroidManifest.xml` declares neither the
   `com.facebook.sdk.ApplicationId` / `ClientToken` meta-data nor
   `FacebookActivity` / `CustomTabActivity`. `FacebookAuth.instance.login()`
   cannot succeed until those exist. Note also that the gateway passes
   `LoginTracking.enabled` rather than the plugin default
   `LoginTracking.limited`, because limited login returns an OIDC token that
   `FacebookAuthProvider.credential` cannot consume.

## Deviations and gaps worth a reviewer's attention

1. **File placement contradicts a REQ-001 boundary rule.** The dartdoc on
   `mobile/lib/features/auth/data/firebase_sign_in_gateway.dart` states that
   `firebase_auth`, `google_sign_in`, `sign_in_with_apple`, and
   `flutter_facebook_auth` imports are restricted to `mobile/lib/core/auth/`,
   and that the concrete implementation belongs there. REQ-002
   `architecture/solution.md` §5 "Affected Modules" and phase P0's Write Scope
   both place the new file in `features/auth/data/` instead. This phase
   followed the P0 Write Scope. Nothing enforces the boundary as a lint, so
   this is a documentation/architecture inconsistency to settle, not a build
   failure. Moving the file later is a pure relocation plus one import change
   in `service_locator.dart`.
2. **`CupidAuthFailure` has no cancellation case.** A user dismissing the
   Google, Apple, or Facebook sheet currently surfaces as
   `UnexpectedAuthFailure`, so the UI will show a generic error for a
   deliberate cancel. Adding a `CancelledFailure` variant means editing
   `mobile/lib/core/auth/cupid_auth_failure.dart`, which is outside this
   phase's Write Scope, and the phase file explicitly forbids inventing a
   second failure taxonomy. Recommend a follow-up story.
3. **Social sign-in paths are not unit-tested.** `SignInWithApple` is a static
   API and `GoogleSignIn`/`FacebookAuth` are plugin singletons requiring
   platform channels, so they are reached directly rather than injected. The
   injected seam is `FirebaseAuth` only, matching the existing
   `FirebaseIdTokenProvider(FirebaseAuth)` precedent. The tests therefore cover
   email/password, password reset, and the current-user operations, which is
   exactly the set named in this phase's acceptance criteria.
