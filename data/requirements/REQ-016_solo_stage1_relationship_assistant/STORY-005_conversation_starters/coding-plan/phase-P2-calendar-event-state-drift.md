# Phase P2 – Bảng `calendar_event_state` + migration v6→v7

## 1. Objective

Một bảng Drift trạng-thái nhỏ nhớ mục sự kiện nào đã thành thẻ hoặc đã bị bỏ
qua, cộng migration cộng thêm v6→v7, cộng việc sửa mọi khẳng định
`schemaVersion` đang chốt ở `6`.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-calendar-event-state-drift.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/core/database/tables/calendar_event_state_table.dart`
  - `mobile/lib/core/database/cupid_database.dart`
  - `mobile/lib/features/conversation_starters/data/calendar_event_state_repository.dart`
  - `mobile/test/core/database/calendar_event_state_migration_test.dart`
  - `mobile/test/core/database/*.dart` — chỉ sửa hằng số phiên bản
  - `mobile/test/features/activity_cards/activity_type_test.dart` — chỉ sửa
    hằng số phiên bản
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `calendar_event_state` (`../architecture/contract-summary.md` §4)
- Shared Interfaces Consumed:
  - `CupidDatabase` (ADR-010 — một Drift owner duy nhất)
- Risk Surfaces:
  - Migration Drift 6→7
  - Ghi thẻ đúng hợp đồng STORY-001 (AC-11/AC-12)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md`
    §4 và §5
  - consumer contract: P3
- Primary Inputs Summary:
  - requirements: AC-12, AC-13, AC-14
  - architecture: `../architecture/solution.md` §4 Contracts And Integrations,
    §5
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một bảng trạng-thái và migration của nó
  - Source/Test File Count: 4 file thực chất, cộng 8 file test chỉ sửa một hằng
    số phiên bản
  - Split Required: NO
  - Split Rationale: 9 khẳng định `schemaVersion` trong 8 file là hệ quả cơ học
    của chính migration này. Tách chúng ra phase khác để lại một cây đỏ giữa
    hai dispatch; gộp vào đây giữ mỗi commit xanh.

## 2. Required Reads

- `../architecture/contract-summary.md` §4, §5
- `mobile/lib/core/database/cupid_database.dart` (khối `@DriftDatabase` và
  `MigrationStrategy`)
- `mobile/lib/core/database/tables/` cho hình dạng bảng đang dùng

## 3. Tasks

- Đọc giá trị `schemaVersion` thật trên nhánh này rồi cộng một. Tại thời điểm
  lập kế hoạch nó là `6`; **không** chép con số từ tài liệu.
- Thêm bảng `calendar_event_state`: PK gộp (`owner_key`, `event_id`), `state`
  TEXT NOT NULL (`converted` | `dismissed`), `updated_at` DATETIME NOT NULL.
- Đăng ký bảng trong `@DriftDatabase(tables: [...])` và thêm nhánh
  `if (from < 7) { await m.createTable(calendarEventState); }`. Chỉ `CREATE
  TABLE` — huỷ-tạo-lại bị cấm tuyệt đối cho bảng dữ liệu gốc.
- Viết `CalendarEventStateRepository` với `Future<Set<String>>
  handledEventIds(String ownerKey)` và `Future<void> markHandled({required
  String ownerKey, required String eventId, required CalendarEventState
  state})`. Chuẩn hoá và mặc định thuộc repository, không thuộc UI.
- Sửa 9 khẳng định `schemaVersion` đang chốt ở giá trị cũ, nằm trong 8 file:
  `test/core/database/activity_card_dao_test.dart`, `migration_v5_test.dart`,
  `expense_dao_test.dart`, `cupid_database_migration_v3_test.dart` (2 chỗ),
  `context_notebook_migration_test.dart`, `journal_dao_test.dart`,
  `timeline_dao_test.dart`, và
  `test/features/activity_cards/activity_type_test.dart`.

## 4. Acceptance Criteria

- Máy ở v6 nâng lên v7 giữ nguyên mọi hàng `activity_cards`, `journal_entries`,
  `notebook_entries`, `skill_profile_entries`, `invite_messages`.
- Không câu lệnh `DROP` nào xuất hiện trong nhánh migration mới.
- Không cột nào trong danh sách cấm của `STORY-001/architecture/contract-summary.md`
  §4 hay `STORY-004/architecture/contract-summary.md` §4 được thêm — đặc biệt
  không cột đếm, không timestamp đo hành vi người kia.
- Ghi lại cùng một `event_id` hai lần không sinh hàng thứ hai.

## 5. Planned Outputs

- Code directories or files: xem `Write Scope`.
- Contracts or schemas: `calendar_event_state`, `schemaVersion` 7.
- Notes or evidence: `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, tầng dữ liệu cục bộ
- Required levels:
  - unit: `CalendarEventStateRepository` — ghi, đọc, idempotency theo PK gộp,
    lọc theo `owner_key`
  - integration: migration v6→v7 trên database in-memory, khẳng định dữ liệu cũ
    còn nguyên và bảng mới tồn tại
  - mobile build/type-check/static-analysis: `flutter analyze lib test` — gate
    là zero analyzer **error**; exit code không phải gate
- Required checks: chạy lại toàn bộ `mobile/test/core/database/` sau khi sửa
  hằng số phiên bản
- Minimum gates by risk surface: migration chỉ cộng thêm, dữ liệu gốc không mất
- Required regression or contract coverage: 8 file test nêu ở Task cuối phải
  xanh trong cùng lần chạy
- Evidence format: lệnh `flutter test mobile/test/core/database/` và tóm tắt
  pass/fail trong `coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase này không dựng màn nào
- Verification strategy:
  - Targeted tests/regression/contract checks: như trên
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: số hàng trước/sau migration bằng nhau cho mọi
    bảng dữ liệu gốc

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-11
