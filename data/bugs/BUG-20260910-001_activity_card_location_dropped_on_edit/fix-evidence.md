# Fix Evidence: BUG-20260910-001

Backfilled by Scrum Master. The fix itself was implemented and verified by
Alex-Mobile-Dev / Iris-QC as part of REQ-016/STORY-002's `PATCH_REQUIRED`
patch cycle (round-1 finding F-3), not the ordinary `fix-bugs` queue. This
document transcribes that already-completed, already-verified evidence into
the bug's own canonical path.

## Patch

Commit `b99d3ac` on branch
`codex/REQ-016_solo_stage1_relationship_assistant-STORY-002_invite_message_composer`.
`activity_card_detail_cubit.dart`: added an `editLocation` mutator; `_withEdits`
now reads `location: clearLocation ? null : location ?? card.location`,
matching the carry-forward shape of every sibling nullable column;
`editLocation` maps an emptied field to `clearLocation: true` rather than an
empty string. Regression test added in
`activity_card_detail_cubit_test.dart` covering 4 reachable paths (unrelated
`_persist`-backed edit, unrelated `_writeStatus` path, explicit
`editLocation` set, explicit `editLocation` clear).

## Original Failure Recheck Gate

Verified independently, twice, by real source-level reviewer inspection
against the exact reported failure modality (an unrelated edit silently
dropping a previously-saved `location`):

1. Slice C scoped-slice review (`review/slice-C-review.md`), STORY-002 round
   2: confirmed `activity_card_detail_cubit.dart:496` carries the fix, 4
   reachable paths have regression tests.
2. Final-synthesis review (`review/review-report.md` in STORY-002's own
   directory, F-3, `Outcome: DEFERRED_ONLY`): re-verified against source a
   second time independently rather than trusted on report, same citation.

Same modality as original: YES — the original failure was a silent
full-snapshot `location` overwrite triggered by any unrelated
`_persist`/`_writeStatus`-backed cubit mutation; the regression tests exercise
that exact call path (cubit method call -> emitted state -> repository write
contract), not a narrower unit-only or compile-only proxy.

## Merge State

Merged into `codex/REQ-016_solo_stage1_relationship_assistant-integration` at
`844487bc2c5c29609c531575c43af74b3fdf2502` as part of
STORY-002_invite_message_composer (`story_master.md Status: DONE`).

BUG_FIX_COMPLETE: YES
