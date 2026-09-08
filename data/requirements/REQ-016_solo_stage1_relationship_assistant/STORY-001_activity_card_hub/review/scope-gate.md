# Review Scope Gate: STORY-001 Danh sách việc-cần-làm / Activity Card Hub

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

## Identity

- Review type: `full-story-review`
- Review report path: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-001_activity_card_hub/review/review-report.md`
- Scope gate path: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-001_activity_card_hub/review/scope-gate.md`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-001`
- Diff baseline: `git -C <Worktree> diff 9207f7296a64cd37ca60e432939469ca96860762 HEAD`

## Scope Decision

- Scope status: `STOP`
- Current story or bug status: `Status: TODO` in `story_master.md`; `Complexity: complex`,
  `Story-Class: shared-foundation`, `Implementation Lane: shared (mobile)`.
- Why this review must stop:

| Metric | Budget (SKILL rule 1c) | Actual | Verdict |
|---|---|---|---|
| Changed/touched source/test/config files | ≤ 12 | **44** | 3.7x over |
| Large governing artifacts (> ~20 KB) | ≤ 2 | **3+** | over |
| Total diff | — | 70 files, +14690 / −469 | — |

Total diff of 70 files = 44 source/test/config + 13 story artifact `.md` + 13 PNG.
Oversized artifacts: `coding-plan/test-results.md` (923 lines, 7 phases in one
file), `visual-fidelity/visual-fidelity-report.md` (496 lines, 4 screens, deltas
D-14..D-27), `mobile/lib/core/database/cupid_database.g.dart` (+2654 / −453).

The cause is structural, not a handoff error: all seven phases (P1, P2, P3, P4,
P7, P5, P6) shipped with no incremental per-phase review, so one pass would have
to hold 7 phase contracts, 15 acceptance criteria across two AC sources, 4
rendered screens and 13 images at once. Rule 1c requires stopping before reading
broadly rather than producing a verdict with unread evidence behind it. No source,
test, config, or evidence implementation file was opened in this pass.

Sibling precedent in this requirement: STORY-003 (50 files, +9802 / −542) returned
`BLOCKED` / `REVIEW_SCOPE_TOO_BROAD` on its first pass and completed successfully
through per-phase slices plus a final synthesis.

## Governing Inputs

- Primary artifacts read for scoping only (Phase 1):
  - `git diff --numstat <BaseHead> HEAD` — measure changed-file count vs budget
  - `story_master.md` — complexity, story class, base AC-1..AC-7, entry-point requirement
  - `coding-plan/master-plan.md` — phase inventory, execution order, risk-surface→phase map
  - `data/retro-audit/rework-backlog.md` — status query only (SKILL rule 1a precondition)
  - `requirements/requirements.md` — AC id query only, no body read
- Existing review findings: `N/A` — first review pass for this story.
- Test evidence: `coding-plan/test-results.md` — NOT read this pass; assigned per
  slice by phase section range.
- Extra artifacts required beyond the default minimum: `requirements/requirements.md`
  is mandatory for every slice (see Query Keys — it holds AC-10..AC-15, which
  `story_master.md` does not).

## Source/Test Files In Scope

For THIS pass: none — Phase 2 is not approved. The 44 files below are the exact
inventory, partitioned into the slices prescribed in `## Prescribed Slice Plan`.
Each slice handoff takes exactly its own group.

S1 — P1 local card store (9):

- `mobile/lib/core/database/cupid_database.dart`
- `mobile/lib/core/database/cupid_database.g.dart` (generated — spot-check `activity_cards` table + schema version only)
- `mobile/lib/core/database/daos/activity_card_dao.dart`
- `mobile/lib/core/database/daos/activity_card_dao.g.dart` (generated)
- `mobile/lib/core/database/tables/activity_cards_table.dart`
- `mobile/test/core/database/activity_card_dao_test.dart`
- `mobile/test/core/database/activity_card_migration_test.dart`
- `mobile/test/core/database/expense_dao_test.dart`
- `mobile/test/core/database/timeline_dao_test.dart`

