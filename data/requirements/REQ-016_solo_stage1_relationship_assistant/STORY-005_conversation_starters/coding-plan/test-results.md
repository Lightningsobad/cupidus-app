# Test Results – STORY-005 Mồi chuyện

## Phase P1 — Gói nội dung mồi chuyện + cổng nhập R-15c

- Owner: Mobile Developer
- Lane: Mobile
- Date: 2026-09-11
- Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-005_conversation_starters`

### Commands run

| # | Command (cwd `mobile/`) | Result |
|---|---|---|
| 1 | `flutter gen-l10n` | OK (worktree l10n generated from `l10n.yaml`) |
| 2 | `flutter test test/features/conversation_starters/starter_content_gate_test.dart --reporter failures-only` | **+38 All tests passed!** |
| 3 | `flutter test test/features/invite_composer/preset_content_gate_test.dart test/features/gift_ideas test/features/before_you_go test/features/context_notebook --reporter failures-only` | **+297 ~7 All other tests passed!** (7 skips pre-existing) |
| 4 | `flutter analyze --no-fatal-infos --no-fatal-warnings lib/core/content/invariant_terms.dart lib/features/conversation_starters test/features/conversation_starters` | **No issues found!** — 0 error, 0 warning, 0 info on touched files |
| 5 | `flutter test .../starter_content_gate_test.dart --plain-name "R-1g" --reporter expanded` | **+7** — enumerates each R-1g case by name |

Command 4 is scoped to the files this phase touched on purpose. The repo-wide
`flutter analyze lib test` baseline is non-zero and pre-existing (see
`phase-P1-content-packs-and-gate.md` §6: exit code is not the gate), so it is
not used as this phase's evidence.

Command 3 is the §6 required regression: it proves extending
`core/content/invariant_terms.dart` with a new *separate* rule family left the
four shipped gates (`preset`, `gift`, `before_you_go`, `context`) green.

### Files delivered

| Path | Kind |
|---|---|
| `mobile/assets/data/req016/starters.v1.json` | asset — 10 seed items (6 `generic`, 4 `contextual`) |
| `mobile/assets/data/req016/calendar_events.v1.json` | asset — 8 seed events (5 `solar`, 3 `lunar`) |
| `mobile/lib/features/conversation_starters/domain/starter_content.dart` | model + parsers |
| `mobile/lib/features/conversation_starters/domain/starter_content_gate.dart` | `validateStarterPacks` |
| `mobile/lib/core/content/invariant_terms.dart` | `StarterStructureRule` + `starterStructureHitsIn()` (additive) |
| `mobile/test/features/conversation_starters/starter_content_gate_test.dart` | 38 tests |

`pubspec.yaml` was **not** touched: `assets/data/req016/` is already declared
(`mobile/pubspec.yaml:101-102`), and no lunar-calendar or HTTP dependency was
added. Two tests assert both facts.

### AC coverage

| AC / BR | What P1 delivers | Proving test |
|---|---|---|
| AC-20 (R-1g: kết bằng câu hỏi) | `StarterStructureRule.missingQuestionEnding` + `starterStructureHitsIn()`; gate maps it to `StarterGateRule.missingQuestionEnding` | group `R-1g: a starter must end by asking (AC-20/BR-8)` — 4 cases incl. trailing-whitespace smuggling |
| AC-22 (không thao túng / không hứa phản ứng) | shared denylists run over every `text` and every event `name` | `a manipulative tone (AC-22)`, `an event name is scanned too` |
| AC-26 (nội dung là dữ liệu có lược đồ, id bền) | two schema'd asset packs, per-item durable `id`, duplicate-id rejection inherited from `ContentPackage.parse` | `both packs exist on disk and are not empty`, `no starter or event wording is written into Dart or l10n (BR-15)` |
| AC-27 / AC-28 (hành vi hết-vòng với mọi N) | **enabled, not implemented here** — pack size stays a data property (`ContentPackage.length`); no count constant is introduced. Rotation itself is P3 | `both starter kinds ship, so neither branch is dead data` (no seed-count assertion anywhere in P1) |
| AC-29 (cổng nhập từ chối và làm hỏng bản dựng) | `validateStarterPacks` reads the two packs from disk in test; any violation fails the suite | `the packs on disk report no violation` + one negative case per gate rule (12 rules) |
| AC-30 (gói sự kiện cập nhật được, không sửa code) | số mục và nội dung sự kiện là dữ liệu; cổng nhập chỉ kiểm hình dạng | groups `an event must carry usable dates and a known type (AC-30)` |
| AC-15 / AC-16 (không mạng, không AI) | no HTTP import in the feature tree, no lunar dependency in `pubspec.yaml` | group `no network and no lunar-conversion dependency (AC-15/AC-16)` |
| AC-18 (ngày lịch âm tất định) | pinned civil `YYYY-MM-DD` per occurrence, `calendar` is provenance only — per `master-plan.md` §6 note A-1 | `a date that matches the shape but does not exist`, `a date in another format` |
| BR-15 (không chuỗi trong code) | scan of `lib/**` for any shipped wording | `no starter or event wording is written into Dart or l10n (BR-15)` |
| BR-16 (N là thuộc tính dữ liệu) | no seed-count literal in the feature or in the tests | the suite asserts kinds/slots by enum coverage, never by count |
| BR-17 (luật bất biến là cổng nhập) | the gate is the enforcement point, not editorial convention | command 2 above turns red on any violating pack |

### Gate rules and their negative case

Each of the 12 `StarterGateRule` values has at least one test proving it fires:

| Rule | Negative case |
|---|---|
| `flattery` | `Bạn thật tuyệt vời, hôm nay sao rồi?` |
| `percent_display` | `Hợp gu tới 80% đó, bạn thấy sao?` |
| `streak_display` | `Đã nhắn 5 ngày liên tiếp rồi, tiếp chứ?` |
| `score_or_ratio` | `Xếp hạng câu nào hợp bạn nhất nhé?` |
| `recipient_behaviour` | `Bạn đã xem tin của mình chưa vậy?` |
| `manipulative_tone` | `Thả thính câu này xem sao?` |
| `missing_question_ending` | verdict endings, generic and contextual, plus trailing whitespace |
| `context_slot_mismatch` | `contextual` without slot; `generic` carrying a slot |
| `value_token_mismatch` | token absent / twice on `contextual`; token present on `generic` |
| `empty_event_dates` | `dates: []` |
| `malformed_event_date` | `15/09/2027` and `2027-02-30` |
| `unknown_activity_type` | `news_feed` |

Parser-level rejections (before the gate runs) are covered separately: unknown
`kind`, unknown `context_slot`, unknown `calendar`, empty `text`, wrong
`schema_id`.

### Contract note for P3/P4

- `CalendarEvent.activityTypeWireValue` keeps the raw string and
  `CalendarEvent.activityType` is the lenient enum read. The gate needs both to
  tell "author left it out" from "author typed a value this build does not
  ship"; consumers should read `activityType`.
- `starterValueToken` (`{value}`) is exported from `starter_content.dart` — P3
  substitutes against it rather than re-declaring the literal.
- Asset keys and schema ids are exported constants
  (`startersAssetKey`, `calendarEventsAssetKey`, `startersSchemaId`,
  `calendarEventsSchemaId`).

### Result

**P1 COMPLETE.** No blocker. No `pubspec.yaml` change, no new dependency, no
`InvariantRule` member added.

## Phase P2 — Bảng `calendar_event_state` + migration v6→v7

### Lệnh đã chạy

| Lệnh | Kết quả |
| --- | --- |
| `dart run build_runner build` (sinh lại `cupid_database.g.dart`) | `Built with build_runner/aot in 26s; wrote 1301 outputs` |
| `flutter test test/features/conversation_starters/calendar_event_state_repository_test.dart test/core/database/calendar_event_state_migration_test.dart` | `+13: All tests passed!` |
| `flutter test test/core/database/ test/features/activity_cards/ test/features/conversation_starters/ --reporter failures-only` | `+346 ~2: All other tests passed!` (2 skipped có sẵn từ trước) |
| `flutter analyze --no-fatal-infos --no-fatal-warnings` trên 3 file `lib/` đã đụng + `test/core/database/` + `test/features/conversation_starters/` + `test/features/activity_cards/activity_type_test.dart` | `Analyzing 6 items... No issues found!` |

Không chạy `flutter analyze` toàn repo: nền tảng phi-zero có sẵn, không thuộc
phase này.

### File đã giao

| File | Vai trò |
| --- | --- |
| `mobile/lib/core/database/tables/calendar_event_state_table.dart` | Bảng Drift, PK gộp (`owner_key`, `event_id`), 4 cột |
| `mobile/lib/core/database/cupid_database.dart` | Đăng ký bảng, `schemaVersion` 6→7, nhánh `if (from < 7)` |
| `mobile/lib/core/database/cupid_database.g.dart` | Sinh tự động bởi `build_runner` |
| `mobile/lib/features/conversation_starters/data/calendar_event_state_repository.dart` | `CalendarEventStateRepository` + enum `CalendarEventHandledState` |
| `mobile/test/core/database/calendar_event_state_migration_test.dart` | 6 test migration v6→v7 và hình dạng bảng |
| `mobile/test/features/conversation_starters/calendar_event_state_repository_test.dart` | 6 test repository |

Sửa hằng số phiên bản (7 điểm `schemaVersion` + 4 điểm `PRAGMA user_version`
trong 8 file): `activity_card_dao_test.dart`, `activity_card_migration_test.dart`
(2), `context_notebook_migration_test.dart` (2), `expense_dao_test.dart`,
`journal_dao_test.dart`, `migration_v5_test.dart` (2), `timeline_dao_test.dart`,
`activity_type_test.dart`. `cupid_database_migration_v3_test.dart` dòng 79/141
so sánh tương đối (`expect(version, db.schemaVersion)`) nên **không** cần sửa —
kế hoạch đếm chúng là 2 trong 9, thực tế số điểm phải sửa là 11 ở 8 file khác.

### Bao phủ AC

| AC | Nội dung | Bao phủ ở P2 | Bằng chứng |
| --- | --- | --- | --- |
| AC-12 | Sự kiện đã đổi thành thẻ chỉ nằm ở kho chung màn (1), màn này không giữ bản sao riêng | ĐỦ ở tầng dữ liệu | Bảng chỉ có `owner_key`/`event_id`/`state`/`updated_at` — không cột nào sao chép nội dung thẻ: `calendar_event_state measures nothing and counts nothing` |
| AC-13 | Sự kiện đã qua ngày không còn được chào mời | MỘT PHẦN — P2 chỉ cấp nền lưu trạng thái; lọc theo ngày thuộc P3 | `handledEventIds` trả về tập id đã xử lý |
| AC-14 | Bỏ qua sạch, một chạm, không hỏi lý do | MỘT PHẦN — P2 cấp `markHandled(state: dismissed)`; nút bỏ qua thuộc P3/P4 | `ghi rồi đọc lại được id sự kiện`, `giá trị wire của trạng thái là hợp đồng với gói nội dung` |
| AC-21 | Không lưu chỉ báo hành vi người kia | ĐỦ | Test cấm cột: tập cột đúng bằng 4 giá trị, và không tiền tố `partner_`/`seen_`/`reply_`/`frequency_` |

### Tiêu chí nghiệm thu của phase

| Tiêu chí | Bằng chứng |
| --- | --- |
| Máy v6 lên v7 giữ nguyên mọi hàng `activity_cards`, `journal_entries`, `notebook_entries`, `skill_profile_entries`, `invite_messages` | `every pre-existing client-owned row survives the upgrade intact` — 5 bảng, mỗi bảng 1 hàng, đọc lại đúng giá trị đã seed |
| Không `DROP` nào trong nhánh migration mới | `nhánh migration v7 chỉ CREATE TABLE, không có DROP` — quét văn bản nhánh `if (from < 7)` trong `cupid_database.dart` |
| Không cột bị cấm | `calendar_event_state measures nothing and counts nothing (R-1b / AC-12 / AC-25)` |
| Ghi cùng `event_id` hai lần không sinh hàng thứ hai | `ghi lại cùng event_id là cập nhật tại chỗ, không sinh dòng thứ hai` — 1 hàng, `state` là lần ghi sau |

Per-story visual fidelity: NOT_APPLICABLE — phase này không dựng màn nào.

### Ghi chú hợp đồng cho P3

- Enum trạng thái tên là **`CalendarEventHandledState`**, không phải
  `CalendarEventState` như kế hoạch viết: `CalendarEventState` đã là tên lớp
  bảng Drift (nó quyết định cả tên SQL `calendar_event_state` lẫn getter
  `db.calendarEventState` mà nhánh migration gọi). Hai định danh không thể trùng
  tên trong cùng một thư viện.
- `markHandled` nhận `updatedAt` tuỳ chọn để test bơm thời gian tất định; bỏ
  trống thì repository tự dùng `DateTime.now()`.
- `handledEventIds(ownerKey)` trả về **mọi** id đã xử lý, không phân biệt
  `converted` và `dismissed`. P3 cần phân biệt thì đọc trực tiếp
  `db.calendarEventState` hoặc xin thêm một cửa đọc.
- Drift lưu `DateTime` theo unix-seconds và đọc ra giờ **địa phương**: so sánh
  phải qua `.toUtc()`.

### Result

**P2 COMPLETE.** No blocker. Không đổi `pubspec.yaml`, không thêm phụ thuộc,
migration chỉ `CREATE TABLE`.

## Phase P3 — Xếp câu mồi tất định + đổi sự kiện thành thẻ

### Lệnh đã chạy

| Lệnh | Kết quả |
| --- | --- |
| `flutter gen-l10n` (worktree mới, `lib/l10n/generated/` bị gitignore) | thành công |
| `flutter test test/features/conversation_starters/starter_selector_test.dart test/features/conversation_starters/calendar_event_service_test.dart` | `+41: All tests passed!` (0 skip) |
| `flutter test <2 file P3> test/features/activity_cards/ --reporter failures-only` | `+254 ~2: All other tests passed!` (2 skip có sẵn từ trước, nằm trong `activity_cards`) |
| `flutter analyze --no-fatal-infos --no-fatal-warnings lib/features/conversation_starters lib/features/activity_cards/domain/activity_card.dart test/features/conversation_starters` | `4 issues found` — **0 error, 0 warning**, 4 `info` thuộc nhóm lint có sẵn của repo (`prefer_initializing_formals` ×3, `use_null_aware_elements` ×1) |

Cổng analyze của phase là zero **error**, không phải exit code; analyze thu hẹp
vào đúng đường dẫn đã đụng vì nền tảng toàn repo phi-zero có sẵn.

### File đã giao

| File | Vai trò |
| --- | --- |
| `mobile/lib/features/activity_cards/domain/activity_card.dart` | Thêm `conversationStarter('conversation_starter')` vào cuối `ActivityCardOrigin`, append-only |
| `mobile/lib/features/conversation_starters/domain/starter_selector.dart` | `StarterSelector.select` hàm thuần + `RenderedStarter` + `stableContentKey` |
| `mobile/lib/features/conversation_starters/domain/calendar_event_service.dart` | `CalendarEventService` (`visibleEvents`/`addToStore`/`dismiss`), `VisibleCalendarEvent`, `nearestUpcomingDate` |
| `mobile/test/features/conversation_starters/starter_selector_test.dart` | 25 test: tất định, quay vòng tham số hoá theo N, riêng-hoá, sổ tay rỗng |
| `mobile/test/features/conversation_starters/calendar_event_service_test.dart` | 16 test: lọc ngày, lọc trạng thái đã xử lý, tạo thẻ, idempotency, enum append-only, không mạng |

### Bao phủ AC

| AC | Nội dung | Bao phủ ở P3 | Bằng chứng |
| --- | --- | --- | --- |
| AC-4 | Câu mồi dùng được ngay, không rỗng | ĐỦ | `N=$n: mỗi trang không rỗng và không có ô giữ chỗ` |
| AC-5 | Mục contextual đủ tư cách xếp trước generic | ĐỦ | `mục contextual đủ tư cách xếp trước mục generic` |
| AC-6/BR-5 | Sổ tay rỗng vẫn ra câu dùng được | ĐỦ | `sổ tay rỗng vẫn ra câu dùng được từ mục generic` |
| AC-11 | Thẻ tạo qua đúng cửa ghi STORY-001, trạng thái `idea` | ĐỦ | `thẻ tạo ra là idea, nguồn sinh conversation_starter, mang sẵn ngày sự kiện` |
| AC-12 | Bấm hai lần chỉ một thẻ; màn không giữ bản sao riêng | ĐỦ | `bấm hai lần cho cùng event_id chỉ tạo một thẻ`, `sự kiện đã đổi thành thẻ biến khỏi danh sách` |
| AC-13/R-1c/R-1d | Sự kiện đã qua ngày không xuất hiện và không API nào nhắc lại | ĐỦ | `sự kiện đã qua ngày không xuất hiện và không có API nào nhắc lại nó`, `sự kiện rơi đúng hôm nay vẫn còn được chào mời` |
| AC-14/BR-10 | Bỏ qua một chạm, không hỏi lý do, không tạo gì | ĐỦ | `dismiss không tạo thẻ nào và không hỏi lý do` |
| AC-15/AC-16/R-7 | Không mạng, không AI | ĐỦ | `lọc + tạo thẻ + bỏ qua chạy trọn dưới HttpClient ném lỗi nếu bị mở` |
| AC-17 | Tất định giữa hai lần chạy | ĐỦ | `hai lần gọi cùng đầu vào trả đúng cùng danh sách id`, `stableContentKey không phụ thuộc String.hashCode` |
| AC-27 | Hết vòng thì quay lại đầu kho, không trạng thái "đã hết" | ĐỦ | `N=$n: duyệt hết kho rồi lặp lại đúng bộ đầu tiên` với N ∈ {1,2,3,4,10,137}; `perPage <= 0 trả rỗng`, `page rất lớn vẫn trả đủ một bộ` |
| AC-28 | N < `perPage` trả đúng N mục, không chèn giữ chỗ | ĐỦ | `perPage không đặt ràng buộc nào lên N`, `N=1`/`N=2` trong bộ tham số hoá |

### Tiêu chí nghiệm thu của phase

| Tiêu chí | Bằng chứng |
| --- | --- |
| Hai lần gọi cùng đầu vào trả id giống hệt | So khớp cả `id` lẫn `text` giữa hai lần gọi |
| N ∈ {1,2,3,4,10,137}, `perPage=3`: duyệt hết rồi wrap đúng bộ đầu | Chu kỳ tính từ `n ~/ gcd(perPage, n)` — suy ra từ N, không hằng số; `seen.length == n`, rồi `pageIds(period) == pageIds(0)` và `pageIds(period+1) == pageIds(1)` |
| N < `perPage` trả đúng N mục, không ném lỗi | `starters.length == (n < perPage ? n : perPage)`; kho rỗng trả rỗng |
| Không câu nào còn sót token `{value}` | `không câu nào trả ra còn sót token {value}` — quét 3 hình thái sổ tay × 4 trang |
| Thẻ `status == idea`, `origin == conversationStarter`, `scheduledOn` bằng ngày sự kiện | `card.status`/`card.origin`/`card.scheduledOn` khẳng định trực tiếp; `một scheduled_on khác null không làm thẻ thành scheduled` đọc lại kho theo status |
| `fromWireValue` vẫn đọc được cả bốn giá trị cũ | `fromWireValue vẫn đọc được cả bốn giá trị cũ sau khi thêm giá trị mới` + `giá trị mới nằm cuối, không chen vào giữa` |
| Không `DateTime.now()` trong domain của phase | Cả `starter_selector.dart` lẫn `calendar_event_service.dart` nhận `today` tiêm vào; không file nào import `dart:core` clock hay gọi `DateTime.now()` |

Per-story visual fidelity: NOT_APPLICABLE — phase này không dựng màn nào.

### Ghi chú hợp đồng cho P4

- `StarterSelector.select` là `static`, không giữ con trỏ trang: P4 tự giữ số
  `page` và truyền `perPage` theo bố cục. API không có cờ "đã hết" nào để P4 vô
  tình dựng thành chỉ báo tiến độ.
- Mục `contextual` thiếu giá trị sổ tay bị **loại hẳn** khỏi kho, không render
  nửa vời; nên số mục đủ tư cách thay đổi theo sổ tay và `select` có thể trả ít
  hơn `perPage`.
- `addToStore` trả `null` khi sự kiện đã xử lý — P4 dùng `null` này để quyết
  định có hiện xác nhận hay không, đừng gọi `visibleEvents` lần nữa để đoán.
- `VisibleCalendarEvent` mang cả `event` nguyên gói lẫn `date` đã chốt; màn đọc
  `event.name`/`event.calendar` từ gói, không tự dựng lại chuỗi ngày.
- `visibleEvents` sắp sẵn theo ngày gần nhất rồi tới `id`; P4 không cần sort lại.

### Result

**P3 COMPLETE.** No blocker. Không đổi `pubspec.yaml`, không thêm phụ thuộc,
không đổi schema Drift, enum `ActivityCardOrigin` chỉ append.
