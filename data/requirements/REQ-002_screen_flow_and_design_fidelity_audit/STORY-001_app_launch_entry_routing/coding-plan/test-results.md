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

## Phase P1 – AC2/AC3 split at the gate (ADR-3, ADR-4)

Date: 2026-08-13
Owner: Mobile Developer

### Commands

| # | Command | Result |
|---|---------|--------|
| 1 | `flutter test test/core/auth/ test/features/auth/` | `00:01 +55: All tests passed!` |
| 2 | `flutter analyze lib/core/auth lib/core/di/service_locator.dart lib/features/auth test/core/auth test/features/auth` | `5 issues found. (ran in 1.8s)` — all `info`, all `prefer_initializing_formals`; 3 pre-existing (`auth_repository.dart:23`, `splash_screen.dart:34/35`), 2 introduced here (`auth_repository.dart:24`, `session_gate_cubit.dart:57`). See the analyze note below. |
| 3 | `flutter analyze lib test` | `79 issues found. (ran in 2.0s)` — all `info`, zero errors, zero warnings. |
| 4 | `flutter test` (full suite, regression check on the DI + constructor changes) | `00:24 +951: All tests passed!` (P0's 933 plus this phase's 18 new tests) |

Bare `flutter analyze` remains unusable here for the reason recorded under
P0: it walks `build/ios/SourcePackages/checkouts/flutterfire/**`.

Analyze note: the two new infos are `prefer_initializing_formals` on
`AuthHistoryStore? authHistoryStore` being assigned to a private field. They
cannot be silenced by following the lint's own suggestion — Dart forbids a
named parameter whose name starts with `_`, so `this._authHistoryStore` is not
expressible for a named parameter. This is the identical false positive already
reported one line above on `_backendUserIdStore`, and the same idiom used by
`splash_screen.dart`; the pattern was kept for consistency rather than
suppressed with a local `ignore`. Command 3's total moved 78 → 79 while command
2 attributes 2 infos to this phase, so one info counted in P0's run is no longer
reported; that delta was not reconciled further, and both runs report zero
errors and zero warnings.

### Files changed

| Path | Change |
|------|--------|
| `mobile/lib/core/auth/auth_history_store.dart` | New. `AuthHistoryStore implements SessionScopedStore`, `SharedPreferences`-backed behind the injectable `Future<SharedPreferences> Function()` seam. |
| `mobile/lib/core/auth/cupid_auth.dart` | One `export` line. |
| `mobile/lib/core/di/service_locator.dart` | One import; `AuthHistoryStore` lazy singleton registered with `registerScopedStore`; `authHistoryStore:` threaded into the existing `AuthRepository` registration. |
| `mobile/lib/features/auth/data/auth_repository.dart` | Optional `AuthHistoryStore?` ctor param, private `_onAuthenticated`, called from all five sign-in entry points. |
| `mobile/lib/features/auth/presentation/session_gate_cubit.dart` | Optional store injection; `CupidSessionSignedOut` branch now splits on the marker. |
| `mobile/test/core/auth/auth_history_store_test.dart` | New. 6 tests. |
| `mobile/test/features/auth/presentation/session_gate_cubit_test.dart` | New. 8 tests. |
| `mobile/test/features/auth/data/auth_repository_test.dart` | 4 marker tests added; the two existing `signOut` tests untouched. |

### Acceptance criteria

| AC | Status | Evidence |
|----|--------|----------|
| Signed-out + marker set → `SessionGateSessionExpired` (AC2) | MET | `session_gate_cubit_test.dart` "signed-out with a history marker resolves to session-expired (AC2)", asserting `prefillEmail` too. |
| Signed-out + marker absent → `SessionGateUnauthenticated` (AC3) | MET | `session_gate_cubit_test.dart` "signed-out without a history marker resolves to welcome (AC3)". |
| Signed-in behaviour unchanged, including timeout-as-success | MET | Three signed-in tests (token succeeds, token times out, refresh throws); `_resolveSignedIn` was not edited. The four pre-existing `splash_screen_test.dart` routing tests still pass. |
| `CupidSession.signOut()` clears the marker through the existing teardown, no second sign-out path | MET | `AuthHistoryStore implements SessionScopedStore` and is registered via `getIt<CupidSession>().registerScopedStore(store)` in the same idiom as `CouplePairingStore`; `session_gate_cubit_test.dart` "a deliberate sign-out teardown returns the gate to welcome" and `auth_history_store_test.dart` "clearOnSignOut resets the device to the never-signed-in state" cover the effect. No sign-out code path was added or edited. |
| The gate still issues zero HTTP requests | MET | `SessionGateCubit` takes no `CupidApi`/`Dio`; the store reads `SharedPreferences` only. `session_gate_cubit_test.dart` "the signed-out path never reads an id token (ADR-011h)" asserts the resolution does not even reach the token provider. |
| `flutter analyze` clean; all tests in scope pass | MET | Commands 1-4; zero errors, zero warnings. |