S2 — P2 domain repository + P7 ActivityType (9):

- `mobile/lib/features/activity_cards/domain/activity_card.dart`
- `mobile/lib/features/activity_cards/domain/activity_card_repository.dart`
- `mobile/lib/features/activity_cards/data/activity_card_repository_impl.dart`
- `mobile/lib/core/di/service_locator.dart`
- `mobile/lib/features/activity_cards/domain/activity_type.dart`
- `mobile/lib/design_system/icons/cupid_icons.dart`
- `mobile/test/features/activity_cards/activity_card_repository_test.dart`
- `mobile/test/features/activity_cards/activity_card_status_test.dart`
- `mobile/test/features/activity_cards/activity_type_test.dart`

S3 — P3 occasion content package (6):

- `mobile/lib/core/content/content_package.dart`
- `mobile/lib/features/activity_cards/domain/occasion_suggestion_service.dart`
- `mobile/assets/data/req016/occasions.v1.json`
- `mobile/pubspec.yaml`
- `mobile/test/core/content/content_package_test.dart`
- `mobile/test/features/activity_cards/occasion_suggestion_service_test.dart`

S4 — P4 hub list, status buckets, entry point (9):

- `mobile/lib/features/activity_cards/presentation/activity_card_list_cubit.dart`
- `mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart`
- `mobile/lib/features/activity_cards/presentation/widgets/activity_card_tile.dart`
- `mobile/lib/features/activity_cards/presentation/widgets/activity_status_filter.dart`
- `mobile/lib/features/home/presentation/home_screen.dart`
- `mobile/lib/main_preview.dart`
- `mobile/test/features/activity_cards/activity_card_hub_view_test.dart`
- `mobile/test/features/home/presentation/home_header_notifications_test.dart`
- `mobile/test/features/home/presentation/timeline_entry_point_test.dart`

S5 — P5 minute-one empty state + quick capture (5):

- `mobile/lib/features/activity_cards/presentation/widgets/minute_one_empty_state.dart`
- `mobile/lib/features/activity_cards/presentation/widgets/quick_capture_sheet.dart`
- `mobile/lib/features/activity_cards/presentation/widgets/quick_entry_strip.dart`
- `mobile/test/features/activity_cards/minute_one_empty_state_test.dart`
- `mobile/test/features/activity_cards/quick_capture_sheet_test.dart`

S6 — P6 card detail, lifecycle, delete (6):

- `mobile/lib/features/activity_cards/presentation/activity_card_detail_cubit.dart`
- `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart` (969 lines — read by symbol/range, not whole)
- `mobile/lib/features/activity_cards/presentation/widgets/status_change_picker.dart`
- `mobile/lib/features/activity_cards/presentation/widgets/delete_card_dialog.dart`
- `mobile/test/features/activity_cards/activity_card_detail_screen_test.dart`
- `mobile/test/features/activity_cards/card_lifecycle_ui_test.dart`

S7 — cross-cutting evidence: no source/test/config files (artifacts only, see
`## Evidence Files In Scope`).

## Evidence Files In Scope

Assigned per slice; none read in this pass.

- `data/.../STORY-001_activity_card_hub/requirements/requirements.md` — every slice (AC source of truth)
- `.../coding-plan/phase-P1-local-card-store.md` — S1
- `.../coding-plan/phase-P2-card-domain-repository.md` — S2
- `.../coding-plan/phase-P7-activity-type-enum-and-card-icon.md` — S2
- `.../coding-plan/phase-P3-occasion-content-package.md` — S3
- `.../coding-plan/phase-P4-hub-list-and-entry-point.md` — S4
- `.../coding-plan/phase-P5-minute-one-empty-state-and-capture.md` — S5
- `.../coding-plan/phase-P6-card-detail-lifecycle-delete.md` — S6
- `.../coding-plan/test-results.md` — each slice reads ONLY its own phase section by range, never the whole 923-line file
- `.../coding-plan/master-plan.md` — read at scope gate; slices reuse §3A mapping from this file, do not re-read
- `.../architecture/contract-summary.md` §1/§2/§3 — S1, S2
- `.../architecture/solution.md` §4 — S1, S2
- `.../ux/uiux-spec.md` — S4, S5, S6 (named sections only)
- `.../visual-fidelity/visual-fidelity-report.md` (496 lines) — S7
- `.../visual-fidelity/design-reference-{man-goc-muon-lam,phut-1-kho-trong,chi-tiet-the-moi-nghi-ra,the-da-thanh-ky-niem}-ios.png` — S7
- `.../visual-fidelity/implemented-*.png` (9 files) — S7
- `data/requirements/REQ-016_solo_stage1_relationship_assistant/req_master.md` — S7 (D-8 resolution block only)

