# Visual Fidelity Report: STORY-060 Contract Particle Dots Disposition

VISUAL_FIDELITY: PASS
Design-Screen: contract

## Verdict Up Front

**Yes — the three ambient particle dots now appear on the `contract` screen,
painted above the contract card, at their token-exact fractional positions.**
All three are present in the post-fix capture. Before this story they were
painted below the Navigator and were invisible on this screen, which is what
STORY-056 recorded as DEF-1.

**This PASS is conditioned on the accepted-difference disposition in `AD-1`
below, not on absolute positional match with the reference PNG.** The particles
sit 27-41 px higher than their reference centres because the implementation
mounts the particle layer against the full screen while the reference renderer
insets it inside a mockup chassis. The UI/UX Designer has dispositioned that
container difference as accepted (Route 2), so it is a recorded accepted
difference rather than an unresolved defect. Read `AD-1` before treating this
verdict as a positional-parity claim.

This report closes AC2 on those terms.

## Evidence Pair

| Side | File | Size | `shasum -a 256` |
|------|------|------|-----------------|
| Design reference | `design-reference-contract-myunsigned-android.png` | 406x900 | `2acd1045727564cf7ff167fd36e13f3a418c65509be7debc35060ba6498514b3` |
| Implementation | `implemented-contract-requesterunsigned-emulator-5560.png` | 405x900 | `c18cf3d27e30ad269047dfad6ac6c2b75bb0481205f39a4519e91d6d3ccff4ca` |

Conditions match STORY-056's and STORY-057's approved pairs: dark theme, `vi`
locale, Android 412x915dp design frame vs `emulator-5560` at 1080x2400 @420dpi,
`font_scale` 1.0, both sides bounded to 900 px tall.

## Design Side — Reused, Not Re-rendered

`master-plan.md` marks the design reference byte-locked
(`sha256 2acd1045…14b3`) and forbids regenerating it. It was **not** rendered.
The file was copied in from STORY-057's approved evidence directory and its
hash verified to reproduce `2acd1045…14b3` exactly. `render-design-canvas.js`
was not run by this story, and no design-source file was opened for writing.

## Implementation Side — Rebuilt After P1+P2 And Re-captured

STORY-057's implementation capture could not be reused: it predates the paint-
order fix, so it depicts the screen with no particle dots at all.

1. `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=contract --dart-define=PREVIEW_CONTRACT_SIGN_STATUS=requesterUnsigned`
   → `✓ Built build/app/outputs/flutter-apk/app-debug.apk`, exit 0. Required,
   because `PREVIEW_CONTRACT_SIGN_STATUS` is a compile-time
   `String.fromEnvironment`. **`main_preview.dart` was not modified** — the
   `requesterUnsigned` fixture STORY-049 added is used as-is, and the harness
   already mounts the same `CupidAppBackground` (`main_preview.dart:1496`), so
   the fix reaches the capture with no harness change.
2. `adb -s emulator-5560 install -r …/app-debug.apk`
3. `adb -s emulator-5560 shell settings put system font_scale 1.0`
4. `am force-stop com.snapsofts.cupid`, then `am start` of
   `com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
5. `capture-mobile-screen.sh --device=emulator-5560 --out=<this dir> --label=contract-requesterunsigned --mode=implemented --platform=android --max-edge=900 --settle-ms=45000`
   → `MOBILE_CAPTURE: OK … 405x900`, exit 0.

Steps 2-5 ran inside a single `--lease-exec` device lease, so no concurrent
worker could disturb the device mid-capture. `--settle-ms=45000` was used on the
first attempt, per STORY-056's recorded harness note that 12000 ms is not enough
for this debug build. The capture was content-verified before being trusted — it
shows the rendered Love Contract screen, not the Flutter splash. No capture was
discarded, and no device was created, booted, wiped, or resized.

## Per-Particle Verdict — Measured, Not Eyeballed

Each side was scanned for pixels within tolerance 6 of each
`CupidSkyPalette.stars` token colour, and the connected blobs' centroids taken.

Expected implementation positions, derived from the tokens against the 405x900
capture (`x = w − rightFactor·w − size/2`, `y = topFactor·h + size/2`):

| # | Token | Expected centre | Measured centre | Verdict |
|---|-------|-----------------|-----------------|---------|
| 0 | `#FFFFFF`, `left 0.08`, `top 0.14`, `size 6` | `(35.4, 129.0)` | `(36, 130)`, a 5px round blob at `lum 118` against a `lum 69` surround | **MATCH** |
| 1 | `#FFD9EA`, `right 0.16`, `top 0.09`, `size 4` | `(338.2, 83.0)` | `(337.3, 82.4)`, 7 px at the exact token colour | **MATCH** |
| 2 | `#CEB4FF`, `right 0.07`, `top 0.26`, `size 5` | `(374.2, 236.5)` | `(373.5, 236.2)`, 10 px at the exact token colour | **MATCH** |

