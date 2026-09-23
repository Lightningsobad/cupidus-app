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

## Phase P4 — Màn Mồi chuyện + nối điểm vào từ Trang chủ

### Lệnh đã chạy

Tất cả chạy trong worktree của story, thư mục `mobile/`, với
`PATH="$HOME/flutter/bin:$PATH"`. Không lệnh nào bị nối ống.

| Lệnh | Kết quả |
| --- | --- |
| `flutter test test/features/conversation_starters --reporter failures-only` | `+103 ~1: All other tests passed!` (1 skip là test chụp ảnh, chỉ chạy khi có dart-define) |
| `flutter test test/features/conversation_starters test/features/activity_cards test/features/gift_ideas test/features/context_notebook --reporter failures-only` | `+508 ~8: All other tests passed!` |
| `flutter test .../conversation_starters_screen_test.dart --dart-define=CAPTURE_VISUALS=true --reporter failures-only` | `+19: All tests passed!` — sinh ảnh thị giác |
| `flutter analyze lib test` | exit 1, **0 error**, 35 warning, 198 info (233 dòng). Gate của phase là zero **error** → đạt. Exit code không phải gate: nền repo vốn đã có 35 warning. Không dòng nào trong 35 warning nằm ở file của P4 (đã đối chiếu từng đường dẫn). |
| `flutter build apk --debug` (build gate, nguồn: runtime registry `mobile-app.buildCommand`) | `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` sau 51.9s |
| `flutter test test/design_system --reporter failures-only` | `+88 -3` — **3 test đỏ có sẵn từ trước**, xem mục dưới |

Runtime startup smoke: NOT_APPLICABLE theo `phase-P4` §1B — phase chỉ thêm một
nhánh điều hướng, không đổi đường khởi động app.

### Ba test đỏ ở `test/design_system` là nợ có sẵn, không phải P4 gây ra

Cả ba đã đỏ ở `BaseHead 96b7f827`; đã đối chiếu bằng `git show 96b7f827:<path>`
và từng dòng bị tố đều đã tồn tại ở đó với đúng số dòng đó.

1. `shared_backdrop_occlusion_guard_test.dart` — `activity_card_detail_screen.dart:371`
   và `reminder_schedule_screen.dart:79` (`Scaffold(backgroundColor: ...)`).
2. `no_fork_guard_test.dart` — 7 chỗ: `skill_profile_screen.dart:167`,
   `context_inline_add_row.dart:242`, `activity_card_detail_screen.dart:590`,
   `quick_capture_sheet.dart:50`, `frame_chip_strip.dart:105`,
   `gift_ideas_screen.dart:157`, `service_locator.dart:659`.
3. `shared_backdrop_occlusion_test.dart` — `chat shows the shared sky wash...`
   `pumpAndSettle timed out`. Màn chat không nằm trong diff của P4.

Guard này **đã** bắt đúng một chỗ do P4 gây ra và chỗ đó đã được sửa:
`conversation_starters_screen.dart:204` từng viết
`Divider(color: context.cupidColors.colorLine)`; guard quét chuỗi con nên chuỗi
`cupidColors.` chứa luôn `Colors.`. Đã nâng token ra biến cục bộ
(`final CupidColorTokens colors = context.cupidColors;`) trong `_ThinDivider`.

### File đã giao

Sản phẩm:

- `mobile/lib/features/conversation_starters/presentation/cubit/conversation_starters_cubit.dart`
- `mobile/lib/features/conversation_starters/presentation/screens/conversation_starters_screen.dart`
- `mobile/lib/features/conversation_starters/presentation/widgets/starter_line.dart`
- `mobile/lib/features/conversation_starters/conversation_starters_entry_point.dart`
- `mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart` (sửa)

Test:

- `mobile/test/features/conversation_starters/conversation_starters_screen_test.dart`
  (19 test: 18 chạy thường + 1 test chụp ảnh `skip` trừ khi có dart-define)
- `mobile/test/features/gift_ideas/gift_ideas_screen_test.dart` (sửa hồi quy)

Bằng chứng thị giác:

- `visual-fidelity/implemented-6-moi-chuyen-a-a-material.png`
- `visual-fidelity/visual-fidelity-report.md` — `VISUAL_FIDELITY: PASS`

### Mở rộng Write Scope so với `phase-P4` §1B

`phase-P4` §1B khai 6 file. Bốn file dưới đây nằm **ngoài** danh sách đó nhưng
**trong** `WriteScope: mobile` của handoff, và đều bắt buộc để P4 xanh:

1. `mobile/lib/design_system/icons/cupid_icons.dart` — thêm duy nhất
   `static const IconData contentCopy = IconData(0xe14d, fontFamily: fontFamily);`.
   `uiux-spec` §2.2 gọi đích danh glyph `content_copy` của Material Symbols;
   barrel icon chưa có nó. Codepoint `0xe14d` đọc từ bảng cmap của chính font
   đang ship, không phải đoán. Chỉ append, không sửa/xoá icon nào.
