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

## Phase P2 — Dịch vụ đóng ngăn và loại trừ ở đường đọc

Status: **COMPLETE**
Ngày chạy: 2026-09-16
Flutter 3.44.1 / Dart 3.12.1 (`export PATH="$HOME/flutter/bin:$PATH"`)
BaseHead của phase: `66a339c013174b635754a3fc6ea488424fc63614`

### 1. Điểm xuất phát (session recovery)

Commit `66a339c0` đã mang sẵn toàn bộ **mã nguồn** P2, không có test nào của P2.
Kiểm kê đối chiếu `phase-P2 §1B Write Scope`:

| File trong write scope | Trạng thái ở `66a339c0` | Việc phase này làm |
|---|---|---|
| `lib/features/chapter_closure/data/chapter_closure_service.dart` | có, `close()`/`reopen()` đầy đủ | không đổi, chỉ kiểm chứng bằng test |
| `lib/core/database/daos/activity_card_dao.dart` | có anti-join ở `cardsByStatus`, `watchCardsByStatus`, `countsByStatus` | không đổi |
| `lib/features/context_notebook/data/context_notebook_repository.dart` | không đổi — cổng nằm ở `context_notebook_dao.notebookRows()`, đúng đường đọc của `entries()` và không đụng `skills()` | không đổi |
| `lib/core/di/service_locator.dart` | có đăng ký `ChapterClosureDao`/`Gate`/`Service` | không đổi |
| `test/features/chapter_closure/chapter_closure_service_test.dart` | **thiếu** | viết mới (14 test) |
| `test/features/activity_cards/activity_card_dao_closure_filter_test.dart` | **thiếu** | viết mới (11 test) |
| `test/features/context_notebook/context_notebook_closure_filter_test.dart` | **thiếu** | viết mới (7 test) |

Một sai khác so với §1B là cố ý và đã kiểm chứng: mệnh đề anti-join của sổ tay
nằm trong `context_notebook_dao.dart` chứ không phải `context_notebook_repository.dart`.
`ContextNotebookRepository.entries()` đọc qua đúng `notebookRows()` đó, nên hành vi
hợp đồng `§3` vẫn đúng và chữ ký công khai không đổi.

Ngoài phạm vi P2 (theo `§3 Tasks` và `contract-summary.md §3`): đường đọc
`promptStates()` **không** được lọc. `§3` chỉ ràng buộc `entries()` và cấm lọc
`skills()`; `ask_prompt` được chụp vào sổ ghi ở P2 nhưng consumer của nó không
thuộc phase này.

### 2. Lệnh đã chạy

| # | Lệnh (chạy trong `mobile/`) | Kết quả |
|---|---|---|
| 1 | `flutter test --no-pub --reporter github test/features/chapter_closure/chapter_closure_service_test.dart` | `🎉 14 tests passed.` — exit 0 |
| 2 | `flutter test --no-pub --reporter github test/features/activity_cards/activity_card_dao_closure_filter_test.dart test/features/context_notebook/context_notebook_closure_filter_test.dart` | `🎉 18 tests passed.` — exit 0 |
| 3 | `flutter test --no-pub --reporter compact test/features/chapter_closure/ test/features/activity_cards/ test/features/context_notebook/ test/core/database/` | `+438 ~6: All other tests passed!` — exit 0, 0 failed, 6 skipped |
| 4 | `flutter analyze --no-pub lib/core/database lib/core/di lib/features/chapter_closure lib/features/context_notebook test/features/chapter_closure test/features/activity_cards test/features/context_notebook` | `13 issues found` — **0 error, 0 warning**, 13 info |
| 5 | `flutter build apk --debug --flavor local` | `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` — exit 0 |

Ghi chú lệnh 3: đây là regression bắt buộc của `§6` (test cũ của `ActivityCardDao`,
`ActivityCardListCubit` và context notebook phải còn xanh với cổng đã nối dây và sổ
ghi rỗng). 438 test xanh, không có test nào đỏ.

Ghi chú lệnh 4: `flutter analyze` trên repo này không bao giờ exit 0 (nền ~222
warning cũ), nên cổng là "0 error mới". 13 issue đều là `info •
prefer_initializing_formals` trên constructor dùng initializer list với tham số
**named** và field private — chuyển sang initializing formal sẽ buộc caller viết
`_db:`, tức đổi API công khai. Cùng lint đã tồn tại sẵn trên
`context_notebook_repository.dart` và `ask_on_the_spot_cubit.dart` (không thuộc
phase này), nên đây là khuôn mẫu sẵn có của codebase chứ không phải lỗi mới.

Ghi chú lệnh 5: `--flavor local` là bắt buộc, giống P1.

### 3. Test mới

`mobile/test/features/chapter_closure/chapter_closure_service_test.dart` (14 test)

- `vị từ phân loại gắn người` → `chỉ ba tín hiệu dương tính đóng một thẻ`
  (đóng đúng `card-invited`, `card-answered`, `card-messaged`)
- → `thẻ chưa từng mời ở lại luồng thường ngày (AC-7)` (`card-untouched` sống sót)
- → `ca không dứt khoát giữ lại, không đóng (AC-10)` (`card-scheduled-alone` sống
  sót: lên lịch một mình không phải tín hiệu gắn người)
- → `thẻ của chủ khác không bao giờ bị đóng` (`card-other-owner` của `user-2`)
- → `lời mời không có item_kind riêng` (`invite-1` không xuất hiện trong
  `chapter_closure_items`; chỉ có kind `activity_card`)
- `sổ tay, hồ sơ kỹ năng và nhật ký riêng` → `mọi mục sổ tay người yêu của chủ hiện
  tại vào sổ đóng` (`entry-a`, `entry-b`; `entry-other` của `user-2` không vào)
- → `hồ sơ kỹ năng không bao giờ là thành viên (AC-8)` (`skill-a`)
- → `nhật ký riêng không bao giờ là thành viên (BR-6)` (`journal-a`, kèm khẳng định
  hàng nhật ký vẫn còn nguyên)
- → `ask_prompt lưu question_id làm item_id (§2)`
  (`ask.birthday.v1`, `ask.coffee.v1`)
- `giao dịch đơn (AC-1)` → `lỗi giữa chừng không để lại closure một nửa`
- `đóng lại và mở lại (AC-17)` → `close trả về id của closure vừa ghi`,
  `đóng lần hai thay thế ảnh chụp cũ, không xếp chồng`,
  `reopen xoá hàng closure và mọi thành viên theo cascade`,
  `reopen khi chưa đóng gì là no-op, không ném lỗi`

`mobile/test/features/activity_cards/activity_card_dao_closure_filter_test.dart` (11 test)

- `chưa đóng gì` → `anti-join không loại trừ gì và phân trang giữ nguyên`
- `phân trang sau khi đóng 10/25 thẻ` → `hai trang liên tiếp trả 10 rồi 5, không
  trùng, không sót`, `cờ hasMore đúng ở cả hai trang`, `không thẻ đã đóng nào lọt
  vào bất kỳ trang nào`, `countsByStatus đếm theo tập đã lọc (AC-11)`,
  `watchCardsByStatus phát ra cùng tập đã lọc`,
  `mở lại đưa đủ 25 thẻ trở lại mọi đường đọc (AC-17)`
- `ảnh chụp tại thời điểm đóng, không tính lại lúc đọc (AC-9)` → `thẻ sống sót được
  mời cho người mới vẫn ở luồng thường ngày`
- `phạm vi lọc` → `pane khác và chủ khác không bị ảnh hưởng`,
  `id đóng dưới kind khác không ẩn thẻ trùng id`

`mobile/test/features/context_notebook/context_notebook_closure_filter_test.dart` (7 test)

- `sổ tay sau khi đóng ngăn (AC-12)` → `entries() trả list rỗng, không ném lỗi`,
  `lọc theo kind cũng rỗng sau khi đóng`,
  `hồ sơ kỹ năng không bao giờ bị lọc (AC-8)`,
  `đóng một phần chỉ giấu đúng mục đã đóng`,
  `mở lại đưa đúng tập mục đó trở lại (AC-17)`,
  `id đóng dưới kind khác không giấu mục sổ tay`
- `trạng thái rỗng` → `chưa đóng gì thì anti-join không giấu gì`,
  `mục viết sau khi đóng vẫn hiện ra bình thường`

### 4. Bằng chứng phân trang (§6 yêu cầu số hàng từng trang)

Fixture: 25 thẻ `card-00`..`card-24`, cùng pane `idea`, `updatedAt` tăng dần theo
chỉ số nên thứ tự đọc là mới nhất trước. Đóng đúng 10 thẻ có chỉ số chẵn từ 0 đến
18 — trải trên **cả hai** trang, không gom vào một trang (một khối đóng nằm gọn ở
trang 2 sẽ làm trang 1 đúng một cách ngẫu nhiên).

| Lần đọc | Tham số | Số hàng trả về | Id trả về (theo thứ tự) |
|---|---|---|---|
| Trang 1 | `limit: 10, offset: 0` | **10** | `card-24, card-23, card-22, card-21, card-20, card-19, card-17, card-15, card-13, card-11` |
| Trang 2 | `limit: 10, offset: 10` | **5** | `card-09, card-07, card-05, card-03, card-01` |
| Trang 3 | `limit: 10, offset: 20` | **0** | — |
| `countsByStatus` | — | `{idea: 15}` | — |

