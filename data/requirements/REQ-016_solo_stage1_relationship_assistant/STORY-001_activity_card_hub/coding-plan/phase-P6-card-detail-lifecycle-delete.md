# Phase P6 – Chi tiết thẻ, chuyển trạng thái hai chiều, và xoá

## 1. Objective

Cho người dùng xem/sửa đầy đủ trường SB-76, chuyển trạng thái theo cả hai chiều
mà không mất dữ liệu âm thầm, và xoá thẻ bằng một hộp thoại trung tính.

## 1A. Ownership

- Phase ID: P6
- Canonical Phase File: `phase-P6-card-detail-lifecycle-delete.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P4
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/activity_cards/presentation/activity_card_detail_cubit.dart`
  - `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart`
  - `mobile/lib/features/activity_cards/presentation/widgets/status_change_picker.dart`
  - `mobile/lib/features/activity_cards/presentation/widgets/delete_card_dialog.dart`
  - `mobile/test/features/activity_cards/activity_card_detail_screen_test.dart`
  - `mobile/test/features/activity_cards/card_lifecycle_ui_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - Màn chi tiết thẻ full-screen — chỗ STORY-006/007 lồng khối mở rộng vào sau
- Shared Interfaces Consumed:
  - repository thẻ, `primaryActionFor` (P2); màn hub (P4)
- Risk Surfaces:
  - AC-15 mất dữ liệu âm thầm khi lùi trạng thái
  - SC-4/SC-5 — đúng một hành động chính, không ngõ cụt
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §5, §7
  - consumer contract: STORY-006/007 lồng khối vào màn này
- Primary Inputs Summary:
  - requirements: AC-8, AC-12, AC-13, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19
  - architecture: `../architecture/solution.md` §4 Contracts And Integrations
  - upstream phase outputs: P4
  - UX constraints: `../ux/uiux-spec.md` §5, §7
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cụm — chi tiết thẻ và vòng đời.
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` §5, §7
- `../requirements/requirements.md` Nhóm C, Nhóm D
- `../architecture/contract-summary.md` §3, §4

## 3. Tasks

- Màn chi tiết **full-screen** (không bottom sheet) để STORY-006/007 lồng khối
  mở rộng vào sau; sửa được toàn bộ trường SB-76, tất cả tuỳ chọn trừ tiêu đề.
- Hành động chính của *Mới nghĩ ra* mở date picker; lưu ngày và chuyển sang *Đã
  hẹn ngày* trong một thao tác (AC-12).
- Hàng "Chuyển trạng thái" mở picker 4 lựa chọn, không giới hạn hướng (AC-14).
- Lùi từ *Đã hẹn ngày* về *Mới nghĩ ra*: hộp thoại "Giữ ngày hẹn đã lưu hay xoá
  luôn?" với 2 lựa chọn rõ ràng, **không** lựa chọn mặc định ngầm là xoá; nhánh
  "giữ" là mặc định an toàn (AC-15).
- Xoá thẻ: một hộp thoại "Xoá thẻ này?", không hỏi lý do, không câu cảm xúc, hai
  nút ngang hàng thị giác, chỉ nút "Xoá" mang màu `--red` (AC-16). Xoá thẻ dọn
  luôn file ảnh mà app sở hữu.
- Toggle "đã rủ": chỉ hai giá trị, chỉ đổi khi người dùng bấm; không timestamp,
  không nhãn thời gian, không suy luận (AC-17, AC-18).
- Chế độ "ghi lại" (Đã đi rồi) và "xem lại" (Đã thành kỷ niệm) là hai chế độ của
  cùng màn này; *Đã thành kỷ niệm* vẫn có đường xoá nên không phải ngõ cụt (AC-13).

## 4. Acceptance Criteria

- Đặt ngày từ *Mới nghĩ ra* chuyển thẻ sang *Đã hẹn ngày* và thẻ hiện ở đúng ngăn (AC-12).
- Chuyển được tới cả 4 trạng thái theo hai chiều (AC-14).
- Lùi trạng thái không xoá âm thầm ngày hẹn/ghi chú/ảnh (AC-15).
- Xoá và xác nhận làm thẻ biến mất, không câu trách móc, không hỏi lý do (AC-16).
- Màn không hiển thị bất kỳ chỉ báo hành vi người kia nào (AC-18) và không kết
  luận/chấm điểm người kia (AC-19).

## 5. Planned Outputs

- Code: detail cubit, màn chi tiết, picker trạng thái, hộp thoại xoá.
- Notes: bằng chứng test và ảnh chụp màn ghi vào `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, tầng presentation
- Required levels:
  - unit: detail cubit lưu trường, đặt ngày, đổi trạng thái, xoá
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
  - visual inspection: ảnh chụp màn chi tiết ở chế độ ghi lại và xem lại
- Required checks:
  - Widget test AC-15: lùi trạng thái rồi chọn "giữ" → `scheduled_on`, ghi chú,
    ảnh còn nguyên; chọn "xoá" mới bỏ, và không nhánh nào là mặc định ngầm.
  - Widget test AC-16: hộp thoại xoá không chứa trường lý do và không chuỗi cảm xúc.
  - Widget test AC-13: ở *Đã thành kỷ niệm* vẫn có "Xem lại" và đường xoá.
  - Widget test AC-17/AC-18: toggle "đã rủ" đúng hai giá trị, không nhãn thời gian.
- Minimum gates by risk surface: hai risk surface ở §1B đều có gate ở trên.
- Evidence format: output `flutter test` + ảnh chụp màn, ghi vào `coding-plan/test-results.md`.
- Per-story visual fidelity: REQUIRED
  - Design screen id + cách render: implementer phát hiện và khoá id theo
    `contracts/design-fidelity-spec.md`, render bằng
    `capture-mobile-screen.sh --mode=design`.
  - Cách chụp màn đã hiện thực: `capture-mobile-screen.sh`.
  - NOTE: gate của chính story này, không hoãn sang audit cấp requirement; không
    tới được runtime thì block bằng `MOBILE_RUNTIME_UNAVAILABLE`.
- Verification strategy:
  - Targeted tests: `flutter test test/features/activity_cards/`
  - Build/type-check: `flutter analyze lib test`
  - Required assertion evidence: tên test + kết quả pass, kèm ảnh chụp so sánh.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-07
