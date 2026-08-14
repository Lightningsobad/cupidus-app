# STORY-001_app_launch_entry_routing-solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-13
- Requirement: REQ-002 (Screen flow correction & design fidelity audit)
- Lane: Mobile (single lane)

## 1. Decision Summary

- Mode: Brownfield correction.
- Architecture Drivers: the splash auth-check gate already exists in source but
  is not reachable in production; and the session model cannot currently tell
  AC2 (expired prior session) apart from AC3 (no session at all).
- Architectural invariants / non-goals: no backend endpoint, DTO, or OpenAPI
  change. No new HTTP request on the launch path (REQ-001 ADR-011h is
  preserved). No visual redesign of splash / welcome / login / home — those are
  STORY-003/004/005/017. No mid-session forced re-auth navigation — STORY-002.
- Proposed technical direction: mount the existing `SplashScreen` as the app's
  initial route, point its authenticated outcome at the authenticated app root
  (`PairGateShell`) rather than a bare `HomeScreen`, add a device-local
  "previously authenticated" marker so the signed-out case can split into
  `login` vs `welcome`, and delete the tap-to-continue affordance that
  navigates before session resolution.
- Why this fits: four of the five ACs are already implemented as unreachable
  code. The dominant work is wiring and one missing state distinction, not a
  new subsystem.

### Key Discovery

The splash gate is dead code in production. `mobile/lib/app/cupid_app.dart:44`
sets `home: PairGateShell(...)`. `SplashScreen` is referenced only by
`mobile/lib/main_preview.dart:390` (the preview catalog) and its own widget
test. Cold launch therefore skips the session check entirely and lands on the
pairing gate, which immediately issues the authenticated `getPartnerLink`
call with no session. This single line is the confirmed user-reported defect
and it violates AC1, AC2, AC3, and AC4 simultaneously.

## 2. Audit Findings (current entry-routing implementation vs AC1-AC5)

| # | Finding | Source | ACs violated |
|---|---------|--------|--------------|
| D1 | Splash gate never mounted; `PairGateShell` is the initial route | `mobile/lib/app/cupid_app.dart:44` | AC1, AC2, AC3, AC4 |
| D2 | Splash's authenticated destination is bare `HomeScreen`, bypassing the pair gate and the tab shell | `mobile/lib/features/auth/presentation/screens/splash_screen.dart:106` vs `mobile/lib/core/navigation/app_shell.dart:141` | AC1 |
| D3 | Signed-out always resolves to `welcome`; an expired prior session cannot reach `login` | `mobile/lib/features/auth/presentation/session_gate_cubit.dart:68-69` | AC2 |
| D4 | Tap-to-continue navigates to `HomeScreen` while the gate is still `Checking` | `mobile/lib/features/auth/presentation/screens/splash_screen.dart:123-133` | AC4 |
| D5 | No production construction site for `AuthRepository`; `FirebaseSignInGateway` has no concrete implementation | `mobile/lib/features/auth/data/firebase_sign_in_gateway.dart:19`; only throwing stubs in `main_preview.dart:408` and tests | blocks AC2, AC3 delivery |

What is already correct and must be preserved, not rebuilt:

- The 2s minimum dwell and the `dwell_complete AND session_resolved` gate
  (`splash_screen.dart:72-99`) already implement AC4's core rule.
- The `CupidSessionSignedIn` branch already produces the AC2 outcome when
  Firebase still holds a user but the refresh token is rejected
  (`session_gate_cubit.dart:75-92`).
- `pushReplacement` already prevents a back-navigation to splash
  (`splash_screen.dart:115-117`).
- No `WidgetsBindingObserver` anywhere drives navigation. The five existing
  lifecycle listeners (`partner_link_poller.dart`, `realtime_coordinator.dart`,
  `reminder_overlay_host.dart`, `ghost_state_row.dart`, `anti_ghost_screen.dart`)
  are all non-navigational.

## 3. Decisions

### ADR-1: `SplashScreen` becomes the app's initial route

`CupidApp.home` becomes `SplashScreen`. `PairGateShell` stops being the initial
route and becomes splash's authenticated destination. `CupidApp`'s existing
`createPairGateCubit` test seam is threaded through to that destination so
full-app widget tests keep their injection point.

Rejected: adding a separate router/`initialRoute` table. There is no
`MaterialApp` routes table anywhere in this codebase (`expenses_route.dart:16`
records that invariant); introducing one is a navigation refactor, not a
routing-correctness fix.

### ADR-2: AC1's "home" is the authenticated app root, not `HomeScreen`

Splash's `SessionGateAuthenticated` outcome replaces itself with
`PairGateShell`, which then applies its own pairing gate (unpaired → pairing
stack, paired → `AppShell` → Home tab). `HomeScreen` is a tab body, not a
screen the launch sequence should mount directly.

Story boundary: STORY-001 owns splash → authenticated root. Everything
`PairGateShell` decides internally stays STORY-002's. This story must not
change `pair_gate_shell.dart`.

