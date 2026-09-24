# Scope Gate — STORY-008 (rework re-review 2026-09-24)

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES
Review report path: data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-008_date_script_three_parts/review/review-report.md

Review type: `compact-story-review`, lượt 2 (khắc phục F-1/F-2/F-3 của lượt
2026-09-17). Baseline diff: `58ff2e56` → `dcacbc56`, 2 commit, không có mã sản
phẩm nào thay đổi.

## Source/Test Files In Scope

- `mobile/lib/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart`
  (dòng 125-147 — hàng `prepare_action_date_script`, kiểm F-2)
- `mobile/lib/features/date_script/date_script_entry_point.dart`
  (toàn file, 33 dòng — `openDateScriptScreen`, kiểm F-2)
- `mobile/test/features/date_script/date_script_screen_test.dart`
  (dòng 36-65, 180-260, 556-615 — `_visualEvidenceDir`, `_loadDesignFonts`,
  helper chụp `RepaintBoundary`)

Không đọc lại P1-P4: lượt 1 đã review toàn bộ mã hiện thực và cho PASS ở mọi
cổng trừ 3 finding chặn.

## Evidence Files In Scope

- `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-008_date_script_three_parts/review/review-report.md`
  (báo cáo lượt 1 — baseline finding F-1/F-2/F-3, D-1..D-5)
- `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-008_date_script_three_parts/visual-fidelity/visual-fidelity-report.md`
- `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-008_date_script_three_parts/visual-fidelity/design-reference-9-kich-ban-buoi-hen-ios.png`
  (mở xem tận mắt)
- `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-008_date_script_three_parts/visual-fidelity/implemented-screen-9-ba-cua-ra-ios.png`
  (mở xem tận mắt + quét pixel đo lề, kiểm D-1)
- `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-008_date_script_three_parts/coding-plan/test-results.md`
  (đọc theo dải: §384-547 — `## Entry Point Reachability`,
  `## Story Runtime Startup Smoke`)
- `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-008_date_script_three_parts/story_master.md`
  (chỉ header `Design-Screen:`, đọc qua diff)

## Query Keys

`VISUAL_FIDELITY`, `Design-Screen`, `Reachable`, `Runtime Id`, `Registry`,
`Ready Check`, `Result`, `Shutdown`, `prepare_action_date_script`,
`openDateScriptScreen`, `_visualEvidenceDir`

## Touched Risk Surfaces

Mobile navigation/discoverability (điểm vào) · design fidelity (`ui_surface:
true`, `design_source` CHỐT) · runtime khởi động story. Không có bề mặt lưu
trữ, hợp đồng kiểu, hay mạng nào bị lượt khắc phục này chạm tới.

## Phase 2 Verdict

Proceed — verification tập trung vào đúng 3 finding chặn, sau đó dừng ở cổng
design-fidelity vì quy ước đặt tên file làm cặp ảnh không ghép được (F-4, xem
`review-report.md` mục `## Rework Re-Review 2026-09-24`).
