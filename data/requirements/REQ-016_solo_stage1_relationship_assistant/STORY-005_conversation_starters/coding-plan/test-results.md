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