2. `mobile/lib/features/conversation_starters/domain/starter_selector.dart` —
   đổi đúng **một** dòng import: `'../../context_notebook/domain/context_notebook_models.dart'`
   → `'../../context_notebook/context_notebook_entry_point.dart'`. Test ranh
   giới import của STORY-004 (`ask_on_the_spot_slot_test.dart`) đỏ vì file P3
   này chọc thẳng vào nội tạng của `context_notebook`. Một lượt grep toàn repo
   xác nhận đây là vi phạm duy nhất còn lại.
3. `mobile/test/features/gift_ideas/gift_ideas_screen_test.dart` — hai test hub
   vốn lặp `<String>['1', '2']` để khẳng định **cả hai** ô lối-vào-nhanh còn
   hiện snackbar `activity_quick_entry_coming_soon`. Ô 1 rời danh sách đó khi
   P4 nối nó vào màn (6), nên hai test giờ chỉ còn chạy ô 2; hồi quy điều hướng
   của ô 1 chuyển sang file test của chính story này.
4. `data/requirements/.../STORY-005_conversation_starters/visual-fidelity/`
   (ảnh + `visual-fidelity-report.md`). `phase-P4` §5 gọi tệp này là
   `coding-plan/visual-fidelity.md`, nhưng quy ước đang chạy của repo — và chỗ
   gate của Reviewer đọc — là `<STORY>/visual-fidelity/visual-fidelity-report.md`
   (STORY-001..004, STORY-006 đều vậy). Theo quy ước repo, không theo tên trong
   phase file.

### Bằng chứng vòng lặp: bảng "số lần bấm → id câu hiện ra" (N = 2)

Gói fixture 2 mục (`s01`, `s02`), `today = 2026-09-16`, `perPage = 3`. Thứ tự
xét duyệt do `stableContentKey` quyết định: `s02` (296279264) đứng trước `s01`
(346612121). `start = (page * 3) % 2` nên chỉ số đầu vòng đảo 0, 1, 0, 1…

| Số lần đã bấm "Xem câu khác" | Id câu hiện ra | Nút còn bật? |
| --- | --- | --- |
| 0 | `s02`, `s01` | có |
| 1 | `s01`, `s02` | có |
| 2 | `s02`, `s01` | có |
| 3 | `s01`, `s02` | có |
| 4 | `s02`, `s01` | có |
| 5 | `s01`, `s02` | có |

Mỗi vòng đúng **2** dòng, không có ô giữ chỗ cho khe thứ ba (AC-28), và
`TextButton.onPressed` khác `null` ở cả 6 lần đo (AC-27 — không có trạng thái
hết kho). Test tương ứng còn chạy thêm N = 12: bấm 6 lần, vượt qua cả 4 vòng
phân biệt, vẫn ra câu và nút vẫn bật.

### Nhãn nút: "Xem câu khác", không phải "Gợi ý khác"

`phase-P4` §3/§4 gọi nút này là "Gợi ý khác". `ux/uiux-spec.md` §2.2 và
`requirements/requirements.md` gọi nó là **"Xem câu khác"**. Artifact ràng buộc
thắng phase file, nên nhãn ship là "Xem câu khác". Đây là lệch tên trong kế
hoạch, không phải lệch hành vi: nút vẫn làm đúng việc §4 mô tả.

### Chuỗi chrome dùng helper `starterText` chứ không qua ARB

Màn (6) dùng `starterText(context, vi, en)` nội tuyến như STORY-004, không thêm
khoá ARB. Cổng nội dung của story (`starter_content_gate.dart`, P1) chỉ cấm
chuỗi **nội dung** (câu mồi, tên sự kiện) nằm trong Dart/l10n; nhãn chrome
("Xem câu khác", "Sự kiện có lịch", "Thêm vào kho", "Đã copy") không phải nội
dung gói và được phép ở trong code.

### Bao phủ AC

| AC | Cách phủ |
| --- | --- |
| AC-1 | `màn mở ra là đã có 3 câu`, không state rỗng trung gian |
| AC-2 | mock `SystemChannels.platform` bắt `Clipboard.setData`; khẳng định toast `Đã copy` hiện rồi tự tắt |
| AC-3 | sau khi copy, `cardCount() == 0`; quét cây widget không có mục "đã copy"/"đã lưu"/"yêu thích" |
| AC-4 | bảng vòng lặp ở trên, cả N = 2 và N = 12 |
| AC-6 | sổ tay trống vẫn ra đủ dòng câu mồi |
| AC-7 | bấm "Bỏ qua" ở khe hỏi không làm mất khối câu mồi hay khối sự kiện |
| AC-8 | trả lời khe hỏi ghi thẳng vào `ContextNotebookRepository` của STORY-004; màn này không có kho riêng |
| AC-9 | không có luồng điền-trước/onboarding nào trên màn |
| AC-11 | bấm "Thêm vào kho" tạo đúng 1 thẻ `idea`, `origin = conversationStarter`, `scheduledOn = '2026-10-20'` |
| AC-12 | sau khi thêm, hàng đó biến khỏi danh sách sự kiện |
| AC-13 | sự kiện đã qua ngày không xuất hiện |
| AC-14 | bấm bỏ qua xoá hàng ngay, không có `AlertDialog`, không tạo thẻ |
| AC-15 | toàn bộ nội dung đọc từ `AssetBundle`; không có spinner/skeleton/banner mạng trong cây widget |
| AC-27 | không chuỗi nào trong `%`, `đã hết`, `hết câu`, `đã xem hết`, `còn lại`, `lưu lại`, `xuất`, `yêu thích`, `đã dùng`, `điểm`, `chuỗi ngày`, `streak`; không `Checkbox`/`Switch`/`Slider`/progress indicator |
| AC-28 | N = 2 render đúng 2 dòng, không ô giữ chỗ |

