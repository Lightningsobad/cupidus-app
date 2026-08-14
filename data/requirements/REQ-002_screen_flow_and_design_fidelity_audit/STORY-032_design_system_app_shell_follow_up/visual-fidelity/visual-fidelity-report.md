# Visual Fidelity Report: STORY-032 — Design System / App Shell Follow-Up

Story: STORY-032 Design System and App Shell Follow-Up
Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Lane: mobile
Configuration audited: dark theme + `vi` locale, Material platform
Design source: `cupid-app-design-system` (locked)

## Verdict

VISUAL_FIDELITY: PASS

The verdict covers the STORY-032 acceptance criteria (AC1 shared background
reach, AC2 `CupidPrimaryButton` restyle, AC3 `CupidHeader` restyle,
AC4 re-render of the two named screens). It does **not** claim whole-screen
parity with the design reference: two of the three screens carry pre-existing
content deviations that STORY-032 neither introduced nor owns. Each is named
under its screen below and again in "Deviations outside STORY-032 scope", so
nothing is absorbed into the PASS silently.

Per-screen verdicts: Forgot Password PASS, Waiting For Pairing PASS,
Vibe Check (`CupidHeader` carrier) PASS. 3/3.

On-device re-verification of those verdicts is partial. `forgot` confirms AC2
and `vibe` confirms AC3 on a real Android surface; `waiting` is inconclusive.
AC1 — the shared background reach — is not testable through the on-device
harness at all, because the preview entrypoint does not mount
`CupidAppBackground` (Finding F1). AC1's evidence therefore remains the
headless raster alone, which does mirror the real composition root. No
on-device result contradicts a recorded verdict; two confirm, one abstains.

## Design Source Resolution

`data/devops/system/design-fidelity-config.json` declares
`design_source.locked: true` and `ui_surface: true`, so the rendered
design-fidelity check is mandatory and non-waivable for this story. Screens
are canvas states of the entry file, addressed by id via
`render-design-canvas.js --screen=<id>`, not separate files.

| Screen in this story | `Design-Screen` id | Design source panel |
| --- | --- | --- |
| Forgot Password | `forgot` | `Cupid Screens.dc.html` canvas state `forgot` |
| Waiting For Pairing | `waiting` | `Cupid Screens.dc.html` canvas state `waiting` |
| Vibe Check (AC3 `CupidHeader` carrier) | `vibe` | `Cupid Screens.dc.html` canvas state `vibe`; shared header block at `Cupid Screens.dc.html:50-56` |

### Provenance of the design-reference renders

The three `design-reference-<id>-android.png` files in this directory are
byte-identical copies of the renders committed by
`REQ-001/STORY-018_design_fidelity_capture` (commit `124d816`), verified by
sha256:

| File | sha256 |
| --- | --- |
| `design-reference-forgot-android.png` | `480540c9910cca7a2c9306790f564bf2927c8a488246507433b0ca9a962d45ec` |
| `design-reference-waiting-android.png` | `e4478f054ad473408d283dcf4dc482ac11c2ce44a197c7b79d24903621f4564d` |
| `design-reference-vibe-android.png` | `764d5b66bf7825e516e41f048bb6efd7c2792106963fa99a56622c8f544bc84f` |

Reuse is valid rather than stale: the design bundle's last change is commit
`5ea820c` (2026-08-11 23:22:59 +0700) and it is an ancestor of `124d816`
(2026-08-12 14:33:58 +0700), so those renders were produced from the same
locked export that is checked out now. No re-render was needed and the
`content_fingerprint` in the config is unchanged.

## Evidence

