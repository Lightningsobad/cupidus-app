# STORY-004 — Test results

Created by the P4 run; earlier phases recorded no section here.

## Phase P4 — Notebook screen, skill profile screen, Me menu entry

Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-004_relationship_notebook_and_gift_ideas`
All commands run from `mobile/` with the Flutter SDK on `PATH`.

### Scoped suite

```
flutter test test/features/context_notebook test/features/account
```

`+190 ~4: All other tests passed!` — 190 passing, 4 skipped. The 4 skipped are
the visual-capture cases in `visual_capture_test.dart`, off unless
`--dart-define=CAPTURE_VISUALS=true` so the ordinary suite stays hermetic.

New coverage in that total:

- `test/features/context_notebook/notebook_screen_test.dart` — 13 cases.
  Grouping into the two fixed groups; neutral empty state (headers plus
  `+ tự thêm`, no inviting copy); row plus `...` menu carrying exactly two
  items; delete taking effect on the tap with no `AlertDialog` and no
  `SnackBar`; in-place edit; the segmented add row. `expectNoBannedSurfaces()`
  runs in every state and rules out share/export/copy glyphs and copy,
  streak/badge glyphs, and any progress indicator or `Slider`.
- `test/features/context_notebook/skill_profile_screen_test.dart` — 9 cases.
  Required-absence: no skill-level, score or tier affordance — a row renders
  exactly one `Text` descendant. Required-presence: every id in
  `requiredSkillSeedIds` renders as `Key('ask-chip-<id>')` on the empty screen,
  `requiredSkillSeedIds.length >= 4`, and `find.byType(TextField)` finds
  nothing there, so the user meets at least four seed chips before any input
  box. Also: no sub-group split once the list has entries, `...` menu of
  exactly `Sửa`/`Xoá`, immediate delete, in-place rename, manual add.
- `test/features/account/me_screen_context_rows_test.dart` — 3 cases. Both new
  `_MenuRow`s exist in the `Kho riêng của tôi` block beside the existing
  `Nhật ký riêng` row, and each pushes its own screen as a route over
  `MeScreen` with no `TabBar`.

Regression in the same run: `me_screen_test.dart`, `me_screen_journal_row_test.dart`,
`context_notebook_repository_test.dart` and `ask_on_the_spot_slot_test.dart` all green.

### Regression found and fixed during this phase

The first scoped run failed 2 of `me_screen_test.dart`'s cases:
`tapping the Theme store row navigates to ThemeStoreScreen` and
`renders the Digital Divorce teaser and the version line`, plus a hit-test
warning on `Typing Ghost` / `Love Contract`. Cause was the test fixture, not the
product: the two new `Kho riêng của tôi` rows push the lower content past the
fold of the default 800x600 test frame, so `tap()` derived offsets at y=612 and
y=810 outside the render tree, and the lazily built version line was never in
the tree at all. Fixed by adding `ensureVisible` before the three taps and
widening the existing scroll from -400 to -800. No product change; that file is
outside this phase's declared Write Scope and the edit is disclosed in the
completion report.

### Static analysis

```
flutter analyze lib/features/context_notebook lib/features/account/presentation/screens/me_screen.dart test/features/context_notebook test/features/account
```

9 issues, all pre-existing `info` lints in files this phase did not create
(`prefer_initializing_formals` in `context_notebook_repository.dart` and
`ask_on_the_spot_cubit.dart`; `unnecessary_import` for `theme_catalog.dart` in
`me_screen.dart`). Scoped to only the files this phase created or edited:

```
flutter analyze lib/features/context_notebook/presentation/screens/notebook_screen.dart lib/features/context_notebook/presentation/screens/skill_profile_screen.dart lib/features/context_notebook/presentation/widgets/context_inline_add_row.dart lib/features/context_notebook/context_notebook_entry_point.dart test/features/context_notebook/notebook_screen_test.dart test/features/context_notebook/skill_profile_screen_test.dart test/features/context_notebook/visual_capture_test.dart test/features/account/me_screen_context_rows_test.dart test/features/account/presentation/screens/me_screen_test.dart
```

`No issues found!`

Repo-wide:

```
flutter analyze --no-fatal-infos --no-fatal-warnings lib test
```

`217 issues found.` with exit code 0 — i.e. zero error-level issues repo-wide;
the 217 are the pre-existing `info` baseline (`prefer_initializing_formals`,
`deprecated_member_use` for `withOpacity`, `unnecessary_import`). Plain
`flutter analyze lib test` exits 1 on that baseline alone, which predates this
phase.

### Visual fidelity

Captured, eyeballed and recorded — see
`../visual-fidelity/visual-fidelity-report.md` (`VISUAL_FIDELITY: PASS`).

```
flutter test test/features/context_notebook/visual_capture_test.dart --dart-define=CAPTURE_VISUALS=true
```

`+4: All tests passed!`, writing six PNGs at the 415x900 iOS reference frame.

## Phase P6 — Gift repository and deterministic selector

Same worktree; all commands run from `mobile/` with the Flutter SDK on `PATH`.

### Scoped suite

```
flutter test test/features/gift_ideas test/features/context_notebook
```

`+161 ~4: All other tests passed!` — 161 passing, 4 skipped, zero failures. The
4 skipped are the same `visual_capture_test.dart` cases, off unless
`--dart-define=CAPTURE_VISUALS=true`. P6 adds no screen, so no visual fidelity
work belongs to this phase.

New coverage in that total:

- `test/features/gift_ideas/gift_selector_test.dart` — 24 cases over a const
  6-idea pack plus a parameterised generated pack.
- `test/features/gift_ideas/gift_repository_test.dart` — 10 cases reading the
  three real shipped packs off disk through a `CachingAssetBundle` and a real
  in-memory-Drift `ContextNotebookRepository`, so an author's pack that stops
  resolving fails here.

### Determinism — same order across two separate processes (AC-28)

Order is asserted against a golden id list held in the test file, not only
against a second in-process call, so a run in a fresh process is checked against
the same fixed expectation. Two separate `flutter test` processes:

```
flutter test test/features/gift_ideas/gift_selector_test.dart   # process 1
flutter test test/features/gift_ideas/gift_selector_test.dart   # process 2
```

Process 1 `00:01 +24: All tests passed!`, process 2 `+24: All tests passed!`.
Both include:

- `recorded context produces the golden order, id breaking every tie` —
  `['gift.b.v1','gift.c.v1','gift.e.v1','gift.f.v1','gift.a.v1','gift.d.v1']`
  with scores `[2,1,1,1,0,0]`.
- `two runs in one process agree, and agree with the golden order`.
- `reversing pack order and context order leaves the ranking alone` — the guard
  against an ordering that only looks stable because the input happened to
  arrive the same way twice.
- `the same recorded state ranks the same way on a second read` in the
  repository test, over the real packs and a real database.

`suggest` sorts on a total order (score desc, then `idea.id` asc), so no two
entries ever compare equal and Dart's unstable `List.sort` has nothing to
reorder. Matches are gathered by walking the index pack in author order rather
than by iterating a hash map.

### Package size is data — N=1 and N=200 (R-15b, AC-33)

The group `kích cỡ gói là dữ liệu (AC-33, R-15b)` runs the same five cases
against a generated pack at both sizes, 10 cases total, all green in the runs
above:

```
N=1   every idea survives an unfiltered pass
N=1   rotation past the end never overflows and never empties
N=1   the handmade branch stays non-empty and inside its branch
N=1   the two-hour ceiling holds at this size
N=1   the order repeats exactly on a second pass
N=200 every idea survives an unfiltered pass
N=200 rotation past the end never overflows and never empties
N=200 the handmade branch stays non-empty and inside its branch
N=200 the two-hour ceiling holds at this size
N=200 the order repeats exactly on a second pass
```

`nextBatch` wraps with `cursor % length`, so there is no index overflow and no
"ran out of ideas" state at either size; `quay vòng khi hết tập (AC-33)` also
asserts cursor 100 ≡ cursor 4 on a 6-idea pack, no repeat inside one batch even
when more are asked for than exist, and 20 consecutive non-empty batches.

### No second store, no randomness (AC-28, AC-32)

`gift_repository_test.dart` scans every `.dart` file under
`lib/features/gift_ideas/` as text and fails on `Table`, `DAO`, `Dao`, `drift`,
`Random`, `DateTime.now`, `Stopwatch`, `dart:io`, `package:dio`,
`package:http`, `HttpClient`, `cupid_api`, `savedGift`, `saved_gift`. A second
case asserts the scan actually reaches both new files, so the guard cannot pass
by scanning nothing. Both green.

The P5-owned `gift_content_gate_test.dart` case
`no Dart file in the gift flow hardcodes a count` also covers the two new files
and is green: neither contains a bare integer literal, so no package size, batch
size or per-kind score weight is pinned in Dart.

### Static analysis

```
flutter analyze lib test
```

`219 issues found.` — 219 `info`, 0 `warning`-level from this phase's files, 0
`error`. Baseline recorded by P4 in this same file was `217 issues found.`, so
the delta is exactly +2, both from `gift_repository.dart:17` and `:18`:
`prefer_initializing_formals` on the private `_notebook` / `_loader` fields.
That lint's suggested fix does not apply to a private field behind a named
parameter, and it is the repo's dominant pre-existing lint (118 hits at
baseline, 120 now) — the sibling `ContextNotebookRepository` constructor carries
it too. Exit code is 1 on the info baseline alone, which predates this phase;
the same run with the baseline made non-fatal exits 0, i.e. zero error-level
issues repo-wide:

```
flutter analyze --no-fatal-infos --no-fatal-warnings lib test
```

`219 issues found.`, exit code 0.

### Exit codes

Final bare runs of both gate commands, from `mobile/`:

```
flutter test test/features/gift_ideas test/features/context_notebook
```

`00:06 +161 ~4: All tests passed!`, exit code 0.

Earlier in the same session this command exited non-zero while the P5-owned
`no Dart file in the gift flow hardcodes a count` gate was still red against
`gift_selector.dart`. That was fixed by removing the bare integer literals from
the selector — the per-kind score weighting and the comparator's `!= 0` — not by
changing the P5 gate, which is outside this phase's Write Scope and stays green.

## Phase P7 — Gift ideas screen (5) and the hub quick-entry cell

Same worktree; all commands run from `mobile/` with the Flutter SDK on `PATH`.

### Scoped suite

```
flutter test test/features/gift_ideas test/features/activity_cards
```

`00:07 +305 ~3: All tests passed!` — 305 passing, 3 skipped, zero failures,
exit code 0. The 3 skipped are `CAPTURE_VISUALS`-gated capture cases (one new in
this phase, two P6-era ones in `activity_cards`). The pre-existing
`test/features/activity_cards/` cases are all in that total and stay green:
STORY-001's hub, detail screen and quick-capture behaviour is unchanged apart
from the quick-entry cell now having a destination.

New coverage, all in `test/features/gift_ideas/gift_ideas_screen_test.dart`
(21 passing + 1 gated capture):

- **Effort tier → minutes (AC-34, R-15a).** `giftDurationMinutes` is asserted
  against `GiftTaxonomyItem.maxMinutes` for every ranked suggestion, and the
  case also asserts every shipped tier is exercised, so a pack that adds a
  fourth tier is covered without editing the test. A second case pins the
  unresolved-tier path to `null`. There is no arithmetic to test: the taxonomy
  already publishes minutes, so the mapping is a read, not a conversion — see
  the phase-file wording note below.
- **Cubit filter state (AC-17, AC-18, AC-32).** Chip rows equal the pack;
  selecting a branch narrows the list and re-selecting the same chip clears it;
  the effort chip acts as a ceiling and composes with the branch chip;
  `refreshContext` re-ranks in place without dropping the active filter.
- **Screen (5) against the shipped packs.** One chip per branch and one per
  tier with no extra "all" cell (the row's `GestureDetector` count is asserted
  equal to the taxonomy length); every ranked suggestion renders as a card, by
  key; tapping a branch chip filters in place and pushes no route.
- **AC-34 empty branch.** The `(branch, tier)` pair that ranks empty is
  *searched for* rather than named, so a reshuffled pack keeps the case
  meaningful. It asserts the settled empty state, no cards, no thrown
  exception, and that the chips stay put so the state is not a dead end.
- **AC-33 no set accounting.** No `%`, "đã hết", "hết ý tưởng", "còn lại",
  "xem thêm", "tải thêm" in any rendered `Text`, and no progress indicator
  widget of either kind.
- **Push to hub (AC-21, AC-23, AC-24 / SC-5).** Against a real in-memory Drift
  `ActivityCardRepositoryImpl`: the created card carries the idea's title,
  `origin == ActivityCardOrigin.giftSuggestion` (wire value `gift_suggestion`),
  `durationMinutes == tier.maxMinutes`, and **`priceVnd == null`**. The reader
  is still on `GiftIdeasScreen` afterwards, the in-place confirmation is
  visible, and the action pill is still there — no auto-navigation, no separate
  "đã lưu" screen.
- **AC-20.** A handmade suggestion renders the "từ kỹ năng: …" line once a
  skill is in the notebook.
- **Absence assertions (AC-16, AC-19, AC-22).** Every rendered `Text` is
  scanned for `₫`, `vnđ`, `vnd`, `đồng`, `$`, `giá`, `rẻ`, `đắt`,
  `khuyến mãi`, `giảm giá`, `mã giảm`, `cửa hàng`, `shop`, `mua `, `http`; and
  separately for `lưu`, `yêu thích`, `chia sẻ`, `save`, `favourite`, `share`,
  `để dành`, `xem sau`. Share/favourite/bookmark/star icons are asserted
  absent, and each card is asserted to hold exactly one button.
- **Quick-entry routing, both hub states.** Tapping slot 0 ("Gợi ý quà") pushes
  `GiftIdeasScreen` and shows no snackbar; slots 1 and 2 still show
  `Key('activity_quick_entry_coming_soon')` and push nothing. Asserted twice
  over: once against a seeded store (the populated hub's own strip) and once
  against an **empty** store, which puts the hub in Minute-1 and mounts that
  state's separate copy of the strip.

### Minute-1 carries its own strip — the fix that needed

The first pass wired only the populated hub. `minute_one_empty_state.dart`
renders a second `QuickEntryStrip`, and it was left as `const QuickEntryStrip()`
with no callback, so in the empty store — the first hub a new user ever sees —
the "Gợi ý quà" cell still fell back to the neutral "Sắp có" answer. That is a
straight failure of this phase's own AC, not a cosmetic gap.

`MinuteOneEmptyState` gained an `onQuickEntryCellSelected` parameter mirroring
`QuickEntryStrip`'s own `ValueChanged<QuickEntryCell>?` contract, threaded from
`_EmptyPane.build()`. `_openQuickEntryCell` moved from a method on
`_ActivityCardHubBody` to a private top-level function in the same file: it uses
no instance state, and `_EmptyPane` is a sibling class that cannot reach a
method on the body. Both hub states now route a cell through the same function,
so the two strips cannot drift apart again.

The two new cases fail against the pre-fix tree: without the callback the strip
falls back to its own snackbar, so `findsOneWidget` on `GiftIdeasScreen` goes
red. The pre-existing seeded-store case could not have caught this — it seeds a
card precisely to leave Minute-1.

The suite counts against the *ranked* list, not the pack: the shipped pack has
10 ideas and the selector ranks 9 for an empty notebook, so pack length is not
the baseline for anything rendered. The widget frame is 415x6000 because the
list virtualizes — in a shorter frame an absence assertion would pass by never
having built the offending card, and `findsNWidgets` would count only what is
on screen. This was a real red: at 415x2400 only 5 of 9 cards mounted.

### Static analysis

```
flutter analyze lib test
```

`222 issues found.`, exit code 1, **0 `error`-level**. P6 recorded `219` in this
same file, so the delta is exactly +3, all `prefer_initializing_formals` on the
new cubit's private `_gifts` / `_cards` / `_selector` fields
(`gift_ideas_cubit.dart:74`, `:75`, `:76`). That is the same lint P6 accepted on
`gift_repository.dart:17-18` for the same reason: the suggested fix does not
apply to a private field behind a named parameter, and it is the repo's dominant
pre-existing lint. The 35 `warning`-level issues repo-wide are all pre-existing
and none are in `lib/features/gift_ideas/`, `lib/features/activity_cards/`, or
either test folder. Exit 1 comes from the info baseline alone:

```
flutter analyze --no-fatal-infos --no-fatal-warnings lib test
```

`222 issues found.`, exit code 0.

The new test file on its own is clean:

```
flutter analyze test/features/gift_ideas/gift_ideas_screen_test.dart
```

`No issues found!`

### Content gates still green

The P5-owned `gift_content_gate_test.dart` (no bare integer literal, no
currency token in any gift file) and the P6-owned `gift_repository_test.dart`
text scan (no `Table`/`drift`/`Random`/`DateTime.now`/`dart:io`/HTTP/`savedGift`
under `lib/features/gift_ideas/`) both cover the three new `lib` files and are
green in the run above.

The zero-integer-literal gate shaped two implementation choices worth recording:
the screen renders the full ranked list rather than calling `nextBatch`, because
a batch size would be a literal; and all sizing comes from `CupidSpacing` /
platform tokens with no `size:` or `maxLines:` argument anywhere.

The currency gate shaped a third: the gate lowercases every file under
`lib/features/gift_ideas/` and rejects the substring `vnd`, so the string
`priceVnd:` cannot appear there at all. The cubit therefore *omits* the argument
rather than passing `priceVnd: null` — same result, and the `isNull` assertion
lives in the test file, which the gate does not scan.

### Visual fidelity — REQUIRED, PASS

`Design-Screen: 5-goi-y-qua-thang-cong-suc`, resolved after rendering per
`contracts/design-fidelity-spec.md`.

Reference, rendered at the iOS reference viewport:

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --surface=cupid-ch-ng-1 --screen=5-goi-y-qua-thang-cong-suc --platform=ios
```

