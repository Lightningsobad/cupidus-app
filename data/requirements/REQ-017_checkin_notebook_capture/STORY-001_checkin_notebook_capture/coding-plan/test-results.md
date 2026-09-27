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

## P2 — Check-in capture content pack

BaseHead: `72e551f19339286336053ab40e40a4ce4c085468` (P1 đã seal).

### Kết luận

`Phase: P2`
`Result: PASS`
`Blocker: NONE`

### Gate 1 — parser + resolution của gói (AC-14, R-15a)

```
PATH="$HOME/flutter/bin:$PATH" flutter test test/features/context_notebook/checkin_capture_content_test.dart --no-pub --reporter failures-only
```

`Result: PASS` — `+16: All tests passed!`, exit 0.

File mới `test/features/context_notebook/checkin_capture_content_test.dart` phủ:

- Gói trên đĩa parse được và mang đủ chín id UX Part D đặt tên
  (`requiredCheckinCaptureCopyIds`).
- Chỉ đúng `notebook.origin.with_card.v1` khai báo tham số; tám item còn lại
  `params` rỗng — một CMS không thể biến nhãn cố định thành template.
- `{card}` được thay bởi `CheckinCaptureCopySet.originLabel`, không bởi UI; nhãn
  trả về không còn dấu `{` nào.
- Tên thẻ `null` và tên thẻ chỉ gồm khoảng trắng đều degrade về
  `notebook.origin.fallback.v1` (AC-9/BR-6), và dòng degrade không chứa
  placeholder.
- Id copy lạ ném `ContentPackageFormatException`, không trả chuỗi rỗng.
- Bảy dạng gói sai đều bị từ chối chứ không bị bỏ qua: id trùng, thiếu `id`,
  thiếu `text`, tham số item không hỗ trợ, tên tham số không ai hỗ trợ,
  placeholder dùng mà không khai báo, tham số khai báo mà text không dùng, và
  gói mang schema id khác.

### Gate 2 — repository nạp thuần asset (R-7/BR-8)

```
PATH="$HOME/flutter/bin:$PATH" flutter test test/features/context_notebook/checkin_capture_content_repository_test.dart --no-pub --reporter failures-only
```

`Result: PASS` — `+5: All tests passed!`, exit 0.

`CheckinCaptureContentRepository` nhận `ContentPackageLoader` có `AssetBundle`
tiêm được, nên test nạp gói thật qua một bundle giả: không HTTP, không model
call trên đường này. Lần `load()` thứ hai trả về đúng cùng một instance
(`same()`), asset hỏng ném `ContentPackageFormatException`, asset thiếu ném lỗi
chứ không degrade thành gói rỗng (R-15a).

### Gate 3 — content gate nhận gói REQ-017 làm tham số thứ ba

```
PATH="$HOME/flutter/bin:$PATH" flutter test test/features/context_notebook/context_content_gate_test.dart --no-pub --reporter failures-only
```

`Result: PASS` — `+31: All tests passed!`, exit 0.

`validateContextPacks` giờ bắt buộc `checkinCapture:` và chạy `invariantHitsIn`
+ `notebookBoundaryHitsIn` trên `text` của từng item. Năm call site cũ trong
test đã cập nhật; không có call site nào trong `lib/` (gate chỉ được gọi từ
test, đúng như thiết kế REQ-016).

Bằng chứng khẳng định §6 yêu cầu — một gói cố tình vi phạm sinh ra
`ContextViolation` mang `packageId` của gói REQ-017:

- `'Điểm số hôm nay của người ấy?'` → có violation với
  `packageId == 'req017.capture.fixture'`, rule `scoreOrRatio`, và `itemId` là
  `checkin.capture.question.v1`.
- `'Người ấy nhắn bao lâu một lần?'` → rule `frequencyProbe` (ranh giới sổ tay
  được canh cả trên copy capture, không chỉ trên câu hỏi ask).
- Copy capture sạch thì hai gói kia vẫn sạch — gate không rò violation chéo.

Test đĩa mở rộng: `assets/data/req017/checkin_capture.v1.json` được đọc từ đĩa
cùng hai pack REQ-016, cả ba phải không-rỗng và tổng violation phải rỗng.

