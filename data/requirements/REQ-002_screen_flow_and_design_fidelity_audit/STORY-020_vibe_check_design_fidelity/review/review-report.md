# Review Report: STORY-020 Design Fidelity — Vibe Check (Round 3)

Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Story: STORY-020_vibe_check_design_fidelity
Reviewer mode: compact-story-review
Round: 3 (round-1 PATCH_REQUIRED F-1..F-4; round-2 PATCH_REQUIRED F-3, F-4, F-5)
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-020`
BaseHead for this round: `6ecda8689700984b15ee97af05c133384d600c51` (round-2 reviewed HEAD, confirmed ancestor)
Worktree HEAD at this review: `ae3912780a53b872fb4b9c071b2b43a9cb38568c` (clean tree)

Outcome: DEFERRED_ONLY

## Scope Gate

- Review type: `compact-story-review`, round-3 re-review of F-3, F-4, F-5 only.
- Report path: this file.
- Round-3 diff (`git diff 6ecda868..HEAD`), commit `ae39127` — exactly the
  declared test + evidence set, no production code:
  - `mobile/test/features/vibes/presentation/widgets/vibe_widgets_test.dart` (+5/-5)
  - `.../STORY-020_vibe_check_design_fidelity/story_master.md` (+3/-1)
  - `.../visual-fidelity/visual-fidelity-report.md` (+195/-40)
  - `.../visual-fidelity/design-reference-vibe-android.png` (new)
  - `.../visual-fidelity/implemented-vibe-emulator-5554.png` (new)
  - (`.../review/review-report.md` also appears in the range, from commit
    `465e0d8`, which is the round-2 report being committed to the branch — not
    round-3 work.)
- `git diff --name-only 6ecda868..HEAD -- mobile/lib` is **empty**: the
  test+evidence-only declaration holds. Every round-2 lib finding therefore
  carries forward unchanged by construction.
- Settled and not re-argued: round-1's "Independently Verified As Correct"
  list, the F-1 vector transcription, the F-2 halo fix, the four accepted
  deferrals, and the three confirmed out-of-scope divergences.

## Verdict Summary

All three round-2 blockers are cleared, and cleared with real evidence rather
than assertion. The captures are genuine, the report rewrite is unusually
honest — it strikes its own prior over-count, names the four rows it got wrong,
and corrects an AC3 paragraph that had asserted the opposite of the delivered
code — and both gates now pass at a full green.

| Round-2 finding | Status |
|---|---|
| F-3 no rendered visual evidence | **CLEARED** |
| F-4 report contradicts the delivered code | **CLEARED** |
| F-5 test file does not compile; suite regressed | **CLEARED** |

## F-3 — Cleared

Both PNGs are tracked in the branch (`A` in `git diff --name-status
6ecda868..HEAD`) under the story's `visual-fidelity/`, and both are real
captures, not placeholders:

```
design-reference-vibe-android.png:   PNG image data, 406 x 900, 8-bit/color RGBA  (174.8K)
implemented-vibe-emulator-5554.png:  PNG image data, 405 x 900, 8-bit/color RGBA  (120.8K)
```

Dimensions match the F-3 requirement exactly. I opened both. The reference is
the canvas Android frame of the Vibe Check screen, dark + `vi`. The implemented
image is an emulator screenshot with a live Android status bar (2:07, signal /
battery) and the gesture nav pill — a device capture, not a re-render of the
design.

Comparing them directly, the substance F-3 existed to prove is visible: the
mood cells paint the ported vector faces (warm gradient `happy` disc with its
corner sparkle, purple `sad`, red-orange `angry` with steam, pink `spicy`,
blue-grey `tired`), not emoji glyphs, and the hero halo sits centered and
uncropped behind the title. That is the round-2 F-1 and F-2 code confirmed at
render, which is precisely what round 2 could not assert.

`story_master.md` now records `Design-Screen: vibe` plus the canvas entry
(`Cupid App.dc.html`) and the resolution method
(`render-design-canvas.js --list-screens`), so the choice of reference is
re-checkable. That was the second half of F-3 and it is satisfied.

`mobile/lib/main_preview.dart` — the harness the implemented capture was built
from — existed at BaseHead (`git cat-file -e 6ecda868:...` succeeds), so the
capture route did not smuggle in new production code.

## F-4 — Cleared

I verified the four corrected baselines against `git show 8396273:<file>`
myself rather than accepting the report's word, because the corrected numbers
*are* the deliverable here:

| Row | Report's corrected claim | Verified at BaseHead `8396273` |
|---|---|---|
| 10 struck | face size was already 52 | `vibe_mood_grid.dart:143` = `VibeMoodFace(mood: mood, size: 52)` — **confirmed**, not a deviation |
| 24 struck | face size was already 26 | `vibe_history_strip.dart:89,93` = `size: 26` — **confirmed**, not a deviation |
| 22 narrowed | already 3px and `colorLine`; only the radius was missing | `vibe_history_strip.dart:91` = `Container(height: 3, color: colors.colorLine)` — **confirmed** |
| 12 narrowed | already 52 box / 42 face / an inset / a radius; only radius+inset values were wrong | `partner_vibe_card.dart:44-52` = `width/height: 52`, `EdgeInsets.all(CupidSpacing.xs)`, `BorderRadius.circular(platform.radiusSmall)`, `VibeMoodFace(size: 42)` — **confirmed** |

The arithmetic holds and the table is internally consistent: 24 claimed − 2
struck + 1 new (row 25, the artwork deviation) = 23, and the surviving numbered
rows are 1-9, 11-23, 25 = 23.

The other three F-4 requirements are met:

- The stale AC3 paragraph ("*already correct: `VibeMoodFace` renders the same
  emoji glyphs … this story only resized them*") is gone. It is replaced by
  row 25 plus an explicit retraction in the AC3 status line naming the earlier
  claim as wrong. The report also retracts its own "no file under
  `lib/design_system/` was modified" line now that `MoodFacePalette` exists.
- The round-2 work is documented: the `MoodFacePainter` port, `MoodFacePalette`
  and its no-fork-guard placement rationale, `_faceBounds` as the SVG
  object-bounding-box span, the static `mfTear`/`mfZ` accent frames, the `none`
  dashed outline, and the halo re-anchor folded into row 3.
- A `Rendered Comparison (F-3)` section with a verdict and a six-row residual
  delta table is present, and every residual is dispositioned rather than
  waved off.

Two things I want to record as good practice rather than let pass silently:
the report documents *why* the emulator's native 1080x2400 @420dpi was kept
(the `--width=412 --density=420` attempt produced the same oversized-text
artifact that contaminated the REQ-001 STORY-018 set, and that capture was
discarded), and *why* a profile build was used (debug APK 179MB vs 606MB free,
`INSTALL_FAILED_INSUFFICIENT_STORAGE`). Both are the kind of capture-method
detail that makes the evidence reproducible instead of a one-off.

## F-5 — Cleared

`vibe_widgets_test.dart:355-361` and its three call sites:

```dart
Future<ByteData> rasterize(WidgetTester tester, MoodFaceArt art) async {
  final ByteData? rgba = await tester.runAsync<ByteData>(() async {
    final ui.Image image = await record(art).toImage(100, 100);
    return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  });
  return rgba!;
}
```

All three call sites now pass `tester` (`:387`, `:423`, `:433`), and the
`return_of_invalid_type_from_closure` error is resolved by the explicit
`runAsync<ByteData>` with the `toByteData` null unwrapped inside the closure.
The diff is +5/-5 and touches no assertion — nothing was weakened to make the
suite pass, which was the specific risk with this class of fix.

On the handoff's "no `!`-null-assertion workaround" wording: `return rgba!;`
remains at `:360`. That one is not a workaround — `WidgetTester.runAsync<T>`
returns `Future<T?>` by API contract, so a null assertion at that boundary is
unavoidable and it was never part of the round-2 error set. Non-issue.

## Gate Re-runs (reviewer, in-worktree, actual output)

Run from the story worktree's `mobile/` with `/Users/alantravala/flutter/bin/flutter`.

`flutter analyze lib/features/vibes lib/design_system/tokens/mood_face_palette.dart test/features/vibes`:

```
Analyzing 3 items...
   info • Use an initializing formal to assign a parameter to a field. … •
          lib/features/vibes/presentation/vibe_screen.dart:27:7 • prefer_initializing_formals
