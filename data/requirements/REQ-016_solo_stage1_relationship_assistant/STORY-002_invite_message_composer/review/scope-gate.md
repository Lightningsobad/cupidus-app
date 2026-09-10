# Review Scope Gate: STORY-002 Xuất lời mời — khung nhại + mad-libs

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

## Identity

- Review type: `full-story-review`
- Review report path: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-002_invite_message_composer/review/review-report.md`
- Scope gate path: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-002_invite_message_composer/review/scope-gate.md`

## Scope Decision

- Scope status: `PROCEED` (partial — gate-level and targeted verification only; see below)
- Why this review is within budget or why it must stop:
  The handoff requests a full review of all 6 phases. The measured diff
  (`git diff --stat 711274e3 HEAD`, merge-base with the integration branch) is
  **40 changed files / +8832 −1752**, of which ~21 are hand-written source files
  and 17 are test files. The handoff also names **13 governing artifacts**
  (solution.md, contract-summary.md, master-plan.md, 6 phase files,
  requirements.md, uiux-spec.md, test-results.md, visual-fidelity-report.md).
  Reviewer SKILL rule 1c caps `full-story-review` at **12 touched
  source/test/config files and 2 large governing artifacts** and requires
  `BLOCKER: REVIEW_SCOPE_TOO_BROAD` with a scoped-slice re-scope above that.
  Scope is ~3x the budget on source files alone.

  Rather than return a bare scope blocker with no verification value, this run
  completed the Phase 1 gate checks plus a bounded set of targeted Phase 2
  checks that do not require broad reading, and found blocking defects that
  return the story to implementation regardless of how the remaining ACs are
  sliced. The **AC-by-AC verification of AC-1..AC-29 was NOT performed** and is
  explicitly not claimed. The re-review must be sliced (plan below).
- Current story or bug status: `story_master.md` → `Status: TODO`,
  `Complexity: complex`, `Story-Class: shared-foundation`,
  `Implementation Lane: shared (backend + mobile)`. Artifacts checklist shows
  `Implementation (Development)` and `Review (Reviewer)` both unchecked.

## Governing Inputs

- Primary artifacts:
  - `story_master.md` (read in full — 102 lines)
  - `requirements/requirements.md` (query-first: `khung nhại`, `AC-16`, `AC-23`,
    `AC-24`, `AC-26`, `AC-27`, `AC-28`, `kiểm duyệt`)
  - `../req_master.md` (query-first: `Design Ruling Log`, `2026-09-10`, `OQ-3`)
  - `coding-plan/test-results.md` (query-first: `^## `, `reachab`, `smoke`,
    `entry point`, `visual_fidelity`, `design-screen`)
- Existing review findings: `N/A` — no prior `review/` directory existed in this
  worktree; this is round 1.
- Test evidence:
  - `coding-plan/test-results.md` §P1..§P6
  - Scrum Master's independently reproduced tallies quoted in the handoff
    (330 passed / 0 failed / 2 pre-existing skips; `flutter analyze` 15
    pre-existing `prefer_initializing_formals` info)
  - `visual-fidelity/visual-fidelity-report.md` (197 lines, read in full)
- Extra artifacts required beyond the default minimum:
  - `data/retro-audit/rework-backlog.md` (rule 1a pre-check — 0 `PENDING`,
    0 `IN_PROGRESS`, gate open)

## Source/Test Files In Scope

Verified in this run (bounded set, within the 12-file budget):

- `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart` (full boundary diff)
- `mobile/lib/features/activity_cards/presentation/activity_card_detail_cubit.dart` (ranged: 330-492, `_withEdits` carry-forward)
- `mobile/lib/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart` (query-first: entry wiring symbols)
- `mobile/assets/data/req016/presets.invite.v1.json` (ranged: 1-50, 98-135 + id/frame index)

NOT verified in this run — deferred to sliced re-review:

- `mobile/lib/features/invite_composer/domain/` — `mad_libs.dart`,
  `invite_renderer.dart`, `invite_preset.dart`, `preset_catalogue.dart`,
  `preset_content_gate.dart`, `invite_payload.dart`,
  `invite_payload_repository.dart`
- `mobile/lib/features/invite_composer/data/invite_payload_repository_impl.dart`
- `mobile/lib/features/invite_composer/presentation/invite_composer_cubit.dart`
- `mobile/lib/features/invite_composer/presentation/widgets/invite_composer_sheet.dart`,
  `frame_chip_strip.dart`
- `mobile/lib/core/database/` — `cupid_database.dart`,
  `tables/invite_messages_table.dart`, `tables/activity_cards_table.dart`,
  `daos/invite_message_dao.dart`
- `mobile/lib/core/di/service_locator.dart`
- `mobile/lib/features/activity_cards/domain/activity_card.dart`,
  `data/activity_card_repository_impl.dart`
- all 17 test files under `mobile/test/features/invite_composer/`,
  `mobile/test/features/activity_cards/`, `mobile/test/core/database/`

## Evidence Files In Scope

- `coding-plan/test-results.md`
- `visual-fidelity/visual-fidelity-report.md`
- `visual-fidelity/implemented-11-xuat-loi-moi-chon-khung-ios.png`
- `visual-fidelity/design-reference-11-xuat-loi-moi-chon-khung-ios.png`
- `visual-fidelity/implemented-11-dien-mad-libs-xem-truoc-ios.png`
- `visual-fidelity/design-reference-11-dien-mad-libs-xem-truoc-ios.png`
- `visual-fidelity/implemented-11-chuan-bi-chon-hanh-dong-ios.png`
- `visual-fidelity/implemented-chi-tiet-the-moi-nghi-ra-ios-cho-hen.png`
- `visual-fidelity/design-reference-chi-tiet-the-moi-nghi-ra-ios.png`
- `visual-fidelity/implemented-chi-tiet-the-da-hen-ngay-ios-cho-hen.png`
- `data/retro-audit/rework-backlog.md`