`hasMore` (suy ra đúng cách `ActivityCardListCubit._fetchPage` làm, `page.length ==
pageSize`): `true` ở trang 1, `false` ở trang 2. Nếu lọc trong Dart sau khi đọc,
trang 1 chỉ còn 5 hàng và `hasMore` hoá `false` ngay, mất 10 thẻ sống sót.

Chứng cứ AC-9 bằng id cụ thể: sau khi đóng, `card-01` (sống sót) được đặt
`invited = true, replyState = 'answered'` — tức được mời cho người mới — và vẫn
nằm trong trang 2, `countsByStatus` vẫn `{idea: 15}`. Vị từ không được tính lại
lúc đọc.

### 5. Bằng chứng giao dịch đơn (AC-1)

`_FailsAfterWritingDao` ghi **thật** hàng `chapter_closures` và toàn bộ
`chapter_closure_items` qua `super.createClosure(...)`, tự xác nhận
`closureCount() > 0` ngay tại chỗ, rồi mới ném `StateError`. Sau khi
`close()` ném:

- `gate.hasAnyClosure()` → `false`
- `select(chapter_closure_items)` → rỗng
- `wroteBeforeThrowing` → `true` (chứng minh dữ liệu đã thực sự nằm trong DB trước
  khi ném, nên cái dọn nó đi đúng là transaction bọc ngoài trong `close()`, không
  phải việc "DAO ném trước khi kịp ghi")

### 6. AC coverage

| AC / BR | Nội dung | Test chứng minh | Kết quả |
|---|---|---|---|
| AC-1 | `close()` là một transaction; lỗi giữa chừng không để lại closure một nửa | `lỗi giữa chừng không để lại closure một nửa` | PASS |
| AC-6 | Vị từ phân loại chạy một lần, chỉ tín hiệu dương tính | `chỉ ba tín hiệu dương tính đóng một thẻ` + 2 test biên | PASS |
| AC-7, AC-10 | Thẻ "mới nghĩ ra" chưa từng mời và ca không dứt khoát được giữ lại | `thẻ chưa từng mời ở lại luồng thường ngày`, `ca không dứt khoát giữ lại, không đóng` | PASS |
| AC-8 | Hồ sơ kỹ năng không bao giờ bị lọc và không bao giờ là thành viên | `hồ sơ kỹ năng không bao giờ là thành viên`, `hồ sơ kỹ năng không bao giờ bị lọc` | PASS |
| AC-9 | Tập đóng là ảnh chụp, không tính lại lúc đọc | `thẻ sống sót được mời cho người mới vẫn ở luồng thường ngày` (`card-01`) | PASS |
| AC-11 | Vật liệu đã đóng biến mất khỏi mọi pane và khỏi `countsByStatus` | `không thẻ đã đóng nào lọt vào bất kỳ trang nào`, `countsByStatus đếm theo tập đã lọc`, `watchCardsByStatus phát ra cùng tập đã lọc` | PASS |
| AC-12 | `entries()` rỗng sau khi đóng — trạng thái bình thường, không lỗi | `entries() trả list rỗng, không ném lỗi`, `lọc theo kind cũng rỗng sau khi đóng` | PASS |
| AC-17 | `reopen()` đưa đúng tập vật liệu đó trở lại mọi đường đọc | `reopen xoá hàng closure và mọi thành viên theo cascade`, `mở lại đưa đủ 25 thẻ trở lại mọi đường đọc`, `mở lại đưa đúng tập mục đó trở lại` | PASS |
| BR-3, BR-4 | Không cột mới trên bảng STORY-001/004, không giá trị thứ năm cho `ActivityCardStatus` | Không diff nào chạm `activity_cards_table.dart`/`ActivityCardStatus`; `schemaVersion` vẫn 7 (P1), test v7 của P1 còn xanh ở lệnh 3 | PASS |
| BR-6 | Nhật ký riêng không bao giờ là thành viên closure | `nhật ký riêng không bao giờ là thành viên (BR-6)` | PASS |
| §3 anti-join | Loại trừ **trong SQL**, trước `LIMIT`/`OFFSET` | bảng phân trang ở mục 4 | PASS |
| §6 regression | Test cũ của DAO thẻ / cubit / context notebook còn xanh | lệnh 3 (`+438 ~6`) | PASS |

### 7. Per-story visual fidelity

NOT_APPLICABLE — P2 không dựng hay đổi màn hình nào (đúng như `phase-P2 §6`).

### 8. Lỗi có sẵn, không do phase này

`test/design_system/shared_backdrop_occlusion_test.dart:565` —
`chat shows the shared sky wash` (`pumpAndSettle` timed out). Đã ghi nhận ở P1 mục
6 với ba bằng chứng cho thấy nó không liên quan tới bump `schemaVersion` 6 → 7.
Không nằm trong các thư mục test mà lệnh 3 chạy, nên không xuất hiện trong lần
chạy này; vẫn là lỗi có sẵn, ngoài write scope P2.

## Phase P3 — Xoá sạch và purge giai đoạn 1

Ngày chạy: 2026-09-17. Worktree:
`story-REQ-016_solo_stage1_relationship_assistant-STORY-013_graceful_exit_and_return`,
HEAD nền `5b08a16a`.

### 1. Lệnh đã chạy

| # | Lệnh | Kết quả |
|---|---|---|
| 1 | `flutter test test/features/chapter_closure/stage1_wipe_registry_parity_test.dart` | `00:00 +6: All tests passed!` |
| 2 | `flutter test test/features/chapter_closure/stage1_wipe_service_test.dart` | `00:00 +16: All tests passed!` |
| 3 | `flutter test test/features/chapter_closure/ test/features/journal/` | `00:11 +114 ~4: All other tests passed!` |
| 4 | `flutter analyze lib/features/chapter_closure lib/core/di test/features/chapter_closure` | `13 issues found` — 0 error, 0 warning |
| 5 | `flutter build apk --debug --flavor local` | `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` |

Lệnh 3 là lệnh xác minh mà `phase-P3 §6` yêu cầu. 4 test `~` là test capture ảnh
có sẵn của journal, chúng bị skip từ trước phase này chứ không phải do P3.

Lệnh 4: cả 13 issue đều là `info • prefer_initializing_formals` trên các
constructor tham số-tên gán vào field riêng tư. Dart không cho phép tham số tên
riêng tư (`this._db` sẽ đổi tên tham số công khai), nên lint này chỉ sửa được
bằng cách đổi API công khai — đúng nhận định đã ghi ở P2. 0 error mới.

Lệnh 5 chệch khỏi chữ trong `phase-P3 §6` (`flutter build apk --debug`): dự án
này có flavor, nên lệnh không flavor thất bại ngay ở Gradle
(`Task 'assembleDevDebug' not found`). Dạng có `--flavor local` là dạng hợp lệ
duy nhất và là dạng P1/P2 đã dùng.

### 2. Tệp của phase này

Mới:

- `mobile/lib/features/chapter_closure/data/stage1_wipe_registry.dart`
- `mobile/lib/features/chapter_closure/data/stage1_wipe_service.dart`
- `mobile/test/features/chapter_closure/stage1_wipe_service_test.dart` (16 test)
- `mobile/test/features/chapter_closure/stage1_wipe_registry_parity_test.dart` (6 test)

Sửa:

- `mobile/lib/core/di/service_locator.dart` — thêm đúng hai đăng ký
  `Stage1WipeRegistry` và `Stage1WipeService` (append-only, không đụng đăng ký cũ)

### 3. Bằng chứng số hàng trước/sau `wipeAll()` (AC-14, AC-27)

Số đếm do chính vị từ trong registry sinh ra (cùng SQL mà lệnh xoá chạy), in ra
từ test `mọi bảng trong registry về 0 hàng cho chủ sở hữu`:

| Bảng | Trước | Sau |
|---|---|---|
| `activity_card_photos` | 1 | 0 |
| `invite_messages` | 1 | 0 |
| `activity_cards` | 1 | 0 |
| `journal_photos` | 1 | 0 |
| `journal_entries` | 1 | 0 |
| `notebook_entries` | 1 | 0 |
| `skill_profile_entries` | 1 | 0 |
| `ask_prompt_state` | 1 | 0 |
| `chapter_closure_items` | 3 | 0 |
| `chapter_closures` | 1 | 0 |

Đúng 10 bảng — bằng toàn bộ bảng REQ-016 **có mặt trong lược đồ ở ngày chạy
2026-09-17**. Con số đó không còn là tổng REQ-016: sau khi các story song song
nhập vào nhánh integration, lược đồ có **14** bảng REQ-016 và registry đã được
bổ sung cho đủ 14 — xem mục 12. Bảng số hàng ở trên là ảnh chụp lịch sử của 10
bảng đã đo, không phải danh sách registry hiện tại.
Cùng phép đếm chạy cho tài khoản thứ hai (`user-2`) trên cùng máy cho kết quả
**không đổi** trước/sau, nên phạm vi xoá đúng bằng một chủ sở hữu.

### 4. Bằng chứng `existsSync()` của gốc media (AC-14, AC-27)

In ra từ test `gốc media biến mất khỏi đĩa, gốc của người khác thì không`:

| Gốc media | Trước | Sau |
|---|---|---|
| `journal_media/<hex(user-1)>/` (của mình) | `true` | `false` |
| `journal_media/<hex(user-2)>/` (tài khoản khác) | `true` | `true` |

