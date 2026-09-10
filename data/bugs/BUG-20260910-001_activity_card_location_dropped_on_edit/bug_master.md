# Bug Master: BUG-20260910-001 Activity Card `location` Silently Dropped On Any Detail-Screen Edit

Status: DONE
Severity: HIGH — silent, permanent data loss on a persisted user field, not
just a UI/display defect. Not blocking to REQ-016/STORY-002 delivery (the
composer sheet itself only reads `location`, it does not write it), but is
live in `main`-bound STORY-001 code today.
Source: out-of-scope finding reported by Alex-Mobile-Dev-2 (mobile-dev) inside
its REQ-016/STORY-002 Phase P5 completion report; independently confirmed by
Scrum Master via direct code inspection (not fixed by, and not filed solely on
the trust of, the reporting agent).
Created: 2026-09-10
Linked Requirement: REQ-016_solo_stage1_relationship_assistant (defect lives
in STORY-001-owned code, surfaced while validating STORY-002)
Linked Story: root cause in STORY-001_activity_card_hub (already DONE,
merged); surfaced during STORY-002_invite_message_composer Phase P5 review

## Report

Observed code defect (confirmed by direct read, not inferred from the report):

`mobile/lib/features/activity_cards/presentation/activity_card_detail_cubit.dart`,
method `_withEdits` (lines 418-492), constructs the returned `ActivityCard`
without ever passing a `location:` argument to the constructor. Every other
persisted, nullable field (`note`, `sourceLink`, `noteKeywords`,
`linkSourceLabel`, `linkSavedAt`, `timeOfDaySlot`, etc.) is carried forward
with the `clearX ? null : x ?? card.location`-shaped pattern; `location` has
no such line and no `clearLocation`/`location` parameter at all.

`ActivityCard.location` (`domain/activity_card.dart` line 157) is a plain
optional field with no default, so omitting it resolves to `null`
unconditionally, regardless of what `state.card.location` was.

Every call path through `_persist` (`editTitle`, `editNote`, `editNoteKeywords`,
`editSourceLink`, `editLinkSourceLabel`, `editActivityType`, `editPriceVnd`,
`editDistanceKm`, `editDurationMinutes`, `editTimeOfDaySlot`,
`editNeedsBooking`, `editIndoorOutdoor`, `editScheduledOn`, `toggleInvited`,
`toggleReplyState`, and `scheduleDate`) builds its write via `_withEdits`, so
`next.location` is always `null`. `_persist` then calls
`_repository.updateCardDetails(next.id, ActivityCardEdit.from(next))`, and
`ActivityCardEdit.from` copies `location: card.location` (i.e. `null`)
straight through. The repository impl
(`activity_card_repository_impl.dart` `updateCardDetails`) writes
`location: Value(edit.location)` as a **full-snapshot column** — per that
method's own docstring ("a `null` here is an instruction to clear that
column, never leave it alone") — so this is an explicit `UPDATE ... SET
location = NULL`, not a no-op.

Net effect: any card that has a saved `location` loses it permanently the
next time the user edits *any other field on the same card* — title, note,
price, distance, invited toggle, status change (`_writeStatus` ->
`_emitCard` -> `_withEdits` has the identical gap), anything. There is
currently no `editLocation` method on this cubit at all, so a user has no way
to notice or re-enter the value through this screen once it is gone.

Expected behavior: `_withEdits` should carry `location` forward exactly like
every other optional field (`location: card.location` at minimum, or
`clearLocation ? null : location ?? card.location` if/when an explicit
`editLocation` mutator is added), so an edit to an unrelated field never
touches `location`.

Reproduction steps (code-level, confirmed by direct read — no test currently
pins this, see below):
1. A card has `location` set (e.g. by AC-4's mad-libs `place` variable path).
2. Call any `_persist`-backed mutator on `ActivityCardDetailCubit` for that
   card, e.g. `editTitle('new title')`.
3. `next = _withEdits(title: 'new title')` — `next.location` is `null`
   because `_withEdits` never reads `card.location`.
4. `_repository.updateCardDetails(next.id, ActivityCardEdit.from(next))`
   writes `location: Value(null)` to the `activity_cards` table.
5. The previously-saved `location` value is gone from both the emitted state
   and the database row.

Proof this is pre-existing in already-merged code, not something introduced
by STORY-002: `activity_card_detail_cubit.dart` and `_withEdits` are
STORY-001-owned files (schema v5's `location` column itself, and the
`updateCardDetails`/`ActivityCardEdit.location` wiring, were added later by
STORY-002 Phase P3, per the REQ-016 checkpoint — `_withEdits` was never
updated at that time to also carry the new column forward). STORY-002 does
not call any of these mutators; it only reads `location` (as the AC-4 `place`
mad-libs variable) through the read path, which is unaffected.

No existing test currently pins or catches this: there is no
`activity_card_detail_cubit_test.dart` in the STORY-002 worktree, and no
other located test asserts that `location` survives a `_persist`-backed edit.

## Artifacts

- [x] Diagnosis (Bug Fixer) — `diagnosis.md` (backfilled by Scrum Master from
  already-established facts; fix landed via STORY-002 patch cycle)
- [x] Fix Evidence (Bug Fixer) — `fix-evidence.md` (backfilled; fix
  independently verified twice by real Reviewer inspection, see file)
- [x] Review (Reviewer) — `review/review-report.md`, Outcome: DEFERRED_ONLY
  (Iris-QC, 2026-09-10; 0 blocking, 4 deferred, 1 dismissed)

## Routing Notes

- Current owner: scrum-master
- Next role: none — bug is DONE and closed
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md` (backfilled by Scrum Master)
- Fix Evidence: `fix-evidence.md` (backfilled by Scrum Master)
- Review Report: `review/review-report.md`, Outcome: DEFERRED_ONLY
- Checkpoint: tracked in
  `data/requirements/REQ-016_solo_stage1_relationship_assistant/scrum-master-checkpoint.md`
