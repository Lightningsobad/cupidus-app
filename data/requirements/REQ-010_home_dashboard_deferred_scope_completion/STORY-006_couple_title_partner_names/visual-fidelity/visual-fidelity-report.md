# Visual Fidelity Report — STORY-006 Phase P1 (Home couple title)

VISUAL_FIDELITY: PASS
Design-Screen: home

- Story: STORY-006 Couple Title Shows Both Partner Names
- Phase: P1 — `../coding-plan/phase-P1-home-couple-title-partner-name.md`
- Surface: Home dashboard couple-presence header (`_CoupleHero` / `_PresenceRow`
  in `mobile/lib/features/home/presentation/home_screen.dart`)
- Date: 2026-08-25
- BaseHead: `d124f68bcfb79530cb003dd55b2be1393f5d2ad7`

## Verdict

**MATCH.** The implemented header renders the design's `Minh & Linh` couple
title with both avatar initials, matching the `../ux/uiux-spec.md` §6.8 design
anchor and the REQ-002 STORY-017 reference capture. The degraded and long-name
states behave as specified, with no fabricated partner data and a visible
ellipsis instead of an overflow.

No deviations found. No deferrals.

## Design Anchor

Resolved against the LOCKED mobile design source in
`data/devops/system/design-fidelity-config.json`, not a sibling canvas.

- Design source: `design_source.id: cupid-app`, `surface: mobile`,
  `entry: cupid-app-design-system/Cupid App.dc.html`, `locked: true`,
  `screens_from: dom`.
- `Design-Screen: home`. The id is a DOM screen state of the locked entry, not a
  separate file: `Cupid App.dc.html` exposes `data-screen-btn="home"`, and the
  screen state resolves through `isHome: sc === 'home'`
  (`Cupid Screens.dc.html:2173`).
- Screen markup source: the locked entry composes each device side from the
  imported `Cupid Screens` component —
  `Cupid App.dc.html:239` (`side="a" platform="ios"`) and
  `Cupid App.dc.html:251` (`side="b" platform="md"`). The couple-presence header
  for the `home` state therefore renders from
  `Cupid Screens.dc.html:238-246` (`<sc-if value="{{ isHome }}">` through the
  `Minh &amp; Linh` title + `{{ coupleTypeLabel }}` subtitle), reached via
  `../ux/uiux-spec.md` §6.8.

Correction: an earlier revision of this report cited
`cupid-app-design-system/Cupid Screens.dc.html` lines 243-246 as the anchor
outright. Those line numbers point at the right markup, but `Cupid Screens` is
an imported component, not the locked `design_source.entry`. The repository
holds two locked design sources (`cupid-app` / mobile and `cupid-web` / web), so
the anchor is now stated as entry + resolved screen id, which is what makes the
verdict re-checkable.

- Rendered reference captured from the `home` state of this same locked canvas
  (Android / `platform="md"` side) by the REQ-002 audit:
  `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-017_home_dashboard_design_fidelity/visual-fidelity/design-reference-home-android.png`
  — overlapping `M` / `L` gradient discs, bold white `Minh & Linh` title, muted
  `Cùng thành phố` subtitle beneath it. That render is now also present in this
  story's own folder as `design-reference-home-header-widget-test.png` so the
  side-by-side pair is local, not a cross-story prose pointer.
- Pre-story implemented state, same audit:
  `.../STORY-017_home_dashboard_design_fidelity/visual-fidelity/implemented-home-android-emulator-5560.png`
  — the gap this story closes: title reads `Minh` only, partner disc carries no
  letter.

## Capture Method

Flutter-rendered golden capture of the real widget tree:
`RepaintBoundary.toImage(pixelRatio: 3)` on `HomeScreen` mounted through the
same `_host` harness the widget tests use, at a 390 x 120 logical viewport with
`devicePixelRatio: 3`. The app's bundled variable fonts (Nunito, Roboto,
Material Symbols Rounded) were loaded into the test renderer with `FontLoader`
so type weight, letterforms and Vietnamese diacritics render exactly as
shipped, and the header was backed with `context.cupidColors.colorBackground`
to reproduce the app shell's dark backdrop.

Each of the three states was captured in its own isolated `flutter test`
invocation, selected with `--dart-define=CAPTURE=<file>`. Three sequential
`pumpWidget` captures inside one test body produced stale, partially-rastered
frames; isolating the runs fixed it.

The capture harness was temporary and has been **removed** from
`mobile/test/features/home/home_screen_test.dart`. Only the permanent
behavioral tests remain there.

### Why not an on-device capture — SCOPED EXCEPTION

Scoped exception (Scrum Master ruling, 2026-08-25): implemented capture is a
widget-test golden, not a freshly-built running-app capture, because the P1
phase file restricted this phase's write scope away from that kind of
provisioning step. Rendered pixel match independently verified by Reviewer
against the real design reference.

