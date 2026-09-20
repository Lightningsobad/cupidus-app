# Phase P1 – Sổ ghi đóng ngăn: schema, migration, cổng đọc

## 1. Objective

Dựng hai bảng Drift của sổ ghi đóng ngăn cùng migration cộng thêm v6→v7, và
`ChapterClosureGate` — API đọc duy nhất mà mọi phase sau (và mọi story REQ-016
sau) dùng để biết "cái gì đang đóng". Kết thúc phase này chưa có gì đóng được và
chưa có màn hình nào đổi; thứ phải đúng là schema và tính bất biến của dữ liệu cũ.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-closure-ledger-schema.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/core/database/tables/chapter_closure_tables.dart`
  - `mobile/lib/core/database/daos/chapter_closure_dao.dart`
  - `mobile/lib/core/database/cupid_database.dart`
  - `mobile/lib/features/chapter_closure/domain/chapter_closure_gate.dart`
  - `mobile/test/core/database/chapter_closure_migration_test.dart`
  - `mobile/test/features/chapter_closure/chapter_closure_gate_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: runtime registry `runCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `chapter_closures` / `chapter_closure_items` (`../architecture/contract-summary.md` §1)
  - `item_kind` allowlist (`../architecture/contract-summary.md` §2)
  - `ChapterClosureGate` (`../architecture/contract-summary.md` §3)
- Shared Interfaces Consumed:
  - `BackendUserIdStore` cho `ownerKey`
  - `CupidDatabase` `MigrationStrategy` (ADR-010, cộng thêm, không recreate)
- Risk Surfaces:
  - Cột cấm lọt vào schema
  - Migration phá dữ liệu người dùng
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` §4
    `Contracts And Integrations`; `mobile/lib/core/database/cupid_database.dart`
    ghi chú "no destructive recreate"
  - consumer contract: `../architecture/contract-summary.md` §1-3
- Primary Inputs Summary:
  - requirements: AC-5, AC-6, AC-14
  - architecture: `../architecture/solution.md` §4; `../architecture/contract-summary.md` §1-3
  - OQ constraints: none
  - upstream phase outputs: none
  - UX constraints, if truly required: none
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: schema + migration + cổng đọc của sổ ghi
  - Source/Test File Count: 6
  - Split Required: NO
  - Split Rationale: đúng một vòng đời; migration và cổng đọc không tách được vì
    test migration và test cổng dùng chung một database fixture

## 2. Required Reads

- `../requirements/requirements.md` (AC-5, AC-6, AC-14)
- `../architecture/solution.md` §4
- `../architecture/contract-summary.md` §1-3
- `mobile/lib/core/database/cupid_database.dart`
- `mobile/lib/core/database/tables/activity_cards_table.dart` (mẫu bảng
  device-authoritative + ghi chú vì sao không phải `SessionScopedStore`)

## 3. Tasks

- Khai báo `ChapterClosures(id, ownerKey, closedAt)` và
  `ChapterClosureItems(closureId, itemKind, itemId)` đúng DDL ở
  `../architecture/contract-summary.md` §1: `closureId` tham chiếu
  `ChapterClosures` với `KeyAction.cascade`, khoá chính ghép
  `(closureId, itemKind, itemId)`.
- Tạo index `(itemKind, itemId)` trên `chapter_closure_items` — thiếu index này
  biến mỗi trang thẻ thành quét bảng (`../architecture/solution.md` §5).
- Nâng `schemaVersion` 6 → 7 và thêm **một** nhánh `if (from < 7)` chỉ gồm
  `createTable` hai bảng mới cộng lệnh tạo index. Không đụng bảng cũ, không
  migrate dữ liệu, không thêm nhánh `else`.
- Viết `ChapterClosureDao` với các hàm ghi/đọc tối thiểu: tạo closure kèm items
  trong một transaction, xoá closure theo id, đọc id đang đóng theo `itemKind`,
  đếm số closure.
- Viết `ChapterClosureGate` phơi đúng ba thứ ở `contract-summary.md` §3:
  `closedIdsOf(kind)`, `hasAnyClosure()`, và biểu thức anti-join dùng lại được
  cho DAO khác. Không phơi `closedAt` ra ngoài dưới dạng số đo thời gian.
- Chạy `dart run build_runner build --delete-conflicting-outputs`.

## 4. Acceptance Criteria

- `schemaVersion` là 7, và mở một database v6 có sẵn dữ liệu rồi nâng lên v7 giữ
  nguyên toàn bộ hàng của `activity_cards`, `notebook_entries`,
  `skill_profile_entries`, `ask_prompt_state`, `journal_entries`.
- Hai bảng mới không có cột nào ngoài cột đã khai ở `contract-summary.md` §1 —
  cụ thể không có `reason`, `label`, `note`, `sentiment`, `person*`, `*count*`,
  `reopened_at` (AC-5, BR-9).
- Xoá một hàng `chapter_closures` làm biến mất mọi `chapter_closure_items` của
  nó (cascade hoạt động với `PRAGMA foreign_keys = ON` đang bật ở `beforeOpen`).
- `closedIdsOf(kind)` trả tập rỗng khi chưa có closure nào và không ném lỗi.
- `hasAnyClosure()` trả `false` ở trạng thái rỗng, `true` sau closure đầu tiên.
- Không có `@DriftDatabase` thứ hai nào được thêm (ADR-010).

## 5. Planned Outputs

- Code directories or files: `mobile/lib/core/database/tables/chapter_closure_tables.dart`,
  `mobile/lib/core/database/daos/chapter_closure_dao.dart`,
  `mobile/lib/features/chapter_closure/domain/chapter_closure_gate.dart`,
  sửa `mobile/lib/core/database/cupid_database.dart`
- Contracts or schemas: sổ ghi v7 theo `../architecture/contract-summary.md` §1
- Requirement configuration guide updates: none
- Notes or evidence: `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: mobile (Flutter, `mobile/`)
- Required levels:
  - unit: `ChapterClosureGate` — rỗng, một kind, nhiều kind, cascade
  - integration: migration v6 → v7 trên database có dữ liệu cũ
  - mobile build/type-check/static-analysis: có
- Required checks:
  - test quét schema cấm cột, theo kiểu `context_notebook_migration_test.dart`:
    liệt kê cột thực tế của hai bảng mới và fail nếu xuất hiện tên nằm trong
    danh sách cấm ở `## 4`
  - `flutter analyze lib test` không sinh **error mới**; nền hiện có là
    0 error kèm nhiều warning cũ, nên exit code không phải bằng chứng
- Minimum gates by risk surface:
  - Cột cấm lọt vào schema → test allowlist cột phải chạy và xanh
  - Migration phá dữ liệu người dùng → test v6→v7 giữ nguyên hàng cũ phải chạy
    và xanh; nếu không dựng được fixture v6 thì BLOCKER, không bỏ qua
- Required regression or contract coverage: các test Drift hiện có phải còn xanh
  sau khi `schemaVersion` đổi — một lần bump làm đỏ nhiều assertion ở các file
  test database khác, sửa hết trong phase này
- Evidence format: `coding-plan/test-results.md` — lệnh đầy đủ, dòng tóm tắt
  pass/fail, và tên các test mới
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng hay đổi màn hình nào
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/core/database/ test/features/chapter_closure/`
  - Build/type-check/lint command when required: `flutter build apk --debug`
  - Required assertion evidence: số hàng trước/sau migration cho từng bảng cũ

## 7. Status

- Status: COMPLETE
- Last updated: 2026-09-12
- Evidence: `coding-plan/test-results.md` §"Phase P1 — Closure ledger schema"
