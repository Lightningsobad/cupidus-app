# Bug Master: BUG-20260815-002 Waiting Screen `_SkyBackdrop` Orphaned After STORY-032 Supersede

Status: IN_PROGRESS
Severity: blocking (REQ-002 requirement integration review PATCH_REQUIRED
finding I-3; 2 regression tests RED + 1 analyzer warning, part of the RED
`flutter test` suite that must be fixed before DEFERRED_ONLY/CLEAN is
possible per SKILL 12c)
Source: REQ-002 requirement integration review (Iris-QC, requirement-level
`Mode: requirement-integration-review`, finding I-3)
Created: 2026-08-15
Linked Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Linked Story: STORY-013 (original approved fix), STORY-032 (superseding
change that orphaned it)

## Report

Observed behavior:
`waiting_screen.dart:337` declares an unreferenced `_SkyBackdrop` element —
this is the single analyzer warning on the integration branch. `_SkyBackdrop`
was introduced in commit `2a92f37` as part of STORY-013's reviewer-approved
design-fidelity fix. STORY-032 ("Design System — App-Shell Background,
Button & Header Follow-Up", Tier-3 final synthesis) later introduced
`CupidAppBackground` which superseded `_SkyBackdrop`'s role, but nothing
removed the now-dead `_SkyBackdrop` declaration/reference and nothing updated
the 2 STORY-013 regression tests that assert against it — those 2 tests are
now RED on the integration branch.

Expected behavior:
Either (a) `_SkyBackdrop` and its dead reference are removed from
`waiting_screen.dart` and the 2 STORY-013 regression tests are retargeted to
assert against `CupidAppBackground` (the design-system successor), or (b) if
`CupidAppBackground` does not actually preserve the visual intent STORY-013's
fix delivered for the waiting screen, `_SkyBackdrop` is restored to active
use. Bug-fixer must determine which via query-first diagnosis of what
`CupidAppBackground` actually renders on the waiting screen before choosing
delete-and-retarget vs. restore — do not guess.

Reproduction steps or command:
Not run by Scrum Master (intake only). Candidate: `flutter analyze` for the
warning; run the 2 STORY-013 regression tests in `mobile/test/` (bug-fixer to
confirm exact filenames during query-first diagnosis) against the integration
branch.

Failure anchors:
- Stack trace: N/A
- Failing test: 2 STORY-013 waiting-screen regression tests (exact filenames
  to be confirmed by bug-fixer)
- Analyzer: 1 warning, unreferenced `_SkyBackdrop` element,
  `waiting_screen.dart:337`
- Route/endpoint/component/job:
  - `mobile/lib/.../waiting_screen.dart:337` (`_SkyBackdrop`, dead)
  - STORY-032's `CupidAppBackground` (superseding component)
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
  finding I-3 (integration worktree:
  `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`)
- An approved story's fix (STORY-013, reviewer-approved) was silently
  superseded/orphaned by a later story (STORY-032) without test/reference
  cleanup — treat this as the authoritative account of what happened; do not
  re-derive from scratch.

## Blockers

- N/A