## Risk Surfaces And Critical Gates

- Touched risk surfaces: persistence/schema/migration · typed/generated contract ·
  local storage/offline · mobile interaction · mobile navigation/discoverability ·
  app lifecycle · mobile discoverability integration
- Source-of-truth artifacts or contracts: `requirements/requirements.md` (AC-1..AC-15),
  `architecture/contract-summary.md` §1–§3, `master-plan.md` §3A risk-surface map,
  ADR-015.6 (no destructive recreate for source-of-truth tables)
- Critical gates to verify:

| Gate | Rule | Slice |
|---|---|---|
| Additive v2→v3 migration, no destructive recreate | ADR-015.6 / master-plan §6 | S1 |
| R-1b — no read-receipt/seen/open-count columns or fields | AC-6 | S1, S6 |
| Shared contract stability for 11 downstream stories | contract-summary §1–§3 | S2 |
| P7 must not touch `schemaVersion` | master-plan §6 | S2 |
| R-7/BR-8 — no runtime AI or content API | AC-1/AC-2 | S3 |
| Entry-point reachability, verified in the route table itself | 12e1 | S4 |
| AC-15 — no silent data loss on status rollback | master-plan §3A | S2, S6 |
| Mobile design fidelity: images opened, not counted | 12e2 / 12e3 | S7 |
| Mobile runtime startup smoke (app launches, first screen, no crash) | 12g | S7 |

- Mandatory web Playwright/browser-e2e gate: `NOT_APPLICABLE in ordinary continue`
- Requirement visual audit evidence: `NOT_APPLICABLE` — no frontend participation; mobile lane only
- Mandatory mobile e2e/signing/store gate: `NOT_APPLICABLE in ordinary continue`
- Requirement mobile visual audit evidence: `REQUIRED` at requirement closure
  (12g2), separate from the per-story check owned by S7; not this story's gate
- Missing gate evidence or blocker: none of the gates above were evaluated in this
  pass — the scope blocker preceded all of them.

## Query Keys

Acceptance source of truth: **`requirements/requirements.md`, not `story_master.md`.**
`story_master.md` lists only AC-1..AC-7; the expanded set **AC-10..AC-15 exists in
`requirements/requirements.md`** (10 id matches), and `master-plan.md` §3A binds
one of them to code: *"AC-15 mất dữ liệu âm thầm khi lùi trạng thái → P2, P6"*.
Every slice must name its ACs from `requirements/requirements.md`; a slice scoped
to the base 7 would skip exactly the criterion that decides FLAG-1.

- S1: `activity_cards`, `activity_card_photos`, `schemaVersion`, `MigrationStrategy`,
  `onUpgrade`, AC-3, AC-6, R-1b, SC-1', ADR-015.6, `seen`, `opened`, `openCount`,
  `viewedAt` (must be absent)
- S2: `ActivityCardRepository`, `createCard`, `updateStatus`, `clearScheduledDate`,
  `deleteCard`, `ActivityCardStatus`, `origin`, `ActivityType`, `TypeConverter`,
  AC-4, AC-7, AC-15, contract-summary §1/§2
- S3: `ContentPackage`, `id`, `version`, `occasions.v1.json`, `OccasionSuggestionService`,
  `assets:` in `pubspec.yaml`, AC-1, AC-2, R-7, BR-8, R-15a, R-15b
