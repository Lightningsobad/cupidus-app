# Review Report: STORY-001 App Launch / Session-Based Entry Routing Correction

Outcome: PATCH_REQUIRED

Review type: compact-story-review (round 1)
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-001 — Complexity `standard`, Scope A (flow/navigation correction)
Lane: `story_master.md` records `shared`; handoff records `mobile`. All delivered
code is under `mobile/`, so the mobile-lane gates were applied.
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-001`
BaseHead: `8396273e6a5e6a2798557aa68864f0ef24cd939b`
Date: 2026-08-13

## Scope Gate

Source/test files in scope (from `git diff --name-only <BaseHead>`), 16 total:

| Production | Test |
|---|---|
| `mobile/lib/app/cupid_app.dart` | `mobile/test/app/cupid_app_entry_routing_test.dart` |
| `mobile/lib/core/auth/auth_history_store.dart` | `mobile/test/app/feature_flags_test.dart` |
| `mobile/lib/core/auth/cupid_auth.dart` | `mobile/test/core/auth/auth_history_store_test.dart` |
| `mobile/lib/core/di/service_locator.dart` | `mobile/test/features/auth/data/auth_repository_test.dart` |
| `mobile/lib/features/auth/data/auth_repository.dart` | `mobile/test/features/auth/data/firebase_auth_sign_in_gateway_test.dart` |
| `mobile/lib/features/auth/data/firebase_auth_sign_in_gateway.dart` | `mobile/test/features/auth/presentation/session_gate_cubit_test.dart` |
| `mobile/lib/features/auth/presentation/screens/splash_screen.dart` | `mobile/test/features/auth/presentation/splash_screen_test.dart` |
| `mobile/lib/features/auth/presentation/session_gate_cubit.dart` | `mobile/test/widget_test.dart` |

Evidence files in scope: `coding-plan/test-results.md` (27.8 KB, read by range),
`coding-plan/phase-P3-visual-fidelity-evidence.md`, `architecture/solution.md`
(ADR-1..ADR-7 range), `ux/uiux-spec.md`, `data/devops/system/design-fidelity-config.json`.

Query keys: AC1-AC5, ADR-1/ADR-2/ADR-3/ADR-5/ADR-6, `hasPreviousSession`,
`markAuthenticated`, `_tryNavigate`, `MaterialApp.home`, `pushReplacement`,
`ui_surface`, `design_source`.

Budget note: the compact mode budget is 8 touched source/test files; this story
touches 16. The handoff was precisely bounded (exact BaseHead, exact evidence,
exact focus), so the review was completed rather than returned as
`REVIEW_SCOPE_TOO_BROAD`. Recorded so the overage is visible, not silent.

## Outcome And Rationale

The routing implementation itself is correct, well-tested, and faithful to the
approved architecture. All five acceptance criteria are satisfied in code and
covered by tests that I re-ran and confirmed green.

The story is returned for rework on **evidence gates, not on routing logic**.
Three mandatory story-level gates for a UI-bearing mobile story are absent, and
the story's own coding plan already scoped one of them (`phase-P3` is still
`Status: NOT_STARTED`). This story changes `MaterialApp.home` — the literal boot
route of the app — and no run in the evidence has ever launched the app.

## Acceptance Criteria Traceability

| AC | Verdict | Evidence |
|----|---------|----------|
| AC1 — valid/refreshable session → home | PASS | `splash_screen.dart:116-118` routes `SessionGateAuthenticated` to `PairGateShell`. Literal AC text says "home"; ADR-2 (approved architecture) defines AC1's "home" as the authenticated app root, since `HomeScreen` is a tab body `PairGateShell` reaches internally. Governing approved deviation, not a substitution. Covered by `splash_screen_test.dart` (asserts `PairGateShell` present, `HomeScreen` absent) and `cupid_app_entry_routing_test.dart:79`. |
| AC2 — expired/invalid session → login | PASS (with gap N1) | Two paths, both implemented: `session_gate_cubit.dart:111-113` (signed-in + `idToken()` throws) and `:87-95` (signed-out + `hasPreviousSession`). Production wiring confirmed at `splash_screen.dart:50` and pinned by a source-scan guard test. See N1 for the upgrade-path gap. |
| AC3 — no session → welcome | PASS | `session_gate_cubit.dart:89-91`; `AuthHistoryStore.clearOnSignOut` (`auth_history_store.dart:47-52`) returns a signed-out device to this branch via the existing `SessionScopedStore` teardown, so no second sign-out path was added. |
| AC4 — no navigation before dwell AND resolution | PASS | `splash_screen.dart:106-109` gates on `_navigated || !_minDwellElapsed || state is SessionGateChecking`; both the dwell timer and the `BlocListener` funnel through the same guard. Three tests, including a 1900 ms hold on a t=0-resolved session. ADR-6 removal of the tap-to-continue affordance closes the one path that could bypass the gate. |
| AC5 — resume does not re-run entry routing | PASS | Structural per ADR-5: splash is `MaterialApp.home` and the decision runs in `initState`; `pushReplacement` (`splash_screen.dart:128-130`) disposes the `BlocProvider<SessionGateCubit>`. Both invariants are regression-tested, including a full `inactive→hidden→paused→hidden→inactive→resumed` cycle and a source-scan guard asserting no `WidgetsBindingObserver`/`AppLifecycleState` in either entry-routing source. |

## Touched Risk Surfaces And Critical Gates

| Risk surface | Gate | Status |
|---|---|---|
| App lifecycle / entry routing | Targeted widget + regression tests | PASS — re-ran `flutter test test/app test/widget_test.dart test/features/auth/presentation` → `+37: All tests passed!` |
| Mobile navigation / discoverability | Entry Point Reachability evidence (rule 12e1) | **FAIL — B2** |
| Mobile interaction (visible splash change) | Per-story rendered visual fidelity (rules 12e2/12e3/12g2) | **FAIL — B1** |
| Runtime / app boot | Story Runtime Startup Smoke (rule 12g) | **FAIL — B3** |
| Local storage / offline | `auth_history_store_test.dart` 6 tests, real `SharedPreferences` | PASS |
| Security / auth | `firebase_auth_sign_in_gateway_test.dart` 12 error-mapping tests; gate issues zero HTTP requests | PASS |
| Static analysis | `flutter analyze` on touched paths → 5 `info`, 0 errors, 0 warnings | PASS |

Configuration guide: not required. Every phase records
`Requirement Configuration Guide: Update Required: NO`, no dependency or env var
was added, and the native social-provider gaps are reported-not-fixed per ADR-7.

## Blocking Findings

**B1 — Per-story visual-fidelity evidence is missing entirely.** [owner: mobile-dev]
`data/devops/system/design-fidelity-config.json` records `ui_surface: true` with a
locked `design_source` (claude-design canvas), and `story_master.md` records
`UI-facing story: YES`. The story's own `coding-plan/phase-P3-visual-fidelity-evidence.md`
is still `Status: NOT_STARTED`, and no `visual-fidelity/` directory exists under
the story. There is no `visual-fidelity-report.md` and no `VISUAL_FIDELITY:`
verdict anywhere.

This is not a formality here. The implementation removed a visible splash element
(the "Chạm để tiếp tục" / "Tap to continue" line, ADR-6) while `ux/uiux-spec.md`
states splash "visuals untouched". ADR-6 authorizes the removal, but P3 task 5 was
the mechanism for recording it so STORY-003 (splash design fidelity) does not read
the absence as a defect and reinstate it. With P3 skipped, that cross-story note
does not exist.

Action: execute phase P3 as written — four captures
(`implemented-launch-home`, `implemented-launch-login`, `implemented-launch-welcome`,
`implemented-splash`) plus `visual-fidelity/visual-fidelity-report.md` with the
resolved `Design-Screen: <id>`, and the explicit ADR-6 note for STORY-003. If a
session state cannot be manufactured on the available device, use P3's stop rule
and report which one and why — do not record `PASS` for an unobserved outcome.

**B2 — No `## Entry Point Reachability` section in `coding-plan/test-results.md`.** [owner: mobile-dev]
Rule 12e1 is mandatory and non-waivable for a UI-facing story. I independently
verified the entry point in code and it is correct: `cupid_app.dart:54-57` sets
`home: SplashScreen(...)`, replacing `PairGateShell`, and
`cupid_app_entry_routing_test.dart:79` pins it. This is therefore an evidence gap,
not an implementation defect.