Two independent app-side renders exist per screen. They are complementary, and
neither alone covers the story: the headless raster mirrors the real
composition root but not the platform, the on-device capture is the real
platform but — as [Finding F1](#f1--the-preview-harness-does-not-mount-cupidappbackground)
records — not the real composition root.

| Screen | Design reference | Headless raster | On-device capture (`emulator-5560`) |
| --- | --- | --- | --- |
| `forgot` | `design-reference-forgot-android.png` (406x900) | `ac4-forgot-password-dark-vi.png` | `implemented-forgot-emulator-5560.png` (405x900) |
| `waiting` | `design-reference-waiting-android.png` (406x900) | `ac4-waiting-for-pairing-dark-vi.png` | `implemented-waiting-emulator-5560.png` (405x900) |
| `vibe` | `design-reference-vibe-android.png` (406x900) | `ac3-vibe-header-dark-vi.png` | `implemented-vibe-emulator-5560.png` (405x900) |

Scale parity on the on-device set is native, not forced: `emulator-5560`
reports `wm size 1080x2400` / `wm density 420`, i.e. 411.4 x 914.3 dp, which
already equals the design canvas's Android frame (412x915). No display
override was applied.

Exact commands (run from the control checkout, which owns `.ai-team-bundle`):

```
# one debug build; the debug manifest carries the cupidpreview:// intent filter
flutter build apk --debug -t lib/main_preview.dart \
  --dart-define=PREVIEW=forgot --dart-define=PREVIEW_BRIGHTNESS=dark

# install once, then switch screens at runtime by deep link, all three captures
# inside ONE device lease (sibling mobile-dev runs share these emulators and
# overwrite com.snapsofts.cupid)
capture-mobile-screen.sh --device=emulator-5560 --lock-timeout=900 --lease-exec -- \
  <install; per screen: force-stop, am start -d cupidpreview://screen/<id>, capture>
```

## Captures

| App render | Design reference | `Design-Screen` | AC states compared |
| --- | --- | --- | --- |
| `ac4-forgot-password-dark-vi.png` | `design-reference-forgot-android.png` | `forgot` | AC1, AC2, AC4[Forgot Password] |
| `ac4-waiting-for-pairing-dark-vi.png` | `design-reference-waiting-android.png` | `waiting` | AC1, AC4[Waiting For Pairing] |
| `ac3-vibe-header-dark-vi.png` | `design-reference-vibe-android.png` | `vibe` | AC1, AC3, AC5 |

App renders are 1170x2532 (390x844 logical at devicePixelRatio 3). Design
references are 406x900 inside the canvas's Android device frame. The two sides
therefore differ in scale and in chrome: the reference includes an OS status
bar and device bezel that the app render does not. Comparisons below are on
layout, colour, and treatment, not on pixel coordinates.

## Capture Method

Headless rasterization inside `flutter test`: the screen is pumped under a
`MaterialApp` that mirrors `CupidApp`'s composition root
(`builder: (context, child) => CupidAppBackground(child: child!)`,
`buildCupidTheme(platform: CupidPlatform.material, brightness: Brightness.dark)`,
`locale: const Locale('vi')` with `AppL10n.localizationsDelegates`), then the
root `RenderRepaintBoundary` is written out with `toImage(pixelRatio: 3)` inside
`tester.runAsync()`.

The harness for the AC3 capture is committed next to the evidence as
`capture_cupid_header.dart` and is run from the `mobile/` package root:

```
flutter test ../data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-032_design_system_app_shell_follow_up/visual-fidelity/capture_cupid_header.dart
```

It lives here rather than under `mobile/test/` because this story's declared
write scope covers its own artifacts, not a new file in the app's test tree.
Two details that matter for reproducing any of these files:

- The app's four bundled families (`Nunito`, `Roboto`, `Roboto Mono`,
  `Material Symbols Rounded`) are installed with `FontLoader` in `setUpAll`.
  Without that step `flutter test` renders the placeholder test font and the
  capture is unreadable.
- The frame is taken at elapsed 2600ms. The three stars have 3400/4600/5200ms
  periods and 0/800/1600ms start delays, so they share no common peak; 2600ms
  is the instant at which all three sit well above their 0.25 rest opacity.

The two AC4 captures predate the committed harness and were produced by the
same parameters; `capture_cupid_header.dart` is the executable record of them.

## Per-Screen Findings

### Forgot Password

