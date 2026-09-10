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

## Phase P4 — Kho payload SB-125

Ngày chạy: 2026-09-10. BaseHead: `00c0bb1`.

### File đã thêm/sửa

Trong Write Scope của P4:

- `mobile/lib/features/invite_composer/domain/invite_payload.dart` (mới) —
  `InvitePayload`, `renderStored`, `madLibsValuesFrom`/`filledValuesFrom`,
  codec `encodeFilledValues`/`decodeFilledValues`.
- `mobile/lib/features/invite_composer/domain/invite_payload_repository.dart`
  (mới) — `abstract interface class InvitePayloadRepository`, đúng 3 thành viên.
- `mobile/lib/features/invite_composer/data/invite_payload_repository_impl.dart`
  (mới) — bản Drift, tiêm `newId`/`now`.
- `mobile/lib/core/database/daos/invite_message_dao.dart` (mới) +
  `invite_message_dao.g.dart` (sinh).
- `mobile/test/features/invite_composer/invite_payload_repository_test.dart`
  (mới) — 23 test.

### Lệch write scope

- `mobile/lib/core/database/cupid_database.dart` (+8/-1) và
  `cupid_database.g.dart` (sinh lại). Lý do: Drift bắt buộc mọi DAO phải nằm
  trong `daos:` của một `@DriftDatabase` duy nhất (ADR-010, có test
  `activity_card_dao_test.dart` khẳng định "exactly one @DriftDatabase").
  Không có cách nào tạo `InviteMessageDao` trong Write Scope P4 mà không chạm
  file này. Thay đổi thuần cộng thêm: một import và một phần tử trong `daos:`;
  `schemaVersion`, `migration`, và danh sách `tables:` không đổi.

### Quyết định thiết kế cần review

1. **`renderStored` nằm ở `invite_payload.dart`, không phải trên repository.**
   Repository chỉ đọc/ghi hàng; render cần gói nội dung, mà kéo
   `PresetCatalogue` vào tầng data sẽ buộc mọi test kho phải nạp asset. Chữ ký:
   `String renderStored(InvitePayload, ContentPackage<InvitePreset>)`.
2. **Nhánh `userEditedText` được kiểm tra trước khi tra preset.** Nhờ vậy
   payload đã sửa tay dựng lại được kể cả khi preset bị đổi lời, đổi thứ tự,
   hay bị gỡ khỏi gói. Test truyền gói **rỗng** để pin điều đó.
3. **`filledValues` giữ ở mức wire (`Map<String, String>`), không phải
   `Map<MadLibsVariable, String>`.** Hàng do build tương lai ghi vẫn đi qua
   build cũ mà không mất khoá nó không gọi tên được; khoá lạ bị *bỏ* lúc render
   nên rơi vào đúng nhánh drop-clause AC-6 thay vì làm hỏng cả câu.
4. **Preset không tìm thấy thì `throw StateError` có nêu tên id**, không render
   câu sai. Đây là trường hợp gói ship gỡ mất một preset — ngoài phạm vi AC,
   nhưng im lặng ở đây sẽ thành câu cụt gửi cho người thật.
5. **`createdAt` bị cắt về mili-giây ngay lúc tạo payload**, vì cột là
   INTEGER epoch-ms; không cắt thì payload trả về từ `savePayload` khác payload
   đọc lại từ đĩa.
6. **`latestForCard` phá hoà bằng `id` giảm dần.** Hai lần bấm chia sẻ trong
   cùng một mili-giây vẫn cho một hàng xác định.

### Lệnh và kết quả

```
$ dart run build_runner build --delete-conflicting-outputs
Built with build_runner/aot in 8s; wrote 628 outputs.
BUILD_RUNNER_EXIT=0
```

```
$ flutter test test/features/invite_composer/invite_payload_repository_test.dart --reporter expanded
00:00 +23: All tests passed!
MINE_EXIT=0
```

```
$ flutter test test/features/invite_composer/ test/core/database/ test/features/activity_cards/
00:10 +353 ~2: All tests passed!
TEST_FINAL_EXIT=0
```