- Origin: out-of-scope finding in Alex-Mobile-Dev-2's REQ-016/STORY-002 Phase
  P5 completion report; independently reproduced by direct read of
  `activity_card_detail_cubit.dart` (`_withEdits`, lines 418-492),
  `activity_card.dart` (lines 94-162), and
  `activity_card_repository_impl.dart` (`updateCardDetails`, lines 111-139)
  in the STORY-002 worktree at commit `ddd027e` (P4 HEAD).
- Not blocking to REQ-016/STORY-002 delivery: the composer sheet only reads
  `location`; does not need this fix to proceed to P6 or to reach DONE.

## Resolution (not yet started)

- Smallest safe fix: add `location`/`clearLocation` carry-forward to
  `_withEdits` (mirroring the existing pattern for `note`/`sourceLink`/etc.),
  and add a regression test asserting `location` survives an unrelated
  `_persist`-backed edit (e.g. `editTitle`) and an unrelated `_writeStatus`
  path (e.g. `changeStatus`).
- **Reclassified 2026-09-10 by Iris-QC (STORY-002 full-story-review round-1,
  finding F-3):** NOT pre-existing STORY-001 code as originally filed. The
  `location` column did not exist until this story's Phase P3 (schema v5);
  STORY-001 could not have dropped a column that did not exist. The story
  created the gap by adding a full-snapshot field without updating the one
  carry-forward site. It also blocks STORY-002's own AC-1 (`{place}` mad-libs
  fill). Superseded: **being fixed inline as part of REQ-016/STORY-002's
  PATCH_REQUIRED patch cycle** (write scope widened to
  `activity_card_detail_cubit.dart` by Scrum Master), not through the ordinary
  `fix bugs` queue. Will close this bug once that patch lands and passes
  review, citing the story patch commit.

- **Closed 2026-09-10 by Scrum Master.** Fixed inline in
  REQ-016/STORY-002's patch round 1, commit `b99d3ac` (story branch), verified
  independently against source before commit (new `editLocation` mutator,
  `_withEdits`/`_persist` carry `location`/`clearLocation` with the same
  `clearLocation ? null : location ?? card.location` shape as every sibling
  nullable column; 4 reachable paths covered by
  `activity_card_detail_cubit_test.dart`). Re-verified independently a second
  time in the STORY-002 final-synthesis review (`review/review-report.md`,
  F-3, `Outcome: DEFERRED_ONLY`). Merged into
  `codex/REQ-016_solo_stage1_relationship_assistant-integration` at
  `844487bc2c5c29609c531575c43af74b3fdf2502` as part of STORY-002
  (`story_master.md Status: DONE`). No separate bug-fixer dispatch was needed.

## Blockers

- N/A
