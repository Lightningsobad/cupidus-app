# Phase P4 – Màn Mồi chuyện + nối điểm vào từ Trang chủ

## 1. Objective

Màn Mồi chuyện dựng được, cuộn vòng không bao giờ hết, có khe hỏi tại chỗ và
dải sự kiện sắp tới; cộng một nhánh duy nhất nối ô `conversationStarters` trên
dải lối vào nhanh của Trang chủ vào màn đó.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-screen-and-entry-point.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P3
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/conversation_starters/presentation/screens/conversation_starters_screen.dart`
  - `mobile/lib/features/conversation_starters/presentation/cubit/conversation_starters_cubit.dart`
  - `mobile/lib/features/conversation_starters/presentation/widgets/starter_line.dart`
  - `mobile/lib/features/conversation_starters/conversation_starters_entry_point.dart`
  - `mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart`
  - `mobile/test/features/conversation_starters/conversation_starters_screen_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE — phase này thêm một nhánh điều hướng, không
    đổi đường khởi động app
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `ConversationStartersEntryPoint` — mặt tiền dựng màn, để STORY-007 và các
    lối vào sau này gọi mà không phải biết Cubit
- Shared Interfaces Consumed:
  - `StarterSelector`, `CalendarEventService` (P3)
  - `AskOnTheSpotSlot` (`STORY-004/architecture/contract-summary.md` §2)
  - `QuickEntryCell.conversationStarters`
    (`mobile/lib/features/activity_cards/presentation/widgets/quick_entry_strip.dart`)
- Risk Surfaces:
  - Visual fidelity màn (6)
  - Hành vi hết-vòng với mọi N (AC-27/AC-28) — bề mặt UI của nó
  - Không mạng / không AI (AC-15/AC-16)
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` cho bố cục màn,
    `../architecture/solution.md` §1 Key Discovery 4 cho điểm nối
  - consumer contract: STORY-007
- Primary Inputs Summary:
  - requirements: AC-1..AC-10, AC-19, AC-21, AC-23..AC-25, AC-27, AC-28
  - architecture: `../architecture/solution.md` §3 UI Delivery Anchor, §4 Mobile
    Lane guardrails
  - upstream phase outputs: P3 selector + service
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một màn và lối vào của chính nó
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../requirements/` (Nhóm A, Nhóm B, Nhóm C, Nhóm F)
- `../ux/uiux-spec.md`
- `../architecture/solution.md` §1 Key Discovery 4, §3 UI Delivery Anchor
- `STORY-004/architecture/contract-summary.md` §2 — chỉ chữ ký `AskOnTheSpotSlot`
- `mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart`
  quanh `_openQuickEntryCell`

## 3. Tasks

- `ConversationStartersCubit` giữ `page` hiện tại, danh sách câu đã render, danh
  sách sự kiện hiển thị, và các action `nextPage`, `addEventToStore`,
  `dismissEvent`. Con trỏ vòng **chỉ** sống trong Cubit; không ghi xuống Drift,
  không ghi vào `SharedPreferences`.
- Màn: tiêu đề, danh sách `StarterLine`, một `AskOnTheSpotSlot` với
  `entryPointId: 'conversation_starters'`, một dải sự kiện sắp tới, và một nút
  "Gợi ý khác". `entryPointId` là nhãn — không thêm nhánh nào theo nó trong
  `AskOnTheSpotSlot`.
- Nút "Gợi ý khác" **luôn bật**. Không trạng thái tắt, không "đã xem hết", không
  chỉ báo "x/N", không thanh tiến độ. Với kho N nhỏ, bấm tiếp tục cuộn vòng.
- `StarterLine` chỉ hiện chữ và một hành động sao chép; không ô đánh dấu, không
  nút "đã dùng", không nút thích/không thích — mọi thứ đó là đo hành vi người
  kia (R-1b) hoặc ghi chép ngoài sổ tay (R-1f).
- Sự kiện: mỗi mục có "Thêm vào kho" và "Bỏ qua", gọi thẳng
  `CalendarEventService`. Sau khi thêm, mục biến mất khỏi dải và **không** có
  màn xác nhận nào dẫn sang thẻ vừa tạo.
