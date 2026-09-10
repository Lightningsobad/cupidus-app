# Phase P3 – Màn danh sách nhật ký + luồng xoá

## 1. Objective

Dựng màn "Nhật ký riêng": danh sách mục theo thời gian, đọc toàn văn, trạng thái
rỗng trung tính, xoá một mục và xoá toàn bộ — và làm cho sự **vắng mặt** của
chia sẻ/xuất/streak trở thành thứ kiểm chứng được bằng test.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-journal-list-screen-and-delete.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: YES (với P4; hai phase ghi vào các file rời nhau ngoại trừ ARB)
- Write Scope:
  - `mobile/lib/features/journal/presentation/journal_list_cubit.dart`
  - `mobile/lib/features/journal/presentation/screens/journal_screen.dart`
  - `mobile/lib/l10n/arb/app_vi.arb`
  - `mobile/lib/l10n/arb/app_en.arb`
  - `mobile/test/features/journal/journal_list_cubit_test.dart`
  - `mobile/test/features/journal/journal_screen_test.dart`
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
  - `JournalScreen` (đích điều hướng cho P5)
- Shared Interfaces Consumed:
  - `JournalRepository`, `JournalEntry` (P2)
- Risk Surfaces:
  - Trôi dạt "cho vui" thành streak/mục tiêu
  - Rò rỉ nội dung ra ngoài (chia sẻ/xuất/mạng/AI)
  - File ảnh mồ côi sau khi xoá
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` mục 2, 4, 5, 7
  - consumer contract: P5 (điều hướng vào màn)
- Primary Inputs Summary:
  - requirements: AC-1, AC-5, AC-6, AC-7, AC-11, AC-12, AC-14, BR-4, BR-7, BR-10
  - architecture: `../architecture/solution.md` section 3 `UI Delivery Anchor`,
    section 4 `Contracts And Integrations`
  - UX constraints: `../ux/uiux-spec.md` mục 2 (bố cục), mục 4 (vắng mặt bắt
    buộc của affordance chia sẻ), mục 5 (hai luồng xoá), mục 7 (trạng thái rỗng)
  - upstream phase outputs: `JournalRepository` từ P2
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: đọc và xoá — một cụm hành vi
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` mục 2, 4, 5, 7
- `../architecture/solution.md` section 3 `UI Delivery Anchor`
- `mobile/lib/features/account/presentation/screens/me_screen.dart` chỉ để lấy
  khuôn header/`CupidHeader` và token màu đang dùng

## 3. Tasks

- `JournalListCubit` (Cubit thường, **không** `HydratedCubit`): stream mục từ
  repository theo trang, các action `deleteEntry`, `deleteAll`, và gọi
  `sweepOrphans()` một lần lúc khởi tạo.
- `JournalScreen`: header "Nhật ký riêng" + nút quay lại; danh sách mới nhất
  trên đầu với ngày, 1-2 dòng trích, thumbnail vuông đọc từ file cục bộ; chạm
  mở toàn văn; CTA "Viết điều gì đó" là hành động chính duy nhất.
- Không hiển thị số mục, chuỗi ngày, huy hiệu, hay thanh tiến trình ở bất kỳ
  đâu trên màn.
- Menu ngữ cảnh của một mục chỉ chứa **đúng một** hành động "Xoá" — không có
  mục chia sẻ/xuất kể cả ở dạng ẩn hay disabled.
- Xoá một mục: hộp thoại xác nhận trung tính, không hỏi lý do, không snackbar
  hoàn tác. Xoá toàn bộ: một hàng "Xoá toàn bộ nhật ký" ở menu header, **một**
  hộp thoại xác nhận duy nhất, không bước gõ lại chữ; sau xác nhận quay về đúng
  trạng thái rỗng lần đầu.
- Trạng thái rỗng: một dòng mô tả trung tính + đúng một CTA, không hình minh hoạ
  lớn, không lời thúc giục.
- Thêm chuỗi vào cả hai file ARB; không hardcode chuỗi trong widget.
- Không mở màn soạn ở phase này — nút CTA nối vào P4 khi P4 xong; trong P3 nó
  gọi một callback được inject, mặc định no-op.

## 4. Acceptance Criteria

- Màn rỗng và màn có ≥2 mục đều không render bất kỳ số đếm/chuỗi ngày/tiến
  trình nào.
