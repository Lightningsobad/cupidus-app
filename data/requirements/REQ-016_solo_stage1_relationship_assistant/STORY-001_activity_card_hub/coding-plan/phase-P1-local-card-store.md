# Phase P1 – Kho thẻ cục bộ (schema + DAO + migration)

## 1. Objective

Tạo lớp lưu trữ gốc cho thẻ hoạt động trong `CupidDatabase`: hai bảng, một DAO
lọc theo `owner_key`, và migration cộng thêm v2→v3 không phá dữ liệu cache đang
có.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-local-card-store.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/core/database/tables/activity_cards_table.dart`
  - `mobile/lib/core/database/daos/activity_card_dao.dart`
  - `mobile/lib/core/database/cupid_database.dart`
  - `mobile/test/core/database/activity_card_dao_test.dart`
  - `mobile/test/core/database/activity_card_migration_test.dart`
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
  - `activity_cards` + `activity_card_photos` (`../architecture/contract-summary.md` §3)
- Shared Interfaces Consumed:
  - `CupidDatabase` (ADR-010, một Drift owner duy nhất)
- Risk Surfaces:
  - Mất dữ liệu gốc khi đăng xuất
  - R-1b — trôi schema sang đo hành vi người kia
  - Migration v2→v3 trên máy đã cài
  - SC-1' — danh sách thứ hai
- Source Of Truth:
  - authoritative artifact: `../architecture/contract-summary.md` §3, §4
  - consumer contract: P2 và 11 story sau của REQ-016
- Primary Inputs Summary:
  - requirements: AC-8, AC-9, AC-17, AC-18, BR-5, BR-12, BR-13
  - architecture: `../architecture/solution.md` §1 Key Discovery, §4
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cụm hành vi — lưu trữ thẻ cục bộ.
  - Source/Test File Count: 5
  - Split Required: NO

## 2. Required Reads

- `../architecture/contract-summary.md`
- `../architecture/solution.md` §1, §4
- `../requirements/requirements.md` Nhóm B, Nhóm D

## 3. Tasks

- Khai báo `ActivityCards` và `ActivityCardPhotos` đúng danh sách cột ở
  `contract-summary.md` §3; `id` là TEXT PK nhận UUID v4 do repository sinh,
  không dùng autoincrement.
- Khoá ngoại `activity_card_photos.card_id` → `activity_cards.id` với
  ON DELETE CASCADE; bật `PRAGMA foreign_keys` nếu chưa bật.
- Thêm chỉ mục trên `(owner_key, status)` cho truy vấn theo ngăn.
- Đăng ký hai bảng và `ActivityCardDao` vào `@DriftDatabase`; bump
  `schemaVersion` lên 3; `onUpgrade` chỉ `createTable` cho hai bảng mới.
- `ActivityCardDao` phơi bày truy vấn theo `owner_key` + `status` có phân trang,
  đếm số thẻ mỗi ngăn, chèn/cập nhật/xoá. **Không** implement
  `SessionScopedStore` và không đăng ký vào hook đăng xuất.
- Ghi chú ngay cạnh khai báo bảng: đây là dữ liệu gốc do client sở hữu, cấm
  migration huỷ-tạo-lại (khác quy ước cache của ADR-007/ADR-015.6).

## 4. Acceptance Criteria

- Bảng có đúng tập cột ở `contract-summary.md` §3, không thừa cột nào.
- Xoá một thẻ xoá kèm các dòng ảnh của nó.
- Truy vấn với `owner_key` khác trả về rỗng.
- Gọi toàn bộ `clearOnSignOut()` đã đăng ký không làm mất dòng thẻ nào.
- DB tạo ở v2 có dữ liệu cache, sau khi nâng lên v3 vẫn giữ nguyên dữ liệu cũ.

## 5. Planned Outputs

- Code: hai bảng Drift, một DAO, `cupid_database.dart` ở schema v3 (+ file `.g.dart` sinh lại).
- Contracts: hiện thực hoá `contract-summary.md` §3.
- Notes: bằng chứng test ghi vào `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, tầng dữ liệu
- Required levels:
  - unit: DAO CRUD, cascade ảnh, cách ly `owner_key`, đếm theo ngăn
  - integration: migration v2→v3 trên `NativeDatabase.memory()` có dữ liệu cache v2
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
- Required checks:
  - Test khẳng định tập cột của `activity_cards` **đúng bằng** allowlist ở
    `contract-summary.md` §3 → thêm bất kỳ cột nào ở §4 làm gãy test.
  - Test khẳng định không tồn tại `@DriftDatabase` thứ hai trong `mobile/lib`.
  - Test khẳng định thẻ sống sót qua `clearOnSignOut()`.
- Minimum gates by risk surface: bốn risk surface ở §1B đều có gate tương ứng ở trên.
- Evidence format: output `flutter test` dán vào `coding-plan/test-results.md`.
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng màn hình.
- Verification strategy:
  - Targeted tests: `flutter test test/core/database/`
  - Build/type-check: `flutter analyze lib test`
  - Required assertion evidence: tên test + kết quả pass cho từng gate trên.

## 7. Status

- Status: DONE
- Last updated: 2026-09-07