- Nối lối vào: trong `_openQuickEntryCell`, thay nhánh snackbar "Sắp có" của
  `QuickEntryCell.conversationStarters` bằng một `Navigator.push` sang
  `ConversationStartersEntryPoint`. Đúng một nhánh — không đổi
  `QuickEntryCell`, không thêm route mới vào bảng route của app, không đụng
  nhánh `zodiacShell`.
- Không `DateTime.now()` trong Cubit; `today` tiêm vào từ entry point để test
  chốt được ngày.

## 4. Acceptance Criteria

- Từ Trang chủ, chạm ô "Mồi chuyện" mở màn Mồi chuyện; không còn snackbar
  "Sắp có" cho ô đó. Ô `zodiacShell` vẫn giữ nguyên hành vi cũ.
- Bấm "Gợi ý khác" nhiều lần hơn tổng số mục vẫn ra câu dùng được, không lần
  nào ra danh sách rỗng, không lần nào nút bị tắt.
- Trên màn không tồn tại: bộ đếm mục còn lại, phần trăm hoàn thành, chuỗi
  "đã xem hết", nút xuất/lưu ngoài sổ tay, hay bất kỳ điều khiển nào chấm điểm
  câu.
- Mọi câu liên quan đến người kia hiển thị đều kết thúc bằng dấu hỏi (R-1g đã
  được P1 chặn ở cổng nhập; đây là khẳng định ở tầng hiển thị).
- Chỉ một khe hỏi tại chỗ tồn tại trên màn tại một thời điểm.
- Không có lời gọi mạng nào phát sinh khi mở màn hoặc khi bấm "Gợi ý khác".

## 5. Planned Outputs

- Code directories or files: xem `Write Scope`.
- Contracts or schemas: `ConversationStartersEntryPoint`.
- Notes or evidence: `coding-plan/test-results.md`,
  `coding-plan/visual-fidelity.md` cùng ảnh chụp kèm theo.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, tầng UI widget
- Required levels:
  - widget: dựng màn với kho N = 2 và N = 12, bấm "Gợi ý khác" quá số mục, khẳng
    định không rỗng và nút vẫn bật; thêm/bỏ qua một sự kiện; sổ tay rỗng vẫn ra
    câu
  - widget (regression): `_openQuickEntryCell` — ô Mồi chuyện điều hướng, ô
    `zodiacShell` vẫn snackbar
  - mobile build/type-check/static-analysis: `flutter analyze lib test` — gate
    là zero analyzer **error**; exit code không phải gate
- Required checks: quét cây widget của màn, khẳng định không có chuỗi cấm nêu ở
  Acceptance Criteria
- Minimum gates by risk surface: hành vi hết-vòng phải test bằng N nhỏ hơn số
  mục mỗi trang, không chỉ bằng kho đầy đủ
- Required regression or contract coverage:
  `mobile/test/features/activity_cards/` cho màn hub, và bộ test
  `AskOnTheSpotSlot` của STORY-004
- Evidence format: lệnh `flutter test <đường dẫn>` và tóm tắt pass/fail trong
  `coding-plan/test-results.md`
- Per-story visual fidelity: **REQUIRED** — đây là phase duy nhất của story dựng
  màn hình thật, và màn tới được từ dải lối vào nhanh trên Trang chủ.
  - Cách chụp ưu tiên: chạy app và chụp màn Mồi chuyện sau khi vào từ Trang chủ.
  - Fallback được phép: bọc `RepaintBoundary` và chụp ngay trong widget test của
    chính phase này. Dùng `CupidAppBackground` và nạp font MaterialIcons của
    framework, nếu không icon sẽ ra ô tofu.
  - Bắt buộc nhìn bằng mắt ảnh đã chụp trước khi kết luận đạt: một lần chạy
    "xanh" vẫn có thể chứa glyph tofu ở chữ tiếng Việt.
- Verification strategy:
  - Targeted tests/regression/contract checks: như trên
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: bảng "số lần bấm → id câu hiện ra" cho N = 2,
    chứng minh vòng lặp; ảnh chụp màn kèm đối chiếu với `../ux/uiux-spec.md`

## 7. Status

- Status: DONE
- Last updated: 2026-09-17
