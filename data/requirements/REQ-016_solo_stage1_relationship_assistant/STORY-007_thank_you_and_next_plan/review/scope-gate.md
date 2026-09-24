# Review Scope Gate: STORY-007 Thank You And Next Plan — story-level (final synthesis)

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

> Bản này **thay thế** bản scope gate chỉ-phủ-P1 mà reviewer slice P1 đã viết
> dưới sức ép cổng `SCOPE_GATE_MISSING`. Nó phủ **toàn bộ** tập file của story
> trên cả 5 slice, đúng yêu cầu mục 4 của handoff final-synthesis. Phạm vi P1
> cũ không bị mất: nó là mục `### Slice P1` bên dưới.

## Identity

- Review type: `final-synthesis` (pass tổng hợp sau 5 slice `scoped-slice`)
- Review report path: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-007_thank_you_and_next_plan/review/review-report.md`
- Scope gate path: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-007_thank_you_and_next_plan/review/scope-gate.md`
- Slice reports đã phủ: `review/slice-p1-activation-ledger.md`,
  `review/slice-p2-block-shell-entry-point.md`,
  `review/slice-p3-preset-category.md`,
  `review/slice-p4-photo-attach.md`,
  `review/slice-p5-next-plan-suggestions.md`

## Scope Decision

- Scope status: `PROCEED`
- Why this review is within budget or why it must stop: toàn bộ diff story so với
  `bfe231aa` là **52 file / +5955 −138** dòng dưới `mobile/`, vượt xa ngân sách
  compact lẫn full review. Vì vậy story đã được chia thành 5 slice độc lập, mỗi
  slice đọc mã nguồn trong phạm vi của mình và đã trả kết quả. Pass này **không**
  đọc lại mã nguồn: nó đọc 5 báo cáo slice + `story_master.md` +
  `visual-fidelity/visual-fidelity-report.md`, đối chiếu tập file bằng
  `git diff --name-status bfe231aa`, và kết luận ở tầng story. Ngân sách vì vậy
  nằm trong giới hạn.
- Current story or bug status: `Status: IN_PROGRESS` trong `story_master.md`;
  cả 5 phase P1-P5 `DONE` trong `coding-plan/master-plan.md` mục 5; nhánh
  `codex/REQ-016_solo_stage1_relationship_assistant-STORY-007_thank_you_and_next_plan`,
  HEAD `32f20f0a`, BaseHead `bfe231aa`.

## Governing Inputs

- Primary artifacts: `requirements/requirements.md` (AC-1..AC-7, AC-14..AC-26,
  AC-28..AC-30, AC-35, AC-36; BR-1..BR-3, BR-6, BR-8, BR-9, BR-11, BR-14,
  BR-16..BR-18), `story_master.md`, `architecture/solution.md` §3/§4,
  `architecture/contract-summary.md`, `coding-plan/master-plan.md` mục 2/5,
  `req_master.md` (R-1b, R-1c, R-1g, R-8, R-15/R-15a/R-15b,
  `## Design Ruling Log` hàng 2026-09-23 `CONTENT_GATE_CATEGORY_COUPLING` và
  `JOURNAL_SOURCE_CONTRACT_CLOSED`).
- Existing review findings: 5 báo cáo slice liệt kê ở `## Identity`, tất cả đều
  ghi **0 phát hiện chặn**.
- Test evidence: `coding-plan/test-results.md` §P1..§P5, cộng 5 lần chạy lại độc
  lập do reviewer từng slice thực hiện trong worktree của story.
- Extra artifacts required beyond the default minimum:
  `visual-fidelity/visual-fidelity-report.md` cùng 3 PNG của nó (cần để phán
  quyết cặp `VISUAL_FIDELITY: PASS` + `DESIGN_SPEC_CONFLICT`).

## Source/Test Files In Scope

Tập dưới đây là **đúng 52 file** của `git diff --name-status bfe231aa -- mobile/`,
đã gán hết cho slice, **không còn file mồ côi**. `A` = thêm mới, `M` = sửa.

### Slice P1 — sổ kích hoạt + gợn sóng `schemaVersion` (31 file)

Nguồn (12):

