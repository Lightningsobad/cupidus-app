# Bug Master: BUG-20260927-001 `context_content_gate_test.dart` BR-16 Zodiac Pack-Phrase Leak

Status: PENDING
Severity: non-blocking to REQ-016 requirement-level delivery (pre-existing,
confirmed byte-identical at the surfacing run's own BaseHead, out of that
run's write scope); blocking to the
`mobile/test/features/context_notebook/context_content_gate_test.dart`
combined-suite gate whenever a session executes it
Source: Alex-Mobile-Dev (mobile-dev), REQ-016 requirement-level `Mode:
mobile-implementation` run (RunId
`RUN-REQ-016_solo_stage1_relationship_assistant-NONE-mobile-dev-fm1wiring`),
reported as `BLOCKER: PREEXISTING_TEST_FAILURE`
Created: 2026-09-27
Linked Requirement: REQ-016_solo_stage1_relationship_assistant
Linked Story: surfaced by the F-M1 requirement-level tab-wiring run (`Story:
NONE`); root cause is `mobile/lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart`,
last touched by STORY-011 P2 (commit `27700367`) — not this run's write scope

## Report

Observed behavior:
`flutter test test/features/context_notebook/context_content_gate_test.dart --no-pub --reporter compact`
fails its BR-16 case at line 159: `Expected: empty; Actual:
['lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart contains
"Ca phe sang"']`. The gate scans shipped source for banned literal pack
phrases; a doc comment in `zodiac_shell_resolver.dart` (line 157 at the
surfacing BaseHead) contains one.

Expected behavior:
The gate should pass, or the doc comment should not contain a banned pack
phrase literal (fix is either a wording change in the STORY-011-owned file,
or a gate-scope adjustment to exclude doc comments — bug-fixer to decide
after diagnosis).

Reproduction steps or command:
```
cd mobile && flutter test test/features/context_notebook/context_content_gate_test.dart --no-pub --reporter compact
```

Proof this is pre-existing, not introduced by the surfacing run:
- Reporting run's worktree HEAD == its own declared BaseHead
  (`9aadd52f536c96d2d5258f841873f3a7469ff72e`, the REQ-016 integration branch
  after the Tech Lead's F-M1 architecture-decision commit).
- `git diff --quiet 9aadd52f -- mobile/lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart`
  and the same for `context_content_gate_test.dart` both exit 0 — both files
  are byte-identical to BaseHead; the reporting run's own diff touched only
  `home_screen.dart` and `activity_card_hub_view_test.dart`.
- The banned phrase is present at `zodiac_shell_resolver.dart:157` already at
  BaseHead, in a doc comment. `git log` attributes the file's last change to
  commit `27700367` (STORY-011 P2), well before this BaseHead.

Why not fixed inline by the reporting agent:
`zodiac_shell_resolver.dart` and `context_content_gate_test.dart` are outside
the F-M1 wiring run's declared WriteScope
(`mobile/lib/features/home/presentation/home_screen.dart`,
`mobile/test/features/activity_cards/`), and the root cause belongs to
STORY-011, not to this requirement-level fix.

## Artifacts

- [ ] Diagnosis (Bug Fixer)
- [ ] Fix Evidence (Bug Fixer)
- [ ] Review (Reviewer)

## Routing Notes

- Current owner: scrum-master
- Next role: bug-fixer, when queued via `fix bugs` (not required to unblock
  the REQ-016 F-M1 fix or the requirement's `DONE` gate — see Resolution
  below)
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md` (not created; needs bug-fixer triage — likely a
  wording change to the doc comment, or a gate-scope adjustment to skip doc
  comments)
- Fix Evidence: `fix-evidence.md` (not created)
- Review Report: `review/review-report.md` (not created)
- Checkpoint: tracked in
  `data/requirements/REQ-016_solo_stage1_relationship_assistant/scrum-master-checkpoint.md`
- Origin: REQ-016 requirement-level F-M1 tab-wiring run
  (`data/runtime/parallel-runs/RUN-REQ-016_solo_stage1_relationship_assistant-NONE-mobile-dev-fm1wiring.json`)

## Resolution (not yet started — non-blocking to REQ-016 delivery)

- The F-M1 fix's own required tests
  (`test/features/context_notebook/` per file) confirm this is the only
  failure in that directory (61 passing, 1 pre-existing failure); the
  requirement-integration review scoped to F-M1 may cite this bug id as the
  tracked, pre-existing, out-of-scope justification instead of re-diagnosing
  it.
- No `bug-fixer` dispatch is required to unblock REQ-016 delivery or the
  `DONE` gate. Queue this bug through `fix bugs` when repo-wide test health
  work is prioritized.

## Blockers

- N/A