### Gate 4 — AC-14 "không có chữ của story trong Dart/ARB"

Quét `lib/**` (`.dart` + `.arb`) tìm wording của gói. Khoanh vùng theo id, có lý
do đo được chứ không suy đoán: một lần chạy chẩn đoán trên toàn bộ chín item
báo 21 collision, và tất cả đều rơi vào bốn item từ vựng UI chung —
`optional_label`, `kind.interest`, `kind.event`, `retry` — đã tồn tại sẵn trong
`lib/l10n/arb/app_vi.arb`, `lib/l10n/generated/`, và mười file screen không liên
quan (`pet_screen.dart`, `invite_screen.dart`, `expense_strings.dart`, ...).

Khẳng định vì thế phủ đúng wording story này thật sự tạo ra: câu hỏi capture,
hint bắt buộc chọn loại, lỗi lưu, và cả hai nhãn origin. Bốn id kia liệt kê
tường minh trong `_genericAppVocabularyIds` kèm lý do. Quét kiểu gộp cả chín id
sẽ báo collision mà REQ-017 không gây ra — một khẳng định sai, không phải một
gate chặt hơn.

### Gate 5 — hồi quy toàn suite `context_notebook` (§6 targeted)

```
PATH="$HOME/flutter/bin:$PATH" flutter test test/features/context_notebook --no-pub --reporter failures-only
```

`Result: PASS` — `+130 ~4: All other tests passed!` (4 skipped có sẵn), exit 0.

`git status --porcelain` trước và sau lần chạy giống nhau byte-for-byte: suite
này chứa `visual_capture_test.dart`, nên đã kiểm tra rằng nó không ghi lại PNG
visual-fidelity của story nào khác.

### Gate 6 — static analysis

```
PATH="$HOME/flutter/bin:$PATH" flutter analyze --no-pub <6 file P2>
```

`Result: PASS` — `No issues found!`, exit 0, trên ba file `lib/` và ba file
`test/` của P2. Khoanh vùng theo file có chủ ý: baseline `flutter analyze lib
test` của repo này vốn non-zero (222 warning sẵn có, 0 error), nên exit code
toàn repo không dùng làm bằng chứng được. Một lint `unnecessary_import` do tôi
gây ra đã sửa rồi chạy lại.

### Visual fidelity

`NOT_APPLICABLE` theo §6 của chính phase file: P2 là gói dữ liệu, parser và
repository, không dựng hay đổi màn nào. Phán quyết của Scrum Master ở P1 cũng
xếp `design-reference-*.png` cho P3/P4.

## P3 — Khối hỏi phụ trong check-in 23h

BaseHead: `218d8bfe6c04d2f5451a15de9a504baca78e10a6`.

### Kết luận

`Phase: P3`
`Result: PASS`

Gate 1–5 và Gate 7 xanh ngay từ lượt đầu. Gate 6 từng đỏ vì một guard kiến trúc
đã ship: `phase_status` không được phép import nội bộ của `context_notebook`, mà
hợp đồng tiêu thụ của chính phase file lại yêu cầu đúng điều đó; cửa hợp lệ duy
nhất nằm ngoài Write Scope ban đầu của P3. Scrum Master đã tự kiểm chứng lại rồi
mở Write Scope cho `context_notebook_entry_point.dart`; ba bước sửa và kết quả
chạy lại nằm ở Gate 8. Sau khi sửa, Gate 6 xanh và Gate 1–2 giữ nguyên số liệu.

### Gate 1 — suite mới cho khối phụ (AC-1/2/3/7/8/9/12/16/17, BR-4, BR-10)

```
PATH="$HOME/flutter/bin:$PATH" flutter test test/features/phase_status/checkin_capture_block_test.dart --no-pub --reporter compact
```

`Result: PASS` — `+19 ~1: All other tests passed!`, exit 0 (1 skipped là test
chụp ảnh, chỉ chạy khi có `--dart-define=CAPTURE_VISUALS=true`, xem Gate 5).

File mới `test/features/phase_status/checkin_capture_block_test.dart` phủ:

- Vị trí (AC-1/AC-7): khối nằm sau trường câu nhật ký và trước CTA, ngăn bằng
  `Divider` chứ không phải thẻ nền riêng; hai chip STORY-012 giữ nguyên chữ và
  vẫn nằm trên khối mới.
