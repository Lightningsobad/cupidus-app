## Story Runtime Startup Smoke

- Runtime Id: backend-api
- Registry: data/devops/system/runtime-command-registry.json
- Reason: `guard-parallel-spawn.sh` refused to spawn Alex-Mobile-Dev for this
  story's Phase P1 with "no declared service runtime is running" even though
  Phase P1 itself declares `Runtime startup smoke: NO`. This section satisfies
  that blanket repo-level spawn-guard precondition; it is not a Phase P1 test
  result.
- Command: `npm run start:dev` in `backend/`, `PORT` sourced from
  `DEVSTACK_PORT_API` in `.env.devstack` (shared devstack tenant `cupid_apps`,
  reserved port 21020 per `sharedInfra.reservedPorts.api`)
- Ready Check: `GET http://127.0.0.1:21020/api-docs-json` expecting HTTP 200
- Result: PASS (HTTP 200, valid OpenAPI JSON body returned; process listening
  on `*:21020`, backend `[NestApplication] Nest application successfully
  started` logged)
- Shutdown: PASS (SIGTERM to the nest dev process; process exited within 2s;
  port 21020 confirmed free afterward)

Notes:
- Worktree-local setup performed to make this runnable: `backend/node_modules`
  installed via `npm ci` (worktrees do not share installed dependencies), and
  two pre-existing local secrets/generated files copied from the control
  checkout into this worktree since git worktrees do not carry untracked
  files: `backend/service-account.json` (pre-supplied Firebase Admin
  credential, not generated) and `.env.devstack` (devstack-generated env
  contract for the same shared `cupid-apps` tenant; `devstack use --check`
  confirms this worktree resolves to the same adopted tenant as the control
  checkout, and `devstack port check` showed no conflicts before starting).
- This smoke does not leave backend-api running; per the handoff, only proof
  it can start and answer ready was required.

## Phase P1 — Content Pack And Gate (Mobile)

All commands run from the story worktree's `mobile/` directory on
`codex/REQ-016_solo_stage1_relationship_assistant-STORY-011_zodiac_quiz_shell`.

### Targeted tests

- Command: `flutter test test/features/zodiac_shell/`
- Result: PASS (67/67 — 46 gate tests, 21 parser/schema tests)
- Covers: shipped packages parse under their contract schema id, mapping keys
  decompose into `questions_per_round` tokens, N read only from
  `ContentPackage.length`, parser rejections, gate rules one control per rule,
  time-gating key refusal per key in `zodiacTimeGatingKeys`, lexical delegation
  to `core/content/invariant_terms.dart`, input-side probe refusal in question
  prompts, and the offline/content-free source scans (AC-22/AC-23/R-15a).

### Regression

- Command: `flutter test test/core/content/`
- Result: PASS (15/15, unchanged — the shared `ContentPackage` parser was reused
  verbatim, not modified)
- Combined confirmation run: `flutter test test/features/zodiac_shell/
  test/core/content/` — PASS (82/82)

### Static analysis

- Command: `flutter analyze lib/features/zodiac_shell test/features/zodiac_shell`
- Result: PASS (`No issues found!`)
- Scoping note: the repository-wide `flutter analyze lib test` baseline is
  non-zero (pre-existing warnings, 0 errors), so analysis is scoped to the
  Phase P1 write scope. Delta introduced by this phase: 0 issues. One
  `unnecessary_import` (`dart:typed_data`) raised on the first run was fixed
  before this result.

### Contract deviation recorded

- `architecture/contract-summary.md` §1 sketches the package envelope key as
  `"schemaId"`, but the same section mandates reusing
  `core/content/content_package.dart` verbatim, and `ContentPackage.parse`
  reads `schema_id`. The shipped packages therefore use `schema_id`; the §2
  schema id *values* (`req016.zodiac_quiz.v1`, `req016.zodiac_outcomes.v1`) are
  matched exactly.

### Notes