The exception is carried in the filename itself: the implemented capture is
named `implemented-home-header-widget-test.png`, where the `<device>` slot of
the `implemented-<screen>-<device>.png` contract holds `widget-test` instead of
a device serial. A reader cannot mistake it for an on-device frame.

Underlying constraint, unchanged: the phase file's §6 is explicit — *"Do not run
the full `flutter test` suite, an emulator/simulator lifecycle, or an APK build
for this phase."* An `emulator-5554` instance is booted, but surfacing this
title on it would require a fresh APK build plus paired backend fixture state,
both outside the phase's authorization. The ruling above is about how the
evidence is labeled; it does not lift that provisioning restriction.

## Captures

Contract pair (`implemented-<screen>-<device>.png` /
`design-reference-<screen>-<device>.png`, `<device>` = `widget-test` per the
scoped exception above):

| File | Role | Source |
| --- | --- | --- |
| `implemented-home-header-widget-test.png` | implemented side of the pair | byte-identical to `header-both-names.png`; the AC1 + AC2 golden of the real `HomeScreen` widget tree |
| `design-reference-home-header-widget-test.png` | design side of the pair | `home` state of the locked `Cupid App.dc.html` canvas, Android/`md` side, as rendered by the REQ-002 STORY-017 audit |

State captures (all three from the same golden harness):

| File | State | Profile input |
| --- | --- | --- |
| `header-both-names.png` | AC1 + AC2, both names resolved | `displayName: 'Minh'`, `partnerDisplayName: 'Linh'` |
| `header-degraded.png` | AC3, partner name absent | `displayName: 'Minh'`, `partnerDisplayName: null` |
| `header-long-names.png` | ellipsis affordance | `'Nguyễn Thị Minh Khai Phương'` & `'Trần Hoàng Bảo Linh Chi'` |

Runtime evidence (not part of the fidelity pair):

| File | Role |
| --- | --- |
| `runtime-smoke-home-emulator-5554.png` | first-screen frame from the F-1 startup smoke on `emulator-5554`; see `../coding-plan/test-results.md` §Story Runtime Startup Smoke. The installed APK on that emulator predates P1, so this frame shows the pre-story `Minh`-only title and is launch/reachability evidence only, never AC evidence |

## Comparison

### `header-both-names.png` vs the design anchor

| Element | Design anchor | Implemented | Result |
| --- | --- | --- | --- |
| Avatar pair | Two overlapping gradient discs, partner disc behind-right | Two overlapping gradient discs, same stacking and offset | match |
| Self initial | `M` on the pink/lilac gradient | `M`, same disc, same gradient | match |
| Partner initial | `L` on the mint/periwinkle gradient | `L`, same disc, same gradient | match — this is the new AC2 behavior |
| Couple title | `Minh & Linh`, bold white, single line | `Minh & Linh`, unchanged Nunito weight/size token | match — this is the new AC1 behavior |
| Couple-type label | `Cùng thành phố`, muted, below the title | identical, position unchanged | match |
| Days counter | gradient `247` + `ngày bên nhau` | identical, untouched by this phase | match |

Spacing, disc diameter, gradients, type scale and colors are byte-for-byte the
existing tokens: the phase changed only the title string, the partner
`_Avatar`'s `initial`, and the `Flexible` + `maxLines`/`overflow` wrapping
(phase task 5 forbids touching any spacing, sizing, color or type token, and
none were).

### `header-degraded.png` — AC3

Title reads `Minh` alone. No `&`, no trailing separator, no placeholder string.
The partner disc still renders, gradient-only, with no letter — identical to
the pre-story implemented state, which is exactly the honest fallback AC3 asks
for. No error text, toast, banner, or retry affordance appears.

### `header-long-names.png` — overflow affordance

The combined title renders on one line and truncates with a visible ellipsis
(`Nguyễn Thị Minh Khai Phương & T…`) instead of wrapping or spilling past the
header. The couple-type label below is unaffected. Programmatic confirmation
from the same widget tree: the title `RenderParagraph` measures 268.0 pt with
`didExceedMaxLines == true`, against 87.78 pt for `Minh & Linh` and 36.02 pt
for `Minh` alone.

## Limitations

- The widget-test renderer mounts `HomeScreen` without the production app
  shell, whose backdrop was substituted with the same
  `colorBackground` token. Ambient shell effects layered above the shell (for
  example a global blur or scrim, if any) are not represented in these frames.
- These are rendered goldens, not device screenshots, so they do not exercise
  platform text shaping or device-specific font fallback. Vietnamese diacritics
  render correctly here with the app's own bundled Nunito, which is the font
  the device also uses.
- The 320 px narrow-width `RenderFlex` overflow noted in
  `../coding-plan/test-results.md` is pre-existing (it reproduces with short
  names and with no partner name at all) and is not visible in these 390 pt
  captures.