- `M mobile/lib/core/database/cupid_database.dart`
- `M mobile/lib/core/database/cupid_database.g.dart`
- `A mobile/lib/core/database/tables/thank_you_activations_table.dart`
- `M mobile/lib/core/di/service_locator.dart`
- `A mobile/lib/features/activity_cards/thank_you/data/thank_you_activation_dao.dart`
- `A mobile/lib/features/activity_cards/thank_you/data/thank_you_activation_repository_impl.dart`
- `A mobile/lib/features/activity_cards/thank_you/domain/thank_you_activation.dart`
- `A mobile/lib/features/activity_cards/thank_you/domain/thank_you_activation_repository.dart`
- `A mobile/lib/features/activity_cards/thank_you/domain/thank_you_activation_service.dart`
- `A mobile/lib/features/activity_cards/thank_you/domain/thank_you_activation_card_status_listener.dart`
- `A mobile/lib/features/activity_cards/thank_you/domain/thank_you_activation_card_status_repository.dart`
- `M mobile/lib/features/chapter_closure/data/stage1_wipe_registry.dart`

Test (19):

- `M mobile/test/core/database/activity_card_dao_test.dart`
- `M mobile/test/core/database/activity_card_migration_test.dart`
- `M mobile/test/core/database/calendar_event_state_migration_test.dart`
- `M mobile/test/core/database/chapter_closure_migration_test.dart`
- `M mobile/test/core/database/context_notebook_migration_test.dart`
- `M mobile/test/core/database/expense_dao_test.dart`
- `M mobile/test/core/database/journal_dao_test.dart`
- `M mobile/test/core/database/migration_v5_test.dart`
- `M mobile/test/core/database/relationship_labels_migration_test.dart`
- `M mobile/test/core/database/timeline_dao_test.dart`
- `A mobile/test/features/activity_cards/thank_you/thank_you_activation_card_status_repository_test.dart`
- `A mobile/test/features/activity_cards/thank_you/thank_you_activation_migration_test.dart`
- `A mobile/test/features/activity_cards/thank_you/thank_you_activation_service_test.dart`
- `M mobile/test/features/chapter_closure/stage1_wipe_registry_parity_test.dart`
- `M mobile/test/features/chapter_closure/stage1_wipe_service_test.dart`
- `M mobile/test/features/activity_cards/activity_type_test.dart` — gợn sóng
  phiên bản, slice P2 §2.6 đã xác nhận thuộc P1
- `M mobile/test/features/before_you_go/before_you_go_block_test.dart` — đăng ký
  `CupidDatabase` do decorator của P1 gây ra; slice P5 §3(1) đã phán quyết thuộc P1
- `M mobile/test/features/compatibility_lookup/relationship_label_repository_test.dart`
  — **mới gán ở pass này** (xem `### Hai file từng mồ côi`)
- `M mobile/test/features/your_view_portrait/portrait_answer_repository_test.dart`
  — **mới gán ở pass này** (xem `### Hai file từng mồ côi`)

### Slice P2 — khung khối + điểm gắn (5 file)

- `M mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart`
- `A mobile/lib/features/activity_cards/thank_you/presentation/thank_you_block_cubit.dart`
- `A mobile/lib/features/activity_cards/thank_you/presentation/widgets/thank_you_block.dart`
  (phần khung; khe ảnh của cùng file thuộc P4)
- `M mobile/test/features/activity_cards/activity_card_detail_screen_test.dart`
- `M mobile/test/features/activity_cards/card_lifecycle_ui_test.dart`

### Slice P3 — danh mục preset "cảm ơn sau hẹn" (3 file)

- `M mobile/lib/features/invite_composer/domain/preset_content_gate.dart`
- `A mobile/assets/data/req016/presets.thank_you_after_date.v1.json`
- `M mobile/test/features/invite_composer/preset_content_gate_test.dart`

### Slice P4 — đính ảnh (8 file)

- `A mobile/lib/features/activity_cards/thank_you/data/attachable_photos.dart`
- `A mobile/lib/features/activity_cards/thank_you/presentation/widgets/photo_attach_section.dart`
- `A mobile/lib/features/activity_cards/thank_you/presentation/widgets/thanks_section.dart`
- `M mobile/lib/features/journal/data/journal_repository.dart`
- `M mobile/lib/features/journal/journal_entry_point.dart`
- `A mobile/test/features/activity_cards/thank_you/photo_attach_test.dart`
- `A mobile/test/features/activity_cards/thank_you/thank_you_block_test.dart`
  (slice P4 §A5 nhận file này, đóng advisory A4 của P2)
