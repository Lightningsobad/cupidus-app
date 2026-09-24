# Review Scope Gate: STORY-007 Thank You And Next Plan — slice P1 (activation ledger)

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

## Identity

- Review type: `scoped-slice` (slice 1/5 of a Tier 3 scoped-slice review; the
  template enum does not list this mode — see the note in Phase 2 Approval)
- Review report path: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-007_thank_you_and_next_plan/review/slice-p1-activation-ledger.md`
- Scope gate path: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-007_thank_you_and_next_plan/review/scope-gate.md`

## Scope Decision

- Scope status: `PROCEED`
- Why this review is within budget or why it must stop: the full STORY-007 diff
  against `bfe231aa` is ~40 source+test files / ~5.5k added lines, past the
  compact and full review budgets. This slice is bounded to the 12 P1 lib files,
  the 10 `test/core/database/` schemaVersion-ripple files and the 5 P1/wipe test
  files named by the handoff. P2-P5 (block shell, preset category, photo attach,
  next-plan suggestions) are explicitly out of scope and dispatched separately.
- Current story or bug status: STORY-007 in flight on
  `codex/REQ-016_solo_stage1_relationship_assistant-STORY-007_thank_you_and_next_plan`;
  phase P1 `Status: DONE` in `coding-plan/phase-P1-activation-ledger.md` §7.

## Governing Inputs

- Primary artifacts: `requirements/requirements.md` (AC-1..AC-5, AC-25, AC-26),
  `architecture/solution.md` §4 Architecture Delta,
  `coding-plan/phase-P1-activation-ledger.md` §1B/§4/§6,
  `coding-plan/master-plan.md` §5, `req_master.md` R-1b / R-15 family.
- Existing review findings: `N/A` — first review pass on this story.
- Test evidence: `coding-plan/test-results.md` §`## P1 — Sổ kích hoạt lời cảm ơn
  (activation ledger)`, plus an independent scoped re-run by this reviewer.
- Extra artifacts required beyond the default minimum: `architecture/contract-summary.md`
  (queried by heading; it turns out to govern the P3 preset-content contract,
  not P1 layering — see the finding in the slice report).

## Source/Test Files In Scope

- `mobile/lib/core/database/cupid_database.dart`
- `mobile/lib/core/database/cupid_database.g.dart`
- `mobile/lib/core/database/tables/thank_you_activations_table.dart`
- `mobile/lib/core/di/service_locator.dart`
- `mobile/lib/features/activity_cards/domain/activity_card.dart`
- `mobile/lib/features/activity_cards/thank_you/data/thank_you_activation_dao.dart`
- `mobile/lib/features/activity_cards/thank_you/data/thank_you_activation_repository_impl.dart`
- `mobile/lib/features/activity_cards/thank_you/domain/thank_you_activation.dart`
- `mobile/lib/features/activity_cards/thank_you/domain/thank_you_activation_repository.dart`
- `mobile/lib/features/activity_cards/thank_you/domain/thank_you_activation_service.dart`
- `mobile/lib/features/activity_cards/thank_you/domain/thank_you_activation_card_status_listener.dart`
- `mobile/lib/features/activity_cards/thank_you/domain/thank_you_activation_card_status_repository.dart`
- `mobile/lib/features/chapter_closure/data/stage1_wipe_registry.dart`
- `mobile/test/core/database/activity_card_dao_test.dart`
- `mobile/test/core/database/activity_card_migration_test.dart`
- `mobile/test/core/database/calendar_event_state_migration_test.dart`
- `mobile/test/core/database/chapter_closure_migration_test.dart`
- `mobile/test/core/database/context_notebook_migration_test.dart`
- `mobile/test/core/database/expense_dao_test.dart`
- `mobile/test/core/database/journal_dao_test.dart`
- `mobile/test/core/database/migration_v5_test.dart`
- `mobile/test/core/database/relationship_labels_migration_test.dart`
- `mobile/test/core/database/timeline_dao_test.dart`
- `mobile/test/features/activity_cards/thank_you/thank_you_activation_card_status_repository_test.dart`
- `mobile/test/features/activity_cards/thank_you/thank_you_activation_migration_test.dart`
- `mobile/test/features/activity_cards/thank_you/thank_you_activation_service_test.dart`
- `mobile/test/features/chapter_closure/stage1_wipe_registry_parity_test.dart`
- `mobile/test/features/chapter_closure/stage1_wipe_service_test.dart`

