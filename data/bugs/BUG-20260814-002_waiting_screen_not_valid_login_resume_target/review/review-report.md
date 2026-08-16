---
story_status_recommendation: "N/A"
implementation_status_recommendation: "KEEP_CHECKED"
reviewed_at: 2026-08-15
reviewed_by: Reviewer
---

# Review Report: BUG-20260814-002 `waiting` Screen Used As Login-Resume Target

Outcome: DEFERRED_ONLY

## Reviewed Inputs

- Review gate: `bugfix-review`
- Scope Gate: `data/bugs/BUG-20260814-002_waiting_screen_not_valid_login_resume_target/review/scope-gate.md`
- Requirements: REQ-002_screen_flow_and_design_fidelity_audit; Tech Lead
  pre-disclosed finding P1-F3 ("`waiting` is not a valid login-resume target");
  REQ-002 integration review finding I-4 (2 RED tests)
- Bug Report: `data/bugs/BUG-20260814-002_waiting_screen_not_valid_login_resume_target/bug_master.md`
- Diagnosis: `data/bugs/BUG-20260814-002_waiting_screen_not_valid_login_resume_target/diagnosis.md`
- Fix Evidence: `data/bugs/BUG-20260814-002_waiting_screen_not_valid_login_resume_target/fix-evidence.md`
- UX: `N/A`
- Architecture: ADR-1 (onboarding chain) and ADR-2 (resume rule table), read
  through their in-source citations only
- Coding Plan: `N/A`
- Test Results: reviewer reruns of the Original Failure Recheck Gate and the
  Analyze Gate, plus a reviewer-authored temporary probe (details below)
- Previous review findings: `N/A` — first review pass for this bug

## Reviewed Scope

- Story complexity: `N/A`
- Bug status: `REPORTED` in `bug_master.md`; `BUG_FIX_COMPLETE: YES` in
  `fix-evidence.md`, so the bug is fix-complete and at the review gate
- Code scope reviewed:
  - changed: `mobile/test/widget_test.dart`, `mobile/test/app/feature_flags_test.dart`
  - read-only verification: `mobile/lib/core/navigation/onboarding_progress_resolver.dart`,
    `mobile/lib/features/auth/presentation/screens/splash_screen.dart`,
    `mobile/lib/core/navigation/pair_gate_shell.dart`,
    `mobile/lib/core/navigation/onboarding_chain.dart`,
    `mobile/lib/core/di/service_locator.dart` (lines 360-419),
    `mobile/lib/features/auth/presentation/screens/login_screen.dart` (lines 150-191),
    `mobile/test/core/navigation/onboarding_route_registry_guard_test.dart`,
    `mobile/android/app/src/main/AndroidManifest.xml`
- Evidence reviewed: `diagnosis.md` and `fix-evidence.md` in full; `git diff HEAD`,
  `git status --short`, `git show a23f018`, `git show d43d9f2`,
  `git merge-base --is-ancestor`
- Risk surfaces reviewed: mobile navigation / login-resume routing; app
  lifecycle and boot sequence; test harness reliability
- Critical gates reviewed: see the Risk Surface Gate Summary
- Backend targeted verification gates: `NOT_APPLICABLE`
- Story runtime startup smoke: `NOT_APPLICABLE` (bugfix runtime gate applies instead — PASS)
- Frontend targeted verification gates: `NOT_APPLICABLE`
- Frontend discoverability/navigation integration: `NOT_APPLICABLE`
- Requirement frontend visual audit: `NOT_APPLICABLE`
- Mobile targeted verification gates: `PASS`
- Mobile discoverability/navigation integration: `NOT_APPLICABLE` — no
  user-facing surface, entry point, or navigation edge was added or changed
- Requirement mobile visual audit: `NOT_APPLICABLE` — test-only change, no
  rendered screen affected
- Story artifacts reviewed: `N/A`
- Bug artifacts reviewed: `bug_master.md`, `diagnosis.md`, `fix-evidence.md`
- OQ context reviewed: `N/A` — no OQ is referenced by this bug

## Outcome Summary

