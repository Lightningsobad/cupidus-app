# Phase P6 – Bề mặt "Chuẩn bị" (cửa vào) + ô nhập địa điểm

## 1. Objective

Thay snackbar stub của hành động chính "Chuẩn bị" bằng bề mặt thật: một sheet
danh sách lựa chọn, trong đó "Xuất lời mời" là mục đầu tiên và duy nhất của
story này. Đồng thời nối ô nhập `location` vào form chi tiết thẻ để biến
mad-libs `place` có dữ liệu thật.

## 1A. Ownership

- Phase ID: P6
- Canonical Phase File: `phase-P6-prepare-entry-surface-and-location-field.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P3, P5
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart`
  - `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart`
  - `mobile/test/features/invite_composer/prepare_actions_sheet_test.dart`
  - `mobile/test/features/activity_cards/activity_card_detail_screen_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `showPrepareActionsSheet(context, card)` — danh sách lựa chọn mà STORY-006
    và STORY-008 sẽ **thêm mục vào**, không thay thế
- Shared Interfaces Consumed:
  - `showInviteComposerSheet` (P5)
  - `ActivityCardEdit.location` (P3)
- Risk Surfaces:
  - Cửa vào và SC-4
  - Trung thực thị giác của hai sheet
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §1, §4, §8
  - consumer contract: STORY-006, STORY-008 (thêm mục vào cùng danh sách)
- Primary Inputs Summary:
  - requirements: AC-1, AC-2, AC-3, AC-4, AC-12, AC-13
  - architecture: `../architecture/solution.md` §1 Key Discovery 1 và 2, §3 UI
    Delivery Anchor
  - upstream phase outputs: P5 sheet soạn lời mời, P3 cột `location`
  - UX constraints: `../ux/uiux-spec.md` §1 ("Xuất lời mời" là **một lựa chọn
    trong danh sách**, không phải nút thay nhãn "Chuẩn bị"), §4 (đóng sheet quay
    về chi tiết thẻ, không về danh sách), §8
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cụm — đường đi từ thẻ tới sheet soạn lời mời. Ô nhập
    `location` nằm cùng phase vì nó ghi cùng file `activity_card_detail_screen.dart`;
    tách ra sẽ tạo hai phase ghi chung một file.
  - Source/Test File Count: 4
  - Split Required: NO

## 2. Required Reads

- `../requirements/` (AC-1..AC-4, AC-12, AC-13)
- `../ux/uiux-spec.md` §1, §4, §5, §8
- `../architecture/solution.md` §1 Key Discovery 1 và 2, §3 UI Delivery Anchor
- P5 output: `showInviteComposerSheet`

## 3. Tasks

- Thay nhánh `ActivityCardPrimaryAction.prepare` trong `_runPrimaryAction`
  (hiện đang hiện snackbar "Phần chuẩn bị nằm ở bước sau") bằng
  `showPrepareActionsSheet`. Xoá hẳn snackbar stub và ghi chú của nó.
- `prepare_actions_sheet.dart`: sheet danh sách lựa chọn, mục "Xuất lời mời" mở
  `showInviteComposerSheet` với `categoryId: 'invite'`. Cấu trúc phải là danh
  sách nhiều mục ngay từ đầu, kể cả khi hiện chỉ có một mục — STORY-006/008 nối
  thêm mục, không sửa lại hình dạng sheet.
- Nếu danh mục không giải ra gói preset nào, mục "Xuất lời mời" **không xuất
  hiện** trong danh sách. Không mở sheet rỗng, không màn lỗi (AC-27).
- Đóng sheet quay về **chi tiết thẻ**, không về danh sách; không mất dữ liệu
  thẻ (BR-3, UX §4).
- Thêm ô nhập `location` vào form chi tiết thẻ, cùng dạng với các trường tuỳ
  chọn đang có, ghi qua `ActivityCardEdit` (nhớ ngữ nghĩa toàn-ảnh: chuỗi rỗng
  phải quy về `null` để xoá cột).
- **Không** thêm hành động chính thứ hai lên thẻ, không thêm route, không thêm
  mục vào tab bar hay menu chính, không thêm mục vào dải lối-vào-nhanh 3 ô
  (AC-2/AC-3/UX §8).
- **Không** thêm UI đếm số lần đã xuất lời mời và không thêm biểu tượng "đã
  gửi" chồng lên toggle *chưa/đã trả lời* sẵn có (UX §4).
- Bấm "Chưa trả lời": đổi trạng thái trong im lặng — không toast, không
  animation kịch tính, không gợi ý nhắn lại (AC-12/UX §5).

## 4. Acceptance Criteria

- Thẻ *Đã hẹn ngày* vẫn có **đúng một** hành động chính; đi theo nó tới được
  sheet soạn lời mời gắn đúng thẻ đó (AC-1/AC-2).
- "Xuất lời mời" không xuất hiện ở tab bar, menu chính, hay dải lối-vào-nhanh,
  và không có route mới nào được đăng ký (AC-3).
- Nhập địa điểm trên thẻ → mở sheet → biến `place` đã được điền (AC-4 khép kín
  cùng P1/P3).
- Đóng sheet → quay về chi tiết thẻ với dữ liệu nguyên vẹn (BR-3).
- Không còn tham chiếu nào tới snackbar stub "Phần chuẩn bị nằm ở bước sau".

## 5. Planned Outputs

- Code directories or files:
  `mobile/lib/features/invite_composer/presentation/widgets/`,
  `mobile/lib/features/activity_cards/presentation/screens/`
- Notes or evidence: `../coding-plan/test-results.md`, ảnh chụp visual fidelity

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, chi tiết thẻ + sheet lựa chọn
- Required levels:
  - integration: widget test đi trọn đường thẻ → "Chuẩn bị" → "Xuất lời mời" →
    sheet soạn lời mời
  - unit: chuẩn hoá chuỗi rỗng → `null` cho `location`
  - mobile build/type-check/static-analysis: có
  - visual inspection: có
- Required checks:
  - đúng một hành động chính trên thẻ *Đã hẹn ngày*
  - không route mới, không mục menu/tab bar mới
  - mục "Xuất lời mời" vắng mặt khi không giải ra gói preset
  - đóng sheet quay về chi tiết thẻ, dữ liệu còn nguyên
  - `location` ghi và đọc lại đúng, chuỗi rỗng xoá cột
  - không widget nào đếm số lần xuất lời mời
- Mobile discoverability / navigation integration: đây là phase cửa vào của
  story. "Xuất lời mời" đến được **chỉ** qua hành động chính "Chuẩn bị" của thẻ
  *Đã hẹn ngày*; không destination riêng, đúng mô tả "hành động (11)".
- Minimum gates by risk surface:
  - Cửa vào và SC-4: widget test đi trọn đường + khẳng định không thêm route
- Required regression or contract coverage: toàn bộ
  `mobile/test/features/activity_cards/` vẫn xanh; đặc biệt các test đang khẳng
  định nhãn/số lượng hành động chính của thẻ. Thêm một hàng vào form chi tiết
  có thể đẩy widget ra ngoài khung mặc định 800x600 và làm `tap()` của test
  khác trượt — chỉnh kích thước khung trong test, không đổi bố cục sản phẩm.
- Evidence format: đầu ra `flutter test` + ảnh chụp, dán vào
  `../coding-plan/test-results.md`
- Per-story visual fidelity (REQUIRED — phase dựng sheet lựa chọn mới và đổi
  form chi tiết thẻ):
  - Design screen id + how it is rendered: implementer tự phân giải và khoá id
    sau khi render, theo `contracts/design-fidelity-spec.md` mục "Design source
    detection and locking"; render bằng `capture-mobile-screen.sh --mode=design`.
  - How the implemented screen is captured: `capture-mobile-screen.sh` trên
    sheet "Chuẩn bị" đã mở và trên chi tiết thẻ có ô địa điểm. Nếu không tới
    được từ runtime, chụp trong chính widget test của story bằng
    `RepaintBoundary`.
  - NOTE: cổng của **chính story này**, kiểm ở review của nó; không được thoả
    bằng hay hoãn sang audit cấp requirement. Không tới được thiết bị/runtime
    nào thì chặn với `MOBILE_RUNTIME_UNAVAILABLE`.
  - Ảnh chụp phải được nhìn bằng mắt: một lần chụp xanh vẫn có thể chứa ô tofu
    nếu ký tự tiếng Việt thiếu trong font đang bundle.
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/activity_cards/ test/features/invite_composer/`
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: số test pass/fail + ảnh chụp hai bề mặt

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-10