Lối vào từ ô lối-vào-nhanh của màn (1) **không** có AC nào trong
`requirements.md` đặt tên; nó do `ux/uiux-spec.md` §1 quy định. Test tương ứng
đăng ký `CupidDatabase`, `BackendUserIdStore`, `ContextNotebookRepository`,
`ActivityCardRepository` vào `getIt` rồi bấm `activity_quick_entry_slot_1` từ
cả hub đầy lẫn trạng thái Phút-1, đi qua đúng đường `_resolveCubit` +
`rootBundle` của production với gói ship thật; ô 2 vẫn ra
`activity_quick_entry_coming_soon`.

### Kiểm tra thị giác

Đã mở ảnh ra nhìn. Chữ tiếng Việt lên đúng dấu, glyph `content_copy` và `close`
rasterise đúng (không tofu). Đối chiếu từng mục `ux/uiux-spec.md` §2 → không có
delta nào. Không dựng được ảnh design reference vì trình dựng canvas trả
`VISUAL_RUNTIME_MISSING` (install defect của runtime, ngoài lane Mobile); đã so
sánh bằng DOM của khung canvas thay thế và ghi 8 điểm `DESIGN_SPEC_CONFLICT`
trong `visual-fidelity/visual-fidelity-report.md`. Id `Design-Screen:` được
**suy ra** (`6-moi-chuyen-a-a`) từ nhãn khung và 6 cặp nhãn→id đã xác nhận ở các
story khác, **chưa** được liệt kê xác nhận bằng trình dựng.

### Result

**P4 COMPLETE.** No blocker. Không đổi `pubspec.yaml`, không thêm phụ thuộc,
không đổi schema Drift, không thêm route vào shell điều hướng (màn được push
bằng `MaterialPageRoute` từ ô lối-vào-nhanh).