- S4: `ActivityCardListCubit`, `ActivityCardHubView`, `ActivityStatusFilter`,
  `ActivityCardTile`, primary-action selection per status, `HomeScreen` solo branch,
  AC-3, AC-4, AC-5, SC-4, SC-5, `## Entry Point Reachability`, `Reachable: YES`
- S5: `MinuteOneEmptyState`, `QuickCaptureSheet`, `QuickEntryStrip`, paste-link path,
  invitation count (exactly two), AC-1, AC-2, J1
- S6: `ActivityCardDetailCubit`, `ActivityCardDetailScreen`, `StatusChangePicker`,
  `DeleteCardDialog`, `scheduledDate`, `emit(`, repository call sites, AC-4, AC-5,
  AC-6, AC-7, AC-15, R-1b, R-1c
- S7: `VISUAL_FIDELITY:`, `Design-Screen:`, D-8, D-14..D-27, `DESIGN_SPEC_CONFLICT`,
  `CONTRACT_GAP`, `## Entry Point Reachability`, `## Story Runtime Startup Smoke`

Files over ~20 KB and their required ranges: `test-results.md` → per-phase section
only; `visual-fidelity-report.md` → per-screen verdict + delta table;
`activity_card_detail_screen.dart` (969 lines) → by symbol; `cupid_database.g.dart`
→ `activity_cards` table + schema version only.

## Phase 2 Approval

- Phase 2 may proceed: `NO`
- If `NO`, final review outcome should be: `BLOCKED` — `REVIEW_SCOPE_TOO_BROAD`
  (SKILL rule 1c)
- If `NO`, exact blocker or re-scope instruction: re-dispatch as the 8-pass plan
  below — seven `Mode: scoped-slice` passes then one `Mode: final-synthesis`, one
  at a time (the `story-state:STORY-001` lock admits one worker in this worktree).
  Each slice writes `review/slice-<n>-<name>.md` inside the declared WriteScope and
  emits a PASS/FAIL/UNVERIFIED table plus findings, not a code walkthrough.

## Prescribed Slice Plan

| Pass | Mode | Subject | Files |
|---|---|---|---|
| S1 | `scoped-slice` | P1 local card store — schema, DAO, v2→v3 migration | 9 |
| S2 | `scoped-slice` | P2 domain repository + P7 `ActivityType` (owns FLAG-1 first half) | 9 |
| S3 | `scoped-slice` | P3 occasion content package — R-7/R-15 | 6 |
| S4 | `scoped-slice` | P4 hub list, buckets, entry point (owns FLAG-2) | 9 |
| S5 | `scoped-slice` | P5 minute-one empty state + quick capture | 5 |
| S6 | `scoped-slice` | P6 detail, lifecycle, delete (owns FLAG-1 second half) | 6 |
| S7 | `scoped-slice` | Visual fidelity images + entry-point/runtime evidence | artifacts only |
| S8 | `final-synthesis` | Verdict from S1–S7 reports only | slice reports only |

Per-slice AC/invariant focus:

- S1: AC-3 structured field set (SB-76) · AC-6/R-1b no behaviour-tracking columns ·
  `schemaVersion` 2→3 additive only · SC-1' single store
- S2: AC-4 · AC-7 · AC-15 · contract-summary §1/§2 (the contract 11 later stories
  consume) · P7 must not touch `schemaVersion`
- S3: AC-1/AC-2 second invitation ("để app gợi ý 1 việc theo dịp gần nhất") ·
  R-7/BR-8 no runtime AI/content API · R-15a/R-15b stable ids, N is data
- S4: AC-3 (SC-4 exactly one primary action per status) · AC-4 bucket placement ·
  AC-5 (SC-5 no dead-end bucket) · rule 12e1 — read `home_screen.dart`'s actual
  branch/route wiring and confirm the hub is reachable from the main menu; do NOT
  accept `Reachable: YES` on trust
- S5: AC-1 (empty state, no onboarding form, exactly two invitations — count them
  in the widget tree, a third CTA is a FAIL) · AC-2 (≥1 card in *Mới nghĩ ra* with
  no extra field entry) · J1 5-second capture incl. paste-link
