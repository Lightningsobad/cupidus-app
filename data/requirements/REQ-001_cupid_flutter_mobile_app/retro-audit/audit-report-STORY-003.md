# Retro Audit Report — STORY-003 Auth (Firebase sign-in + refresh-token interceptor)

Reviewer: Iris-QC
Run Key: 2026-08-12:REQ-001:STORY-003:retro-audit
Story: STORY-003_auth (Requirement REQ-001, Status DONE, Implementation Lane: mobile, Story-Class: standard)

## Method

Independently re-read current code on `main` (no reliance on the prior
`review/review-report.md` verdict beyond pointing at file locations) and
re-ran the story's test suites in isolation:

- `mobile/lib/core/auth/cupid_session.dart`, `cupid_auth_interceptor.dart`, `cupid_auth.dart`
- `mobile/lib/features/auth/data/auth_repository.dart`
- `mobile/lib/features/auth/presentation/session_gate_cubit.dart`, `screens/splash_screen.dart`, `sign_out_action.dart`, `sign_out_confirm_dialog.dart`
- `mobile/test/core/auth/cupid_auth_interceptor_test.dart` (7/7 pass, isolated run)
- `mobile/test/features/auth/presentation/splash_screen_test.dart` (4/4 pass, isolated run — covers all 3 `SessionGateState` outcome branches plus the checking state)
- `mobile/test/features/auth/presentation/sign_out_action_test.dart` (9 tests pass, isolated run — confirm+teardown+navigate and cancel+focus-return paths)
- `mobile/test/features/auth/presentation/sign_out_cubit_test.dart` (2/2 pass, isolated run)
- `mobile/test/features/auth/data/auth_repository_test.dart` (2/2 pass, isolated run)

Note on tooling: a single run that invoked `flutter test` on
`auth_repository_test.dart` concurrently with another `flutter test`
invocation against the same project produced a spurious `openapi/cupid_api`
`.g.dart`-missing compile error. Read-tool inspection confirmed the named
`.g.dart` files exist on disk with correct generated content and are
git-tracked (`git ls-files` + `git status` clean), and a subsequent isolated
rerun of the same test file passed cleanly. Treated as a concurrent-process
build-cache race in this audit environment, not a story defect — not scored
against any AC.

## AC-by-AC Traceability

| AC | Status | Evidence |
| --- | --- | --- |
| AC1 — sign in reaches authenticated area | PASS | `AuthRepository` (`mobile/lib/features/auth/data/auth_repository.dart:39-73`) drives Firebase sign-in via `FirebaseSignInGateway`, then `_syncBackendProfile()` calls `POST /auth/login` falling back to `POST /auth/register` on 404, matching `architecture/solution.md` §2. `SplashScreen`/`SessionGateCubit` route a signed-in session to `HomeScreen` (`splash_screen.dart:106-108`, `session_gate_cubit.dart:86`). Verified by direct code read; `splash_screen_test.dart` "CupidSessionSignedIn with a resolving token routes to HomeScreen" independently exercises this path against a real `StreamController`. |
| AC2 — expired token refreshed transparently | PASS | `CupidAuthInterceptor.onError` (`cupid_auth_interceptor.dart:52-77`) force-refreshes exactly once via a single-flight `Future` (`_refreshFuture`, lines 79-83), retries the original request exactly once with the new token, and forwards the original error unchanged (no throw) on failure while invoking `onSessionExpired`. Independently re-run `cupid_auth_interceptor_test.dart`, 7/7 pass in isolation, including the refresh-storm gate ("5 concurrent 401s trigger exactly one refreshAccessToken call") and the no-second-retry / failed-refresh-forwards-original-error cases — these exercise real interceptor logic against a fake token provider and a fake `HttpClientAdapter`, not stubs of the behavior under test. |
| AC3 — session persists across cold start | PASS | `CupidSession.state` (`cupid_session.dart:55-58`) yields `CupidSessionUnknown` then follows Firebase's own restored `authStateChanges()` — no hand-rolled cache. `SessionGateCubit`/`SplashScreen` implement the 3-way branch from `ux/uiux-spec.md` §3 exactly: valid/refreshable session → Home, no session → Welcome, session-present-but-refresh-fails → `login` session-expired variant with `prefillEmail` (`session_gate_cubit.dart:64-92`), plus the 2s min-dwell timer and tap-to-continue fallback (`splash_screen.dart:72-133`). Independently re-run `splash_screen_test.dart`, 4/4 pass in isolation, covering the checking state and all 3 outcome branches against a real `StreamController<CupidSessionState>`. |
| AC4 — sign-out clears session + cached data | PASS | `CupidSession.signOut()` (`cupid_session.dart:82-87`) does real `_auth.signOut()` then ordered `SessionScopedStore.clearOnSignOut()` teardown for every registered store. `AuthRepository.signOut()` delegates to this via an injected callback (documented DI seam). `SignOutAction`/`showSignOutConfirmDialog` match `ux/uiux-spec.md` §5 verbatim: title "Đăng xuất?"/"Log out?", body names local photo/private-data clearing, destructive `--red`-styled confirm (not hold-gesture), cancel as text button, navigate to `welcome` (not `login`) on success (`sign_out_action.dart:57-63`, `sign_out_confirm_dialog.dart:17-43`). Independently re-run `sign_out_action_test.dart` (confirm→teardown→navigate and cancel→no-teardown→focus-return paths) and `sign_out_cubit_test.dart`, all pass in isolation against a real `AuthRepository` with an injected counting teardown callback. |

