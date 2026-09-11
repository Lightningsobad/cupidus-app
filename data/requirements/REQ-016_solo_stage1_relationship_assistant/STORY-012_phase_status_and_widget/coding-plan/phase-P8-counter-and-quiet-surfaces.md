# Phase P8 – Bề mặt bộ đếm, cột mốc, tiến triển quà, và nhỏ giọt

## 1. Objective

Cho ba chính sách khoảng lặng của P3 một chỗ đứng trên màn (1), giữ đúng tinh
thần: đây là của cải đang lớn của người dùng, không phải bảng điểm.

## 1A. Ownership

- Phase ID: P8
- Canonical Phase File: `phase-P8-counter-and-quiet-surfaces.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P3, P7
- Parallelizable: NO (sửa `activity_card_hub_view.dart`, dùng chung với P7)
- Write Scope:
  - `mobile/lib/features/phase_status/presentation/wealth_counter_line.dart`
  - `mobile/lib/features/phase_status/presentation/gift_progress_block.dart`
  - `mobile/lib/features/activity_cards/presentation/activity_card_hub_view.dart`
  - `mobile/test/features/phase_status/wealth_counter_line_test.dart`
  - `mobile/test/features/phase_status/gift_progress_block_test.dart`
  - `mobile/test/features/phase_status/quiet_surfaces_capture_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
- Shared Interfaces Produced:
  - Không có; P8 là bề mặt cuối
- Shared Interfaces Consumed:
  - P3 `WealthCounter`/`MilestoneResolver`/`DripCadencePolicy`
  - P7 `PhaseStatusCubit` (gắn thêm vào cubit sẵn có, không tạo cubit mới)
  - `ActivityCardRepository.countsByStatus()` (đọc lại khi mount/resume)
- Risk Surfaces:
  - `VISUAL-FIDELITY`
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §5, §6
  - consumer contract: không phase nào tiêu thụ P8
- Primary Inputs Summary:
  - requirements: AC-20..AC-29, AC-38, BR-5..BR-9
  - architecture: `../architecture/solution.md` §4 Mobile Lane guardrails
    (dùng `countsByStatus()` sẵn có, **không** thêm `watchCountsByStatus`)
  - upstream phase outputs: P3, P7
  - UX constraints: `../ux/uiux-spec.md` §5 tiến triển quà + nhỏ giọt, §6 vị trí
    bộ đếm và caption cột mốc J12
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: bề mặt khoảng lặng trên màn (1)
  - Source/Test File Count: 2 source mới + 1 file sửa + 3 test
  - Split Required: NO

## 2. Required Reads

- `../requirements/` nhóm F, G + AC-38
- `../ux/uiux-spec.md` §5, §6
- `mobile/lib/features/phase_status/presentation/phase_status_cubit.dart` (P7)
- `mobile/lib/features/activity_cards/domain/activity_card_repository.dart`

## 3. Tasks

- `WealthCounterLine`: hiện giá trị `WealthCounter` ở đúng vị trí
  `../ux/uiux-spec.md` §6. Nguồn số là `countsByStatus()` **đọc lại khi mount và
  khi resume** — không thêm `watchCountsByStatus` vào repository, vì đó là file
  của STORY-001 và AC-24 vốn chỉ yêu cầu "khi họ mở màn (1)".
- Caption cột mốc J12 từ `MilestoneResolver`: hiện một lần rồi thôi, dạng câu
  nhận ra, **không nút**, không chia sẻ, không huy hiệu (AC-28/BR-8).
- `GiftProgressBlock`: khi có ý tưởng quà đang chạy thì hiện tiến triển theo
  §5; khi không có thì trả `SizedBox.shrink()` — **không** ô trống mời gọi, không
  CTA "thêm ý tưởng quà" (AC-21/BR-2).
- Nhỏ giọt: hỏi `DripCadencePolicy`; `null` → không dựng gì. Không thông điệp
  "đã hết", không chỉ số còn lại, không lịch hẹn lần sau (AC-38).
- Không phần trăm, không thanh %, không "chuỗi ngày", không so sánh với tuần
  trước ở bất kỳ bề mặt nào (BR-5/BR-7).
- Bộ đếm giảm khi xoá thẻ: hiện giá trị mới, không hộp thoại cảnh báo về việc
  "mất" gì (AC-29).

## 4. Acceptance Criteria

- Bộ đếm hiện đúng số thẻ `memory`, cập nhật khi mở lại màn (1) (AC-24/AC-25).
- Không màn nào hiện %, chuỗi ngày, điểm số, hay so sánh kỳ trước (BR-5/BR-7).
- Cột mốc là câu nhận ra, không hành động kèm theo (AC-28/BR-8).
- Không ý tưởng quà → không khối tiến triển, không CTA (AC-21).
- Kho nhỏ giọt cạn → màn (1) im lặng, không dấu vết (AC-38).
- Xoá thẻ làm bộ đếm giảm, không cảnh báo (AC-29).
- `ActivityCardRepository` không bị sửa (BR-12).

## 5. Planned Outputs

- Code directories or files: `mobile/lib/features/phase_status/presentation/`
- Notes or evidence: `coding-plan/test-results.md`, ảnh chụp đối chiếu thiết kế

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: widget test Flutter
- Required levels:
  - widget: bộ đếm, cột mốc, khối quà rỗng, nhỏ giọt `null`
  - mobile build/type-check/static-analysis: `flutter analyze lib test`, đếm *error*
- Required checks:
  - test quét cây widget đã dựng: không `Text` nào chứa `%`, `streak`, `chuỗi`,
    hay con số đếm ngày (BR-5/BR-7)
  - test trạng thái rỗng toàn phần (0 thẻ, 0 quà, kho nhỏ giọt cạn): màn (1) dựng
    được và **không** có nút mời gọi nào xuất hiện thêm
  - `git diff` khẳng định `activity_card_repository.dart` không nằm trong diff
  - regression: nếu thêm hàng làm một `tap()` cũ trượt khỏi khung 800x600 mặc
    định, nới khung test chứ không đổi layout
- Minimum gates by risk surface: `VISUAL-FIDELITY`
- Required regression or contract coverage: `mobile/test/features/activity_cards/`
  và test P7 vẫn xanh
- Evidence format: `flutter test` output + đường dẫn ảnh chụp
- Per-story visual fidelity: chụp `RepaintBoundary` trong
  `quiet_surfaces_capture_test.dart` (màn (1) sau cổng solo, không tới được bằng
  điều hướng thường), đối chiếu bản thiết kế màn (1) ở trạng thái khoảng lặng, và
  ghi giá trị `Design-Screen` do người cài đặt xác định sau khi dựng (Tech Lead
  không gán trước). Ảnh phải được **nhìn bằng mắt**: bản chụp xanh vẫn có thể đầy
  ô tofu nếu font thiếu glyph có dấu.
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/phase_status/ test/features/activity_cards/`
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: tên test, số pass/fail, đường dẫn ảnh chụp và
    nhận xét đối chiếu từng vùng

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-11