Không còn tệp mồ côi: sau khi xoá, `journal_media/` chỉ còn đúng một mục con là
segment của `user-2`. Thứ tự là hàng trước, tệp sau (giống
`JournalRepository.deleteAll()`), nên một cú sập giữa chừng chỉ có thể để lại
tệp thừa đã mất hàng — không bao giờ để lại hàng trỏ vào tệp không còn.

### 5. Bằng chứng `purgeClosed()` theo từng id (AC-15)

Ảnh chụp closure: `{activity_card: card-da-dong, notebook_entry: note-da-dong,
ask_prompt: question-da-dong}`.

| Bảng | Còn lại sau purge | Nghĩa |
|---|---|---|
| `activity_cards` | `[card-giu-lai]` | thẻ đã đóng biến mất |
| `activity_card_photos` | `[anh-giu-lai]` | ảnh đính kèm của thẻ đã đóng đi theo |
| `invite_messages` | `[moi-giu-lai]` | lời mời của thẻ đã đóng đi theo |
| `notebook_entries` | `[note-giu-lai]` | mục sổ tay đã đóng biến mất |
| `ask_prompt_state` | `[question-giu-lai]` | trạng thái câu hỏi đã đóng biến mất |
| `skill_profile_entries` | `[skill-1]` | không bao giờ bị chạm (AC-8) |
| `journal_entries` / `journal_photos` | `[journal-1]` / `[journalphoto-1]` | nhật ký riêng không bao giờ là thành viên (BR-6) |

Sau purge `hasAnyClosure()` → `false`: sổ đóng ngăn ra đi cùng vật liệu của nó,
vì các thành viên không còn tồn tại. Hai biên đã kiểm: purge khi **chưa** đóng
ngăn không xoá gì, và purge không với sang hàng của tài khoản khác.

### 6. Tripwire parity của registry

`stage1_wipe_registry_parity_test.dart` so `Stage1WipeRegistry.tables` với
`CupidDatabase.allTables` trừ đúng 5 bảng đệm máy chủ (`messages`,
`timeline_entries`, `timeline_sync_state`, `expenses`,
`expense_sync_metadata`) — loại trừ theo tên, từng quyết định một, không theo
mẫu có thể nuốt mất một bảng REQ-016 tương lai. Thêm một bảng REQ-016 mà quên
đăng ký → test này đỏ.

Test không rỗng nghĩa: có một case cố tình bỏ một bảng khỏi tập đã đăng ký và
khẳng định phép so sánh **phải** khác nhau, nên một so sánh "luôn xanh" không
thể lọt. Ngoài ra mỗi vị từ chủ sở hữu được chạy thật trên lược đồ (`SELECT
COUNT(*) ... WHERE <vị từ>`), nên một lỗi chính tả trong SQL sẽ ném chứ không
âm thầm bỏ sót hàng, và thứ tự bảng con trước bảng cha được khẳng định cho cả
bốn cặp khoá ngoại.

### 7. AC coverage

| AC / BR | Nội dung | Test chứng minh | Kết quả |
|---|---|---|---|
| AC-14 | Sau `wipeAll()` không còn hàng nào của chủ sở hữu trong mọi bảng registry | `mọi bảng trong registry về 0 hàng cho chủ sở hữu` | PASS |
| AC-14 | Gốc media biến mất khỏi đĩa, không còn tệp mồ côi | `gốc media biến mất khỏi đĩa...`, `không còn tệp ảnh mồ côi...` | PASS |
| AC-14 | Khoá tuỳ chọn của REQ-016 bị xoá, khoá tính năng khác ở lại | `khoá tuỳ chọn của REQ-016 bị xoá, khoá tính năng khác ở lại (AC-27)` | PASS |
| AC-14 | `hasAnyClosure()` false và mọi đường đọc rỗng mà không ném lỗi | `hasAnyClosure về false và mọi đọc đều rỗng, không ném lỗi` | PASS |
| AC-27 | Không dư lượng hàng: 0 hàng cho chủ sở hữu ở **cả 14 bảng REQ-016** của registry (số hàng trước/sau của 10 bảng đo ngày 2026-09-17 ở mục 3; 4 bảng còn lại được phủ bởi vòng vá ở mục 12) | `mọi bảng trong registry về 0 hàng cho chủ sở hữu` (vòng lặp trên `registry.tables`, nên tự phủ bảng mới), `mọi bảng REQ-016 trong lược đồ đều có mặt trong registry` | PASS |
| AC-27 | Không file ảnh mồ côi: gốc media biến mất khỏi đĩa và `journal_media/` chỉ còn segment của tài khoản khác (mục 4) | `gốc media biến mất khỏi đĩa...`, `không còn tệp ảnh mồ côi...` | PASS |
| AC-27 | Không dư lượng khoá prefs: mọi khoá REQ-016 — kể cả `req016.last_opened_at` do P6 tạo — không còn sau `wipeAll()` | `khoá tuỳ chọn của REQ-016 bị xoá, khoá tính năng khác ở lại (AC-27)` | PASS (vá F1, xem mục 11) |
| AC-27 | Không hàng đợi hoàn tác/bản nháp sót: `wipeAll()` chạy hai lần liên tiếp vẫn im lặng và vẫn rỗng | `xoá hai lần liên tiếp vẫn im lặng và vẫn rỗng` | PASS |
| AC-15 | Vật liệu đã đóng biến mất thật, vật liệu giữ lại còn nguyên từng id | 3 test trong nhóm `purgeClosed ...` (mục 5) | PASS |
| AC-29 | Không đi qua `clearOnSignOut()`; phiên đăng nhập sống sót | `phiên đăng nhập sống sót: vẫn ghi được ngay sau khi xoá (AC-29)` — `messages` (bộ đệm do đăng xuất sở hữu) còn nguyên, `resolve()` vẫn trả chủ sở hữu, ghi mới thành công | PASS |
| AC-8, BR-6 | Hồ sơ kỹ năng và nhật ký riêng không bị purge chạm vào | `hồ sơ kỹ năng và nhật ký riêng không bao giờ bị purge chạm vào` | PASS |
| §4 registry | Ba danh sách `tables` / `mediaRoots` / `preferenceKeys` đầy đủ và có tripwire | `stage1_wipe_registry_parity_test.dart` (6 test) | PASS |
| §6 regression | `JournalRepository.deleteAll()` và test media-store cũ còn xanh | lệnh 3 (`+114 ~4`) | PASS |

### 8. Per-story visual fidelity

NOT_APPLICABLE — P3 không dựng hay đổi màn hình nào (đúng như `phase-P3 §6`).

### 9. Quan sát để Reviewer đọc trước

1. **`hasAnyClosure()` không lọc theo chủ sở hữu.** Đây là thiết kế có sẵn từ
   P1/P2 (`chapter_closure_dao.dart` nói rõ ledger không mang vị từ owner). Hệ
   quả: trên máy dùng chung, sau khi `user-1` rời đi, `hasAnyClosure()` vẫn
   `true` nếu `user-2` đang có closure. AC-14 được kiểm trong ngữ cảnh thật của
   nó — tài khoản duy nhất trên máy — và ngữ cảnh hai tài khoản được ghi lại
   thành một test riêng (`sổ đóng ngăn của tài khoản khác vẫn còn nguyên`) thay
   vì sửa lén API của P2. Nếu Reviewer muốn `hasAnyClosure()` mang owner, đó là
   thay đổi hợp đồng §3, nằm ngoài write scope P3.
2. **`preferenceKeys` khớp theo tiền tố.** `before_you_go` ghi một khoá cho mỗi
   thẻ (`before_you_go.dismissed_on.<cardId>`), nên không tồn tại danh sách khoá
   chính xác hữu hạn. Khoá chính xác là tiền tố của chính nó, nên cơ chế này là
   tập cha, không phải ngoại lệ.
3. **`req016.last_opened_at` chưa có trong `preferenceKeys`.** Khoá đó do P6 tạo;
   ở BaseHead `5b08a16a` chưa có mã nào trong `lib/` viết khoá đó. P6 phải thêm
   nó vào registry khi tạo.
   → ĐÃ XỬ LÝ ở vòng vá F1 (mục 11): khoá đã nằm trong `preferenceKeys` và có
   khẳng định test rằng nó không còn sau `wipeAll()`.
4. **`activity_card_photos` được xoá hàng nhưng không xoá tệp.** `localPath` trỏ
   tới đường dẫn mà app này chưa từng sao chép vào thư mục của riêng nó, nên xoá
   tệp sẽ với ra ngoài vùng dữ liệu của app và phá ảnh gốc của người dùng. Gốc
   media duy nhất app sở hữu là `journal_media/`, và nó nằm trong `mediaRoots`.
   Khi nào có luồng sao chép ảnh thẻ vào thư mục riêng, gốc đó phải được đăng ký
   thêm.

### 10. Lỗi có sẵn, không do phase này

`test/design_system/shared_backdrop_occlusion_test.dart:565` —
`chat shows the shared sky wash` (`pumpAndSettle` timed out). Đã ghi ở P1 mục 6
và P2 mục 8. Không nằm trong các thư mục mà lệnh 3 chạy nên không xuất hiện
trong lần chạy này; vẫn là lỗi có sẵn, ngoài write scope P3.