- Nội dung là dữ liệu (AC-14): câu hỏi và nhãn "Tuỳ chọn" so khớp với chuỗi đọc
  thẳng từ `assets/data/req017/checkin_capture.v1.json` trên đĩa, không phải
  chuỗi viết tay trong test.
- Build không có gói nội dung thì không có khối nào (`capture: null` → không
  `TextField` thứ hai). Điều kiện hiển thị là nội dung, không phải seam ghi.
- AC-3/BR-4: mở màn không ô nào được tô sẵn; gõ chữ cũng không tự chọn giúp.
- AC-17: đúng hai `TextField` trên màn, trường mới `maxLines: 1`, đúng hai lựa
  chọn, không trường ngày và không trường chi tiết.
- AC-6/BR-3: gõ vào trường câu nhật ký không tràn sang trường mới.
- AC-2: để nguyên khối (hoặc gõ toàn khoảng trắng) → không ghi sổ tay, nhật ký
  vẫn chạy đúng một lần, màn đóng.
- AC-16/BR-4: có ý nhưng chưa chọn loại → không ghi, nhật ký vẫn chạy một lần,
  màn ở lại, hiện dòng nhắc; dòng nhắc chỉ xuất hiện sau khi chạm CTA, và biến
  mất khi xoá ý. Chọn loại ngay sau đó thì ghi luôn, không cần chạm CTA lần hai.
- AC-12/BR-10: repository ném lỗi → hiện lỗi + "Thử lại" ngay trong khối, giữ
  nguyên chữ đã gõ và loại đã chọn, nhật ký vẫn đúng một lần, màn ở lại. Bấm
  "Thử lại" ghi đúng một hàng và không gọi nhật ký thêm lần nào.
- AC-8/BR-12: chạm CTA hai lần liên tiếp → đúng một lần ghi, một lần nhật ký.
- AC-9/BR-6: thẻ không đọc được tên (`cardTitle: null`) vẫn ghi được ý, vẫn kèm
  `cardId` và `originCheckInRef`.

`Nhật ký chạy đúng một lần` được khẳng định ở cả bốn nhánh (không hỏi / đã ghi /
thiếu loại / ghi lỗi) nhờ cờ `_journalHandedOff` trong `_save()`: vì KD-1 cho
phép màn ở lại sau khi lưu, nếu không có cờ này thì cú chạm CTA thứ hai sẽ soạn
một mục nhật ký thứ hai.

### Gate 2 — hồi quy suite check-in STORY-012 (không hạ assertion nào)

```
PATH="$HOME/flutter/bin:$PATH" flutter test test/features/phase_status --no-pub --reporter compact
```

`Result: PASS` — `+282 ~7`, exit 0.

`evening_check_in_sheet_test.dart` không sửa một dòng nào. Rủi ro "khối mới đẩy
CTA ra ngoài khung 800x600" mà handoff cảnh báo không xảy ra: khối chỉ dựng khi
`capture != null`, mà suite STORY-012 không truyền gói nội dung nên bố cục của
nó không đổi.

### Gate 3 — bề mặt test riêng của suite mới (ghi lại để người sau khỏi vấp)

Suite mới chạy ở `Size(800, 1600)`, không phải khung tham chiếu 412x915. Lý do:
font mặc định của `flutter_test` rộng hơn font thật, nên ở bề rộng 412 hàng hai
chip STORY-012 (`evening_check_in_sheet.dart:362`) tràn 63px và làm mọi test đỏ
vì lỗi layout — một hiện vật của font test, không phải lỗi sản phẩm. Ảnh chụp ở
Gate 5 vẫn dùng 412x915 vì ở đó font thật đã được nạp. Giữ bề rộng 800 như suite
STORY-012, chỉ nâng chiều cao để khối mới không nằm ngoài tầm chạm.

### Gate 4 — static analysis

```
PATH="$HOME/flutter/bin:$PATH" flutter analyze --no-pub lib/features/phase_status/presentation/evening_check_in_sheet.dart lib/features/phase_status/presentation/widgets/checkin_capture_block.dart lib/features/context_notebook/presentation/widgets/context_inline_add_row.dart test/features/phase_status/checkin_capture_block_test.dart
```

