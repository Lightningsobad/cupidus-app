# Test Results — REQ-017 / STORY-001

Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-017_checkin_notebook_capture-STORY-001_checkin_notebook_capture`
Branch: `codex/REQ-017_checkin_notebook_capture-STORY-001_checkin_notebook_capture`
BaseHead: `0198e32ddd3f8bad6a4d5274fd7b5ebeae9158b1`
Flutter SDK: `$HOME/flutter/bin` (không có trên PATH mặc định, phải prefix)
Mọi lệnh chạy từ `<worktree>/mobile`.

## P1 — Notebook origin persistence

### Kết luận

`Phase: P1`
`Result: PASS`
`Blocker: NONE`

Toàn bộ tiêu chí nghiệm thu của P1 đã được chứng minh xanh, và gate hồi quy
`context_notebook` giờ cũng xanh sau khi BUG-20260927-001 được sửa — xem mục
"Gate 5" ở cuối. Lần chạy đầu của P1 (BaseHead `0198e32d`) bị chặn bởi một test
đỏ sẵn ngoài WriteScope; lịch sử đó giữ lại bên dưới để truy vết.

### Gate 1 — migration + database (integration, RS-1/RS-3)

```
PATH="$HOME/flutter/bin:$PATH" flutter test test/core/database --reporter failures-only
```

`Result: PASS` — `+106: All tests passed!`, exit 0.

Bao gồm nhóm mới `v10 -> v11 (REQ-017 origin columns)` trong
`test/core/database/context_notebook_migration_test.dart`:

- `adds the three origin columns with ADD COLUMN only` — nâng cấp từ một file
  schema v10 thật (mở schema hiện tại, xoá đúng ba cột v11, rewind
  `PRAGMA user_version = 10`), khẳng định `user_version` thành 11 và ba cột
  `origin_check_in_ref` / `origin_card_id` / `origin_card_title` xuất hiện.
- `the pre-v11 row survives and reads back with all three columns null` — hàng
  ghi từ thời v10 còn nguyên và đọc lại ra `null` cả ba cột (AC: hàng cũ đọc
  được với ba giá trị null).
- Danh sách cột đóng của `notebook_entries` đã mở rộng đúng ba cột, nên khẳng
  định "không cột nào đo hành vi người kia" vẫn giữ nguyên hiệu lực.
- Nhánh migration chỉ dùng `m.addColumn`, không `DROP`/`deleteTable`/
  `destructivelyRecreate` — khẳng định "không huỷ-tạo-lại bảng" tiếp tục xanh.

### Gate 2 — repository unit (RS-6)

```
PATH="$HOME/flutter/bin:$PATH" flutter test \
  test/features/context_notebook/ask_cadence_policy_test.dart \
  test/features/context_notebook/ask_on_the_spot_slot_test.dart \
  test/features/context_notebook/context_notebook_closure_filter_test.dart \
  test/features/context_notebook/context_notebook_repository_test.dart \
  test/features/context_notebook/notebook_screen_test.dart \
  test/features/context_notebook/skill_profile_screen_test.dart \
  --reporter failures-only
```

`Result: PASS` — `+78: All tests passed!`, exit 0.

Nhóm mới `ghi từ check-in là idempotent theo lần check-in (AC-8/BR-12)` trong
`context_notebook_repository_test.dart` phủ:

- hai lần gọi cùng `originCheckInRef` → đúng một hàng, `kind`/`value`/
  `updated_at` bị ghi đè (đếm hàng sau hai lần ghi cùng ref);
- hai `originCheckInRef` khác nhau → hai hàng (BR-12);
- `cardTitle == null` → `origin_card_title` null và lệnh ghi vẫn thành công
  (AC-9);
- `source` giữ `ask_on_the_spot` và `ContextEntrySource.values` vẫn đúng hai
  giá trị (BR-11);
- `addEntry` không mang theo xuất xứ;
- `updateEntry` giữ nguyên cả ba cột xuất xứ (AC-5);
- `deleteEntry` không chạm ba cột xuất xứ;
- hàng của owner thứ hai bị cô lập khỏi khoá idempotency.

### Gate 3 — hồi quy `schemaVersion` (cùng lần chạy)

```
PATH="$HOME/flutter/bin:$PATH" flutter test \
  test/features/compatibility_lookup/relationship_label_repository_test.dart \
  test/features/activity_cards/activity_type_test.dart \
  test/features/activity_cards/thank_you/thank_you_activation_migration_test.dart \
  test/features/your_view_portrait/portrait_answer_repository_test.dart \
  --reporter failures-only