## Design Fidelity

`design-fidelity-config.json` names a locked `design_source`
(`cupid-app-design-system/project`) and `ui_surface: true`; this story is
mobile-lane and UI-bearing (splash/welcome/login/register/otp/forgot
screens), so Design Fidelity is in scope.

The only rendered-evidence artifact in this requirement is
`integration-review/mobile-visual-audit.md` (Result: FAIL, 10/37 screens
captured: `alarm`, `home`, `antighost`, `gallery`, `invite`, `joincode`,
`paired`, `pet`, `privacy`, `vibe`). None of this story's screens
(`splash`, `welcome`, `login`, `register`, `otp`, `forgot`) are among the
10 captured pairs, and no `STORY-003_auth/visual-fidelity/` directory
exists. Per the handoff's explicit instruction, this is not upgraded to
`PASS`/`MATCH` on code inspection alone — a missing render is not a match.

| Screen | Design Reference | Implemented Capture | Result | Deviation |
| --- | --- | --- | --- | --- |
| `splash` | not rendered | not captured | UNVERIFIED | no rendered evidence exists for this screen in this requirement |
| `welcome` | not rendered | not captured | UNVERIFIED | no rendered evidence exists |
| `login` | not rendered | not captured | UNVERIFIED | no rendered evidence exists |
| `register` | not rendered | not captured | UNVERIFIED | no rendered evidence exists |
| `otp` | not rendered | not captured | UNVERIFIED | no rendered evidence exists |
| `forgot` | not rendered | not captured | UNVERIFIED | no rendered evidence exists |

Per `retro-audit.md`, an `UNVERIFIED` design row blocks `GREEN`/`AMBER`
exactly as a failed AC would; classification impact is `RED-PATCH` (the
deviation is an evidence gap, not an invalidated architecture/product
direction).

## Open Question Relevance

| OQ | Relevant? | Blocked Scope | Approval/Triage Source | Classification Impact |
| --- | --- | --- | --- | --- |
| OQ4 — offline storage (Drift vs `hydrated_bloc`) | No | N/A — auth/session state uses neither Drift nor a hand-rolled cache; `CupidSession.state` follows Firebase's own persistence directly | Resolved (ADR-007) | none |
| OQ5 — light theme & EN locale in v1 | No, not for this story's ACs | Applies at the design-token/i18n-infrastructure layer (STORY-001), not to this story's auth flow logic or AC wording | Working assumption per `conflicts_open_questions.md`, PO-owned at `design_system` breakdown | none |
| R8 — Socket.IO auth gap (`chat.gateway.ts` no auth check) | Relevant, forward-compat only | Backend fix itself is out of this story's scope (A1 frozen); this story owns exposing the Firebase token for `handshake.auth.token` | `CupidSession.idToken()`/`idTokenStream` (`cupid_session.dart:63-72`) deliver the forward-compat contract the story was asked for | none for this story — the still-open backend decision remains a pre-production blocker for epic-2, not a STORY-003 defect |
| D1/Critical-Alerts DND copy conflict | No | Epic-3 Notifications screen scope, unrelated to auth | N/A | none |