## P5 — Phân cấp hero/phụ (ruling 2026-09-20 mục 2), 2026-09-20

Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-005_conversation_starters`.
BaseHead: `06dc96a489a6fcb734690cd26ad113c2ae725a0f`.

### Lệnh đã chạy

| Lệnh | Kết quả |
| --- | --- |
| `flutter test test/features/conversation_starters/conversation_starters_screen_test.dart --reporter failures-only` | `+24 ~1: All other tests passed!` (1 skipped = test chụp ảnh, tắt khi không có `CAPTURE_VISUALS`) |
| `flutter test <file trên> --plain-name "phân cấp hero/phụ" --reporter expanded` | `+6: All tests passed!` — liệt kê đủ 6 case mới |
| `flutter test test/features/conversation_starters --reporter failures-only` | `+106 ~1 -3` — 3 đỏ **có sẵn từ trước**, xem mục dưới |
| `flutter test <file trên> --dart-define=CAPTURE_VISUALS=true --reporter failures-only` | `+25: All tests passed!`, ảnh đã ghi |
| `flutter analyze lib/features/conversation_starters/presentation test/.../conversation_starters_screen_test.dart` | 7 issues, **toàn bộ là `info` có sẵn trong `conversation_starters_cubit.dart`**; 0 issue ở file đã chạm |
| `flutter analyze lib test` | 0 error, 35 warning, 230 info — đúng baseline repo, không có mục nào ở file đã chạm |

### Ba test đỏ là baseline của nhánh, không do P5

`starter_content_gate_test.dart` (2 case) và `calendar_event_service_test.dart`
(1 case) so khớp danh sách thành viên enum và đang thiếu ba giá trị mà story
khác đã thêm: `assertive_claim` (`InvariantRule`),
`missing_question_ending` (`StarterGateRule`), `compatibility_lookup`
(`ActivityCardOrigin`). `git log -S` cho thấy cả ba đã có mặt ở commit tổ tiên
của BaseHead (`47c52888` STORY-009, `6d59a6d0`/`406c0bc6` STORY-010), tức là đỏ
trước khi phase này bắt đầu. Diff của P5 gồm đúng 4 file (3 widget/screen + 1
test) và **không** file nào trong hai test đỏ import chúng — kiểm bằng danh sách
`import` của cả hai file. Việc sửa chúng thuộc lane sở hữu enum, không phải P5.

### Bảng N → (thẻ hero, câu phụ, caption "CÙNG CHỦ ĐỀ")

| N (số mục trong gói) | thẻ hero | câu phụ (`StarterLine`) | caption `CÙNG CHỦ ĐỀ` |
| --- | --- | --- | --- |
| 1 | 1 | 0 | không |
| 2 | 1 | 1 | có |
| 12 | 1 | 2 | có |

Ở N = 1 còn khẳng định không có `starter_line_placeholder`, không có hộp rỗng,
và `_starterIdsOnScreen` dài đúng 1 (AC-28).

### Bao phủ acceptance criteria của phase

| Tiêu chí §4 | Cách phủ |
| --- | --- |
| đúng một hero + tối đa hai câu phụ | `kho đủ dài: một thẻ hero + hai câu phụ dưới caption (N = 12)` |
| N = 1 không caption, không hộp rỗng | `N = 1: chỉ thẻ hero, không caption "CÙNG CHỦ ĐỀ", không ô rỗng` |
| N = 2 một hero + đúng một phụ | `N = 2: một hero + đúng một câu phụ` |
| bấm quá số mục vẫn có hero, nút không tắt | `bấm quá số mục thì hero luôn còn chữ (N = 2)` + test AC-27 sẵn có (`button.onPressed` khác null ở cả 6 lần đo) |
| cùng (ngày, sổ tay, page) ra cùng hero | `cùng (ngày, sổ tay, page) ra cùng một hero qua hai lần dựng (AC-17)`; và hero được khẳng định bằng `expectedRound(12, 0).first` |
| không bộ đếm/phần trăm/"đã xem hết"/nút lưu | test quét chuỗi cấm sẵn có, chạy lại xanh với bố cục mới |
| không khoá ARB mới | hai caption đi qua `starterText(context, vi, en)`; `starter_content_gate_test.dart` không đổi |

Thứ tự không đổi: hero là phần tử `[0]` của danh sách `StarterSelector` trả về.
Helper `_starterIdsOnScreen` đọc hero trước rồi tới các `StarterLine`, nên các
bảng xoay vòng AC-27 giữ nguyên ý nghĩa và vẫn xanh.

### Kiểm tra thị giác

Đã chụp lại `visual-fidelity/implemented-6-moi-chuyen-a-a-material.png` và **mở
ra nhìn bằng mắt**. Thẻ hero có caption `CÂU HÔM NAY` (mint, IN HOA, giãn chữ)
trên câu hero cỡ `cardTitle` đậm hơn hẳn hai câu phụ; dưới đó caption
`CÙNG CHỦ ĐỀ` muted rồi hai hộp bo góc nền `colorSurfaceAlt` — đúng tương quan
canvas `design-reference-6-moi-chuyen-a-a-ios.png`. Dấu tiếng Việt lên đủ ở cả
`Mồi chuyện`, `CÂU HÔM NAY`, `CÙNG CHỦ ĐỀ`, `Xem câu khác`; glyph `content_copy`
rasterise đúng, không ô tofu.

Khoảng cách còn lại so với canvas — nút đặc `Chép để nhắn`, icon `refresh`, dòng
trấn an dưới thẻ hero, nhãn khối sự kiện, badge ngày — là mục 3/4/5/6b/7, thuộc
P6/P7, cố ý **không** làm ở phase này. Nút copy trên hai câu phụ được **giữ**
theo §3 của phase file (canvas không vẽ, nhưng gỡ affordance ngoài phạm vi
ruling là tự phân xử).

`git status` sau khi chụp: chỉ 4 file mã/test của phase và đúng một PNG của
story này thay đổi; không đụng PNG visual-fidelity của story khác.

### Result

**P5 COMPLETE.** No blocker. Không đổi `pubspec.yaml`, không thêm phụ thuộc,
không đổi schema Drift, không thêm khoá ARB, không đổi `RenderedStarter` hay
`StarterSelector`.

## P6 — Nhãn, affordance và ngày inline (ruling 2026-09-20 mục 3, 4, 5, 6b), 2026-09-20

Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-005_conversation_starters`.
BaseHead: `ae908e93b87e399f0e9da55deb45bc791dd16c39`.

### Lệnh đã chạy

| Lệnh | Kết quả |
| --- | --- |
| `flutter test test/features/conversation_starters/event_date_label_test.dart` | `+5: All tests passed!` |
| `flutter test test/features/conversation_starters/conversation_starters_screen_test.dart -r github` | `29 tests passed, 1 skipped` (skip = test chụp ảnh, tắt khi không có `CAPTURE_VISUALS`) |
| `flutter test test/features/conversation_starters/conversation_starters_screen_test.dart --dart-define=CAPTURE_VISUALS=true -r github` | `30 tests passed` — ảnh đã ghi |
| `flutter test <5 file còn lại của thư mục> test/design_system -r github` | xanh, trừ đúng 3 đỏ baseline mô tả dưới |
| `flutter analyze lib test` | 265 issues: **0 error**, 35 warning, 230 info — trùng khít baseline ghi ở P5; **0 chẩn đoán ở cả 7 file đã chạm** |

Exit code của `flutter analyze` là 1 theo đúng baseline nhánh (info/warning có sẵn);
gate của phase là zero **error** và không warning mới ở file đã chạm — cả hai đạt.

