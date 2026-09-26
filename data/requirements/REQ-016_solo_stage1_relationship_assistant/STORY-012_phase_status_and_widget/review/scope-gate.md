# Scope Gate — STORY-012 (lượt S9, tái review sau `PATCH_REQUIRED` của S8)

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Review type: `full-story-review`
Review report path: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/review/review-report.md`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget`
BaseHead (handoff): `b58afbe073eff4e1ebb9151735221532a9cf5a82`
Worktree HEAD lúc review: `63a15bb06938d9896ee2ad8a23b61fffec50b54c`

## Quyết định phạm vi: mốc là commit báo cáo S8, không phải BaseHead

Handoff đề nghị dựng lại toàn bộ `b58afbe0..HEAD` (109 tệp). Đó vẫn vượt xa
hạn mức 12 tệp của `full-story-review` (SKILL rule 1c), và lượt này là lần tái
review **thứ hai**: S1–S6b (lát cắt), S7 (tổng hợp), S8 (tái review sau rework
P9–P12) đều đã chấm và đã commit.

Phạm vi S9 = delta kể từ commit ghi báo cáo S8 (`5d23250f`), tức
`git -C <Worktree> diff 5d23250f..HEAD`: 31 tệp, trong đó **15 tệp
source/test/config**. Sáu finding chặn B-1..B-6 của S8 được kiểm lại trực tiếp
trên delta này; mọi kết luận S1–S8 mà delta không chạm tới thì kế thừa.

15 tệp source/test/config vượt nhẹ hạn mức 12. Không tách lát cắt vì phạm vi
thực tế là **sáu finding có tên**, không phải sáu vùng mã độc lập: mỗi tệp
được đọc theo đúng hunk của finding, không tệp nào đọc toàn bộ.

## Source/Test Files In Scope

Native/widget:
1. `mobile/android/app/src/main/kotlin/com/snapsofts/cupid/CupidPhaseWidgetProvider.kt` (+107/-4) — B-2, B-5, B-6
2. `mobile/android/app/src/main/res/drawable/widget_bg_phase_date_day.xml` (mới) — B-2
3. `mobile/android/app/src/main/res/drawable/widget_bg_phase_flat.xml` (mới) — B-2
4. `mobile/android/app/src/main/res/layout/cupid_phase_widget.xml` (+10/-8) — B-4
5. `mobile/android/app/src/main/res/xml/cupid_phase_widget_info.xml` (+8/-2) — B-3
6. `mobile/ios/CupidPhaseWidget/CupidPhaseWidget.swift` (+8/-1) — B-6

Dart/nội dung:
7. `mobile/assets/data/req016/phase_content.v1.json` (+6/-5) — B-1, B-3
8. `mobile/lib/features/phase_status/domain/phase_content.dart` (+71/-2) — B-1, B-3
9. `mobile/lib/features/phase_status/presentation/phase_status_cubit.dart` (+12) — B-1
10. `mobile/lib/features/phase_status/presentation/phase_status_line.dart` (+67/-5) — B-1
11. `mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart` (+7) — B-1

Test:
12. `mobile/test/features/phase_status/phase_content_repository_test.dart` (+138)
13. `mobile/test/features/phase_status/phase_status_line_test.dart` (+50)
14. `mobile/test/features/phase_status/phase_content_gate_test.dart` (+25/-1)
15. `mobile/test/features/phase_status/native_copy_scan_test.dart` (+13)

## Evidence Files In Scope

(artefact chi phối và bằng chứng đọc ở lượt này)

- `story_master.md` (9 KB) — AC9 (đã vá), Lane, Complexity, Design-Surface,
  Design-Screen, trạng thái Artifacts.
- `requirements/requirements.md` — **chỉ diff** `5d23250f..HEAD` (vá B-1 trên
  AC-5, vá B-1/B-3 trên AC-37, vá BR-15).
- `ux/uiux-spec.md` — **chỉ diff** (§1 vá B-1; §2 vá B-3/B-4/B-6).
- `architecture/contract-summary.md` + `architecture/solution.md` — **chỉ
  diff** (§3a giá trị `--dot-today`, §3b nền theo pha, §3c số cỡ lớn, §4a
  `action_label` + ngân sách 28).
- `visual-fidelity/visual-fidelity-report.md` (49 KB) — chỉ dòng 1–3 verdict,
  mục "Đặt cặp ảnh" + "Hai cổng đang đòi hai quy ước tên trái nhau"
  (dòng 75–121), và mục "Lượt patch #4" (dòng 703–807). Đọc theo dải.
- `review/review-report.md` bản S8 — bảng finding chặn B-1..B-6 và N-1..N-6.

Một artefact lớn > 20 KB đọc theo dải (`visual-fidelity-report.md`); không đọc
lại `coding-plan/test-results.md` (133 KB) vì delta **không chạm** tệp đó —
xem N-7.

**Không đọc**: `scrum-master-checkpoint.md` (handoff chỉ định bỏ qua),
`coding-plan/master-plan.md`, các phase file P1–P12, `slice-S1..S6b.md`.

## Ảnh phải mở bằng mắt (rule 12e3)

Đã mở, không nhận trên lời khai:

- `implemented-hub-waiting.png` ↔ `design-reference-ngan-da-hen-ngay-dang-doi-ios.png` (ô 1, B-1)
- `implemented-widget-date-day.png` ↔ `design-reference-sb-84-widget-bon-pha-ios.png` (ô 7, B-2/B-3/B-4/B-6)
- `implemented-widget-upcoming.png` (B-5 — cụm số "4"; B-3 — dòng phụ đủ)
- `implemented-widget-waiting.png` (B-2 — nền phẳng không dính gradient; B-4)

## Bề mặt rủi ro đã chạm ở delta này và cổng tối thiểu

| Bề mặt rủi ro | Cổng tối thiểu | Kết |
|---|---|---|
| design fidelity (12e2/12e3) | ảnh implemented + reference mở bằng mắt, verdict `VISUAL_FIDELITY` | **FAIL một phần** — xem B-1a |
| typed/generated contract (`action_label`, ngân sách 28 grapheme) | test nạp asset thật + fixture vượt ngân sách | PASS (mã + test có mặt) |
| mobile interaction (chip hành động phụ) | test widget dựng/không-dựng chip + đích chạm | PASS |
| build native Android (drawable + span mới) | `flutter build apk --debug --flavor local --split-per-abi` xanh | PASS (lượt patch #4) |
| app lifecycle / runtime smoke | app cài + chạy, `adb logcat` sạch | PASS (lượt patch #4) |
| operational command (registry buildCommand) | lệnh registry chạy được | vẫn lệch — N-2, chủ DevOps |
| cổng bằng chứng thị giác (`visual_fidelity.py`) | script exit 0 ở `--stage review` | **exit 1** — xem B-7 |

## Query Keys

`AC9`, `AC-5`, `AC-37`, `BR-15`, `B-1`..`B-6`, `action_label`,
`phaseContentShortStringBudget`, `_PhaseStatusAction`, `backgroundFor`,
`numeralFor`, `secondaryFor`, `DOT_TODAY`, `ON_ACCENT`, `TEXT_ON_GRADIENT`,
`displaySizedNumeral`, `minWidth`, `VISUAL_FIDELITY`, `Lượt patch #4`.

## Phase 2 được tiếp tục?

CÓ. Không thiếu input thượng nguồn nào.