```
$ flutter analyze lib/features/invite_composer lib/core/database test/features/invite_composer test/core/database
   info • prefer_initializing_formals • invite_payload_repository_impl.dart:22:9 ('this._newId')
   info • prefer_initializing_formals • invite_payload_repository_impl.dart:23:9 ('this._now')
   info • prefer_initializing_formals • preset_catalogue.dart:23:9 ('this._loader')
3 issues found.
```

0 error, 0 warning trong phạm vi P4. Cả 3 info là cùng một dương tính giả đã
được chấp nhận từ STORY-001: tham số **có tên, có giá trị mặc định** không thể
là initializing formal của một field private trong Dart. Mẫu y hệt đã tồn tại
sẵn ở `activity_card_repository_impl.dart:23` (`_newId`) và
`content_package.dart:208`.

```
$ flutter analyze --no-fatal-infos --no-fatal-warnings lib test
ANALYZE_ERRORS_ONLY_EXIT=0
```

`flutter analyze lib test` toàn repo vẫn ra 208 dòng info/warning
chat/dream_jar/design_system có sẵn — đó là `BUG-20260908-001`, không phải P4.

```
$ flutter build apk --debug
✓ Built build/app/outputs/flutter-apk/app-local-debug.apk
BUILD_EXIT=0
```

### Chuỗi trước khi lưu và sau khi mở lại database

Hai chuỗi dưới đây do test
`round trip through a reopened database > unedited payload re-renders to the
exact export-time string (AC-18)` khẳng định bằng `==`. Nhánh ghi và nhánh đọc
dùng **hai kết nối khác nhau**: `writer` bị `close()` trước khi `reader` mở file
lên, nên không có object Dart nào sống sót qua ranh giới đó.

```
filled_values lúc lưu : {"activity":"xem phim","date":"thứ Bảy 20/9","time":"tối"}
preset_id lúc lưu     : invite.rap_phim.v1
pack_version lúc lưu  : 1.0.0
user_edited_text      : NULL

trước khi lưu (renderInvite trực tiếp):
Tui đang tính đi xem phim. Chắc là thứ Bảy 20/9, tầm tối. Bận thì thôi nha, tui tự đi cũng vui.

sau khi đóng + mở lại DB (renderStored trên hàng đọc từ đĩa):
Tui đang tính đi xem phim. Chắc là thứ Bảy 20/9, tầm tối. Bận thì thôi nha, tui tự đi cũng vui.
```

Nhánh sửa tay (AC-7/AC-18):

```
user_edited_text lúc lưu:
Mai tối đi xem phim với tui nha, hong đi cũng ok.

sau khi đóng + mở lại DB:
Mai tối đi xem phim với tui nha, hong đi cũng ok.
```

Lưu ý mệnh đề `Chỗ hẹn là {place}` bị rơi ở cả hai lần vì thẻ không có
`location` — nhánh AC-6 giữ nguyên qua vòng lưu/đọc.

### Chứng minh test đỏ được (không phải test luôn xanh)

Hai khẳng định nặng nhất đã được cố tình làm hỏng rồi khôi phục.

1. Thêm tạm `Future<int> countForCard(String)` vào `invite_message_dao.dart`:

```
00:00 +2 -1: no counting surface (R-1e/AC-14) lib/core/database/daos/invite_message_dao.dart declares no aggregate, count, or ranking query [E]
  Expected: empty
    Actual: WhereIterable<String>:['  Future<int> countForCard(String cardId) async =>']
  lib/core/database/daos/invite_message_dao.dart must expose no "count" surface (R-1e/AC-14)
```

2. Sửa tạm `savePayload` để ghi `filledValues` rỗng và `userEditedText` null:

```
00:00 +0 -1: unedited payload re-renders to the exact export-time string (AC-18) [E]
  Expected: 'Tui đang tính đi xem phim. Chắc là thứ Bảy 20/9, tầm tối. Bận thì thôi nha, tui tự đi cũng vui.'
    Actual: 'Bận thì thôi nha, tui tự đi cũng vui.'
00:00 +0 -2: edited payload re-renders to the edited string (AC-7/AC-18) [E]
  Expected: 'Mai tối đi xem phim với tui nha, hong đi cũng ok.'
    Actual: <null>
00:00 +0 -3: the stored columns hold the input, never the rendered sentence [E]
  Expected: {'activity': 'xem phim', 'date': 'thứ Bảy 20/9', 'time': 'tối'}
    Actual: {}
```

