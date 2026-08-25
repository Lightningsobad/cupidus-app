# Phase P1 – Test Results

- Phase: P1 (`phase-P1-home-quick-grid-zodiac-tile.md`)
- Lane: Mobile
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-011_zodiac_red_flag_and_home_quick_grid_completion-STORY-002_home_quick_grid_zodiac_tile`
- BaseHead: `72412218d782eee89f2284282ac6eb5ce5957297`
- Date: 2026-08-25

## 1. `auto_awesome` codepoint

Confirmed codepoint: **`0xe65f`** — single codepoint, no alias.

Read from the bundled font's cmap with `fontTools`, per the convention at
`cupid_icons.dart:9-11`. Not copied from Flutter's `Icons` class, not guessed.

Command (run from `mobile/`):

```bash
python3 -c "
from fontTools.ttLib import TTFont
f = TTFont('assets/fonts/MaterialSymbolsRounded-Variable.ttf', lazy=True)
best = f.getBestCmap()
rev = {}
for cp, name in best.items():
    rev.setdefault(name, []).append(cp)
print('auto_awesome', [hex(c) for c in rev.get('auto_awesome', [])])
for n in sorted(rev):
    if 'auto_awesome' in n:
        print(n, [hex(c) for c in rev[n]])
"
```

Output:

```text
auto_awesome ['0xe65f']
auto_awesome ['0xe65f']
auto_awesome_mosaic ['0xe660']
auto_awesome_motion ['0xe661']
```

Alias check — the neighbouring `CupidIcons` entries document whether a second
codepoint resolves to the same outline, so the glyph outlines were hashed with a
`RecordingPen` rather than compared by name:

```text
glyph name for 0xe65f: auto_awesome gid 4944
codepoints mapping to that glyph name: ['0xe65f']
same-outline codepoints: [('0xe65f', 'auto_awesome')]
```

No alias, and the two adjacent codepoints (`0xe660` `auto_awesome_mosaic`,
`0xe661` `auto_awesome_motion`) are distinct glyphs. Recorded in the doc comment
at `mobile/lib/design_system/icons/cupid_icons.dart:230-235`.

## 2. Targeted test run

Command (from `mobile/`, `PATH="$HOME/flutter/bin:$PATH"`):

```bash
flutter test test/features/home/home_quick_grid_test.dart \
             test/features/reminders/reminder_entry_point_test.dart
```

Result: **PASS (exit 0) — `00:01 +7: All tests passed!`**

The new suite was also re-run on its own as the final gate:

```bash
flutter test test/features/home/home_quick_grid_test.dart
```

Result: **PASS (exit 0) — `00:00 +6 ~1: All tests passed!`** (the `~1` skip is
the `CAPTURE_VISUALS`-gated capture test in §4, which is off by default).

New suite `mobile/test/features/home/home_quick_grid_test.dart` (6 always-on
tests + 1 capture-gated):

| Test | Covers |
|---|---|
| `AC1: both quick-grid tiles live in one Row as equal-width Expanded children, at the list position the Synced Alarm card held, with _cardGap above and below` | AC1 layout |
| `AC1: the zodiac tile carries the peach auto_awesome plate, the locale-invariant title and a single-line ellipsized subtitle` | AC1 tile internals |
| `AC1: the title literal is identical in `en`` | UX §3.2 locale-invariant title |
| `AC2: tapping the zodiac tile resolves the named route to ZodiacRedFlagScreen` | AC2 navigation |
| `Regression: the reshaped Synced Alarm tile keeps its key, copy, glyph and ReminderScheduleScreen destination` | Synced Alarm regression |
| `Accessibility: each tile is one button node labelled "<title>. <subtitle>" with a tap target no shorter than the platform minimum` | UX §5 |

### Required assertion evidence

AC1 layout assertion — one shared `Row`, equal width, 12px gap, preserved list
position with `_cardGap` (13) below:

```dart
final Finder sharedRow = find.ancestor(
  of: reminderTile,
  matching: find.byType(Row),
);
final Finder rowWithZodiac = find.descendant(
  of: sharedRow.first,
  matching: zodiacTile,
);
expect(rowWithZodiac, findsOneWidget);

final Rect reminderRect = tester.getRect(reminderTile);
final Rect zodiacRect = tester.getRect(zodiacTile);
expect(reminderRect.width, moreOrLessEquals(zodiacRect.width));
expect(reminderRect.top, moreOrLessEquals(zodiacRect.top));
expect(zodiacRect.left - reminderRect.right, moreOrLessEquals(12));

final Rect dreamJarRect = tester.getRect(
  find.byKey(const Key('home_dream_jar_entry_card')),
);
expect(dreamJarRect.top - reminderRect.bottom, moreOrLessEquals(13));
```

AC2 navigation assertion:

```dart
expect(find.byType(ZodiacRedFlagScreen), findsNothing);

await tester.tap(find.byKey(const Key('home_zodiac_entry_tile')));
await tester.pumpAndSettle();

