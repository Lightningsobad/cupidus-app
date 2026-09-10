# Diagnosis: BUG-20260910-001

Backfilled by Scrum Master from already-established facts (this bug was fixed
inline through REQ-016/STORY-002's patch cycle, not the ordinary `fix-bugs`
queue, so it never produced these canonical artifacts at the time). No new
diagnostic judgment here — this transcribes `bug_master.md`'s own "Report"
section, written before the fix existed.

## Root Cause

`mobile/lib/features/activity_cards/presentation/activity_card_detail_cubit.dart`,
method `_withEdits` (pre-fix lines 418-492), constructed the returned
`ActivityCard` without ever passing a `location:` argument. Every other
persisted nullable field used the `clearX ? null : x ?? card.location`-shaped
carry-forward pattern; `location` had no such line and no `clearLocation`
parameter, so it silently resolved to `null` on every edit through any
`_persist`-backed mutator (`editTitle`, `editNote`, ..., `toggleInvited`,
`scheduleDate`) and any `_writeStatus`-backed path. The repository's
`updateCardDetails` treats `location` as a full-snapshot column, so this was
an explicit `UPDATE ... SET location = NULL`, not a no-op.

## Pre-Fix Reproduction Gate

No automated test existed before the fix (`bug_master.md` line 83-85: "No
existing test currently pins or catches this"). Reproduction is via direct
code trace, confirmed independently by two parties before any fix landed:
Alex-Mobile-Dev (originating report, REQ-016/STORY-002 Phase P5) and Scrum
Master (direct read of `_withEdits`, `ActivityCard`, and
`activity_card_repository_impl.dart` at commit `ddd027e`, the pre-patch P4
HEAD). Trace: `_withEdits(title: 'x')` -> `next.location == null`
unconditionally (constructor arg omitted) -> `_persist` ->
`_repository.updateCardDetails(next.id, ActivityCardEdit.from(next))` ->
`ActivityCardEdit.from` copies `location: null` straight through ->
repository writes `location: Value(null)` as an explicit clear. Reproducible
statically on any card with a saved `location` and any unrelated edit call;
not gated behind a flag, race, or environment condition.

## Classification

Reclassified 2026-09-10 by Iris-QC (STORY-002 round-1 full-story-review,
finding F-3): story-caused, not pre-existing STORY-001 code — the `location`
column did not exist until STORY-002 Phase P3 (schema v5); `_withEdits` was
never updated at that time to carry the new column forward. See
`bug_master.md` "Resolution" section for the full reclassification note.

## Fix Scope

Smallest safe fix (matches `bug_master.md`'s own "Resolution" plan): add an
`editLocation` mutator and `location`/`clearLocation` carry-forward to
`_withEdits`, mirroring the existing pattern for every sibling nullable
field, plus a regression test asserting `location` survives an unrelated
edit. See `fix-evidence.md` for the actual patch record.
