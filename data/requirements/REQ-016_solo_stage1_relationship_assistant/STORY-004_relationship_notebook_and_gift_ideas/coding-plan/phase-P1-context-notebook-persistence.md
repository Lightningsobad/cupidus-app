# Phase P1 – Kho ngữ cảnh: bảng Drift + repository

## 1. Objective

Ba bảng cục bộ của kho ngữ cảnh (sổ tay, hồ sơ kỹ năng, trạng thái câu hỏi) tồn
tại với migration cộng thêm, cùng một repository là cửa đọc/ghi duy nhất.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-context-notebook-persistence.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: YES (với P2)
- Write Scope:
  - `mobile/lib/core/database/tables/context_notebook_tables.dart`
  - `mobile/lib/core/database/cupid_database.dart`
  - `mobile/lib/features/context_notebook/domain/context_notebook_models.dart`
  - `mobile/lib/features/context_notebook/data/context_notebook_dao.dart`
  - `mobile/lib/features/context_notebook/data/context_notebook_repository.dart`
  - `mobile/lib/core/di/service_locator.dart`
  - `mobile/test/features/context_notebook/context_notebook_repository_test.dart`
  - `mobile/test/core/database/context_notebook_migration_test.dart`
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
  - `notebook_entries` / `skill_profile_entries` / `ask_prompt_state`
  - `ContextNotebookRepository`, `NotebookEntry`, `SkillEntry`, `NotebookKind`
- Shared Interfaces Consumed:
  - `CupidDatabase` (một Drift owner duy nhất, ADR-010)
- Risk Surfaces:
  - Migration Drift đụng độ với STORY-003 đang chạy
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md` §4
  - consumer contract: `../architecture/contract-summary.md` §3 (P3 gọi repository này)
- Primary Inputs Summary:
  - requirements: AC-4, AC-6, AC-9, AC-12, AC-25
  - architecture: `../architecture/contract-summary.md` §4, §5
  - OQ constraints: R-15a (id bền), R-15c (cột bị cấm)
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một tầng lưu trữ cục bộ + cửa truy cập của nó
  - Source/Test File Count: 8
  - Split Required: NO
  - Split Rationale: ba bảng nằm trong một file Drift và chia sẻ đúng một
    migration + một repository; tách ra sẽ buộc hai phase cùng sửa
    `cupid_database.dart`.

## 2. Required Reads

- `../architecture/contract-summary.md` §4, §5
- `../requirements/requirements.md` (AC-4, AC-6, AC-9, AC-12, AC-25)

## 3. Tasks

- Khai báo ba bảng theo đúng cột ở `contract-summary.md` §4, PK gộp
  (`owner_key`, `question_id`) cho `ask_prompt_state`.
- Đọc `CupidDatabase.schemaVersion` hiện có trên nhánh tích hợp, cộng một, viết
  nhánh migration **chỉ `CREATE TABLE`**. Không đụng bảng cũ, không huỷ-tạo-lại.
- Repository: tạo/sửa/xoá mục sổ tay và kỹ năng, đọc theo `owner_key`, ghi
  `ask_prompt_state`. Chuẩn hoá và giá trị mặc định nằm ở đây, không ở UI.
- Đăng ký repository trong `service_locator.dart`. **Không** đăng ký DAO làm
  `SessionScopedStore`.

## 4. Acceptance Criteria

- Ba bảng tồn tại; `schemaVersion` tăng đúng một so với giá trị thật trước đó.
- Migration từ phiên bản trước giữ nguyên mọi hàng `activity_cards`,
  `journal_entries`, `invite_messages`.
- Repository sửa/xoá có hiệu lực ngay (AC-9) và mục ghi từ hỏi-tại-chỗ đọc lại
  được kèm `question_id` (AC-4).
- Không tồn tại cột mức độ/sao/điểm/hạng trên `skill_profile_entries` và không
  cột đo hành vi người kia trên `notebook_entries` (AC-12, AC-25).

## 5. Planned Outputs

- Code directories or files: xem `Write Scope`
- Contracts or schemas: ba bảng theo `../architecture/contract-summary.md` §4
- Notes or evidence: `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, tầng dữ liệu
- Required levels:
  - unit: repository CRUD, chuẩn hoá, lọc theo `owner_key`
  - integration: Drift migration v(n) → v(n+1) trên database có sẵn dữ liệu
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
- Required checks: assert bằng test rằng danh sách cột bị cấm ở
  `../architecture/contract-summary.md` §4 không xuất hiện trong schema sinh ra
- Minimum gates by risk surface: migration test giữ nguyên mọi hàng của ba bảng
  đã có; thiếu gate này → `SCHEMA_CONTENTION`
- Required regression or contract coverage: test hiện có của
  `activity_cards`/`journal`/`invite_composer` giữ nguyên xanh
- Evidence format: lệnh + kết quả tóm tắt trong `test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng màn nào
- Verification strategy:
  - Targeted tests/regression/contract checks: `flutter test test/features/context_notebook test/core/database`
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: log migration test và số test pass

## 7. Status

- Status: COMPLETE (Mobile self-assessment; chờ Scrum Master verify + commit)
- Last updated: 2026-09-10
- Evidence: `../test-results.md` §Phase P1
- schemaVersion: 5 -> 6 (đọc sống trên nhánh tích hợp, cộng một)