`DESIGN_CANVAS: OK … 415x900` →
`visual-fidelity/design-reference-5-goi-y-qua-thang-cong-suc-ios.png`.

Implementation captured through `RepaintBoundary.toImage()` in this story's own
widget test at the same 415x900, `devicePixelRatio: 1` — the P4 precedent, used
because no device/simulator runtime is reachable from this lane:

```
flutter test test/features/gift_ideas/gift_ideas_screen_test.dart \
  --dart-define=CAPTURE_VISUALS=true --name='captures'
```

`00:00 +1: All tests passed!` →
`implemented-5-goi-y-qua-thang-cong-suc-ios.png` and `…-md.png`.

Both captures were opened and read, not just produced. Every Vietnamese string
renders with full diacritics and no tofu — "Gợi ý quà", "Không tốn tiền",
"Tự tay làm", "Trong 30 phút", "Trọn một buổi", "Cuốn album ảnh tự dán",
"từ kỹ năng: Gói quà đẹp", "Thêm vào kho của tôi" — and the framework
`MaterialIcons` glyphs (the `+` on the pill, the effort timer) draw as glyphs,
so `$FLUTTER_ROOT`'s icon font is loaded in the harness alongside the four
bundled text fonts.

The iOS capture's title band is blank: `CupidHeader` on iOS is a
`BackdropFilter`, and an offscreen boundary has no backdrop to sample. That is
the known P4 harness limitation, not a regression — the `-md.png` re-render is
what evidences the "Gợi ý quà" title, and it shows it.

