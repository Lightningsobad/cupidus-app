# Scrum Master Checkpoint: BUG-20260814-002

Bug id: BUG-20260814-002_waiting_screen_not_valid_login_resume_target
Status: DONE

## Resolution

Reviewer (Iris-QC) Outcome: DEFERRED_ONLY. 0 blocking, 4 deferred (D-1/D-2
diagnosis narrative precision, non-blocking; F-1/F-2 runtime-registry
launcher-class + readiness-probe defects, routed to DevOps, same family as
BUG-20260814-003's D-4). Fix + full bug artifacts committed on
`codex/REQ-002_screen_flow_and_design_fidelity_audit-integration` commit
`a0b6ed5`. A reviewer scratch probe file
(`mobile/test/zz_iris_probe_bug002_test.dart`) was removed from the
integration worktree via `git clean -f` after explicit user confirmation
(bash-safety-guard blocked plain `rm`) before this commit. This was the last
of the 5 REQ-002-round bug-registry bugs (BUG-20260815-001, -002,
BUG-20260814-003, -004, -002 — all now DONE). Next: REQ-002 requirement
checkpoint Next Valid Step 3 (Alex-Mobile-Dev: STORY-005 visual-fidelity
evidence + `integration-review/mobile-visual-audit.md`), then a fresh
integration build/runtime verification and Iris-QC Round 2 requirement
integration review.

## Artifact Paths
- Bug master: `data/bugs/BUG-20260814-002_waiting_screen_not_valid_login_resume_target/bug_master.md`
- Diagnosis: `data/bugs/BUG-20260814-002_waiting_screen_not_valid_login_resume_target/diagnosis.md`
- Fix evidence: `data/bugs/BUG-20260814-002_waiting_screen_not_valid_login_resume_target/fix-evidence.md`
- Review: `data/bugs/BUG-20260814-002_waiting_screen_not_valid_login_resume_target/review/review-report.md`

## Failure Anchors
- Tech Lead finding P1-F3: `waiting` is not a valid login-resume target
- Component: login-resume / onboarding-progress resolution logic
- `widget_test.dart` — 0 widgets found for `home_screen_ready_signal` with a
  seeded signed-in + paired session
- `app/feature_flags_test.dart` — same failure
- `git log -S` on the routing key: no REQ-002 commit touched it, so the
  routing logic itself is the cause, not a stale/renamed key
- Registry-declared `inAppFirstScreenSignal` == `home_screen_ready_signal`

## Expected Behavior Source
Tech Lead pre-disclosure (P1-F3), REQ-002 planning; independently reconfirmed
by REQ-002 requirement integration review (Iris-QC), finding I-4 — "Same
family as BUG-20260814-002".

Suspected impacted runtime/service/app: mobile-app (Flutter)
Runtime registry: `data/devops/system/runtime-command-registry.json`

Query keys for future bug-fixer handoff: "P1-F3", "OnboardingProgressResolver",
"waiting", "home_screen_ready_signal", "inAppFirstScreenSignal",
"widget_test.dart", "feature_flags_test.dart"

Active Bug Fixer Agent Id: Justin-BugFixer@session-0463b8e0
Bug Fixer Status: COMPLETE (BUG_FIX_COMPLETE: YES)

## Fix Summary (for Reviewer handoff)

**The reported framing does not survive evidence.** "Login-resume logic
resolves to `waiting`" is contradicted: `waiting` is structurally unreachable
as a resume target and the resolver's own dartdoc says so explicitly
("`waiting` and `permissions` are deliberately absent from the outcomes"). No
switch/resolver arm anywhere returns or renders `waiting` for a login-resume
boot. A runtime probe of the exact seeded harness showed the boot correctly
mounts `HomeScreen` with `home_screen_ready_signal` present, one frame later
than the test asserts.

**Actual root cause: a lost frame in the test pump sequence, from an
integration merge, not a resolver defect.** Two REQ-002 commits each left a
correct-for-its-own-base pump sequence: `a23f018` (STORY-001, splash gate)
left `pump(3s)` then `pumpAndSettle()`; `d43d9f2` (STORY-032,
`CupidAppBackground`) left `pump()` then `pump(1s)` (STORY-032 branched
before STORY-001, per `git merge-base --is-ancestor a23f018 d43d9f2` = false,
so it never saw the splash dwell, and dropped `pumpAndSettle` because
`CupidAppBackground` twinkles forever and the tree never settles). The
integration merge combined STORY-001's dwell-clear with STORY-032's two-pump
structure but put the bare `pump()` BEFORE `pump(3s)` instead of after it —
so the frame that builds the just-pushed route was spent before the dwell
was even cleared. Both stories' contributions survived the merge
individually; their ordering requirement did not. This also explains why
`git log -S` on the key found nothing: the key was never touched, only pump
ordering in the two test harnesses.

Fix: test-only, 2 files (`mobile/test/widget_test.dart`,
`mobile/test/app/feature_flags_test.dart`), `+10 -6`. Reorders to
`pump(3s)` (clear dwell → `pushReplacement`) then `pump()` (build pushed
route) then `pump(1s)` (finish the 300ms transition) — the merge resolution
that should have happened, preserving both parent commits' individual
requirements and STORY-032's "never `pumpAndSettle` at the composition root"
constraint. No production code changed.

Gates: Pre-Fix Reproduction REPRODUCED (both files, `Found 0 widgets with key
[<'home_screen_ready_signal'>]`). Original Failure Recheck PASS (`+5: All
tests passed!`, both originally-RED assertions now find the widget). Analyze
PASS on the 2 touched files (`No issues found!`; repo-wide 80 pre-existing
`info`-level issues in `lib/`, none in touched files). FULL-suite Regression
PASS: `+1242 ~2` (2242 total minus 2 skipped), zero failures — baseline at
HEAD `2da7d19` (BUG-20260814-003's own recorded baseline) was `+1240 ~2 -2`;
net 2 fixed, 0 introduced, confirming these were exactly the 2 residual
failures both prior bugs' regression runs had already attributed to this bug.
Build PASS (`flutter build apk --debug` exit 0). Runtime Startup PASS
(emulator-5560, `ResumedActivity` on the real launcher, pid alive, empty
error-level logcat; registry's own `am start -W` readiness probe times out
because the animated composition root never idles — expected, not a startup
failure, see F-2).

Not-in-scope findings for Scrum Master triage (recorded in `bug_master.md`,
not created as new bugs — both route to DevOps, same registry row F-1
already flagged by BUG-20260814-003): F-1 registry launcher-class defect
(now independently confirmed twice); F-2 registry `am start -W` readiness
step is structurally unusable for this app (animated root never idles),
`dumpsys` ResumedActivity poll is the reliable signal.

Work location: fix directly in the REQ-002 integration worktree
(`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`,
branch `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`),
from HEAD `2da7d19`. Changes left uncommitted for Scrum Master: 2 modified
test files + 2 new bug-record files (`diagnosis.md`, `fix-evidence.md`).

Work location: fix directly in the REQ-002 integration worktree
(`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`,
branch `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`), not
a fresh story worktree — this is only observable once the full integration is
assembled.

Priority: blocking REQ-002 DONE. Iris-QC's requirement integration review
(`Outcome: PATCH_REQUIRED`) states the RED `flutter test` suite is the
primary proof gate under SKILL 12c and cannot be recorded DEFERRED_ONLY —
this bug must reach `Status: DONE` before the next integration review can
pass.
