# Review Scope Gate: STORY-005 Mồi chuyện — rework P5-P7

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

## Identity

- Review type: `full-story-review`
- Review report path: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-005_conversation_starters/review/review-report.md`
- Scope gate path: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-005_conversation_starters/review/scope-gate.md`

## Scope Decision

- Scope status: `PROCEED`
- Why this review is within budget or why it must stop: diff baseline
  `a4386f76` → `1dd4ba01` (commits `06dc96a4` plan docs, `ae908e93` P5,
  `9ab00f48` P6, `fa9c0ad5` P7, `353c648e` status flip, `1dd4ba01` doc
  correction). `git merge-base --is-ancestor a4386f76 HEAD` = YES, so the
  baseline is a valid implementation diff baseline (not HEAD). The diff touches
  10 lib/asset files + 4 test files = 14, two over the 12-file `full-story-review`
  budget. Recorded rather than blocked: `mobile/lib/design_system/icons/cupid_icons.dart`
  (+7 / −0, one `IconData` constant) and `mobile/assets/data/req016/calendar_events.v1.json`
  (+18 / −6, two additive data keys per event) carry no branching logic and are
  reviewed from their diff hunks only, so effective review breadth stays at 12.
  P1-P4 is explicitly out of scope (approved `DEFERRED_ONLY`, 2026-09-17).
- Current story or bug status: `story_master.md` records `Status: DONE` with
  `Review (Reviewer)` checked for P1-P4 only; P5-P7 has no Reviewer report yet.
  Retro gate: `data/retro-audit/rework-backlog.md` has 0 `Status: PENDING` and 0
  `Status: IN_PROGRESS` RWB items, so `Retro-Bypass: NO` is satisfiable.

## Governing Inputs

- Primary artifacts: `story_master.md` (7.2 KB, full read — under threshold);
  `requirements/requirements.md` (21.2 KB, ranged/query only);
  `coding-plan/master-plan.md` (9.7 KB, phase inventory + write scope rows);
  `architecture/contract-summary.md` (7.6 KB, only rows P5-P7 touched)
- Existing review findings: `review/review-report.md` (P1-P4, `Outcome:
  DEFERRED_ONLY`) — cited, not re-read or re-litigated
- Test evidence: `coding-plan/test-results.md` (53.8 KB — ranged reads only,
  keyed on P5/P6/P7 sections, `## Entry Point Reachability`, `## Story Runtime
  Startup Smoke`, and the `conversation_starters` failure rows)
- Extra artifacts required beyond the default minimum:
  `visual-fidelity/visual-fidelity-report.md` (20.5 KB — ranged only, keyed on
  `VISUAL_FIDELITY`, `Design-Screen`, and P5-P7 coverage) plus both PNGs under
  `visual-fidelity/` opened as images (rule 12e3); `ux/uiux-spec.md` (8.0 KB)
  because P5-P7 changed rendered chrome and the diff touches it

## Source/Test Files In Scope

- `mobile/lib/features/conversation_starters/domain/calendar_event_service.dart`
- `mobile/lib/features/conversation_starters/domain/event_date_label.dart` (new)
- `mobile/lib/features/conversation_starters/domain/starter_content.dart`
- `mobile/lib/features/conversation_starters/domain/starter_content_gate.dart`
- `mobile/lib/features/conversation_starters/presentation/cubit/conversation_starters_cubit.dart`
- `mobile/lib/features/conversation_starters/presentation/screens/conversation_starters_screen.dart`
- `mobile/lib/features/conversation_starters/presentation/widgets/starter_hero_card.dart` (new)
- `mobile/lib/features/conversation_starters/presentation/widgets/starter_line.dart`
- `mobile/lib/design_system/icons/cupid_icons.dart` (diff hunk only)
- `mobile/assets/data/req016/calendar_events.v1.json` (diff hunk only)
- `mobile/test/features/conversation_starters/calendar_event_service_test.dart`
- `mobile/test/features/conversation_starters/conversation_starters_screen_test.dart`
- `mobile/test/features/conversation_starters/event_date_label_test.dart` (new)
- `mobile/test/features/conversation_starters/starter_content_gate_test.dart`

## Evidence Files In Scope