### 11. Vòng vá sau review — F1 (`req016.last_opened_at`, AC-27)

Ngày chạy: 2026-09-17, sau `review/review-report.md` `Outcome: PATCH_REQUIRED`.
Vá ở đây chứ không ở P6 vì `stage1_wipe_registry.dart` là tệp do P3 sở hữu;
lý do "write scope của phase" mà P6 viện ra là lý do cấp phase, không phải cấp
story (đúng như F1 lập luận).

Sửa:

- `mobile/lib/features/chapter_closure/data/stage1_wipe_registry.dart` —
  `preferenceKeys` thêm `Stage1LastOpenedStore.preferenceKey`. Dùng chính hằng
  của store thay vì gõ lại chuỗi `'req016.last_opened_at'`, nên đổi tên khoá sẽ
  đi kèm registry thay vì âm thầm để lại dư lượng.
- `mobile/test/features/chapter_closure/stage1_wipe_service_test.dart` — test
  `khoá tuỳ chọn của REQ-016 bị xoá, khoá tính năng khác ở lại (AC-27)` nay gieo
  khoá đó trong `setMockInitialValues`, khẳng định nó **có mặt trước** `wipeAll()`
  (nếu không, phép phủ định sau đó là vô nghĩa), và sau `wipeAll()` khẳng định ba
  điều: khoá không còn trong `prefs.getKeys()`, `Stage1LastOpenedStore
  .absentAtLeast(kReturnAbsenceThreshold, now: DateTime(2030))` trả `false`
  (không còn mốc nào → lần quay lại kế tiếp là cài mới, không phải "vắng 30 ngày"),
  và `theme.selected` / `auth.signed_in_before` của tính năng khác vẫn còn.
- `mobile/test/features/chapter_closure/stage1_wipe_registry_parity_test.dart` —
  khẳng định danh sách `preferenceKeys` cập nhật theo, giữ tripwire không rỗng
  nghĩa.

Bằng chứng in ra từ test (`BẰNG CHỨNG khoá prefs sau wipeAll`):
`{theme.selected, auth.signed_in_before}` — đúng hai khoá của tính năng khác,
không còn khoá REQ-016 nào.

Lưu ý phạm vi tripwire: parity test chỉ đối chiếu `tables` với
`CupidDatabase.allTables`, nên nó **không** thể bắt thiếu sót ở `preferenceKeys`
(đó là lý do F1 lọt qua P3..P6). Khẳng định danh sách khoá ở trên là phần bù thủ
công cho khoảng trống đó.

| # | Lệnh | Kết quả |
|---|---|---|
| 1 | `flutter test test/features/chapter_closure/stage1_wipe_registry_parity_test.dart` | `00:02 +6: All tests passed!` |
| 2 | `flutter test test/features/chapter_closure/stage1_wipe_service_test.dart` | `00:00 +16: All tests passed!` |
| 3 | `flutter test test/features/chapter_closure` | `00:07 +81 ~1: All tests passed!` |
| 4 | `flutter analyze lib/features/chapter_closure test/features/chapter_closure` | `15 issues found` — 0 error, 0 warning, 0 info mới |
| 5 | `flutter build apk --debug --flavor local` | `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` (exit 0) |

Lệnh 4: cả 15 issue đều là `info • prefer_initializing_formals` có sẵn trên
constructor của `chapter_closure_service` / `stage1_wipe_registry` /
`stage1_wipe_service` / `return_gate_resolver`; không issue nào rơi vào dòng mới.
Nền analyze của repo không bao giờ exit 0 (xem P6 mục 1).

Nhãn AC-27: mục 3, mục 4 và bảng AC coverage mục 7 đã gắn lại đúng AC-27 cho
bằng chứng dư lượng đã có sẵn (F3 phần AC-27). AC-13, AC-31, AC-32 của F3 vẫn là
DEFERRED, không thuộc vá này.

### 12. Vòng vá sau integration review — F-I1 (registry thiếu 3 bảng, AC-14/AC-27)

Ngày chạy: 2026-09-26, sau `integration-review/review-report.md`
`Outcome: PATCH_REQUIRED`. Registry được viết khi lược đồ chỉ có 10 bảng
REQ-016; các story song song nhập thêm bảng vào `CupidDatabase` sau đó, nên
đúng thứ mà tripwire parity sinh ra để bắt đã xảy ra thật. Quyết định của Tech
Lead (`architecture/solution.md` §7 phần bổ sung F-I1): `REGISTER` cả ba bảng,
kể cả `calendar_event_state`.

Tổng đã đếm thật trên lược đồ của worktree này (sau khi `sync-target` nhập nhánh
integration, `BaseHead: d95d1eee`): `@DriftDatabase.tables` trong
`mobile/lib/core/database/cupid_database.dart` liệt kê **19** bảng, trừ đúng 5
bảng đệm máy chủ trong `nonReq016Tables()` → **14** bảng REQ-016. Registry
trước vá có 11 entry (10 ban đầu + `thank_you_activations` do một story khác
thêm), thiếu đúng 3.

Sửa:

- `mobile/lib/features/chapter_closure/data/stage1_wipe_registry.dart` — thêm ba
  `Stage1WipeTable`, mỗi bảng khoá trên chính cột `ownerKey` của nó qua helper
  `_ownedBy(...)`, tức vị từ vẫn sinh từ metadata Drift (`GeneratedColumn.name`)
  chứ không gõ tay tên cột:
  `portrait_answers`, `relationship_labels`, `calendar_event_state`.
  `portrait_answers` đặt **trước** `notebook_entries` vì
  `portrait_answers.notebook_entry_id` trỏ sang bảng đó, cùng quy ước con-trước-
  cha mà bốn cặp khoá ngoại đang theo. `nonReq016Tables()` không bị chạm.
- `mobile/test/features/chapter_closure/stage1_wipe_registry_parity_test.dart` —
  không cần sửa: `expect(expected, hasLength(14))` đã là con số đúng của lược đồ
  sau nhập, và chính nó là phép khẳng định chặn một bảng REQ-016 thứ 15 lọt vào
  mà không ai đăng ký. Trước vá phép so sánh `registeredTables() == expected`
  đỏ (11 ≠ 14); sau vá xanh.

| # | Lệnh | Kết quả |
|---|---|---|
| 1 | `flutter test test/features/chapter_closure/stage1_wipe_registry_parity_test.dart --reporter expanded` | `00:00 +6: All tests passed!` — exit 0 |
| 2 | `flutter analyze --no-fatal-infos --no-fatal-warnings lib/features/chapter_closure/data/stage1_wipe_registry.dart test/features/chapter_closure/stage1_wipe_registry_parity_test.dart` | `2 issues found` — 0 error, 0 warning |

Lệnh 1 chạy `--reporter expanded` để mỗi case hiện tên, trong đó có
`mỗi vị từ chủ sở hữu chạy được trên lược đồ thật` — vòng lặp `SELECT COUNT(*)
... WHERE <vị từ>` chạy thật trên cả 14 bảng, nên ba vị từ mới được xác nhận
hợp lệ trên SQLite chứ không chỉ biên dịch được. Lệnh 2: cả 2 issue đều là
`info • prefer_initializing_formals` có sẵn trên constructor
`Stage1WipeRegistry` (dòng 58, 59), không issue nào rơi vào dòng mới.

Bằng chứng dư lượng: `mọi bảng trong registry về 0 hàng cho chủ sở hữu` trong
`stage1_wipe_service_test.dart` duyệt `registry.tables` bằng vòng lặp, nên ba
bảng mới tự nằm trong phép khẳng định đó mà không cần sửa test. Test đó không
được chạy lại ở vòng này (ngoài phạm vi lệnh được cấp cho vòng vá — chỉ tệp
parity); lần chạy xanh gần nhất là lệnh 2 của mục 11.

## Phase P4 — Lối vào đóng ngăn và hộp thoại xác nhận

Ngày chạy: 2026-09-17. Worktree:
`story-REQ-016_solo_stage1_relationship_assistant-STORY-013_graceful_exit_and_return`,
HEAD nền `e1eec120`.

### 1. Lệnh đã chạy

| # | Lệnh | Kết quả |
|---|---|---|
| 1 | `flutter test test/features/chapter_closure/close_chapter_dialog_test.dart` | `00:00 +4 ~1: All tests passed!` |
| 2 | `flutter test test/features/activity_cards/activity_card_hub_close_entry_test.dart` | `00:00 +4: All tests passed!` |
| 3 | `flutter test test/features/chapter_closure/ test/features/activity_cards/activity_card_hub_close_entry_test.dart` | `00:03 +55 ~1: All other tests passed!` |
| 4 | `flutter test test/features/activity_cards/` | `00:13 +227 ~2: All other tests passed!` (exit 0) |
| 5 | `flutter analyze lib/features/chapter_closure lib/features/activity_cards test/features/chapter_closure test/features/activity_cards` | `20 issues found` — 0 error, 0 warning |
| 6 | `flutter test test/features/chapter_closure/close_chapter_dialog_test.dart --dart-define=CAPTURE_VISUALS=true` | `00:02 +5: All tests passed!` (chụp ảnh implemented) |
| 7 | `flutter build apk --debug --flavor local` | `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` |