- `mobile/pubspec.yaml` already declares the `assets/data/req016/` directory, so
  both new packages bundle with no pubspec change (no edit was made to it).
### Design reference resolved (design-side only)

- `Design-Screen: 7-vo-hoang-dao-3-viec` — resolved by this lane and recorded in
  `story_master.md`; no `Design-Screen:` line had been written before.
- Enumerated first, never guessed:
  `node .ai-team-bundle/runtime/tools/render-design-canvas.js
  --surface=cupid-ch-ng-1 --list-screens`
- Rendered:
  `node .ai-team-bundle/runtime/tools/render-design-canvas.js
  --surface=cupid-ch-ng-1 --screen=7-vo-hoang-dao-3-viec --platform=ios
  --out=<story-dir>/visual-fidelity`
  → `DESIGN_CANVAS: OK .../visual-fidelity/design-reference-7-vo-hoang-dao-3-viec-ios.png 415x900`
- Confirmed by looking, not by string match. The render is the "Cung & trắc
  nghiệm" screen and it corroborates the P1 data contract: a self-addressed
  insight, an `about_other` block whose ask line renders as a quoted question
  (AC-15), exactly three suggestion cards each with a title plus a meta note
  (AC-4/BR-2 → `minimumSuggestionsPerOutcome`), and a closing disclaimer with no
  percentage, score, or verdict anywhere (AC-13/AC-14). Candidate
  `tro-doan-khong-thang-thua` was rejected: it is the guessing game, not this
  result surface.

- Visual fidelity: the *implemented* side is NOT_APPLICABLE for this phase —
  P1 ships data and domain code only, no widget. `implemented-*.png` and
  `visual-fidelity-report.md` belong to Phase P3 (result surface screens), which
  now has its design reference in place rather than building blind. This phase
  deliberately wrote no `VISUAL_FIDELITY:` verdict: there is nothing rendered to
  compare yet, and a typed token without a capture is exactly what the gate
  exists to refuse.

## Phase P2 — Deterministic Session (Mobile)

Run at: 2026-09-24 · Worktree:
`.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-011_zodiac_quiz_shell`

### Commands and results

| Command | Result |
| --- | --- |
| `flutter test test/features/zodiac_shell/` | 45/45 PASS |
| `flutter analyze lib/features/zodiac_shell lib/features/activity_cards/domain/activity_card.dart test/features/zodiac_shell` | `No issues found!` (3 items) |
| `flutter test test/features/zodiac_shell/ test/features/activity_cards/` | `+457 ~5: All other tests passed!` (0 failures, 5 pre-existing skips) |

Breakdown of the 45: `zodiac_shell_resolver_test.dart` 16,
`zodiac_rotation_store_test.dart` 15, `zodiac_shell_cubit_test.dart` 14.

`flutter analyze` is scoped to this phase's write scope on purpose: the
repository baseline is non-zero (222 pre-existing warnings, 0 errors), so a
whole-tree run can never read as a pass/fail signal. The delta this phase adds
is zero.

A fresh worktree needs `flutter gen-l10n` before any test that transitively
imports a screen; `zodiac_shell_cubit_test.dart` does, through
`context_notebook_entry_point.dart`. The generated `lib/l10n/generated/` stays
untracked.

### Required assertion evidence

- **Deterministic repeat (AC-21)** —
  `zodiac_shell_resolver_test.dart` "the same set, answers and notebook resolve
  identically every time" resolves the same round five times and asserts one
  distinct outcome id and one distinct suggestion-id sequence.
  `zodiac_shell_cubit_test.dart` "the same answers land on the same outcome on a
  later round" repeats that against the shipped assets *after* the rotation
  cursor has advanced, which is the assumption `solution.md` §3 records: the
  cursor picks questions and never reaches the mapping.
  A second test scans every `.dart` under `lib/features/zodiac_shell/` for
  `DateTime.now`, `Random(`, `Random.secure` and `Stopwatch` and requires none —
  the determinism claim holds for files added later, not just today's.