Every particle lands within 1 px of its token position. Particles 1 and 2 were
caught near their twinkle peak, so their pixels are their own opaque token
colour. Particle 0 was caught near its low phase (opacity floor `0.25`), so it
reads as a partially blended white — the same low-opacity rendering the design
reference shows for that particle, confirmed by cropping both sides at 6x: on
both, a small grey-white disc of the same size and opacity is present. It sits
on the card's top-left corner in the implementation and above the `L` of the
`Love Contract` title in the reference — the container offset dispositioned as
`AD-1`.

The important part is *what it sits on*: in the implementation capture that disc
is painted **on the card's own rounded top-left corner surface**, inside the
card's border radius. That is only possible with the particle layer above the
Navigator. Pre-fix it was behind the card and therefore not rendered at all.

## Position Correspondence Between The Two Sides

Absolute pixel coordinates differ between the two images, and the reason is
frame geometry in the reference renderer, not placement in the app.

The design canvas draws a device chassis and status bar around the app body, so
its particle box is inset within the 406x900 image. Solving that box from the
two token-coloured dots (two equations, two unknowns per axis) gives
`x ∈ [5.3, 397.5]` (`W = 392.2`) and `y ∈ [47.3, 869.1]` (`H = 821.8`) — a ~5px
side bezel and a ~47px top inset, which is the chassis edge plus the status bar.
The Flutter implementation mounts `CupidAppBackground` at `MaterialApp.builder`,
so its box is the full 405x900 screen, status bar included.

Normalised against each renderer's own particle box, the placements coincide:

| # | Design fractional `(x, y)` | Implementation fractional `(x, y)` | Delta |
|---|----------------------------|------------------------------------|-------|
| 1 | `(0.8348, 0.0925)` | `(0.8328, 0.0916)` | `0.002` / `0.001` |
| 2 | `(0.9235, 0.2631)` | `(0.9222, 0.2624)` | `0.001` / `0.001` |

Particle 0's predicted reference centre from the same solved box is
`(39.7, 165.4)`; the 6x crop shows the disc at `(42, 165)`. Same agreement.

So the dots are at the reference's positions in the sense the design source
defines them — the same fractions of the app body — while their absolute pixel
positions differ from the reference by 27-41 px vertically. That residual is
**not** a general property of this evidence pair and no precedent from prior
approved pairs covers it: a column scan at `x=200` shows the two images' content
is aligned within 3 px (app-bar title `y 66-80` ref vs `y 69-83` impl; display
title `y 175-188` ref vs `y 177-195` impl). The inset belongs to the particle
layer's container alone. These are the first elements in REQ-002 positioned as a
*fraction of a container*, which is precisely when the container definition
becomes load-bearing, so prior pairs — whose compared elements were laid out by
the app below the status bar — establish nothing here. The difference is
dispositioned below as an accepted difference.

## Deviations

### AD-1 — Particle layer container differs from the reference renderer's: ACCEPTED DIFFERENCE

**The three ambient particles render at the same fractional positions the design
source defines, but against the full screen rather than the reference PNG's
inset box, so they land 27-41 px higher in absolute pixels; this is accepted as
a design-tool mockup artifact, not an implementation defect.**

Disposition source: the **Route-2 addendum in `../ux/uiux-spec.md`**, in which
the UI/UX Designer decided that the full-screen `CupidAppBackground` /
`_CupidSkyStars` mount is the correct reading of the canvas source
(`Cupid Screens.dc.html:44`'s root div is `height:100%`, and the header pads
itself with `var(--safe-top)`), and that the reference PNG's ~47 px top and
~33 px bottom inset is the design tool's phone-mockup chassis, not design
intent. Same disposition family as STORY-010 / STORY-047's `CC-1` (dashed avatar
border = authoring-tool chrome, not a shipped element).

Measured deltas, from Reviewer `Iris-QC-2`'s independent scan of the two PNGs in
this directory (token-colour blob centroids, tolerance 8-10):

| Particle | Reference centre | Implementation centre | Δx | Δy |
|---|---|---|---|---|
| `#FFD9EA` (`right 16%`, `top 9%`) | `(332.7, 123.3)` | `(337.5, 82.5)` | `+4.8` | **`−40.8`** |
| `#CEB4FF` (`right 7%`, `top 26%`) | `(367.8, 263.2)` | `(373.5, 236.1)` | `+5.7` | **`−27.1`** |
| `#FFFFFF` (`left 8%`, `top 14%`) | `(42, 165)` | `(36, 130)` | `−6` | **`−35`** |

