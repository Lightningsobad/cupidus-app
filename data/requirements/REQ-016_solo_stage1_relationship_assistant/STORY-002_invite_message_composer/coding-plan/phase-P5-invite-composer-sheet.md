# Phase P5 – Bottom sheet soạn lời mời

## 1. Objective

Dựng bottom sheet "Soạn lời mời": dải chip khung nhại, khối xem trước sửa được
tại chỗ, và nút "Chia sẻ" mở OS Share Sheet đồng thời ghi payload SB-125.

## 1A. Ownership

- Phase ID: P5
- Canonical Phase File: `phase-P5-invite-composer-sheet.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2, P4
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/invite_composer/presentation/invite_composer_cubit.dart`
  - `mobile/lib/features/invite_composer/presentation/widgets/invite_composer_sheet.dart`
  - `mobile/lib/features/invite_composer/presentation/widgets/frame_chip_strip.dart`
  - `mobile/lib/core/di/service_locator.dart`
  - `mobile/test/features/invite_composer/invite_composer_cubit_test.dart`
  - `mobile/test/features/invite_composer/invite_composer_sheet_test.dart`
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
  - `showInviteComposerSheet(context, card, categoryId)` — cửa gọi mà STORY-007
    và STORY-008 sẽ dùng lại với danh mục/ngữ cảnh khác
- Shared Interfaces Consumed:
  - `preset_catalogue` + `validatePresetPack` (P2)
  - `InvitePayloadRepository` (P4)
  - `renderInvite`, `MadLibsValues` (P1)
  - `SharePlus.instance.share(ShareParams)` — theo đúng tiền lệ đã kiểm chứng
    ở `mobile/lib/features/home/presentation/home_screen.dart`
- Risk Surfaces:
  - Cửa vào và SC-4
  - N là thuộc tính dữ liệu
  - Trung thực thị giác của hai sheet
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §2, §6
  - consumer contract: P6 (cửa vào), STORY-007/008 ngoài story