Cả hai thay đổi tạm đã được gỡ; `git status` sau đó chỉ còn các file P4 thật.

### Đối chiếu AC

| AC | Chỗ được pin | Test |
|---|---|---|
| AC-6 | mệnh đề thiếu biến bị rơi, và giữ nguyên sau khi lưu/đọc | `a clause whose variable is absent stays dropped` |
| AC-7 | `userEditedText` là override, `''` cũng là override | `edited: an empty override is an override` |
| AC-13 | payload tham chiếu thẻ nguồn qua `card_id` (FK cascade P3) | seed thẻ + `latestForCard` |
| AC-14 | không API đếm/tổng hợp/xếp hạng ở cả 3 file | 3 test quét mã `declares no aggregate, count, or ranking query` |
| AC-17 | payload có cấu trúc; cột id không chứa chuỗi đã render | `the stored columns hold the input, never the rendered sentence` |
| AC-18 | render lại đúng chuỗi sau khi đóng/mở DB, cả hai nhánh | 2 test round-trip |
| AC-19 | allowlist 8 cột; không cột người nhận/hành vi người nhận | `the table carries no recipient or recipient-behaviour column` |

### Ghi chú bàn giao cho P5/P6

- P5 gọi `filledValuesFrom(MadLibsValues.fromCard(card))` để dựng `filledValues`,
  và `savePayload(...)` đúng một lần mỗi lần chạm chia sẻ. Không thêm khoá
  idempotency: hai lần chạm là hai vật phẩm và không bề mặt nào đếm chúng.
- `packVersion` truyền vào `savePayload` phải là `package.version` của gói
  **đang mở**, không phải hằng số.
- `InvitePayloadRepositoryImpl` chưa được đăng ký ở DI/`cupid_app.dart` — P5 sở
  hữu việc nối dây đó, P4 cố ý dừng ở tầng domain/data.
- Test quét mã ở nhóm `no counting surface` chỉ soi 3 file P4. Nếu P5 tạo thêm
  file kho payload, hãy thêm đường dẫn vào `payloadSources`.

## Phase P5 — sheet soạn lời mời

- Ngày: 2026-09-10
- Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-002_invite_message_composer`
- File chạm (đúng Write Scope của phase):
  - `mobile/lib/features/invite_composer/presentation/invite_composer_cubit.dart` (mới)
  - `mobile/lib/features/invite_composer/presentation/widgets/invite_composer_sheet.dart` (mới)
  - `mobile/lib/features/invite_composer/presentation/widgets/frame_chip_strip.dart` (mới)
  - `mobile/lib/core/di/service_locator.dart` (chỉ thêm, 4 import + 3 đăng ký)
  - `mobile/test/features/invite_composer/invite_composer_cubit_test.dart` (mới)
  - `mobile/test/features/invite_composer/invite_composer_sheet_test.dart` (mới)

### Lệnh và kết quả

```
$ flutter test test/features/invite_composer/invite_composer_cubit_test.dart
00:00 +22: All tests passed!

$ flutter test test/features/invite_composer/invite_composer_sheet_test.dart
00:01 +12: All tests passed!

$ flutter test test/features/invite_composer/ test/features/activity_cards/ --reporter=failures-only
+313 ~2: 2 skipped tests.
+313 ~2: All other tests passed!

$ flutter analyze lib/features/invite_composer lib/core/di test/features/invite_composer
8 issues found. (ran in 2.5s)

