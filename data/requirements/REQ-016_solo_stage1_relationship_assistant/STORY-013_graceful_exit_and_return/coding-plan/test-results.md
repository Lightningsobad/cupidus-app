# STORY-013 — Test Results

Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-013_graceful_exit_and_return`
Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-013_graceful_exit_and_return`
BaseHead: `7fe3d780c3cb4a15857ac6a7993dc7fd7cc985f4`

## Phase P1 — Closure ledger schema

Status: **COMPLETE**
Ngày chạy: 2026-09-12
Flutter 3.44.1 / Dart 3.12.1 (`export PATH="$HOME/flutter/bin:$PATH"`)

### 1. Lệnh đã chạy

| # | Lệnh (chạy trong `mobile/`) | Kết quả |
|---|---|---|
| 1 | `flutter test --no-pub --reporter github test/core/database/ test/features/chapter_closure/` | `🎉 103 tests passed.` — exit 0, 0 failed |
| 2 | `flutter analyze --no-pub lib/core/database lib/features/chapter_closure test/core/database test/features/chapter_closure` | `No issues found! (ran in 2.8s)` — **0 error mới**, 0 warning mới |
| 3 | `flutter build apk --debug --flavor local` | `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` — exit 0 |

Ghi chú lệnh 2: theo `phase-P1 §6`, exit code của `flutter analyze` trên toàn repo
không phải bằng chứng (nền hiện có ~222 warning cũ, 0 error). Gate ở đây là
"0 error mới", nên analyze được thu hẹp đúng vào 4 thư mục P1 chạm tới và trả về
sạch hoàn toàn.

Ghi chú lệnh 3: `flutter build apk --debug` trần thất bại với
`Task 'assembleDevDebug' not found` vì `android/app/build.gradle.kts` khai hai
product flavor `local`, `prod`. Lệnh hợp lệ tương đương là `--flavor local`.

### 2. Test mới

`mobile/test/core/database/chapter_closure_migration_test.dart` (10 test)

- `v6 -> v7` → `lands on v7 with both ledger tables present`
- `v6 -> v7` → `every pre-v7 table keeps its exact row count` (bằng chứng số hàng
  trước/sau cho `activity_cards`, `notebook_entries`, `skill_profile_entries`,
  `ask_prompt_state`, `journal_entries`)
- `v6 -> v7` → `the seeded rows keep their content, not just their count`
- `v6 -> v7` → `the ledger is writable immediately after the upgrade`
- `v7 on a fresh install` → `onCreate emits both tables at schemaVersion 7`
- `v7 on a fresh install` → `chapter_closure_items has the composite primary key`
- `v7 on a fresh install` → `the (item_kind, item_id) index exists on the right columns`
- `v7 on a fresh install` → `deleting a closure cascades its items away`
- `v7 on a fresh install` → `an item without its closure row is rejected`
- `cột bị cấm vĩnh viễn (AC-5 / BR-9 / BR-7)` → `hai bảng mới không có cột nào ngoài contract §1`

`mobile/test/features/chapter_closure/chapter_closure_gate_test.dart` (11 test)

- `trạng thái rỗng` → `closedIdsOf returns an empty set without throwing`
- `trạng thái rỗng` → `closedIdsOf is empty for every kind`
- `trạng thái rỗng` → `hasAnyClosure is false`
- `một closure` → `hasAnyClosure flips to true`
- `một closure` → `closedIdsOf returns only the requested kind`
- `nhiều kind và nhiều closure` → `ids from different closures merge into one set per kind`
- `nhiều kind và nhiều closure` → `reopening one closure releases only its own ids (AC-17)`
- `nhiều kind và nhiều closure` → `reopening every closure returns the gate to its empty state`
- `anti-join dùng lại được (§3)` → `excludes closed ids inside SQL, so LIMIT still fills the page`
- `anti-join dùng lại được (§3)` → `an id closed under another kind is not excluded`
- `anti-join dùng lại được (§3)` → `with nothing closed the anti-join excludes nothing`
- `vocabulary (§2)` → `the wire values are exactly the three contracted kinds`

### 3. Regression từ bump `schemaVersion` 6 → 7

Tech Lead đã cảnh báo trước rủi ro này; đã dọn hết **trong cùng phase**, không hoãn.

Hai nhóm hỏng khác nhau:

**(a) Fixture migration dựng schema hiện tại rồi lùi `user_version`.** Drift phát
`CREATE TABLE IF NOT EXISTS` nhưng `Migrator.createIndex` phát `CREATE INDEX`
trần, nên fixture để sót bảng v7 làm nhánh v7 thật ném
`SqliteException(1): index chapter_closure_items_kind_item already exists`.
Đã thêm `DROP TABLE chapter_closure_items` rồi `DROP TABLE chapter_closures`
(items trước, theo chiều khoá ngoại) vào 4 fixture:

