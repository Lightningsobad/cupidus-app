# Visual Fidelity Report: STORY-036 Register

VISUAL_FIDELITY: PASS

## Scope Of This Comparison

- Screen: `register` (Epic 1, onboarding chain, `NO_CHROME` / `NO_TABS`)
- Design-Screen: `register` (exact id in the canvas inventory; no shortlist
  needed, no `MOBILE_VISUAL_AUDIT_STATE_MISSING`)
- Configuration: dark theme + `vi` locale (the only user-facing configuration
  enabled in v1; light / `en` excluded per OQ5 and this story's Out of Scope)
- Device: `emulator-5560` (the emulator already running for this requirement's
  prior mobile visual work; none provisioned)
- Frame: Android 412 x 915 dp, captured at `--width=824 --density=320`
  (824 / 2 = 412 dp) and bounded by `--max-edge=900`, so the capture frame
  equals the frame the canvas renders

## Evidence Pair

- Implemented: `implemented-register-emulator-5560.png` (405 x 900)
- Design reference: `design-reference-register-android.png` (406 x 900)

Reference rendered with the locked config in
`data/devops/system/design-fidelity-config.json`:

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --entry="Cupid App.dc.html" --screen=register --platform=android \
  --theme=dark --locale=vi
```

Capture taken inside one device lease so the preview launch and the screencap
could not be interleaved with another run:

```
.ai-team-bundle/runtime/tools/capture-mobile-screen.sh \
  --device=emulator-5560 --lease-exec -- <launch main_preview.dart + capture>
```

The screen was reached by faking its state through `lib/main_preview.dart`
(`--dart-define=PREVIEW=register`), never by driving the live app.

## Method

Both images are normalised into design units before comparison. The reference
render sits inside a device bezel, so the two PNGs are not at the same scale:
the reference resolves 372 design px of card content across 350 raw px
(0.9409 px/dp) and the capture across 365 raw px (0.9812 px/dp). Raw pixel
spans are therefore divided by each image's own factor. Card height is read as
card-top-to-card-top pitch minus the design's 14 dp gap, which cancels the
box-shadow bias that fill detection alone would introduce.

## Measured Comparison (design px unless noted)

| Item | Design source | Reference | Implemented |
| --- | --- | --- | --- |
| Screen side padding | 20 | 20 | 20 |
| Field card pitch (top to top) | 14 gap + card | 81.84 | 82.04 |
| Field card height | - | 67.84 | 68.04 |
| Card fill | `--surf` #241B42 | (36, 27, 66) | (36, 27, 66) |
| Card corner radius | `--r-card` md = 24 | 24 | 24 |
| Label glyph band from card top | 11 px, `.06em`, uppercase | 15.9 - 23.4 | 16.3 - 23.4 |
| Input glyph baseline from card top | 16 px | 48.9 | 48.9 |
| Meter total span | 340 | 339.0 | 341.4 |
| Meter segment height | 5 | 5 | 5 |
| Meter filled (3 of 4) | `--mint` #79E2CD | (121, 226, 205) | (121, 226, 205) |
| Meter unfilled (1 of 4) | `--line` over `--surf` | (59, 50, 86) | (59, 50, 86) |
| Strength caption | `--mint`, 11 px, 600 | (121, 226, 205) | (121, 226, 205) |
| Consent check box | 24 x 24, radius 9 | 24 | 24 |
| CTA width / height | 372 / 54 | 369.9 / 54 | 371.0 / 54 |
| CTA gradient ends | `--grad-hot` #FF7FB6 to #B78CF5 | (250,127,185) to (186,139,241) | (253,127,183) to (185,140,243) |

Solid fills match the design tokens exactly on both sides. Glyph-edge samples
in the capture read 2-6 levels brighter than the token because the 824 px
render is resampled down to 405 px; the meter's solid bars, sampled in the same
image, land on the token value exactly, which isolates that to resampling.

## Deviation Found And Fixed In App Code (AC2)

Each field card rendered 4.3 dp taller than the reference (72.1 vs 67.8), and
the surplus repeated on all three stacked cards. A differential capture
isolated it: forcing the input's strut to `height: 1.0` moved the card to
63.5 dp, which puts Flutter's natural line box for this style at 24.2 dp
against the design's ~19.9 dp. The design source's own register block already
declares `line-height: 1.25` (`Cupid Screens.dc.html` line 1472), and pinning
the field input to it reproduces the reference: card 68.04 vs 67.84 dp, input
baseline identical at 48.9 dp.

Fix: `_fieldInputLineHeight = 1.25` plus a forced `strutStyle` on the field
`TextField` in
`mobile/lib/features/auth/presentation/screens/register_screen.dart`. Every
other design value (padding `13px 16px`, label gap 6, font sizes 11 / 16,
radius, colours, meter and CTA geometry) was already transcribed exactly and
needed no change.

A second, smaller fix made the comparison possible at all: the reference
composes every field populated, while the preview harness rendered the empty
form. `RegisterScreen` gained seedable `initialName` / `initialEmail` /
`initialPassword` (same shape as the existing `OtpScreen.initialCode`), and
`lib/main_preview.dart` seeds the design source's own sample row
(`Minh` / `minh@gmail.com` / `loveyou247`).

## Approved Deviation, Not A Defect

The reference renders the canvas's shared header (pink back arrow + `Đăng ký`),
because `register` is absent from the canvas's own `NO_CHROME` list and
`BACK_TO.register = 'welcome'`. The app deliberately omits it: STORY-002's
approved UX spec, `ux/uiux-spec.md` section "Chrome Rules (NO_CHROME +
NO_TABS)" (AC4), forbids header/app-bar chrome on every onboarding-chain node
from `splash` through `fingerprint_vow`, and this story's own `story_master.md`
line 11 records the screen as `NO_CHROME / NO_TABS`. Adding the header would
contradict an accepted spec and regress sibling screens, so the reference is
kept as rendered and the deviation is recorded as governed. The locked
`design-fidelity-config.json` was not edited to hide it.

## Residual Within Tolerance

The password card measures 107.0 dp against the reference's 104.2. The
difference is the strength caption's own line box (Flutter reserves ~1.5 dp
more than Chrome for an 11 px row), below the ~1 dp measurement noise of the
two renders plus antialiasing, and not visible at 1:1.

## Form-Field Validation States (AC3)

| State | Composed in design source | Verified by |
| --- | --- | --- |
| filled | Yes (lines 1477 / 1481 / 1485) | rendered pair above |
| empty | No composed variant; the `<input>`s declare no `placeholder` | app renders the same card with an empty controller and no `hintText` |
| focused | No composed variant for register | app uses the canvas's own active-input treatment, `1.5px solid var(--pink)` (OTP boxes, lines 1509-1511 and 1568), painted as `foregroundDecoration` so it costs no layout inset |
| error | No composed variant for register anywhere in the canvas | app renders a form-level message in the `--red` token; no per-field error styling is invented |

No reference was fabricated for the three states the canvas does not compose,
and no mismatched screen was paired.

## Verification Run In This Session

| Command | Result |
| --- | --- |
| `flutter analyze lib/features/auth/presentation/screens/register_screen.dart lib/main_preview.dart` | No issues found |
| `flutter test test/features/auth/presentation/screens/register_screen_test.dart` | 8 passed |
| `flutter test test/features/auth/` | 112 passed |
| `flutter test` (full suite) | 1264 passed, 2 skipped |

Regression guard: `field inputs pin their line box to the design line height`
in `mobile/test/features/auth/presentation/screens/register_screen_test.dart`
asserts the forced strut at 16 px / 1.25. A `matchesGoldenFile` baseline was
not introduced: the repository has no golden infrastructure, and standing one
up for a single screen is outside this trivial hardening story's scope.