- **Wrap-around (AC-32)** — `zodiac_rotation_store_test.dart` runs a 7-question
  set for 16 rounds and asserts rounds 8-14 repeat rounds 1-7 in the same order;
  a 5-question set with a 2-question round is asserted to return `[4, 0]` across
  the seam; N=1 returns `[0]` forever rather than running out. The shipped
  `zodiac_quiz.v1.json` cannot exercise any of this — every set ships exactly
  `questions_per_round` questions today — so these run on fixtures, and a
  separate case pins the shipped shape (round == set length repeats).
- **Append-only enum** — the P2 change to `ActivityCardOrigin` is an append;
  `activity_card_test.dart`'s own "the four earlier values keep their positions"
  assertion still passes, and `cubit` test "the card carries the zodiac origin,
  the idea status and the suggestion title" pins `zodiac_shell` end to end
  through `createCard`.

### A tail-freeze the append had to retire

Appending `zodiacShell` broke exactly one assertion elsewhere,
`mobile/test/features/activity_cards/activity_card_test.dart:53`:

`expect(ActivityCardOrigin.values.last, ActivityCardOrigin.dateScript);`

That line pinned the *tail* of an enum whose own contract is append-only, so it
was guaranteed to break on the next append — the very thing the two lines above
it exist to allow ("append-only: the four earlier values keep their positions",
still passing). It now asserts `date_script`'s own index instead, which is what
append-only actually promises and what survives STORY-012's append too. A new
case pins `zodiac_shell`'s wire value and its position behind `date_script`.

Verified as the only breaking assertion before touching anything:
`activity_card_status_test.dart:29` iterates all values without pinning the
tail, and `conversation_starters/calendar_event_service_test.dart:418` pins only
the first five. The file is inside this run's registered `write_scope`.

### Design notes worth carrying into P3

- `ZodiacShellState` has no question index and no round length. A progress bar,
  a "câu 2/5", or a "đã hết" line is not merely unrendered — it cannot be built
  from this state (AC-18/AC-19/AC-31). P3 should not add one.
- The rotation cursor is stored already reduced modulo the set length, so the
  number on disk is a position, never a tally. "How many have I played" is
  unanswerable from storage, not just unexposed.
- `ZodiacShellCubit.undoAddToCards` lives here, not in P3, because P3's write
  scope holds only screens/widgets/arb/tests and its 5-second undo snackbar
  needs a door to delete the card it just created.
- Notebook enrichment folds free text to the packs' ASCII tag vocabulary
  (lowercase, Vietnamese diacritics folded, contiguous runs of up to three
  words joined by `_`). No such helper existed in the repository. Punctuation
  ends a phrase so `cà phê, sách` cannot invent `phe_sach`; spaces do not. A
  notebook that throws — the signed-out case, since the notebook door needs a
  resolved backend user id — is treated exactly like an empty one, and never
  reaches a state P3 could render as an error (AC-25/BR-4).

## Phase P3 — Result Surface And Screens (Mobile)

Run at: 2026-09-24 · Worktree:
`.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-011_zodiac_quiz_shell`

`flutter gen-l10n` was run first, as required after the two `.arb` edits.

### Commands and results

| Command | Result |
| --- | --- |
| `flutter test test/features/zodiac_shell/zodiac_result_surface_test.dart` | 10/10 PASS |
| `flutter test test/features/zodiac_shell/zodiac_shell_screen_test.dart` | 12/12 PASS (+2 capture tests skipped without the flag) |
| `flutter test test/features/zodiac_shell/ --concurrency=1` | `+134 ~2: All other tests passed!` (0 failures) |
| `flutter test test/features/activity_cards/ --concurrency=1` | `+345 ~5: All other tests passed!` (0 failures, 5 pre-existing skips) |
| `flutter analyze lib/features/zodiac_shell lib/l10n test/features/zodiac_shell` | `No issues found!` (3 items) |
| `flutter test test/features/zodiac_shell/zodiac_shell_screen_test.dart --dart-define=CAPTURE_VISUALS=true` | 14/14 PASS, 2 PNGs written |