`Result: PASS` — `No issues found!`, exit 0, trên đủ bốn file P3 chạm tới. Vẫn
khoanh vùng theo file vì lý do đã ghi ở Gate 6 của P2 (baseline toàn repo
non-zero).

### Gate 5 — visual fidelity (`23h-vua-ve-j8`)

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js --location=cupid-app-design-system --surface=cupid-ch-ng-1 --screen=23h-vua-ve-j8 --out=<visual-fidelity>
PATH="$HOME/flutter/bin:$PATH" FLUTTER_ROOT="$HOME/flutter" flutter test test/features/phase_status/checkin_capture_block_test.dart --no-pub --dart-define=CAPTURE_VISUALS=true --plain-name "capture:"
python3 .claude/hooks/lib/visual_fidelity.py --dir <STORY dir> --stage review --stack mobile
```

`Result: PASS` — cổng exit 0, không in gì.

- `design-reference-23h-vua-ve-j8-ios.png` 415x900, `DESIGN_CANVAS: OK`.
- `implemented-23h-vua-ve-j8-capture-block.png` 412x915, dựng bằng
  `RepaintBoundary` trong chính widget test của phase (màn 23h chỉ tới được từ
  thông báo, không có route nào trong app dẫn tới).
- Đã soi bằng mắt: không tofu, nền đục, dấu tiếng Việt đủ, icon ô ảnh đúng hình,
  nhóm hai lựa chọn đang ở trạng thái chưa chọn gì.
- Đối chứng chống "xanh giả": copy thư mục sang `/tmp/vf-control/`, đổi tên ảnh
  implemented thành `implemented-check-in-sheet-capture.png` (không mở đầu bằng
  id canvas) → cổng exit 1 với "no screen has BOTH renders". Cổng có thật.
- `--dir` phải là thư mục **story**, không phải thư mục `visual-fidelity/`: công
  cụ tự nối thêm `visual-fidelity/`. Truyền nhầm thì thông báo lỗi trông y như
  thiếu báo cáo.
- `visual-fidelity/visual-fidelity-report.md` ghi `VISUAL_FIDELITY: PASS` và
  ghi rõ `DESIGN_SPEC_CONFLICT`: canvas `23h-vua-ve-j8` vẽ trạng thái cuối của
  REQ-016 nên không có khối hỏi phụ. Phần đã có trên canvas chấm theo canvas,
  phần thêm mới chấm theo UX Phần A.2.

### Gate 6 — hồi quy `context_notebook` (ĐỎ lượt đầu → đã giải quyết ở Gate 8)

```
PATH="$HOME/flutter/bin:$PATH" flutter test test/features/context_notebook --no-pub --reporter compact
```

`Result: FAIL` — `+129 ~4 -1: Some tests failed.`, exit 1.

Đúng một test đỏ:
`test/features/context_notebook/ask_on_the_spot_slot_test.dart:446` —
`biên giới import của feature > no file outside features/context_notebook imports an internal`.

Bảy vi phạm, tất cả do P3 tạo ra:

```
lib/features/phase_status/presentation/evening_check_in_sheet.dart -> ../../context_notebook/data/checkin_capture_content_repository.dart
lib/features/phase_status/presentation/evening_check_in_sheet.dart -> ../../context_notebook/data/context_notebook_repository.dart
lib/features/phase_status/presentation/evening_check_in_sheet.dart -> ../../context_notebook/domain/checkin_capture_content.dart
lib/features/phase_status/presentation/evening_check_in_sheet.dart -> ../../context_notebook/domain/context_notebook_models.dart
lib/features/phase_status/presentation/widgets/checkin_capture_block.dart -> ../../../context_notebook/domain/checkin_capture_content.dart
lib/features/phase_status/presentation/widgets/checkin_capture_block.dart -> ../../../context_notebook/domain/context_notebook_models.dart
lib/features/phase_status/presentation/widgets/checkin_capture_block.dart -> ../../../context_notebook/presentation/widgets/context_inline_add_row.dart
```

Guard cấm mọi file ngoài `lib/features/context_notebook/` import
`data/`, `domain/`, `presentation/` của feature đó; ngoại lệ duy nhất là
composition root `lib/core/di/service_locator.dart`. Cửa hợp lệ là
`lib/features/context_notebook/context_notebook_entry_point.dart` — nó đã từng
được mở rộng đúng kiểu này một lần (STORY-009 thêm cửa ghi thứ hai
`recordAnsweredQuestion`, có ghi chú sửa đổi §6 ngay trong doc comment).

Vì sao P3 không tự sửa được:

- Write Scope của P3 (§1B) chỉ có ba file `lib/` và `mobile/test/features/phase_status/**`.
  `context_notebook_entry_point.dart` không nằm trong đó.
- Hợp đồng tiêu thụ trong chính §1B ("khối phụ chỉ ghi qua
  `ContextNotebookRepository`") và `architecture/solution.md` §"New or changed
  boundaries" đều mô tả `phase_status` gọi thẳng xuống `context_notebook`, và
  không chỗ nào nhắc tới `context_notebook_entry_point.dart`. Đây là lỗ hổng của
  bản thiết kế, không phải lựa chọn của lượt code này.
- Sửa bài test guard để cho qua là hướng sai: nó là bằng chứng kiến trúc đang
  hoạt động đúng như thiết kế.

Việc cần mở scope (nhỏ và đúng tinh thần hợp đồng "một cửa ghi duy nhất"):

1. Thêm vào `context_notebook_entry_point.dart`:
   - `export 'domain/checkin_capture_content.dart' show CheckinCaptureCopy, CheckinCaptureCopySet;`
   - một hàm nạp gói nội dung (bọc `CheckinCaptureContentRepository`)
   - `Future<void> recordCheckInCapture({required NotebookKind kind, required String value, required String originCheckInRef, String? cardId, String? cardTitle})`
     uỷ quyền xuống `ContextNotebookRepository.recordFromCheckIn`
   - `export 'presentation/widgets/context_inline_add_row.dart' show ContextInlineAddOption, ContextInlineSegmented;`
2. Đổi ba import trong `evening_check_in_sheet.dart` và ba import trong
   `checkin_capture_block.dart` sang cửa đó.
3. Cập nhật ghi chú hợp đồng cho cửa ghi thứ ba, giống cách STORY-009 đã làm.

Không có bước nào trong ba bước trên đổi hành vi, nên Gate 1–5 sẽ giữ nguyên
kết quả; chỉ cần chạy lại Gate 1, 2 và 6.

### Sai lệch có chủ ý so với phase file

1. **Không thêm cờ `allowNoSelection` vào `ContextInlineAddRow`.** §3 task 2 đề
   nghị nới chỗ khởi tạo `_optionId` (`context_inline_add_row.dart:86-88`) bằng
   một cờ do host truyền. Không host nào cần cờ đó: màn check-in **không** dùng
   `ContextInlineAddRow` (UX A.2 đặt nhóm lựa chọn **dưới** trường, còn hàng
   inline đặt nó **bên phải** và tự mang nút Lưu/Huỷ của riêng nó). Thay vào đó
   `_InlineSegmented` được nâng thành `ContextInlineSegmented` công khai — nó vốn
   đã vẽ `selectedId == null` thành "chưa chọn gì", đúng trạng thái AC-3 cần.
   Hành vi mặc định của `ContextInlineAddRow` không đổi một byte, và khoá
   `context-inline-add-segmented` / `context-inline-add-option-<id>` giữ nguyên
   nên test của màn Sổ tay và màn kỹ năng không phải sửa.
2. **`capture == null` là điều kiện ẩn khối, không phải `recordCapture == null`.**
   Seam ghi là của test; nếu gắn điều kiện hiển thị vào seam thì một build thật
   thiếu đăng ký DI sẽ âm thầm mất khối thay vì lỗi to. Đây cũng là bài học §7
   của STORY-012.

### Gate 7 — xác nhận lại suite database (do build-evidence gate viện dẫn)

Build-evidence gate chặn stop với `BUILD_FAILED_BUT_COMPLETE` và trích dẫn một
lần chạy **thất bại trong quá khứ** của lệnh dưới đây. Lệnh đó thuộc P1 (đợt
nâng `schemaVersion`) và đã được xử lý trong chính phase đó — xem "Gate đỏ
(LỊCH SỬ — đã giải quyết)" ở mục P1. Chạy lại nguyên văn tại HEAD hiện tại:

```
cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter test test/core/database --reporter failures-only
```

Kết quả: `+106: All tests passed!`, exit 0.

Kết luận: không còn thất bại nào ở suite database tại HEAD của P3.

### Gate 8 — sửa ranh giới kiến trúc sau khi Write Scope được mở

Scrum Master kiểm chứng độc lập (đọc lại guard, tự chạy lại suite và tái hiện
đúng 7 vi phạm, đọc `context_notebook_entry_point.dart` và tiền lệ STORY-009) rồi
mở Write Scope cho `mobile/lib/features/context_notebook/context_notebook_entry_point.dart`.
Ba bước sửa, không đổi hành vi:

1. `context_notebook_entry_point.dart` mở cửa ghi thứ ba:
   - `loadCheckInCaptureCopy()` bọc `CheckinCaptureContentRepository` (giữ nguyên
     cache theo tiến trình, chuyển từ biến private của `evening_check_in_sheet.dart`
     vào cửa vào).
   - `recordCheckInCapture({kind, value, originCheckInRef, cardId, cardTitle})`
     uỷ quyền xuống `ContextNotebookRepository.recordFromCheckIn`.
   - `export 'domain/checkin_capture_content.dart' show CheckinCaptureCopy,
     CheckinCaptureCopySet` + bảy hằng id của các dòng chữ trong gói. **Không**
     xuất `checkinCaptureAssetKey`, `checkinCaptureSchemaId` hay hàm parser: host
     không được ghim phiên bản gói khác hay tự dựng copy set từ chuỗi (AC-14).
   - `export 'presentation/widgets/context_inline_add_row.dart' show
     ContextInlineAddOption, ContextInlineSegmented`.
   - Ghi chú hợp đồng cửa thứ ba, theo đúng khuôn ghi chú `recordAnsweredQuestion`
     của STORY-009: nêu rõ vẫn không có bulk/import/pre-fill/update/delete/read-all,
     và `originCheckInRef` là thứ giữ tính idempotent theo từng check-in.
   - Dòng doc của `library` nay nêu thêm REQ-017 STORY-001 cùng hai hàm mới.
2. Bảy import vi phạm biến thành **một** import cửa vào mỗi tệp:
   - `evening_check_in_sheet.dart`: bốn import `context_notebook/data|domain/...`
     → `import '../../context_notebook/context_notebook_entry_point.dart';`
   - `checkin_capture_block.dart`: ba import `context_notebook/domain|presentation/...`
     → `import '../../../context_notebook/context_notebook_entry_point.dart';`
   - `_captureContent.load()` → `loadCheckInCaptureCopy()`; `_recordCapture` giờ
     `return recordCheckInCapture(...)` thay vì gọi trực tiếp `getIt<...>()`.
3. Không sửa một dòng nào của bài test guard.

Chạy lại:

```
cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter analyze --no-pub <5 tệp đã sửa>
cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter test test/features/context_notebook --no-pub --reporter compact
cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter test test/features/phase_status --no-pub --reporter failures-only
```

| Gate | Trước | Sau |
|------|-------|-----|
| analyze (5 tệp, thêm `context_notebook_entry_point.dart`) | `No issues found!` | `No issues found!`, exit 0 |
| Gate 6 `test/features/context_notebook` | `+129 ~4 -1`, exit 1 | `+130 ~4: All other tests passed!`, exit 0 |
| Gate 2 `test/features/phase_status` | `+282 ~7`, exit 0 | `+282 ~7`, exit 0 — không đổi một con số |

Lượt analyze đầu sau khi chuyển import báo 7 lỗi `undefined_identifier` cho bảy
hằng id chữ mà `checkin_capture_block.dart` dùng; đó là thiếu sót của danh sách
`show`, đã bổ sung rồi analyze sạch. Không có gate nào khác phải chạy lại: khối,
suite của nó và bằng chứng hình ảnh không đổi nội dung.

`git status --porcelain` sau các lần chạy: chỉ các tệp của P3; không PNG của story
khác bị bẩn.