- Review outcome: DEFERRED_ONLY
- Rationale: The bug-fixer's central claim — that the reported defect does not
  exist and the fix is correctly test-only — was independently re-derived and
  **holds**. It is in fact better supported than the diagnosis states: the
  "`waiting` is not a reachable login-resume target" invariant is not merely
  documented in a dartdoc, it is enforced by a dedicated exhaustive guard test
  that would fail if the resolver ever gained a `waiting` outcome. The
  pump-ordering root cause was confirmed by a reviewer-authored probe that
  deterministically reproduces the original failure under the pre-fix ordering
  and shows it resolved under the post-fix ordering. Two gates were rerun and
  passed; three were accepted from evidence under rule 18. The deferred items
  are artifact-accuracy issues and two correctly-routed DevOps findings, none of
  which affect the correctness of the fix.
- Blocking findings: 0
- Deferred findings: 4
- Dismissed observations: 0

## Independent Verification Of The "No Real Defect" Claim

This claim was treated as the primary review target and was re-derived from
source and Git, not accepted from the artifacts.

**1. `waiting` is unreachable as a login-resume target — CONFIRMED, and the
invariant is machine-enforced.**

- `onboarding_progress_resolver.dart:40-66` — `resolve()` has exactly five
  returns: `home`, `loveContract` (`:45-48`), `otp` (`:52`), `profileSetup`
  (`:56-59`), `pairingChoice` (`:62`), plus the `catch` fallback to
  `pairingChoice` (`:64`). No `waiting`. The class dartdoc at `:25-27` states the
  exclusion explicitly, exactly as the diagnosis quotes.
- `splash_screen.dart:111-124` — the destination switch has four arms
  (`SizedBox.shrink`, `WelcomeScreen`, `PairGateShell`, `LoginScreen`), exhaustive
  over `SessionGateState`. No `waiting` arm. Confirmed.
- `pair_gate_shell.dart:137-151` — the state switch has three arms
  (`_PairGateChecking`, `PairingChoiceScreen`, `AppShell`), exhaustive over
  `PairGateState`. No `waiting` arm. Confirmed.
- `onboarding_chain.dart:38-39` — `waiting` appears only as the forward edges
  `invite -> waiting -> paired`. Repo-wide search shows `WaitingScreen` is pushed
  from exactly one site, `invite_screen.dart:159`, i.e. the inviter flow.
  Confirmed.
- Not cited by the diagnosis, and stronger than what it argues: the only two
  login-resume call sites are `login_screen.dart:164` and `welcome_screen.dart:98`,
  and `mobile/test/core/navigation/onboarding_route_registry_guard_test.dart`
  drives `resolve()` across its entire input space (16 profile/verification
  combinations plus both failure fallbacks), collects every node it can return,
  and asserts each is either in the shipped `onboardingRouteBuilders()` registry
  or in `_directPushResumeTargets = {profileSetup}`. `waiting` is in neither set,
  so a resolver that could return `waiting` would fail that test. It passes.

P1-F3 is therefore a pre-disclosed constraint the implementation honours and
regression-guards. It is not an outstanding defect, and integration review
finding I-4 attributed the 2 RED tests to it by proximity.

**2. The pump-ordering root cause — CONFIRMED by reviewer probe, with one
correction to the stated mechanism.**

The diagnosis's own probe was deleted and could not be rerun, so a fresh probe
was written, run, and is being removed (see Action Items). It ran the real
harness twice, dumping the mounted screens at each pump:

```
PROBE-A (pre-fix order: pump(), pump(3s))
  [after pump(3s) — the old assert point]  SplashScreen, PairGateShell, _PairGateChecking | READY_KEY=false
  [+pump()]                                SplashScreen, PairGateShell, AppShell, HomeScreen | READY_KEY=true

PROBE-B (post-fix order: pump(3s), pump(), pump(1s))
  [after pump(3s)]                         SplashScreen, PairGateShell, _PairGateChecking | READY_KEY=false
  [after pump()]                           SplashScreen, PairGateShell, AppShell, HomeScreen | READY_KEY=true
  [after pump(1s) — the assert point]      PairGateShell, AppShell, HomeScreen | READY_KEY=true
```

- The pre-fix ordering deterministically fails: an explicit `findsNothing`
  assertion at the old assert point passed. The original failure is fully
  explained by pump ordering.
- `WaitingScreen` and `PairingChoiceScreen` never mount in either run —
  independent runtime corroboration of point 1.
- Timing arithmetic is consistent: `splash_screen.dart:77` sets
  `_minDwell = Duration(seconds: 2)`, `:93` arms the dwell timer, `:128-130`
  calls `pushReplacement(MaterialPageRoute(...))`. `pump(3s)` therefore clears
  the 2s dwell with margin, and the post-fix sequence leaves one frame of slack
  before its assertion.