Design-Screen: `forgot`
App render: `ac4-forgot-password-dark-vi.png`
Design-Reference: `visual-fidelity/design-reference-forgot-android.png`
Implemented-Capture: `visual-fidelity/implemented-forgot-emulator-5560.png`
AC states compared: AC1, AC2, AC4[Forgot Password]
VISUAL_FIDELITY: PASS

On-device capture verdict: **CONFIRMS for AC2/AC4, cannot test AC1.** The
capture reproduces the gradient CTA and the full content stack exactly as the
headless raster and the reference show them — the `--grad-hot` pink-to-purple
band, the `--glow` bloom beneath it, the lock tile, headline, `EMAIL` card and
mint Private Gallery note all land in the same order at the same treatment.
AC2 is therefore proven on a real Android surface, not only in a widget test.
AC1 is untestable from this capture: the harness renders the screen without
`CupidAppBackground`, so the sampled background is `#000000` at all six probe
points rather than the reference's `#3D1C62` / `#582145` wash. See Finding F1.

Matches the reference on every element AC1/AC2/AC4 govern:

- **Background (AC1).** The reference's three-lobe sky wash — purple top-left,
  pink top-right, teal bleeding up from the bottom — is present in the app
  render at the same distribution and reaches full bleed. Before Phase 2 this
  screen painted `colorBackground` edge to edge through its own `Scaffold`, so
  none of it was reachable.
- **Primary CTA (AC2).** Both sides render "Gửi link đặt lại" as a full-width
  rounded band filled with `--grad-hot` (120deg `#FF7FB6` to `#B78CF5`) and
  carrying the `--glow` drop shadow (`0 8px 28px rgba(255,107,168,.34)`),
  visible as the pink bloom under the button. Label weight, gradient direction
  and the glow's offset all correspond.
- **Supporting content.** Lock tile, headline "Quên mật khẩu là chuyện
  thường", subcopy, `EMAIL` field and the mint Private Gallery note appear in
  the same order and styling on both sides.

Twinkle stars: two of the three are discernible. The left star lands at
logical (31, 118), directly behind the opaque headline, so the content
occludes it. That is the real composition — the star layer is painted below
`widget.child` in `CupidAppBackground` by design — and its presence in the
tree is asserted structurally in
`mobile/test/design_system/cupid_app_background_test.dart` rather than
visually here.

State difference, not a defect: the reference shows a seeded email
(`minh@gmail.com`) while the app render shows the empty field. Different form
state, same field styling.

Out-of-scope deviation: the reference carries a `CupidHeader` (pink back
glyph + "Quên mật khẩu" title) that the app render has no equivalent for.
`forgot_screen.dart:99` mounts a bare `Scaffold` with no `appBar`, so there is
no header on this screen for STORY-032 to restyle. Pre-existing composition
gap, not introduced here. See "Deviations outside STORY-032 scope".

### Waiting For Pairing

Design-Screen: `waiting`
App render: `ac4-waiting-for-pairing-dark-vi.png`
Design-Reference: `visual-fidelity/design-reference-waiting-android.png`
Implemented-Capture: `visual-fidelity/implemented-waiting-emulator-5560.png`
AC states compared: AC1, AC4[Waiting For Pairing]
VISUAL_FIDELITY: PASS

On-device capture verdict: **INCONCLUSIVE — neither confirms nor contradicts.**
This screen's only in-scope claim is AC1, and AC1 is exactly what the on-device
harness cannot render (Finding F1; background samples `#000000` at all six
probe points). The capture is additionally off-state: it shows the paired
terminal state ("Đã ghép đôi! 🎉") rather than the waiting state, because
`main_preview.dart:394` builds `WaitingScreen` with only an `expiresAt` while
the screen resolves pairing from the live seeded preview session, which is
already paired. See Finding F2. The recorded PASS still rests on the headless
raster, which does mirror the real composition root; it has not been
independently re-confirmed on device.

- **Background (AC1).** The sky wash matches the reference lobe for lobe, and
  all three twinkle stars are visible and land where the design source places
  them: white 6px at `left 8% / top 14%`, pink 4px at `right 16% / top 9%`,
  purple 5px at `right 7% / top 26%` (`Cupid Screens.dc.html:45-47`). Nothing
  occludes them on this screen, so this render is the cleanest proof that the
  shared star layer reaches a Phase 2 screen.
