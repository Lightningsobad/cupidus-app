# Bug Master: BUG-20260814-003 Caption Typography Token Mismatch (Expected 13 / Actual 11.5)

Status: REPORTED
Severity: unknown
Source: REQ-002 STORY-002 round-3 audit (accepted as pre-existing baseline
across multiple stories; tracked for follow-up fix, not blocking)
Created: 2026-08-14
Linked Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Linked Story: cross-story (caption typography token, owner not yet confirmed)

## Report

Observed behavior:
Three design-fidelity tests each assert a caption font size of `13` but
observe `11.5` at the same shared root cause (caption typography token).

Expected behavior:
Rendered caption text should match the expected typography token size (`13`).

Reproduction steps or command:
Not run by Scrum Master (intake only). Candidate:
```
cd mobile
flutter test test/features/auth/login_screen_test.dart
flutter test test/features/pairing/waiting_screen_design_fidelity_test.dart
flutter test test/features/pairing/joincode_screen_design_test.dart
```
(paths approximate; bug-fixer to confirm exact file locations via query-first
reading.)

Failure anchors:
- Stack trace: N/A (design-fidelity assertion mismatch)
- Failing test:
  - `login_screen_test.dart:91`
  - `waiting_screen_design_fidelity_test.dart:238`
  - `joincode_screen_design_test.dart:107`
- Route/endpoint/component/job: caption typography token (shared)
- Environment: mobile (Flutter)

## Artifacts

- [ ] Diagnosis (Bug Fixer)
- [ ] Fix Evidence (Bug Fixer)
- [ ] Review (Reviewer)

## Routing Notes

- Current owner: scrum-master
- Next role: queued for fix-bugs
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md`
- Fix Evidence: `fix-evidence.md`
- Review Report: `review/review-report.md`
- Checkpoint: `scrum-master-checkpoint.md`
- Origin checkpoint: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/scrum-master-checkpoint.md` § Cross-Story / Infra Findings
- Note: all 3 failure instances were accepted as a pre-existing baseline during
  REQ-002 story review gates (not a regression); filed here for follow-up
  tracking, not urgent.

## Blockers

- N/A
