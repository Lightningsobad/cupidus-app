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

## Phase P2 – entry route wiring

Date: 2026-08-13
Owner: mobile-dev (Alex-Mobile-Dev-6, run
`RUN-REQ-002_screen_flow_and_design_fidelity_audit-STORY-001-mobile-dev`)

### Commands

All run from `<worktree>/mobile` with Flutter 3.44.1 / Dart 3.12.1
(`$HOME/flutter/bin/flutter`; the SDK is not on `PATH`).

| # | Command | Result |
|---|---------|--------|
| 1 | `flutter analyze lib/app lib/features/auth test/features/auth test/app` | `5 issues found.` — all `info` `prefer_initializing_formals`, **0 errors, 0 warnings**. Exit 1 (analyze exits non-zero on info too, same as the P0/P1 precedent). |
| 2 | `flutter test test/features/auth test/app test/widget_test.dart` | `+56: All tests passed!` (exit 0). |
| 3 | `flutter analyze lib/app lib/features/auth test/features/auth test/app test/widget_test.dart` | `5 issues found.` — same 5 infos as command 1, **0 errors, 0 warnings**. |
| 4 | `flutter test` (whole suite) | `+960: All tests passed!` (exit 0) — P1's 951 baseline plus this phase's 9 new tests. |

Commands 2-4 are the post-fix run. Before the write-scope extension described
under "Write-scope extension" below, command 2 reported `+53 -2: Some tests
failed.`

Bare `flutter analyze` with no path argument is still unusable here: it walks a
vendored FlutterFire CocoaPods checkout. Command 1 keeps the P0/P1 convention of
naming explicit paths.

The 5 analyzer infos are the P1 baseline (3) plus 2 new ones on
`splash_screen.dart:38-39`, both `prefer_initializing_formals` against the
private `_createSessionGateCubit` / `_createPairGateCubit` fields. They are
private-field constructor forwards, which the lint cannot express as an
initializing formal, so they are accepted rather than "fixed".

### Files changed

| Path | Change |
|------|--------|
| `mobile/lib/app/cupid_app.dart` | ADR-1: `home:` is now `SplashScreen`, not `PairGateShell`. Added the `createSessionGateCubit` injection seam alongside the existing `createPairGateCubit`. |
| `mobile/lib/features/auth/presentation/screens/splash_screen.dart` | ADR-2 handoff to `PairGateShell`; ADR-3 `authHistoryStore: getIt<AuthHistoryStore>()` added to the production gate; ADR-6 tap-to-continue affordance and its `_pendingState`/`_onTapToContinue` machinery deleted; `authRepository` resolved lazily so the authenticated path never touches `getIt<AuthRepository>()`. |
| `mobile/test/features/auth/presentation/splash_screen_test.dart` | Harness switched from the removed `resolvePairingStatus` seam to `createPairGateCubit`; AC1 test retargeted to `PairGateShell`; 2 tests added for the AC4 dwell floor and the ADR-6 affordance removal. |
| `mobile/test/app/cupid_app_entry_routing_test.dart` | New. 7 app-level tests for AC1/AC4/AC5, including two source-scan guards. |
| `mobile/test/app/feature_flags_test.dart` | Write-scope extension. Test-only: `createSessionGateCubit` seam + explicit dwell advance. All existing assertions kept verbatim. |
| `mobile/test/widget_test.dart` | Write-scope extension. Same test-only change. |
| `.../coding-plan/phase-P2-entry-route-wiring.md` | Status `NOT_STARTED` → `DONE`. |
| `.../coding-plan/test-results.md` | This section appended. |

`mobile/lib/main_preview.dart` was in the conditional write scope but needed no
change: `_buildSplash` passes `authRepository:` explicitly, which the new
constructor still accepts.

### Acceptance criteria

| AC | Verdict | Evidence |
|----|---------|----------|
| AC1 — valid session routes to the authenticated root | MET | `splash_screen_test.dart` "CupidSessionSignedIn … routes to PairGateShell, never a bare HomeScreen" asserts `PairGateShell` present and `HomeScreen` absent, closing ADR-2. `cupid_app_entry_routing_test.dart` "CupidApp boots to splash, not straight to the pair gate" covers the same route at app level. |
| AC2 — expired session routes to `LoginScreen(sessionExpired: true)` | MET | `splash_screen_test.dart` "CupidSessionSignedIn with a failing token routes to the session-expired LoginScreen variant". Reachability in production is now real, not just testable: the P1 deviation is closed by wiring `authHistoryStore: getIt<AuthHistoryStore>()` into `_defaultSessionGateCubit`, and a source-scan guard test pins that construction so it cannot silently regress. |
| AC3 — no prior session routes to `WelcomeScreen` | MET | `splash_screen_test.dart` "CupidSessionSignedOut routes to WelcomeScreen". |
| AC4 — nothing navigates before `dwell_complete AND session_resolved` | MET | Three tests: a session resolved at t=0 still holds splash through 1900 ms and only leaves after the 2 s floor; the dwell elapsing on an unresolved gate navigates nowhere; and tapping the splash body reaches no destination now that ADR-6 removed the affordance. |
| AC5 — resume invariants hold | MET | Structural, per ADR-5. A full `inactive → hidden → paused → hidden → inactive → resumed` cycle after routing neither re-mounts splash (`gateCreations` stays 1) nor changes the route; a session emission arriving after `pushReplacement` causes no navigation; and a source-scan guard asserts neither entry-routing source mentions `WidgetsBindingObserver`, `AppLifecycleState`, or `didChangeAppLifecycleState`. |

