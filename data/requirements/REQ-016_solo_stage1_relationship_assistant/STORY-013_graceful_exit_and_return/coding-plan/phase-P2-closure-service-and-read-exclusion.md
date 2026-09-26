# Phase P2 – Dịch vụ đóng ngăn và loại trừ ở đường đọc

## 1. Objective

Hiện thực hành động đóng ngăn (chọn vật liệu gắn người → ghi sổ trong một
transaction) và làm cho vật liệu đã đóng biến mất khỏi luồng thường ngày bằng
anti-join **trong SQL**. Hai nửa này là một cụm hành vi duy nhất và chỉ chứng
minh được cùng nhau: "đóng một thẻ, thẻ đó rời khỏi pane, thẻ khác thì không".

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-closure-service-and-read-exclusion.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/chapter_closure/data/chapter_closure_service.dart`
  - `mobile/lib/core/database/daos/activity_card_dao.dart`
  - `mobile/lib/features/context_notebook/data/context_notebook_repository.dart`
  - `mobile/lib/core/di/service_locator.dart`
  - `mobile/test/features/chapter_closure/chapter_closure_service_test.dart`
  - `mobile/test/features/activity_cards/activity_card_dao_closure_filter_test.dart`
  - `mobile/test/features/context_notebook/context_notebook_closure_filter_test.dart`
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
  - `ChapterClosureService.close()` / `.reopen()`
- Shared Interfaces Consumed:
  - `ChapterClosureGate` (P1)
  - `item_kind` allowlist (`../architecture/contract-summary.md` §2)
- Risk Surfaces:
  - Phân loại gắn người sai → mất tài sản
  - Rò rỉ vật liệu đã đóng ra luồng thường ngày
  - Phân trang sai do lọc sau khi đọc
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` §1
    `Key Discovery`, §4 `Contracts And Integrations`
  - consumer contract: `../architecture/contract-summary.md` §3, §6
- Primary Inputs Summary:
  - requirements: AC-1, AC-6, AC-7, AC-8, AC-9, AC-10, AC-11, AC-12, AC-17
  - architecture: `../architecture/solution.md` §1, §4
  - OQ constraints: none
  - upstream phase outputs: P1 — sổ ghi v7 và `ChapterClosureGate`
  - UX constraints, if truly required: none
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: ghi trạng thái đóng + loại trừ nó ở mọi đường đọc
  - Source/Test File Count: 7
  - Split Required: NO
  - Split Rationale: bốn file nguồn, trong đó ba là sửa tại chỗ nhỏ (thêm mệnh đề
    `NOT EXISTS`, thêm tham số constructor, nối dây DI); tách ghi khỏi đọc sẽ tạo
    một phase không tự chứng minh được điều gì

## 2. Required Reads

- `../requirements/requirements.md` (AC-1, AC-6..AC-12, AC-17)
- `../architecture/solution.md` §1, §4
- `../architecture/contract-summary.md` §2, §3, §6
- `mobile/lib/core/database/daos/activity_card_dao.dart`
- `mobile/lib/features/activity_cards/presentation/activity_card_list_cubit.dart`
- `mobile/lib/features/context_notebook/context_notebook_entry_point.dart`
- P1 outputs

## 3. Tasks

- Viết `ChapterClosureService.close()`: chạy vị từ phân loại AC-6 **một lần**,
  ghi một hàng `chapter_closures` và toàn bộ `chapter_closure_items` trong
  **một** transaction Drift (AC-1). Vị từ chỉ gồm tín hiệu dương tính:
  - `activity_card` khi thẻ có `invited = true` hoặc `replyState` khác
    `not_answered`, hoặc có ít nhất một `invite_messages` trỏ vào nó;
  - `notebook_entry` cho mọi mục sổ tay người yêu đang sống;
  - `ask_prompt` cho mọi hàng `ask_prompt_state` của `ownerKey`, `item_id` là
    `question_id`.
- Không ghi `item_kind` cho lời mời: `invite_messages.card_id` đã
  `ON DELETE CASCADE` về `activity_cards`.
- Viết `ChapterClosureService.reopen()` = xoá đúng hàng `chapter_closures`; items
  biến mất theo cascade. Không cột `reopened_at`, không lịch sử (BR-7, AC-17).
- Thêm mệnh đề `NOT EXISTS (SELECT 1 FROM chapter_closure_items WHERE item_kind
  = ? AND item_id = <bảng>.<pk>)` vào `cardsByStatus`, `watchCardsByStatus`, và
  `countsByStatus` của `ActivityCardDao` — **trong** truy vấn, trước
  `limit/offset`.