- `test/core/database/context_notebook_migration_test.dart` (`seedV5`)
- `test/core/database/migration_v5_test.dart` (`seedPreV5`)
- `test/core/database/cupid_database_migration_v3_test.dart` (`seedV2Database`)
- `test/core/database/activity_card_migration_test.dart` (cả hai setUp `v2 -> current`, `v3 -> current`)

**(b) Assertion hằng số `schemaVersion`.** 7 chỗ `expect(..., 6)` đã bump lên `7`:

- `test/core/database/activity_card_dao_test.dart` (kèm sửa tiêu đề test)
- `test/core/database/timeline_dao_test.dart`
- `test/core/database/journal_dao_test.dart`
- `test/core/database/expense_dao_test.dart`
- `test/core/database/context_notebook_migration_test.dart` (2 assertion)
- `test/core/database/migration_v5_test.dart` (3 assertion)
- `test/features/activity_cards/activity_type_test.dart`

`cupid_database_migration_v3_test.dart` đọc `upgraded.schemaVersion` động nên
không có số nào phải đổi.

### 4. AC coverage

| AC / BR | Nội dung | Test chứng minh | Kết quả |
|---|---|---|---|
| AC-5 (§4 gạch 2), BR-9 | Hai bảng mới không có cột ngoài `contract-summary.md` §1 — không `reason`, `label`, `note`, `sentiment`, `person*`, `*count*` | `chapter_closure_migration_test.dart` → `cột bị cấm vĩnh viễn` | PASS |
| BR-7 | Mở lại là xoá hàng, không lưu lịch sử → không có `reopened_at` | cùng test trên (tên `reopened_at` nằm trong danh sách cấm) + `reopening one closure releases only its own ids (AC-17)` | PASS |
| AC-6 (§4 gạch 1) | `schemaVersion == 7`; v6 → v7 giữ nguyên toàn bộ hàng của 5 bảng cũ | `v6 -> v7` (4 test, có số hàng trước/sau và kiểm tra nội dung) | PASS |
| AC-14 / §3 gate | `closedIdsOf(kind)` trả set rỗng khi chưa có closure và không ném lỗi; `hasAnyClosure()` false → true | `chapter_closure_gate_test.dart` → `trạng thái rỗng` (3 test), `một closure` (2 test) | PASS |
| AC-17 | Mở lại một closure chỉ nhả id của chính nó | `reopening one closure releases only its own ids (AC-17)`, `reopening every closure returns the gate to its empty state` | PASS |
| §4 gạch 3 | Cascade chạy được nhờ `PRAGMA foreign_keys = ON` ở `beforeOpen` | `deleting a closure cascades its items away`, `an item without its closure row is rejected` | PASS |
| §4 gạch 6, ADR-010 | Không thêm `@DriftDatabase` thứ hai | `activity_card_dao_test.dart` → `lib declares exactly one @DriftDatabase (ADR-010)` (quét `lib/` thật) | PASS |
| §3 anti-join | Loại id đã đóng **trong SQL**, để `LIMIT`/`OFFSET` không sai trang | `excludes closed ids inside SQL, so LIMIT still fills the page` (+2 test biên) | PASS |

### 5. Per-story visual fidelity

NOT_APPLICABLE — P1 không dựng hay đổi màn hình nào (đúng như `phase-P1 §6`).

### 6. Lỗi có sẵn, không do phase này

`test/design_system/shared_backdrop_occlusion_test.dart:565` —
`chat shows the shared sky wash despite its persistent bottom chrome` đỏ với
`pumpAndSettle timed out` (`_renderAndProbe`, dòng 135).

Không liên quan tới bump 6 → 7, bằng ba điểm:

1. Case `chat` (dòng 558-576) không hề dựng `CupidDatabase`; nó chỉ nhận
   `_EmptyChatRepository`, `_SilentRealtimeCoordinator` và hai store chạy trên
   `Dio` stub.
2. Case `timeline` (dòng 538) **có** dựng `db.CupidDatabase(NativeDatabase.memory())`
   và vẫn xanh trong cùng lần chạy.
3. Log quanh nó là lỗi môi trường — `dio` không nối được `http://localhost:3000/users/me`
   và `[InAppNotificationManager] FCM init error: [core/no-app] No Firebase App '[DEFAULT]'`.

Nằm ngoài write scope P1 (`mobile/lib/core/database`, `mobile/lib/features/chapter_closure`),
nên ghi nhận chứ không sửa ở đây.