$ flutter build apk --debug
✓ Built build/app/outputs/flutter-apk/app-local-debug.apk
```

- 313 pass / 0 fail / 2 skipped. Hai test skip là hai test đã skip sẵn của
  `activity_cards`, không do P5.
- 8 issue của `analyze` đều là `info • prefer_initializing_formals`, 0 warning,
  0 error: 3 issue có sẵn từ P2/P4 (`preset_catalogue.dart:23`,
  `invite_payload_repository_impl.dart:22,23`) và 5 issue mới ở
  `invite_composer_cubit.dart:141-145`, cùng đúng khuôn mẫu private-field đã
  được chấp nhận ở P2/P4.
- `analyze lib test` toàn repo không dùng được ở phase này: nó ngập cảnh báo có
  sẵn của `chat`/`dream_jar` đang theo dõi ở `BUG-20260908-001`.

### Cổng visual fidelity

- `../visual-fidelity/visual-fidelity-report.md` — `VISUAL_FIDELITY: PASS`
- Ảnh: `implemented-11-xuat-loi-moi-chon-khung-ios.png`,
  `implemented-11-dien-mad-libs-xem-truoc-ios.png` (415x900), đối chiếu
  `design-reference-11-*.png`
- Chụp trong chính widget test của story qua `RepaintBoundary`: P5 cố ý không
  đăng ký route nào (SC-4) nên sheet chưa tới được từ bản build đang chạy;
  `main_preview.dart` ngoài Write Scope. Thiết bị *có* sẵn (`emulator-5554`),
  nên đây là phương án dự phòng được handoff cho phép, **không phải**
  `MOBILE_RUNTIME_UNAVAILABLE`.
- Đã nhìn bằng mắt cả hai ảnh: dấu tiếng Việt đúng hoàn toàn, không ô tofu, và
  không còn `{...}` nào trong thân lời mời.
- Báo cáo §2 nêu 4 xung đột giữa canvas thiết kế và spec/AC cần PO phán quyết;
  hai trong số đó ("Gửi qua Zalo", banner "CÒN HAI CHỖ TRỐNG") là vi phạm AC
  nằm ngay trong bản thiết kế.

### Đối chiếu AC

| AC | Chỗ được pin | Test |
|---|---|---|
| AC-4 | năm biến mad-libs đều được điền, không sót `{}` | `opens with the first frame already rendered` |
| AC-5 | chạm chip đổi khung, không có bước "Áp dụng" | `tapping a chip re-renders the preview with no apply step` |
| AC-7 | sửa ngay trong khối xem trước, không mở màn riêng | `tapping the preview edits it in place, not on a new screen` |
| AC-16 | đúng một CTA "Chia sẻ", không icon kênh riêng | `the only send affordance is the one Share Sheet CTA (AC-16)` |
| AC-17 | ghi payload trước, rồi mới đặt `invited`, rồi mới share; chỉ đặt cờ ở lần xuất đầu | `writes the payload before handing the text to the OS`, `sets invited on first export and leaves every other field alone`, `a second export in the same session does not re-flip invited` (cubit) |
| AC-19 | không nhánh nào đọc `ShareResult` | `the share call hands off and reads nothing back (R-1b/AC-19)` |
| AC-26/AC-27/R-15b | không đếm, không vị trí, không tiến độ; N=1 và N=200 hành xử như nhau | `a pack with one frame draws one chip and no placeholder`, `a 200-frame pack behaves exactly like a 1-frame one (R-15b)`, `no frame count, position, or progress is shown` |
| SC-4 | phase không thêm route/tab/menu nào | `this phase adds no route, tab, or menu entry — that is P6` |

### Ghi chú kỹ thuật cho P6

- `_TestBundle` phải tự override `loadString`. Bản kế thừa của `AssetBundle`
  đẩy payload lớn hơn ~50 KB sang isolate `compute`, và future đó không bao giờ
  hoàn tất dưới đồng hồ giả của widget test — gói 200 khung vì thế trông như
  "không tải được" vì một lý do không tồn tại trên thiết bị. Đây là hiện tượng
  của khung test, không phải lỗi sản phẩm.
- Ảnh chụp bằng `RenderRepaintBoundary.toImage()` phải nằm trong
  `tester.runAsync<ByteData?>(...)`, nếu không test treo vô hạn.
- Test cấm-đếm bỏ qua đúng chuỗi thân lời mời khi quét regex `n/m`: ngày dạng
  `d/M` ("15/8") trông y hệt một chỉ số vị trí. Lệnh cấm áp cho phần khung giao
  diện, không áp cho nội dung gói.
- `showInviteComposerSheet(context, card, categoryId)` là điểm vào duy nhất P6
  (và STORY-007/008) cần gọi; nó trả `true` khi người dùng đã xuất lời mời.

## Phase P6 — Lối vào "Chuẩn bị" và ô địa điểm

- Ngày: 2026-09-10
- Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-002_invite_message_composer`
- File chạm (đúng Write Scope của phase, 4 file):
  - `mobile/lib/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart` (mới)
  - `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart` (sửa)
  - `mobile/test/features/invite_composer/prepare_actions_sheet_test.dart` (mới)
  - `mobile/test/features/activity_cards/activity_card_detail_screen_test.dart` (sửa)