### Test scope honoured

Commands 1-3 stay inside the phase's declared paths plus the two extension
files. Command 4 is the whole-suite regression sweep. No emulator, simulator,
signing, or e2e work was attempted; device capture remains P3.

### Write-scope extension — resolved

This phase initially closed red. Command 2 failed on exactly two tests, both in
`mobile/test/app/feature_flags_test.dart`:

1. `CupidApp resolves dark theme mode and vi locale with flags off, and the
   runtime readiness key still resolves` —
   `Bad state: GetIt: Object/factory with type CupidSession is not registered
   inside GetIt` at `splash_screen.dart:46` (`_defaultSessionGateCubit`), then
   `Found 0 widgets with key [<'home_screen_ready_signal'>]` at
   `feature_flags_test.dart:85`.
2. `AppL10n under Locale(en) stays directly constructible with flags off` —
   `type 'Null' is not a subtype of type 'SessionGateCubit' in type cast` thrown
   from `_CreateInheritedProviderState.dispose` while finalizing the widget
   tree. This is fallout from failure 1: the provider's `create` threw, so its
   value is null, and tearing that provider down then crashes.

`mobile/test/widget_test.dart` fails the same way for the same reason.

These are **not** production defects, and they cannot be fixed from production
code, for two independent reasons:

- `mobile/lib/main.dart:20` does call `setupServiceLocator()` before
  `runApp(const CupidApp())`, so `CupidSession` *is* registered on the real
  launch path. Adding a `getIt.isRegistered` fallback to `SplashScreen` would
  exist purely to satisfy these tests while masking a genuine DI break, and
  would silently route a mis-wired production build to the signed-out branch.
- Even with DI registered, these tests supply no session stream, so the gate
  stays `SessionGateChecking` forever and splash correctly never navigates.
  `pumpAndSettle()` would still never reach `home_screen_ready_signal`.

The assertions were written when `CupidApp.home` was the pair gate;
`home_screen_ready_signal` was a proxy for "the app booted". ADR-1 makes that
proxy wrong by design. The correct change is test-side and does not weaken any
assertion: pass the `createSessionGateCubit:` seam with a signed-in session,
pump past the 2 s dwell instead of relying on `pumpAndSettle()`, and keep the
existing theme/locale/readiness expectations as they are.

Both files were outside the phase's original write scope, so the change was
escalated rather than guessed. Scrum Master approved the extension on
2026-08-13 and the fix was applied to both files:
`createSessionGateCubit:` is passed a `SessionGateCubit` reading a
`Stream.value(CupidSessionSignedIn(...))`, and `pumpAndSettle()` is preceded by
an explicit `pump(Duration(seconds: 3))` to clear the AC4 dwell — `pumpAndSettle`
alone cannot, because the splash dot animation never settles. Every pre-existing
assertion (`themeMode`, `locale`, `home_screen_ready_signal`) is kept verbatim.
No production code changed for this, nothing was weakened, deleted, or skipped.

Commands 2-4 above are the post-fix results. Phase status is now `DONE`.

### Deviations and gaps worth a reviewer's attention

1. **`createSessionGateCubit` was added to `CupidApp`, which P2 Task 1 does not
   name.** Task 1 only specifies the `createPairGateCubit` passthrough, but the
   phase's own AC4/AC5 app-level assertions are untestable without a session
   injection point, because a real `CupidSession` needs a live or mocked
   `FirebaseAuth`. The parameter defaults to null, so the production tree is
   unchanged.
2. **`resolvePairingStatus` was deleted from `SplashScreen`.** Once ADR-2 makes
   the authenticated destination `PairGateShell`, that seam is dead — the shell
   owns the pairing check and exposes no such parameter. `PairGateShell` itself
   was read-only for this phase and was not modified.
3. **The two source-scan guard tests read `lib/...` by relative path**, matching
   the existing precedent in
   `test/features/reminders/reminder_copy_guard_test.dart`. They pass only when
   the suite runs with `<worktree>/mobile` as the working directory.
