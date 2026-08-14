# Bug Master: BUG-20260815-001 ADR-004 No-Fork Guard Red — Raw Color Literals

Status: REPORTED
Severity: blocking (REQ-002 requirement integration review PATCH_REQUIRED
finding I-1; part of the RED `flutter test` suite that must be fixed before
DEFERRED_ONLY/CLEAN is possible per SKILL 12c)
Source: REQ-002 requirement integration review (Iris-QC, requirement-level
`Mode: requirement-integration-review`, finding I-1)
Created: 2026-08-15
Linked Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Linked Story: STORY-019, STORY-021, STORY-031 (each contributes a subset of
the violations; the guard test itself is shared/cross-story)

## Report

Observed behavior:
The ADR-004 no-fork/no-raw-color guard test is RED on the integration branch.
7 raw `Color(...)` literals bypass the shared design-token system across 3
different screens owned by 3 different stories, only visible once all three
merged together:

- `ghost_settings_screen.dart:211`, `:411` (STORY-019)
- `notification_settings_screen.dart:359` (STORY-031)
- `reminder_schedule_screen.dart:448`, `:449`, `:452` (STORY-021)
- `reminder_weekday_chips.dart:71` (STORY-021)

Expected behavior:
Every color value in these files resolves through the shared design-token
system (e.g. `CupidColorTokens` / `context.cupidColors` or the established
per-repo token accessor), not a literal `Color(0x...)`/`Colors.*` constant.
The guard test passes with 0 violations.

Reproduction steps or command:
Not run by Scrum Master (intake only). Candidate: run the ADR-004 no-fork /
raw-color guard test file in `mobile/test/` (bug-fixer to confirm exact
filename during query-first diagnosis) against the integration branch.

Failure anchors:
- Stack trace: N/A
- Failing test: the ADR-004 no-fork/raw-color guard test (exact filename to
  be confirmed by bug-fixer; same guard family Iris-QC's requirement
  integration review flagged as RED in `flutter test`)
- Route/endpoint/component/job:
  - `mobile/lib/.../ghost_settings_screen.dart:211,411`
  - `mobile/lib/.../notification_settings_screen.dart:359`
  - `mobile/lib/.../reminder_schedule_screen.dart:448,449,452`
  - `mobile/lib/.../reminder_weekday_chips.dart:71`
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
- Origin: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/integration-review/review-report.md`
  finding I-1 (integration worktree:
  `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`)
- Distinct root-cause family from `BUG-20260814-004` anchor (a) (ADR-002 copy
  guard, not ADR-004 color guard) — do not merge into that bug.

## Blockers

- N/A