- **AC4's "restyled CTA/header" clause is vacuous here.** This screen mounts
  neither `CupidHeader` nor `CupidPrimaryButton`; its "Làm mới" is an outline
  pill. AC4 reduces to the background wash on this screen, and that is what
  the render proves.

Out-of-scope deviation: the reference shows a fuller, personalized state —
hourglass glyph inside a ringed circle, "Đang đợi Linh vào…" with the partner
name, invite-code card (`CPD-8F2K`), and a "Gửi lại" gradient CTA next to a
simulate-join control. The app renders a generic simplified state: flat pink
circle with no glyph or ring, "Đang chờ người ấy…", and only the outline
refresh pill. This is the same DEVIATION REQ-001/STORY-018 already recorded
for `waiting`; it is screen-content scope, untouched by this story's one-line
`backgroundColor` removal.

### Vibe Check — AC3 `CupidHeader` carrier

Design-Screen: `vibe`
App render: `ac3-vibe-header-dark-vi.png`
Design-Reference: `visual-fidelity/design-reference-vibe-android.png`
Implemented-Capture: `visual-fidelity/implemented-vibe-emulator-5560.png`
AC states compared: AC1, AC3, AC5
VISUAL_FIDELITY: PASS

On-device capture verdict: **CONFIRMS AC3, cannot test AC1.** The capture shows
the `CupidHeader` with no opaque band — the specific deviation AC3 forbids —
carrying the pink back glyph and the Nunito w800 "Vibe Check" title, matching
the reference. This also closes the "Known Gap" the previous revision of this
report left open: the header is now verified on a real Android surface, where
`BackdropFilter` goes through platform compositing rather than the test
rasterizer, and it composites correctly. AC1 remains untestable here for the
same reason as the other two screens (Finding F1).

This capture exists to give AC3 the visual proof it previously lacked.
`vibe_screen.dart:79` mounts an unmodified `CupidHeader` with a `title` and an
`onBack`, so both the surface treatment and the back glyph are exercised. The
screen is otherwise unchanged by this story beyond its `backgroundColor`
removal.

Compared against the design source header block at
`Cupid Screens.dc.html:50-56`:

| Design source value | Design reference | App render |
| --- | --- | --- |
| `background:transparent` | header sits directly on the sky wash, no band | the purple lobe continues unbroken through the header strip; no opaque edge at the header's bottom boundary | 
| `backdrop-filter:blur(16px)` | smooth gradient behind, blur visually inert | same — gradient backdrop, no visible seam (see note below) |
| back glyph `font-size:26px; color:var(--pink)` | pink left-pointing arrow | pink left-pointing arrow at the same relative size and inset |
| title `Nunito 800 21px`, ellipsized | "Vibe Check" | "Vibe Check", same weight and face |

The header renders with no opaque band, which is the specific deviation AC3
forbids. Body copy renders in Vietnamese, confirming the `vi` locale is
active; "Vibe Check" is a brand string and is identical on both sides.

Note on the blur: with a smooth gradient behind it and `extendBodyBehindAppBar`
unset, a 16-sigma `BackdropFilter` is close to a visual no-op, so this capture
confirms the header is transparent and correctly composited but cannot by
itself distinguish sigma 16 from another sigma. The design source header is
likewise `flex:none` in normal flow with the page background behind it, so
this is faithful rather than a shortfall. Exact sigma, `BackdropFilter` count
per platform, transparent `AppBar.backgroundColor` and the `--pink` back glyph
remain asserted in `mobile/test/design_system/adaptive_widgets_test.dart`;
render and assertions are complementary here, and AC3 now has both.

Out-of-scope difference: the reference includes the 5-tab bottom `CupidTabBar`
and a seeded partner card; the capture harness mounts `VibeScreen` standalone
with an empty repository, so it shows neither. Harness framing, not a screen
defect — the header, which is what AC3 governs, is unaffected.

## Deviations Outside STORY-032 Scope

