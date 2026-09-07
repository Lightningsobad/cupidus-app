# Phase P1 – Journal persistence schema (Drift v3)

## 1. Objective

Thêm hai bảng device-authoritative của nhật ký vào `CupidDatabase` cùng một DAO
lọc theo `ownerUserId`, nâng `schemaVersion` 2 → 3 bằng migration thuần cộng
thêm, và khoá lại luật "cấm destructive-recreate" từ v3.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-journal-persistence-schema.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/core/database/tables/journal_entries.dart`
  - `mobile/lib/core/database/tables/journal_photos.dart`
  - `mobile/lib/core/database/daos/journal_dao.dart`
  - `mobile/lib/core/database/cupid_database.dart`
  - `mobile/test/core/database/journal_dao_test.dart`
  - `mobile/test/core/database/cupid_database_migration_v3_test.dart`
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
  - `JournalDao` (mọi phương thức nhận `ownerUserId`)
  - schema v3 của `CupidDatabase`
- Shared Interfaces Consumed:
  - `CupidDatabase` hiện có (`@DriftDatabase` duy nhất, ADR-010)
- Risk Surfaces:
  - Mất dữ liệu người dùng qua đường cache
  - Nội dung lộ sang tài khoản khác trên cùng máy
  - File ảnh mồ côi sau khi xoá
  - Trôi dạt "cho vui" thành streak/mục tiêu
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md`
    section 4 → `Entry Data Model`
  - consumer contract: P2 repository
- Primary Inputs Summary:
  - requirements: AC-2, AC-3, AC-5, AC-11, AC-12, AC-13, BR-4
  - architecture: `../architecture/solution.md` section 1 (Key Discovery 1-3),
    section 4 (`Entry Data Model`, `Boundaries And Ownership`)
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: lưu trữ quan hệ của mục nhật ký + migration
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` (section 1 Key Discovery, section 4 Entry Data Model)
- `mobile/lib/core/database/cupid_database.dart`
- `mobile/lib/core/database/daos/timeline_dao.dart` (khuôn DAO hiện có —
  **chỉ tham khảo cấu trúc**, không copy phần `SessionScopedStore`)

## 3. Tasks

- Định nghĩa `JournalEntries` và `JournalPhotos` đúng bảng cột ở
  `../architecture/solution.md` section 4; `JournalPhotos.entryId` là FK
  ON DELETE CASCADE và `relativePath` lưu đường dẫn **tương đối**.
- Viết `JournalDao` là `@DriftAccessor`. Mọi phương thức đọc/ghi/xoá **bắt buộc
  nhận `ownerUserId`** và đưa nó vào mệnh đề `where`; không tạo phương thức nào
  không có tham số này.
- Phương thức tối thiểu: `watchEntries(ownerUserId, {limit, offset})` sắp xếp
  `createdAt` giảm dần, `entryById(ownerUserId, id)`, `upsertEntry(...)` ghi đè
  đúng hàng (AC-3), `deleteEntry(ownerUserId, id)`,
  `deleteAllEntries(ownerUserId)`, và `liveEntryIds(ownerUserId)` để P2 đối
  chiếu quét ảnh mồ côi.
- Đăng ký hai bảng + DAO vào `@DriftDatabase`, nâng `schemaVersion` lên 3, thêm
  nhánh `if (from < 3) { createTable(journalEntries); createTable(journalPhotos); }`
  vào `onUpgrade`; không đụng nhánh `from < 2`.
- Thay comment migration hiện tại: ghi rõ **từ v3 trở đi `CupidDatabase` không
  còn là cache vứt được**, destructive-recreate bị cấm vì bảng nhật ký là dữ
  liệu người dùng không tái tạo được.
- **Không** đăng ký `JournalDao` như `SessionScopedStore` và không thêm
  `clearAll()` không lọc `ownerUserId`.
- Chạy `build_runner` để sinh lại `cupid_database.g.dart`.

## 4. Acceptance Criteria

- Schema v3 tạo được từ mới và nâng cấp được từ v2 mà dữ liệu v2 còn nguyên.
- Không có phương thức DAO nào truy cập bảng nhật ký mà thiếu `ownerUserId`.
- `deleteAllEntries` xoá hàng của đúng một owner trong một transaction.
- Không tồn tại cột `deletedAt`, cột đếm, cột streak, hay cột trạng thái chia sẻ.
- Không có `@DriftDatabase` thứ hai và không có file `.sqlite` mới.

## 5. Planned Outputs

- Code directories or files: các file trong Write Scope + `cupid_database.g.dart` sinh lại
- Contracts or schemas: `JournalDao`, schema v3
- Notes or evidence: bằng chứng test ghi vào `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: mobile (Dart/Drift, không cần thiết bị)
- Required levels:
  - unit: `journal_dao_test.dart` — chèn/sửa/đọc/xoá; user B không đọc được mục
    của user A; `deleteEntry` xoá kèm hàng ảnh (CASCADE); `upsertEntry` giữ
    nguyên `id` khi sửa
  - integration: `cupid_database_migration_v3_test.dart` — mở DB ở schema v2 có
    dữ liệu, nâng lên v3, assert dữ liệu v2 còn nguyên và hai bảng mới tồn tại
  - mobile build/type-check/static-analysis: analyze giới hạn `lib test`
- Required checks: grep schema xác nhận không có cột `deletedAt`/`streak*`/
  `goal*`/`count*`; grep `JournalDao` xác nhận không xuất hiện
  `SessionScopedStore`
- Minimum gates by risk surface: `MIGRATION_TEST_UNRUNNABLE`,
  `DAO_SCOPE_TEST_UNRUNNABLE` (theo `../architecture/solution.md` section 4)
- Evidence format: lệnh + kết quả tóm tắt trong `test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng màn UI nào.
- Verification strategy:
  - Targeted tests: chỉ hai file test của phase này
  - Build/type-check/lint command when required: analyze phạm vi `lib test` sau
    khi sinh l10n và `build_runner`

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-07
