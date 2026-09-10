# Test Results – STORY-002 Xuất lời mời

## Phase P1 – Engine render tất định + bộ biến mad-libs

- Ngày: 2026-09-10
- Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-002_invite_message_composer`
- Lệnh chạy từ `mobile/`, prefix `PATH="$HOME/flutter/bin:$PATH"`.

### Targeted tests

`flutter test test/features/invite_composer/ --reporter expanded`

```
00:00 +26: All tests passed!
```

26/26 pass, 0 fail. Tên từng case (reporter expanded):

- `mad_libs_test.dart` (11): MadLibsVariable is a closed set of exactly five
  variables · rejects a name outside the set · MadLibsValues drops null, empty,
  and whitespace-only sources · trims a present value · exposes an unmodifiable
  map · fromCard resolves the card-backed variables · fromCard is deterministic
  for the same card · fromCard omits variables whose source field is null ·
  fromCard omits an activity whose title is blank · fromCard renders every
  time-of-day slot in lower case · domain purity no domain file reaches the
  network or a non-deterministic source
- `invite_renderer_test.dart` (15): parses the contract example shape · rejects
  targets "recipient" · rejects an unknown clause role · rejects a requires
  entry outside the closed variable set · rejects a placeholder outside the
  closed variable set · rejects a placeholder that is not gated by requires ·
  rejects a missing mandatory field instead of defaulting · ignores unknown keys
  at clause level · renderInvite is deterministic across repeated renders ·
  fills every placeholder when all five variables are present · drops the whole
  clause when place is missing · reads cleanly for every subset of the five
  variables · keeps the decline door for every subset · renders nothing but the
  decline door when every variable is absent · keeps clause order and does not
  edit case or punctuation

### Regression / contract coverage

`flutter test test/core/content/ --reporter failures-only`

```
+15: All tests passed!
```

15/15 pass, 0 fail. `core/content/` không bị sửa một dòng nào ở phase này.

### Static analysis

`flutter analyze --no-fatal-infos --no-fatal-warnings lib/features/invite_composer test/features/invite_composer`

```
Analyzing 2 items...
No issues found! (ran in 1.6s)
```

`flutter analyze lib test` → `201 issues found`, exit 1. Chạy lại cùng phạm vi
với `--no-fatal-infos --no-fatal-warnings` → **exit 0**, tức **0 error**. 201
issue còn lại là nhiễu `info`/`warning` có sẵn từ trước (unused_import,
unnecessary_import, deprecated `withOpacity`, `prefer_initializing_formals`),
không có cái nào thuộc file của phase này.

### Ma trận thiếu trường (AC-6/AC-9/AC-10)

Test `reads cleanly for every subset of the five variables` và `keeps the
decline door for every subset` duyệt **cả 32 tổ hợp** của bộ 5 biến (đủ 5,
thiếu 1, thiếu 4, thiếu tất cả nằm trong đó). Mỗi tổ hợp khẳng định chuỗi kết
quả: không chứa `{`, không chứa `}`, không có khoảng trắng đôi, không có khoảng
trắng đầu/cuối, không rỗng, và luôn còn nguyên câu cửa từ chối.

### Per-story visual fidelity

NOT_APPLICABLE — phase P1 không dựng màn UI nào.

### Ghi chú bàn giao

`MadLibsValues.fromCard` hiện giải được 4 biến: `activity` ← `title`, `date` ←
`formatLongViDate(scheduled_on)`, `time` ← từ khung giờ viết thường, `duration`
← `formatDurationMinutes(duration_minutes)`. Biến `place` chưa có trường nguồn:
`ActivityCard.location` mới ra đời ở P3. Xem mục "Lệch write scope" ở
`phase-P1-mad-libs-render-engine.md` §7.

## Phase P3 – Schema v5: cột `location` + bảng `invite_messages`

- Ngày: 2026-09-10
- Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-002_invite_message_composer`
- Lệnh chạy từ `mobile/`, prefix `PATH="$HOME/flutter/bin:$PATH"`.
- Sinh mã: `dart run build_runner build --delete-conflicting-outputs` →
  `Built with build_runner/aot in 23s; wrote 1165 outputs.` (build_runner
  2.15.1 cảnh báo `--delete-conflicting-outputs` đã bị bỏ và ignore cờ này;
  không ảnh hưởng kết quả.)