Action: add the section with `Reachable: YES` and the concrete path
(app cold launch → `MaterialApp.home` → `SplashScreen` → resolved destination).

**B3 — No `## Story Runtime Startup Smoke` section; no waiver.** [owner: mobile-dev]
Rule 12g makes registry-backed startup smoke mandatory for a non-trivial `mobile`
story, and `story_master.md` carries no `Runtime-Smoke: WAIVED — <reason>` line.
`test-results.md` states plainly under P2: "No emulator, simulator, signing, or
e2e work was attempted."

This is the highest-value missing gate in this story. The change replaces the
app's boot route. Every piece of evidence to date is `flutter test` in a headless
widget harness, which never runs `main()`, never initializes Firebase, and never
resolves `getIt<AuthRepository>()` or `getIt<AuthHistoryStore>()` through the real
`setupServiceLocator()`. Two of the three landing destinations resolve
`getIt<AuthRepository>()` lazily at navigation time
(`splash_screen.dart:85-86`), and that registration is new in this story — its
first real execution would be on a device.

Action: launch the app on the provided emulator/simulator, confirm it reaches
splash and then its resolved first screen with no crash and no error screen, and
record the result. P3's captures can satisfy this in the same device session.

## Non-Blocking Findings

**N1 — AC2 does not hold for a device authenticated before this build.** [owner: mobile-dev]
`AuthHistoryStore.markAuthenticated` is only ever called from
`AuthRepository._onAuthenticated` (`auth_repository.dart:71-73`), i.e. at sign-in
time. `SessionGateCubit._resolveSignedIn` never sets the marker. So any device
that authenticated before this code ships has `hasPreviousSession == false`; if
Firebase later clears the local user (token revoked, account disabled) the next
cold launch resolves `CupidSessionSignedOut` + marker absent → `WelcomeScreen`,
which is exactly the AC2 failure this story exists to fix.

