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

---

# Round 2 — Rework Verification

Outcome: DEFERRED_ONLY

Review type: compact-story-review (round 2, scoped to the round-1 findings)
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-001 — Complexity `standard`, Scope A (flow/navigation correction)
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-001`
Reviewed tip: `cec117a`
Date: 2026-08-14

## Diff Baseline Correction

The handoff declared `BaseHead: fc10180` as "the round-1 reviewed tip". It is not.
`fc10180` is a `complete story boundary` commit that already contains part of the
round-2 rework:

- the N1 production fix (`session_gate_cubit.dart`) and its regression test,
- four of the five `implemented-*` captures,
- the round-1 review report itself.

A strict `fc10180..HEAD` diff therefore shows **no `mobile/` change at all** and
would have hidden the entire N1 fix, making the commit message's "N1 fixes" look
unsubstantiated. I reviewed `a23f018..cec117a` for code and `fc10180..cec117a`
for the round-2 evidence layer. Recorded so the next round-N handoff pins the
true reviewed tip rather than the boundary commit.

## Round-1 Finding Disposition

| ID | Verdict | Basis |
|----|---------|-------|
| B1 — visual-fidelity evidence missing | **RESOLVED** | `visual-fidelity/` now holds 5 implemented captures, 5 design references and `visual-fidelity-report.md` with per-screen verdicts, `Design-Screen: splash, welcome, login`, and the ADR-6 cross-story note. Verified by rendering the artifacts, not by reading the claim — see below. |
| B2 — no `Entry Point Reachability` section | **RESOLVED** | `coding-plan/test-results.md` `## Entry Point Reachability`, `Reachable: YES`, with the concrete launcher → `MaterialApp.home` → `SplashScreen` → resolved-destination path and the `adb ... resolve-activity` result. Matches the code fact round 1 had already verified independently. |
| B3 — no `Story Runtime Startup Smoke`, no waiver | **RESOLVED** | `## Story Runtime Startup Smoke`, `Runtime-Smoke: PERFORMED`. Two real cold starts on `emulator-5560` (`am start -W`, `Status: ok`, `LaunchState: COLD`), differing only in the ADR-3 marker and landing on login (AC2) vs welcome (AC3), plus a clean `AndroidRuntime`/`flutter` logcat scan. This is the gate round 1 cared most about: it runs `main()`, Firebase init and the real `setupServiceLocator()`, which no widget test does. |
| N1 — marker not self-healing on the signed-in path | **RESOLVED** | `mobile/lib/features/auth/presentation/session_gate_cubit.dart:98-101` calls `await _authHistoryStore?.markAuthenticated(email: email)` at the top of `_resolveSignedIn`, with a comment stating why. Covered by a new regression test, `resolving signed-in self-heals a missing history marker (N1)` (`session_gate_cubit_test.dart:136-153`), which asserts the marker is absent before and both marker and `lastEmail` are set after. |

## Verification Performed By Reviewer

Round 1 approved the routing logic and its tests; no production code changed
except the N1 line, so this round verified the N1 change and the evidence layer
rather than re-deriving the ACs.

- **Tests re-run, not trusted.** `flutter test test/app test/widget_test.dart
  test/features/auth test/core/auth` → `00:05 +70: All tests passed!` (full,
  unfiltered output). Includes the new N1 test.
- **Captures rendered, not tallied.** Opened
  `implemented-splash-emulator-5554.png` and
  `design-reference-splash-emulator-5554.png` side by side. The implemented
  capture is a genuine 1080x2400 device screenshot (status bar, DEBUG banner)
  showing the Cupid wordmark, three dots and the Vietnamese caption on a
  pink→lavender→mint gradient with **no** tap-to-continue pill. The design
  reference shows violet→magenta→teal, an upper-left radial glow, a low-placed
  caption and the "Chạm để tiếp tục" pill. D1-D4 are exactly as recorded — I did
  not have to take the report's word for any of them.
- **AC2 verified by observation.** `implemented-launch-login-emulator-5560.png`
  shows the session-expired variant headed "Đăng nhập lại để tiếp tục" with the
  email field prefilled `seed.user@cupid.test`. That prefill can only arrive via
  `AuthHistoryStore.lastEmail()` → `SessionGateSessionExpired` → screen, so the
  capture proves the AC2 data path end to end on a device, not merely that some
  login screen appeared. D11-D17 match the rendered image.
- **Design source pinned.** The report's `sha256:44c8b209…c1cf2c58` matches
  `data/devops/system/design-fidelity-config.json` `content_fingerprint`
  byte for byte, with `locked: true` and `ui_surface: true`.