Visible consequence, for the record: the pink dot sits inside the card's header
band in the reference but in the app-bar row, clear of the card, in the
implementation; the purple dot sits beside the `§1` clause marker in the
reference but at the header band's lower edge; the white dot sits above the `L`
of the display title in the reference but on the card's top-left corner.

The implementation is internally exact — predicted `y` from the tokens against
`H = 900` is `83.0` and `236.5` against measured `82.5` and `236.1` — so the
disagreement is entirely the container box, not the geometry. Route 1 (insetting
`_CupidSkyStars` to `MediaQuery.viewPadding`) was available and was **not**
taken, per the Designer's decision.

### New Deviations Beyond The Particles: NONE

The pair was checked for anything the particle fix could have disturbed.
Everything else differing is already dispositioned by STORY-056's and
STORY-057's approved reports and is re-confirmed here unchanged:

- **Clause-counter row `2/20 điều khoản`** — present in the implementation,
  absent from the design source. Dispositioned as A-1 by STORY-015, re-confirmed
  as CC-1 by STORY-050.
- **Subtitle** — design `Giữa Minh & Linh · …` vs the implementation's neutral
  fallback; the preview harness supplies no `myDisplayName`. Fixture state.
- **Clause selection and clause label language** — the fixture selects 2 of 4
  and renders the harness's English strings. Preview fixture data, not shipped
  copy.
- **Add-clause label** — renders `+ Thêm điều khoản của riêng tụi mình` on both
  sides; STORY-057's correction is intact and was not regressed.

The card, its clause rows, the hold-to-sign control, and the footer are
unchanged in position and size. Nothing was occluded by the layer moving up: the
particles total three discs of 4-6 px at ≤1.0 opacity.

## Interaction Is Unaffected

The layer now sits above the whole route, so the source's `pointer-events:none`
had to be re-proved rather than assumed. It is pinned by three widget tests that
hit-test at a star centre and assert the tap still reaches the screen below:
`cupid_app_background_test.dart` (`never intercepts a tap landing on a star`),
`welcome_screen_test.dart`, and `vow_screen_test.dart`. The layer keeps its
`ExcludeSemantics` + `IgnorePointer` + `RepaintBoundary` wrapping and keeps
honouring `MediaQuery.disableAnimations`.

## Scope Boundary Held

Working-tree diff against `BaseHead` `81175c5`, `mobile/` only:

```
 .../decorations/cupid_star_field.dart              | 127 ---------------------
 mobile/lib/design_system/design_system.dart        |   1 -
 .../design_system/theme/cupid_app_background.dart  |  10 +-
 .../auth/presentation/screens/welcome_screen.dart  |   4 -
 .../vow/presentation/screens/vow_screen.dart       |   3 -
 .../design_system/cupid_app_background_test.dart   |  60 ++++++++++
 .../presentation/screens/welcome_screen_test.dart  | 109 +++++++++++++-----
 .../vow/presentation/screens/vow_screen_test.dart  |  93 +++++++++++++--
 8 files changed, 229 insertions(+), 178 deletions(-)
```

Plus one new untracked test file,
`mobile/test/features/love_contracts/presentation/screens/love_contract_particle_dots_test.dart`.

Holding the plan's cross-phase invariants:

- **`mobile/lib/features/love_contracts/` has zero production diff.** The
  `contract` screen received no code change; the fix is entirely at the shell.
- `mobile/lib/design_system/tokens/cupid_sky_palette.dart` — unmodified.
- `mobile/lib/main_preview.dart` — unmodified.
- No new widget, token, colour literal, duration, or geometry value was added by
  either phase. `cupid_app_background.dart`'s `+10/-…` is the `Stack` child
  reorder plus the corrected dartdoc.

## Verification State

Run in this session from `/Users/alantravala/workspace/snapsofts/cupid-apps/mobile`,
Flutter 3.44.1 stable:

- **P1** — `flutter analyze` on the 3 touched files → `No issues found!`, exit 0.
  `flutter test` on the 3 relevant suites → `+14: All tests passed!`, exit 0.
- **P2** — `flutter analyze` on the 5 touched items → `No issues found!`, exit 0.
  `flutter test` on the 4 relevant suites → `+25: All tests passed!`, exit 0.
- **Full suite** — `flutter test` → `01:18 +1319 ~2: All tests passed!`, exit 0.
  1319 passed, 2 skipped, 0 failed, against STORY-057's baseline of 1314 passed
  / 2 skipped. The `+5` delta is this story's own tests. A paint-order change
  above every route in the app is exactly the kind that needs a full-suite run,
  and it produced no regression.

Full transcripts, including the pre-fix failure checks that prove the new tests
are real regression pins rather than tautologies, are in
`../coding-plan/test-results.md`.

VISUAL_FIDELITY: PASS
