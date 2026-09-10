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