### Ba test đỏ vẫn là baseline của nhánh, không do P6

Y hệt danh sách P5 đã lập: `starter_content_gate_test.dart` (2 case, dòng 471 và
498) và `calendar_event_service_test.dart` (1 case, dòng 390) so khớp danh sách
thành viên enum và thiếu `assertive_claim` (`InvariantRule`),
`missing_question_ending` (`StarterGateRule`), `compatibility_lookup`
(`ActivityCardOrigin`). `git diff --name-only ae908e93` của P6 trả đúng 5 file
sửa + 2 file mới, **không** file nào trong đó, và cũng không file nào trong đồ
thị import của hai test đỏ. Sửa chúng thuộc lane sở hữu enum.

### Bảng nhãn cũ → nhãn mới (4 chuỗi của ruling)

| Mục ruling | Nhãn cũ | Nhãn mới |
| --- | --- | --- |
| 3 | text button `Xem câu khác` (chữ, trên thân màn) | nút đặc `Chép để nhắn` + nút tròn icon `refresh` (nhãn `Xem câu khác` chuyển vào `Semantics`) |
| 4 | *(không có)* | `Câu này nhắn liền, không cần lưu. Quay lại là có câu khác.` |
| 5 | tiêu đề `Sự kiện có lịch` | `CÓ LỊCH SẴN · RỦ ĐI ĐƯỢC` |
| 5 | pill `Thêm vào kho của tôi` | `Thêm vào Muốn làm` |
| 6b | badge `dd/mm` riêng (`starter_event_date_<id>`) | ngày gộp vào dòng tên: `<tên> — thứ Bảy 16/08` |

Mục 6b dùng dạng **tuyệt đối** (`thứ Bảy 16/08`), không phải dạng tương đối
(`thứ Bảy này`): `eventDateLabel` là hàm thuần của chuỗi `YYYY-MM-DD` mà gói
ship, không đọc đồng hồ, nên nhãn không thể lệch khỏi ngày thẻ đang mang.

### Codepoint của `CupidIcons.refresh` và nguồn tra

`0xe5d5`. Tra bằng `fontTools` `getBestCmap()` chạy thẳng trên font đang bundle
`mobile/assets/fonts/MaterialSymbolsRounded-Variable.ttf` — không lấy từ trí nhớ
(tiền lệ D-20/R8-F-2). Cmap xác nhận đây là codepoint đơn, không alias;
`autorenew`/`0xe028`, `sync`/`0xe627`, `cached`/`0xe86a`, `restart_alt`/`0xf053`
là glyph khác, đã ghi trong doc comment của token để không ai thay bừa.

### Bao phủ acceptance criteria của phase

| Tiêu chí §4 | Cách phủ |
| --- | --- |
| hero có đúng một nút đặc + một nút tròn, hết text button | `thẻ hero có nút đặc "Chép để nhắn" kèm icon copy`, `nút tròn refresh thay text button "Xem câu khác"` (`find.text('Xem câu khác')` findsNothing) |
| nút đặc ghi clipboard, toast, không tạo thẻ | `copy một câu (AC-2, AC-3)` chạy lại xanh trên affordance mới |
| bấm nút tròn quá số mục vẫn ra câu, không bao giờ tắt | `bấm nhiều lần hơn số câu vẫn luôn ra câu, nút không bao giờ tắt (N = 2)` — đọc `InkWell.onTap` của `starter_next_round` |
| `Semantics` nhãn `Xem câu khác`, vùng chạm ≥44pt | cùng test; khẳng định `properties.button == true`, `properties.label` và kích thước ≥ `kStarterCopyTapTarget` |
| dòng trấn an dưới hàng CTA | `dòng trấn an nằm dưới hàng CTA của thẻ hero` — so `getBottomLeft` của CTA với `getTopLeft` của dòng |
| nhãn khối sự kiện + pill mới, hành vi không đổi | `khối sự kiện đọc nhãn mới, nhãn cũ biến mất`; `"Thêm vào Muốn làm" tạo thẻ conversationStarter rồi bỏ dòng đi`; `"Bỏ qua" ...` |
| hết badge riêng, ngày nằm trong dòng tên | `ngày nằm trong dòng tên, không còn badge riêng (ruling 6b)` — `starter_event_date_<id>` findsNothing |
| ngày khớp `VisibleCalendarEvent.date` | `ngày hiển thị khớp VisibleCalendarEvent.date` — `endsWith(eventDateLabel('2026-10-20'))` |
| `refresh` render glyph thật, không tofu | mục "Kiểm tra thị giác" dưới |
| không khoá ARB mới, không chuỗi nội dung vào Dart, không gọi mạng | mọi nhãn đi qua `starterText(context, vi, en)`; `app_vi.arb` không đổi; test cổng nội dung và test "không lời gọi mạng" chạy lại xanh |

Unit `eventDateLabel` phủ bảy thứ trong tuần (2026-08-17 … 2026-08-23), số 0 dẫn
đầu (`2026-01-05` → `thứ Hai 05/01`), năm nhuận/cuối năm, tính thuần, và từ chối
chuỗi không phải `YYYY-MM-DD` (`throwsFormatException`).