### ADR-3: A device-local `AuthHistoryStore` splits AC2 from AC3

Root cause of D3: `CupidSession` maps `User? == null` to
`CupidSessionSignedOut` for three different real-world situations — never
signed in, deliberate sign-out, and refresh token revoked/expired (Firebase
clears the local user on several invalid-refresh-token paths). Firebase state
alone cannot satisfy AC2 and AC3 at the same time.

Add `AuthHistoryStore`, backed by `shared_preferences` (the established local
persistence primitive in this codebase, always behind an injectable
`Future<SharedPreferences> Function()` seam — see `couple_pairing_store.dart`,
`notification_preferences_store.dart`, `ghost_consent_store.dart`):

- `hasPreviousSession` (bool) and `lastEmail` (String?).
- Marked after any successful authentication.
- Cleared on deliberate sign-out.

Clearing reuses the existing teardown hook rather than adding a second
sign-out path: `AuthHistoryStore implements SessionScopedStore` and registers
via `CupidSession.registerScopedStore`, exactly like `CouplePairingStore`
(`service_locator.dart:147-154`). `CupidSession.signOut()` already iterates
those stores. So a deliberate sign-out clears the marker (AC3), while a
revoked token — which never calls `signOut()` — leaves it set (AC2).

Rejected: reading Firebase's own persisted user record, or keeping a parallel
token cache. `cupid_session.dart:41` states firebase_auth is the only source of
session truth and holds no parallel cache; this marker is a one-bit local
history flag, not a second session store, and it is deliberately not a token.

### ADR-4: Session resolution table for the splash hold

Resolved entirely from `CupidSession`, with no network call, preserving
ADR-011h:

| `CupidSessionState` | Resolution | Gate state | Target |
|---|---|---|---|
| `CupidSessionUnknown` | not resolved | `Checking` (hold) | — |
| `CupidSessionSignedIn` + non-forced `idToken()` succeeds or times out | valid | `Authenticated` | `PairGateShell` |
| `CupidSessionSignedIn` + `idToken()` throws | expired | `SessionExpired(prefillEmail: email)` | `LoginScreen` |
| `CupidSessionSignedOut` + `hasPreviousSession == true` | expired | `SessionExpired(prefillEmail: lastEmail)` | `LoginScreen` |
| `CupidSessionSignedOut` + `hasPreviousSession == false` | none | `Unauthenticated` | `WelcomeScreen` |

Only the last two rows are new. The `idToken()` timeout-as-optimistic-success
rule stays as is: it is what keeps a slow network from extending the splash
hold, and treating a timeout as "expired" would wrongly bounce a valid user to
login on a bad connection.

### ADR-5: AC5's resume guard is structural — no lifecycle machinery

Because splash is `MaterialApp.home` and the decision runs in
`_SplashViewState.initState`, it runs exactly once per Flutter engine launch.
A foreground resume of a live process does not re-run `initState`; a resume
from a terminated state is a fresh process and therefore a fresh `initState`.
That is precisely AC5's cold-launch-vs-resume distinction, obtained for free.

AC5 is therefore an invariant to protect, not a feature to build:

1. No `WidgetsBindingObserver` / `AppLifecycleState` subscription may drive
   entry routing. Holds today; must be regression-tested.
2. Splash must leave the stack via `pushReplacement`, which disposes its
   `BlocProvider<SessionGateCubit>` and cancels the session subscription, so no
   later session emission can re-route. Holds today; must be regression-tested.

Consequence to state explicitly: once splash is replaced, a mid-session token
revocation will not re-route to login. That is correct for STORY-001 — forced
mid-session re-auth is STORY-002's scope.

### ADR-6: Remove the tap-to-continue affordance

`_onTapToContinue` navigates to `HomeScreen` while the gate is still
`Checking`, which is exactly what AC4 forbids, and it lands on the wrong
destination per ADR-2. Delete the `GestureDetector`, `_onTapToContinue`, and
the "Chạm để tiếp tục" / "Tap to continue" text.

Its cost is an AC4 violation; its benefit is near zero under the corrected
design, because after the 2s dwell the only remaining wait is a token read
already bounded at 3s and treated as success on timeout.

Cross-story coordination: this removes a visible splash element, and splash
visual fidelity is STORY-003. The UX spec's "Checking-State UI" section already
requires coordinating splash changes with STORY-003. STORY-003 must be told
that the tap-to-continue line is gone by design and must not be reinstated.

### ADR-7: `AuthRepository` becomes reachable in production

Blocking finding D5: `FirebaseSignInGateway` is an `abstract interface class`
with no concrete implementation in `lib/`, and `AuthRepository` is never
constructed outside the preview harness and tests. AC2 and AC3 both terminate
on screens whose constructors require an `AuthRepository`
(`LoginScreen`, `WelcomeScreen`), so neither can be delivered until one exists.

Resolution, scoped to the minimum:

- Add a concrete `firebase_auth`-backed `FirebaseSignInGateway`. Every plugin
  it needs is already declared in `mobile/pubspec.yaml` (`firebase_auth`,
  `google_sign_in`, `sign_in_with_apple`, `flutter_facebook_auth`) and Firebase
  is already initialized in `main.dart`, so this adds no dependency and no
  configuration change.
- Register `AuthRepository` in `service_locator.dart`, and give `SplashScreen`
  a `getIt<AuthRepository>()` default so it follows the same
  optional-injection seam it already uses for `createSessionGateCubit` and
  `resolvePairingStatus`.

Explicitly NOT in this story: any new auth UI, any new provider, and native
provider configuration (Google OAuth client ids, Apple Sign In capability,
Facebook app id). Those affect what happens when a user taps a button on the
login screen, not which screen the launch sequence lands on. The implementer
must report — not fix — any missing native configuration found.

> SCOPE DISCOVERY, requires Scrum Master / Product Owner acknowledgement.
> ADR-7 is capability wiring the story text did not anticipate. It is
> unavoidable for AC2/AC3 and is deliberately held to the smallest reachable
> surface. It is called out rather than absorbed silently.

## 4. Risk Surfaces And Source Of Truth

| Risk Surface | Why it is a risk | Source of truth |
|---|---|---|
| R1 Initial-route swap | Changing `CupidApp.home` moves the entire app behind a session gate; a mistake here bricks launch for every user | ADR-1, ADR-2 |
| R2 AC2/AC3 split correctness | Marker set/clear timing decides whether an expired user gets `login` or is dumped on `welcome` | ADR-3, ADR-4 |
| R3 AC4 no premature navigation | Both the dwell/resolution gate and the removed tap affordance | ADR-4, ADR-6 |
| R4 AC5 resume invariant | Silently regressed by any future lifecycle observer or by a lingering gate subscription | ADR-5 |
| R5 `AuthRepository` reachability | AC2/AC3 destinations cannot be constructed without it | ADR-7 |
| R6 Splash visual overlap with STORY-003 | Two stories editing `splash_screen.dart` | ADR-6, `../ux/uiux-spec.md` Checking-State UI |

## 5. Architecture Delta

### Boundaries And Ownership

- STORY-001 owns: `cupid_app.dart` (the `home:` line), `splash_screen.dart`
  (routing logic only), `session_gate_cubit.dart`, the new `AuthHistoryStore`,
  the new concrete sign-in gateway, and their `service_locator.dart`
  registrations.
- STORY-001 must not touch: `pair_gate_shell.dart`, `app_shell.dart`,
  `home_screen.dart`, `sign_out_action.dart`, or any screen's visual layout.
- `cupid_session.dart` gains no new responsibility. The marker is a separate
  store registered through the existing `SessionScopedStore` hook.

### Affected Modules

- `mobile/lib/app/cupid_app.dart` — initial route.
- `mobile/lib/features/auth/presentation/screens/splash_screen.dart` — destination
  table, tap affordance removal, `AuthRepository` default.
- `mobile/lib/features/auth/presentation/session_gate_cubit.dart` — signed-out branch.
- `mobile/lib/features/auth/data/auth_repository.dart` — mark on successful auth.
- `mobile/lib/core/auth/auth_history_store.dart` — new.
- `mobile/lib/core/auth/cupid_auth.dart` — barrel export.
- `mobile/lib/features/auth/data/firebase_auth_sign_in_gateway.dart` — new.
- `mobile/lib/core/di/service_locator.dart` — registrations.

### Contracts And Integrations

- Backend: unchanged. No endpoint, DTO, or OpenAPI regeneration.
- Network behavior on the launch path: unchanged. The gate still issues zero
  HTTP requests (ADR-011h).
- New internal contract: `AuthHistoryStore` — written by `AuthRepository` on
  successful auth, cleared by `CupidSession.signOut()` teardown, read by
  `SessionGateCubit`.

### Lane Handoff

Single mobile lane, strictly sequential. No backend, frontend, or devops work.

## 6. Non-Functional Impact

- Launch latency: unchanged. Dwell stays 2s; the marker read is a local
  `SharedPreferences` lookup that runs concurrently with the dwell.
- Security/privacy: the marker stores a boolean and a last-known email for
  login prefill. It is not a credential and not a token. It is cleared on
  deliberate sign-out along with every other session-scoped store.
- Configuration guide impact: NOT_APPLICABLE. No env var, secret, or
  third-party integration change; every plugin is already declared.

## 7. Open Items Resolved

Both `story_master.md` Open Items for Tech Lead are answered:

- Session-resolution mechanism during the splash hold: ADR-3 + ADR-4 — local
  token read plus a device-local previously-authenticated marker, no network
  call.
- Cold launch vs resume distinction: ADR-5 — obtained structurally from
  `MaterialApp.home` + `initState`, with two invariants to regression-test
  rather than new lifecycle machinery.