- `A mobile/test/features/activity_cards/thank_you/thanks_section_test.dart`

### Slice P5 — gợi ý "chốt việc kế tiếp" (5 file)

- `A mobile/lib/features/activity_cards/thank_you/domain/next_plan_suggestion_service.dart`
- `A mobile/lib/features/activity_cards/thank_you/presentation/next_plan_cubit.dart`
- `A mobile/lib/features/activity_cards/thank_you/presentation/widgets/next_plan_section.dart`
- `M mobile/lib/features/activity_cards/domain/activity_card.dart` (slice P5 §3(2b)
  nhận làm bằng chứng của mình — hiện thực trực tiếp AC-24)
- `A mobile/test/features/activity_cards/thank_you/next_plan_test.dart`

### Hai file từng mồ côi — đã kiểm và gán ở pass này

`mobile/test/features/compatibility_lookup/relationship_label_repository_test.dart`
(+12 −6) và `mobile/test/features/your_view_portrait/portrait_answer_repository_test.dart`
(+9 −4) không nằm trong danh sách file của bất kỳ slice nào. Pass này đã đọc
diff của cả hai: chúng cùng **một loại thay đổi duy nhất** với 3 file gợn sóng
"vượt mức" mà slice P1 §1.6 đã nghiệm thu — cập nhật assertion
`schemaVersion`/`user_version` lên `10`, đổi tên group từ số phiên bản cứng
(`v6 -> v8`, `v8 on a fresh install`, `v6 -> v7`) sang `current`, và thêm
`DROP TABLE chapter_closure_items` + `DROP TABLE chapter_closures` vào fixture v6
vì `Migrator.createIndex` phát `CREATE INDEX` trần. Sửa nằm **ở fixture**, không
chạm migration chạy trên máy người dùng; không assertion nào bị nới lỏng hay xoá.
Gán về **slice P1**, không có phát hiện chặn.

## Evidence Files In Scope

- `.../STORY-007_thank_you_and_next_plan/coding-plan/test-results.md` (§P1..§P5)
- `.../STORY-007_thank_you_and_next_plan/coding-plan/master-plan.md`
- `.../STORY-007_thank_you_and_next_plan/coding-plan/phase-P1..P5-*.md`
- `.../STORY-007_thank_you_and_next_plan/architecture/solution.md`
- `.../STORY-007_thank_you_and_next_plan/architecture/contract-summary.md`
- `.../STORY-007_thank_you_and_next_plan/requirements/requirements.md`
- `.../STORY-007_thank_you_and_next_plan/ux/uiux-spec.md`
- `.../STORY-007_thank_you_and_next_plan/visual-fidelity/visual-fidelity-report.md`
  và 3 PNG `design-reference-`, `implemented-`, `state-khong-anh-sb-212-...-ios.png`
- `.../STORY-007_thank_you_and_next_plan/review/slice-p1..p5-*.md`
- `data/requirements/REQ-016_solo_stage1_relationship_assistant/req_master.md`
- `data/bugs/master_bugs_list.md` (`BUG-20260923-002`, `BUG-20260924-001`)

Ghi chú vệ sinh nhánh (không phải file nguồn): diff so với `bfe231aa` còn chứa
`A data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-013_graceful_exit_and_return/visual-fidelity/implemented-j13-man-quay-lai-ios.png`
— một PNG thuộc **STORY-013**, ngoài phạm vi story này. Xem mục `## 7` của
`review/review-report.md`.

## Risk Surfaces And Critical Gates

- Touched risk surfaces: `DRIFT_SCHEMA_COLLISION`, `ACTIVATION_RULES_UNTESTABLE`,
  `LOCAL_DATE_RULE_UNVERIFIED`, `SILENCE_PENALTY_LEAK` (P1);
  `SECOND_DESTINATION` / `SECOND_PRIMARY_ACTION` (P2, P4);
  `CONTENT_GATE_CATEGORY_COUPLING` (P3);
  `JOURNAL_SOURCE_CONTRACT_CLOSED`, `JOURNAL_METADATA_LEAK` (P4);
  `SECOND_CARD_CREATION_PATH` (P5).
- Source-of-truth artifacts or contracts: `architecture/solution.md` §3/§4 (bảng
  Risk Surfaces, Boundaries And Ownership), `requirements/requirements.md` AC/BR,
  `req_master.md` `## Design Ruling Log` hai hàng 2026-09-23.
