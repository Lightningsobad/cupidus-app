# Phase P7 – Dòng trạng thái theo pha + đếm ngược trên màn (1)

## 1. Objective

Đưa bốn pha lên màn (1) thành **một** dòng trạng thái đọc được trong một nhịp
mắt, cộng đếm ngược cho thẻ sắp tới. Pha `waiting` không được biến thành đồng hồ
đếm sự im lặng của người kia.

## 1A. Ownership

- Phase ID: P7
- Canonical Phase File: `phase-P7-phase-line-and-countdown.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: NO (sửa `activity_card_hub_view.dart`, dùng chung với P8)
- Write Scope:
  - `mobile/lib/features/phase_status/presentation/phase_status_cubit.dart`
  - `mobile/lib/features/phase_status/presentation/phase_status_line.dart`
  - `mobile/lib/features/activity_cards/presentation/activity_card_hub_view.dart`
  - `mobile/lib/features/activity_cards/presentation/activity_card_tile.dart`
  - `mobile/lib/features/activity_cards/presentation/activity_card_detail_screen.dart`
  - `mobile/test/features/phase_status/phase_status_line_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
- Shared Interfaces Produced:
  - `PhaseStatusCubit` (P8 gắn vào cùng cubit, không tạo cubit thứ hai)
- Shared Interfaces Consumed:
  - P2 `resolveSoloPhase`, P1 gói `phase_content.v1.json`,
    P4 `pushWidgetPayload` (gọi khi mount/resume)
- Risk Surfaces:
  - `VISUAL-FIDELITY`
  - `WIDGET-STALE`
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §1, §3
  - consumer contract: P8 mở rộng cùng cubit và cùng view
- Primary Inputs Summary:
  - requirements: AC-1..AC-13, AC-15, BR-1..BR-4
  - architecture: `../architecture/solution.md` §3 UI Delivery Anchor, §4
    (`VISUAL-FIDELITY`, `WIDGET-STALE`)
  - upstream phase outputs: P1, P2, P4
  - UX constraints: `../ux/uiux-spec.md` §1 bảng bốn pha, §3 đếm ngược
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: dòng trạng thái + đếm ngược, một cụm hiển thị
  - Source/Test File Count: 2 source mới + 3 file sửa + 1 test
  - Split Required: NO

## 2. Required Reads

- `../requirements/` nhóm A, B, C
- `../ux/uiux-spec.md` §1, §3
- `../architecture/solution.md` §3 UI Delivery Anchor
- `mobile/lib/features/activity_cards/presentation/activity_card_hub_view.dart`
- Bản thiết kế màn (1) mà `../ux/uiux-spec.md` neo tới

## 3. Tasks

- `PhaseStatusCubit`: gọi `resolveSoloPhase` (P2), tra chữ từ gói
  `phase_content.v1.json` (P1), phát một state duy nhất cho cả dòng trạng thái
  lẫn các bề mặt P8. **Không** suy pha lần hai ở lớp presentation.
- Nạp lại khi màn (1) mount và khi app resume; cùng lúc đó gọi
  `pushWidgetPayload` (P4) để widget và app không lệch nhau (`WIDGET-STALE`).
  Không timer, không stream định kỳ.
- `PhaseStatusLine`: một dòng cho mỗi pha, chữ đến từ gói. Pha `quiet` **có thể**
  không có gì để hiện; khi đó widget dòng trả `SizedBox.shrink()`, không khung
  rỗng, không skeleton.
- Đếm ngược cho pha `upcoming` theo `../ux/uiux-spec.md` §3: đơn vị ngày dân
  dụng, không giờ-phút-giây, không thanh tiến độ.
- Pha `waiting` **không** hiện số ngày đã đợi, không "đã gửi N ngày trước",
  không đổi màu theo độ trễ (AC-7/BR-3).
- Thẻ `scheduled` có ngày đã qua: hiện trung tính, không câu trách móc, không
  nhắc dọn dẹp (AC-15).
- Sửa `activity_card_tile.dart` và `activity_card_detail_screen.dart` **chỉ** để
  hiển thị pha; không đổi model, không đổi repository, không thêm cột (BR-12).
- Chữ Việt cần đủ dấu; kiểm codepoint của `Text` dựa vào cmap của font chữ được
  bundle trước khi chốt ảnh chụp.

## 4. Acceptance Criteria

- Bốn pha hiện đúng dòng của mình, lấy từ gói nội dung, không chuỗi cứng (AC-1,
  AC-37).
- `BeforeYouGoPhase == null` vẫn cho pha `dateDay` đúng (AC-2).
- Không đếm ngày chờ, không leo thang, không chỉ báo hành vi người kia (AC-7/BR-3).
- Đếm ngược chỉ ở `upcoming`, theo ngày, không giờ-phút-giây (AC-9..AC-11).
- Ngày đã qua hiện trung tính (AC-15).
- Pha `quiet` không nội dung → không khung rỗng nào xuất hiện (BR-2).
- Widget đồng bộ với màn (1) ngay sau mount/resume (AC-33).

## 5. Planned Outputs

- Code directories or files: `mobile/lib/features/phase_status/presentation/`,
  `mobile/lib/features/activity_cards/presentation/`
- Notes or evidence: `coding-plan/test-results.md`, ảnh chụp đối chiếu thiết kế

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: widget test Flutter
- Required levels:
  - widget: bốn pha, nhánh `quiet` rỗng, đếm ngược, ngày quá khứ
  - mobile build/type-check/static-analysis: `flutter analyze lib test`, đếm *error*
- Required checks:
  - test khẳng định pha `waiting` **không** render chữ số nào (AC-7)
  - test khẳng định `pushWidgetPayload` được gọi đúng một lần mỗi lần mount
  - test khẳng định không chuỗi hiển thị cứng trong
    `phase_status_line.dart` (mọi chữ đến từ gói)
  - regression: các test hiện có của `activity_card_hub_view` vẫn xanh; nếu một
    `tap()` trượt vì màn cao thêm, nới khung test chứ không sửa layout
- Minimum gates by risk surface: `VISUAL-FIDELITY`, `WIDGET-STALE`
- Required regression or contract coverage: `mobile/test/features/activity_cards/`
- Evidence format: `flutter test` output + đường dẫn ảnh chụp
- Per-story visual fidelity: `ActivityCardHubView` nằm sau cổng solo nên không
  tới được bằng điều hướng thường; chụp `RepaintBoundary` trong chính widget test
  của phase này, đối chiếu bản thiết kế màn (1), và ghi giá trị `Design-Screen`
  do người cài đặt xác định sau khi dựng (Tech Lead không gán trước)
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/phase_status/ test/features/activity_cards/`
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: tên test, số pass/fail, đường dẫn ảnh chụp và
    nhận xét đối chiếu từng vùng

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-11
