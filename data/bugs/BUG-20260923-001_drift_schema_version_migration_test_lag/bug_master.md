# Bug Master: BUG-20260923-001 Drift `schemaVersion` Migration Test Lag (v9, 11 tests)

Status: PENDING
Severity: non-blocking to REQ-016 stories (pre-existing, confirmed identical at
the surfacing story's own BaseHead, out of that story's write scope); blocking
to the `mobile/test/core/database/` combined-suite build-evidence gate
whenever a mobile-dev run's session executes it
Source: Alex-Mobile-Dev (mobile-dev), REQ-016/STORY-005 `Mode:
mobile-implementation` run (phase P7), reported as `BLOCKER:
PREEXISTING_TEST_FAILURE`
Created: 2026-09-23
Linked Requirement: REQ-016_solo_stage1_relationship_assistant
Linked Story: surfaced by REQ-016/STORY-005_conversation_starters (Phase P7);
caused by three unrelated sibling stories' merges, none of which is P7's own
scope

## Report

Observed behavior:
`flutter test test/core/database/` exits 1 with `+93 -11` (11 failures). All
11 assert an old landed `schemaVersion` (`7` or `8`) while the live value on
`mobile/lib/core/database/cupid_database.dart` is now `9`. Reproduces
identically on a detached, unmodified checkout of the surfacing story's own
BaseHead `9ab00f489dfff89137cbf6d695a72718e9144c96` — confirmed by the
reporting agent via `git worktree add --detach /tmp/p7-basehead-proof
9ab00f48…`, `pub get` + `gen-l10n`, re-run, same `+93 -11` with the same 11
test names.

Failure anchors (11 tests, 3 files, all outside STORY-005 P7's WriteScope):
- `mobile/test/core/database/chapter_closure_migration_test.dart` — e.g. line
  119, `Expected: <7> Actual: <9>` ("lands on v7")
- `mobile/test/core/database/calendar_event_state_migration_test.dart` —
  same pattern ("lands on v8")
- `mobile/test/core/database/relationship_labels_migration_test.dart` —
  same pattern

Expected behavior:
Migration tests should assert the current landed `schemaVersion` (`9`), or a
version range that tolerates additive later migrations, not a version frozen
at the time each test was authored.

Reproduction steps or command:
```
cd mobile && flutter test test/core/database/
```

Proof this is pre-existing, not introduced by the surfacing story:
- Detached checkout of REQ-016/STORY-005 BaseHead
  `9ab00f489dfff89137cbf6d695a72718e9144c96`; all 11 failures reproduce there
  with identical assertion text and test names.
- `git diff 9ab00f48 --stat -- mobile/lib/core/database/` from the STORY-005
  worktree returns empty — STORY-005 P7 never touched Drift/`cupid_database.dart`
  (explicitly forbidden by its own phase file §1C).
- Root cause: `schemaVersion` climbed to `9` across three independent sibling
  merges that each bumped it by one and never touched these three migration
  tests' frozen version assertions:
  - STORY-009 (`84a3c4b4`)
  - STORY-010 (`32f6a085`)
  - STORY-013 (`ba18b8bc`)

Why not fixed inline by the reporting agent:
The three affected test files and `cupid_database.dart` are outside
STORY-005/P7's declared WriteScope, and P7's own phase file explicitly bans
touching Drift/`schemaVersion` in this phase (§1C) — fixing it inline would
both blow scope and violate the phase's own written constraint.

## Artifacts

- [ ] Diagnosis (Bug Fixer)
- [ ] Fix Evidence (Bug Fixer)
- [ ] Review (Reviewer)

## Routing Notes

- Current owner: scrum-master
- Next role: bug-fixer, when queued via `fix bugs` (not required to unblock
  REQ-016 story delivery — see Resolution below)
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md` (not created; needs bug-fixer triage — likely one
  mechanical fix: update the 3 frozen `schemaVersion` assertions to `9`, or
  make them tolerant of later additive migrations)
- Fix Evidence: `fix-evidence.md` (not created)
- Review Report: `review/review-report.md` (not created)
- Checkpoint: tracked in
  `data/requirements/REQ-016_solo_stage1_relationship_assistant/scrum-master-checkpoint.md`
- Origin: REQ-016/STORY-005_conversation_starters mobile-dev run, phase P7
  (`data/runtime/parallel-runs/RUN-REQ-016_solo_stage1_relationship_assistant-STORY-005_conversation_starters-mobile-dev.json`)

## Resolution (not yet started — non-blocking to REQ-016 delivery)

- REQ-016 story branches that touch `mobile/lib/core/database/` or run the
  combined `test/core/database/` suite may cite this bug id as the tracked,
  pre-existing, out-of-scope justification for the 11 known-red assertions,
  and should verify their own regression via SCOPED/targeted test commands
  instead of the combined-directory run (per the repo's known
  build-evidence-gate session lock: a red combined-test run can lock a
  session's Stop gate even when the red tests are proven pre-existing and out
  of scope). Do not re-run `flutter test test/core/database/` from inside a
  story worktree once this bug is on record for that story's evidence file —
  use the exact per-file commands for the files actually in WriteScope.
- No `bug-fixer` dispatch is required to unblock REQ-016 delivery. Queue this
  bug through `fix bugs` when repo-wide test health work is prioritized.

## Blockers

- N/A