Test `~` duy nhất ở lệnh 1/3 là chính test chụp ảnh của phase này: nó bị skip
trong luồng thường (để bộ test giữ tính hermetic) và được bật riêng ở lệnh 6.
Hai test `~` ở lệnh 4 là các test chụp ảnh có sẵn của `activity_cards`.

Lệnh 5: cả 20 issue đều là `info • prefer_initializing_formals` trên constructor
có sẵn từ P1/P2 và từ `activity_cards`; không issue nào nằm trong mã P4 viết ra.
Lệnh 7 dùng `--flavor local` vì dự án có flavor (`assembleDevDebug` không tồn
tại) — cùng lý do đã ghi ở P3 mục 1.

### 2. Tệp của phase này

| Tệp | Vai trò |
|---|---|
| `mobile/lib/features/chapter_closure/presentation/widgets/close_chapter_dialog.dart` | hộp thoại xác nhận duy nhất, dựng trên `AlertDialog` + `ActivityDialogChoiceButton` |
| `mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart` | nút overflow `more_vert` một mục, mạch xác nhận → `close()` → dòng báo trung tính → `cubit.load()` |
| `mobile/test/features/chapter_closure/close_chapter_dialog_test.dart` | nội dung, hai lựa chọn ngang nhau, quét từ cấm, giá trị trả về, chụp ảnh |
| `mobile/test/features/activity_cards/activity_card_hub_close_entry_test.dart` | lối vào từ hub, gọi `close()` đúng một lần, huỷ không ghi gì |

### 3. Lệch so với UX spec: overflow không nằm trong app bar

`ux/uiux-spec.md` §1 và `phase-P4` mô tả lối vào là mục trong overflow
`more_vert` của **app bar** tab "Nhà". Vỏ stage-1 hiện tại không có app bar, và
đó không phải thiếu sót: `activity_card_hub_view_test.dart:839` (STORY-006,
AC-22/D-3) khẳng định `find.byType(AppBar) findsNothing` cho phiên chưa ghép
đôi. Thêm `AppBar` làm test đó đỏ — đã đo thật, không suy đoán:

```
Expected: no matching candidates
  Actual: _TypeWidgetFinder:<Found 1 widget with type "AppBar": [...]>
  test description: AC-22/D-3: an unpaired session gets the four-item stage-1 tab bar
```

Cách giải: nút overflow nằm ở hàng đầu trong chính nội dung hub, canh phải —
cùng vị trí và cùng hình dạng thị giác mà app bar sẽ cho, nhưng không dựng lại
thanh chrome mà AC-22/D-3 đã loại bỏ. Mọi ràng buộc đo được của §1 vẫn giữ: một
mục duy nhất, nhãn "Đóng ngăn gọn gàng", không banner, không nút nổi, không gợi ý.

### 4. Lệch so với khung thiết kế: nhật ký riêng

Khung `j11-dong-ngan-gon-gang` vẽ "9 dòng nhật ký riêng" ở phía **sẽ đóng**.
BR-6 cấm điều đó, và `chapter_closure_service.dart` không bao giờ đưa
`journal_entries` vào thành viên closure. Hộp thoại vì vậy liệt kê nhật ký riêng
ở phía **giữ lại**; quyết định được ghi ngay trong doc comment của
`close_chapter_dialog.dart`. AC thắng khung vẽ.

### 5. Quét từ cấm

Test `no consolation, no reason prompt, no reach-out nudge` duyệt **mọi** widget
`Text` trong cây con của hộp thoại và khẳng định không chuỗi nào chứa
`tiếc quá`, `buồn`, `nhớ`, `chắc chắn không đổi ý`, `để lại một lời nhắn`,
`thử nhắn lại`, `vì sao`, `lý do` (không phân biệt hoa thường). Cùng test khẳng
định toàn hộp thoại chỉ có đúng một dấu `?` — tiêu đề — nên không câu hỏi thứ
hai nào lọt vào. Test lối vào quét thêm dòng báo sau khi đóng: không `Mở lại`,
không `nhớ`.

### 6. AC coverage

| AC / BR | Nội dung | Test chứng minh | Kết quả |
|---|---|---|---|
| AC-1 | Một lần xác nhận đóng toàn bộ vật liệu gắn người, gọi `close()` đúng một lần | `one confirmation closes the chapter exactly once` | PASS |
| AC-2 | Hộp thoại chỉ nêu sự thật tác động, không hỏi lý do, không "chắc chưa", không khảo sát | `states the impact facts and nothing else`, `no consolation, no reason prompt, no reach-out nudge` | PASS |
| AC-2 | Đúng hai lựa chọn, ngang nhau về hình, chỉ khác màu hành động chính | `offers exactly two equal choices, action verbs only` | PASS |
| AC-3 | Sau khi đóng: đúng một dòng báo trung tính, tự biến mất | `confirmation is followed by one neutral line, no way back in` | PASS |
| AC-4 | Không câu chữ nào gợi liên hệ lại | quét từ cấm (mục 5) + `expect(find.textContaining('nhớ'), findsNothing)` | PASS |
| AC-5 | Không tồn tại ô lý do / nhãn cảm xúc / trường ghi chú | `expect(find.byType(TextField), findsNothing)`, `find.byType(Radio)` findsNothing | PASS |
| AC-16 | Một lối vào duy nhất, do người dùng chủ động mở; app không tự đề xuất | `the overflow is the only way in, and holds one item` — trước khi mở overflow, không chuỗi nào chứa `ngăn`, không key mục đóng ngăn, không hộp thoại | PASS |
| AC-30 | Huỷ hoặc đóng xong, hub vẫn đứng đó và dùng được | `cancelling writes nothing`, `confirmation is followed by...` — cả hai khẳng định `activity_card_hub` còn trên màn hình | PASS |
| BR-6 | Nhật ký riêng nằm ở phía giữ lại | `states the impact facts and nothing else` so chuỗi dòng 2 với `closeChapterFacts` | PASS |
| BR-9 | Huỷ không ghi gì xuống kho | `cancelling writes nothing` — `closeCalls == 0` | PASS |

Test lối vào dùng `_RecordingClosureService implements ChapterClosureService`
(đếm `close`/`reopen`), nên "đúng một lần" là con số đo được chứ không phải suy
ra từ giao diện.

### 7. Per-story visual fidelity

| Mục | Giá trị |
|---|---|
| Khung thiết kế | `visual-fidelity/design-reference-j11-dong-ngan-gon-gang-ios.png` (415x900, canvas `cupid-ch-ng-1`, screen `j11-dong-ngan-gon-gang`, `--platform=ios`) |
| Khung hiện thực | `visual-fidelity/implemented-j11-dong-ngan-gon-gang-ios.png` (415x900, `RepaintBoundary` trong chính test của phase, đúng viewport tham chiếu) |
| Cách chụp | Màn hình chưa có đường điều hướng trên thiết bị ở phase này, nên dùng phương án `RepaintBoundary` — font đóng gói được nạp thật bằng `FontLoader` để không có glyph hộp |
| Kết quả | PASS với một lệch có chủ ý đã ghi bên dưới |

Đã nhìn tận mắt cả hai ảnh.

Khớp: nền surface tím đậm, bo góc thẻ, tiêu đề đậm, thân là các dòng sự thật
màu chữ mờ, hai hành động ở đáy với **chỉ** hành động chính mang màu đỏ/hồng,
toàn bộ dấu tiếng Việt hiện đúng (không ô tofu nào trong ảnh chụp).

Lệch có chủ ý: khung thiết kế vẽ một màn hình chiếm trọn (X góc trái trên, hai
thẻ kiểm kê, chân trang nói về mở lại trong cài đặt). `phase-P4 §2` và
`uiux-spec §2` lại quy định **một** hộp thoại với **đúng hai** nút ngang nhau,
và chân trang "mở lại" là thứ AC-16 cấm. Hiện thực giữ cấu trúc nội dung của
khung (sẽ đóng / giữ lại / không xoá gì) nhưng đặt nó trong `AlertDialog` theo
đúng luật đo được. Đây là lệch giữa khung và AC, không phải sai lệch thi công.

### 8. Lỗi có sẵn, không do phase này

`test/design_system/shared_backdrop_occlusion_test.dart:565` —
`chat shows the shared sky wash` (`pumpAndSettle` timed out). Đã ghi ở P1 mục 6,
P2 mục 8, P3 mục 10. Ngoài write scope P4.

## Phase P5 — Ô "Đã đóng" trên dải lọc

Ngày chạy: 2026-09-17. Worktree:
`story-REQ-016_solo_stage1_relationship_assistant-STORY-013_graceful_exit_and_return`,
HEAD nền `84c1f0e1`.

### 1. Lệnh đã chạy

| # | Lệnh | Kết quả |
|---|---|---|
| 1 | `flutter test test/features/chapter_closure/closed_archive_actions_test.dart` | `00:00 +6: All tests passed!` |
| 2 | `flutter test test/features/activity_cards/activity_status_filter_closed_pane_test.dart` | `00:01 +8 ~1: All tests passed!` |
| 3 | `flutter test test/features/activity_cards/ test/features/chapter_closure/` | `+292 ~4: All other tests passed!` (exit 0) |
| 4 | `flutter analyze lib/features/activity_cards lib/features/chapter_closure lib/core/database/daos lib/core/di test/features/activity_cards test/features/chapter_closure` | `25 issues found` → sửa còn 24 — 0 error, 0 warning |
| 5 | `flutter test test/features/activity_cards/activity_status_filter_closed_pane_test.dart --dart-define=CAPTURE_VISUALS=true` | `00:00 +9: All tests passed!` (chụp ảnh implemented) |
| 6 | `flutter build apk --debug --flavor local` | `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` |