```

`Result: PASS` — `+74: All tests passed!`, exit 0.

Việc nâng `schemaVersion` 10 → 11 làm đỏ hai lớp khẳng định, đã sửa hết trong
cùng lần chạy này:

1. Các khẳng định chốt cứng số 10 (`readUserVersion`, `schemaVersion`) trong 15
   file test — đã đổi sang 11. Riêng `cupid_database_migration_v3_test.dart`
   dùng biến `version` nên không cần sửa.
2. `SqliteException(1): duplicate column name: origin_check_in_ref` trong các
   fixture migration của story khác. Nguyên nhân: fixture dựng schema hiện tại
   rồi chỉ xoá bảng của đúng version mình rồi rewind `user_version`, nên
   `notebook_entries` đã sẵn ba cột khi nhánh v11 chạy `ADD COLUMN`. Đã thêm
   vòng `ALTER TABLE notebook_entries DROP COLUMN` cho ba cột vào từng fixture
   (đúng hình dạng của một máy v6–v10 thật), thay vì để migration production dò
   cột tồn tại — đó sẽ là code phòng thủ cho một tình huống chỉ có trong fixture.

### Gate 4 — static analysis

```
PATH="$HOME/flutter/bin:$PATH" flutter analyze \
  lib/core/database lib/features/context_notebook \
  test/core/database test/features/context_notebook
```

`Result: PASS (theo delta)` — `8 issues found.`, exit 1.

Baseline của repo khác 0 theo thiết kế, nên chỉ so delta. Cả 8 issue đều ở mức
`info` / `prefer_initializing_formals`, nằm trên constructor của
`context_notebook_repository.dart` (dòng 27–30) và
`ask_on_the_spot_cubit.dart` (dòng 66–69) — đều có sẵn trước P1. 0 error, 0
warning. Delta do P1 tạo ra: 0.

### Gate đỏ (LỊCH SỬ — đã giải quyết) — hồi quy `context_notebook`

```
PATH="$HOME/flutter/bin:$PATH" flutter test test/features/context_notebook/ask_cadence_policy_test.dart \
  test/features/context_notebook/ask_on_the_spot_slot_test.dart \
  test/features/context_notebook/context_content_gate_test.dart \
  test/features/context_notebook/context_notebook_closure_filter_test.dart \
  test/features/context_notebook/context_notebook_repository_test.dart \
  test/features/context_notebook/notebook_screen_test.dart \
  test/features/context_notebook/skill_profile_screen_test.dart \
  --reporter failures-only