- S6: AC-4 (schedule date → *Đã hẹn ngày*) · AC-5 two-way transitions ·
  AC-6/R-1b (only đã/chưa trả lời; no seen indicator, no open time, no open count) ·
  AC-7/R-1c undramatic delete · AC-15 no silent data loss on status rollback
- S7: rule 12e3 mobile-lane fidelity — **open the images, do not count the files**;
  confirm each `implemented-*` shows this story's screen in the built app (not a
  splash frame, spinner, red error screen, or wrong screen), confirm the resolved
  `Design-Screen: <id>` is recorded and the reference actually depicts that screen ·
  rule 12g mobile runtime startup smoke · re-assess whether the top-line
  `VISUAL_FIDELITY: FAIL` should now read PASS given D-8 closed on 2026-09-08 with
  no code change required, or must stay FAIL/PARTIAL on an independent ground found
  in D-14..D-27 · type each of the 14 deltas as `DESIGN_SPEC_CONFLICT` (verify each
  claim quotes the AC clause and the design element side by side — an unquoted
  claim is an ordinary implementation delta wearing a label, and stays
  `PATCH_REQUIRED`) / `CONTRACT_GAP` / glyph-swap
- S8: fresh context, read ONLY `review/slice-1..7-*.md`. Do not re-read source,
  phase files, `test-results.md`, requirements, UX, or architecture unless a slice
  report marks an item `UNVERIFIED` and names the exact missing evidence key.
  Overwrite `review/review-report.md` with the single literal `Outcome:` line,
  blocking findings with an owner each, deferred findings, and the story state
  recommendation. Do not copy slice prose forward.

Note for S7: four screens have design references but nine implemented captures
exist, including `round2`/`round3`/`round4` retries and a second device variant of
the same screen. Establish which implemented capture is the authoritative one per
screen before comparing; a stale retry frame compared against the reference
produces a wrong verdict in whichever direction it points.

## Open Flags Carried Into The Slices

Both were raised by the P6 implementer and are untriaged. Neither is resolvable at
scope-gate depth — each is assigned to the slice that holds its code.

- **FLAG-1 — repository has no field-write path.** `activity_card_repository.dart`
  exposes `updateStatus`, `clearScheduledDate`, `deleteCard`, `createCard`; the P6
  detail screen's scheduled-date and other field edits are reported to live only in
  detail-cubit memory. `status` transitions do persist. S2 establishes what the
  contract actually exposes; S6 establishes what the detail screen does with it and
  issues the classification. Rule 14 (exact AC text) applies: AC-4 as written in
  `story_master.md` requires transition + correct bucket placement and states no
  round-trip persistence — but AC-10..AC-15 in `requirements/requirements.md` must
  be read before that conclusion stands, and AC-15 (silent data loss on status
  rollback) is bound to exactly P2+P6 by master-plan §3A.
- **FLAG-2 — hub view mounts neither P5 nor P6.** `activity_card_hub_view.dart`
  reportedly does not mount the P5 empty-state/capture widgets and does not route
  to the P6 detail screen; both are outside every phase's declared write scope so
  far. S4 owns this against rule 12e1 (non-waivable reachable entry point) and the
  story's *System Integration And Discoverability* section. Test to apply: if AC-1,
  AC-2, AC-4, or AC-7 can be exercised only by a widget test mounting the widget
  directly, and never by a user arriving from the main menu, the AC is unverifiable
  end-to-end and that is `PATCH_REQUIRED`, not an acceptable staged-rollout gap.
  S4 must confirm this in the code rather than inherit the claim from this gate.

## Preconditions Verified

- `data/retro-audit/rework-backlog.md` — 0 items `Status: PENDING`, 0 items
  `Status: IN_PROGRESS`. SKILL rule 1a precondition clear; no retro bypass needed.
- Required artifacts present for a complex story: `requirements/`, `ux/`,
  `architecture/solution.md`, `architecture/contract-summary.md`, `coding-plan/`
  (master plan + 7 phase files + `test-results.md`), `visual-fidelity/`.