Deltas against the reference are recorded in
`visual-fidelity/visual-fidelity-report.md`; the two that are design-vs-spec
conflicts rather than implementation drift are the primary-action label and the
per-card dismiss affordance.

## Phase P7 — vá biên giới import (rework F1, 2026-09-11)

- Lane: Mobile
- Date: 2026-09-11

### Cái gì đỏ

Gate biên giới import của P3
(`ask_on_the_spot_slot_test.dart:446`, "no file outside features/context_notebook
imports an internal") đỏ ở HEAD với ba offender, tất cả từ
`gift_ideas_screen.dart`: `data/context_notebook_repository.dart`,
`domain/ask_cadence_policy.dart`, `domain/context_content.dart`.

Nguyên nhân: màn (5) khai ba seam test/preview (`notebookRepository`,
`contentLoader`, `sessionSkips`) **kiểu** trực tiếp bằng type nội bộ của
`context_notebook`, nên nó buộc phải với qua mặt tiền. Đây là vi phạm bất biến
của P7, không phải của P3, và widening allowlist của gate (allowlist cố ý chỉ
có `service_locator.dart`) sẽ xoá đúng cái bất biến gate sinh ra để giữ.

### Cái gì sửa

- `gift_ideas_screen.dart`: ba seam đổi thành **một** seam
  `askSlotBuilder` kiểu `GiftIdeasAskSlotBuilder` — typedef chỉ dùng type của
  Flutter core. Màn vẫn tự giữ danh tính của ô hỏi (`entryPointId`,
  `neededFieldIds`) và truyền xuống builder; production dùng
  `_defaultAskSlot`, dựng `AskOnTheSpotSlot` không seam đúng như trước.
- `context_notebook_entry_point.dart`: thêm đúng một dòng
  `export 'domain/context_content.dart' show AskTarget;`. Caller **phải** gọi
  tên target trong `neededFieldIds`, nên nếu không export thì mỗi caller chép
  wire value của §2 vào Dart của mình — đó mới là cách bộ từ vựng §2 trôi.
  Repository, DAO, cubit, policy, widget nội bộ vẫn nằm ngoài mặt tiền.
- `gift_ideas_screen_test.dart`: `giftScreen()` bơm seam qua builder (file test
  không bị gate quét, gate chỉ quét `lib/`). Test "exactly one inline ask card"
  thêm assert `slot.entryPointId == giftIdeasEntryPointId` và
  `slot.neededFieldIds == [notebook.interest, notebook.event, skill]`, nên danh
  tính production của ô hỏi vẫn được test phủ chứ không biến mất cùng seam cũ.

`AskOnTheSpotSlot` giữ nguyên hợp đồng công khai; đây là vá tại call-site của
P7, không phải thiết kế lại widget của P3.

### Commands

| Lệnh | Kết quả |
|---|---|
| `flutter test test/features/context_notebook/ask_on_the_spot_slot_test.dart` | `00:04 +12: All tests passed!` (gồm case biên giới import) |
| `flutter test test/features/gift_ideas test/features/activity_cards` | `00:12 +305 ~3: All other tests passed!` — 305 passing, 3 skipped, 0 failures |
| `flutter analyze lib test` | `222 issues found.`, exit 1, **0 error-level**, không issue nào ở hai file `lib` và một file test đã sửa |

Cả ba lệnh chạy với `PATH="$HOME/flutter/bin:$PATH"` trong `mobile/`. Số đếm
bằng đúng baseline P7 (305/3/0 và 222 issue), nên vá không đổi nền.

## Phase P7 — vòng vá neo theo bản thiết kế (2026-09-11)

- Lane: Mobile
- Date: 2026-09-11

### Quyết định làm nền cho vòng này

Với màn (5), **bản thiết kế canvas là mốc neo, đứng trên câu chữ của
`ux/uiux-spec.md`** (tiền lệ STORY-001, commit b516c48, D-1/D-2/D-3). Đây là
câu trả lời cho tranh chấp *spec vs canvas*, **không** phải giấy phép ghi đè
một AC. Vì vậy trong bảy hạng mục `DESIGN_SPEC_CONFLICT` mà §P7 của
`visual-fidelity-report.md` ghi, chỉ năm hạng mục thuần câu chữ được neo theo
canvas; hạng mục 4 và 5 do AC-32/AC-34/R-15b chi phối nên giữ nguyên
pack-driven.

### Kiểm tra quy tắc dừng trước khi đổi nhãn (hạng mục 1)

Handoff yêu cầu dừng và báo `DESIGN_SPEC_CONFLICT_AC_RISK` nếu nhãn
`+ Thêm vào Muốn làm` của canvas buộc phải dựng kho thứ hai. Đã tra thẳng
trong cây nguồn: `Muốn làm` chính là tên tab hub sẵn có của pha 1
(`home_screen.dart:309` trả về `'Muốn làm'`; `activity_card_hub_view.dart`
tự mô tả mình là đích của tab đó; `req_master.md` hàng quyết định D-3 chốt
thanh tab 4 mục `Muốn làm / Ý tưởng / Sổ tay / Nhật ký`). Nhãn mới **gọi tên
đúng cái kho đang có**, `addToHub` vẫn gọi `createCard` của STORY-001, không
sinh collection nào khác. Không có rủi ro AC → không chặn.

### Kiểm tra AC trước khi đổi hàng cuối màn (hạng mục 7)

Đọc thẳng `requirements.md`: **AC-20 nói về dòng "từ kỹ năng" của nhánh tự
làm, không nói về liên kết khoá vị trí.** Không AC nào quy định hình dạng hàng
cuối màn, nên đổi nó sang hàng bấm được kiểu thẻ chỉ đụng câu chữ Phần D —
đúng phạm vi quyết định neo. Ràng buộc thật sự ở đây là AC-24/SC-5 (không ngõ
cụt), nên hàng này khi bấm sẽ hiện thông báo ngắn nêu cả hai bề mặt R-13, theo
đúng cách thanh quick-entry của màn (1) trả lời cho ô chưa dựng.

### Sửa F1 (slice-P7, MAJOR) — AC-14 vế 2

`gift_idea_card.dart` chỉ vẽ dòng căn cứ cho nhánh tự làm, vì `_skillLabel()`
chỉ soi `GiftContextKind.skill`. Mọi gợi ý khớp sở thích hoặc khớp dịp đều im
lặng, trong khi AC-14 vế 2 đòi **mọi** gợi ý riêng-hoá phải nói căn cứ do
người dùng nhập. Đã tổng quát hoá thành `_ProvenanceLine` đọc
`suggestion.matches`: skill → "từ kỹ năng: …", interest → "từ sổ tay: …",
event → "từ dịp bạn đã ghi: …". `_basis()` vẫn ưu tiên match kỹ năng cho ý
tưởng nhánh tự làm, nên AC-20 giữ nguyên câu chữ cũ. Gợi ý không khớp gì thì
vẫn không có dòng nào (không bịa căn cứ). `uiux-spec.md` Phần D mục 3 — vốn
giới hạn dòng căn cứ ở nhánh handmade và vì thế tự mâu thuẫn với Phần E — đã
được vá theo hành vi đúng này.

### Bẫy đã vướng: cổng số nguyên của luồng quà

`gift_content_gate_test.dart` cấm **mọi** literal số nguyên trần dưới
`lib/features/gift_ideas/`, kể cả số không liên quan gì tới pack. Lượt cài đặt
đầu tiên đỏ 8 chỗ: `0` của `notebookRowCount`, `index == 0`/`index > 0` của
vòng lặp danh sách, và các `size:`/`_diameter` 36/28/18/16. Cách sửa giữ đúng
tinh thần gate chứ không né gate:

- `notebookRowCount: int` → `notebookRowLabels: List<String>`, dải "dựa trên"
  đọc `.isNotEmpty`/`.length` từ chính các dòng người dùng đã viết.
- `visible.indexed` + so sánh index → `identical(suggestion, visible.first)`.
- mọi số đo → token `CupidSpacing` (`xl`/`lg`/`md`). Đã tra
  `lib/design_system/tokens`: không có token cỡ icon riêng, nên thang spacing
  là nguồn hợp lệ duy nhất.

### Glyph mới

Ba codepoint đọc ra từ cmap của `MaterialSymbolsRounded-Variable.ttf` đang
bundle (fontTools), không đoán: `close`/0xe5cd, `help`/0xe887,
`handyman`/0xf10b. Đã mở cả ba capture xem bằng mắt — không có ô tofu nào.

### Test mới

`gift_ideas_screen_test.dart` thêm: hàng đoán ở cuối màn nằm dưới mọi thẻ và
bấm được (2 case), thẻ dẫn đầu đầy đủ / thẻ sau dạng gọn, nút tròn của thẻ gọn
đẩy về hub y như pill, nhóm `bỏ qua một gợi ý` (2 case: `×` chỉ ở thẻ dẫn đầu;
bấm thì thẻ rơi ra, thẻ kế tiếp lên dạng đầy đủ, và không ghi gì xuống), nhóm
`dải "dựa trên" dưới bộ lọc` (2 case), và case AC-14 "mọi gợi ý riêng-hoá đều
nêu căn cứ, không riêng nhánh tự làm". Case "một nút mỗi thẻ" viết lại thành
một key `gift_idea_add_<id>` mỗi thẻ + đúng một `ElevatedButton` toàn màn.

### Commands

| Lệnh | Kết quả |
|---|---|
| `flutter test test/features/gift_ideas` | `+100 ~1: All other tests passed!` |
| `flutter test test/features/activity_cards test/features/context_notebook` | `+303 ~6: All other tests passed!` |
| `flutter test test/features/gift_ideas test/features/activity_cards test/features/context_notebook` | `+403 ~7: All other tests passed!` — 403 passing, 7 skipped, 0 failures |
| `flutter analyze lib test` | `222 issues found.`, exit 1, **0 error-level** — bằng đúng baseline 222/0, không lint mới |
| `flutter test test/features/gift_ideas/gift_ideas_screen_test.dart --dart-define=CAPTURE_VISUALS=true` | `+30: All tests passed!` — render lại 3 capture màn (5) |

Cả năm lệnh chạy với `PATH="$HOME/flutter/bin:$PATH"` trong `mobile/`.

### Ghi chú cho Reviewer

- Hạng mục VF 4 (số nhánh) và 5 (nhãn bậc công sức) **cố ý không đổi**. Xem
  `visual-fidelity-report.md` §P7 mục "Items 4 and 5". `gift_taxonomy.v1.json`
  không bị đụng tới trong vòng này.
- F3 (`story_master.md` thiếu màn 5 trong Design-Screen) và F5 (waiver runtime
  smoke) thuộc Scrum Master, không đụng ở lane này.

## Vòng vá F6 — AC-33 quay vòng sau khi bỏ qua (2026-09-11)

- Lane: Mobile
- Date: 2026-09-11
- Phạm vi: đúng ba file mà `review/review-report.md` §"Required patch scope for
  F6" liệt kê. Không đụng `gift_selector.dart`, `gift_selector_test.dart`,
  `_FilterChipRow`, hay hai hạng mục pack-driven được bảo vệ.

### Lỗi

`dismissedGiftIds` chỉ lớn lên: `_rank` mang nó qua mọi lần xếp hạng và
`visibleSuggestions` lọc bỏ vô điều kiện, không có gì xoá nó ngoài việc huỷ
cubit. Bỏ qua đủ số thẻ trong một phiên là màn hình nói `gift_ideas_no_match`
— tức là "chưa có ý tưởng nào khớp bộ lọc này" — trong khi kho vẫn còn ý
tưởng. AC-33 (`requirements.md:236-242`) cấm đúng trạng thái đó với **mọi N**,
và AC-18 (`:160-162`) còn bị hạ ngưỡng xuống *một* lần bỏ qua: dismissal sống
qua lần đổi bộ lọc, nên một nhánh hẹp chỉ có một mục khớp cũng rỗng theo.

### Cách vá

Nối dây `GiftSelector.nextBatch` — cơ chế quay vòng tất định đã có sẵn và đã
xanh ở `gift_selector_test.dart:397-441` nhưng **chưa có caller nào trong
`lib/`**:

- `GiftIdeasState` thêm `roundStartGiftId` (`String?`, mặc định null): điểm mở
  đầu của vòng hiện tại. Là **id chứ không phải chỉ số** vì cổng nội dung của
  luồng quà cấm mọi literal số nguyên trần dưới `lib/features/gift_ideas/`
  (BR-17) — bản cài đặt đầu dùng `int cursor` và bị
  `gift_content_gate_test.dart` bắt ngay ở `cursor: 0`. Vòng đời màn hình,
  không ghi xuống đâu cả (`architecture/contract-summary.md` §6).
- `_startingAtRound(round)` xoay danh sách về `roundStartGiftId` bằng
  `nextBatch`; khi không có điểm mở đầu, hoặc điểm mở đầu không nằm trong danh
  sách (đúng cảnh sau khi đổi bộ lọc), nó trả nguyên danh sách.
- `visibleSuggestions` rơi về **toàn bộ** danh sách đã xếp hạng khi mọi mục
  của nó đã bị bỏ qua. Đây là chốt chặn cho AC-18: một nhánh có mục khớp thật
  không bao giờ vẽ ra rỗng. `suggestions` rỗng vẫn cho ra rỗng — đó là nhánh
  rỗng đã định của AC-34 và là đường duy nhất tới dòng no-match.
- `withDismissed` khi lần bỏ qua này sẽ vét sạch danh sách thì xoá tập đã bỏ
  qua và dời `roundStartGiftId` sang mục ngay sau mục dẫn đầu vòng vừa xong.
  Vòng mới là cả danh sách, xoay đi một chỗ: tất định, không lặp lại y hệt
  ngay, và `×` không bao giờ thành nút chết (AC-24).
- `gift_ideas_screen.dart` đọc điều kiện rỗng từ `state.suggestions.isEmpty`
  thay vì `visible.isEmpty`, nên dòng no-match chỉ còn một nguồn duy nhất là
  ca AC-34.

`GiftSelector.suggest` vẫn thuần: dismissal và vòng quay đều nằm ở tầng view
(AC-28). Không có kho thứ hai, không có gì được ghi xuống (AC-22/SC-1').

### Test mới (2 case, đã kiểm tra không rỗng nghĩa)

- `bỏ qua một gợi ý › waving every idea away wraps the round, it does not
  empty it`: bấm `×` đúng một lần cho **mỗi** mục đã xếp hạng — bản cũ chỉ có
  case bỏ qua đúng một thẻ. Mỗi bước khẳng định `gift-ideas-no-match` không
  xuất hiện và vẫn còn thẻ; sau vòng cuối, cả tập trở lại, thẻ dẫn đầu là
  `ranked[1]` và vẫn mang `×`; không có thẻ nào bị ghi xuống hub.
- `cubit đổi bộ lọc › dismissals carried into a narrower branch cannot empty it
  (AC-18)`: tìm nhánh hẹp nhất từ chính gói đã ship (không đặt tên cứng), bỏ
  qua hết các mục của nhánh đó khi đang ở danh sách rộng, rồi mới bấm chip
  nhánh. Khẳng định nhánh không rỗng và tập nhìn thấy đúng bằng tập đã xếp
  hạng của nhánh.

Đã chạy ngược để chứng minh test bắt được lỗi: tắt phần rơi-về trong
`visibleSuggestions` và nhánh wrap trong `withDismissed` thì case thứ nhất đỏ
(`Found 0 widgets with type "GiftIdeaCard"`) và case thứ hai đỏ
(`Expected: non-empty / Actual: []`). Bật lại thì cả hai xanh.

### Commands

| Lệnh | Kết quả |
|---|---|
| `flutter test test/features/gift_ideas/gift_ideas_screen_test.dart` | `+31 ~1: All tests passed!` |
| `flutter test test/features/gift_ideas/gift_selector_test.dart` (không sửa) | xanh, chạy kèm ở lượt gộp dưới |
| `flutter test test/features/gift_ideas` | `+102 ~1: All other tests passed!`, exit 0 — gồm `gift_content_gate_test.dart` |
| `flutter analyze --no-fatal-infos <3 file đã sửa>` | exit 0; 3 info `prefer_initializing_formals` ở dòng 182-184, là hàm dựng `GiftIdeasCubit` **không nằm trong diff**, tức có sẵn từ trước; 0 error, 0 warning |

Chạy với `PATH="$HOME/flutter/bin:$PATH"` trong `mobile/`. Baseline thư mục
`test/features/gift_ideas` là `+100 ~1`; `+102` là đúng hai case mới.

### Không đổi

Không đụng capture: thay đổi màn hình chỉ nằm ở điều kiện của dòng no-match,
không có trong ba ảnh `visual-fidelity/` của màn (5), nên không dựng lại ảnh.