## Risk Surfaces And Critical Gates

- Touched risk surfaces: persistence/schema/migration (schema v5: `location`
  column + `invite_messages` table); local storage/offline (SB-125 payload
  store); mobile interaction (composer sheet, chip strip, inline edit);
  mobile navigation/discoverability (new "Chuẩn bị" entry sheet + rewired
  primary CTA); typed/generated contract (Drift `.g.dart` regeneration);
  runtime/configuration (`service_locator.dart` registrations); data
  migration/backfill (v4→v5).
- Source-of-truth artifacts or contracts: `ux/uiux-spec.md` §1/§2/§4/§6
  (declared SoT by the P5/P6 phase files); `requirements/requirements.md`
  AC-1..AC-29; `architecture/contract-summary.md` §3.
- Critical gates to verify:
  1. Entry Point Reachability (rule 12e1) — **FAIL, evidence section absent**
  2. Story Runtime Startup Smoke (rule 12g) — **FAIL, evidence section absent**
  3. Mobile design fidelity, reviewer verifies-not-recaptures (rule 12e3) —
     **PARTIAL**. All 8 PNGs were opened and read; all are real captures of this
     story's screens (no error frame, no blank frame, no wrong screen), and the
     three `Design-Screen:` ids match the references. But two claims in
     `visual-fidelity-report.md` are contradicted or understated by the images
     themselves — see review report F-4 and F-5.
  4. Targeted widget/unit/migration tests + `flutter analyze` (rule 12e0) —
     **PASS** on the reproduced tallies
  5. Schema-v5 migration correctness — **NOT VERIFIED** (sliced out)
- Mandatory web Playwright/browser-e2e gate: `NOT_APPLICABLE in ordinary continue`
- Requirement visual audit evidence: `NOT_APPLICABLE` (mobile lane; per-story
  rule 12g2 capture applies instead)
- Mandatory mobile e2e/emulator/signing/store gate: `NOT_APPLICABLE in ordinary continue`
- Requirement mobile visual audit evidence: `REQUIRED when requirement had mobile participation`
  — deferred to REQ-016 integration review, not this story gate
- Missing gate evidence or blocker: `## Entry Point Reachability` and
  `## Story Runtime Startup Smoke` are both absent from
  `coding-plan/test-results.md`, and `story_master.md` records no
  `Runtime-Smoke: WAIVED — <reason>`.

## Query Keys

- AC ids: AC-1, AC-3, AC-4, AC-5, AC-9, AC-16, AC-23, AC-24, AC-25, AC-26,
  AC-27, AC-28, AC-29
- Story ACs 1-7 in `story_master.md ## Acceptance Criteria`
- Symbols: `_withEdits`, `_commitLocation`, `_editWithLocation`,
  `normalizeLocation`, `ActivityCardEdit.from`, `showPrepareActionsSheet`,
  `showInviteComposerSheet`, `PrepareActionsPresenter`, `InviteComposerOpener`,
  `ActivityCardPrimaryAction.prepare`
- Content-pack keys: `frame`, `clauses`, `requires`, `targets`,
  `role: decline_door`, `editorial_review`, `schema_id: req016.presets.v1`
- Headings: `## Entry Point Reachability`, `## Story Runtime Startup Smoke`,
  `## Design Ruling Log`, `VISUAL_FIDELITY:`, `Design-Screen:`,
  `Design-Surface:`, `Runtime-Smoke:`
- Commands: `flutter test test/features/activity_cards/ test/features/invite_composer/`,
  `flutter analyze`
- Git baseline: `git -C <Worktree> diff 711274e3fde25788c91390a44572d53766bba778 HEAD`

## Phase 2 Approval

- Phase 2 may proceed: `NO` (partial only — bounded gate + targeted checks were
  completed; systematic AC-1..AC-29 verification is NOT approved at this scope)
- If `NO`, final review outcome should be: `PATCH_REQUIRED`
- If `NO`, exact blocker or re-scope instruction:
  Two non-waivable evidence gates are missing and one story-caused correctness
  defect was found, so the story returns to the mobile lane now. For the
  re-review after rework, split into `Reviewer: scoped-slice` passes with exact
  files and query keys, then a fresh `Reviewer: final-synthesis`:
  - **Slice A — render engine + content pack (P1/P2):** `mad_libs.dart`,
    `invite_renderer.dart`, `invite_preset.dart`, `preset_catalogue.dart`,
    `preset_content_gate.dart`, `presets.invite.v1.json` + their 5 tests.
    ACs: AC-5, AC-9, AC-23, AC-25, AC-26, AC-27, AC-28, AC-29; story AC-2, AC-3.
  - **Slice B — schema v5 + payload store (P3/P4):** `cupid_database.dart`,
    both new table files, `invite_message_dao.dart`,
    `invite_payload_repository_impl.dart`, `invite_payload.dart`,
    `invite_payload_repository.dart`, `service_locator.dart` +
    `migration_v5_test.dart`, `invite_payload_repository_test.dart`.
    ACs: AC-16..AC-19; story AC-5 (SB-125 renderable payload).
  - **Slice C — composer sheet + entry surface (P5/P6):**
    `invite_composer_cubit.dart`, `invite_composer_sheet.dart`,
    `frame_chip_strip.dart`, `prepare_actions_sheet.dart`,
    `activity_card_detail_screen.dart` + their 4 tests.
    ACs: story AC-1, AC-4, AC-6, AC-7; AC-1, AC-3, AC-4, AC-16.
  - Each slice gets 1 large governing artifact max, query-first.