Hai neo key được **giữ nguyên** để regression P4/P5 không mất điểm bám:
`starter_line_copy_<id>` chuyển sang nút đặc của hero, `starter_next_round`
chuyển sang nút tròn. Nút tròn dựng bằng `InkWell` chứ không `IconButton`, nên
khẳng định sẵn có `expect(find.byType(IconButton), findsNothing)` vẫn đúng.
Bộ lọc quét chuỗi cấm dạng `x/N` đổi từ "trừ các key badge ngày" sang "trừ các
key `starter_event_name_`", vì ngày inline giờ nằm trong chính dòng tên.

### Kiểm tra thị giác

Đã chụp lại `visual-fidelity/implemented-6-moi-chuyen-a-a-material.png` và **mở
ra nhìn bằng mắt**. Glyph `refresh` mới thêm rasterise đúng thành vòng tròn có
mũi tên trong đĩa viền `colorLine` — **không ô tofu**, đây là rủi ro lớn nhất của
phase và đã loại trừ bằng mắt chứ không bằng một lần chạy xanh. Nút đặc
`Chép để nhắn` là dải gradient hồng-tím full-width kèm icon copy, đĩa refresh nằm
sát phải cùng hàng, dòng trấn an muted nằm ngay dưới — khớp canvas
`design-reference-6-moi-chuyen-a-a-ios.png`. Dấu tiếng Việt đủ ở `Mồi chuyện`,
`CÂU HÔM NAY`, `Chép để nhắn`, `Câu này nhắn liền, không cần lưu. Quay lại là có
câu khác.`, `CÙNG CHỦ ĐỀ`.

Giới hạn đã biết của ảnh này: trong khung reference `415x900`, ô hỏi sổ tay
(`ContextAskCard`) chiếm nửa dưới màn và đẩy khối sự kiện xuống dưới fold, nên
mục 5 và 6b **không đối chiếu được bằng mắt** trong ảnh — canvas vẽ khối sự kiện
ngay dưới hai câu phụ vì canvas không vẽ ô hỏi. Đây là chênh lệch bố cục có sẵn
từ trước P6 (giống như canvas có tab bar mà màn chưa có), không do phase này gây
ra; P6 cố ý **không** đụng vào điều kiện hiện của ô hỏi vì nó nằm ngoài ruling và
ngoài Write Scope. Bằng chứng mục 5/6b vì vậy đến từ bốn test widget liệt kê ở
bảng trên. Đã thử nạp thêm entry `NotebookKind.event` vào fixture chụp để ô hỏi
rút lui — không có tác dụng — và đã hoàn tác để fixture chụp không lệch khỏi
bản gốc.

`git status` sau khi chụp: 5 file mã/test sửa + 2 file mới + đúng một PNG của
story này; không đụng PNG visual-fidelity của story khác.

### Result

**P6 DONE.** No blocker. Không đổi `pubspec.yaml`, không thêm phụ thuộc, không
đổi schema Drift, không thêm khoá ARB, không đổi `RenderedStarter`,
`StarterSelector` hay `VisibleCalendarEvent`. Không đụng
`phase-P7-event-reason-field.md`.

## P7 — Dòng lý do của sự kiện (ruling 2026-09-20 mục 7), 2026-09-23

Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-005_conversation_starters`.
BaseHead: `9ab00f489dfff89137cbf6d695a72718e9144c96`.

### Lệnh đã chạy

| Lệnh | Kết quả |
| --- | --- |
| `flutter test test/features/conversation_starters/starter_content_gate_test.dart` | `+48: All tests passed!` |
| `flutter test test/features/conversation_starters/calendar_event_service_test.dart` | `+24: All tests passed!` |
| `flutter test test/features/conversation_starters/` | `+140 ~1: All other tests passed!` (skip = test chụp ảnh) |
| `flutter test test/features/conversation_starters/conversation_starters_screen_test.dart --dart-define=CAPTURE_VISUALS=true` | `+33: All tests passed!` — ảnh đã ghi |
| `flutter test test/core/content/ <6 file content-gate anh em>` | `+218: All tests passed!` |
| `flutter test test/core/database/` | `+93 -11` — **toàn bộ 11 đỏ là baseline nhánh**, xem mục dưới |
| `flutter analyze lib/features/conversation_starters test/features/conversation_starters` | 10 issues: **0 error**, 0 warning, 10 info `prefer_initializing_formals` có sẵn trên dòng khởi tạo không hề chạm |
| `flutter analyze lib test` | **0 error**; 0 chẩn đoán mới ở file đã chạm |

Exit code của `flutter analyze` là 1 theo baseline nhánh; gate của phase là zero
**error** và không warning mới ở file đã chạm — cả hai đạt.

### `mobile/lib/core/database/` không có một thay đổi nào

`git diff 9ab00f48 --stat -- mobile/lib/core/database/` trả về **rỗng**. Phase này
không thêm cột, bảng, migration Drift nào và không đụng `schemaVersion` (§1C).
Dữ liệu mới đi hoàn toàn qua gói nội dung `req016.calendar_events.v1`, giữ nguyên
`schema_id`, thêm hai khoá **tuỳ chọn** `reason_template` / `reason_context_slot`.

### 11 test đỏ của `test/core/database/` đã đỏ sẵn **tại BaseHead** — chặn P7

`schemaVersion` hiện là **9** sau ba merge anh em (`84a3c4b4` STORY-009,
`32f6a085` STORY-010, `ba18b8bc` STORY-013), trong khi các test migration cũ vẫn
khẳng định "lands on v7"/"lands on v8". Đây đúng lớp lỗi va chạm `schemaVersion`
giữa các nhánh song song.

**Bằng chứng BaseHead (chạy thật, không suy luận).** Dựng worktree tách rời sạch
tại đúng BaseHead rồi chạy lại:

```
git worktree add --detach /tmp/p7-basehead-proof 9ab00f489dfff89137cbf6d695a72718e9144c96
git -C /tmp/p7-basehead-proof rev-parse HEAD   # 9ab00f489dfff89137cbf6d695a72718e9144c96
git -C /tmp/p7-basehead-proof status --short   # rỗng — cây sạch, không mang thay đổi của P7
cd /tmp/p7-basehead-proof/mobile && flutter pub get && flutter gen-l10n
flutter test test/core/database/
```

Kết quả tại BaseHead: `+93 -11: Some tests failed.` — **trùng khít** con số và
trùng khít 11 tên test với lần chạy trên cây làm việc của P7. Khẳng định đỏ mẫu,
nguyên văn:

```
+0 -1: v6 -> v7 lands on v7 with both closure-ledger tables present [E]
  Expected: <7>
    Actual: <9>
  test/core/database/chapter_closure_migration_test.dart 119:7
