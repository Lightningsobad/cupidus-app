---
story_status_recommendation: "DONE"
implementation_status_recommendation: "KEEP_CHECKED"
reviewed_at: 2026-09-10
reviewed_by: Reviewer
---

# Review Report: BUG-20260910-001 Activity Card `location` Silently Dropped On Any Detail-Screen Edit

Outcome: DEFERRED_ONLY

## Reviewed Inputs

- Review gate: `bugfix-review`
- Scope Gate: `data/bugs/BUG-20260910-001_activity_card_location_dropped_on_edit/review/scope-gate.md`
- Requirements: REQ-016_solo_stage1_relationship_assistant, STORY-002 AC-4
  (`{place}` mad-libs variable) as the AC the defect blocked.
- Bug Report: `data/bugs/BUG-20260910-001_activity_card_location_dropped_on_edit/bug_master.md`
- Diagnosis: `data/bugs/BUG-20260910-001_activity_card_location_dropped_on_edit/diagnosis.md`
  (read from the control checkout — see D-4)
- Fix Evidence: `data/bugs/BUG-20260910-001_activity_card_location_dropped_on_edit/fix-evidence.md`
  (read from the control checkout — see D-4)
- UX: `N/A`
- Architecture: `N/A`
- Coding Plan: `N/A`
- Test Results: `mobile/test/features/activity_cards/activity_card_detail_cubit_test.dart`
  group `BUG-20260910-001 · location survives an unrelated edit` (4 tests), as
  recorded in STORY-002's own review cycle.
- Previous review findings: STORY-002 round-2 `review/slice-C-review.md` §3 F-3;
  STORY-002 final-synthesis `review/review-report.md` F-3.

## Reviewed Scope

- Story complexity: `N/A`
- Bug status: fix merged; `bug_master.md` already carries `Status: DONE` (see D-3)
- Code scope reviewed: 3 files —
  `mobile/lib/features/activity_cards/presentation/activity_card_detail_cubit.dart`
  (`editLocation` :212-213, `_persist` :341-342/:377-378, `_emitCard` :409-426,
  `_withEdits` :496),
  `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart`
  (`normalizeLocation` :71-77, `_commitLocation` :272-281),
  `mobile/test/features/activity_cards/activity_card_detail_cubit_test.dart` (:70-136).
- Evidence reviewed: the three bug artifacts plus the two cited STORY-002 review
  sections, read query-first by `F-3` / `location`.
- Risk surfaces reviewed: persisted-data integrity on the full-snapshot
  `activity_cards.location` column; the `_persist` write path and the
  `_writeStatus` -> `_emitCard` -> `_withEdits` status path.
- Critical gates reviewed: pre-fix reproduction gate, original-failure recheck
  gate, `BUG_FIX_COMPLETE` marker, unapproved-scope check, regression check on
  sibling nullable columns.
- Backend targeted verification gates: `NOT_APPLICABLE`
- Story runtime startup smoke: `NOT_APPLICABLE`
- Frontend targeted verification gates: `NOT_APPLICABLE`
- Frontend discoverability/navigation integration: `NOT_APPLICABLE`
- Requirement frontend visual audit: `NOT_APPLICABLE`
- Mobile targeted verification gates: `PASS` — the regression group exercises the
  cubit-call -> emitted-state -> repository-write-contract path for all four
  reachable `location` routes; no e2e/emulator/signing evidence is required at a
  bugfix gate.
- Mobile discoverability/navigation integration: `NOT_APPLICABLE` — the location
  input's discoverability belongs to STORY-002 AC-4, already gated there.
- Requirement mobile visual audit: `NOT_APPLICABLE` — deferred to REQ-016
  integration review; this bug has no rendered surface of its own.
- Story artifacts reviewed: STORY-002 `slice-C-review.md`, `review-report.md`
  (F-3 sections only). STORY-002 was **not** re-reviewed as a whole.
- Bug artifacts reviewed: `bug_master.md`, `diagnosis.md`, `fix-evidence.md`
- OQ context reviewed: none open against this bug.

## Outcome Summary

- Review outcome: DEFERRED_ONLY
- Rationale: the fix is correct, minimal, and matches the codebase's own
  carry-forward contract character-for-character; the reported failure modality
  is pinned by four regression tests on the exact call path; the reproduction
  gate, recheck gate, and `BUG_FIX_COMPLETE: YES` marker are all present and, on
  independent Git and source verification, substantively accurate. No product
  scope was added beyond STORY-002's own approved AC-4 surface. Four non-blocking
  items are recorded: one provenance overstatement in a backfilled citation, one
  stale test comment already noted upstream, one workflow-ordering deviation, and
  one artifact-location split.
