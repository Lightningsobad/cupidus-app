# Bug Master: BUG-20260814-001 Chrome Header Breach (forgot_password/otp/permissions/onboarding_profile_setup)

Status: REVIEW_REQUIRED
Severity: unknown
Source: STORY-002 P5 cross-story audit (REQ-002 screen flow correction & design fidelity audit)
Created: 2026-08-14
Linked Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Linked Story: STORY-007, STORY-008, STORY-009, STORY-010

## Report

Observed behavior:
`forgot_password`, `otp`, `permissions`, and `onboarding_profile_setup` screens
each render a `CupidHeader`.

Expected behavior:
`ux/uiux-spec.md`'s Chrome Rules are unconditional (locked spec, not a
design-intent question): these routes must not render `CupidHeader`.

Reproduction steps or command:
Not run by Scrum Master (intake only). Candidate: run
`mobile/test/features/**/chain_chrome_guard_test.dart` in the `mobile/`
Flutter project and inspect `_trackedHeaderBreaches` output.

Failure anchors:
- Stack trace: N/A (design-fidelity/chrome-rule guard finding, not a crash)
- Failing test: `chain_chrome_guard_test.dart` `_trackedHeaderBreaches` (added
  by STORY-002 P5 to pin/track these breaches)
- Route/endpoint/component/job: `CupidHeader` rendered on routes
  `forgot_password`, `otp`, `permissions`, `onboarding_profile_setup`
  (owned by STORY-007/008/009/010 respectively)
- Environment: mobile (Flutter)

## Artifacts

- [x] Diagnosis (Bug Fixer)
- [x] Fix Evidence (Bug Fixer)
- [ ] Review (Reviewer)

## Routing Notes

- Current owner: reviewer (Justin-BugFixer completed 2026-08-16, commit
  `f726e8c` in the REQ-002 integration worktree; BUG_FIX_COMPLETE: YES,
  build/analyze/test/runtime gates all PASS — see `fix-evidence.md`. This is
  the only pre-existing REPORTED bug tied to REQ-002 not covered by Round 1's
  I-1..I-8; must reach `DONE` before REQ-002 can be marked DONE)
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md`
- Fix Evidence: `fix-evidence.md`
- Review Report: `review/review-report.md`
- Checkpoint: `scrum-master-checkpoint.md`
- Origin checkpoint: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/scrum-master-checkpoint.md` § Cross-Story / Infra Findings

## Blockers

- N/A