1 issue found. (ran in 1.9s)
```

**0 errors.** The seven round-2 errors are gone. The single remaining `info` is
the pre-existing `prefer_initializing_formals` at `vibe_screen.dart:27:7`,
identical at BaseHead and not chargeable to this story. (`flutter analyze`
exits non-zero on any issue including `info`; the exit code is not a failure
signal here.)

`flutter test test/features/vibes test/design_system`:

```
00:03 +79: All tests passed!
```

**79 passed, 0 failed**, full suite — not a filtered subset. The count
reconciles: 75 round-1 baseline + 4 round-2 `VibeMoodFace artwork` tests. The
round-2 regression (61 passed, `vibe_widgets_test.dart` failing to load) is
fully recovered; the file's ~14 tests are live again, including the three
round-1 STORY-020 fidelity tests and `no_fork_guard_test.dart`, which passes
with `mood_face_palette.dart` in place.

## Acceptance Criteria

| AC | Status | Basis |
|---|---|---|
| AC1 layout/spacing/token/typography match | **MET** | Code-level work settled in rounds 1-2; now confirmed at render against the reference for every region the capture exercises. Residual deltas are approved divergences, the deferred shared-header item, or empty-data state — none is a styling defect |
| AC2 deviations corrected in the app, not merely documented | **MET** | 23 deviations fixed in code, count re-derived and the four bad baselines corrected against BaseHead (verified independently above); documentation half now matches the branch |
| AC3 mood sticker treatment matches the design source | **MET** | `MoodFacePainter` transcription verified faithful in round 2, now confirmed at render; four artwork tests live and passing; the contradicting evidence paragraph retracted |
| AC4 no change to how the screen is reached | **MET** | Navigation untouched across all three rounds; the `HomeScreen` entry-point test passes in this run |

## Risk Surfaces And Critical Gates

| Surface | Gate | Result |
|---|---|---|
| Mobile interaction / rendering | `flutter analyze` on changed scope | **PASS** — 0 errors, 1 pre-existing info |
| Mobile interaction / rendering | `flutter test test/features/vibes test/design_system` | **PASS** — 79 passed, 0 failed |
| Design fidelity (12e2/12e3, mobile lane) | rendered implemented + reference PNGs | **PASS** — both present, tracked, correct dimensions, visually verified |
| Design fidelity | `Design-Screen` recorded for re-checkability | **PASS** — `Design-Screen: vibe` in `story_master.md` |
| Mobile navigation / discoverability | entry point unchanged, existing test passes | PASS |
| No-fork guard (raw color literals) | `test/design_system/no_fork_guard_test.dart` | PASS |
| Scope discipline | no `mobile/lib/**` change in round 3 | PASS — diff against `mobile/lib` is empty |
| Runtime startup smoke (12g) | n/a | Not required — `Complexity: trivial` |
| Configuration guide | n/a | No setup/configuration surface touched |

## Deferred (non-blocking, carried forward — basis for `DEFERRED_ONLY`)

None of these blocks merge. All four were pre-recorded before this round, and
because round 3 changed no `lib/` file, each is unchanged by construction
rather than by re-inspection.

1. **`_paintNone` dash caps.** `_stroke(...)` always sets `StrokeCap.round`;
   `Mood Face.dc.html:108` sets no `stroke-linecap`, so the source dashes are
   butt-capped. The `none` face appears at 26px and 52px in the capture, below
   the resolution at which a ~1px per-dash difference could be settled. The
   report carries it as explicitly unresolved rather than claiming it either
   way, which is the correct disposition.
2. **Dead dartdoc links.** `vibe_mood_face.dart:234` and `:294` reference
   `[_MoodFacePainter]`; the class is public `MoodFacePainter`. Cosmetic, and
   a `lib/` edit was out of scope for a test+evidence-only round.
3. **Back-arrow tint** (`--pink` in the source vs `--tx` rendered). Painted by
   the shared adaptive `CupidHeader`, so fixing it is a cross-screen change
   outside this story's lane. Correctly folded into the existing deferred
   `CupidHeader` chrome item and recorded in the residual-delta table so it is
   not lost.
4. **Offline-state capture regions.** The implemented capture shows
   `Không có kết nối mạng`, so the partner card and the 7-day strip render
   their empty state (`Chưa nói gì`, all-`none` faces) instead of the
   reference's seeded data. Their box geometry, spacing, radii and typography
   are still comparable and do match; the mood-dependent fill of those two
   regions is verified by code review and widget tests rather than by pixel.
   Disclosed plainly in the report. Acceptable, but if a later story recaptures
   this screen against a reachable backend, that is the gap worth closing.

Approved prior divergences confirmed at render and **not** findings: the 5-cell
3+2 mood grid (`soft`/`Mềm lòng` absent from the grid though `MoodFaceArt`
still carries the face), the omitted "tự xoá sau 30 ngày" retention label
(UX §6 A-2 — no backend deletion job exists), and the absent 5-tab bottom bar
(Vibe Check is not an `AppShell` tab destination).

## Recommended Workflow State

- Check `Implementation (Development)`.
- Check `Review (Reviewer)`.
- Story status: ready for `DONE` / merge-eligible into
  `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`.
- No rework handoff required.

REVIEW_COMPLETE: YES
