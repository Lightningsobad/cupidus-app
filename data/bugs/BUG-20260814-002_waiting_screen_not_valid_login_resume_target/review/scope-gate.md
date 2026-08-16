# Review Scope Gate: BUG-20260814-002 `waiting` Screen Used As Login-Resume Target

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

## Identity

- Review type: `bugfix-review`
- Review report path: `data/bugs/BUG-20260814-002_waiting_screen_not_valid_login_resume_target/review/review-report.md`
- Scope gate path: `data/bugs/BUG-20260814-002_waiting_screen_not_valid_login_resume_target/review/scope-gate.md`
- Work location: REQ-002 integration worktree
  `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`,
  branch `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`, HEAD `2da7d19`.

## Scope Decision

- Scope status: `PROCEED`
- Why this review is within budget or why it must stop:
  The change set is 2 test files (10 insertions, 6 deletions). The bug-fixer
  asserts the reported defect does not exist and that no production code needed
  to change. That claim is load-bearing and must be independently re-derived, so
  the scope adds 4 read-only production navigation/routing files as verification
  targets (not as changed files). Total 6 source/test files, 0 governing
  artifacts over 20 KB — inside the bugfix-review budget.
- Current story or bug status: `bug_master.md` records `Status: REPORTED` with
  all three `## Artifacts` checkboxes unchecked; `fix-evidence.md` records
  `BUG_FIX_COMPLETE: YES`, so the bug is fix-complete and ready for the review
  gate. Scrum Master owns the status transition.
- Retro gate: no `data/retro-audit/rework-backlog.md` exists on this branch
  (`git ls-files data/retro-audit/` returns only `scrum-master-checkpoint.md`),
  so rule 1a imposes no `RWB-*` blocker and `Retro-Bypass: NO` is correct.

## Governing Inputs

- Primary artifacts:
  - `data/bugs/BUG-20260814-002_waiting_screen_not_valid_login_resume_target/bug_master.md`
  - `data/bugs/BUG-20260814-002_waiting_screen_not_valid_login_resume_target/diagnosis.md`
  - `data/bugs/BUG-20260814-002_waiting_screen_not_valid_login_resume_target/fix-evidence.md`
- Existing review findings: `N/A` — first review pass for this bug. Upstream
  context only: REQ-002 integration review finding I-4 (2 RED tests), which this
  bug's diagnosis re-attributes.
- Test evidence: `fix-evidence.md` `## Gate: Original Failure Recheck`,
  `## Gate: Analyze`, `## Gate: Regression Evidence`, `## Gate: Build`,
  `## Gate: Runtime Startup`.
- Extra artifacts required beyond the default minimum: none. `story_master.md`
  is not required — the bug is linked to STORY-002 only as an unconfirmed
  candidate and the expected behavior does not depend on it (rule 16).

## Source/Test Files In Scope

Changed (the entire fix diff):

- `mobile/test/widget_test.dart`
- `mobile/test/app/feature_flags_test.dart`

Read-only, to independently re-derive the "no production defect exists" claim:

- `mobile/lib/core/navigation/onboarding_progress_resolver.dart`
- `mobile/lib/features/auth/presentation/screens/splash_screen.dart`
- `mobile/lib/core/navigation/pair_gate_shell.dart`
- `mobile/lib/core/navigation/onboarding_chain.dart`

## Evidence Files In Scope

- `data/bugs/BUG-20260814-002_waiting_screen_not_valid_login_resume_target/diagnosis.md`
  (`## Pre-Fix Reproduction Gate`, `## Headline`, `## Actual Root Cause`,
  `## Out-Of-Scope Findings`)
- `data/bugs/BUG-20260814-002_waiting_screen_not_valid_login_resume_target/fix-evidence.md`
  (all five gate sections)
- Git history for commit provenance: `a23f018` (STORY-001), `d43d9f2`
  (STORY-032), and the integration merge that combined them.

## Risk Surfaces And Critical Gates

- Touched risk surfaces:
  - mobile navigation / login-resume routing (the *claimed* surface — must be
    proven unaffected, since a wrong "no defect" call ships a real routing bug)
  - app lifecycle / boot sequence (splash dwell -> `pushReplacement` -> route build)
  - test harness reliability (the only surface actually modified)
- Source-of-truth artifacts or contracts:
  - `OnboardingProgressResolver.resolve()` outcome set (the resolver's own dartdoc
    is the documented contract that `waiting` is absent)
  - Tech Lead finding P1-F3: "`waiting` is not a valid login-resume target"
  - runtime registry `inAppFirstScreenSignal` = `home_screen_ready_signal`
- Critical gates to verify:
  - Original Failure Recheck Gate — RERUN independently (same modality:
    `flutter test` on the two named files)
  - Analyze Gate — RERUN independently on the two touched files
  - Build / Runtime Startup / full-suite Regression — accept from
    `fix-evidence.md` under rule 18 (current, specific, uncontradicted,
    registry-backed); state the acceptance explicitly in the report
  - Structural unreachability of `waiting` — re-derive from source, do not trust
  - Pump-order arithmetic — re-derive from `splash_screen.dart` timing, do not
    trust the deleted probe
  - Commit provenance (`a23f018`, `d43d9f2`, ancestry) — re-derive from git
- Mandatory web Playwright/browser-e2e gate: `NOT_APPLICABLE in ordinary continue`
- Requirement visual audit evidence: `NOT_APPLICABLE` — test-only change, no
  UI-bearing surface delivered by this bugfix
- Mandatory mobile e2e/emulator/signing/store gate: `NOT_APPLICABLE in ordinary continue`
- Requirement mobile visual audit evidence: `NOT_APPLICABLE` — no rendered
  screen changed by this bugfix
- Missing gate evidence or blocker: `N/A`

## Query Keys

- `waiting`, `OnboardingNode.waiting`, `WaitingScreen`
- `OnboardingProgressResolver`, `resolve(`, `OnboardingDestination`
- `pushReplacement`, splash dwell duration constant, `MaterialPageRoute`
  transition duration
- `home_screen_ready_signal`
- `pump(`, `pumpAndSettle`, `CupidAppBackground`
- `PairGateShell` state switch arms, `PairingChoiceScreen`, `AppShell`
- Commits `a23f018`, `d43d9f2`; `git merge-base --is-ancestor`
- Not-in-scope findings F-1 (launcher activity class) and F-2 (`am start -W`
  readiness)

## Phase 2 Approval

- Phase 2 may proceed: `YES`
- If `NO`, final review outcome should be: `N/A`
- If `NO`, exact blocker or re-scope instruction: `N/A`
