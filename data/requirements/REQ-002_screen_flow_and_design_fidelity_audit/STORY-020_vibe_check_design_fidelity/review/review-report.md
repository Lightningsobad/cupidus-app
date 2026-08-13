# Review Report: STORY-020 Design Fidelity — Vibe Check (Round 2)

Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Story: STORY-020_vibe_check_design_fidelity
Reviewer mode: compact-story-review
Round: 2 (round-1 returned PATCH_REQUIRED with F-1..F-4)
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-020`
BaseHead: `8396273e6a5e6a2798557aa68864f0ef24cd939b`
Round-1 reviewed commit: `1c4eace9b6fcecbf054b9f0dbb8d5cda373bdf01`
Worktree HEAD at this review: `6ecda8689700984b15ee97af05c133384d600c51` (clean)

Outcome: PATCH_REQUIRED

## Scope Gate

- Review type: `compact-story-review`, round-2 re-review of findings F-1..F-4.
- Report path: this file.
- Round-2 diff (`git diff 1c4eace..HEAD`), 4 source/test files + 1 report file:
  - `mobile/lib/design_system/tokens/mood_face_palette.dart` (new, 60 lines)
  - `mobile/lib/features/vibes/presentation/widgets/vibe_mood_face.dart` (+416/-…)
  - `mobile/lib/features/vibes/presentation/vibe_screen.dart` (+33/-28)
  - `mobile/test/features/vibes/presentation/widgets/vibe_widgets_test.dart` (+94)
  - `.../review/review-report.md` (round-1 report committed into the branch)
- Evidence in scope: `visual-fidelity/visual-fidelity-report.md`, `story_master.md`,
  `cupid-app-design-system/project/Mood Face.dc.html`,
  `data/devops/system/design-fidelity-config.json`.
- Query keys: F-1 mood-face artwork, F-2 hero halo clipping/anchor, F-3 rendered
  capture, F-4 deviation-table accuracy, plus a re-run of `flutter analyze` and
  `flutter test test/features/vibes test/design_system`.
- Everything listed under round-1 "Independently Verified As Correct" is settled
  and was not re-argued.

## Verdict Summary

The two code findings were fixed, and fixed well — the `Mood Face` port is a
faithful, line-by-line transcription of the design source, and the halo
re-anchor is correct. But the patch was submitted without being compiled: the
new test file has seven analyzer errors, so the entire `vibe_widgets_test.dart`
suite no longer loads and the branch is now *below* its round-1 test baseline.
And `visual-fidelity-report.md` is byte-identical to round-1 — F-3 and F-4 were
not touched at all, so the story's own evidence artifact still asserts that the
emoji glyphs were correct, which the round-2 code itself now contradicts.

| Round-1 finding | Status |
|---|---|
| F-1 mood faces are emoji, not the `Mood Face` component | **Fixed in code** — verified faithful; not yet confirmed at render |
| F-2 hero halo mispositioned and clipped | **Fixed** |
| F-3 no rendered visual evidence | **NOT ADDRESSED** — still blocking |
| F-4 inaccurate "Was" rows / deviation count | **NOT ADDRESSED** — still blocking, now worse |
| F-5 (new) test file does not compile | **NEW BLOCKER** |

## Findings

### F-5 (NEW, BLOCKING) — `vibe_widgets_test.dart` does not compile; the suite regressed

`mobile/test/features/vibes/presentation/widgets/vibe_widgets_test.dart:355`
declares the helper with two positional parameters:

```dart
Future<ByteData> rasterize(WidgetTester tester, MoodFaceArt art) async {
```

and every call site passes one argument (`await rasterize(art)` at :387,
`await rasterize(MoodFaceArt.happy)` at :423, `await rasterize(MoodFaceArt.none)`
at :433). The helper also returns `Future<ByteData?>` from a `Future<ByteData>`
closure at :358.

`flutter analyze lib/features/vibes lib/design_system/tokens/mood_face_palette.dart test/features/vibes`
— reviewer re-run:

```
error • The returned type 'Future<ByteData?>' isn't returnable from a 'Future<ByteData>' function … vibe_widgets_test.dart:358 • return_of_invalid_type_from_closure
error • The argument type 'MoodFaceArt' can't be assigned to the parameter type 'WidgetTester' … :387, :423, :433
error • 2 positional arguments expected by 'rasterize', but 1 found … :387, :423, :433
8 issues found.
```

(The 8th is the pre-existing `prefer_initializing_formals` info at
`vibe_screen.dart:27`, unchanged and not chargeable to this story.)

`flutter test test/features/vibes test/design_system` — reviewer re-run:

```
00:03 +61 -1: Some tests failed.
Failing tests:
  …/test/features/vibes/presentation/widgets/vibe_widgets_test.dart: loading …
```

61 passed, 1 file failed to **load**. Round 1 was 75 passed / 0 failed, so the
whole ~14-test `vibe_widgets_test.dart` file is now dead — including the three
round-1 STORY-020 fidelity tests (gradient alpha stops, no-resize-on-select,
amber nudge banner) that were the accepted evidence for the spacing/token half
of this audit, plus the pre-existing widget coverage in that file.

The visual-fidelity report's `flutter test … 75 passed` row therefore no longer
describes this branch, and the round-2 commit was pushed without re-running
either gate.

Required: fix the helper signature (drop the unused `tester` parameter or pass
it at every call site) and the nullable return, then re-run both commands and
record the actual result.

### F-3 (STILL OPEN, BLOCKING) — no rendered visual evidence exists

`git diff 1c4eace..HEAD --name-status` shows `visual-fidelity/visual-fidelity-report.md`
was not modified in the round-2 commit, and `git ls-files` plus
`git ls-files -o -i --exclude-standard` confirm there is **no PNG at all** under
`STORY-020_vibe_check_design_fidelity/visual-fidelity/` — neither tracked,
untracked, nor ignored. The directory holds only the markdown report.

`data/devops/system/design-fidelity-config.json` has `ui_surface: true` and a
locked `design_source` (`claude-design`, `cupid-app-design-system/project`), and
`story_master.md` records the design reference as locked and confirmed by
`detect_design_source.py`. So neither audited scope-out applies and the rendered
check is mandatory for this mobile-lane, UI-bearing story.

This is the same gap round-1 flagged, and it now matters more, not less: F-1 was
closed by replacing every mood glyph on the screen with newly hand-transcribed
vector artwork. Nothing in the branch shows what that actually looks like.

Required (mobile-dev owns capture per the mobile lane's fidelity rules):
`implemented-vibe-<device>.png` and `design-reference-vibe-<device>.png` under
`STORY-020_vibe_check_design_fidelity/visual-fidelity/`, dark theme + `vi`
locale, plus the resolved `Design-Screen: <id>` recorded — `story_master.md`
currently records a prose screen name ("Vibe Check, Epic 3") but no canvas
screen id, so the choice of reference cannot be re-checked by anyone.

### F-4 (STILL OPEN, BLOCKING) — `visual-fidelity-report.md` is unchanged and now factually contradicts the code

The file is identical to the round-1 version. Three consequences:

1. The four inaccurate "Was" baselines round-1 named (rows 10, 12, 22, 24) are
   still there, and the headline "24 deviations fixed in code" still over-counts.
2. Its AC3 paragraph still reads *"Mood sticker treatment (AC3) was already
   correct: `VibeMoodFace` renders the same emoji glyphs as the source's
   `moodList` faces, and this story only resized them."* The round-2 commit
   deleted that emoji map and replaced it with `MoodFacePainter`. The story's
   evidence artifact now describes the opposite of what the branch contains.
3. None of the round-2 work is documented: the new `MoodFacePalette`, the
   `MoodFacePainter` port, the static-frame decision for `mfTear`/`mfZ` accents,
   or the halo re-anchor. On a story whose *deliverable is the fidelity audit*,
   the artifact is the product.

Required: rewrite the report against the delivered code — correct the four rows
and the count, replace the AC3 paragraph, document the round-2 changes, and
attach the F-3 comparison with any residual delta named.

## F-1 and F-2 — Verified Fixed

**F-1.** `vibe_mood_face.dart` now paints all seven design-source faces through
`MoodFacePainter` at the source's `viewBox="0 0 100 100"` scale, with the palette
extracted to `mood_face_palette.dart`. I re-derived every face against
`cupid-app-design-system/project/Mood Face.dc.html` and it is an accurate
transcription — the six gradients (`mfA`–`mfF`), the `r=38` disc, every brow /
eye / blush / mouth path and stroke width, the sparkle, heart, tear and steam
accents, the `z` sleep marks at their SVG baselines, and the `none` face's
`stroke-dasharray="7 7"` outline at `opacity 0.7`. Two details worth recording
as correct rather than lucky: `_faceBounds = Rect.fromLTRB(12,12,88,88)` is the
right object-bounding-box span for the SVG's `x1/y1/x2/y2` gradient, and the
soft accent's `transform="translate(76,8) scale(0.9)"` is correctly applied as
scale-then-shift. `VibeMood.horny → MoodFaceArt.spicy` is the right mapping.
Painting `mfTear`/`mfZ` accents at peak keyframe opacity rather than their `t=0`
opacity of zero is the correct call and is documented in the source comments.

The new palette file sits in `mobile/lib/design_system/tokens/`, matching the
existing `bun_sprite_palette.dart` / `pet_hero_gradient.dart` precedent for
additive single-consumer illustration palettes, so no shared token file was
edited. Flag to Scrum Master only if that directory was outside the round-2
WriteScope — as code it is the right placement.

**F-2.** `vibe_screen.dart:139-142` now puts the `Stack` outside the `Padding`
with `clipBehavior: Clip.none`, so `Positioned(top: 0)` resolves against the
hero block's own box (matching the source's `position:absolute; top:0` against
the padding box) and the 90px halo is no longer cropped by the shorter text
column. Correct on both counts.

## Acceptance Criteria

| AC | Status | Basis |
|---|---|---|
| AC1 layout/spacing/token/typography match | **UNVERIFIED** | Code-level work is correct (F-2 fixed, round-1 spacing set settled), but with no rendered capture (F-3) "match exactly with no visible deviation" cannot be asserted |
| AC2 deviations corrected in the app, not merely documented | **PARTIAL** | Corrected in code; the documentation half (F-4) still describes the pre-fix state and contradicts the branch |
| AC3 mood sticker treatment matches the design source | **UNVERIFIED** | Artwork now ported and verified faithful at source level; needs the rendered confirmation of F-3, and the tests that cover it do not compile (F-5) |
| AC4 no change to how the screen is reached | **MET** | Navigation untouched in the round-2 diff; `vibe_screen_test.dart` (incl. the `HomeScreen` entry-point test) passes in the reviewer re-run |

## Risk Surfaces And Critical Gates

| Surface | Gate | Result |
|---|---|---|
| Mobile interaction / rendering | `flutter analyze` on changed scope | **FAIL** — 7 errors (F-5) |
| Mobile interaction / rendering | `flutter test test/features/vibes test/design_system` | **FAIL** — 61 passed, `vibe_widgets_test.dart` fails to load (F-5) |
| Design fidelity (12e2/12e3, mobile lane) | rendered implemented + reference PNGs | **FAIL** — no images exist (F-3) |
| Mobile navigation / discoverability | entry point unchanged, existing test passes | PASS |
| No-fork guard (raw color literals) | `test/design_system/no_fork_guard_test.dart` | PASS in the reviewer run — the new literals live in `design_system/tokens/`, which the guard permits |
| Runtime startup smoke (12g) | n/a | Not required — `Complexity: trivial` |
| Configuration guide | n/a | No setup/configuration surface touched |

## Minor Notes (non-blocking, fold into the patch if convenient)

- `vibe_mood_face.dart:234` and `:294` reference `[_MoodFacePainter]` in dartdoc;
  the class is public `MoodFacePainter`, so both links are dead.
- `_paintNone` uses `_stroke(...)`, which always sets `StrokeCap.round`, on the
  dashed outline. `Mood Face.dc.html:108` sets no `stroke-linecap`, so the source
  dashes are butt-capped. At 52px this lengthens each dash by roughly a pixel.
  Worth confirming against the F-3 render rather than guessing.

## Required To Clear (round 3)

1. **F-5** — fix the `rasterize` signature and nullable return in
   `vibe_widgets_test.dart`; re-run `flutter analyze` and
   `flutter test test/features/vibes test/design_system` and record real output.
   The suite must be back to a full pass, not 61/-1.
2. **F-3** — capture `implemented-vibe-<device>.png` and
   `design-reference-vibe-<device>.png` under the story's `visual-fidelity/`,
   dark + `vi`, and record the resolved `Design-Screen: <id>`.
3. **F-4** — rewrite `visual-fidelity-report.md` against the delivered code:
   correct rows 10/12/22/24 and the deviation count, replace the stale AC3
   emoji paragraph, document the `MoodFacePainter` port and halo re-anchor, and
   state the F-3 comparison verdict with any residual delta.

Settled and not to be re-argued in round 3: round-1's "Independently Verified As
Correct" list, the F-1 vector transcription (verified against the design source
in this pass), the F-2 halo fix, the four accepted round-1 deferrals (partner
name line, decorative white highlights, animations, `CupidHeader` chrome
typography), and the three confirmed out-of-scope divergences (5-cell 3+2 grid,
omitted 30-day retention label, no 5-tab bottom bar).

## Recommended Workflow State

- Uncheck `Implementation (Development)`.
- Leave `Review (Reviewer)` unchecked.
- Story status: `IN_PROGRESS`; return to the `mobile` lane with F-3, F-4, F-5.

REVIEW_COMPLETE: YES