### Targeted tests

`flutter test test/core/database/migration_v5_test.dart --reporter failures-only`

```
+9: All tests passed!
```

9/9 pass, 0 fail. Ba nhóm: `v3 -> v5` (3), `v4 -> v5` (3), `v5 on a fresh
install` (1), `invite_messages cascade (BR-2)` (2).

### Bằng chứng khẳng định bắt buộc — số hàng trước/sau nâng cấp

Case `the pre-upgrade row survives intact, with location null` chạy **hai lần**,
một cho `from = 3` và một cho `from = 4`. Cả hai lần:

- trước nâng cấp: `SELECT COUNT(*) FROM activity_cards` = **1** (đọc ở kết nối
  riêng, đóng lại trước khi mở kết nối nâng cấp)
- sau nâng cấp: `activityCards` trả về **1** hàng, `title = 'Đi ăn lẩu'`,
  `note = 'thẻ viết từ hồi v3'` / `'thẻ viết từ hồi v4'`,
  `scheduled_on = '2026-09-20'`, `price_vnd = 250000`, `location = NULL`

Không hàng nào mất, không hàng nào bị viết lại. Fixture dựng bằng cách mở schema
hiện tại rồi gỡ đúng phần thêm của v5 (`DROP TABLE invite_messages`,
`ALTER TABLE activity_cards DROP COLUMN location`, và với v3 thêm 5 cột B-1),
nên hình dạng cũ bám theo định nghĩa bảng thật thay vì DDL chép tay.

`PRAGMA user_version` = **5** sau cả hai đường; `PRAGMA table_info` chứa
`location`; `sqlite_master` chứa `invite_messages`.

Đường v4 → v5 là đường mà bẫy thứ tự migration nhắm tới: máy ở v4 không vào
nhánh `from < 3` lẫn nhánh `from < 4`, nên nếu `addColumn(location)` bị nối vào
`else if (from < 4)` thì nhóm này mất cột. Test `v4 -> v5` khẳng định trực tiếp
điều đó.

### Cascade (AC — xoá thẻ xoá lời mời)

- `deleting a card deletes only its own invites`: 2 thẻ, mỗi thẻ 1 hàng
  `invite_messages`; xoá `card-a` → còn đúng `['invite-card-b']`.
- `an invite cannot reference a card that does not exist`: insert với
  `card_id = 'card-missing'` ném lỗi. Cả hai dựa vào
  `PRAGMA foreign_keys = ON` mà `beforeOpen` bật sẵn.

### Regression / contract coverage

`flutter test test/core/database/ test/features/activity_cards/ --reporter failures-only`

```
+273 ~2: 2 skipped tests.
+273 ~2: All other tests passed!
```

273 pass, 0 fail, 2 skip (skip có sẵn từ trước).

`flutter test test/features/invite_composer/ --reporter failures-only`

```
+29: All tests passed!
```

29/29 pass (26 của P1 + 3 case `place` mới). Gộp cả ba thư mục:
`flutter test test/core/database test/features/activity_cards test/features/invite_composer`
→ `+302 ~2: All other tests passed!`

### Test sẵn có phải sửa vì bump schema (không phải test mới)

Sáu khẳng định ghim cứng `4` hoặc bộ cột v4 vỡ ngay khi `schemaVersion` lên 5.
Đây là hệ quả tất yếu của phase, đã sửa tại chỗ và ghi rõ để reviewer không phải
đoán:

- `test/core/database/timeline_dao_test.dart:37` — `schemaVersion` 4 → 5
- `test/core/database/journal_dao_test.dart:58` — `schemaVersion` 4 → 5
- `test/core/database/expense_dao_test.dart:38` — `schemaVersion` 4 → 5
- `test/core/database/activity_card_dao_test.dart:61-62` — `schemaVersion` 4 → 5
- `test/core/database/activity_card_dao_test.dart:69-99` — allowlist cột §3 thêm
  `location`, `hasLength(22)` → `hasLength(23)`
- `test/features/activity_cards/activity_type_test.dart:176` — `schemaVersion`
  4 → 5

Ngoài ra hai fixture migration cũ phải gỡ thêm phần v5 để mô phỏng đúng máy cũ:
`activity_card_migration_test.dart` (drop `invite_messages`, drop cột
`location`, `user_version` 4 → 5, `hasLength(22)` → `23`) và
`cupid_database_migration_v3_test.dart` (drop `invite_messages` trước
`activity_cards`, vì nó giữ FK cascade trỏ vào đó).

Đã quét toàn repo: `grep -rln "schemaVersion\|user_version" test lib` chỉ trả về
các file nằm trong phạm vi test đã chạy xanh ở trên, không còn chỗ ghim nào sót.

### Static analysis

`flutter analyze --no-fatal-infos --no-fatal-warnings lib/core/database lib/features/activity_cards lib/features/invite_composer test/core/database test/features/invite_composer test/features/activity_cards`

```
Analyzing 6 items...
7 issues found. (ran in 2.2s)
```

Exit 0 → **0 error**. Cả 7 issue là `info • prefer_initializing_formals` có sẵn
từ trước trên constructor không đổi (`activity_card_repository_impl.dart:21-23`,
`occasion_suggestion_service.dart:110`, `activity_card_detail_cubit.dart:76`,
`activity_card_list_cubit.dart:102-103`). Không issue nào nằm trong file P3 thêm
mới hoặc dòng P3 sửa.

`flutter analyze lib test` → `201 issues found`, exit 1; chạy lại cùng phạm vi
với `--no-fatal-infos --no-fatal-warnings` → **exit 0**, tức 0 error toàn
`lib` + `test`. Con số 201 giữ nguyên so với P1, tức phase này không thêm
info/warning nào.

### Build / type-check

`flutter build apk --debug` (đúng `buildCommand` của runtime id `mobile-app`
trong `data/devops/system/runtime-command-registry.json`)

```
Running Gradle task 'assembleLocalDebug'...                        62.3s
✓ Built build/app/outputs/flutter-apk/app-local-debug.apk
```

Cảnh báo KGP (`mobile_scanner`, `sign_in_with_apple`) và
`--enable-native-access` là nhiễu môi trường có sẵn, không liên quan P3.

### Per-story visual fidelity

NOT_APPLICABLE — phase P3 không dựng màn UI nào.

### Ghi chú bàn giao

- `MadLibsValues.fromCard` nay giải đủ **5/5** biến: `place` ←
  `card.location ?? ''`, đi qua đúng bộ lọc rỗng của constructor nên
  `location = null` và `location = '   '` đều rơi vào nhánh AC-6 y hệt bốn biến
  kia. Bốn biến còn lại không đổi một dòng. Khoảng trống bàn giao của P1 đã
  đóng; AC-4 chỉ còn chờ ô nhập địa điểm ở P6.
- `ActivityCardEdit` lên 17 trường. Ngữ nghĩa toàn-ảnh giữ nguyên: `location:
  null` là **xoá** cột, không phải "giữ nguyên" — có test khẳng định cả hai
  chiều (`location round-trips through ActivityCardEdit after the upgrade`).
- `NewActivityCard` **không** nhận `location`. `createCard` chưa ghi cột này;
  đường ghi duy nhất hôm nay là `updateCardDetails`. P6 quyết định có mở cửa
  tạo-mới hay không.
- Chưa có DAO/repository cho `invite_messages` — P4 sở hữu phần đó. P3 chỉ dựng
  lược đồ.