```

Worktree tạm đã gỡ bằng `git worktree remove --force` sau khi lấy bằng chứng.

Đường dẫn đỏ, tất cả **ngoài Write Scope** của P7:

- `mobile/test/core/database/calendar_event_state_migration_test.dart` (4 case)
- `mobile/test/core/database/chapter_closure_migration_test.dart` (2 case)
- `mobile/test/core/database/relationship_labels_migration_test.dart` (5 case)

Bằng chứng bổ trợ không do P7: diff `core/database` rỗng như mục trên, và
`grep -rl conversation_starters test/core/database/` không trả file nào — đồ thị
import của các test đó không chạm file nào P7 sửa. Sửa chúng thuộc lane sở hữu
Drift; P7 bị cấm mở Drift theo §1C nên không tự vá.

### Sửa trôi enum do merge song song (ngoài phạm vi P7, cần Reviewer phán)

Hai sửa nằm trong Write Scope nhưng **không** thuộc yêu cầu §3 của P7. Cả hai là
hệ quả của story anh em merge vào nhánh khi STORY-005 đang bay:

1. `starter_content_gate.dart`: STORY-009 (`47c52888`, merge `84a3c4b4`) thêm
   `assertiveClaim('assertive_claim')` vào `InvariantRule` và cập nhật năm cổng
   anh em, nhưng bỏ sót cổng của STORY-005. Ngoài hai test đỏ, đây còn là rủi ro
   `StateError` lúc chạy: `_starterRuleFor` dùng `firstWhere` **không** `orElse`.
   Đã vá bằng cách soi `gift_content_gate.dart`, chèn `assertiveClaim` làm giá
   trị thứ bảy, và sửa hai khẳng định "sáu" thành "bảy".
2. `calendar_event_service_test.dart`: STORY-010 (`32f6a085`) nối
   `compatibilityLookup` vào `ActivityCardOrigin`, làm đỏ test append-only vốn so
   khớp danh sách enum đủ 5 phần tử. Hợp đồng mà test đó bảo vệ là *đoạn đầu bị
   đóng băng* (wire value ghi xuống Drift), nên khẳng định đổi sang so `take(5)`
   với tiền tố đóng băng — nối thêm vào cuối vẫn xanh, chen vào giữa hoặc đổi chỗ
   `conversation_starter` vẫn đỏ.

218 test của sáu cổng nội dung anh em chạy lại xanh sau sửa (1).

### Bảng sổ tay → dòng lý do

`resolveEventReason` là hàm thuần, khoá chọn `stableContentKey('$today|$eventId')`
— cùng phép FNV-1a mà `StarterSelector` dùng, nên AC-17 giữ một quy tắc chứ không
mọc quy tắc thứ hai.

| Cấu hình sổ tay | Sự kiện | Dòng lý do |
| --- | --- | --- |
| rỗng | có `reason_template` + slot `interest` | *(không có dòng)* |
| 1 mục `interest` = `Cà phê sáng`, 1 mục `event` | có template slot `interest` | `Đúng dòng "Cà phê sáng" trong sổ tay` |
| 4 mục `interest` | có template slot `interest` | một mục tất định; đảo thứ tự nhập **không** đổi kết quả |
| 8 mục `interest` | bốn sự kiện id khác nhau | ra nhiều hơn một dòng — không khoá cứng vào một mục |
| 1 mục `interest` giá trị rỗng | có template slot `interest` | *(không có dòng)* — không dựng ngoặc trống |
| bất kỳ | **không** khai template | *(không có dòng)* |

### Cổng nhập của gói ship

`validateStarterPacks` thêm ba luật: `event_reason_slot_mismatch` (khai một trong
hai khoá), `event_reason_token_mismatch` (số `{value}` khác 1),
`event_reason_asks_question` (dòng lý do kết thúc bằng dấu hỏi — đây là chuỗi
hiển thị duy nhất **không** được hỏi, nên dùng `starterStructureHitsIn` đảo
chiều thay vì nhân bản hằng dấu hỏi). Template cũng đi qua `_displayViolations`
nên bảy luật `InvariantRule` (tâng bốc, phần trăm, chuỗi, điểm/tỉ lệ, hành vi
người nhận, giọng thao túng, khẳng định chắc nịch) áp lên nó y như tên sự kiện.
`violations.isEmpty` cho gói ship kèm: sáu trên tám sự kiện mang lý do;
`tet_duong_lich` và `gio_to_hung_vuong` cố ý không mang khoá nào, chứng minh cặp
khoá là tuỳ chọn thật.

### AC-12/AC-14 không bị dòng lý do làm sống lại

`refreshContext` dựng lại lý do **trên `state.events`**, không gọi lại
`visibleEvents`. Gọi lại sẽ dựng dải từ gói và kéo về những dòng vừa "Thêm vào
Muốn làm" hoặc vừa bỏ qua. Test widget bỏ qua `ev-later`, ghi thêm mục sổ tay,
gọi `refreshContext`: `ev-upcoming` mọc dòng lý do, `ev-later` vẫn biến mất.

### Kiểm tra thị giác

Đã chụp lại `visual-fidelity/implemented-6-moi-chuyen-a-a-material.png` và **mở
ra nhìn bằng mắt**. Dòng lý do hiện đúng dưới dòng tên, cỡ `caption`, màu
`colorTextMuted`: `Đúng dòng "thích đọc sách cũ" trong sổ tay` dưới
`Sinh nhật bạn ấy — thứ Ba 20/10`. Đây là chỗ dễ ra tofu nhất của phase vì có cả
dấu ngoặc kép lẫn dấu tiếng Việt: **không ô tofu nào** — `Đ`, `ú`, `ò`, `í`, `ọ`,
`á`, `ũ`, `ổ` rasterise đủ nét, cặp `"` thẳng nguyên vẹn. `Kỷ niệm quen nhau —
thứ Hai 02/11` không có dòng lý do, đúng như gói fixture khai. Badge
`CÓ LỊCH SẴN · RỦ ĐI ĐƯỢC` và icon lịch/`×` vẫn nguyên.

Giới hạn bố cục mà P6 ghi lại đã **gỡ được**: P6 kết luận ô hỏi sổ tay chiếm nửa
dưới khung `415x900` và đẩy khối sự kiện xuống dưới fold, và ghi rằng nạp thêm
entry `NotebookKind.event` không có tác dụng (đúng — P7 thử lại, vẫn không). Cách
hiệu quả là chạm `ask-skip` trước khi chụp: ô hỏi rút lui và khối sự kiện lên
đúng vị trí canvas vẽ. `_captureAtReferenceViewport` vì thế nhận thêm tham số tuỳ
chọn `beforeCapture`; khung reference, nền, font và nền tảng Material giữ y
nguyên. Ảnh giờ đối chiếu được trực tiếp với
`design-reference-6-moi-chuyen-a-a-ios.png`, gồm cả mục 5 và 6b mà P6 phải để
lại cho test widget.

`git status` sau khi chụp: đúng 10 file, tất cả nằm trong Write Scope, và **đúng
một** PNG — của chính story này; không đụng PNG visual-fidelity của story khác.

### Result

**Toàn bộ công việc mã của P7 đã xong và xanh**, nhưng phase **không** được báo
COMPLETE: `flutter test test/core/database/` — một cổng bắt buộc của §6 — thoát
khác 0, và một test đỏ thì không bao giờ được miễn.

`BLOCKER: PREEXISTING_TEST_FAILURE`

- Lệnh: `flutter test test/core/database/`
- Khẳng định đỏ: `Expected: <7> Actual: <9>` tại
  `test/core/database/chapter_closure_migration_test.dart:119` (và 10 case cùng
  lớp)
- Bằng chứng BaseHead: `+93 -11` y hệt trên cây sạch tại
  `9ab00f489dfff89137cbf6d695a72718e9144c96` — xem mục trên
- Đường dẫn ngoài phạm vi: `mobile/test/core/database/` và
  `mobile/lib/core/database/cupid_database.dart` (`schemaVersion` = 9)

Không đổi `pubspec.yaml`, không thêm phụ thuộc, không đổi schema Drift, không đổi
`schema_id` của gói, không thêm khoá ARB. Hai sửa trôi enum nêu trên nằm ngoài §3
và cần Reviewer xác nhận.