expect(find.byType(ZodiacRedFlagScreen), findsOneWidget);
```

The harness carries the same `routes:` entry as `cupid_app.dart:68-71`, per the
phase's stated trap — a bare `HomeScreen` under a route-less `MaterialApp`
throws "Could not find a generator for route" on that tap.

### Task 8 — `reminder_entry_point_test.dart`

**No edit required.** That suite asserts only key resolution plus tap behaviour
(`reminder_entry_point_test.dart:148-154`: `find.byKey(const
Key('home_reminder_entry_card'))`, `tester.tap`, then `expect(find.byType(
ReminderScheduleScreen), findsOneWidget)`). It carries no assertion on the old
full-width shape, so it passes unmodified against the reshaped tile. It is left
byte-for-byte unchanged, and the file is absent from the diff.

### Environment note

This worktree was checked out without `lib/l10n/generated/`, so the first test
run failed with `Error when reading 'lib/l10n/generated/app_l10n.dart': No such
file or directory` across the whole app. Resolved by running `flutter gen-l10n`
once from `mobile/` before the suites; the generated tree is gitignored and does
not appear in the diff.

## 3. Static analysis / build gate

Command (from `mobile/`):

```bash
flutter analyze lib test --no-fatal-infos
```

Result: **PASS (exit 0) — 0 errors, 0 warnings.** 75 pre-existing `info`-level lints
(`prefer_initializing_formals`, `use_null_aware_elements`,
`deprecated_member_use`) in files outside this phase's write scope. Grepping the
full analyzer output for `home_screen.dart`, `cupid_icons.dart`,
`home_quick_grid_test.dart`, and `reminder_entry_point_test.dart` returns **no
matches**, so this diff introduces zero new analyzer issues.

Bare `flutter analyze` (no path args) additionally walks
`build/ios/SourcePackages/checkouts/flutterfire/**` — vendored FlutterFire
example/dartpad sources that were already failing analysis in this worktree
before any edit here (`Target of URI doesn't exist:
'package:cloud_firestore/cloud_firestore.dart'`). That is untracked build
output, unrelated to this phase; the gate above is therefore scoped to `lib`
and `test`.

`--no-fatal-infos` sets the gate threshold at errors and warnings. `flutter
analyze` exits non-zero on any `info` lint, and all 75 here are pre-existing
`info` lints in files this phase does not touch, so without the flag the command
reports failure for issues that predate this diff. The errors/warnings count is
0 either way.

## 4. AC1 visual inspection

Capture: `coding-plan/home-quick-grid-vi-dark.png`
(412x915, Android reference viewport, `devicePixelRatio: 1`).

Produced by the `CAPTURE_VISUALS`-gated test at the end of
`home_quick_grid_test.dart`, mirroring the existing
`test/features/reminders/visual_capture_support.dart` precedent:

```bash
flutter test test/features/home/home_quick_grid_test.dart \
  --dart-define=CAPTURE_VISUALS=true
```

Result: `00:06 +7: All tests passed!`

### Splash-frame trap confirmation

The phase's §6 trap is that a splash/loading frame silently invalidates the
comparison. The capture test asserts the rendered frame **before** it encodes the
image, so a splash frame fails the test instead of being written:

```dart
expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
expect(find.byKey(const Key('home_reminder_entry_card')), findsOneWidget);
expect(find.byKey(const Key('home_zodiac_entry_tile')), findsOneWidget);
```

Visually confirmed on the written PNG as well: it shows the couple hero header
("Minh / Cùng thành phố"), the `247 ngày bên nhau` counter, the milestone pill,
and the full card column — i.e. the real Home dashboard, not a splash or
loading frame. The capture is taken from `HomeScreen` directly (the same widget
`main_preview.dart`'s `'home'` canvas builds, with the same
`PREVIEW_HOME_FIXTURE` profile values), so the splash route is never on screen.

### Comparison against the design source Home node (dark theme + `vi`)

- Two equal-width tiles occupy one row at the list position the full-width
  Synced Alarm card previously held — between the Daily Vibe card above and
  `Hũ Ước Mơ` (Dream Jar) below, with the shared 13px `_cardGap` on each side.
- Left tile: amber 38x38 plate at alpha 0.2 holding the
  `notifications_active` bell, title `Nhắc nhở đồng bộ`, subtitle
  `Nhắc trên cả hai máy`. Copy, glyph and destination unchanged from the
  previous full-width card.
- Right tile: peach 38x38 plate holding the `auto_awesome` sparkle — the glyph
  rasterizes as the four-point sparkle, which visually confirms `0xe65f` is the
  right cmap entry and not a fallback box. Title `Zodiac Red Flag`, subtitle
  `Xem chỉ số xung đột hôm …` correctly ellipsized to one line.
- Both tiles are the same height, share `radiusCard` corners, `colorSurface`
  fill and the card-consistent `elevationShadow`.

Capture-harness caveat (not a regression): the `Chi tiêu chung` and
`Thư viện ảnh` cards render their glyphs as empty boxes in this PNG. Those two
cards use Flutter's own `Icons` class rather than `CupidIcons`, and a widget
test ships no asset bundle, so only the four fonts loaded by `_loadDesignFonts`
rasterize. Both cards are outside this phase's write scope and are unchanged in
the diff.

## 5. Diff scope (AC4)

```text
 M mobile/lib/design_system/icons/cupid_icons.dart
 M mobile/lib/features/home/presentation/home_screen.dart
?? mobile/test/features/home/home_quick_grid_test.dart
?? data/requirements/.../coding-plan/home-quick-grid-vi-dark.png
```

`git diff --stat 72412218` → 2 files changed, 149 insertions(+), 39 deletions(-).

No Dream Jar, Anti-Ghosting, tab-bar/`app_shell.dart`, or `ZodiacRedFlagScreen`
(screen/cubit/data) change appears in the diff. `_ReminderEntryCard` is deleted
and unreferenced; the one remaining dartdoc reference to it
(`home_screen.dart:1033`) now points at `[_QuickGridTile]`, so no dead widget
and no broken doc reference is left behind.

## 6. Status

- Status: COMPLETE
- Last updated: 2026-08-25