- Critical gates to verify: một bump `schemaVersion` 9→10 cộng thêm; ngữ nghĩa
  kích hoạt một-lần-trọn-đời; không bề mặt trừng phạt/streak/bộ đếm/%; layering
  DAO→repository→service và chiều import ADR-010; đúng một điểm gắn, không
  destination mới, không hành động chính cấp thẻ thứ hai; `decline_door` theo
  phạm vi danh mục chứ không phải công tắc toàn cục; nhật ký chỉ lộ đường dẫn
  ảnh, không văn bản/siêu dữ liệu; tạo thẻ qua đúng một đường của STORY-001.
- Mandatory web Playwright/browser-e2e gate: `NOT_APPLICABLE in ordinary continue`
- Requirement visual audit evidence: `NOT_APPLICABLE`
- Mandatory mobile e2e/emulator/signing/store gate: `NOT_APPLICABLE in ordinary continue`
- Requirement mobile visual audit evidence: `PRESENT` —
  `visual-fidelity/visual-fidelity-report.md`, `VISUAL_FIDELITY: PASS`,
  `Design-Screen: sb-212-cam-on-chot-viec-ke-tiep`, 3 PNG 415x900 ios, dựng bằng
  `RepaintBoundary.toImage` trong widget test của chính story (fallback đã có
  tiền lệ STORY-006 P2 / STORY-003 P3 cho bề mặt không tới được bằng điều hướng).
- Missing gate evidence or blocker: `N/A`

## Query Keys

- AC ids: AC-1..AC-7 (kích hoạt, khung khối, điểm gắn), AC-8 (renderer STORY-002),
  AC-14..AC-18 (đính ảnh — **đúng tập AC của phần 2**, không phải AC-4/AC-5),
  AC-19..AC-24 (chốt việc kế tiếp), AC-25/AC-26/AC-28 (không trừng phạt),
  AC-29/AC-30 (ngoại tuyến, không AI), AC-33..AC-36 (cổng nội dung, N là dữ liệu).
- Rules: BR-1, BR-2, BR-3, BR-6, BR-8, BR-9, BR-11, BR-14, BR-16, BR-17, BR-18,
  R-1b, R-1c, R-1g, R-15, R-15a, R-15b, ADR-010.
- Risk surface ids: xem `## Risk Surfaces And Critical Gates`.
- Headings: `## Design Ruling Log`, `## DESIGN_SPEC_CONFLICT`, `## Authority note`,
  `### Sai lệch so với handoff`, `### Deltas inside phần 2 — accepted`,
  `### Deltas inside phần 3 — accepted`, `## 5. Phase Table`.
- Symbols: `schemaVersion`, `thankYouActivations`, `ThankYouActivationService`,
  `ThankYouActivationAwareCardRepository`, `ThankYouSection`, `ThankYouBlockCubit`,
  `_declineDoorCategories`, `journalPhotoPathsForOrigin`, `mergeAttachablePhotos`,
  `NextPlanSuggestionService.suggest`, `ActivityCardOrigin.nextPlanAfterDate`,
  `maxNextPlanSuggestions`.
- Commands: `git -C <Worktree> diff --name-status bfe231aa -- mobile/`;
  `git log --oneline -S'CONTENT_GATE_CATEGORY_COUPLING' main -- .../req_master.md`.
- Test names: `mọi bảng REQ-016 trong lược đồ đều có mặt trong registry`;
  `chạm một chip tạo ngay thẻ *Mới nghĩ ra* trong kho chung`;
  `kho ảnh hỏng thì mất khe phần 2, không mất cả khối (AC-25)`.

## Phase 2 Approval

- Phase 2 may proceed: `YES`
- If `NO`, final review outcome should be: `N/A`
- If `NO`, exact blocker or re-scope instruction: `N/A`

Xung đột template được ghi nhận, không tự hấp thụ im lặng: enum `Review type`
trong `.claude/skills/reviewer/assets/scope_gate_template.md` không có thành viên
nào cho `scoped-slice` lẫn `final-synthesis`, dù cả hai đều là chế độ Reviewer
điều phối được. Giá trị thật của pass này được ghi nguyên văn thay vì ép vào một
thành viên enum sai.
