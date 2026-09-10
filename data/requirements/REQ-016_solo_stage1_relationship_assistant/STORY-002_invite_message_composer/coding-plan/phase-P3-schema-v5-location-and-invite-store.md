# Phase P3 – Schema v5: cột `location` + bảng `invite_messages`

## 1. Objective

Nâng `CupidDatabase` lên schema v5 bằng một migration **chỉ cộng thêm**: cột
`location` trên `activity_cards` và bảng mới `invite_messages`. Đây là phase
duy nhất chạm `core/database/` trong story này.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-schema-v5-location-and-invite-store.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: YES (song song với P1)
- Write Scope:
  - `mobile/lib/core/database/tables/activity_cards_table.dart`
  - `mobile/lib/core/database/tables/invite_messages_table.dart`
  - `mobile/lib/core/database/cupid_database.dart`
  - `mobile/lib/features/activity_cards/domain/activity_card.dart`
  - `mobile/lib/features/activity_cards/data/activity_card_repository_impl.dart`
  - `mobile/test/core/database/migration_v5_test.dart`
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
  - `activity_cards.location` (cột, và trường trên `ActivityCard` +
    `ActivityCardEdit`)
  - bảng `invite_messages` (schema v5)
- Shared Interfaces Consumed:
  - schema v4 hiện có và bất biến "migration chỉ được cộng thêm"
- Risk Surfaces:
  - Migration phá dữ liệu chỉ tồn tại trên máy
  - Hình dạng payload SB-125 (phần lược đồ bảng)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md` §4
  - consumer contract: P4 (repository payload), P6 (ô nhập địa điểm)
- Primary Inputs Summary:
  - requirements: AC-4, AC-6, AC-17, AC-19
  - architecture: `../architecture/solution.md` §1 Key Discovery 1, §4 Contracts
    And Integrations (bẫy thứ tự migration)
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một bước nhảy schema. Hai thay đổi lược đồ cùng version phải
    nằm cùng phase, vì tách ra sẽ có hai phase cùng ghi `cupid_database.dart` và
    hai lần sinh mã cho cùng một version.
  - Source/Test File Count: 6 (chưa kể `.g.dart` do `build_runner` sinh)
  - Split Required: NO

## 2. Required Reads

- `../requirements/` (AC-4, AC-6, AC-17, AC-19)
- `../architecture/contract-summary.md` §4, §5
- `../architecture/solution.md` §1 Key Discovery 1, §4 Contracts And Integrations
- `mobile/lib/core/database/cupid_database.dart` (chú thích migration hiện có)

## 3. Tasks

- Thêm `location` (`TEXT NULL`) vào `activity_cards_table.dart`; thêm trường
  `location` vào `ActivityCard`, `ActivityCardEdit` (kể cả `ActivityCardEdit.from`)
  và ánh xạ đọc/ghi trong `activity_card_repository_impl.dart`. `ActivityCardEdit`
  là toàn-ảnh: `null` nghĩa là **xoá** cột, không phải "giữ nguyên".
- Tạo `invite_messages_table.dart` đúng bảng cột ở `contract-summary.md` §4, với
  `card_id` là FK tới `activity_cards.id` kèm `ON DELETE CASCADE`. Không thêm cột
  nào về người nhận, thời điểm gửi/mở, hay kết quả Share Sheet.
- Nâng `schemaVersion` lên 5 và mở rộng `onUpgrade` theo đúng hình dạng sau —
  đây là chỗ dễ sai nhất của phase:
  - `from < 3` vẫn `createTable(activityCards)`, vốn phát sinh định nghĩa
    **hiện tại** nên đã bao gồm `location`.
  - `addColumn(location)` phải nằm trong nhánh `else` của `from < 3`, dưới điều
    kiện **riêng** `from < 5` — **không** nối vào `else if (from < 4)` đang có,
    vì nối vào đó sẽ bỏ sót đúng nhóm máy đang đứng ở v4.
  - `createTable(inviteMessages)` chạy cho mọi `from < 5`, không điều kiện phụ.
- Chạy `build_runner` để cập nhật `cupid_database.g.dart` và
  `activity_card_dao.g.dart`.
- Không sửa ngữ nghĩa của bất kỳ cột nào STORY-001 đã giao; không recreate bảng.

## 4. Acceptance Criteria

- Máy ở v3 và máy ở v4 đều lên được v5, và trong **cả hai** trường hợp hàng
  `activity_cards` cũ còn nguyên vẹn, có thêm `location = NULL`.
- Máy cài mới (`onCreate`) có đủ cả `location` lẫn `invite_messages`.
- Xoá một thẻ sẽ xoá các hàng `invite_messages` gắn với nó (cascade, với
  `PRAGMA foreign_keys = ON` mà `beforeOpen` đã bật).
- `flutter analyze lib test` sạch sau khi sinh mã.

## 5. Planned Outputs

- Code directories or files: `mobile/lib/core/database/`,
  `mobile/lib/features/activity_cards/domain|data/`
- Contracts or schemas: schema v5
- Notes or evidence: `../coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, tầng sqlite/drift
- Required levels:
  - unit: đọc/ghi `location` qua `ActivityCardEdit` (kể cả ghi `null` để xoá)
  - integration: migration v3 → v5 và v4 → v5 trên database có sẵn dữ liệu
  - mobile build/type-check/static-analysis: có
- Required checks:
  - hàng cũ còn nguyên sau cả hai đường migration
  - `onCreate` v5 có đủ cột/bảng mới
  - cascade xoá `invite_messages` theo thẻ
- Minimum gates by risk surface:
  - Migration phá dữ liệu chỉ tồn tại trên máy: test migration hai đường, có
    dữ liệu thật trước khi nâng cấp
- Required regression or contract coverage: toàn bộ
  `mobile/test/features/activity_cards/` phải vẫn xanh — thêm một trường vào
  `ActivityCardEdit` chạm mọi caller đang có.
- Evidence format: đầu ra `flutter test` dán vào `../coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng màn UI nào.
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/core/database/ test/features/activity_cards/`
  - Build/type-check/lint command when required:
    `dart run build_runner build --delete-conflicting-outputs` rồi
    `flutter analyze lib test`
  - Required assertion evidence: kết quả hai test migration, nêu rõ số hàng còn
    lại trước/sau

## 7. Status

- Status: DONE
- Last updated: 2026-09-10
- Evidence: `test-results.md` § "Phase P3 – Schema v5"

### Lệch write scope

Write Scope ở §1B liệt kê 6 file. Thực tế phase chạm thêm 9 file; không file nào
là mở rộng phạm vi tự ý, tất cả đều là hệ quả cơ học của việc bump
`schemaVersion` lên 5:

- `mobile/lib/core/database/tables/invite_messages_table.dart` — §1B ghi thiếu,
  nhưng §3 yêu cầu tạo đúng file này.
- `mobile/lib/features/invite_composer/domain/mad_libs.dart` +
  `mobile/test/features/invite_composer/mad_libs_test.dart` — nối `place` ←
  `card.location`, đóng khoảng trống P1 để lại. Được giao thêm trong handoff.
- 6 test ghim cứng `schemaVersion == 4` hoặc bộ cột v4, cộng 2 fixture migration
  cũ phải gỡ thêm phần v5. Danh sách chính xác từng file/dòng nằm ở
  `test-results.md` § "Test sẵn có phải sửa vì bump schema".

Không sửa ngữ nghĩa cột nào của STORY-001, không recreate bảng nào, không đụng
`core/content/` hay bất kỳ vùng nào của P1/P2/P4/P5/P6.