- Correction: at the pre-fix assert point the pushed route **is** already built
  (`PairGateShell` is mounted, showing `_PairGateChecking`). The frame that is
  missing is the one that renders the resolved `PairGateCubit` emission
  (`PairGatePaired` -> `AppShell` -> `HomeScreen`), not the one that builds the
  pushed route. See D-1.

**3. Commit provenance — CONFIRMED.**

- `a23f018` — "feat(REQ-002/STORY-001): route app launch through splash entry
  gate (P2)", 2026-08-13. Added `pump(3s)` and kept `pumpAndSettle()`. Matches
  the diagnosis table.
- `d43d9f2` — "feat(REQ-002_.../STORY-032): complete story boundary",
  2026-08-14. Replaced `pumpAndSettle()` with `pump()` + `pump(1s)`, with no
  `pump(3s)` in its context. Matches the diagnosis table.
- `git merge-base --is-ancestor a23f018 d43d9f2` exits 1 (false), as claimed.
  The reverse is also false, so the two are divergent siblings rather than
  strictly ordered — but the substantive claim, that STORY-032's branch never
  contained the splash entry gate, is exactly what the false result establishes.
- The pre-fix merged state was `pump()` + `pump(3s)`, i.e. STORY-032's `pump(1s)`
  was bumped to 3s and its trailing settle pump lost, matching the diagnosis's
  account of how the merge reconciled the two.

**4. The change set is exactly as described — CONFIRMED.**

`git diff --stat HEAD` and `git status --short` show 2 files changed,
+10 / -6, both under `mobile/test/`. Zero files under `mobile/lib/` are
touched. The fix is genuinely test-only.

## Traceability Summary

- Requirements: REQ-002; P1-F3 verified as honoured and guard-tested, not defective
- Bug report: observed behavior "login-resume can resolve to `waiting`" is
  contradicted by source, by the exhaustive resolver guard test, and by runtime
  probe; the reported defect does not exist
- Diagnosis: `## Pre-Fix Reproduction Gate` present (rule 16 satisfied); root
  cause independently confirmed
- Open Questions: none referenced
- UX: `N/A`
- Architecture: ADR-1/ADR-2 constraints unchanged by this fix
- Testing evidence: Recheck and Analyze gates rerun by the reviewer; Build,
  Runtime Startup, and full-suite Regression accepted from `fix-evidence.md`
  under rule 18

## Risk Surface Gate Summary

| Risk Surface | Source Of Truth | Critical Gate | Result | Notes |
|--------------|-----------------|---------------|--------|-------|
| Mobile login-resume routing | `OnboardingProgressResolver.resolve()` outcome set; P1-F3 | Resolver outcome set + `onboarding_route_registry_guard_test.dart` | PASS | Re-derived from source; `waiting` not returnable and the guard test would fail if it were |
| App lifecycle / boot sequence | `splash_screen.dart` dwell + `pushReplacement` | Boot-to-ready-signal widget test | PASS | Rerun by reviewer; probe confirms mount order |
| Test harness reliability | The 2 changed test files | Original Failure Recheck Gate | PASS | Reviewer rerun: 5/5, same modality (`flutter test`, both named files) |
| Test harness reliability | The 2 changed test files | Analyze Gate | PASS | Reviewer rerun: `No issues found! (ran in 1.7s)` |
| Mobile build | `flutter build apk --debug` | Build Gate | PASS (accepted, rule 18) | Not rerun; evidence current at HEAD `2da7d19` and uncontradicted |
| Mobile runtime startup | Runtime registry id `mobile-app` | Runtime Startup Gate | PASS (accepted, rule 18) | Not rerun; ResumedActivity poll, live pid, clean error logcat, registry shutdown. Launcher workaround per F-1 |
| Regression | Full `flutter test` suite | Regression Gate | PASS (accepted, rule 18) | Not rerun; `+1242 ~2`, 0 failures vs `+1240 ~2 -2` baseline — exactly the 2 target tests recovered, 0 new |

Rule 18 acceptance is explicit: the Build, Runtime Startup, and full-suite
Regression gates were **not** independently rerun. They were accepted because
the evidence is current (same HEAD `2da7d19` this review inspected), specific
(named commands, device `emulator-5560`, pid `24766`, exact pass counts against
a named baseline), registry-backed (runtime id `mobile-app`, its readiness poll
and its documented shutdown step), and uncontradicted by anything observed
during this review.

