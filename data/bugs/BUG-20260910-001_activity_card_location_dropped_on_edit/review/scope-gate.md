# Review Scope Gate: BUG-20260910-001 Activity Card `location` Silently Dropped On Any Detail-Screen Edit

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

## Identity

- Review type: `bugfix-review`
- Review report path: `data/bugs/BUG-20260910-001_activity_card_location_dropped_on_edit/review/review-report.md` (written inside the integration worktree, per handoff `Worktree`)
- Scope gate path: `data/bugs/BUG-20260910-001_activity_card_location_dropped_on_edit/review/scope-gate.md` (same worktree)

## Scope Decision

- Scope status: `PROCEED`
- Why this review is within budget or why it must stop: the fix is a single-file
  source change (`activity_card_detail_cubit.dart`) plus one test file
  (`activity_card_detail_cubit_test.dart`) — 2 implementation files, far under
  the 12-file budget. Three bug artifacts, all under 8 KB. Two STORY-002 review
  artifacts are read query-first ("F-3", "location") only to confirm the two
  cited independent verifications actually exist and say what `fix-evidence.md`
  claims; STORY-002 is explicitly NOT re-reviewed as a whole.
- Current story or bug status: `bug_master.md` already carries `Status: DONE`
  with all three `## Artifacts` checkboxes unchecked. The fix is merged into
  `codex/REQ-016_solo_stage1_relationship_assistant-integration` at
  `844487bc2c5c29609c531575c43af74b3fdf2502` via STORY-002. This review files the
  bug's own canonical `Outcome:`, which the DONE status was set ahead of.

## Governing Inputs

- Primary artifacts: `bug_master.md`, `diagnosis.md`, `fix-evidence.md` for
  BUG-20260910-001.
- Existing review findings: STORY-002 round-1 `review-report.md` finding F-3
  (which reclassified this bug), STORY-002 round-2 `slice-C-review.md`, STORY-002
  final-synthesis `review-report.md` F-3 (`Outcome: DEFERRED_ONLY`).
- Test evidence: `activity_card_detail_cubit_test.dart` regression cases for the
  4 reachable `location` paths, as cited by `fix-evidence.md`.
- Extra artifacts required beyond the default minimum: none.

## Source/Test Files In Scope

- `mobile/lib/features/activity_cards/presentation/activity_card_detail_cubit.dart`
- `mobile/test/features/activity_cards/presentation/activity_card_detail_cubit_test.dart`

## Evidence Files In Scope

- `data/bugs/BUG-20260910-001_activity_card_location_dropped_on_edit/bug_master.md`
- `data/bugs/BUG-20260910-001_activity_card_location_dropped_on_edit/diagnosis.md`
- `data/bugs/BUG-20260910-001_activity_card_location_dropped_on_edit/fix-evidence.md`
- `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-002_invite_message_composer/review/review-report.md` (query key `F-3` only)
- `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-002_invite_message_composer/review/slice-C-review.md` (query key `location` only)

## Risk Surfaces And Critical Gates

- Touched risk surfaces: persisted-data integrity on a full-snapshot column
  (`activity_cards.location`); cubit write path (`_withEdits` -> `_persist` ->
  `updateCardDetails`) and status-write path (`_writeStatus` -> `_emitCard` ->
  `_withEdits`).
- Source-of-truth artifacts or contracts: `bug_master.md` `## Report` (the exact
  reported failure modality); `updateCardDetails`'s full-snapshot docstring
  contract; the sibling-field carry-forward pattern
  `clearX ? null : x ?? card.x` in `_withEdits`.
- Critical gates to verify: (a) `diagnosis.md` contains
  `## Pre-Fix Reproduction Gate` with a sound trace; (b) `fix-evidence.md`
  `## Original Failure Recheck Gate` proves the fix against the exact reported
  modality, not a narrower proxy, and its two citations resolve to real text in
  the named STORY-002 artifacts; (c) `fix-evidence.md` ends
  `BUG_FIX_COMPLETE: YES`; (d) no unapproved product scope added by the fix;
  (e) no regression on sibling fields.
- Mandatory web Playwright/browser-e2e gate: `NOT_APPLICABLE in ordinary continue`
- Requirement visual audit evidence: `NOT_APPLICABLE` — this bugfix is a cubit
  state/persistence change with no rendered surface of its own; the
  requirement-level mobile visual audit belongs to REQ-016 closure, not to this
  bug gate.
- Mandatory mobile e2e/emulator/signing/store gate: `NOT_APPLICABLE in ordinary continue`
- Requirement mobile visual audit evidence: `NOT_APPLICABLE` (see above; deferred
  to requirement integration review).
- Missing gate evidence or blocker: `N/A`

## Query Keys

- Source symbols: `_withEdits`, `_persist`, `_writeStatus`, `editLocation`,
  `clearLocation`, `location`
- Test names/symbols: `editLocation`, `location`
- Finding ids: `F-3`
- Artifact headings: `## Pre-Fix Reproduction Gate`,
  `## Original Failure Recheck Gate`, `BUG_FIX_COMPLETE`
- Commits: `b99d3ac` (story patch), `844487bc2c5c29609c531575c43af74b3fdf2502`
  (integration merge), `ddd027e` (pre-patch P4 HEAD)

## Phase 2 Approval

- Phase 2 may proceed: `YES`
- If `NO`, final review outcome should be: N/A
- If `NO`, exact blocker or re-scope instruction: N/A

## Scope Deviation Disclosed

- The handoff declared all required inputs under `<Worktree>`. `diagnosis.md`
  and `fix-evidence.md` do not exist in the integration worktree — they exist
  only in the control checkout at
  `/Users/alantravala/workspace/snapsofts/cupid-apps/data/bugs/BUG-20260910-001_activity_card_location_dropped_on_edit/`.
  They were read read-only from there, because that is the only place they
  exist. No control-checkout file was written.