### Lệnh và kết quả

```
$ flutter test test/features/invite_composer/prepare_actions_sheet_test.dart
00:00 +8: All tests passed!

$ flutter test test/features/activity_cards/activity_card_detail_screen_test.dart --reporter=failures-only
+46 ~1: 1 skipped test.
+46 ~1: All other tests passed!

$ flutter test test/features/activity_cards/ test/features/invite_composer/ --reporter=compact
00:09 +330 ~2: 2 skipped tests.
00:09 +330 ~2: All other tests passed!

$ flutter analyze lib test
209 issues found. (ran in 2.8s)

$ flutter analyze lib/features/invite_composer lib/features/activity_cards test/features/invite_composer test/features/activity_cards
15 issues found. (ran in 2.9s)

$ flutter build apk --debug
✓ Built build/app/outputs/flutter-apk/app-local-debug.apk
```

- 330 pass / 0 fail / 2 skipped. Hai test skip là hai test đã skip sẵn của
  `activity_cards` (khung ảnh STORY-001 sau `kCaptureVisuals`), không do P6.
  P6 thêm 17 test: 8 test mới trong `prepare_actions_sheet_test.dart` và 9 test
  mới trong `activity_card_detail_screen_test.dart` (38 → 47).
- `flutter analyze lib test` toàn repo: 209 issue, tất cả thuộc nền có sẵn
  `BUG-20260908-001` (`chat`/`dream_jar`/`themes`...). Con số này *giảm* so với
  lần chạy đầu của phase (215) vì 6 issue `unnecessary_underscores` do chính P6
  sinh ra đã được sửa (`__`/`___` → `_`).
- Thu hẹp về hai thư mục feature bị chạm: 15 issue, **tất cả** là
  `info • prefer_initializing_formals` trên constructor không đổi, đúng nhóm
  `BUG-20260908-001` đã ghi nhận ở P2/P3/P4/P5. 0 warning, 0 error, và 0 issue
  phát sinh từ mã P6.

### Cổng visual fidelity

- `../visual-fidelity/visual-fidelity-report.md` §3 — `VISUAL_FIDELITY: PASS`
- Ảnh (415x900): `implemented-11-chuan-bi-chon-hanh-dong-ios.png`,
  `implemented-chi-tiet-the-moi-nghi-ra-ios-cho-hen.png`,
  `implemented-chi-tiet-the-da-hen-ngay-ios-cho-hen.png`; đối chiếu
  `design-reference-chi-tiet-the-moi-nghi-ra-ios.png` (dựng mới trong phase này
  bằng `render-design-canvas.js --surface=cupid-ch-ng-1 --platform=ios`).
- Sheet "Chuẩn bị" **không có** frame thiết kế: `--list-screens` trên surface
  `cupid-ch-ng-1` trả 29 màn và không màn nào là bộ chọn này. Source Of Truth là
  `../ux/uiux-spec.md` §1/§4 đúng như phase file khai báo. Ghi ở §3.4 (e).
- `chi-tiet-the-moi-nghi-ra` không vẽ hàng địa điểm: cột `location` là quyết
  định schema v5 bổ sung của Tech Lead (R-1e) để khép AC-4, ra đời sau bản
  thiết kế. Ghi ở §3.4 (f).
- Đã nhìn bằng mắt cả ba ảnh. Lần chụp đầu của sheet **có** tofu: hai icon hàng
  rasterize thành ô vuông rỗng vì harness chỉ nạp ba font chữ. Đã thêm
  `MaterialSymbolsRounded-Variable.ttf` vào `_loadBundledFonts` và chụp lại;
  bản đang lưu sạch. Test vẫn xanh ở cả hai lần — đây đúng là loại lỗi mà chỉ
  việc mở ảnh ra xem mới bắt được.