- `coding-plan/test-results.md`
- `coding-plan/phase-P5-hero-and-secondary-hierarchy.md`
- `coding-plan/phase-P6-labels-affordances-and-date-inline.md`
- `coding-plan/phase-P7-event-reason-field.md`
- `coding-plan/master-plan.md`
- `visual-fidelity/visual-fidelity-report.md`
- `visual-fidelity/implemented-6-moi-chuyen-a-a-material.png`
- `visual-fidelity/design-reference-6-moi-chuyen-a-a-ios.png`
- `data/bugs/BUG-20260923-001_drift_schema_version_migration_test_lag/bug_master.md`
- `data/bugs/BUG-20260923-002_conversation_starters_enum_pinned_assertion_lag/bug_master.md`

## Risk Surfaces And Critical Gates

- Touched risk surfaces: mobile interaction (hero/secondary hierarchy, copy +
  "xem câu khác" affordance); mobile navigation/discoverability (entry point
  unchanged by P5-P7 but must still verify); typed/generated contract
  (`CalendarEvent` gains `reasonTemplate`/`reasonContextSlot`;
  `StarterGateRule` enum grows by 4 values); local storage/offline (static
  asset pack only — no network, AC-15/AC-16); content-invariant gate
  (`starter_content_gate.dart` rule additions, including an inverted
  `starterStructureHitsIn` use).
- Source-of-truth artifacts or contracts: `architecture/contract-summary.md`
  rows for the content package + gate; `requirements/requirements.md` ACs
  governing hierarchy, affordance labels, date-inline, reason line, R-1g and
  R-15a/b/c; `ux/uiux-spec.md` for the rendered chrome P5-P7 changed.
- Critical gates to verify: (1) targeted Flutter unit/widget tests for P5, P6,
  P7 green; (2) `flutter analyze` evidence (baseline is non-zero warnings —
  errors must be 0); (3) `## Entry Point Reachability` recorded AND verified in
  code; (4) `## Story Runtime Startup Smoke` recorded or `Runtime-Smoke:
  WAIVED`; (5) rule 12e3 mobile design-fidelity — both PNGs opened, verdict not
  contradicted, and P5-P7 rendered-surface coverage confirmed (P5-P7 change the
  rendered screen, so P1-P4-era evidence alone would be stale); (6) sibling
  call-site sweep for the `CalendarEvent`/`StarterGateRule` contract growth
  (rule 12d) bounded to `features/conversation_starters` + its gate callers.
- Mandatory web Playwright/browser-e2e gate: `NOT_APPLICABLE in ordinary continue`
- Requirement visual audit evidence: `NOT_APPLICABLE` (mobile-only lane; the
  requirement-level mobile visual audit is a separate REQ-016 closure gate)
- Mandatory mobile e2e/emulator/signing/store gate: `NOT_APPLICABLE in ordinary continue`
- Requirement mobile visual audit evidence: `NOT_APPLICABLE at story level`
  (rule 12g2 — the per-story capture is what this review checks)
- Missing gate evidence or blocker: `N/A` at gate time — resolved in Phase 2

## Query Keys

- `requirements.md` (21.2 KB): query by `reason`, `CÙNG CHỦ ĐỀ`, `xem câu khác`,
  `thứ`, `sự kiện`, `AC-4`, `AC-12`, `AC-14`, `AC-15`, `AC-16`, `AC-17`,
  `AC-27`, `AC-28`, `R-1g`, `R-15`, `## Open Question Impact` — the AC ids the
  code comments assert are NOT assumed correct from the handoff's
  "AC-1..AC-6"; the literal AC text is what is checked.
- `test-results.md` (53.8 KB): query by `P5`, `P6`, `P7`, `Entry Point
  Reachability`, `Runtime Startup Smoke`, `flutter analyze`,
  `conversation_starters`, `BUG-20260923-00`, `+0 -` / failure rows.
- `visual-fidelity-report.md` (20.5 KB): query by `VISUAL_FIDELITY`,
  `Design-Screen`, `P5`, `P6`, `P7`, `DESIGN_ANCHOR_ADJUDICATION_REQUIRED`.
- Source symbols: `StarterHeroCard`, `_SecondaryStarterCard`, `_TopicCaption`,
  `eventDateLabel`, `resolveEventReason`, `reasonTemplate`,
  `reasonContextSlot`, `eventReasonAsksQuestion`, `starterStructureHitsIn`,
  `refreshContext`, `CupidIcons.refresh`, `starter_next_round`.
- Bug ids to confirm filed and out of scope: `BUG-20260923-001`,
  `BUG-20260923-002`.

## Phase 2 Approval

- Phase 2 may proceed: `YES`
- If `NO`, final review outcome should be: `N/A`
- If `NO`, exact blocker or re-scope instruction: `N/A`