- Primary Inputs Summary:
  - requirements: AC-4, AC-5, AC-7, AC-14, AC-16, AC-17, AC-26, AC-27
  - architecture: `../architecture/solution.md` §3 UI Delivery Anchor, §4
  - upstream phase outputs: P2 gói preset, P4 repository payload
  - UX constraints: `../ux/uiux-spec.md` §2 (bố cục sáu mục từ trên xuống),
    §3 (không placeholder rỗng), §6 (danh mục là tham số ẩn, không có bộ chọn
    danh mục cho người dùng)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một bề mặt modal và cubit của nó.
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../requirements/` (AC-4..AC-7, AC-14, AC-16, AC-17, AC-26, AC-27)
- `../ux/uiux-spec.md` §1, §2, §3, §6
- `../architecture/contract-summary.md` §3, §4, §6
- P2 và P4 outputs

## 3. Tasks

- `invite_composer_cubit.dart`: load gói theo `categoryId`, giữ chỉ số khung
  đang chọn, render lại ngay khi đổi chip (không nút "áp dụng"), giữ bản sửa
  tay của người dùng tách khỏi bản render gốc.
- Chỉ số khung tính **modulo `pack.length`**. Không thông báo "đã hết", không
  màn ngõ cụt, không chỉ báo tiến độ, không hiển thị số lượng dưới bất kỳ dạng
  nào (AC-26/AC-27/R-15b). Không hằng số đếm preset ở bất kỳ đâu trong phase.
- `frame_chip_strip.dart`: hàng chip cuộn ngang; chip đang chọn nền `--pink`
  nhạt, chữ `body 17pt/600`; chip chưa chọn viền mỏng, chữ `colorTextMuted`.
  Với `length == 1` thì hiện đúng một chip, không ô trống giữ chỗ.
- `invite_composer_sheet.dart`: sheet bo `--r-sheet`, cao ~70%, kéo giãn tới
  full-screen, kéo xuống để đóng; khối xem trước bo `--r-card`, chạm để chuyển
  thành text field sửa tại chỗ (không mở màn soạn thảo riêng); pill full-width
  nền `--grad` nhãn "Chia sẻ".
- Bấm "Chia sẻ": ghi payload qua `InvitePayloadRepository` **trước**, rồi mở
  Share Sheet với văn bản cuối cùng (bản sửa tay nếu có). `ShareResult` **không**
  được đọc: không snackbar, không retry, không lưu kết quả (R-1b).
- Lần xuất đầu tiên của một thẻ đặt `activity_cards.invited = true` để toggle
  *chưa/đã trả lời* mà STORY-001 đã vẽ xuất hiện. Story này **không** vẽ lại
  toggle đó và không thêm biểu tượng "đã gửi" chồng lên nó.
- Không ô nhập người nhận, không icon kênh nhắn tin riêng, không bộ chọn danh
  mục (AC-16, UX §6).
- Nếu danh mục không giải ra gói nào, sheet **không** được mở rỗng — trạng thái
  đó do P6 xử lý bằng cách không hiện mục trong danh sách "Chuẩn bị".

## 4. Acceptance Criteria

- Mở sheet trên thẻ *Đã hẹn ngày* đủ trường → hiện ngay ít nhất một lời mời đã
  điền tên hoạt động, ngày hẹn, địa điểm (AC-4).
- Đổi chip → nội dung soạn lại tức thì bằng chính dữ liệu thẻ đó (AC-5).
- Sửa toàn văn rồi chia sẻ → bản đi ra là bản đã sửa (AC-7).
- Chia sẻ → payload có cấu trúc đã nằm trong `invite_messages` và Share Sheet
  được gọi đúng một lần; app không gửi tới ai (AC-16/AC-17).
- Hành vi giống hệt với gói N = 1 và gói N = 200; không widget nào hiện số
  lượng hay tiến độ (AC-26/AC-27).
- Không có nút gửi nào khác ngoài "Chia sẻ".

## 5. Planned Outputs

- Code directories or files: `mobile/lib/features/invite_composer/presentation/`
- Notes or evidence: `../coding-plan/test-results.md`, ảnh chụp visual fidelity

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, bottom sheet
- Required levels:
  - unit: cubit (đổi khung, quay vòng modulo, giữ bản sửa tay)
  - integration: widget test dựng sheet với gói giả N = 1 và N = 200
  - mobile build/type-check/static-analysis: có
  - visual inspection: có
- Required checks:
  - render ban đầu có đủ ba biến khi thẻ đủ trường
  - đổi chip render lại ngay, không nút phụ
  - sửa tại chỗ → văn bản chia sẻ là bản đã sửa
  - chia sẻ ghi đúng một hàng payload và gọi share đúng một lần
  - `ShareResult` không được đọc ở bất kỳ nhánh nào
  - không widget nào trong cây sheet hiện số lượng/tiến độ preset
- Mobile discoverability / navigation integration: sheet này **không** đăng ký
  route, không xuất hiện trong tab bar hay menu; đường tới nó do P6 giao.
- Minimum gates by risk surface:
  - N là thuộc tính dữ liệu: widget test chạy hai lần với N = 1 và N = 200
  - Cửa vào và SC-4: test khẳng định phase không thêm route/menu nào
- Required regression or contract coverage: `flutter test test/features/activity_cards/`
  vẫn xanh — thêm hàng/khối mới có thể đẩy widget ra ngoài khung mặc định
  800x600 và làm `tap()` của test khác trượt; nếu gặp, chỉnh kích thước khung
  trong test chứ không đổi bố cục sản phẩm.
- Evidence format: đầu ra `flutter test` + ảnh chụp, dán vào
  `../coding-plan/test-results.md`
- Per-story visual fidelity (REQUIRED — phase dựng màn UI mới):
  - Design screen id + how it is rendered: implementer tự phân giải và khoá id
    sau khi render, theo `contracts/design-fidelity-spec.md` mục "Design source
    detection and locking"; render bằng `capture-mobile-screen.sh --mode=design`.
  - How the implemented screen is captured: `capture-mobile-screen.sh` trên sheet
    đã mở. Nếu không tới được sheet từ runtime, chụp trong chính widget test của
    story bằng `RepaintBoundary` thay vì bỏ qua cổng.
  - NOTE: đây là cổng của **chính story này**, kiểm ở review của nó; không bao
    giờ được thoả bằng, hay hoãn sang, audit cấp requirement. Nếu không tới được
    thiết bị/runtime nào, phase chặn với `MOBILE_RUNTIME_UNAVAILABLE` — chặn,
    không phải hoãn.
  - Ảnh chụp phải được **nhìn bằng mắt**, không chỉ đọc mã thoát: một lần chụp
    xanh vẫn có thể chứa ô tofu nếu ký tự tiếng Việt không có trong font đang
    bundle.
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/invite_composer/ test/features/activity_cards/`
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: số test pass/fail + ảnh chụp sheet

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-10
