# Visual Fidelity Report: STORY-032 — Design System / App Shell Follow-Up

Story: STORY-032 Design System and App Shell Follow-Up
Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Lane: mobile
Configuration audited: dark theme + `vi` locale, Material platform
Purpose: AC4 evidence required by `coding-plan/master-plan.md` §"Phase 2
verification" — render Forgot Password and Waiting For Pairing after the
per-screen `Scaffold` `backgroundColor` overrides are removed, and confirm the
shared app-shell sky wash and the twinkle stars now reach both screens.
Outcome: CONFIRMED AT RENDER

## Captures

| File | Screen | Shows |
| --- | --- | --- |
| `ac4-forgot-password-dark-vi.png` | Forgot Password | sky wash, twinkle stars, restyled primary CTA (Phase 3) |
| `ac4-waiting-for-pairing-dark-vi.png` | Waiting For Pairing | sky wash, all three twinkle stars |

Both are 1170x2532 (390x844 logical at devicePixelRatio 3).

## Capture Method

Headless rasterization inside `flutter test`: the screen is pumped under a
`MaterialApp` that mirrors `CupidApp`'s composition root
(`builder: (context, child) => CupidAppBackground(child: child!)`,
`buildCupidTheme(platform: CupidPlatform.material, brightness: Brightness.dark)`,
`locale: const Locale('vi')` with `AppL10n.localizationsDelegates`), then the
root `RenderRepaintBoundary` is written out with `toImage(pixelRatio: 3)` inside
`tester.runAsync()`.

Two details that matter for reproducing these files:

- The app's four bundled families (`Nunito`, `Roboto`, `Roboto Mono`,
  `Material Symbols Rounded`) are installed with `FontLoader` in `setUpAll`.
  Without that step `flutter test` renders the placeholder test font and the
  capture is unreadable.
- The frame is taken at elapsed 2600ms. The three stars have 3400/4600/5200ms
  periods and 0/800/1600ms start delays, so they share no common peak; 2600ms
  is the instant at which all three sit well above their 0.25 rest opacity.

The harness itself is not committed — the story's declared write scope covers
`lib/design_system/adaptive/`, the 21 Phase 2 screens and this story's own
artifacts, not a new file under `mobile/test/`. The parameters above are
sufficient to rebuild it.

## Findings

### AC1 / AC4 — the shared background reaches both screens

Both captures show the three-layer sky wash from `CupidSkyPalette.darkLayers`:
the purple lobe (`rgba(123,47,190,.55)`) top-left, the pink lobe
(`rgba(255,75,140,.32)`) top-right, and the teal lobe (`rgba(0,201,167,.16)`)
bleeding up from the bottom edge. Before Phase 2 both screens painted
`colorBackground` edge to edge through their own `Scaffold`, so none of this was
reachable.

Twinkle stars: all three are visible on Waiting For Pairing — white 6px at
`left 8% / top 14%`, pink 4px at `right 16% / top 9%`, purple 5px at
`right 7% / top 26%`. On Forgot Password only the two right-hand stars are
discernible: the left star lands at logical (31, 118), directly behind the
opaque "Quên mật khẩu là chuyện thường" headline, so the content occludes it.
That is the real composition — the star layer is painted below `widget.child` in
`CupidAppBackground` by design — and its presence in the tree is asserted
structurally in `mobile/test/design_system/cupid_app_background_test.dart`
rather than visually here.

### AC2 — primary CTA restyle

The Forgot Password capture shows "Gửi link đặt lại" as a full-width 54pt band
filled with `--grad-hot` (120deg `#FF7FB6` to `#B78CF5`) and carrying the
`--glow` drop shadow (`0 8px 28px rgba(255,107,168,.34)`), visible as the pink
bloom below the button. The Material 20dp corner radius is unchanged. The label
renders at 16.5 / w800 in `--tx`.

Waiting For Pairing's "Làm mới" is a secondary/outline control, not
`CupidPrimaryButton`, so it is correctly unaffected.

### AC3 / AC5 — header restyle

Neither captured screen mounts a `CupidHeader`, so the transparent-AppBar and
backdrop-blur change is not observable in these two files. It is covered by
assertions instead, in `mobile/test/design_system/adaptive_widgets_test.dart`:
`AppBar.backgroundColor == Colors.transparent`, exactly one `BackdropFilter`
descendant of `CupidHeader` on both platforms, no `Container` inside the iOS
header still painting `colorBackground`, and the back glyph resolved to
`--pink`.

## Known Gap

No on-device capture. Producing one requires a running Android or iOS target,
which is outside this lane. The rasterized frames above are the in-lane
substitute; they exercise the same widget tree and the same theme, but they do
not cover platform compositing of `BackdropFilter`, which is exactly the part of
Phase 3 the captures already do not show. If the review gate needs the header
blur confirmed on a real target, that has to be scheduled as separate on-device
verification.