## OQ Discipline Findings

- No scope was removed, assumed, or deferred in this story's ACs because of an
  open question without triage. R8's forward-compat token-exposure ask (from
  the story's own "Open Items For Downstream Roles") is delivered in code
  (`idToken()`/`idTokenStream`); the separate backend-side auth-gap decision
  remains correctly tracked as a pre-production user decision in
  `conflicts_open_questions.md`, not silently absorbed into this story.
- No AC substitution or deviation from the story master's exact wording was
  found.

## Implementation Defects Or Unverified Behavior

- None found in the delivered auth/session logic. All 4 ACs verified PASS
  against current code and passing, independently re-run tests.
- The only gap is the Design Fidelity evidence gap above (no rendered
  capture exists for any of this story's 6 screens), which is a missing
  verification artifact, not an observed code defect.

Story-level Substantive Verdict: NEEDS_WORK
Classification Impact: RED-PATCH
REVIEW_COMPLETE: YES

## Substantive Findings - STORY-003

Run Key: 2026-08-12:REQ-001:STORY-003:retro-audit
Story: STORY-003

### AC-by-AC Traceability
| AC | Status | Evidence |
| --- | --- | --- |
| AC1 | PASS | See above — `auth_repository.dart` + `splash_screen.dart` routing, confirmed by code and `splash_screen_test.dart`. |
| AC2 | PASS | See above — `cupid_auth_interceptor.dart` single-flight refresh/retry, confirmed by code and 7/7 isolated `cupid_auth_interceptor_test.dart` passes. |
| AC3 | PASS | See above — `cupid_session.dart` + `session_gate_cubit.dart` + `splash_screen.dart`, confirmed by code and 4/4 isolated `splash_screen_test.dart` passes. |
| AC4 | PASS | See above — `cupid_session.dart:signOut()` + `sign_out_action.dart`/`sign_out_confirm_dialog.dart`, confirmed by code and isolated `sign_out_action_test.dart`/`sign_out_cubit_test.dart` passes. |

### Design Fidelity
| Screen | Design Reference | Implemented Capture | Result | Deviation |
| --- | --- | --- | --- | --- |
| splash | not rendered | not captured | UNVERIFIED | no rendered evidence exists |
| welcome | not rendered | not captured | UNVERIFIED | no rendered evidence exists |
| login | not rendered | not captured | UNVERIFIED | no rendered evidence exists |
| register | not rendered | not captured | UNVERIFIED | no rendered evidence exists |
| otp | not rendered | not captured | UNVERIFIED | no rendered evidence exists |
| forgot | not rendered | not captured | UNVERIFIED | no rendered evidence exists |

### Open Question Relevance
| OQ | Relevant? | Blocked Scope | Approval/Triage Source | Classification Impact |
| --- | --- | --- | --- | --- |
| OQ4 | No | N/A | Resolved (ADR-007) | none |
| OQ5 | No (not for this story's ACs) | design-token/i18n layer only | PO-owned, `conflicts_open_questions.md` | none |
| R8 | Relevant, forward-compat delivered | backend fix itself out of scope (A1) | `cupid_session.dart` idToken()/idTokenStream | none for this story |
| D1/Critical-Alerts copy | No | Notifications screen, unrelated | N/A | none |

### OQ Discipline Findings
- No untriaged OQ-driven scope cut found in this story.
- R8 forward-compat obligation from the story's own downstream note is delivered in code.

Story-level Substantive Verdict: NEEDS_WORK
Classification Impact: RED-PATCH
REVIEW_COMPLETE: YES
