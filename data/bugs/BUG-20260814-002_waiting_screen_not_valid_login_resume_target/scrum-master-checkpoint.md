# Scrum Master Checkpoint: BUG-20260814-002

Bug id: BUG-20260814-002_waiting_screen_not_valid_login_resume_target
Status: IN_PROGRESS

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
Bug Fixer Status: RUNNING

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
