VISUAL_FIDELITY: PASS

# Invite (tạo mã) — Rendered Visual Fidelity

## Scope Of This Comparison

Closes the missing-evidence gap left by STORY-011 (RWB-20260816-004): STORY-011
asserted invite fidelity without a rendered same-screen evidence pair. This
report re-runs STORY-011's own AC scope — layout, spacing, colour/token usage,
typography, and the code-display / share-component styling including the mono
type treatment — against a real rendered reference and a real device capture.

Out of scope per the story: light theme and `en` locale (OQ5), and the couple-type
picker / "Tiếp tục → Đợi ghép" block that the canvas draws *below* the invite
card (STORY-011 plan §1 D2 places those on separate nodes).

Theme: dark. Locale: `vi`. Platform frame: Android.

## Evidence Pair

| Role | Path | Size |
| --- | --- | --- |
| Design reference | `design-reference-invite-android.png` | 406×900 |
| Implementation | `implemented-invite-emulator-5560.png` | 405×900 |

Both live in this story's own `visual-fidelity/` directory. Nothing was moved,
edited, or deleted in STORY-002's, STORY-011's, STORY-034's, STORY-035's or
STORY-036's evidence directories.

## Method

- Reference: `render-design-canvas.js` over
  `cupid-app-design-system/project/Cupid App.dc.html`, `--screen=invite`,
  `--plat=and`, `--theme=dark`, `--lang=vi` (the same route STORY-036 used for
  `--screen=register`).
- Implementation: `capture-mobile-screen.sh` (adb `exec-out screencap`) on
  `emulator-5560` at `--width=824 --density=320`, driving `lib/main_preview.dart`
  with `--dart-define=PREVIEW=invite`.
- Fixture: the preview entry seeds `InviteCubit` with the design canvas' own
  sample invitation (`CPD-8F2K`, 24 h TTL). Without it the unauthenticated
  preview session renders `InviteFailed`, so the capture would not show the code
  card the canvas id names.
- Normalisation: each PNG carries its own px/dp factor, derived from the known
  372 dp card width (412 dp frame − 2 × 20 dp screen padding):
  reference **0.9409 px/dp**, capture **0.9812 px/dp**. All figures below are
  design dp.
- Card edges are probed 4 px inside the left border and corrected for the 24 dp
  corner radius by `r − sqrt(r² − (r − d)²)`.
- The reference PNG carries ≈9.8 dp of page backdrop outside the 412 dp device
  frame on each side; screen-relative paddings are computed after removing it.

## Measured Comparison (design dp)

| Property | Design source | Reference | Implementation | Verdict |
| --- | --- | --- | --- | --- |
| Card width | 372 | 372.00 (anchor) | 372.00 (anchor) | PASS |
| Screen side padding | 20 | 20.00 | 20.38 | PASS |
| Screen backdrop, top-left | `--sky` layer 1 over `--bg` → (61,29,98) | (64,29,102) | (61,29,98) | PASS |
| Screen backdrop, top-right | `--sky` layer 2 over `--bg` → (93,34,71) | (87,33,68) | (93,35,71) | PASS |
| Screen backdrop, left mid | `--bg` #171129 → (23,17,41) | (28,21,51) | (23,17,41) | PASS |
| Screen backdrop, bottom centre | `--sky` layer 3 over `--bg` → (21,36,54) | (20,37,54) | (21,36,54) | PASS |
| Card fill | `--surf` #241B42 → (36,27,66) | (36,27,66) | (36,27,66) | PASS |
| Label ink top from card top | 22 pad + leading | 24.18 | 25.91 | PASS (Δ1.73) |
| Label ink width | "Mã ghép đôi của bạn" 12.5 px | 121.17 | 119.24 | PASS (Δ1.93) |
| Label ink centre offset | 0 (centred) | +0.00 | +0.00 | PASS |
| Code ink width | Roboto Mono 36 / ls .16em | 212.57 | 211.99 | PASS (Δ0.58) |
| Code ink centre offset | −2.88 (trailing ls) | −3.19 | −2.55 | PASS |
| Code gradient left | `--pink` #FF7FB6 → (255,127,182) | — | (255,128,184) | PASS |
| Code gradient right | `--purple` #B78CF5 → (183,140,245) | — | (190,141,244) | PASS |
| Countdown ink height | 11.5 px caption | 13.82 | 13.25 | PASS |
| Share pill height | 48 | 49.95¹ | 47.90 | PASS |
| Share pill width | 275 (332 − 48 − 9) | 268.90¹ | 274.16 | PASS (Δ0.84) |
| Share pill left inset | 20 | 21.26¹ | 20.38 | PASS |
| Share gradient left | (255,127,182) | (251,127,185) | (254,127,183) | PASS |
| Share gradient right | (183,140,245) | (186,139,241) | (184,140,244) | PASS |
| Pill icon → label gap | 8 (+ side bearings) | 13.82 | 14.27 | PASS (Δ0.45) |
| Share label ink width | "Gửi link mời" 15 px / 700 | 81.84 | 76.44 | Residual R1 |
| Action row gap | 9 | — | 8.97 | PASS |
| Copy button width | 48 | — | 47.90 | PASS |
| Copy button height | 48 | — | 47.90 | PASS |
| Copy border colour | `--line` over surf → (59,50,86) | — | (59,50,86) | PASS |
| Copy border thickness | 1.5 | — | 1.02–2.04² | PASS |
| Copy right inset from card edge | 20 | — | 20.38 | PASS |
| Card height | see closure below | 204.60 | 228.13 | Explained |