### Test scope honoured

Unit/component only. No app install, no device/emulator/simulator launch, no
signing or store configuration touched, no e2e run.

### Deviations and gaps worth a reviewer's attention

1. **The production splash still constructs the gate without the store, so
   AC2 is not yet reachable end to end.** `SplashScreen._defaultSessionGateCubit`
   (`mobile/lib/features/auth/presentation/screens/splash_screen.dart:41-47`)
   builds `SessionGateCubit` with `sessionState` and `idToken` only.
   `splash_screen.dart` is not in P1's Write Scope — it belongs to P2 — so the
   store parameter was made optional (`AuthHistoryStore?`) rather than required:
   a required parameter would have left the tree failing to analyze at the end
   of this phase. A null store preserves the pre-P1 behaviour exactly
   (signed-out → `welcome`), which is why the four existing splash routing tests
   still pass unchanged. **P2 must add `authHistoryStore:
   getIt<AuthHistoryStore>()` to `_defaultSessionGateCubit`**, otherwise the
   AC2 defect (finding D3) survives in production even though the mechanism now
   exists and is tested.
2. **Social sign-ins clear the prefill email rather than preserving it.**
   `FirebaseSignInGateway.signInWithGoogle/Apple/Facebook` return `void`, so no
   email is available at the call site and `_onAuthenticated(null)` is used.
   `markAuthenticated` treats a null/blank email as "drop the stored address",
   so a Google/Apple/Facebook user's later session-expiry lands on `login` with
   an empty prefill. The alternative — keeping the last stored address — would
   prefill a *different* user's email after an account switch, which is worse.
   Raising the gateway's return type to carry the signed-in email is a
   cross-cutting change outside this phase's Write Scope.
3. **The `auth.` key namespace is pinned by literal, not by constant.**
   `auth_history_store_test.dart` asserts the raw strings
   `auth.has_previous_session_v1` / `auth.last_email_v1` against a real
   `SharedPreferences` instance rather than importing the store's constants,
   which stay private. A rename therefore fails the test rather than silently
   orphaning previously persisted markers on upgrade.

## Phase P0 — re-verification

Date: 2026-08-13
Owner: Mobile Developer
Worktree HEAD: `1f66576` (`BaseHead` for this dispatch)

P0 was dispatched a second time while its phase file still read
`Status: NOT_STARTED`. On inspection the phase's three Write Scope files were
already present and already committed in `fa628c0`, an ancestor of the current
worktree HEAD, so no source change was needed. The gates were re-run from
scratch against the current tree to confirm the landed code still holds, and the
phase file Status was corrected to `DONE`.

### Commands

| # | Command | Result |
|---|---------|--------|
| 1 | `flutter pub get` | `Got dependencies!` (same 35 out-of-date-but-compatible packages; no constraint changed) |
| 2 | `flutter analyze lib/features/auth/data/firebase_auth_sign_in_gateway.dart lib/core/di/service_locator.dart test/features/auth/data/firebase_auth_sign_in_gateway_test.dart` | `No issues found! (ran in 1.3s)` |
| 3 | `flutter analyze lib test` | `79 issues found. (ran in 2.0s)` — all `info`, zero errors, zero warnings. Matches the P1 baseline exactly; command 2 confirms none belong to the P0 files. Exit code is 1 because `flutter analyze` exits non-zero on `info`-level findings too. |
| 4 | `flutter test test/features/auth/` | `00:01 +42: All tests passed!` |
| 5 | `flutter test --reporter=failures-only` (full suite) | `+951: All tests passed!`, zero failure blocks |

The Flutter SDK is not on `PATH`; all commands used `$HOME/flutter/bin/flutter`
(Flutter 3.44.1, Dart 3.12.1) from `<worktree>/mobile`.

Command 4 now reports 42 tests where the original P0 run reported 30: the extra
12 are P1's `session_gate_cubit_test.dart` and `auth_repository_test.dart`
additions, which live under the same `test/features/auth/` path.

### Files changed

| Path | Change |
|------|--------|
| `.../coding-plan/phase-P0-auth-repository-reachability.md` | Status `NOT_STARTED` → `DONE`; Gate line marked SATISFIED. |
| `.../coding-plan/test-results.md` | This section appended. |

No file under `mobile/` was modified by this dispatch.

### Acceptance criteria

All four AC remain MET on the evidence recorded in the original "Phase P0"
section above, now re-confirmed by commands 2-5 against the current tree. The
"Reported, not fixed" native-configuration findings and the three deviations
recorded under Phase P0 still stand unchanged and still need a reviewer
decision — in particular deviation 1, the `features/auth/data/` vs
`core/auth/` file-placement contradiction.
