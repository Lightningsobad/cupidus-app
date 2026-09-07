# Phase P4 – Màn soạn / sửa mục nhật ký

## 1. Objective

Dựng màn soạn full-screen dùng chung cho ba đường vào: viết mới, sửa mục đã lưu,
và mở với nội dung điền sẵn (nền tảng cho hợp đồng điểm nhận ở P5). Đính ảnh đi
qua image picker của OS và dừng ở đó — không upload, không ghi vào thư viện ảnh.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-journal-composer-screen.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: YES (với P3)
- Write Scope:
  - `mobile/lib/features/journal/presentation/journal_composer_cubit.dart`
  - `mobile/lib/features/journal/presentation/screens/journal_composer_screen.dart`
  - `mobile/lib/l10n/arb/app_vi.arb`
  - `mobile/lib/l10n/arb/app_en.arb`
  - `mobile/test/features/journal/journal_composer_cubit_test.dart`
  - `mobile/test/features/journal/journal_composer_screen_test.dart`
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
  - `JournalComposerScreen` nhận nội dung điền sẵn — bề mặt mà P5 gói lại thành
    `openJournalComposer`
- Shared Interfaces Consumed:
  - `JournalRepository`, `JournalMediaStore` (P2)
- Risk Surfaces:
  - Rò rỉ nội dung ra ngoài (chia sẻ/xuất/mạng/AI)
  - Trôi dạt "cho vui" thành streak/mục tiêu
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` mục 3, 4, 6
  - consumer contract: `../architecture/contract-summary.md` section 3
- Primary Inputs Summary:
  - requirements: AC-2, AC-3, AC-4, AC-6, AC-8, AC-10, BR-5, BR-8, BR-9
  - architecture: `../architecture/solution.md` section 4 `Entry Data Model`
  - UX constraints: `../ux/uiux-spec.md` mục 3 (bố cục màn soạn, luật sửa ghi
    đè, placeholder tĩnh), mục 4 (không affordance chia sẻ), mục 6 (mở với
    trường điền sẵn)
  - upstream phase outputs: `JournalRepository`, `JournalMediaStore` từ P2
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: soạn/sửa một mục — một cụm hành vi
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` mục 3, 4, 6
- `../architecture/contract-summary.md` section 3
- `mobile/lib/features/gallery/presentation/gallery_upload_cubit.dart` **chỉ**
  để lấy khuôn gọi `pickMultiImage` với seam tiêm được cho test — dừng ở bước
  chọn ảnh, không lấy phần upload

## 3. Tasks

- `JournalComposerCubit` (Cubit thường, **không** `HydratedCubit`) với ba chế độ
  khởi tạo: trống, sửa một `entryId` có sẵn, và điền sẵn từ nội dung ngoài
  (`seedText` + `seedPhotoPaths` + `originRef`).
- Đặt `origin` = `manual` cho hai chế độ đầu và `external` cho chế độ điền sẵn;
  lưu `originRef` nguyên văn, **không** parse và **không** render.
- Ảnh mồi và ảnh người dùng chọn đều đi qua `JournalMediaStore.importPhoto` —
  mục nhật ký chỉ tham chiếu bản sao của chính nó.
- `JournalComposerScreen`: ô nhập tự giãn, thanh công cụ đính ảnh dưới bàn
  phím (chọn nhiều ảnh được), nút "Lưu" góc trên phải; tiêu đề đổi thành "Sửa"
  khi mở mục đã lưu.
- Lưu ở chế độ sửa **ghi đè đúng hàng cũ**, giữ nguyên `id`, không tạo bản sao,
  không hiện lịch sử phiên bản.
- Câu mồi viết, nếu có, là **một chuỗi tĩnh cố định** trong ARB hiển thị dạng
  placeholder mờ — không sinh động, không đổi mỗi lần mở, không gọi AI.
- Không nút chia sẻ/xuất/copy toàn bộ ở bất kỳ đâu trên màn soạn.
- Không lưu bản nháp ra đĩa; huỷ màn soạn là mất nội dung chưa lưu, đúng AC-13.
- Nội dung điền sẵn phải sửa/xoá được và **chỉ được lưu khi người dùng bấm
  "Lưu"** — app không tự ghi mục hộ người dùng.
- Thêm chuỗi vào cả hai file ARB.

## 4. Acceptance Criteria

- Lưu mục mới kèm nhiều ảnh tạo đúng một hàng entry + n hàng ảnh, ảnh nằm trong
  media root của nhật ký.
- Mở lại mục đã lưu, sửa chữ và ảnh, lưu: cùng `id`, không phát sinh hàng thứ hai.
- Mở ở chế độ điền sẵn rồi thoát mà không bấm "Lưu": không mục nào được tạo.
- Cây widget màn soạn không chứa affordance chia sẻ/xuất/copy.
- Placeholder mồi viết giống hệt nhau qua nhiều lần mở.

## 5. Planned Outputs

- Code directories or files: các file trong Write Scope
- Contracts or schemas: bề mặt màn soạn nhận nội dung điền sẵn cho P5
- Notes or evidence: ảnh chụp màn hình + bằng chứng test trong `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: mobile (widget test + Cubit test, image picker tiêm giả)
- Required levels:
  - unit: `journal_composer_cubit_test.dart` — ba chế độ khởi tạo; `origin`
    đúng giá trị; sửa giữ nguyên `id`; huỷ không tạo mục; ảnh mồi được sao chép
    chứ không tham chiếu đường dẫn caller
  - integration: `journal_composer_screen_test.dart` — nhập chữ, đính ảnh qua
    picker giả, lưu; mở chế độ sửa và ghi đè
  - mobile build/type-check/static-analysis: analyze giới hạn `lib test`
  - visual inspection: ảnh chụp màn soạn ở trạng thái trống và trạng thái có ảnh
- Required checks:
  - widget test assert không tìm thấy affordance chia sẻ/xuất/copy (AC-6)
  - test assert placeholder mồi viết bất biến qua nhiều lần dựng (BR-8)
  - grep `mobile/lib/features/journal/**` không có import bị cấm ở
    `coding-agent-guide.md` mục 6
- Mobile discoverability / navigation integration: chưa áp ở phase này — điểm
  vào do P5 nối.
- Minimum gates by risk surface: `PRIVACY_EGRESS_GATE_UNRUNNABLE` (theo
  `../architecture/solution.md` section 4)
- Evidence format: lệnh + kết quả + đường dẫn ảnh chụp trong `test-results.md`
- Per-story visual fidelity: REQUIRED
  - Design screen id + how it is rendered: như P3 — chạy bước dò design source
    cho màn soạn và ghi lại kết quả thật; `../ux/uiux-spec.md` đã báo trước
    `DESIGN_SOURCE_NOT_DETECTED` là bình thường vì đây là màn mới. Không tự đặt
    ra verdict khác khi không có khung đối chiếu.
  - How the implemented screen is captured: `capture-mobile-screen.sh` cho màn
    soạn ở trạng thái trống và trạng thái có ảnh đính kèm.
  - NOTE: cổng riêng của story, kiểm ở review của story này, không hoãn sang
    audit mức requirement. Không chạm được thiết bị/runtime thì chặn với
    `MOBILE_RUNTIME_UNAVAILABLE`.
- Verification strategy:
  - Targeted tests: chỉ hai file test của phase này
  - Build/type-check/lint command when required: analyze phạm vi `lib test` sau
    khi sinh l10n

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-07
