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

### 3. Bằng chứng số hàng trước/sau `wipeAll()` (AC-14)

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

Đúng 10 bảng — bằng toàn bộ bảng REQ-016 trong `CupidDatabase.allTables`.
Cùng phép đếm chạy cho tài khoản thứ hai (`user-2`) trên cùng máy cho kết quả
**không đổi** trước/sau, nên phạm vi xoá đúng bằng một chủ sở hữu.

### 4. Bằng chứng `existsSync()` của gốc media (AC-14)

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
| AC-14 | Khoá tuỳ chọn của REQ-016 bị xoá, khoá tính năng khác ở lại | `khoá tuỳ chọn của REQ-016 bị xoá, khoá tính năng khác ở lại` | PASS |
| AC-14 | `hasAnyClosure()` false và mọi đường đọc rỗng mà không ném lỗi | `hasAnyClosure về false và mọi đọc đều rỗng, không ném lỗi` | PASS |
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