¹ Reference-side detector artefact, see R2. ² Two rendered px at 0.9812 px/dp.

Design source for every "Design source" cell:
`cupid-app-design-system/project/Cupid Screens.dc.html:176-186` (the `isInvite`
block) plus the `--surf` / `--line` / `--pink` / `--purple` / `--grad-hot` /
`--r-card` / `--r-btn` / `--sky` / `--bg` token block at lines 23-26.

The four screen-backdrop rows probe the region *outside* the card, which the
earlier revision of this report did not cover (Reviewer B1). Their "Design
source" column is not eyeballed: the dark-theme `--sky` value at line 26 is
three `radial-gradient(... , transparent N%)` layers, and each expected RGB is
the analytic composite of those layers — premultiplied-alpha ramp
`a(t) = a₀ · max(0, 1 − t/stop)` over the elliptical distance `t`, painted
bottom-up (teal, pink, purple) over `--bg` — evaluated at the same normalised
frame coordinate sampled in both PNGs. The implementation reproduces the
computed composite exactly at three of the four probes and within 1 unit at the
fourth. Each sample is the median of a 7×7 patch so a star-layer dot cannot
skew it.

## Card-Height Closure

The 23.53 dp card-height difference resolves completely, with no app-side
spacing deviation left over:

| Component | dp |
| --- | --- |
| Governed extra caption line ("Mã 6 ký tự"), measured as the app's own caption line pitch (ink tops 109.48 → 124.77) | +15.29 |
| Code line-box difference (reference code ink top 56.06 vs implementation 65.65) | +9.59 |
| Sum | +24.88 |
| Measured card-height difference (204.60 → 228.13) | +23.53 |
| Unexplained residual | −1.35 |

Every declared box-model value in the app matches the markup exactly: card
padding `22px 20px`, code margin `10px 0 4px`, action row `margin-top:18px`,
action height 48, action gap 9. The residual is inside the ±2 dp edge-detection
floor.

## Reference Artefact: Roboto Mono Falls Back To A Serif

The reference render loads Roboto, Nunito and Material Symbols Rounded
correctly — the icons and every UI text run are right — but resolves
`font-family:'Roboto Mono'` to a serif fallback, which is visible in the
rendered `CPD-8F2K` glyphs. A serif fallback's hhea box is ≈1.15 em versus
Roboto Mono's ≈1.32 em, i.e. ≈6.1 dp shorter at 36 px, plus a different
ascent split. That is the whole of the 9.59 dp code line-box difference above.

The reference's code *pixels* are therefore not a valid target for the mono
treatment. The mono treatment was instead verified against the design markup
and confirmed by an independent width prediction:

- Markup: `font-family:'Roboto Mono';font-weight:500;font-size:36px;letter-spacing:.16em`.
- App: `type.labelMono` (family `Roboto Mono`) with `_codeFontSize = 36`,
  `fontWeight: FontWeight.w500`, `_codeLetterSpacing = 36 × 0.16 = 5.76`.
- Predicted ink width for 8 glyphs at 0.6 em advance: `8 × (21.6 + 5.76) − 5.76 −
  side bearings ≈ 211`. Measured **211.99**.

## Deviations Found And Fixed In App Code (AC2)

**D1 — share CTA Vietnamese label.** The rendered comparison surfaced a copy
deviation STORY-011 did not catch. The design source is
`<span data-vi>Gửi link mời</span><span data-en>Share invite</span>`
(`Cupid Screens.dc.html:183`); the app shipped `Chia sẻ mã mời` for `vi`. The
`en` string already matched.

Fixed in app code, not documented around:
`mobile/lib/features/pairing/presentation/screens/invite_screen.dart:385`

```dart
context.viEn('Gửi link mời', 'Share invite'),
```