- Blocking findings: 0
- Deferred findings: 4
- Dismissed observations: 1

## Traceability Summary

- Requirements: STORY-002 AC-4 (`{place}`) — the AC the defect blocked; the fix
  restores it.
- Bug report: `bug_master.md` `## Report` reproduction steps 1-5 map one-to-one
  onto the verified pre-fix code state (see Risk Surface Gate Summary).
- Diagnosis: `## Root Cause` and `## Pre-Fix Reproduction Gate` verified sound.
- Open Questions: none.
- UX: `N/A`
- Architecture: `N/A`
- Testing evidence: `activity_card_detail_cubit_test.dart:70-136`.

## Risk Surface Gate Summary

| Risk Surface | Source Of Truth | Critical Gate | Result | Notes |
|--------------|-----------------|---------------|--------|-------|
| Pre-fix defect really existed | `git log -S` on the carry-forward string | reproduction gate is not retro-fiction | PASS | `location: clearLocation ? null : location ?? card.location` is introduced by exactly one commit, `b99d3ac` (the patch). It was absent before, so the pre-fix trace in `diagnosis.md` is correct. |
| Defect attribution | `git log -S "location"` on `domain/activity_card.dart` | reclassification is accurate | PASS | The `location` field enters at `f90f1e6` "feat(STORY-002): P3 schema v5 (location column ...)". STORY-001 could not have dropped a column that did not exist, so Iris-QC's F-3 reclassification (story-caused, not pre-existing) is confirmed independently. |
| `_persist` write path | `activity_card_detail_cubit.dart` sibling pattern | carry-forward matches sibling nullable columns | PASS | `:496` `location: clearLocation ? null : location ?? card.location` is the identical shape to `note :478`, `sourceLink :479`, `noteKeywords :489`, `linkSavedAt :495`. Threaded through `_persist` at `:341-342` and `:377-378`. |
| `_writeStatus` status path | `_emitCard :409-426` | status changes do not clear `location` | PASS | `_emitCard` passes no `location`/`clearLocation`, so the defaults resolve to `null ?? card.location` — the saved place is carried. Pinned by the `changeStatus(done)` test at `:89-104`. |
| Empty-input boundary | `normalizeLocation :71-77` | emptied field clears, `''` never stored | PASS | Blank/whitespace trims to `null`; `_commitLocation :272-281` feeds that into `editLocation`, which sets `clearLocation: location == null`. The `''` -> stored-empty-string hazard the full-snapshot column would otherwise create is closed. |
| Regression on sibling fields | `_withEdits` signature `:341-342`, `:457-458` | additive change, no existing caller behavior altered | PASS | Both new parameters are optional with `null`/`false` defaults, so every pre-existing call site is unchanged. |
| Recheck-gate modality | `fix-evidence.md ## Original Failure Recheck Gate` | verified against the reported modality, not a narrower proxy | PASS | The reported modality is "an unrelated edit silently drops a saved `location`". Test `:75-87` calls `editTitle` on a card with a saved place and asserts both the repository snapshot *and* the emitted state still hold it — the full cubit -> repository-contract path, not a compile-only or field-only proxy. |
| Citation accuracy | `slice-C-review.md :66-80`, `review-report.md :64-70` | cited sections say what `fix-evidence.md` claims | PARTIAL | Citation 1 is exact (`:496`, sibling shape, four reachable paths, `clearLocation` over `''`). Citation 2 exists with `Outcome: DEFERRED_ONLY` at `:136` but describes itself as reporting Slice C's verification, not a second independent source read — see D-1. |
| Merge state | `git branch --contains`, `merge-base --is-ancestor` | fix is actually on the integration branch | PASS | `b99d3ac` is contained in `codex/REQ-016_solo_stage1_relationship_assistant-integration`; merge commit `844487b` exists and is an ancestor of integration HEAD. |
| Completion marker | `fix-evidence.md :47` | ends `BUG_FIX_COMPLETE: YES` | PASS | Present as the final line, unformatted. |

## Blocking Findings

None.

## Deferred Findings