- **Device claims checked against the devices.** Both named emulators are
  attached (`adb devices` → `emulator-5554`, `emulator-5560`). I read each
  device's `shared_prefs` directly:
  - `emulator-5554` has **no** `com.google.firebase.auth.api.Store.*.xml` at all;
  - `emulator-5560`'s store is literally `<map />`.

  This independently confirms the P3 stop-rule justification for `home`: no
  persisted Firebase user exists on either device, so an AC1 launch state cannot
  be manufactured without live-project credentials.
  - Neither device's `FlutterSharedPreferences.xml` still contains
    `flutter.auth.has_previous_session_v1`, confirming the report's claim that the
    seeded AC2 state was restored and no sibling story inherits a manufactured
    device.

## Gate Conflict Adjudication — `VISUAL_FIDELITY: FAIL` Does Not Block This Story

`coding-plan/master-plan.md` states the story "cannot go to Review until
`visual-fidelity-report.md` exists and records `VISUAL_FIDELITY: PASS`", and the
delivered report records `FAIL`. Mobile Developer escalated the conflict rather
than softening the verdict. **Adjudicated in favour of the story; the `FAIL`
token is not a blocker here.** Reasoning:

1. `story_master.md:53-56` puts "Visual/design fidelity of the splash, welcome,
   login, or home screens themselves" **explicitly out of scope**, and names
   STORY-003/004/005/017 as the owners.
2. All 17 deltas are pre-existing screen drift owned by those sibling stories,
   except D1 — the ADR-6 tap-to-continue removal, which is this story's only
   visual change and is architecture-approved.
3. Enforcing `PASS` literally would require STORY-001 to fix three screens it is
   forbidden to touch, in write scopes it does not hold. The gate would be
   unclosable by construction, and the only ways to "pass" it would be to fake a
   verdict or skip the capture — the two failure modes B1 was raised to prevent.
4. The reviewer vocabulary already has the correct instrument for real findings
   owned elsewhere: they are deferred, not blocking. Hence `DEFERRED_ONLY`
   rather than `CLEAN` — the deltas are real and must not be written off.

The `PASS` wording in `master-plan.md` was authored before it was known that the
routing story would be the first to render these screens. It should be read as
"no fidelity regression attributable to this story", which holds. Scrum Master
should not treat the `FAIL` token as a DONE blocker for STORY-001.

Recording `PASS` would have been wrong, and the honest `FAIL` with routed
ownership is the better artifact. That judgement call is endorsed.

## Residual Risks And Deferred Findings

Round-1 deferred findings D1-D5 stand unchanged. Added this round:

| ID | Finding | Route |
|----|---------|-------|
| D6 | The ADR-6 "do not reinstate the tap-to-continue pill" note lives **only** in STORY-001's `visual-fidelity/visual-fidelity-report.md`. STORY-003 has no pointer to it. If STORY-003 matches the canvas literally it will restore the pill and reintroduce the AC4 bypass this story was opened to fix. | **Highest-value carry-over.** Scrum Master should quote this constraint directly in the STORY-003 handoff; STORY-001 cannot write into STORY-003's scope. |
| D7 | AC1 / `home` was never observed on a device. Independently confirmed unmanufacturable (no persisted Firebase user on either emulator, no seed credentials provisioned). AC1 remains covered by widget tests round 1 accepted as PASS. | Whichever story first has an authenticated device captures `implemented-launch-home-*`; STORY-017 owns the comparison. |
| D8 | Offline session resolution is slow: on these emulators splash still showed at 12 s and the destination only by 45 s. The delay is Firebase Auth's first offline auth-state emission, not this story's code, and it errs *late* — AC4 forbids navigating *early*, so it is not a violation. | Bounding the first-emission wait would change approved ADR-011h semantics. Follow-up decision, not rework. |
| D9 | The five `design-reference-*` files are viewport renders but are named per emulator; the `-5554`/`-5560` pairs are byte-identical duplicates. | Cosmetic naming only. Worth normalising in the REQ-002 convention so later stories do not read a device id into a design render. |
| D10 | `emulator-5560` carries a leftover `flutter.cupid_pairing_status_v1:…` = `paired` entry from other device work. Not written by this story, and its cleanup of its own seed was correct. | Device hygiene note for whoever next relies on a clean pairing state. |

No blocking findings this round.

## State Recommendation

- Story status: eligible to proceed. Round-1 blockers B1, B2, B3 and finding N1
  are all genuinely resolved, verified against artifacts and devices rather than
  assertions.
- `Outcome: DEFERRED_ONLY` satisfies the review gate; the story branch is merge
  eligible into `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`.
- Still outstanding for Scrum Master, unchanged from round 1 and **not** fixed by
  this rework: `story_master.md` records `Status: PENDING` with
  `Implementation (Development)` and `Review (Reviewer)` unchecked, and
  `Implementation Lane: shared` while every delivered file is under `mobile/`.
  Reviewer does not edit workflow state.
- Carry D6 into the STORY-003 handoff before that story starts.
