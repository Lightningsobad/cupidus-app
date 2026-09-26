# Bug Master: BUG-20260923-002 `conversation_starters` Pinned-Enum Assertion Lag (3 tests)

Status: PENDING
Severity: non-blocking to REQ-016 stories (pre-existing, confirmed identical at
the surfacing story's own BaseHead, out of that story's write scope); blocking
to the `mobile/test/features/conversation_starters/` combined-suite
build-evidence gate whenever a mobile-dev run's session executes it
Source: Alex-Mobile-Dev (mobile-dev), REQ-016/STORY-007 `Mode:
mobile-implementation` run (phase P5), reported as `BLOCKER:
PREEXISTING_TEST_FAILURE`
Created: 2026-09-23
Linked Requirement: REQ-016_solo_stage1_relationship_assistant
Linked Story: surfaced by REQ-016/STORY-007_thank_you_and_next_plan (Phase P5);
root cause is REQ-016/STORY-005_conversation_starters's own Design-Ruling-Log
rework phases (P6/P7), same root-cause family as that story's already-recorded
open Reviewer question — not a new/unrelated defect family, and not caused by
P5's own scope

## Report

Observed behavior:
`flutter test test/features/conversation_starters` exits 1 with `+100 ~1 -3`
(3 failures). All 3 lock a shared enum/rule-list in
`mobile/lib/features/activity_cards/domain/activity_card.dart` to a shorter,
frozen shape than what the code currently ships:
- `calendar_event_service_test.dart:390` — locks `ActivityCardOrigin` wire
  values to exactly 5 entries ending at `'conversation_starter'`; shipped code
  already has 6 (ending `'compatibility_lookup'`) at BaseHead, now 7 after P5
  additively appended `nextPlanAfterDate('next_plan_after_date')` per
  `architecture/contract-summary.md` §2/§4 + AC-24.
- `starter_content_gate_test.dart:471` — locks `InvariantRule` to 6 entries;
  shipped code already has 7 (`'assertive_claim'`) at BaseHead.
- `starter_content_gate_test.dart:498` — pairs `InvariantRule[6] =
  'assertive_claim'` against `StarterGateRule[6] = 'missing_question_ending'`;
  same frozen-length mismatch as the two above.

Expected behavior:
These tests should assert the current shipped enum/rule-list shape (or a
tolerant prefix/subset check), not a length frozen at authoring time — the
same category of staleness already flagged as an unresolved "Open Reviewer
question" for STORY-005's P5-P7 rework (`StarterGateRule.assertiveClaim`
addition; `ActivityCardOrigin` append-only assertion changed to a
frozen-prefix `take(5)` comparison), recorded in
`data/requirements/REQ-016_solo_stage1_relationship_assistant/scrum-master-checkpoint.md`.

Reproduction steps or command:
```
cd mobile && flutter test test/features/conversation_starters
```

Proof this is pre-existing, not introduced by the surfacing story:
- `git show d684c7e513e768f6f3ab0861492702c101b5b94e:mobile/lib/features/activity_cards/domain/activity_card.dart`
  (STORY-007 P5's own BaseHead, before P5 ran) already shows `ActivityCardOrigin`
  with 6 entries and the rule-list already at 7 `InvariantRule` entries —
  confirmed by the reporting agent from that exact BaseHead, before its own
  edit landed.
- `git status`/`git diff` for
  `mobile/test/features/conversation_starters/` and
  `mobile/lib/features/conversation_starters/` from the STORY-007 P5 worktree
  is clean — P5 touched neither directory.
- P5's own additive 7th `ActivityCardOrigin` value makes failure (1) one
  element longer than at BaseHead, but the assertion was already failing on
  length at BaseHead (5 expected vs. 6 shipped) before that — P5 did not turn
  a passing assertion red, it added to an already-red one. Failures (2) and
  (3) touch no symbol P5 changed at all (`InvariantRule`/`StarterGateRule`
  pairing, owned by STORY-005 P6/P7).

Why not fixed inline by the reporting agent:
The three affected test files and the shared `activity_card.dart` enum
definitions are outside STORY-007/P5's declared WriteScope
(`thank_you/domain/`, `thank_you/presentation/`,
`test/features/activity_cards/thank_you/` only), and the root cause belongs to
STORY-005's rework, not STORY-007.

## Artifacts

- [ ] Diagnosis (Bug Fixer)
- [ ] Fix Evidence (Bug Fixer)
- [ ] Review (Reviewer)

## Routing Notes

- Current owner: scrum-master
- Next role: bug-fixer, when queued via `fix bugs` (not required to unblock
  REQ-016 story delivery — see Resolution below); or folded into STORY-005's
  pending `full-story-review` rework findings once that review's guard block
  is resolved, since it is the same root-cause family as that story's already
  open Reviewer question
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md` (not created; needs bug-fixer triage — likely one
  mechanical fix: widen the 3 frozen assertions in `calendar_event_service_test.dart`
  and `starter_content_gate_test.dart` to match the current shipped
  `ActivityCardOrigin`/`InvariantRule`/`StarterGateRule` lists, or make them
  tolerant of later additive entries)
- Fix Evidence: `fix-evidence.md` (not created)
- Review Report: `review/review-report.md` (not created)
- Checkpoint: tracked in
  `data/requirements/REQ-016_solo_stage1_relationship_assistant/scrum-master-checkpoint.md`
- Origin: REQ-016/STORY-007_thank_you_and_next_plan mobile-dev run, phase P5
  (`data/runtime/parallel-runs/RUN-REQ-016_solo_stage1_relationship_assistant-STORY-007_thank_you_and_next_plan-mobile-dev-P5.json`)

## Resolution (not yet started — non-blocking to REQ-016 delivery)

- REQ-016 story branches that touch the shared `ActivityCardOrigin`/
  `InvariantRule`/`StarterGateRule` enums in `activity_card.dart`, or run the
  combined `test/features/conversation_starters` suite, may cite this bug id
  as the tracked, pre-existing, out-of-scope justification for these 3
  known-red assertions, and should verify their own regression via
  SCOPED/targeted test commands instead of the combined-directory run (same
  known build-evidence-gate session-lock pattern as `BUG-20260923-001`).
- No `bug-fixer` dispatch is required to unblock REQ-016 delivery. Queue this
  bug through `fix bugs` when repo-wide test health work is prioritized, or
  resolve it together with STORY-005's rework review once that review's
  `guard-parallel-spawn.sh [GENERIC]` block (see REQ-016 checkpoint, Open user
  decision 2) is unblocked.

## Blockers

- N/A