- Cây widget của cả màn không chứa icon hay label chia sẻ/xuất/copy.
- Xoá một mục và xoá toàn bộ đều gọi đúng API repository và cập nhật danh sách
  ngay, không giữ bản sao trong state.
- Danh sách phân trang qua repository; state không giữ toàn bộ mục.

## 5. Planned Outputs

- Code directories or files: các file trong Write Scope
- Contracts or schemas: `JournalScreen` làm đích điều hướng cho P5
- Notes or evidence: ảnh chụp màn hình + bằng chứng test trong `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: mobile (widget test + Cubit test)
- Required levels:
  - unit: `journal_list_cubit_test.dart` — phát trạng thái rỗng/có dữ liệu,
    `deleteEntry`, `deleteAll`, gọi `sweepOrphans` đúng một lần
  - integration: `journal_screen_test.dart` — render rỗng và render ≥2 mục;
    luồng xoá một mục và xoá toàn bộ qua hộp thoại xác nhận
  - mobile build/type-check/static-analysis: analyze giới hạn `lib test`
  - visual inspection: ảnh chụp màn danh sách ở trạng thái rỗng và có dữ liệu
- Required checks:
  - widget test assert **không tìm thấy** widget nào có nhãn/icon chia sẻ, xuất,
    copy toàn bộ (đây là cách AC-6 nghiệm thu được)
  - widget test assert không có text khớp mẫu số đếm chuỗi ngày/streak (AC-1)
  - grep `mobile/lib/features/journal/**` không có import bị cấm ở
    `coding-agent-guide.md` mục 6
- Mobile discoverability / navigation integration: chưa áp ở phase này — điểm
  vào do P5 nối; P3 chỉ giao màn.
- Minimum gates by risk surface: `PRIVACY_EGRESS_GATE_UNRUNNABLE`,
  `STREAK_ABSENCE_TEST_UNRUNNABLE` (theo `../architecture/solution.md` section 4)
- Evidence format: lệnh + kết quả + đường dẫn ảnh chụp trong `test-results.md`
- Per-story visual fidelity: REQUIRED
  - Design screen id + how it is rendered: `../ux/uiux-spec.md` đầu file đã ghi
    `DESIGN_SOURCE_NOT_DETECTED` là bình thường cho story này — màn nhật ký là
    màn mới, không có khung thiết kế đối chiếu trong `design_source` đang khoá.
    Chạy bước dò design source cho màn này và **ghi lại kết quả thật**; nếu quả
    thật không có khung tương ứng thì ghi `DESIGN_SOURCE_NOT_DETECTED` kèm bằng
    chứng lệnh, không tự đặt ra một verdict khác.
  - How the implemented screen is captured: `capture-mobile-screen.sh` cho màn
    đã dựng, ở cả trạng thái rỗng và trạng thái có dữ liệu.
  - NOTE: đây là cổng riêng của story, kiểm ở review của story này; không hoãn
    sang audit mức requirement. Nếu không chạm được thiết bị/runtime nào thì
    phase chặn với `MOBILE_RUNTIME_UNAVAILABLE`, đây là blocker chứ không phải
    khoản hoãn.
- Verification strategy:
  - Targeted tests: chỉ hai file test của phase này
  - Build/type-check/lint command when required: analyze phạm vi `lib test` sau
    khi sinh l10n

## 7. Status

- Status: COMPLETE
- Last updated: 2026-09-08
- Blocker: NONE
- Evidence: `test-results.md` section "Phase P3";
  `../visual-fidelity/visual-fidelity-report.md` (`VISUAL_FIDELITY: PASS`)
- Note on the visual-fidelity gate: the earlier
  `MOBILE_VISUAL_AUDIT_SCREEN_UNREACHABLE` blocker is **resolved and withdrawn**.
  `capture-mobile-screen.sh` needs the screen to be reachable, and it is not from
  this phase (`JournalScreen` has no `previewScreens` entry and no route, since
  section 6 assigns the entry point to P5, and both files are out of Write
  Scope). The screen was instead rendered directly via `RepaintBoundary.toImage`
  inside `journal_screen_test.dart` — a Write Scope file — following the existing
  repo pattern at `test/features/reminders/visual_capture_support.dart`. Captures
  for both the empty and populated states now exist under `../visual-fidelity/`.
- Residual, not owned here: the iOS half of the DB-file backup exclusion lives in
  `mobile/lib/core/database/cupid_database.dart` (a P1 file, outside this Write
  Scope) and was left untouched.