Lệnh 4 lần đầu ra 25 issue: 24 `info • prefer_initializing_formals` có sẵn từ
P1/P2 và từ `activity_cards`, cộng **một** issue mới do chính test của phase này
sinh ra (`use_null_aware_elements` ở `navigatorObservers`). Đã sửa bằng
`<NavigatorObserver>[?observer]`; sau đó chỉ còn 24 issue nền. Không error mới.

Bốn test `~` ở lệnh 3 là các test chụp ảnh bị skip trong luồng thường (hai của
`activity_cards` có sẵn, một của P4, một của phase này), được bật riêng ở lệnh 5.

### 2. Tệp của phase này

| Tệp | Vai trò |
|---|---|
| `mobile/lib/core/database/daos/activity_card_dao.dart` | `closedCards`/`closedCardCount` — đọc phần đã đóng bằng **chính** phép thử thành viên mà năm ô kia phủ định, đảo dấu trong SQL (`_closed => _notClosed.not()`) |
| `mobile/lib/features/activity_cards/domain/activity_card_repository.dart` | thêm interface riêng `ClosedArchiveReader`, không đụng `ActivityCardRepository` |
| `mobile/lib/features/activity_cards/data/closed_archive_reader_impl.dart` | hiện thực đọc kho đã đóng, dùng lại `activityCardFromRow` |
| `mobile/lib/features/activity_cards/data/activity_card_repository_impl.dart` | mở public hàm map hàng → domain để không có bản sao thứ hai của danh sách cột |
| `mobile/lib/features/activity_cards/presentation/activity_card_list_cubit.dart` | pane thứ sáu `closed`, `hasClosedArchive`/`closedCount`, `_readClosure()`, phân trang kho đã đóng |
| `mobile/lib/features/activity_cards/presentation/widgets/activity_status_filter.dart` | `showClosedPane` và nhãn "Đã đóng" |
| `mobile/lib/features/chapter_closure/presentation/widgets/closed_archive_actions.dart` | hai hành động "Mở lại ngăn" / "Xoá hẳn", mỗi hành động một hộp thoại xác nhận |
| `mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart` | nối dây `ClosedArchiveReader`, sửa điều kiện Phút-1, chèn hàng hành động vào đúng ô "Đã đóng" |
| `mobile/lib/core/di/service_locator.dart` | đăng ký `ClosedArchiveReader` |
| `mobile/test/features/activity_cards/activity_status_filter_closed_pane_test.dart` | 5 ô / 6 ô, chạm được từ màn (1), không route mới, không rò vật liệu, phân trang, chụp ảnh |
| `mobile/test/features/chapter_closure/closed_archive_actions_test.dart` | hai hành động, mỗi hành động một lần xác nhận, huỷ không ghi gì, quét từ cấm |

### 3. Lọc phần đã đóng nằm ở SQL, không ở Dart

`hasMore` của cubit suy ra từ `page.length == _pageSize`. Nếu lọc sau khi đọc,
mỗi trang sẽ ngắn đi một cách ngẫu nhiên và `hasMore` sẽ sai. Vì vậy ô "Đã đóng"
dùng đúng biểu thức anti-join của P3, phủ định trong SQL:

```dart
Expression<bool> get _closed => _notClosed.not();
```

Test `the closed pane pages like the other five` đo điều này với `pageSize: 2`
trên 5 thẻ đã đóng: trang 1 = 2, `hasMore` true; sau hai lần `loadMore` đủ 5 thẻ
và `hasMore` false.

### 4. Vì sao thêm interface mới thay vì thêm hàm vào `ActivityCardRepository`

Đã đếm trước khi quyết: 14 tệp `implements ActivityCardRepository` và 13 chỗ
dựng `ActivityCardRepositoryImpl(` trong test. Thêm một hàm abstract hay một
tham số bắt buộc sẽ làm đỏ toàn bộ. `ClosedArchiveReader` là interface riêng,
tuỳ chọn ở mọi nơi, nên số chỗ phải sửa là 0.

### 5. Bẫy Phút-1 sau khi đóng ngăn

Đóng ngăn có thể đưa `storeCount` về 0. Điều kiện Phút-1 cũ khi đó sẽ giấu dải
lọc — và cùng với nó là lối duy nhất vào kho đã đóng. Đã sửa:

```dart
final bool minuteOne =
    !state.loading && state.storeCount == 0 && !state.hasClosedArchive;
```

### 6. Hồi quy phải sửa: `activity_card_hub_view_test.dart`

Test `AC-10/D-1: renders exactly five panes` khẳng định `ActivityCardPane.values`
có đúng 5 phần tử. Enum giờ có 6. Đo thật:

```
Expected: an object with length of <5>
  Actual: [... ActivityCardPane.closed]
   Which: has length of <6>
```

Sửa đúng ý định gốc của test — dải lọc mà phiên chưa có closure mở ra vẫn là
**đúng năm ô** — bằng cách đếm các pane không phải kho đã đóng và khẳng định
thêm `activity_status_filter_cell_closed` `findsNothing`. Không nới lỏng ràng
buộc nào; AC-16 được khẳng định mạnh hơn trước.

### 7. Quét từ cấm

Test `no congratulation, no consolation, no comment on the decision` duyệt mọi
`Text` trong hộp thoại mở lại **và** mọi `Text` còn trên màn sau khi mở lại,
khẳng định không chuỗi nào chứa `tiếc quá`, `buồn`, `nhớ`, `chúc mừng`,
`tuyệt vời`, `giỏi lắm`, `chắc chắn không đổi ý`, `vì sao`, `lý do`. Cùng test
khẳng định `find.byType(SnackBar) findsNothing`: mở lại không báo bằng lời, chỉ
báo bằng việc kho thay đổi.

### 8. AC coverage

| AC / BR | Nội dung | Test chứng minh | Kết quả |
|---|---|---|---|
| AC-11 | Vật liệu đã đóng chỉ ở ô thứ sáu, không lọt vào năm ô kia | `closed material is absent from the other five panes` — duyệt cả 5 ô, `closedCardsCalls == 0` | PASS |
| AC-11 | Số đếm kho đã đóng đứng riêng, không cộng vào "Tất cả" | `the closed count sits beside the sixth label...` — "Tất cả · 4", "Đã đóng · 2" | PASS |
| AC-14 | Kho đã đóng là một ô trên chính dải lọc | `exactly six cells once a closure exists` | PASS |
| AC-15 | Xoá hẳn gọi `purgeClosed()` đúng một lần, không bao giờ `wipeAll()` | `one confirmation purges the closed material exactly once` | PASS |
| AC-16 | Chưa có closure thì không dấu vết nào của kho đã đóng | `exactly five cells before a closure exists` — không ô `closed`, không chuỗi "Đã đóng" | PASS |
| AC-17 | Mở lại gọi `reopen()` đúng một lần, không lời chúc mừng, không bình luận | `one confirmation reopens the chapter exactly once`, quét từ cấm (mục 7) | PASS |
| AC-30 | Ô thứ sáu không phải ngõ cụt: kho rỗng thì rơi về "Tất cả" | `an emptied archive lands the user on "Tất cả", not a dead end` | PASS |
| AC-2 | Mỗi hành động đúng một lần xác nhận, hai lựa chọn ngang nhau, một dấu `?` | `each dialog offers exactly two equal choices` | PASS |
| AC-5 | Không ô lý do / trường ghi chú trong hộp thoại | cùng test — `TextField`/`EditableText` `findsNothing` | PASS |
| BR-9 | Huỷ không ghi gì | `cancelling writes nothing, on either action` — cả ba bộ đếm bằng 0 | PASS |
| Điều hướng | Ô thứ sáu chạm được từ màn (1), không dẫn sang route mới | `the sixth cell is reachable from screen (1) and opens no route` — `NavigatorObserver` đếm push, không đổi | PASS |

### 9. Per-story visual fidelity

| Mục | Giá trị |
|---|---|
| Khung thiết kế | `visual-fidelity/design-reference-kho-da-dong-ios.png` (415x900, canvas `cupid-ch-ng-1`, screen `ngan-da-hen-ngay-dang-doi`, `--platform=ios`) |
| Khung hiện thực | `visual-fidelity/implemented-kho-da-dong-ios.png` (415x900, `RepaintBoundary` trong chính test của phase, đúng viewport tham chiếu) |
| Cách chụp | Trạng thái này chỉ tới được sau khi đóng ngăn thật nên dùng phương án `RepaintBoundary` đã có tiền lệ trong REQ-016; font đóng gói nạp thật bằng `FontLoader`, và cây được bọc một lớp `ColoredBox` mờ đục vì nếu không ảnh ra trong suốt |
| Kết quả | PASS với hai lệch có chủ ý đã ghi bên dưới |

Đã nhìn tận mắt cả hai ảnh.

**Canvas không có khung riêng cho kho đã đóng.** `phase-P5 §6` nhắc tới SB-64/SB-65
trên `cupid-ch-ng-1`; liệt kê thật bằng
`render-design-canvas.js --surface=cupid-ch-ng-1 --list-screens` cho 29 khung và
không khung nào vẽ bề mặt này:

```
chon-che-do-lan-dang-nhap-dau, phut-1-kho-trong, man-goc-muon-lam,
ngan-da-hen-ngay-dang-doi, chi-tiet-the-moi-nghi-ra, sb-211-truoc-gio-di,
23h-vua-ve-j8, sb-212-cam-on-chot-viec-ke-tiep, the-da-thanh-ky-niem,
11-xuat-loi-moi-chon-khung, 11-dien-mad-libs-xem-truoc, j11-dong-ngan-gon-gang,
j13-quay-lai-sau-3-thang, tab-y-tuong-hub-cua-vao, 5-goi-y-qua-thang-cong-suc,
6-moi-chuyen-a-a, 7-vo-hoang-dao-3-viec, 9-kich-ban-buoi-hen,
8-chan-dung-theo-cach-ban-nhin, 10-bang-tra-an-khop, 2-so-tay-nguoi-yeu,
3-ho-so-ky-nang-phien-ban-toi, 4-nhat-ky-rieng, man-goc-sang, loi-moi-sang,
c3-them-viec-khong-ma-sat, sb-84-widget-bon-pha, j12-nhan-ra-cot-moc,
tro-doan-khong-thang-thua
```

Neo thiết kế vì vậy là `ngan-da-hen-ngay-dang-doi` — khung **duy nhất** vẽ chính
dải lọc mà phase này thêm ô thứ sáu vào. Đây là bằng chứng mạnh hơn
`NOT_APPLICABLE`: ô mới phải giống hệt năm ô đã vẽ, và khung đó cho biết "giống
hệt" nghĩa là gì.

Khớp: viên thuốc bo tròn, nhãn đầy đủ không viết tắt kèm `· <số>` chữ nhỏ, viên
đang chọn tô hồng đặc chữ trắng, viên còn lại viền mảnh chữ mờ, dải cuộn ngang
thay vì co nhãn. Ô "Đã đóng · 2" được vẽ đúng bằng cùng `_StatusCell`, không
badge đỏ, không huy hiệu. Toàn bộ dấu tiếng Việt hiện đúng trong ảnh chụp
("Đã đóng", "Đã thành kỷ niệm", "Mở lại ngăn", "Xoá hẳn") — không ô tofu nào.

Lệch có chủ ý 1: khung thiết kế có tiêu đề "Muốn làm" và thanh tab dưới đáy.
Ảnh hiện thực không có, vì vỏ stage-1 đã bỏ app bar theo AC-22/D-3 (đã ghi ở P4
mục 3) và host của widget test không dựng thanh tab. Không phải sai lệch thi công.

Lệch có chủ ý 2: trong ảnh hiện thực dải lọc đã cuộn sang phải nên viên trái
cùng bị cắt. Đó chính là hành vi khung thiết kế quy định — cuộn ngang thay vì co
nhãn — và là thao tác thật mà test dùng để chạm tới ô thứ sáu.

### 10. Lỗi có sẵn, không do phase này

`test/design_system/shared_backdrop_occlusion_test.dart:565` —
`chat shows the shared sky wash` (`pumpAndSettle` timed out). Đã ghi ở P1 mục 6,
P2 mục 8, P3 mục 10, P4 mục 8. Không nằm trong các thư mục mà lệnh 3 chạy.
Ngoài write scope P5.

## Phase P6 — Cổng quay lại và màn J13

Status: **COMPLETE**
Ngày chạy: 2026-09-17
Flutter 3.44.1 / Dart 3.12.1 (`export PATH="$HOME/flutter/bin:$PATH"`)

### 1. Lệnh đã chạy

| # | Lệnh (chạy trong `mobile/`) | Kết quả |
|---|---|---|
| 1 | `flutter test test/features/chapter_closure/` | `81 passed, 1 skipped` — 0 failed |
| 2 | `flutter test test/features/auth/presentation/splash_screen_test.dart` | `+10: All tests passed!` — hồi quy splash còn nguyên |
| 3 | `flutter test test/features/chapter_closure/ test/features/auth/` (lệnh của `phase-P6 §6`) | `::error::191 tests passed, 4 failed, 1 skipped.` — **cả 4 lỗi là lỗi nền, đã đo ở mục 9** |
| 4 | `flutter analyze lib test` | `241 issues found.` — **0 error**, 0 warning mới; hai `info` duy nhất do phase này sinh ra ghi ở mục 4 |
| 5 | `flutter analyze --no-pub lib/features/chapter_closure lib/features/auth lib/core/di test/features/chapter_closure` | `33 issues found.` — 0 error; phần thu hẹp vào đúng code phase này chạm tới |
| 6 | `flutter build apk --debug --flavor local` | `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` — exit 0 |

Ghi chú lệnh 4: theo nền đã ghi từ P1, exit code của `flutter analyze` toàn repo
không phải bằng chứng (hàng trăm warning cũ, 0 error). Gate là "0 error mới".

### 2. Tệp của phase này

| Tệp | Vai trò |
|---|---|
| `mobile/lib/features/chapter_closure/data/stage1_last_opened_store.dart` | mốc mở app, một khoá `req016.last_opened_at`; **không** getter nào trả ngày hay khoảng cách |
| `mobile/lib/features/chapter_closure/domain/return_gate_resolver.dart` | `shouldShow()` / `markOpened()`, một hằng ngưỡng duy nhất `kReturnAbsenceThreshold = 30 ngày` |
| `mobile/lib/features/chapter_closure/presentation/screens/return_screen.dart` | màn J13: lời chào trung tính, ba lựa chọn ngang nhau, lối X, liên kết xoá sạch |
| `mobile/lib/features/chapter_closure/presentation/widgets/wipe_confirm_dialog.dart` | hộp thoại xác nhận xoá sạch, dựng theo đúng khuôn `close_chapter_dialog.dart` của P4 |
| `mobile/lib/features/auth/presentation/screens/splash_screen.dart` | cắm nhánh cổng vào đường đã xác thực, thêm seam `returnGateResolver` |
| `mobile/lib/core/di/service_locator.dart` | đăng ký `Stage1LastOpenedStore` và `ReturnGateResolver` |
| `mobile/test/features/chapter_closure/return_gate_resolver_test.dart` | 8 test: dưới/đúng/trên ngưỡng, máy mới, một khoá duy nhất, `markOpened`, rào kiểu |
| `mobile/test/features/chapter_closure/return_screen_test.dart` | 16 test: bố cục, quét từ cấm, bốn lối ra cộng lối X, luồng xoá sạch, hai ca đi qua splash, chụp ảnh |

### 3. Rào kiểu của AC-20 nằm ở chữ ký, không ở lời hứa

AC-20 cấm màn biết mình đã vắng bao lâu. Cách chặn không phải là "không dùng",
mà là không có đường để dùng: toàn bộ bề mặt public của cổng chỉ có
`Future<bool> shouldShow()`, `Future<void> markOpened()` và
`Future<bool> absentAtLeast(Duration, {required DateTime now})`. Không thành viên
public nào trả `Duration`, `DateTime`, `int` hay `num`.

Test `no public member of the gate returns a Duration, DateTime, or count` quét
chính hai tệp nguồn bằng biểu thức chính quy (`dart:mirrors` không dùng được dưới
`flutter test`) và fail nếu ai đó thêm một getter như thế. Test thứ hai khẳng
định trong `return_gate_resolver.dart` có **đúng một** dòng `^const Duration `,
chặn việc lén thêm tầng ngưỡng thứ hai mà AC-19 không cho.

### 4. Hai `info` analyze mới và vì sao giữ nguyên

`return_gate_resolver.dart:18,19` sinh `prefer_initializing_formals`. Đây đúng
kiểu đã có sẵn ở `stage1_wipe_service.dart:27-32`,
`chapter_closure_service.dart:29-33` và `stage1_wipe_registry.dart:57,58` — tức
là khuôn mà chính thư mục này đang dùng (trường private có tên khác tham số).
Sửa riêng hai dòng này sẽ làm code của phase lệch khỏi năm tệp anh em. 0 error,
0 warning.

### 5. Splash không được phép đỏ khi cổng chưa đăng ký

`_navigateAuthenticated()` không gọi thẳng `getIt<ReturnGateResolver>()`. Nhiều
harness test chỉ đăng ký `CupidDatabase` + `ActivityCardRepository`, nên một lần
`getIt` cứng sẽ ném và làm đỏ hồi quy splash. Dùng đúng tiền lệ đã có trong
`pairing_choice_screen.dart` và `app_shell.dart`:

```dart
final ReturnGateResolver? resolver = widget.returnGateResolver ??
    (getIt.isRegistered<ReturnGateResolver>() ? getIt<ReturnGateResolver>() : null);
```

Cổng chưa đăng ký nghĩa là "không có cổng quay lại", không phải lỗi. Lệnh 2
chứng minh 10 test splash sẵn có còn xanh nguyên.

### 6. Lệch có chủ ý: ba lựa chọn cùng đổ về một màn dùng được