- **D-1 — `fix-evidence.md` overstates the independence of its second
  citation.** The `## Original Failure Recheck Gate` says the fix was "Verified
  independently, twice, by real source-level reviewer inspection", and lists the
  STORY-002 final-synthesis review as the second independent check that
  "re-verified against source a second time independently rather than trusted on
  report". The cited section itself
  (`STORY-002_invite_message_composer/review/review-report.md:64-70`) reads
  "Verified in Slice C with direct source evidence" — it attributes the source
  verification to Slice C rather than claiming its own. The provenance claim is
  therefore one count stronger than the artifact it cites supports. Non-blocking
  because the substantive claim is unaffected: the fix *is* verified at source
  against the exact reported modality, by Slice C and independently again by
  this review (source read plus the two Git pickaxe checks above). Suggested
  wording: "verified at source in Slice C, carried forward unchallenged by the
  final-synthesis review".
- **D-2 — stale comment in this bug's own regression test group.**
  `activity_card_detail_cubit_test.dart:73-74` says "These three cases are the
  paths that reach `_withEdits`" and is followed by four tests. The tests are
  right, the sentence is stale. Already filed upstream as `N-C5` in
  `slice-C-review.md:181-185` and still present in the merged code. Cosmetic;
  fold into any future touch of this file.
- **D-3 — the bug was marked `DONE` before its own review outcome existed.**
  `bug_master.md:3` already reads `Status: DONE`, and its `## Artifacts` block
  (`:88-91`) still has all three checkboxes — Diagnosis, Fix Evidence, Review —
  unchecked, while `## Routing Notes` (`:96-100`) still says "Next role:
  bug-fixer" and describes all three artifacts as "not yet created". Per
  `AGENTS.md`, a bug may be marked `DONE` only after a bugfix review records
  `CLEAN` or `DEFERRED_ONLY`. That condition is satisfied as of this report, so
  the deviation resolves benignly and no rollback is warranted — but the state
  file is now internally contradictory and should be reconciled. Reviewer does
  not edit state files; see Implementation Action Items.
- **D-4 — the bug's artifact set is split across two checkouts.**
  `diagnosis.md` and `fix-evidence.md` exist only in the control checkout at
  `/Users/alantravala/workspace/snapsofts/cupid-apps/data/bugs/BUG-20260910-001_activity_card_location_dropped_on_edit/`;
  the integration worktree holds only `bug_master.md`. The handoff declared all
  three as required inputs under `<Worktree>`, so they were read read-only from
  the control checkout (disclosed in `scope-gate.md`). This review's two output
  files were written to the worktree as instructed, which means the bug folder
  is currently incomplete in *both* locations. Non-blocking to the fix itself.

## Dismissed Observations

- 1 dismissed: `_commitLocation:277-279` returns early when the normalized value
  equals the current `state.card.location`, skipping the write. This looked at
  first like it could suppress a needed repair write on a card whose `location`
  was already nulled by the old defect, but it cannot — the guard compares
  against in-memory state, and any *different* value (including `null` -> a typed
  place) still writes. Not actionable.

## Implementation Action Items

None required for the fix. Two artifact-hygiene items for `scrum-master`, which
owns these files:

- `[scrum-master] data/bugs/BUG-20260910-001_.../bug_master.md`: reconcile
  `## Artifacts` (check Diagnosis, Fix Evidence, Review) and `## Routing Notes`
  (current owner, next role, and the three "not yet created" lines) with the now
  actual state, so the file stops contradicting its own `Status: DONE` (D-3).
- `[scrum-master] data/bugs/BUG-20260910-001_.../`: converge the artifact set on
  one location — either copy `diagnosis.md`/`fix-evidence.md` into the
  integration worktree, or copy `review/scope-gate.md`/`review/review-report.md`
  back into the control checkout — so the bug folder is complete wherever it is
  read (D-4). Optionally apply the D-1 wording correction at the same time.

## Workflow State Recommendation

- Story status: `N/A`
- Bug status: `DONE`
- `Implementation (Development)`: `KEEP_CHECKED`
- `Review (Reviewer)`: `CHECK`
- Next step: `scrum-master` records this `Outcome: DEFERRED_ONLY` against
  BUG-20260910-001, checks the three `## Artifacts` boxes, updates
  `data/bugs/master_bugs_list.md`, and clears the two hygiene action items
  above. No code change is required and no re-review is needed. D-1 and D-2
  carry forward as notes only.
- State update owner: `scrum-master` only. Reviewer does not edit story or
  requirement status files.