**D2 — Scaffold background override occluded the app-shell backdrop**
(Reviewer B1). `invite_screen.dart` set `backgroundColor: colors.colorBackground`
on its `Scaffold`, painting a flat `--bg` fill over the shared
`CupidAppBackground` layer that `cupid_app.dart:59` mounts behind every screen.
The whole `--sky` gradient wash and the star layer were therefore invisible on
this node. Removed, following the `forgot_screen.dart:103-106` precedent from
REQ-002 STORY-032 AC1:

`mobile/lib/features/pairing/presentation/screens/invite_screen.dart:170-176`

```dart
return Scaffold(
  // backgroundColor override intentionally removed (REQ-002 STORY-032
  // AC1): the shared CupidAppBackground app-shell layer now paints the
  // sky-gradient wash behind every screen; a Scaffold-level solid fill
  // here would occlude it.
  body: SafeArea(
```

The now-unused `colors` local and its no-fork-guard comment went with it; every
other token access in the file is unchanged.

Re-verified with a fresh render pair after each fix: the
`implemented-invite-emulator-5560.png` in this directory is the post-D2 capture,
and every implementation figure in the tables above comes from it. Card geometry
is byte-for-byte unaffected by D2 — all ink bands moved by a uniform +1.02 dp,
which is one rendered pixel of card-top edge detection now that the card sits on
a gradient rather than a flat fill; every relative spacing, width, and colour is
identical to the pre-D2 capture.

## Approved Deviations, Not Defects

| # | Deviation | Governing decision |
| --- | --- | --- |
| G1 | Reference draws the shared header (back arrow + title); the app has none | The canvas' own `NO_CHROME` map (`Cupid Screens.dc.html:1960`) omits `invite`, but STORY-002's approved `ux/uiux-spec.md` "Chrome Rules" places every node from `splash` through `fingerprint_vow` — `invite` included — under NO_CHROME/NO_TABS (AC4). The app keeps the back edge as an in-body pink affordance (`_InChainBackButton`). App chrome was **not** altered to match the reference. |
| G2 | Extra caption line "Mã 6 ký tự" | UX spec §3 correction: the backend emits a 6-character code, so the canvas' non-hex placeholder needs the character-count hint. |
| G3 | "Hết hạn sau 23h 59p" live countdown vs the mockup's static "Hết hạn sau 15 phút" | Frozen backend contract is a 24 h invitation TTL (STORY-011 D-list). |
| G4 | Couple-type picker and the "Tiếp tục → Đợi ghép" / "Continue → Waiting" CTA absent below the card (`Cupid Screens.dc.html:209`, `onClick="{{ goWaiting }}"`) | STORY-011 plan §1 D2 — separate nodes in the approved flow. |

## Residuals Within Tolerance

- **R1 — share label ink width, Δ5.40 dp on a ≈78 dp string.** Both sides
  declare Roboto 15 px / 700: the canvas sets `--fs-ui: Roboto,system-ui,sans-serif`
  on the Android platform frame (`Cupid Screens.dc.html:25`), and the app's
  `.material()` platform tokens set `uiFontFamily = 'Roboto'`. The difference is
  the Google Fonts static 700 instance versus the bundled `Roboto-Variable.ttf`
  at `wght` 700, plus ±1 rendered px of edge quantisation at each end (±2.1 dp
  reference, ±2.0 dp capture). Both rows are centre-aligned, so no spacing token
  is affected.
- **R2 — reference pill height 49.95 and width 268.90 against a design 48 × 275.**
  The `--glow` bleed inflates the reference pill's bright-run height and its
  rounded ends deflate the bright-run width. The implementation measures
  47.90 × 274.16 under the identical detector.
- **R3 — reference PNG page backdrop.** ≈9.8 dp per side outside the 412 dp
  device frame; removed before computing screen-relative paddings.

## Verification Run In This Session

| Command | Result |
| --- | --- |
| `flutter analyze lib/features/pairing/presentation/screens/invite_screen.dart lib/main_preview.dart` | 0 errors, 0 warnings. The same 3 pre-existing `info` `prefer_initializing_formals` at `invite_screen.dart:73,74,102`; those constructor lines are outside this story's diff. Re-run after D2 to confirm dropping the `colors` local left no unused-variable warning. |
| `flutter test test/features/pairing test/design_system/no_fork_guard_test.dart` | **All tests passed!** (98 tests) — re-run after D2. |

## Files Changed

- `mobile/lib/features/pairing/presentation/screens/invite_screen.dart` — D1 copy
  fix and D2 background-override removal.
- `mobile/lib/main_preview.dart` — `invite` preview entry now seeds a fixture
  `InviteCubit` so the canvas id renders its code card instead of `InviteFailed`.