`phase-P6 §3` gộp ba đích đến thành "một màn dùng được". Đo trước khi quyết:
`AppShell` không có seam chọn tab ban đầu, `HomeScreen` không có seam chọn ô ban
đầu. Dựng hai seam đó phải sửa tệp ngoài write scope của phase. Vì vậy cả ba ô,
lối X, và cả nhánh sau khi xoá sạch đều `pushReplacement` về `PairGateShell`.
Điều quan trọng của AC-24/AC-30 vẫn được giữ và được đo: J13 không bao giờ là
cổng chặn, không pop ngược về được, và mọi lối ra đều dẫn tới màn dùng được.

### 7. `req016.last_opened_at` không nằm trong `Stage1WipeRegistry`

Đã cân nhắc và **không** thêm khoá này vào `Stage1WipeRegistry.preferenceKeys`:
tệp đó nằm ngoài write scope của phase, và mốc mở app được làm mới ngay tại
splash của chính lần chạy đó, nên sau khi xoá sạch J13 không thể hiện lại. Ghi
lại ở đây để reviewer quyết định có muốn gom khoá này vào registry ở một phase
sau hay không.

→ **Quyết định đã lật: reviewer chặn (F1).** Lý do write scope là lý do cấp
phase, không phải cấp story, và AC-27 nói về dư lượng trên thiết bị chứ không
nói về hành vi màn hình, nên lập luận "splash làm mới mốc ngay" không gỡ được
AC-27. Khoá đã được thêm vào `preferenceKeys` cùng test khẳng định — xem mục 11
của phase P3.

### 8. AC coverage

| AC / BR | Nội dung | Test chứng minh | Kết quả |
|---|---|---|---|
| AC-18 | Vắng đủ lâu thì lần mở app tiếp theo rơi vào J13 | `an authenticated launch past the threshold lands on J13` — đi qua `SplashScreen` thật, không dựng màn trực tiếp | PASS |
| AC-18 | Chưa đủ lâu thì đường cũ giữ nguyên | `an authenticated launch below the threshold keeps the old route` | PASS |
| AC-19 | Đúng một ngưỡng, không tầng thứ hai | `exactly one absence threshold constant exists, at 30 days` | PASS |
| AC-19 | Dưới / đúng / trên ngưỡng, và máy chưa từng mở | 4 test nhóm `shouldShow` | PASS |
| AC-20 | Màn không biết được mình đã vắng bao lâu | `no public member of the gate returns a Duration, DateTime, or count` | PASS |
| AC-21 | Không câu chữ nào nhắc tới sự vắng mặt | `carries no forbidden phrase on the screen or in the dialog` — quét 20 cụm cấm trên mọi `Text` của màn và của hộp thoại | PASS |
| AC-22 | Ba lựa chọn cố định, không xếp hạng, không gợi ý | `draws all three choices at the same size and weight`; cả ba do cùng một `_ChoiceTile` vẽ | PASS |
| AC-23 | Quyết định chỉ đọc một nguồn duy nhất | `reads exactly one key, so nothing else can feed the decision` — `prefs.getKeys()` đúng một khoá | PASS |
| AC-24 | Cổng chỉ hiện một lần, không quay lại được | `the screen cannot be popped back to`; `markOpenedCalls == 1` ngay trong lần mở đó | PASS |
| AC-24 / AC-30 | Mọi lối ra dẫn tới màn dùng được | `choice 1..3 replaces the screen with the app root`, `the close icon behaves exactly like a choice` | PASS |
| AC-25 | Liên kết xoá sạch có mặt nhưng không nổi bật | `separates the wipe link from the last choice by at least lg`; kiểu `caption`, không nền, không biểu tượng | PASS |
| AC-26 | Xoá sạch gọi `wipeAll()` đúng một lần | `one confirmation wipes and lands on the first-run state` | PASS |
| AC-28 | Hộp thoại không hỏi lý do, không giữ chân | `the confirmation asks nothing and offers exactly two actions` — đúng một dấu `?`, không `TextField` | PASS |
| AC-29 | Sau khi xoá về thẳng trạng thái đầu, không màn chia tay | cùng test ở AC-26 | PASS |
| BR | Huỷ thì không ghi gì | `cancelling wipes nothing and keeps the screen` — `wipeAllCalls == 0` | PASS |
| Chạm | Lối X đủ vùng chạm | `gives the close icon a full tap target (≥44pt)` | PASS |

### 9. Bốn lỗi ở lệnh 3 là lỗi nền, đã đo chứ không suy đoán

Đã chạy hai lần cùng một lệnh trên cùng worktree, khác nhau đúng ở chỗ có hay
không có thay đổi của phase này (`git stash push` riêng hai tệp `lib/` bị sửa,
rồi `git stash pop`, đối chiếu `diff -q` sau khi khôi phục):

| Lần chạy | Lệnh | Kết quả |
|---|---|---|
| Có thay đổi P6 | `flutter test test/features/auth/` | `110 tests passed, 4 failed` |
| Đã gỡ thay đổi P6 | `flutter test test/features/auth/` | `110 tests passed, 4 failed` |

Số giống hệt nhau, và đúng bốn test đó:

| Test | Nguyên nhân đo được |
|---|---|
| `auth_repository_test.dart` → `every social entry point records the marker` | `[core/no-app] No Firebase App '[DEFAULT]' has been created` từ `auth_repository.dart:230` |
| `auth_leg_edges_test.dart` → `social sign-in lands on the resolved node, never straight on home` | `Found 0 widgets with text "node:pairingChoice"` |
| `auth_leg_edges_test.dart` → `social sign-in for an account with no display name resumes on the real profile setup screen` | `Found 0 widgets with type "OnboardingProfileSetupScreen"` |
| `welcome_screen_test.dart` → `the shared twinkle star field paints over the backdrop` | `Expected: a numeric value within <0.02> of <1.0>, Actual: <0.7411764705882353>` |

Cả bốn nằm trong `welcome_screen` / `auth_repository` — không tệp nào trong
`git diff --name-only <BaseHead>` của phase này, và không đường nào đi qua
`splash_screen`, `ReturnScreen` hay `ReturnGateResolver`. Ngoài write scope P6.

### 10. Per-story visual fidelity

| Mục | Giá trị |
|---|---|
| Khung thiết kế | `visual-fidelity/design-reference-j13-quay-lai-sau-3-thang-ios.png` (415x900, canvas `cupid-ch-ng-1`, screen `j13-quay-lai-sau-3-thang`, `--platform=ios`) |
| Khung hiện thực | `visual-fidelity/implemented-j13-man-quay-lai-ios.png` (390x844, `RepaintBoundary` trong chính test của phase) |
| Cách chụp | Màn chỉ tới được sau khi mốc mở app vượt ngưỡng nên dùng phương án `RepaintBoundary` đã có tiền lệ trong REQ-016; font đóng gói (Nunito, Roboto, Roboto Mono, Material Symbols Rounded) nạp thật từ đĩa bằng `FontLoader` |
| Kết quả | PASS với năm lệch có chủ ý ghi bên dưới |

Ghi chú id khung: `phase-P6 §6` đoán id là "SB-100". Liệt kê thật bằng
`render-design-canvas.js --surface=cupid-ch-ng-1 --list-screens` cho thấy không
có khung nào tên như vậy; khung đúng của J13 là `j13-quay-lai-sau-3-thang`.

Đã nhìn tận mắt cả hai ảnh. Mọi dấu tiếng Việt hiện đúng trong ảnh hiện thực
("Chào bạn", "Xem kho ý tưởng", "Xem sổ tay & kỹ năng", "Bắt đầu một việc mới",
"Xoá hết dữ liệu chặng 1") và cả ba biểu tượng vẽ ra hình thật — không ô tofu.

**Năm lệch so với canvas, tất cả đều do AC ép, không phải thi công sai:**

1. Lời chào. Canvas viết "Chào bạn. Mở lại từ đâu cũng được." kèm dòng phụ "Mọi
   thứ vẫn nguyên chỗ cũ. Không có gì phải bù, không có gì bị mất." Bỏ: cả hai
   câu đều quy chiếu về sự vắng mặt và dùng khung "mất mát" (AC-20, AC-21). Bản
   hiện thực dùng lời chào đúng bằng lời chào của người rời đi từ hôm qua.
2. Dòng phụ trên mỗi ô. Canvas có "8 điều vẫn còn để dành", "2 chỗ theo mùa —
   giờ đang đúng mùa đó", "34 dòng". Bỏ: AC-22 buộc ba lựa chọn phải cố định,
   không chấm điểm, không xếp hạng; riêng "giờ đang đúng mùa đó" là một gợi ý
   thứ tự trá hình.
3. Nút xoá sạch. Canvas đặt một nút viên thuốc căn giữa, nhãn "Xoá sạch — một
   thao tác", dưới câu dẫn "Hoặc dọn hết cho nhẹ lòng." Thay bằng liên kết chữ
   nhỏ màu đỏ như `ux/uiux-spec.md` §6 quy định; "cho nhẹ lòng" là khung cảm xúc
   mà §2 cấm.
4. Lối X. Canvas không vẽ nút đóng. `ux/uiux-spec.md` §6 và `phase-P6 §3` đều
   bắt buộc phải có ("Mọi lối ra, kể cả nút đóng X"), nên bản hiện thực thêm.
5. Chip biểu tượng. Canvas tô mỗi ô một màu khác nhau. Bản hiện thực vẽ cả ba
   giống hệt theo §6 ("cùng cỡ, cùng kiểu, cùng độ đậm"), vì màu khác nhau đọc
   ra thành thứ tự ưu tiên (AC-22).