- Thêm cùng mệnh đề vào đường đọc `entries()` của `ContextNotebookRepository`.
  **Không** đụng `skills()` (AC-9) và không đụng nhật ký riêng (BR-6).
- Nối `ChapterClosureGate` vào `ActivityCardDao` và `ContextNotebookRepository`
  qua constructor trong `service_locator.dart`. Chữ ký công khai của
  `ActivityCardRepository` và `ContextNotebookReader` **không đổi**.

## 4. Acceptance Criteria

- Đóng ngăn trên một bộ dữ liệu hỗn hợp: thẻ "Mới nghĩ ra" chưa từng mời **vẫn
  còn**; hồ sơ kỹ năng **vẫn còn**; nhật ký riêng **vẫn còn** (AC-8, AC-9).
- Thẻ đã mời, mục sổ tay người yêu, và trạng thái câu hỏi đã hỏi không còn xuất
  hiện ở bất kỳ pane nào và không còn trong `countsByStatus` (AC-11).
- Một thẻ sống sót sau đó được mời cho người mới **không** bị hút vào kho đã
  đóng — tập đóng là ảnh chụp tại thời điểm đóng, không phải vị từ tính lúc đọc
  (AC-9, `../architecture/solution.md` §1 Key Discovery).
- Phân trang đúng: pane có 25 thẻ trong đó 10 đã đóng, đọc hai trang liên tiếp
  `pageSize = 10` trả 10 rồi 5, không trùng, không sót, và cờ `hasMore` đúng ở
  cả hai trang.
- `ContextNotebookReader.entries()` trả list rỗng sau khi đóng — đúng hành vi "sổ
  tay còn trống" mà AC-12 yêu cầu, không phải lỗi, không thông điệp lỗi.
- `reopen()` đưa đúng tập vật liệu đó trở lại mọi đường đọc.
- Lỗi giữa chừng trong `close()` không để lại closure một nửa: sau rollback,
  `hasAnyClosure()` vẫn `false` (AC-1).
- Không thêm giá trị thứ năm nào vào `ActivityCardStatus`; không thêm cột nào vào
  bảng của STORY-001/004 (BR-3, BR-4).

## 5. Planned Outputs

- Code directories or files: `mobile/lib/features/chapter_closure/data/chapter_closure_service.dart`
  và ba sửa đổi tại chỗ ở `activity_card_dao.dart`,
  `context_notebook_repository.dart`, `service_locator.dart`
- Contracts or schemas: dạng anti-join chuẩn (`../architecture/contract-summary.md` §3)
- Requirement configuration guide updates: none
- Notes or evidence: `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: mobile (Flutter, `mobile/`)
- Required levels:
  - unit: vị từ phân loại AC-6 trên từng loại vật liệu, kể cả ca không dứt khoát
    (AC-10 → giữ lại, không đóng)
  - integration: `ChapterClosureService` trên database thật kèm rollback; DAO
    filter + phân trang; `entries()` sau khi đóng
  - mobile build/type-check/static-analysis: có
- Required checks:
  - test phân trang phải dùng ≥ 25 hàng với ≥ 10 hàng đã đóng; một fixture nhỏ
    hơn `pageSize` không chứng minh được gì
  - `flutter analyze lib test` không sinh error mới
- Minimum gates by risk surface:
  - Phân loại gắn người sai → ba assertion sống sót (thẻ chưa mời, hồ sơ kỹ năng,
    thẻ sống sót được mời lại) phải chạy và xanh
  - Rò rỉ vật liệu đã đóng → assertion trên `cardsByStatus`, `countsByStatus`,
    `entries()` phải chạy và xanh
  - Phân trang sai → test hai trang liên tiếp phải chạy và xanh
- Required regression or contract coverage: test hiện có của
  `ActivityCardDao`/`ActivityCardListCubit` và của context notebook phải còn
  xanh với cổng đã nối dây và sổ ghi rỗng
- Evidence format: `coding-plan/test-results.md` — lệnh đầy đủ, tóm tắt pass/fail,
  và số hàng trả về ở từng trang của test phân trang
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng hay đổi màn hình nào
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/chapter_closure/ test/features/activity_cards/ test/features/context_notebook/`
  - Build/type-check/lint command when required: `flutter build apk --debug`
  - Required assertion evidence: id cụ thể của vật liệu sống sót và vật liệu bị
    đóng trong từng assertion, không chỉ số đếm

## 7. Status

- Status: DONE
- Last updated: 2026-09-16