Recorded so the requirement-level audit picks them up and so no reader mistakes
them for regressions from this story. None is caused by this story's diff,
which removes per-screen `Scaffold` `backgroundColor` overrides and restyles
two shared components.

1. **Forgot Password has no header.** Design shows a `CupidHeader` with back
   affordance and title; `forgot_screen.dart:99` has no `appBar`. Screen
   composition scope.
2. **Waiting For Pairing renders a generic state.** Missing hourglass glyph and
   ring, partner name, invite-code card and resend CTA versus the design's
   personalized state. Matches STORY-018's existing `waiting` DEVIATION row.
   Screen content/data scope.

## Findings From The On-Device Pass

Both are defects in the capture harness, not in the shipped app, and both are
in `mobile/lib/**` — outside this evidence-only run's WriteScope. They are
recorded here rather than patched.

### F1 — the preview harness does not mount `CupidAppBackground`

`mobile/lib/design_system/theme/cupid_theme.dart:45` sets
`scaffoldBackgroundColor: Colors.transparent`, with the adjacent comment at
line 43 stating that `CupidAppBackground` "owns the base fill now, one layer
above every route". `mobile/lib/app/cupid_app.dart:43-44` mounts it for the
real app. `mobile/lib/main_preview.dart:532-533` does not: it spends
`MaterialApp.builder` on `MediaQuery.withNoTextScaling` and never wraps the
child.

Consequence: every screen captured through the preview entrypoint renders a
transparent `Scaffold` over nothing. Measured background at six probe points
(corners plus mid-edges) on all three captures:

| Render | TL | TR | BL / BR |
| --- | --- | --- | --- |
| `implemented-*-emulator-5560.png` (all 3) | `#000000` | `#000000` | `#000000` |
| `design-reference-forgot-android.png` | `#3D1C62` | `#582145` | `#171129` |

Not even `colorBackground` (`#171129`) survives, which is what makes this
unambiguous rather than a brightness judgement call.

This is a regression *introduced by this story*: before Phase 2 each screen
painted `colorBackground` through its own `Scaffold`, so the preview harness
rendered an approximately correct background by accident. Removing those
per-screen overrides was correct for the app and left the harness with nothing
to paint.

Blast radius beyond STORY-032: `main_preview.dart` is the capture entrypoint
for **every** REQ-002 design-fidelity story, so from this story's merge onward
no on-device capture in this requirement can evidence a background, a sky wash
or the twinkle-star layer. Fix is one line in the preview entrypoint's
`builder` — mount `CupidAppBackground` exactly as `cupid_app.dart` does — and
it should be sequenced before any further on-device fidelity capture.

### F2 — `waiting` cannot be captured in its waiting state

`main_preview.dart:394-395` builds `WaitingScreen` with only `expiresAt`; the
screen resolves pairing status from the live session that
`bootstrapPreviewSession()` signs in, and that seeded account is already
paired. The capture therefore renders the paired terminal state
("Đã ghép đôi! 🎉") instead of the state the design reference shows. Faking
the state needs a preview fixture (a `PREVIEW_PAIR_STATUS` dart-define in the
established style of `PREVIEW_CONTRACT_SIGN_STATUS` at line 246), which is a
source change. Typed code: `MOBILE_VISUAL_AUDIT_STATE_MISSING`.

## Verification

| Gate | Command | Result |
| --- | --- | --- |
| Preview build | `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=forgot --dart-define=PREVIEW_BRIGHTNESS=dark` | exit 0 |
| Capture `forgot` | `capture-mobile-screen.sh --label=forgot --device=emulator-5560` | `MOBILE_CAPTURE: OK 405x900 73254` |
| Capture `waiting` | `capture-mobile-screen.sh --label=waiting --device=emulator-5560` | `MOBILE_CAPTURE: OK 405x900 21280` |
| Capture `vibe` | `capture-mobile-screen.sh --label=vibe --device=emulator-5560` | `MOBILE_CAPTURE: OK 405x900 124867` |

`flutter analyze` and `flutter test` were not re-run: this pass changed no
application source, only evidence artifacts.