`flutter analyze` stays scoped to this phase's write scope on purpose: the
repository baseline is non-zero (222 pre-existing warnings, 0 errors), so a
whole-tree run can never read as a pass/fail signal. The delta this phase adds
is zero. One `unnecessary_import` raised on the first run was fixed before the
result above.

The zodiac suite is run with `--concurrency=1` because the default parallel
reporter interleaves output from seven files and a single failure scrolls out
of reach.

### Required assertion evidence

- **Every shipped outcome, not a sample** — `zodiac_result_surface_test.dart`
  loads `zodiac_outcomes.v1.json` off disk and loops all 27 shipped outcomes
  for: exactly `minimumSuggestionsPerOutcome` cards, the insight present, one
  and only one `Scrollable` in the tree, cards as descendants of the result
  surface, and no `ExpansionTile`/`ExpansionPanelList`. A verdict can therefore
  not ship alone (SC-2/BR-2) for any outcome an author writes, not just the
  ones a fixture happens to name.
- **Block order proved by geometry** — the same file asserts
  `insight.dy < askBlock.dy < subheading.dy < firstCard.dy` with
  `tester.getTopLeft`, rather than asserting that four widgets merely exist.
- **The ask block is conditional, both ways** — present with its exact
  `ask_line` text and the guess-provenance eyebrow for all three `about_other`
  outcomes; absent for all 24 others. Asserting only the positive half would
  pass on a screen that draws the block unconditionally.
- **Display bans scanned, not eyeballed** — every `Text` of every outcome is
  scanned for `%`, and `LinearProgressIndicator`/`CircularProgressIndicator`/
  `Slider` are asserted absent (AC-13/AC-14/AC-19). On the picker, every `Text`
  is scanned for "mở khoá"/"chuỗi" and for the `n/m` shape (AC-18/AC-19).
- **The 5-second undo, measured** — `zodiac_shell_screen_test.dart` reads the
  `SnackBar` widget and asserts `duration == Duration(seconds: 5)` and a
  non-null action; the undo tap is then asserted to delete exactly the card id
  that was just created, and a following add still lands.
- **Card contract** — `origin: ActivityCardOrigin.zodiacShell`,
  `status: ActivityCardStatus.idea`, title equal to the suggestion title, and
  no `AlertDialog` anywhere on the path (AC-7, §3.2).
- **Multi-select** — all three suggestions go to the store from one surface, in
  pack order, with the surface still mounted afterwards.
- **Leaving is free** — from the result, "Chọn lát khác" returns to the picker
  with an empty store and no snackbar (AC-10); mid-round, "Để khi khác" clears
  `set`/`question`/`result` and re-entering asks a fresh question (AC-3).
- **Accessible name for a text-free button** — the `Semantics` label
  `zodiac_shell_add_to_my_store_action` is counted on the tree and must appear
  once per card.

### `.arb` scope

11 keys added to `app_vi.arb` and `app_en.arb`, all chrome: screen title, guess
label, guess-provenance eyebrow, ask-block title, suggestions subheading, the
add action, the snackbar line and its undo, the two neutral exits, and the
positioning note. No quiz prompt, option label, insight, ask line, suggestion
title or note was copied out of the P1 packs — and the P1 gate proves it: its
`no shipped wording lives in a Dart file under the feature` scan runs green
against the two new source files.

### A P1 gate rule that bit the doc comments

