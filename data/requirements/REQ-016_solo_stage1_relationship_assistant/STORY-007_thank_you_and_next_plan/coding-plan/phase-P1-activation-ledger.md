# Phase P1 – Lượt kích hoạt một lần trọn đời

## 1. Objective

Lớp dữ liệu + luật vòng đời cho "một lượt kích hoạt cho mỗi thẻ, trọn đời":
arm khi thẻ sang *Đã đi rồi*, chỉ đủ điều kiện trình bày từ ngày lịch kế tiếp,
tiêu thụ vĩnh viễn ở lần trình bày đầu, huỷ lặng lẽ khi thẻ rời trạng thái.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-activation-ledger.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/activity_cards/thank_you/data/` (bảng drift,
    DAO, repository — bind tên module ở bước 1)
  - `mobile/lib/features/activity_cards/thank_you/domain/` (service
    vòng đời)
  - lớp drift database của app: bump `schemaVersion` + migration
  - `mobile/test/features/activity_cards/thank_you/` (unit test)
  - các file test hiện có đang assert `schemaVersion` (sửa assertion)
- Impacted Runtime Service/App:
  - Name: mobile
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - service vòng đời lượt kích hoạt (arm / cancel / consume / eligibility)
- Shared Interfaces Consumed:
  - mô hình thẻ + tín hiệu đổi trạng thái của STORY-001 (AC-14)
- Risk Surfaces:
  - Lượt kích hoạt một lần trọn đời
  - Biên ngày lịch địa phương
  - Bump `schemaVersion` của drift
  - Không phạt im lặng
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` mục 4
  - consumer contract: P2 đọc `eligibility` và gọi `consume`
- Primary Inputs Summary:
  - requirements: AC-1..AC-5, AC-25, BR-2, BR-3
  - architecture: `../architecture/solution.md` mục 1, 4, 6
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cụm hành vi — vòng đời lượt kích hoạt
  - Source/Test File Count: ~6 (bảng+migration, DAO, repository, service, 2 test)
  - Split Required: NO

## 2. Required Reads

- `../requirements/` (Nhóm A, Business Rules BR-2/BR-3)
- `../architecture/solution.md`

## 3. Tasks

- Bind đã xong, không phải việc của P1 nữa: module là
  `mobile/lib/features/activity_cards`, database là
  `mobile/lib/core/database/cupid_database.dart`, bảng đặt tại
  `mobile/lib/core/database/tables/` cạnh `activity_cards_table.dart` —
  bảng của story này **không** nằm trong thư mục feature, vì mọi bảng drift
  của app đều khai báo tập trung ở `core/database/tables/`.
- `schemaVersion` hiện hành trên base là **9**; bump lên **10** đúng một lần và
  viết migration cho bảng mới. Nếu khi bắt đầu P1 con số đã khác 9, một story
  song song đã bump trước — **dừng** với `DRIFT_SCHEMA_COLLISION` thay vì bump
  chồng, vì nhánh thứ hai sẽ không bao giờ chạy migration.
- Tạo bảng trạng thái lượt kích hoạt: khoá chính là id thẻ; các cột trạng thái
  (`ARMED` / `CONSUMED` / `CANCELLED`), ngày arm (ngày lịch địa phương), mốc
  tiêu thụ.
- Viết DAO + repository: upsert khi arm, chuyển trạng thái, truy vấn theo thẻ.
- Viết service vòng đời với 4 thao tác: `arm` (chỉ khi chưa có bản ghi nào cho
  thẻ đó), `cancel` (chỉ từ `ARMED`), `consume` (**idempotent**; gọi lại trên
  `CONSUMED` là no-op), `isEligible` (đúng khi trạng thái `ARMED` **và** ngày
  lịch địa phương hôm nay **lớn hơn** ngày arm).
- Nối `arm` / `cancel` vào tín hiệu đổi trạng thái thẻ của STORY-001 mà
  **không** sửa lược đồ bảng thẻ.
- Sửa các assertion `schemaVersion` đang đỏ ở các file test hiện có.

## 4. Acceptance Criteria

- `arm` trên một thẻ đã có bản ghi `CONSUMED` hoặc `CANCELLED` là no-op — hai
  trạng thái này **hấp thụ**, không có đường quay lại `ARMED` (AC-4, AC-5).
- `isEligible` sai trong cùng ngày arm, đúng từ ngày lịch kế tiếp (AC-1, AC-2).
- Không thao tác nào ghi bộ đếm, huy hiệu, streak, hay cờ "đã bỏ lỡ" (AC-25).
- Bộ test của app xanh trở lại sau khi bump `schemaVersion`.

## 5. Planned Outputs

- Code directories: `.../thank_you/data/`, `.../thank_you/domain/`, lớp drift
  database (bump + migration)
- Notes or evidence: tên module đã bind + `schemaVersion` cũ/mới ghi vào
  `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, lớp dữ liệu/domain, không UI
- Required levels:
  - unit: service vòng đời + DAO
  - integration: migration drift từ phiên bản trước lên phiên bản mới
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
- Required checks:
  - 5 chuyển trạng thái: arm; `isEligible` sai cùng ngày; `isEligible` đúng
    sang ngày mới; `consume` rồi `arm` lại (no-op); rời *Đã đi rồi* khi còn
    `ARMED` → `CANCELLED` rồi `arm` lại (no-op).
  - Biên ngày: cùng một thẻ ở 23:59 và 00:01 cho kết quả `isEligible` khác
    nhau; một trường hợp đổi timezone không làm lượt kích hoạt sống lại.
  - `consume` gọi hai lần không đổi `consumedAt`.
- Minimum gates by risk surface: mọi risk surface liệt kê ở `## 1B` phải có ít
  nhất một assertion trực tiếp.
- Required regression or contract coverage: các test hiện có assert
  `schemaVersion` phải xanh sau khi sửa.
- Evidence format: lệnh + số test pass/fail ghi vào `coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase này không dựng UI.
- Verification strategy:
  - Targeted tests: `flutter test` giới hạn ở thư mục test của sub-feature +
    các file test `schemaVersion` bị ảnh hưởng.
  - Build/type-check: `flutter analyze lib test`. **Baseline không phải 0** —
    repo có warning tồn đọng; gate là **không thêm error mới**, không phải exit
    code 0.
  - Required assertion evidence: trích dòng kết quả test thật, không tóm tắt.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-20