Explicitly NOT in this slice: `thank_you/data/attachable_photos.dart`,
`thank_you/domain/next_plan_suggestion_service.dart`, everything under
`thank_you/presentation/`, and their tests (P2-P5).

## Evidence Files In Scope

- `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-007_thank_you_and_next_plan/coding-plan/test-results.md`
- `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-007_thank_you_and_next_plan/coding-plan/phase-P1-activation-ledger.md`
- `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-007_thank_you_and_next_plan/coding-plan/master-plan.md`
- `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-007_thank_you_and_next_plan/architecture/solution.md`
- `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-007_thank_you_and_next_plan/architecture/contract-summary.md`
- `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-007_thank_you_and_next_plan/requirements/requirements.md`
- `data/requirements/REQ-016_solo_stage1_relationship_assistant/req_master.md`

## Risk Surfaces And Critical Gates

- Touched risk surfaces: `DRIFT_SCHEMA_COLLISION`, `ACTIVATION_RULES_UNTESTABLE`,
  `LOCAL_DATE_RULE_UNVERIFIED`, `SILENCE_PENALTY_LEAK`.
- Source-of-truth artifacts or contracts: `solution.md` §4 Risk Surfaces table,
  `phase-P1-activation-ledger.md` §1B/§4, AC-1..AC-5 and AC-25/AC-26.
- Critical gates to verify: single 9→10 schemaVersion bump with an additive
  migration step; single-fire lifetime activation semantics; no punishment,
  streak, counter, deadline or percent surface; DAO/repository/service layering
  and the ADR-010 `core/` → `features/` import direction; targeted P1 test
  evidence.
- Mandatory web Playwright/browser-e2e gate: `NOT_APPLICABLE in ordinary continue`
- Requirement visual audit evidence: `NOT_APPLICABLE`
- Mandatory mobile e2e/emulator/signing/store gate: `NOT_APPLICABLE in ordinary continue`
- Requirement mobile visual audit evidence: `NOT_APPLICABLE` — P1 builds no UI
  (`phase-P1-activation-ledger.md` §6: "Per-story visual fidelity: NOT_APPLICABLE").
- Missing gate evidence or blocker: `N/A`

## Query Keys

- AC ids: AC-1, AC-2, AC-3, AC-4, AC-5, AC-25, AC-26, AC-14 (STORY-001 signal).
- Rules: BR-2, BR-3, R-1b, R-15 / R-15a / R-15b, ADR-010.
- Risk surface ids: `DRIFT_SCHEMA_COLLISION`, `ACTIVATION_RULES_UNTESTABLE`,
  `LOCAL_DATE_RULE_UNVERIFIED`, `SILENCE_PENALTY_LEAK`.
- Headings: `## P1 — Sổ kích hoạt lời cảm ơn (activation ledger)`,
  `### Sửa lỗi tồn đọng`, `### Sai lệch so với handoff, cần Scrum Master ghi nhận`,
  `## 4. Architecture Delta`, `### Boundaries And Ownership`,
  `### Risk Surfaces And Source Of Truth`, `## 7. Status`.
- Symbols: `schemaVersion`, `thankYouActivations`, `ThankYouActivationStatuses`,
  `ThankYouActivationService.arm/cancel/consume/isEligible`, `civilDateOf`,
  `insertArmed`, `settleArmed`, `ThankYouActivationAwareCardRepository`,
  `ActivityCardOrigin.nextPlanAfterDate`, `Stage1WipeRegistry.tables`.
- Commands: `git -C <Worktree> diff bfe231aa -- <slice files>`;
  `flutter test test/core/database/ test/features/activity_cards/thank_you/ test/features/chapter_closure/ --reporter failures-only`.
- Test names: `mọi bảng REQ-016 trong lược đồ đều có mặt trong registry`.

## Phase 2 Approval

- Phase 2 may proceed: `YES`
- If `NO`, final review outcome should be: `N/A`
- If `NO`, exact blocker or re-scope instruction: `N/A`

Template conflict recorded, not silently absorbed: the `Review type` enum in
`.claude/skills/reviewer/assets/scope_gate_template.md` has no `scoped-slice`
member even though `scoped-slice` is a dispatchable Reviewer mode. The dispatched
mode is used above verbatim rather than forced into a wrong enum member.