Not blocking on its own: the app is pre-release, so the affected installed base
may be empty, and the primary AC2 path (signed-in + failing `idToken()`) is
unaffected. But the fix is one line — mark the device authenticated when the gate
resolves `SignedIn` — and it makes the marker self-healing. Worth folding into the
B1-B3 rework pass rather than deferring.

## Deferred Findings

| ID | Finding | Note |
|----|---------|------|
| D1 | `firebase_auth_sign_in_gateway.dart` sits in `features/auth/data/` while the interface dartdoc reserves provider SDK imports for `core/auth/` | Pre-existing doc/architecture contradiction; P0 Write Scope chose the current location. Pure relocation + one import when settled. |
| D2 | `CupidAuthFailure` has no cancellation case — dismissing a social sheet surfaces `UnexpectedAuthFailure` | Pre-existing taxonomy gap; needs a follow-up story. |
| D3 | Social sign-in native config absent (Google iOS URL scheme, Google Android Gradle plugin, Apple entitlement/nonce, Facebook on both platforms) | Correctly reported-not-fixed per ADR-7. Breaks social buttons at tap time, not launch routing. Route to DevOps/a follow-up story. |
| D4 | `data/devops/system/runtime-command-registry.json` fails the runtime-registry guard (`mobile-app.readiness.type: widget-test`, no `dependsOn`) | Pre-existing, outside this story's write scope. Route to DevOps. Note this may also obstruct B3's registry-backed smoke. |
| D5 | Stale comment at `reminder_overlay_host.dart:28-34` claims `main.dart` does not call `setupServiceLocator()`; it does, at line 20 | Cosmetic but actively misleading — it misled the DI reasoning during P2. |

## Write-Scope Extension Verification

The Scrum-Master-approved extension to `mobile/test/app/feature_flags_test.dart`
and `mobile/test/widget_test.dart` is genuinely test-only and additive: both files
are `+14 / -0` in the diff. No pre-existing assertion was weakened, skipped, or
deleted — the `themeMode`, `locale`, and `home_screen_ready_signal` expectations
are intact and still pass. The additions are a `createSessionGateCubit:` seam and
an explicit `pump(Duration(seconds: 3))` to clear the AC4 dwell, which
`pumpAndSettle()` cannot do because the splash dot animation never settles. No
production code was changed to accommodate the tests. Extension approved as
recorded.

## Verification Performed By Reviewer

- `git -C <worktree> diff <BaseHead>` over all 16 source/test files.
- Independent code read of the entry-route chain: `cupid_app.dart` →
  `splash_screen.dart` → `session_gate_cubit.dart` → `auth_history_store.dart`,
  plus the two new `service_locator.dart` registrations.
- Re-ran `flutter test test/app test/widget_test.dart test/features/auth/presentation`
  → `00:03 +37: All tests passed!` Confirms the implementer's recorded scoped run.
- Confirmed absence of `visual-fidelity/` via `git ls-files` (tracked) and
  `git status --porcelain` (untracked) — the directory does not exist in any form.

## State Recommendation

- Story status: `IN_PROGRESS` — return to mobile-dev.
- Leave `Implementation (Development)` unchecked; leave `Review (Reviewer)` unchecked.
- Rework set: B1, B2, B3, and N1 (bundle N1 with the device session for B1/B3).
- Round-2 review can be a scoped re-review of the three evidence gates plus the
  one-line N1 change. The routing logic and its tests are approved as-is and do
  not need re-verification unless they change.

Scrum Master note: `story_master.md` still records `Status: PENDING` with
`Implementation (Development)` unchecked, and `Implementation Lane: shared` while
the handoff and all delivered code say `mobile`. Reviewer does not edit workflow
state; flagging for correction.
