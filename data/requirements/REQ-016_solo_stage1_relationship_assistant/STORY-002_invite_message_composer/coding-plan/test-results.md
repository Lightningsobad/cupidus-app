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

## Phase P2 — Kho preset theo danh mục + cổng nhập luật bất biến

Base: `f90f1e6de9df0d0634d62e6d57de7effa222992d`. Worktree:
`.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-002_invite_message_composer`.

### File đã thêm / sửa

Thêm mới (4/5 file Write Scope):

- `mobile/lib/features/invite_composer/domain/preset_catalogue.dart`
- `mobile/lib/features/invite_composer/domain/preset_content_gate.dart`
- `mobile/assets/data/req016/presets.invite.v1.json`
- `mobile/test/features/invite_composer/preset_catalogue_test.dart`
- `mobile/test/features/invite_composer/preset_content_gate_test.dart`

`mobile/lib/core/content/content_package.dart` **không** bị sửa (yêu cầu §6),
xác nhận bằng `git status --porcelain`.

### Lệch write scope

Một file ngoài Write Scope §1B:

- `mobile/lib/features/invite_composer/domain/invite_preset.dart` (+43 dòng)

Lý do: P1 giao `InvitePreset` chỉ parse `id`, `frame`, `clauses`. Nó **không**
đọc `editorial_review` (`contract-summary.md` §3 hàng 8), trong khi §3 của
phase P2 bắt cổng phải kiểm "`editorial_review` có đủ hai lớp" với chữ ký cố
định `validatePresetPack(ContentPackage<InvitePreset>)`. Không mở rộng
`InvitePreset` thì luật đó không thể tồn tại. Đây là cùng dạng khoảng trống
bàn giao P1 mà P3 đã đóng cho `place`.

Quyết định đi kèm: `editorial_review` được parse **lỏng** (nullable
`EditorialReview`), không phải khoá bắt buộc của parser. Nếu bắt buộc ở tầng
parse, gói thiếu lớp duyệt sẽ chết bằng `ContentPackageFormatException` trước
khi cổng chạy, và luật `editorial_review_incomplete` thành code chết không có
fixture nào làm đỏ được — trái với §6 "mỗi luật của cổng có ít nhất một fixture
vi phạm". Khoá lạ/khoá sai kiểu vẫn là lỗi load: `editorial_review` không phải
object → ném ngay.

### Luật `clauses[].targets` — cưỡng chế ở tầng parser, không ở gate

§3 liệt kê "mọi `targets` hợp lệ" trong nhóm luật cấu trúc. `recipient`
**không** là thành viên của enum `ClauseTarget` (P1, R-1d), nên gói khai báo nó
chết trong `invitePresetFromJson` trước khi có `ContentPackage` để đưa vào
`validatePresetPack`. Viết lại luật đó trong gate sẽ là code không bao giờ đỏ
được. Cách xử lý: ghi rõ trong dartdoc của `validatePresetPack`, và đặt fixture
vi phạm ở đúng tầng cưỡng chế nó —
`preset_content_gate_test.dart` → nhóm "rules the parser enforces before the
gate sees a package" → test `a clause aimed at the recipient never becomes a
package (R-1d)`.

### Test scope của phase

```
$ flutter test test/features/invite_composer/ test/core/content/ --reporter failures-only
+72: All tests passed!
```

### Bằng chứng cổng thật sự làm hỏng bản dựng (AC-28 / BR-16)

Fixture đơn vị chưa đủ: chúng chứng minh hàm trả về vi phạm, không chứng minh
bản dựng đỏ. Đã thả tạm một gói vi phạm thật vào thư mục asset
(`assets/data/req016/presets.violating.v1.json`: không có cửa từ chối,
`editorial_review` một lớp, "xinh", "đã xem", "90%", "tỉ lệ") rồi chạy lại
test quét đĩa:

```
$ flutter test test/features/invite_composer/preset_content_gate_test.dart --reporter failures-only
+1 -1: shipped packs pass the gate (AC-28/BR-16) every pack on disk loads and reports no violation [E]
  Expected: empty
    Actual: MappedListIterable<PresetViolation, String>:[
              'presets.violating/violating.one.v1 [decline_door_missing]: expected exactly one decline_door clause, found 0',
              'presets.violating/violating.one.v1 [editorial_review_incomplete]: editorial_review must record both layer1 and layer2',
              'presets.violating/violating.one.v1 [flattery]: text uses the denylisted term "xinh"',
              'presets.violating/violating.one.v1 [recipient_behaviour]: text uses the denylisted term "đã xem"',
              'presets.violating/violating.one.v1 [percent_display]: text shows a "%" figure',
              'presets.violating/violating.one.v1 [score_or_ratio]: text uses the denylisted term "tỉ lệ"'
            ]
  assets/data/req016/presets.violating.v1.json broke an invariant rule
