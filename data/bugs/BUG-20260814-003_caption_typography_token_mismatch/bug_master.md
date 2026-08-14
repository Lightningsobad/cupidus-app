# Bug Master: BUG-20260814-003 Caption Typography Token Mismatch (Expected 13 / Actual 11.5)

Status: REPORTED
Severity: blocking (reconfirmed and broadened by REQ-002 requirement
integration review finding I-5; part of the RED `flutter test` suite that
must be fixed before DEFERRED_ONLY/CLEAN is possible per SKILL 12c — the
earlier "accepted baseline, not blocking" disposition was a per-story review
exception and does not survive requirement-level integration review)
Source: REQ-002 STORY-002 round-3 audit (originally accepted as pre-existing
baseline across multiple stories); blast radius widened and reconfirmed RED
by Iris-QC's REQ-002 requirement integration review (finding I-5)
Created: 2026-08-14
Linked Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Linked Story: cross-story (caption typography token, owner not yet confirmed)

## Report

Observed behavior:
Three design-fidelity tests each assert a caption font size of `13` but
observe `11.5` at the same shared root cause (caption typography token).
Finding I-5 (requirement integration review) confirms this same root cause
also covers the login caption and additionally surfaces a SECOND, previously
uncovered drift on the same shared token family: the muted-alpha value used
by the Love Pet eyebrow has drifted `0.65` → `0.575`. Both drifts trace to the
same shared token surface, `mobile/lib/design_system`, touched across 14
commits spanning 14 different REQ-002 stories — this is a widely shared
design-system regression, not an isolated per-screen issue.

Expected behavior:
Rendered caption text should match the expected typography token size (`13`)
on every screen that uses it (including login). The Love Pet eyebrow's muted
alpha should read `0.65`, not the drifted `0.575`.

Reproduction steps or command:
Not run by Scrum Master (intake only). Candidate:
```
cd mobile
flutter test test/features/auth/login_screen_test.dart
flutter test test/features/pairing/waiting_screen_design_fidelity_test.dart
flutter test test/features/pairing/joincode_screen_design_test.dart
```
(paths approximate; bug-fixer to confirm exact file locations via
query-first reading, and to locate the exact test(s) — if any — covering the
Love Pet eyebrow muted-alpha drift, which finding I-5 states was previously
uncovered by any assertion.)

Failure anchors:
- Stack trace: N/A (design-fidelity assertion mismatch)
- Failing test:
  - `login_screen_test.dart:91`
  - `waiting_screen_design_fidelity_test.dart:238`
  - `joincode_screen_design_test.dart:107`
- Uncovered (no assertion yet, per I-5): Love Pet eyebrow muted-alpha
  `0.65` → `0.575` drift
- Route/endpoint/component/job: caption typography token (shared);
  `mobile/lib/design_system` (shared token surface, 14 commits / 14 stories)
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
  REQ-002 story review gates (not a regression). That per-story acceptance is
  superseded at requirement level: Iris-QC's requirement integration review
  (`Outcome: PATCH_REQUIRED`, finding I-5) treats the RED `flutter test` suite
  as the primary proof gate under SKILL 12c, so this bug is now blocking
  REQ-002 DONE, not a low-urgency follow-up.

## Blockers

- N/A
