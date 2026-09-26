# Scope Gate — STORY-012 (lượt S10, tái review sau `PATCH_REQUIRED` của S9)

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Review type: `full-story-review`
Review report path: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/review/review-report.md`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget`
BaseHead (handoff): `b58afbe073eff4e1ebb9151735221532a9cf5a82`
Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget`

## Quyết định phạm vi: mốc là commit báo cáo S9, không phải BaseHead

Handoff nêu `BaseHead b58afbe0`. Dựng lại toàn bộ dải đó là 109 tệp — vượt xa
hạn mức 12 tệp của `full-story-review` (SKILL rule 1c), và handoff S10 nói rõ:
không làm lại lượt một, S8 đã chấm AC1–AC8, S9 đã chấm B-2..B-6.

Phạm vi S10 = **delta của lượt sửa**, tức `git diff 802b3fa6..HEAD` (hai commit
`6496c4f5` + `6ee190eb`) = **1 tệp source** (`phase_status_line.dart`),
3 tệp artefact, 12 đường ảnh (11 rename + 1 recapture). Dưới hạn mức.

Ba finding phải đóng thật ở lượt này: **B-1a**, **B-7**, **N-7**.

## Source/Test Files In Scope

1. `mobile/lib/features/phase_status/presentation/phase_status_line.dart`
   (+42/-24) — B-1a, đọc theo hunk `_PhaseStatusAction`.

Không tệp source/test nào khác bị delta này chạm → B-2..B-6 và AC1–AC8 kiểm
bằng `git diff --name-only`, không đọc lại mã.

## Evidence Files In Scope

- `story_master.md` (9.9 KB) — diff `802b3fa6..HEAD` + dòng `Design-Screen`.
- `architecture/solution.md` (29 KB) — **chỉ** §8/§8b (quy ước tên B-7). Đọc
  theo dải sau khi Grep.
- `ux/uiux-spec.md` (20 KB) — **chỉ** §1, bản vá B-1 ngày 2026-09-26. Đọc theo
  dải sau khi Grep.
- `coding-plan/test-results.md` (140 KB) — **chỉ** mục `## Lượt patch #4`
  (N-7). Grep trước, Read theo dải. Không đọc toàn tệp.
- `visual-fidelity/visual-fidelity-report.md` (63 KB) — **chỉ** bảng ghép cặp
  và ô 1 của lượt patch mới. Grep trước, Read theo dải.
- `review/review-report.md` bản S9 — đã đọc: B-1a, B-7, N-7 và bảng cổng.

Hai artefact > 20 KB đọc theo dải: `test-results.md`, `visual-fidelity-report.md`.

**Không đọc**: `coding-plan/master-plan.md`, phase file P1–P12,
`slice-S1..S6b.md`, `requirements/requirements.md` (delta không chạm),
`contract-summary.md`.

## Ảnh phải mở bằng mắt (rule 12e3)

Ô 1 được chụp lại sau khi sửa chip, nên bắt buộc mở lại chính cặp đó:

- `implemented-ngan-da-hen-ngay-dang-doi-waiting.png` ↔
  `design-reference-ngan-da-hen-ngay-dang-doi-ios.png` (ô 1 — B-1a)

Sáu ô còn lại (2–7) chỉ **đổi tên tệp**, nội dung byte không đổi (`git diff -M`
báo rename 100%). Không mở lại — S9 đã soi và delta không sửa pixel nào.

## Bề mặt rủi ro đã chạm ở delta này và cổng tối thiểu

| Bề mặt rủi ro | Cổng tối thiểu | Kết |
|---|---|---|
| design fidelity (12e2/12e3) ô 1 | ảnh implemented + reference mở bằng mắt | xem B-1a ở báo cáo |
| cổng bằng chứng thị giác (`visual_fidelity.py`) | script `--stage review --stack mobile` exit 0, tự chạy | xem B-7 ở báo cáo |
| mobile interaction (chip hành động phụ) | test widget `phase_status_line` xanh; đích chạm + vùng chạm ≥44dp giữ nguyên | xem báo cáo |
| frontend/mobile static analysis | `flutter analyze` trên `lib/features/phase_status` 0 error | xem báo cáo |
| bằng chứng test (N-7) | mục `## Lượt patch #4` có lệnh + kết quả thật | xem báo cáo |

Bề mặt **không** bị delta chạm, kế thừa S8/S9: native widget Android/iOS,
hợp đồng `action_label`, cổng bất biến AC-39, build APK, runtime smoke, entry
point reachability, configuration guide.

## Query Keys

`_PhaseStatusAction`, `radiusButton`, `colorText`, `colorAccentPink`,
`colorSurface`, `colorLine`, `Lượt patch #5`, `Lượt patch #4`, `§8b`,
`Design-Screen`, `VISUAL_FIDELITY`, `AC9`, `B-1a`, `B-7`, `N-7`.

## Phase 2 được tiếp tục?

CÓ. Không thiếu input thượng nguồn nào.