```

`Result: FAIL` — `+105 -1: Some tests failed.`, exit 1.

Test đỏ duy nhất:

- File: `test/features/context_notebook/context_content_gate_test.dart:159`
- Test: `shipped packs pass the gate from disk (AC-35/AC-36/BR-18) >`
  `no pack wording is written into any Dart or l10n file (BR-16)`
- Khẳng định: `Expected: empty` / `Actual: ['lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart contains "Cà phê sáng"']`

Nguyên nhân: test quét toàn bộ `lib/**` tìm bất kỳ chuỗi nào trùng với
`prompt`/`chips`/`skill label` của các pack JSON đã ship. Một literal trong
`lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart` trùng chữ với một
chip của pack ask.

Bằng chứng đây là lỗi có sẵn ở BaseHead, không do P1:

```
git rev-parse HEAD
  -> 0198e32ddd3f8bad6a4d5274fd7b5ebeae9158b1   # bằng đúng BaseHead

git diff --quiet 0198e32d -- mobile/lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart
  -> exit 0   # file gây lỗi giống BaseHead từng byte

git diff --quiet 0198e32d -- mobile/test/features/context_notebook/context_content_gate_test.dart
  -> exit 0   # file test giống BaseHead từng byte
```

Cả input lẫn chủ thể của khẳng định đều không nằm trong diff của P1
(`git diff --name-only 0198e32d` không chứa hai đường dẫn trên). Test là một
phép quét file tất định, nên nó đỏ y như vậy tại BaseHead khi chưa có bất kỳ
thay đổi nào của P1.

Tại sao P1 không tự sửa:

- Sửa đúng chỗ là `lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart`
  (đổi literal) hoặc pack JSON của ask — cả hai đều ngoài WriteScope của P1.
- `context_content_gate_test.dart` thì nằm trong WriteScope (`mobile/test`),
  nhưng nới khẳng định BR-16 của story khác để lần chạy của mình xanh là làm
  yếu chốt kiểm soát, không phải sửa lỗi.

Đề xuất cho Scrum Master: mở bug cho xung đột chữ giữa pack ask và
`zodiac_shell_resolver.dart` (REQ-016), rồi quyết định P1 có được chuyển `DONE`
hay không dựa trên bốn gate đã xanh ở trên.

### Gate 5 — hồi quy `context_notebook` + `zodiac_shell` sau khi sửa bug

BUG-20260927-001 đã `DONE` (bugfix review `Outcome: DEFERRED_ONLY`), và commit
sửa trên `main` (`70ddb8b8`) đã được cherry-pick vào worktree này thành
`248e9179`. Kiểm chứng trước khi chạy:

```
git rev-parse HEAD
  -> 248e9179cd8a2836497a79aa133ab498efd5251e
git rev-parse HEAD:mobile/lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart
  -> 6d6df182e70eaff11b988a30a60ea9cb8321857e   # khớp main
```

Toàn bộ thay đổi P1 chưa commit còn nguyên, không có xung đột.

```
PATH="$HOME/flutter/bin:$PATH" flutter test \
  test/features/context_notebook test/features/zodiac_shell \
  --reporter failures-only
```

`Result: PASS` — `+248 ~8: All other tests passed!` (8 test skipped sẵn),
exit 0.

Ca BR-16 ở `context_content_gate_test.dart:159` giờ xanh, nên gate hồi quy
`context_notebook` của §6 đã thoả theo cả hai cách đọc nêu bên dưới — câu hỏi
diễn giải trở thành vô nghĩa và không cần Scrum Master chốt nữa.

Lần chạy này có nạp `visual_capture_test.dart`; `git status` sau đó xác nhận
không có PNG visual-fidelity nào của story khác bị bẩn.

### Gate 6 — chạy lại `test/core/database` tại HEAD sau cherry-pick

Gate bằng chứng build yêu cầu chạy lại đúng lệnh của Gate 1 tại HEAD hiện tại
(Gate 1 ban đầu chạy ở HEAD `0198e32d`, trước cherry-pick), để chứng minh
migration cộng thêm và các chốt `schemaVersion` vẫn xanh ở `248e9179`.

```
PATH="$HOME/flutter/bin:$PATH" flutter test test/core/database \
  --reporter failures-only
```

`Result: PASS` — `+106: All tests passed!`, exit 0. Không lệch so với Gate 1.

### (LỊCH SỬ — không còn cần quyết định) Đọc §6 theo nghĩa nào

Câu §6 là: "các suite `context_notebook` hiện có và mọi test chốt
`schemaVersion` phải **xanh lại** trong cùng lần chạy". Có hai cách đọc, và
verdict của P1 phụ thuộc hoàn toàn vào việc chọn cách nào.

**Cách đọc A — "mọi file trong thư mục phải xanh" → P1 `BLOCKED`.**
Đây là cách tôi đã áp dụng cho `## 7. Status` và hàng P1 trong master-plan.

**Cách đọc B — "không được gây hồi quy" → P1 đạt gate.**
Lập luận:

- "xanh **lại**" hàm ý trước đó đã xanh. `context_content_gate_test.dart` chưa
  từng xanh ở BaseHead, nên nó không thể "xanh lại".
- Risk surface tương ứng trong `../architecture/solution.md` §4 tên là
  **RS-6 Notebook consumer non-regression**, tức đối tượng bảo vệ là hồi quy.
- Quan trọng nhất: WriteScope của P1 **không** chứa `lib/features/zodiac_shell/`
  hay pack JSON của ask. Nếu §6 đòi P1 làm suite đó xanh thì kế hoạch đã yêu cầu
  một việc mà chính nó cấm về mặt cấu trúc — phase bất khả thi theo thiết kế.
- Theo cách đọc B, P1 đạt: mọi suite xanh ở BaseHead đều còn xanh, số test đỏ
  không đổi (đúng một, đỏ byte-identical ở cả hai đầu).

Tôi **không** tự chuyển sang cách đọc B, dù thấy lập luận cấu trúc của nó mạnh,
vì repo có luật minh thị "một test đỏ không bao giờ được miễn" và luật đó tồn tại
đúng để người hiện thực đang bị gate ép không tự lý giải thành "phần của tôi ổn".
Khi hai cách đọc đều bào chữa được, tiebreaker của repo là đẩy phán quyết lên
Scrum Master. Nếu bạn chọn cách đọc B, việc cần làm là đổi `## 7. Status` và hàng
P1 sang `DONE`, giữ bug cho xung đột chữ REQ-016, và release run slot.
