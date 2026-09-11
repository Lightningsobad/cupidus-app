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