## Deferred Findings

- **D-1 — Diagnosis and in-test comments describe the missing frame one link too
  early.** `diagnosis.md` states "the assertion runs with the pushed route not
  yet built", and the comment now carried in both test files says "pump the frame
  that builds the pushed route plus its 300ms transition". The reviewer probe
  shows the pushed route is already built at that point; what has not yet
  rendered is the resolved `PairGateCubit` emission that swaps
  `_PairGateChecking` for `AppShell`/`HomeScreen`. The root cause classification,
  the impacted surface, and the fix are all unaffected — only the explanatory
  detail is off. Non-blocking, but both are durable text a future maintainer will
  read as authoritative. Owner: Bug Fixer, or whoever next edits these files.
- **D-2 — The diagnosis's Evidence-1 probe transcript is not reproducible and
  diverges from an independent rerun.** It records `SplashScreen=1` only at the
  `pump(3s)` row and the ready key appearing only after a further `+200ms`; the
  reviewer probe shows `PairGateShell` and `_PairGateChecking` already mounted at
  that row and the ready key appearing after a single zero-duration `pump()`. The
  load-bearing fact (ready key absent at the old assert point) agrees in both.
  The original probe was deleted, so the divergence cannot be resolved.
  Recommendation for future diagnoses: keep the probe file, or paste its source
  into the artifact, when a transcript is offered as primary evidence.
- **F-1 — Runtime registry declares a launcher activity that does not exist
  (DevOps).** `data/devops/system/runtime-command-registry.json` declares
  `com.snapsofts.cupid/com.snapsofts.cupid.MainActivity`. Substantiated
  independently: `mobile/android/app/src/main/AndroidManifest.xml:13` declares
  `.MainActivity` relative to the Android namespace `com.snapsofts.cupid_mobile`,
  while the applicationId is `com.snapsofts.cupid`, so the resolvable component
  is `com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`. Correctly
  deferred: the registry is outside this bug's write scope, and the bug-fixer
  documented the workaround it used. Already independently confirmed during
  BUG-20260814-003. Non-blocking for this bug; route to DevOps.
- **F-2 — Registry `am start -W` readiness step is unreliable for this app
  (DevOps).** `CupidAppBackground` animates continuously, so the activity never
  goes idle and `am start -W` always reports `Status: timeout`. The
  `dumpsys activity activities` ResumedActivity poll is the reliable signal and
  did pass. Correctly deferred; route to DevOps. Non-blocking.

Neither F-1 nor F-2 is a live blocking defect for this bug: the runtime startup
gate still produced a genuine pass through the registry's own ResumedActivity
readiness signal.

## Implementation Action Items

Not rework — one reviewer-side housekeeping item that must be cleared before
Scrum Master stages this change set:

- `[scrum-master + user confirmation]`
  `mobile/test/zz_iris_probe_bug002_test.dart` — a temporary probe file the
  reviewer created to verify the pump-ordering claim is still present as an
  untracked file in the integration worktree. Deleting it was blocked by
  `.claude/hooks/bash-safety-guard.sh`, which requires explicit user
  confirmation for `rm` under a project directory. It is not part of the fix.
  It must be removed before any `git add -A`, or the commit will contain a
  reviewer scratch file. Exact command, pending user confirmation:
  `rm /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit/mobile/test/zz_iris_probe_bug002_test.dart`

## Workflow State Recommendation

- Story status: `N/A`
- Bug status: `DONE`
- `Implementation (Development)`: `KEEP_CHECKED`
- `Review (Reviewer)`: `CHECK`
- Next step: Scrum Master clears the reviewer probe file (user confirmation
  required), then commits the 2 test files plus the three bug artifacts and this
  review, marks BUG-20260814-002 `DONE` in `bug_master.md` and
  `data/bugs/master_bugs_list.md`, and routes F-1 and F-2 to DevOps as separate
  registry work. REQ-002 integration review finding I-4 can be closed: the 2 RED
  tests it flagged are green, and the P1-F3 routing concern it attached to them
  is verified as an already-honoured, guard-tested invariant rather than a
  defect.
- State update owner: `scrum-master` only. Reviewer does not edit story or
  requirement status files.