4. **The AC5 lifecycle test hard-codes the transition sequence**
   `inactive → hidden → paused → hidden → inactive → resumed`, because
   `WidgetsBinding` rejects a direct `resumed → paused` jump. If Flutter relaxes
   that state machine the intermediate steps become redundant, not wrong.
5. **A stale comment at `reminder_overlay_host.dart:28-34`** claims `main.dart`
   does not call `setupServiceLocator()` yet. It does, at line 20. Out of scope
   here, but it misleads exactly the DI reasoning that produced the blocker
   above.

## Entry Point Reachability

Rule 12e1. Round-1 review finding B2.

Reachable: YES

Path from a cold app launch to this story's changed behaviour, with no
intermediate navigation and nothing to discover:

`launcher icon` → `com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
→ `main.dart:20 setupServiceLocator()` → `runApp(const CupidApp())`
→ `cupid_app.dart:54-57 MaterialApp.home: SplashScreen(...)`
→ `SplashScreen.initState` starts the 2 s dwell timer and subscribes the
`SessionGateCubit` → gate resolves → `splash_screen.dart:128-130
pushReplacement` → one of `PairGateShell` (AC1), `LoginScreen` session-expired
variant (AC2), or `WelcomeScreen` (AC3).

The entry point is the app's own boot route, so there is no menu item, deep
link, feature flag, or setting a user must find first. Nothing is gated behind
a build flag: `createSessionGateCubit` defaults to null and the production tree
uses `_defaultSessionGateCubit`.

| Evidence | Result |
|---|---|
| `cupid_app.dart:54-57` sets `home: SplashScreen(...)`, replacing the previous `PairGateShell` | Confirmed by code read |
| `cupid_app_entry_routing_test.dart:79` pins `MaterialApp.home` as `SplashScreen` so the entry point cannot silently regress | Passing |
| Real device cold start reaches splash and then a resolved destination | Confirmed twice on `emulator-5560` — see Story Runtime Startup Smoke below |
| Launcher activity resolves | `adb shell cmd package resolve-activity --brief -c android.intent.category.LAUNCHER com.snapsofts.cupid` → `com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` |

## Story Runtime Startup Smoke

Rule 12g. Round-1 review finding B3.

Runtime-Smoke: PERFORMED — real device cold start of the production entry point.

Impacted runtime service/app: `mobile-app` (`data/devops/system/runtime-command-registry.json`).

This story replaces `MaterialApp.home`, i.e. the literal boot route, and adds two
`setupServiceLocator()` registrations that widget tests never execute. The smoke
below runs `main()` for real: Firebase initialises, `setupServiceLocator()` runs,
and `getIt<AuthRepository>()` / `getIt<AuthHistoryStore>()` resolve through the
real container on a device.

### Runs

Both runs used the debug APK already installed on the emulator, launched cold
via the launcher activity after `am force-stop`, holding the device lease so no
parallel story shared the device.

| # | Device | Seeded state | `am start -W` | Landing screen observed | Crash / error screen |
|---|--------|--------------|---------------|-------------------------|----------------------|
| 1 | emulator-5560 | Firebase signed out **+** `flutter.auth.has_previous_session_v1 = true`, `flutter.auth.last_email_v1 = seed.user@cupid.test` | `Status: ok`, `LaunchState: COLD`, `TotalTime: 6432`, `WaitTime: 6447` | Session-expired **login** (AC2), heading "Đăng nhập lại để tiếp tục", email prefilled `seed.user@cupid.test` | None |
| 2 | emulator-5560 | Firebase signed out, marker restored to absent | `Status: ok`, `LaunchState: COLD`, `TotalTime: 5999`, `WaitTime: 6011` | **welcome** (AC3) | None |

Runs 1 and 2 are the same binary on the same device, differing only in the ADR-3
history marker. They resolve to different screens accordingly, which exercises
both signed-out rows of `SessionGateCubit._resolveSignedOut`
(`session_gate_cubit.dart:87-95`) end to end on a real device — the branch that
only device-local state can distinguish, and the one this story added.

Run 1 additionally confirms the `prefillEmail` value travels from
`AuthHistoryStore.lastEmail()` through `SessionGateSessionExpired` into the
rendered field, so the AC2 path is verified by observation, not inference.

### Error scan

`adb logcat -d AndroidRuntime:E flutter:V "*:S"` after each run returned only:

```
I flutter : Using the Impeller rendering backend (OpenGLES).
I flutter : The Dart VM service is listening on http://127.0.0.1:.../
```

No `AndroidRuntime` exception, no Dart unhandled exception, no Flutter red error
screen, no `GetIt` "not registered" failure. The DI registrations added in P0 and
P2 therefore resolve on the real launch path, which was the specific risk B3
raised.

### Registry conformance note

`runtime-command-registry.json` records `mobile-app.readiness.type: widget-test`
against `Key('home_screen_ready_signal')`, and its launch entry
`scripts/run-mobile.sh` is marked `interactive: true, ciSafe: false`. That
readiness signal could not be used as this story's startup gate for two reasons:

1. The key lives on the home screen, which is only reachable with a valid
   authenticated session — the one state that cannot be manufactured here (see
   the visual-fidelity report).
2. A widget-test readiness signal is exactly the kind of evidence B3 rejected;
   it never runs `main()`.

The device cold start above is strictly stronger than the registry's declared
readiness check. The registry's non-conformance (`readiness.type` not a runtime
probe, no `dependsOn`) is pre-existing and outside this story's write scope; it
is carried as deferred finding D4 for DevOps.

### Observation for the reviewer — offline session resolution is slow

On these emulators, which have no working internet connection, the gate takes
noticeably longer than the 2 s minimum dwell to resolve: a capture at 12 s after
launch still showed splash, while captures at 45 s showed the resolved
destination. The delay is in the first non-`CupidSessionUnknown` emission from
`CupidSession.state` (Firebase Auth's initial auth-state resolution offline), not
in this story's code — `_resolveSignedOut` performs only local
`SharedPreferences` reads and issues no HTTP request.

This does not violate AC4, which forbids navigating *early*; the observed
behaviour is the opposite direction, and the dwell guard held correctly
throughout. Flagged rather than fixed: bounding the wait for the first session
emission would change the approved ADR-011h resolution semantics and belongs to
a follow-up decision, not to this story's rework.

## Phase P3 – Visual fidelity evidence

Round-1 review finding B1. Full detail in
`../visual-fidelity/visual-fidelity-report.md`.

| Screen / route | AC | Device | Capture |
|---|---|---|---|
| splash (during dwell) | AC4 | emulator-5554, emulator-5560 | `../visual-fidelity/implemented-splash-emulator-5554.png`, `…-5560.png` |
| launch → welcome | AC3 | emulator-5554, emulator-5560 | `../visual-fidelity/implemented-launch-welcome-emulator-5554.png`, `…-5560.png` |
| launch → login (session-expired) | AC2 | emulator-5560 | `../visual-fidelity/implemented-launch-login-emulator-5560.png` |
| launch → home | AC1 | — | NOT CAPTURED — P3 stop rule, no manufacturable valid Firebase session |

Design references rendered from the locked `claude-design` canvas
(`Cupid App.dc.html`, `--platform=android --theme=dark --lang=vi`) for screen ids
`splash`, `welcome`, `login`; recorded as `Design-Screen: splash, welcome, login`
in `story_master.md`.

- `VISUAL_FIDELITY: FAIL` — `../visual-fidelity/visual-fidelity-report.md`
- 17 deltas recorded (D1-D17). **None is attributable to this story's change
  surface.** D1 (the removed "Chạm để tiếp tục" pill) is the intentional ADR-6
  change and is written up explicitly so STORY-003 does not reinstate it and
  reintroduce the AC4 bypass. The remaining 16 are pre-existing screen drift
  owned by STORY-003 (splash), STORY-004 (welcome) and STORY-005 (login) — the
  sibling stories REQ-002 created for exactly that work.
- Golden test: not added. Baselining now would freeze the known-drifted
  appearance of these three screens and fight STORY-003/004/005 when they correct
  them. The golden belongs to the story that makes the screen match its design.
- Blocker: none raised. The uncaptured `home` state is an environment credential
  gap, not a design gap, and STORY-017 owns that screen's comparison.

Devices were left as found: no display size override was kept, and the
`emulator-5560` `shared_prefs` file was restored to its pre-seed content.

## Round-2 rework summary

| Finding | Status |
|---|---|
| B1 — per-story visual-fidelity evidence missing | CLOSED — 5 captures + 5 design references + `visual-fidelity-report.md` with per-screen verdicts, `Design-Screen` ids, and the ADR-6 note for STORY-003 |
| B2 — no `Entry Point Reachability` section | CLOSED — section added above, `Reachable: YES` |
| B3 — no `Story Runtime Startup Smoke` section | CLOSED — section added above, two real device cold starts, no waiver needed |
| N1 — `markAuthenticated` not called on the signed-in resolution path | CLOSED — `session_gate_cubit.dart:101` calls `await _authHistoryStore?.markAuthenticated(email: email)` at the top of `_resolveSignedIn`, making the ADR-3 marker self-healing for devices authenticated before this build |

No production code changed during round-2 rework beyond the N1 line, which was
already present in the sealed baseline. The work was evidence capture.
