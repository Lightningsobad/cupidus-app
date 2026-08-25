# Story Review Report: STORY-002 Home Quick Grid — Zodiac Red Flag Tile

Outcome: PATCH_REQUIRED

- Scope gate: `review/scope-gate.md` (`SCOPE_GATE_COMPLETE: YES`)
- Requirement: REQ-011_zodiac_red_flag_and_home_quick_grid_completion
- Story: STORY-002_home_quick_grid_zodiac_tile
- Review mode: compact-story-review
- Story class: standard (mobile-only, single lane)
- Reviewer: Iris-QC
- Date: 2026-08-25
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-011_zodiac_red_flag_and_home_quick_grid_completion-STORY-002_home_quick_grid_zodiac_tile`
- Branch: `codex/REQ-011_zodiac_red_flag_and_home_quick_grid_completion-STORY-002_home_quick_grid_zodiac_tile`
- BaseHead (review diff baseline): `98420aaca21ed1734768bae2ad7bfb98769b111f`
- Worktree HEAD at review: `4023279c54a75833f07b7eb41ea31f61070295eb`

## 1. Diff scope

`git -C <Worktree> diff 98420aac --stat` — 11 files, 1364 insertions / 43
deletions. Source/test portion is exactly the three declared files:

```text
mobile/lib/design_system/icons/cupid_icons.dart                 |   6 +
mobile/lib/features/home/presentation/home_screen.dart          | 182 ++++++---
mobile/test/features/home/home_quick_grid_test.dart             | 405 ++++++++++
```

The remaining 8 paths are this story's own governing artifacts (story_master,
ux-spec, architecture/solution, coding-plan files, AC1 capture PNG). Working
tree is clean; no untracked strays.

## 2. Acceptance criteria

### AC1 — both tiles in the design's 2-column layout: PARTIAL (see F1)

Structure and tile internals verify cleanly against the UX spec and are
test-asserted. What is *not* established is the second half of AC1's wording —
the comparison "against `cupid-app-design-system`'s Home node ... with no
visible deviation." No design-side render exists and no measured comparison was
performed. See finding F1.

`_QuickGridRow` (`mobile/lib/features/home/presentation/home_screen.dart`)
renders one `Row` under `IntrinsicHeight` with two `Expanded` children and a
`SizedBox(width: _quickGridGap /* 12 */)` between them. It replaces the
`_ReminderEntryCard` call site at the identical list position (between the
Daily Vibe card and `DreamJarEntryCard`), with the pre-existing `_cardGap`
spacing preserved on both sides.

Tile internals match `ux/ux-spec.md` §3 literally: `padding: 16`,
`radiusCard`, `colorSurface`, `elevationShadow` on a `DecoratedBox` behind the
`Material` (correct — `Material`'s `borderRadius` form paints no `boxShadow`),
38x38 icon plate at `radiusSmall` with accent at `alpha 0.2`, glyph `size: 22`
at full-opacity accent, `SizedBox(height: 11)`, 14px/`w800` title in
`colorText`, `SizedBox(height: 3)`, 11.5px subtitle with `maxLines: 1` +
`TextOverflow.ellipsis`.

Independently confirmed by running the suite (see §5): the AC1 layout test
asserts nearest-common-`Row` containment of both keys, equal widths, equal
tops, a 12px inter-tile gap, and the 13px `_cardGap` to the Dream Jar card
below.

Visual evidence `coding-plan/home-quick-grid-vi-dark.png` (412x915, dark theme,
`vi`) inspected directly. It is the real Home frame, not a splash frame: couple
hero (`Minh` / `Cùng thành phố`), `247 ngày bên nhau` counter, milestone pill,
and the full card column are all painted. The quick-grid row shows the amber
bell tile `Nhắc nhở đồng bộ` / `Nhắc trên cả hai máy` beside the peach sparkle
tile `Zodiac Red Flag` / `Xem chỉ số xung đột hôm …` (correctly ellipsized to
one line), equal width, equal height, shared corner radius and fill. The
`auto_awesome` glyph rasterizes as the four-point sparkle, which corroborates
the `0xe65f` cmap lookup rather than a fallback box. The phase §6 splash-frame
trap is additionally closed mechanically: the capture test asserts
`home_screen_ready_signal` plus both tile keys *before* encoding the image, so
a splash frame fails rather than being written.

### AC2 — zodiac tile navigates to the STORY-001 screen: PASS

`Navigator.of(context).pushNamed(ZodiacRedFlagScreen.routeName)` using the
imported constant, not a literal route string. The AC2 test pumps a
`MaterialApp` carrying the same `routes:` entry `cupid_app.dart` registers and
asserts `find.byType(ZodiacRedFlagScreen)` goes from `findsNothing` to
`findsOneWidget` after the tap. Confirmed passing on my own run.

### AC3 — no new top-level entry point: PASS

The tile lives inside the already-reachable Home dashboard card list. No
`app_shell.dart`, tab-bar, or route-registration change appears anywhere in the
diff — verified against the full `--stat`, not just the evidence's claim.

## 3. Out-of-Scope / Option A resolution

The PO patch to `story_master.md` Out of Scope (commit `03ccf13`) carves out
Option A: the Synced Alarm tile's presentation container may be reshaped from a
full-width row into a half-width grid tile; content, behavior, and identity must
not change. Implementation matches that carve-out exactly:

- Key preserved: `Key('home_reminder_entry_card')` moved onto the reshaped tile.
- Copy unchanged: `context.reminderNotificationsRowTitle` /
  `context.reminderNotificationsRowSubtitle`.
- Glyph unchanged: `CupidIcons.notificationsActive`.
- Destination unchanged: same `MaterialPageRoute` push to
  `ReminderScheduleScreen`.
- Changed only as presentation, and only as UX §3.1 directs: glyph color
  `colorText` -> `colorAmber` accent, size 24 -> 22, container shape.

The regression test asserts all four preserved properties including the tap
destination, and I ran it. The pre-existing
`mobile/test/features/reminders/reminder_entry_point_test.dart` is byte-for-byte
unchanged (absent from the diff) and passes unmodified against the reshaped
tile — I ran it separately: `00:00 +1: All tests passed!` (exit 0).

`_ReminderEntryCard` is deleted, and the one surviving dartdoc cross-reference
was repointed to `[_QuickGridTile]`. No dead widget, no broken doc link.

## 4. Scope creep check: NONE FOUND

- Dream Jar and Anti-Ghosting remain full-width entry cards, not folded into
  any grid. Untouched in the diff.
- `ZodiacRedFlagScreen`, its cubit, and its data layer are untouched — STORY-001's
  surface.
- No tab-bar / navigation-structure change.
- No live or personalized Zodiac data on the tile; the subtitle is static teaser
  copy, as UX §3.2 requires.
- No other REQ-010 Home region (presence row, counter, hero caption, milestone
  pill, card rhythm, header actions, `--sky` backdrop) is modified.

## 5. Independent verification (re-run by reviewer, not quoted from evidence)

Targeted suite, from `<Worktree>/mobile` with `PATH="$HOME/flutter/bin:$PATH"`:

```bash
flutter test test/features/home/home_quick_grid_test.dart
```
-> `00:00 +6 ~1: All tests passed!` (exit 0). The `~1` skip is the
`CAPTURE_VISUALS`-gated capture test, off by default by design.

```bash
flutter test test/features/reminders/reminder_entry_point_test.dart
```
-> `00:00 +1: All tests passed!` (exit 0).

```bash
flutter analyze lib test --no-fatal-infos
```
-> `75 issues found. (ran in 1.4s)`, exit 0. All 75 are `info`-level
(`prefer_initializing_formals`, `use_null_aware_elements`,
`deprecated_member_use`); **0 errors, 0 warnings**. None of the 75 name
`home_screen.dart`, `cupid_icons.dart`, `home_quick_grid_test.dart`, or
`reminder_entry_point_test.dart` — this diff introduces zero new analyzer
issues. The implementation evidence's claimed PASS results are confirmed
accurate.

## 6. Accessibility

Each tile is wrapped in `Semantics(button: true, excludeSemantics: true,
label: '$title. $subtitle')`, matching the `_AntiGhostEntryCardChrome`
precedent named in UX §5, and constrained by
`BoxConstraints(minHeight: platformTokens.tapTarget)` so the whole tile — not
just the icon — is a single button node meeting the platform minimum. The
accessibility test asserts both semantic labels resolve and that the zodiac
tile's rendered height is `>= context.cupidPlatform.tapTarget`. Confirmed
passing.

## 7. Codepoint discipline

`CupidIcons.autoAwesome = IconData(0xe65f, fontFamily: fontFamily)`. The
evidence documents the codepoint being read from the bundled
`MaterialSymbolsRounded-Variable.ttf` cmap with `fontTools` per the
`cupid_icons.dart:9-11` convention, including a `RecordingPen` outline-hash
alias check confirming no second codepoint maps to the same outline, and that
the adjacent `0xe660` / `0xe661` are the distinct `auto_awesome_mosaic` and
`auto_awesome_motion` glyphs. The doc comment records all of it. This is the
required method, not a guess or an `Icons`-class copy. The capture's rendered
sparkle is independent corroboration.

## 8. Residual observations (non-blocking, no deferral against this story)

1. **Design source specifies 4 grid tiles, 2 are gridded.** The design's Home
   node grid holds Synced Alarm, Zodiac Red Flag, Dream Jar, and Anti-Ghosting.
   This story grids only the first two; Dream Jar and Anti-Ghosting stay as
   full-width entry cards. That is explicitly excluded by `story_master.md` Out
   of Scope and `ux/ux-spec.md` §6, and AC1's subject is the two named tiles, so
   AC1 is satisfied as written. Flagging for requirement-level integration
   review / future backlog consideration only — not a defect in this story.
2. **Evidence BaseHead differs from handoff BaseHead.** `test-results.md`
   records `72412218` (the mobile-dev spawn baseline, taken after the UX and
   plan docs were committed); this review used the handoff's `98420aac` (the
   story-branch baseline). `72412218` is not an ancestor of `98420aac`; the
   difference between them is docs-only (554 deletions across
   solution/master-plan/phase/ux-spec/story_master). The code diff is identical
   under both baselines — the evidence's "2 files changed, 149 insertions(+),
   39 deletions(-)" matches my own `lib` diff exactly. No code is unreviewed.
3. **Capture-harness glyph artifact.** In the PNG, the `Chi tiêu chung` and
   `Thư viện ảnh` cards render glyphs as empty boxes. Those cards are untouched
   in this diff, and the capture loads only the four fonts
   `_loadDesignFonts` registers, so this is a widget-test asset-bundle artifact
   of the capture harness, not a Home regression.

## 9. Findings

### F1 — PATCH_REQUIRED: story-level design-fidelity render+compare evidence is missing

**Observed.** This story has no `visual-fidelity/` directory. The only visual
artifact is `coding-plan/home-quick-grid-vi-dark.png`, a widget-test
`RenderRepaintBoundary` capture of the implemented side only. There is no
design-side render of the `cupid-app-design-system` Home node, no paired
comparison, and no `visual-fidelity/visual-fidelity-report.md` recording
`VISUAL_FIDELITY: PASS`.

**Why this is blocking rather than deferred.** AC1 is not written as "the tiles
sit in a Row"; it is written as a comparison — "when compared against
`cupid-app-design-system`'s Home node, then the quick grid shows both ... with
no visible deviation." A capture of only the implemented side cannot establish
"no visible deviation" from a design source that was never rendered alongside
it. My §2 AC1 assessment in the first pass of this review leaned on that
single-sided capture plus prose reasoning, which is precisely the "typed
verdict" this gate exists to reject. The correction is mine to make, and I am
making it: the structural half of AC1 is proven, the fidelity half is not.

**Precedent — this is a per-story omission, not a missing capability.**
STORY-001 in this same requirement, this same cycle, produced the full triple:

```text
STORY-001_zodiac_red_flag_screen/visual-fidelity/
  design-reference-zodiac-android.png     406x900
  implemented-zodiac-emulator-5554.png    405x900
  visual-fidelity-report.md               VISUAL_FIDELITY: PASS
