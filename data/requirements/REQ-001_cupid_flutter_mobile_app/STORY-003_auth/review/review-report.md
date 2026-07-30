# Review Report: STORY-003 Auth (Firebase sign-in + refresh-token interceptor)

Mode: compact-review (parallel-story, RunId
RUN-REQ-001_cupid_flutter_mobile_app-STORY-003-review)
Reviewer: Iris-QC
BaseHead reviewed against: `79b35294da73e70f4ff91f1a9b960899c5b42f12`
Worktree HEAD at review time: `7dae1de724d8ccf04c1b817c4f66b89c4058d8b2`

## Verdict: CLEAN

## Verification performed

- `git diff 79b35294...` full 42-file / +4690/-9 story diff read and mapped
  to phases P1-P5 of `coding-plan` embedded in `architecture/solution.md`
  §8.
- `flutter pub get`, `flutter analyze lib test` (clean: 0 errors, 1 info-level
  `prefer_initializing_formals` lint on `splash_screen.dart:27`, non-blocking
  style note), `flutter test` (76/76 passing) all re-run independently in the
  worktree using the Flutter SDK at `$HOME/flutter` per the runtime registry
  `mobile-app.sdk.resolutionOrder`.
- Confirmed WriteScope compliance: every changed file outside
  `mobile/lib/**`, `mobile/test/**`, `mobile/pubspec.{yaml,lock}` is one of
  `mobile/android/app/build.gradle.kts`, `mobile/android/app/google-services.json`,
  `mobile/ios/Runner.xcodeproj/**`, `mobile/ios/Runner/GoogleService-Info.plist`,
  or `data/requirements/REQ-001_cupid_flutter_mobile_app/{STORY-003_auth,deployment}/**`
  — matches P1 DevOps scope and the two files noted in
  `architecture/solution.md` §4 Mobile/DevOps handoffs. No stray writes found.

## AC-by-AC findings

- **AC1 (sign-in reaches authenticated area):** `AuthRepository` +
  `FirebaseSignInGateway` seam + `SignInCubit`/`RegisterCubit` wire
  email/social sign-in through to `Home` via `SplashScreen`/`WelcomeScreen`/
  `LoginScreen`. Backend profile sync (`POST /auth/login` falling back to
  `/auth/register` on 404) matches `architecture/solution.md` §2. Met.
- **AC2 (transparent refresh):** `CupidAuthInterceptor`
  (`mobile/lib/core/auth/cupid_auth_interceptor.dart`) implements bearer
  attach + single-flight force-refresh + retry-exactly-once exactly per
  ADR-011c. Test suite
  (`mobile/test/core/auth/cupid_auth_interceptor_test.dart`) independently
  verifies every Risk Surface row in `solution.md` §4: 401→refresh→retry→
  success, no-second-retry, failed-refresh forwards original error with
  `onSessionExpired` invoked exactly once and zero replay attempts, and 5
  concurrent 401s trigger exactly 1 `refreshAccessToken()` call (the
  "refresh storm" gate) confirmed via a held-completer fake. Met, with real
  (non-mocked-away) logic under test.
- **AC3 (session persistence / splash gate):** `SessionGateCubit` +
  `SplashScreen` implement UX §3 precisely — `CupidSessionUnknown` holds on
  checking state, `SignedOut`→`welcome`, `SignedIn`→ non-forced
  `idToken()` bounded by a 3s timeout treated as optimistic success
  (ADR-011h), thrown refresh failure →`SessionGateSessionExpired` with
  `prefillEmail` carried through to `LoginScreen`. 2s min-dwell timer and
  tap-to-continue affordance match UX §3's dwell-budget language. Widget
  tests in `splash_screen_test.dart` drive this via a real
  `StreamController<CupidSessionState>`, not a stub — confirmed by reading
  the harness. Met.
- **AC4 (sign-out clears session + cached data):** `CupidSession.signOut()`
  does real `_auth.signOut()` then ordered `SessionScopedStore.clearOnSignOut()`
  teardown; `AuthRepository.signOut()` delegates to an injected teardown
  callback (documented seam, since `core/auth/**` construction needs live
  Firebase which is out of this phase's write scope — this is a deliberate,
  well-commented DI seam, not a stub of the behavior being tested).
  `SignOutCubit` state machine (`idle`→`in-progress`→`success`/`failed`) is
  real, and `SignOutAction`/`showSignOutConfirmDialog` match UX §5
  verbatim: title "Đăng xuất?"/"Log out?", body copy calling out
  photos/private-data clearing, destructive-red confirm button (not
  hold-gesture), navigate to `welcome` (not `login`) on success. Widget test
  `sign_out_action_test.dart` exercises the full confirm→teardown→navigate
  path and a cancel→no-teardown→focus-returns-to-trigger path (UX §7
  accessibility gate), both against a real `AuthRepository` instance with an
  injected counting teardown callback, not a faked assertion. Met.

## Other checks

- No stubbed/faked Firebase auth: `core/auth/**` imports real
  `package:firebase_auth`; only test doubles (`_FakeTokenProvider`,
  `_UnusedGateway` — the latter never exercised since it's unrelated to
  sign-out) stand in for Firebase in unit/widget tests, which is correct
  test hygiene, not production stubbing.
- Debug token-leak guard (ADR-011d): `cupid_interceptor_slots_test.dart`
  diff present and `LogInterceptor(requestHeader: false)` change confirmed
  in the diagnostics slot.
- Android `applicationId`/iOS bundle-id change to `com.snapsofts.cupid` is
  recorded in `deployment/configuration-guide.md`'s 2026-07-30 entry as a
  deliberate, explained user decision (Firebase registration mismatch), not
  an unexplained scope change — verified `build.gradle.kts` diff matches
  exactly what the guide describes (1-line applicationId change).

## Deferred / non-blocking items (not fixed in this review, correctly flagged by the team already)

1. `google_sign_in`'s Android `default_web_client_id` auto-resolution may
   not work because the Google Services Gradle plugin was deliberately not
   wired (outside DevOps WriteScope). No concrete `GoogleSignIn(...)` call
   site exists yet in this story's diff, so there is nothing to patch now —
   flagged forward (as already recorded in `configuration-guide.md`) for
   whichever future story builds the concrete social-sign-in gateway.
2. UX System Memory §12 "Auth Session UX Patterns" update (splash-as-
   auth-gate, session-expired-routes-to-login patterns) is recommended but
   out of this story's WriteScope (`STORY-003_auth/ux/**` only) — a Scrum
   Master follow-up, not a story defect.

Neither item blocks AC1-AC4 or introduces a defect in the reviewed diff.

## REVIEW_COMPLETE: YES

Outcome: CLEAN