### Đối chiếu AC

| AC | Chỗ được pin | Test |
|---|---|---|
| AC-1/AC-2 | thẻ *Đã hẹn ngày* vẫn đúng một hành động chính, đi theo nó tới được sheet soạn lời mời gắn đúng thẻ | `the one CTA leads card → Chuẩn bị → Xuất lời mời → composer` |
| AC-3 | không route mới, không mục tab bar/menu; sheet là popup route | `the whole path pushes no page route (AC-3)`, `the sheet registers no route and no menu entry (AC-3)` |
| AC-4 | nhập địa điểm trên thẻ → sheet nhận đúng giá trị vừa lưu | `a typed place is written on blur (AC-4)`, `the card handed to Chuẩn bị carries the just-typed place` |
| AC-4 (toàn-ảnh) | chuỗi rỗng quy về `null` để xoá cột, không ghi `""` | `an emptied place is written as null, not as ""`, `normalizeLocation trims, and turns blank into null` |
| AC-26/AC-27 | không mở sheet rỗng, không màn lỗi khi gói không giải ra; không đếm, không dấu "đã gửi" | `does not open at all when the pack holds no preset (AC-27)`, `does not open when the pack asset is missing (AC-27)`, `shows no export count and no "sent" marker (AC-26/AC-27)` |
| BR-3 / UX §4 | đóng sheet quay về chi tiết thẻ, không mất dữ liệu; sheet tự đóng trước khi composer mở | `closes itself before the composer opens (UX §4)`, `the one CTA leads card → ...` (khẳng định `activity_card_detail` còn nguyên) |
| Phase §4 | không còn tham chiếu tới snackbar stub | `the "chuẩn bị nằm ở bước sau" snackbar stub is gone for good` |

### Quyết định thiết kế và nợ cần biết

- **`_commitLocation` ghi thẳng qua `repository.updateCardDetails`, không qua
  cubit.** `ActivityCardDetailCubit` không có `editLocation`, và `_withEdits`
  của nó không mang `location` sang (`BUG-20260910-001`). Thêm `editLocation`
  đồng nghĩa với sửa `_withEdits` — tức là vá `BUG-20260910-001`, việc handoff
  cấm — trong một file thứ 5 ngoài Write Scope. Nên P6 dựng nguyên một
  `ActivityCardEdit` đầy đủ (`_editWithLocation`) rồi ghi.
- **Hệ quả còn treo:** vì `BUG-20260910-001` chưa vá, một lần sửa *khác* đi qua
  cubit (ví dụ `editTitle`) vẫn sẽ xoá sạch cột `location` vừa lưu. P6 không
  gây ra và không che được lỗi này. Bản vá nên thêm `location`/`clearLocation`
  vào `_withEdits` cùng một mutator `editLocation`; sau đó màn hình có thể
  chuyển sang đường cubit và bỏ `_editWithLocation`.
- **Nhánh `prepare` đọc lại thẻ bằng `repository.cardById`** trước khi mở sheet,
  vì bản sao trong cubit có thể chậm một nhịp so với ô địa điểm ghi thẳng. Đây
  là lý do `_StubRepository.cardById` trong test không còn `throw`.
- **Hàng địa điểm không có icon dẫn đầu.** Font Material Symbols Rounded đang
  đóng gói không có glyph place/pin; hàng provenance của link đã lập sẵn tiền lệ
  hàng không icon nên hàng này đi theo.
- **Khung test:** thêm một hàng vào form chi tiết có thể đẩy widget ra ngoài
  khung mặc định 800x600 và làm `tap()` của test khác trượt. Không có test nào
  vỡ lần này (`_useTallViewport` 415x1600 đã có sẵn ở các test chạm CTA), nhưng
  rủi ro vẫn là thật cho các phase sau — chỉnh kích thước khung trong test, đừng
  đổi bố cục sản phẩm.
- **`prepare_actions_sheet.dart` là bề mặt dùng chung cho STORY-006/008:** thêm
  mục bằng cách nối vào `_resolveActions`, không sửa hình dạng sheet.
  `PrepareActionsPresenter` là seam để test/preview lái màn chi tiết mà không
  cần DI của feature này.
