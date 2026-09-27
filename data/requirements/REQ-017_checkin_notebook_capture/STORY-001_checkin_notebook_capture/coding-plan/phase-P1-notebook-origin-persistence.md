# Phase P1 – Cột xuất xứ và đường ghi idempotent cho mục sổ tay

## 1. Objective

`notebook_entries` mang được xuất xứ của một lần check-in, và
`ContextNotebookRepository` có đúng một đường ghi idempotent theo lần check-in đó —
không đổi nghĩa bất kỳ dữ liệu sổ tay nào đang có.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-notebook-origin-persistence.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/core/database/tables/context_notebook_tables.dart`
  - `mobile/lib/core/database/cupid_database.dart` (+ `cupid_database.g.dart` sinh lại)
  - `mobile/lib/features/context_notebook/domain/context_notebook_models.dart`
  - `mobile/lib/features/context_notebook/data/context_notebook_dao.dart`
  - `mobile/lib/features/context_notebook/data/context_notebook_repository.dart`
  - `mobile/test/**` chỉ các test bị ảnh hưởng bởi `schemaVersion` và test repository/dao
- Impacted Runtime Service/App:
  - Name: `mobile`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `ContextNotebookRepository` đường ghi từ check-in (nhận `originCheckInRef`,
    `originCardId`, `originCardTitle`) và trường xuất xứ trên `NotebookEntry`
- Shared Interfaces Consumed:
  - `eveningCheckInOriginRef(cardId)` (`mobile/lib/features/phase_status/presentation/evening_check_in_sheet.dart:35`)
- Risk Surfaces:
  - RS-1 Notebook local persistence write path
  - RS-3 Per-check-in idempotency (AC-8/BR-12)
  - RS-6 Notebook consumer non-regression (BR-11, AC-10/AC-13)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` §4
    `Contracts And Integrations`
  - consumer contract: `ContextNotebookRepository` là cửa ghi duy nhất vào `notebook_entries`
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC-5, AC-8, AC-9, AC-11, BR-11, BR-12
  - architecture: `../architecture/solution.md` §1 KD-2, KD-5, §4
  - OQ constraints: không có OQ chặn
  - upstream phase outputs: không có
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cluster — lược đồ xuất xứ + đường ghi idempotent của nó
  - Source/Test File Count: 5 source + tệp sinh + ~2-3 tệp test
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md` (AC-5, AC-8, AC-9, AC-11, BR-11, BR-12)
- `../architecture/solution.md` §1 (KD-2, KD-5), §4

## 3. Tasks

- Thêm ba cột nullable vào `NotebookEntries`: `originCheckInRef`, `originCardId`,
  `originCardTitle`. Không thêm cột nào khác, không thêm giá trị nào vào
  `ContextEntrySource`.
- Đọc `schemaVersion` thật trên nhánh tích hợp, cộng một, viết migration **chỉ**
  `ALTER TABLE ADD COLUMN`. Huỷ-tạo-lại bảng dữ liệu gốc bị cấm tuyệt đối.
- Chạy lại drift codegen; sửa mọi assertion đang chốt `schemaVersion` cũ trong cùng
  lần chạy này.
- Mở rộng `NotebookEntry` bằng ba trường xuất xứ tương ứng (nullable).
- Thêm vào DAO một phép tra hàng theo `owner_key` + `origin_check_in_ref`.
- Thêm đường ghi từ check-in trên `ContextNotebookRepository`: nhận ý, loại,
  `originCheckInRef` (bắt buộc), `originCardId`, `originCardTitle`; nếu đã có hàng
  cùng `owner_key` + `origin_check_in_ref` thì cập nhật `kind`/`value`/`updated_at`
  của hàng đó, không chèn hàng mới. `source` giữ `ask_on_the_spot`.
- `updateEntry`/`deleteEntry` không đổi hành vi và **không** chạm ba cột xuất xứ, để
  sửa nội dung hay đổi loại không làm đổi nhãn (AC-5).

## 4. Acceptance Criteria

- Hàng cũ đọc lên với ba cột `null` và mọi hành vi sổ tay cũ không đổi.
- Hai lần gọi đường ghi với cùng `originCheckInRef` để lại đúng một hàng; hai ref khác
  nhau để lại hai hàng (BR-12).
- `updateEntry` với nội dung/loại mới giữ nguyên ba cột xuất xứ (AC-5).
- `cardTitle == null` lúc ghi → `origin_card_title` là `null` và ghi vẫn thành công (AC-9).
- `ContextEntrySource` vẫn đúng hai giá trị; `entries()` giữ nguyên chữ ký (BR-11).

## 5. Planned Outputs

- Code directories or files: như `Write Scope`
- Contracts or schemas: ba cột xuất xứ trên `notebook_entries`, `schemaVersion` +1
- Notes or evidence: `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter `mobile`, tầng dữ liệu
- Required levels:
  - unit: repository (idempotency, giữ nguyên xuất xứ khi update, `cardTitle` null)
  - integration: migration cộng thêm chạy được trên schema trước đó
  - mobile build/type-check/static-analysis: `flutter analyze lib test` phạm vi tệp đã
    sửa (baseline của repo khác 0, chỉ so sánh delta của chính phase này)
- Required checks: không cột nào đo hành vi người kia; không huỷ-tạo-lại bảng
- Required regression or contract coverage: các suite `context_notebook` hiện có và mọi
  test chốt `schemaVersion` phải xanh lại trong cùng lần chạy
- Minimum gates by risk surface: RS-1, RS-3, RS-6 theo bảng `../architecture/solution.md` §4
- Evidence format: lệnh test + kết quả trong `coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng hay đổi màn nào
- Verification strategy:
  - Targeted tests/regression/contract checks: chỉ các suite `context_notebook` và
    database/migration; không chạy toàn bộ `flutter test`
  - Required assertion evidence: đếm hàng sau hai lần ghi cùng ref; ba cột xuất xứ
    không đổi sau `updateEntry`

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-28