+1 -2: ... every preset on disk carries exactly one decline door (AC-10/BR-5) [E]
+1 -3: ... this story ships exactly one active category (AC-22) [E]
+17 -3: Some tests failed.
EXIT=1
```

Gói vi phạm đã được xoá ngay sau đó; `find assets/data/req016 -type f` chỉ còn
`presets.invite.v1.json` và `occasions.v1.json` (của STORY-001). Điểm quan
trọng: test **không** liệt kê tay file nào — nó quét thư mục, nên gói của
STORY-007 tự động rơi vào cổng mà không cần thêm nhánh (AC-29).

### Analyze

```
$ flutter analyze lib/features/invite_composer lib/core/content test/features/invite_composer test/core/content
   info • prefer_initializing_formals • lib/core/content/content_package.dart:208:55
   info • prefer_initializing_formals • lib/features/invite_composer/domain/preset_catalogue.dart:23:9
2 issues found.
```

Không có error/warning. Hai info còn lại là dương tính giả của
`prefer_initializing_formals`: tham số là **named**, còn Dart không cho phép
initializing formal mang tên private (`this._loader`), nên gợi ý của lint
không biên dịch được. `content_package.dart:208` đã mang đúng info này từ
STORY-001 với cùng hình dạng constructor.

Quét toàn repo để chắc chắn không thêm lỗi thật:

```
$ flutter analyze --no-fatal-infos --no-fatal-warnings lib test
ERRORS_ONLY_EXIT=0
```

Nhiễu info/warning toàn repo còn lại thuộc `BUG-20260908-001` (chat/dream_jar),
không phải phase này.

### Build (runtime registry `mobile-app` → `buildCommand`)

```
$ flutter build apk --debug
Running Gradle task 'assembleLocalDebug'...                         8.3s
✓ Built build/app/outputs/flutter-apk/app-local-debug.apk
BUILD_EXIT=0
```

### Regression rộng hơn

```
$ flutter test test/features/invite_composer/ test/core/content/ test/features/activity_cards/ test/core/database/ --reporter failures-only
+345 ~2: 2 skipped tests.
+345 ~2: All other tests passed!
TEST_EXIT=0
```

345 pass (302 của P3 + 43 test mới), 2 skip có sẵn từ trước.

### Đối chiếu Acceptance Criteria của phase

| AC phase | Bằng chứng |
|---|---|
| Gói `invite` load được, gate trả về 0 vi phạm | `every pack on disk loads and reports no violation` |
| Preset vi phạm → test đỏ | khối "bằng chứng cổng làm hỏng bản dựng" ở trên + 11 fixture đơn vị |
| `schema_id` khác → từ chối lúc load | `a pack under another schema id is rejected at load (AC-29)`, và bản catalogue tương ứng |
| Khoá asset suy ra bằng quy ước | `presetAssetKey('thanks')`, `presetAssetKey('anything_at_all')` — không sửa code |
| Không câu chữ lời mời nào trong `mobile/lib/` | `no shipped invite wording is written into any Dart file (R-15a)` quét `lib/**/*.dart` với toàn bộ `frame` + `clauses[].text` của gói ship |

### Ghi chú bàn giao

- Quy ước khoá asset: `assets/data/req016/presets.<categoryId>.v1.json`.
  `schema_id` dùng chung `req016.presets.v1` cho **mọi** danh mục — STORY-007
  không được đặt id riêng (AC-29, `contract-summary.md` §2).
- Denylist nằm hoàn toàn trong `preset_content_gate.dart`, không có một token
  nào trong asset (R-15c). Khớp theo **ranh giới từ** (`\p{L}\p{N}` lookaround,
  `unicode: true`), nên `điểm số` không bắn nhầm vào `địa điểm` — có test khẳng
  định đúng cặp đó.
- `PresetCatalogue` cache `Future` theo `categoryId`, parse đúng một lần cho mỗi
  danh mục. Test dùng bundle **không** caching (`AssetBundle` trần, không phải
  `CachingAssetBundle`) để phép đo cache là của catalogue chứ không của bundle.
- Gói ship có 10 preset. Con số đó là **dữ liệu** (R-15b): không hằng số nào
  trong `lib/`, không test nào khẳng định nó. Chỗ duy nhất pin số lượng là
  danh sách **file danh mục** trong test AC-22 — đúng ngoại lệ mà BR-15 nêu
  tên, và là dòng STORY-007 sẽ sửa khi ranh giới phạm vi đổi.
- Hành vi quay vòng hết-tập (AC-26) **không** thuộc P2. Catalogue chỉ trả gói;
  P5 (sheet) sở hữu việc đổi khung và modulo.
- `EditorialReview.approvedAt` được parse và giữ nguyên nhưng gate chưa dùng.
  Nó là vết truy xuất AC-23, không phải điều kiện ship.