`zodiac_shell_content_gate_test.dart`'s `no source writes down how many items a
package ships (R-15b)` matches the seed counts with
`RegExp('(?<![\\w.])$count(?![\\w.])')`. The quiz pack ships 10 sets, so a
*comment* citing `AC-10` or `R-10` matched — the digits are preceded by a
hyphen, which is not `\w`. Both citations were reworded to state the rule
instead of its id. The gate rule itself was not touched: it belongs to P1 and
sits outside this phase's write scope, and the false positive costs a comment
while the true positive it exists for costs a shipped constant.

### Visual fidelity

- Verdict: `VISUAL_FIDELITY: PASS` ·
  `Design-Screen: 7-vo-hoang-dao-3-viec` ·
  report: `visual-fidelity/visual-fidelity-report.md`
- Capture path: no Android/iOS device is attached to this machine (`adb
  devices` empty, `flutter devices` lists only macOS and Chrome) and the screen
  has no entry point until P4, so the repo's established
  `RepaintBoundary.toImage()` fallback was used inside the story's own widget
  test, building the real `ZodiacShellScreen` with the real theme, real
  background and disk-loaded packs.
- Frames: `implemented-7-vo-hoang-dao-3-viec-md.png` (415x900, the same frame
  as the reference) and `implemented-7-vo-hoang-dao-3-viec-md-chon-lat.png`
  (415x1100, the picker, which does not fit a phone frame).
- Both images were looked at, not just produced green: Vietnamese diacritics
  all land and every icon draws its glyph rather than a notdef box.
- Gate verified by running `.claude/hooks/lib/visual_fidelity.py --stage review
  --stack mobile` against this story directory (silent, exit 0), with a `/tmp`
  copy whose token was changed to `PASS_STATIC_ONLY` as the control — the
  control was rejected, so the pass is a real evaluation and not a no-op.

### Notes for P4

- `ZodiacShellScreen` registers nothing in the service locator: it builds its
  own `ZodiacShellCubit`, whose defaults already resolve the content loader,
  the rotation store and the card hub. P4 only needs a route that pushes it.
- `CupidHeader` renders the back control from `Navigator.canPop`, so the push
  from quick-entry slot 3 gets it for free; it is correctly absent in a capture
  where the screen is the harness `home`.

## Phase P4 — Entry Point Wiring (Mobile)

Run at: 2026-09-24 · Worktree:
`.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-011_zodiac_quiz_shell`

### Commands and results

| Command | Result |
| --- | --- |
| `flutter test test/features/zodiac_shell/zodiac_shell_entry_point_test.dart` | 8/8 PASS (+2 capture tests skipped without the flag) |
| `flutter test test/features/activity_cards/quick_entry_strip_test.dart` | 5/5 PASS |
| `flutter test test/features/zodiac_shell/ test/features/activity_cards/` | `+492 ~9: All other tests passed!` (0 failures, 9 skips) |
| `flutter test test/features/zodiac_shell/zodiac_shell_entry_point_test.dart --dart-define=CAPTURE_VISUALS=true` | 10/10 PASS, 2 PNGs written |
| `flutter analyze lib test` | 271 issues, **0 errors**, delta 0 — see below |
| `flutter build apk --debug` | `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` |
| `visual_fidelity.py --stage review --stack mobile --lane mobile` | exit 0 |

`flutter analyze` was run whole-tree this phase (`lib test`, as §6 of the phase
file requires) rather than scoped like P1-P3. The baseline is non-zero, so the
delta is established a different way: **no** issue line in the 271 names any of
the four files this phase created or edited, and the error count is 0. The
first run reported 272 — one `unused_import` of `zodiac_shell_entry_point.dart`
in this phase's own test, which was removed before the result above. The test
reaches the screen by tapping from the hub, so it never referenced the symbol.

The build command was run bare, with no `| tail` / `| grep` / redirect, so its
full output is on the record.

### Required assertion evidence

- **Navigation is proved from the hub, not from a direct push** —
  `zodiac_shell_entry_point_test.dart` mounts `ActivityCardHubView` with a fake
  `NavigatorObserver`, taps `activity_quick_entry_slot_2`, then asserts
  `find.byType(ZodiacShellScreen)` is on screen, `observer.pushed.last` is a
  `MaterialPageRoute<void>` (full-screen route, not a sheet), and the hub is
  gone. Asserting only that a route was pushed would pass on a route to the
  wrong screen.
- **Both hub surfaces route identically** — the same assertion runs against the
  populated hub and against the Minute-1 empty store, which is the first hub a
  new account sees. A cell wired in only one of the two states is the failure
  this pair exists to catch.
- **Back returns to the hub** — tapping `CupidIcons.arrowBack` on the pushed
  screen restores the hub. `tester.pageBack()` cannot be used: the app draws its
  own `CupidHeader` rather than a `CupertinoNavigationBar`/`AppBar` back button.
- **No gating, scanned rather than asserted by absence of a lock icon** — the
  source of `zodiac_shell_entry_point.dart` is read off disk, comment lines are
  stripped, and the remaining code is required to contain none of `Geolocator`,
  `premium`, `paywall`, `subscription`, `entitlement`, `onboarding`,
  `isUnlocked`, `isLocked` — **and no `if (` at all**. The comment-stripping is
  load-bearing: the file's own doc comment names the rules it does not
  implement, so an unfiltered scan would fail on itself. The same scan runs
  against `quick_entry_strip.dart`.
- **The placeholder branch is gone** — a scan requires the hub source to no
  longer contain `activity_quick_entry_coming_soon` and to contain
  `openZodiacShellScreen(context)`.
- **The forbidden direct imports are absent** — the hub source is matched with
  `RegExp(r'\bZodiacShellScreen\b')` (a plain `contains` is useless here:
  `openZodiacShellScreen` contains that substring), and against
  `ZodiacShellCubit` and `zodiac_shell/presentation`. It must import only
  `zodiac_shell_entry_point.dart`.
- **The module exposes exactly one symbol** — the entry-point source is matched
  for top-level declarations and must yield exactly one function, with no
  `export ` and no `class `. Unlike `gift_ideas`/`conversation_starters` this
  file deliberately carries no `export`, so the cubit, resolver, rotation store
  and packs stay unreachable from outside (AC-20).
- **Strip shape pinned independently** — `quick_entry_strip_test.dart` holds the
  three cells, their order, their labels and their glyphs; one handler call per
  tap asserted as `expect(selected, QuickEntryCell.values)`; no locked variant
  and no "Sắp có" text on slot 2; and the narrow-frame (280x400) branch scrolls
  horizontally with every cell still at least `kQuickEntryMinCellWidth` wide.

### A test that was written and then deleted

A case that pushed the screen and asserted `zodiac_picker_list` renders was
removed rather than fixed. The pushed screen's real `ZodiacShellCubit.load()`
does asset I/O that the widget test's fake-async zone never runs, and a
`tester.runAsync` delay did not help. P3's `zodiac_shell_screen_test.dart`
already proves pack loading against the real assets; the two from-hub push
tests already satisfy §6 of the phase file. Keeping a flaky third assertion
would have added no coverage.

### Visual fidelity

- Verdict: `VISUAL_FIDELITY: PASS` for the surface P4 owns ·
  report: `visual-fidelity/visual-fidelity-report.md` §P4
- Design screens resolved by `--list-screens` and rendered by `--screen=<slug>`,
  never `--label`: `tab-y-tuong-hub-cua-vao` (the canvas frame that actually
  draws the three entry points), plus `man-goc-muon-lam` and `phut-1-kho-trong`
  (the two hub states). New `Design-Screen:` lines were added to the report
  header alongside P3's.
- Capture path: still no device attached, so the P3 `RepaintBoundary` harness
  was reused inside this phase's own test —
  `implemented-man-goc-muon-lam-md-quick-entry.png` and
  `implemented-phut-1-kho-trong-md-quick-entry.png`, both 415x900.
- Both PNGs were opened and read, not merely produced green: "Vỏ hoàng đạo",
  "Gợi ý quà", "Mồi chuyện", "Bắt đầu từ một điều nhỏ nhé." and the surrounding
  card text all carry their diacritics, and the filled `auto_awesome` sparkles,
  `redeem` and `mood` glyphs all draw rather than a notdef box. No lock, no
  "Sắp có" badge, no dimming on slot 2 in either image.
- Gate control: the same `visual_fidelity.py` invocation pointed one directory
  too deep returned exit 1 with the "does not record `VISUAL_FIDELITY: PASS`"
  message, so the exit 0 above is a real evaluation and not a no-op.
- Recorded as deferred, not as a P4 defect: the canvas draws the three entry
  points as a vertical list with chevrons inside the Ý tưởng tab, while the
  shipped shape is a horizontal three-cell strip on the Muốn làm hub. That shape
  is STORY-001's and was already filled for slots 0 and 1 by STORY-004/005; P4
  may not change cell order, `kQuickEntryCellCount`, or the strip keys. The cell
  label "Vỏ hoàng đạo" also differs from the canvas row's "Cung & trắc nghiệm" —
  unchanged on purpose, because the label is AC-28-governed and "Cung & trắc
  nghiệm" is the *screen* title, which screen (7) already renders.

### Three stale placeholder tests retired

Removing the snackbar branch broke three pre-existing tests that asserted the
placeholder §3 is contracted to remove. All three failed with
`Found 0 widgets with key [<'activity_quick_entry_coming_soon'>]`:

| File | Line | Case |
| --- | --- | --- |
| `test/features/gift_ideas/gift_ideas_screen_test.dart` | 1166 | "the still-unfilled Minute-1 cell keeps the neutral message" |
| `test/features/gift_ideas/gift_ideas_screen_test.dart` | 1189 | "the still-unfilled cell answers with the neutral message" |
| `test/features/conversation_starters/conversation_starters_screen_test.dart` | 1000 | `ô cung hoàng đạo vẫn giữ câu trả lời "sắp có"` |

All three are stale by construction — each was written while STORY-011 was
unshipped — and the codebase already carried the precedent for retiring them at
`gift_ideas_screen_test.dart:1163`, where slot 1 left that list when STORY-005
shipped screen (6) and its regression moved to the owning story's suite. All
three were deleted and both precedent comments rewritten to name slot 2 and to
point at `test/features/zodiac_shell/zodiac_shell_entry_point_test.dart`, which
is where the replacement coverage lives. Nothing else in either file was
touched; the neighbouring "slot 0 / slot 1 reaches its own screen" assertions
still run and still pass.

A write-scope note, because the handoff prose and the registered run state
disagreed: the WriteScope list written in the handoff message names 8 paths and
does not include these two files, but `write_scope` in
`data/runtime/parallel-runs/RUN-REQ-016_solo_stage1_relationship_assistant-STORY-011_zodiac_quiz_shell-mobile-dev.json`
names 10 and does, at entries 5 and 6 (identically in `write_scope_normalized`
and `write_scope_raw`). That run file is this run — matching `agent_id`,
`tool_use_id` and a `registered_at` from the same spawn — and it is the record
the spawn guard enforces, so it governs. Scrum Master was told before the edit
and can revert these two files if the 8-path prose list was the intended grant.

Verification after the deletions:

| Command | Result |
| --- | --- |
| `flutter test test/features/gift_ideas/ test/features/conversation_starters/` | `+240 ~2: All other tests passed!` |
| `flutter test test/features/zodiac_shell/ test/features/activity_cards/ test/features/gift_ideas/ test/features/conversation_starters/` | `+732 ~11: All other tests passed!` |
| `flutter analyze lib test` | 271 issues, 0 errors, still no issue naming any file this phase touched |

### Worktree hygiene

`git status --porcelain` after the final test run showed
`STORY-002_invite_message_composer/visual-fidelity/implemented-11-chuan-bi-chon-hanh-dong-ios.png`
modified — the mobile suite rewrites that other story's PNG, exactly as it did
in P2 and P3. It was reverted with `git checkout --`, and the final status
contains only files inside this phase's declared write scope.