```

REQ-010's Home stories did the same (`design-reference-home-android.png` +
`implemented-home-android.png` + report). The tooling, the `home` preview
canvas, and the recipe all already exist in this repository.

**Exact patch required (Mobile Developer).** Produce
`data/requirements/REQ-011_zodiac_red_flag_and_home_quick_grid_completion/STORY-002_home_quick_grid_zodiac_tile/visual-fidelity/`
containing a design-side render, an implemented-side device capture, and
`visual-fidelity-report.md` whose first line is `VISUAL_FIDELITY: PASS`.

Design side — the Home node, android / dark / vi, per REQ-010 STORY-004's
recorded entry (`Cupid App.dc.html` is the render entry; `Cupid Screens.dc.html`
is the screen library, not an entry):

```bash
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --surface=mobile --entry="Cupid App.dc.html" \
  --location=<worktree>/cupid-app-design-system \
  --screen=home --platform=android --theme=dark --lang=vi \
  --out=<story>/visual-fidelity
```

Implemented side — the `home` preview canvas, matching STORY-001's device
geometry so both images describe the same 411dp layout:

```bash
flutter build apk --debug -t lib/main_preview.dart \
  --dart-define=PREVIEW=home --dart-define=PREVIEW_HOME_FIXTURE=true \
  --target-platform android-arm64
adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-local-debug.apk
adb -s emulator-5554 shell am start -a android.intent.action.VIEW \
  -d "cupidpreview://screen/home" com.snapsofts.cupid
capture-mobile-screen.sh --out=<story>/visual-fidelity --label=home \
  --device=emulator-5554 --width=540 --density=210 --settle-ms=3000
```

Heed STORY-001's two recorded traps: capture only after the app has settled past
the Flutter splash (its 8s attempt still photographed the splash), and do not
omit `--density`, which silently renders at ~270dp and makes the comparison
meaningless.

The comparison must cover, at minimum, the two tiles' equal widths and the 12px
gap, the 38x38 icon plates and their amber/peach accents at alpha 0.2, the
14px/w800 titles, the 11.5px subtitles, and the tiles' position in the card
column. The known 4-tiles-vs-2-tiles difference in §8.1 should be recorded there
as an accepted, scoped deviation rather than silently omitted.

**Not in dispute.** AC2, AC3, the Synced Alarm regression surface, accessibility,
codepoint discipline, and scope containment are all verified and need no rework.
This patch is additive evidence; no source change is expected or wanted.

## 10. Verdict

Outcome: PATCH_REQUIRED

The implementation itself is sound. AC2 and AC3 pass, the Synced Alarm
regression surface is intact and independently re-verified, accessibility
matches the UX spec, the PO's Option A resolution is implemented precisely as
scoped, and no scope creep reaches Dream Jar, Anti-Ghosting, the tab bar, or
STORY-001's own surface. The test and analyze gates claimed in the
implementation evidence were re-run by this review and confirmed accurate.

The single gap is F1: AC1 is a design-comparison criterion, and the required
render+compare evidence that would close it was never produced for this story,
although its sibling STORY-001 produced exactly that artifact set this cycle.
Route back to Mobile Developer for the additive visual-fidelity evidence, then
re-review. Not merge-eligible until F1 closes.

