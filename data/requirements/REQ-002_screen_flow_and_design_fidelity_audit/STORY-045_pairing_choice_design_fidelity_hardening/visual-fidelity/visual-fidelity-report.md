# Visual Fidelity Report: STORY-045 Pairing Choice Surface/CTA Styling Fidelity

VISUAL_FIDELITY: PASS

## Evidence Pair

| Side | File | Size | Provenance |
|------|------|------|-----------|
| Design reference | `design-reference-pairingchoice-android.png` | 406x900 | Rendered by STORY-034 (`render-design-canvas.js --screen=pairingchoice --platform=android --theme=dark --lang=vi`), reused as-is per this story's scope — not re-rendered. |
| Implementation | `implemented-pairingchoice-emulator-5560.png` | 405x900 | Captured 2026-08-18 from the running app after this story's fix, `capture-mobile-screen.sh --device=emulator-5560 --route=cupidpreview://screen/pairingchoice --settle-ms=9000`. |

Same-state pairing: dark theme, `vi` locale, unpaired onboarding state, Android
412x915 dp design frame vs `emulator-5560` at 1080x2400 @420dpi = 411x914 dp
logical, `font_scale` 1.0. The two frames are dimensionally equivalent, so the
comparison below is 1:1 in image pixels (the reference carries a device bezel
that offsets it ~5px down and ~7px right).

## Root Cause

The four deviations in STORY-034's finding D1 were measured against a **stale
implementation capture**, not against the code as it stood when this story
opened. STORY-034's own `visual-fidelity-report.md` records its implemented PNG
as a "pre-existing capture" copied from `STORY-002_onboarding_pairing_navigation`.
That capture predates commit `d43d9f2` (2026-08-14, STORY-032), which is when
both `CupidPrimaryButton`'s gradient+glow and `CupidAppBackground`'s gradient +
particle field last changed. It was also taken at `--width=540` with no matching
`--density`, which collapses the emulator's logical width from ~411dp to ~205dp
and manufactures the reported "type scale too large / pill label wraps to two
lines / title wraps at the wrong word" symptoms.

Re-capturing the unmodified code at native resolution (baseline, before any edit
in this story) showed D1's deviations 1 and 2 were **already closed**: the
gradient surface with particle accents and the gradient+glow pill CTA both
render. The two deviations that were real are D1-3 (title type scale) and D1-4
(title vertical offset) — and D1-3 was inverted from the report: the title
rendered *smaller* than the design (22px UI font vs the design's 27px Nunito
w900), so it fit on one line where the reference wraps to two.

## Change Applied

One file: `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`.

Transcribed the design source's own container and title rules
(`cupid-app-design-system/project/Cupid Screens.dc.html`, `isPairingChoice`
block) onto the screen:

- `Center` -> `Align(alignment: Alignment.topCenter)` with
  `EdgeInsets.fromLTRB(28, 150, 28, 0)`, matching the design's
  `padding:150px 28px 0` with no `justify-content:center`. The 28 horizontal
  inset is load-bearing beyond spacing — it sets the title's line width, and the
  design's title wraps within ~1px of that bound.
- Title style `cupidType.cardTitle` -> `cupidType.display.copyWith(fontSize: 27,
  height: 1.3)`, matching the design's
  `font-family:Nunito;font-weight:900;font-size:27px;line-height:1.3`. This
  follows the existing `joincode_screen.dart` precedent for a design-source-sized
  Nunito title.

No change was needed for the background or the CTA: `CupidAppBackground` is
already mounted at the composition root and this screen's `Scaffold` already
leaves its background transparent, and `CupidPrimaryButton` already applies
`colors.gradientHot` + `colors.glowShadow`. No design token or shared component
was modified or forked.

Reference geometry independently confirms the transcription: the design frame's
status-bar row measures ~49 CSS px, and `49 + 150 + (2 x 27 x 1.3) + 32` lands
the pill top at 301 CSS px == the reference's measured 296 image px. The design
source's `150px` is therefore measured below the status bar, which is exactly
what `SafeArea` + a 150dp top pad reproduces on device.

## Acceptance Criteria Verification

Measurements are ink-extent bounding boxes in image pixels, taken from both PNGs
with the same detector. Reference values carry its ~5px vertical / ~7px
horizontal bezel offset.

| AC | Check | Design reference | Implementation | Result |
|----|-------|-----------------|----------------|--------|
| 1 | Background gradient | top-left `57,27,92` / top-right `93,34,71`, darkening to `23,17,41` mid/lower | top-left `57,27,92` / top-right `93,34,71`, darkening to `23,17,41` mid/lower | MATCH |
| 1 | Particle accents | 3 small light dots in the upper field | 3 small light dots in the upper field, same placement | MATCH |
| 2 | CTA gradient | left `250,127,185` -> right `192,138,236` | left `253,127,184` -> right `193,138,236` | MATCH |
| 2 | CTA glow | visible pink halo below the pill | visible pink halo below the pill | MATCH |
| 3 | Pill label lines | 1 line | 1 line | MATCH |
| 3 | Title wrap word | wraps before `Cupid`; line 1 `Ghép đôi để mở khoá` (w=268), line 2 `Cupid` (w=70) | wraps before `Cupid`; line 1 w=272, line 2 w=71 | MATCH |
| 4 | Title vertical offset | line 1 ink top y=201 (22.3% of frame) | line 1 ink top y=200 (22.2% of frame) | MATCH |
| 4 | Title line 2 top | y=237 | y=237 | MATCH |
| 4 | Pill top | y=296 | y=297 | MATCH |
| 6 | Content / structure / navigation | title, pill CTA, secondary text link; `Ghép đôi để mở khoá Cupid` / `Ghép đôi với người ấy` / `Tôi đã có mã`; both CTAs push their existing destinations | identical strings, identical widget order, `_openInvite` / `_openJoincode` untouched | UNCHANGED |

All AC1-AC4 deltas are within 1px of the reference. AC5 is satisfied by this
report and the two PNGs beside it. AC6 holds: the diff touches only the layout
alignment, the container padding, and the title `TextStyle` — no string, no
widget added or removed, no navigation edge changed.

## Known Non-Regressions (out of this story's scope)

- Pill height renders 52px vs the reference's 48px. `CupidPrimaryButton` pins a
  shared `_primaryCtaHeight = 54` dp; the design's box computes to ~50 CSS px.
  This is a shared-component constant applied identically on every screen that
  uses the primary CTA, it predates this story, and AC2 scopes the CTA check to
  gradient and glow. Not changed here to avoid a cross-screen visual change.
- The secondary link sits ~13px lower than the reference, from `TextButton`'s
  default internal padding on top of the screen's existing `CupidSpacing.sm`
  gap. Not among D1's four deviations, and adjusting it would be a layout change
  AC6 excludes.

## Verification Commands

| Command | Result |
|---------|--------|
| `flutter analyze lib test` | PASS — 80 issues, all `info`, 0 errors, 0 warnings; byte-identical to the pre-change baseline (exit 1 is expected, infos are counted) |
| `flutter test test/features/pairing test/design_system test/app` | PASS — 170/170, includes `pairing_choice_screen_test.dart`, `no_fork_guard_test.dart`, `theme_matrix_test.dart`, `cupid_app_background_test.dart` |
| `flutter build apk --debug -t lib/main_preview.dart` | PASS — `build/app/outputs/flutter-apk/app-debug.apk` |
| `adb -s emulator-5560 install -r ...` | PASS |
| `capture-mobile-screen.sh --device=emulator-5560 --route=cupidpreview://screen/pairingchoice` | `MOBILE_CAPTURE: OK ... 405x900` |
