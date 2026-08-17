# UX Spec: STORY-035 Welcome Screen Design Fidelity Hardening

This is a re-verification/hardening spec, not a redesign. It restates the
already-locked design source as concrete, checkable match criteria so
mobile-dev can compare a rendered screenshot pair against it without
re-deriving design intent. No new copy, CTA, or screen state is introduced.

## Screen id confirmation

`welcome` already exists as a canvas state — no addition needed (unlike
STORY-034, which added a new node). Confirmed directly in
`cupid-app-design-system/project/Cupid Screens.dc.html`:
`isWelcome: sc === 'welcome'` (screen-flag list, ~line 2142), body block at
`<sc-if value="{{ isWelcome }}">` lines 68-91.

Render command:
```
render-design-canvas.js --screen=welcome --platform=android --theme=dark --lang=vi
```
(Same device/theme/lang convention as STORY-034's confirmed command and
STORY-033's `design-reference-welcome-android.png` capture.)

## Why this hardening pass is needed (evidence already on file)

STORY-033's incidental full-bleed capture of `welcome`
(`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-033_app_shell_design_system_deltas/visual-fidelity/design-reference-welcome-android.png`
vs `implemented-welcome-emulator-5554.png` in the same folder) already shows
the implemented screen visibly diverging from the design reference in
exactly the areas STORY-004's report claimed to have fixed: hero content
rendered centered instead of left-aligned, no visible accent rule under the
wordmark, the sub-copy paragraph not legible, the CTA block vertically
centered instead of bottom-pinned, the Google CTA rendered as a colored
filled pink button instead of a white pill with a dark label, the Email CTA
rendered as a bare text link instead of an outlined pill, and the footnote
rendered at near-zero contrast.

That pair is **not** this story's own matched evidence (different capture
context/purpose, reused only as a lead per the story's own text) — AC2 still
requires a fresh, same-story evidence pair in this story's own
`visual-fidelity/` directory. But mobile-dev should expect the fresh render
to reproduce these same deviations and treat this list as the starting
hypothesis for AC4's fix-and-reverify pass.

## Match criteria

Source: `cupid-app-design-system/project/Cupid Screens.dc.html`,
`<sc-if value="{{ isWelcome }}">` block, lines 68-91 (unchanged since
STORY-004). Token mappings below reuse STORY-004's already-approved
literal-to-token mapping
(`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-004_welcome_design_fidelity/visual-fidelity/visual-fidelity-report.md`,
D1-D11/D13) rather than re-deriving new ones — that report's target state is
still the correct target, the gap this story closes is that the rendered app
does not actually match it yet.

### Screen structure

- Two-part vertical composition, not one centered column: a flexible hero
  region that centers its own content vertically in the remaining space, and
  a CTA block pinned to the bottom of the screen.
- Background: a screen-specific gradient, distinct from the general Nebula
  Sky app-shell background used elsewhere on other screens — a `165deg`
  diagonal sweep, purple → pink → red (`#7B2FBE` at 0% → `#FF4B8C` at 58% →
  `#FF3366` at 100%). Target implementation is `colors.gradientHot` with its
  stops reversed, expressed on the `165deg` axis (not the token's own default
  `120deg`). Do not use `--grad`/`gradientDream` ("Dream Gradient") here —
  that token is the general system CTA/hero gradient referenced elsewhere in
  UX memory; this specific screen's background is a distinct, screen-local
  gradient in the design source.

### Hero content — left-aligned, not centered

- Wordmark "Cupid": left-aligned, Nunito, weight 900, ~60px, line-height
  0.95, tight negative tracking (~-0.03em, ≈ -1.8 logical px at this size),
  color `colors.colorText` (white).
- Accent rule directly under the wordmark: a short bar, 52×4, 2px corner
  radius, `colors.colorText` at ~55% opacity, ~18px gap above / ~16px below.
  Must be visibly present — it is missing from the current render.
- Tagline, two lines with the explicit break preserved ("Yêu nghiêm túc." /
  "Chia tay đàng hoàng."): left-aligned, Nunito, weight 700, 23px,
  line-height 1.3, `colors.colorText`, wrapped at max-width ~280 logical px.
- Sub-copy ("App cho hai người. Không có newsfeed, không có người thứ ba."):
  left-aligned, 14px, line-height 1.55, `colors.colorText` at ~78% opacity,
  max-width ~270, 12px gap above it. Must render at legible contrast — it is
  currently not visible at a legible level.
- Nothing in the hero is centered. Only the legal footnote at the very
  bottom of the CTA block is center-aligned.

### CTA block — bottom-pinned, per-provider styling (not Dream Gradient)

Up to three rows, each 52px tall, `999px` pill radius
(`context.cupidPlatform.radiusButton` / `--r-btn`, identical on both
platform tokens), stacked with a 10px gap, 16px/weight-600 labels:

- **Apple** — rendered only when `CupidPlatform.of(context) ==
  CupidPlatform.ios`: fill `colors.colorBackground` (#171129, mapped from
  the design's literal `#000`), label `colors.colorText` (#F7EEFB, mapped
  from the design's literal `#fff`), copy "Tiếp tục với Apple" / "Continue
  with Apple".
- **Google** — always rendered: fill `colors.colorText` (#F7EEFB, mapped
  from the design's literal `#fff`), label `colors.colorBackground`
  (#171129, mapped from the design's literal `#1A1A2E`), a soft shadow
  (design: `box-shadow:0 2px 10px rgba(0,0,0,.14)`; STORY-004's approximation
  was `elevation: 2`), copy "Tiếp tục với Google" / "Continue with Google".
  A colored or gradient fill on this row is the deviation to fix, not a
  target state — currently the render shows a pink/gradient-filled Google
  button, which is wrong. The Google "G" glyph stays label-only (brand SVG
  asset remains out of WriteScope per STORY-004 D12 unless this story's own
  WriteScope already covers asset/pubspec changes — confirm with Tech Lead's
  boundary before adding it).
- **Email** — always rendered: no fill, 1.5px outline at `colors.colorText`
  alpha 0.5, label `colors.colorText`, copy "Dùng email" / "Use email". It
  must render as a bordered pill button, not a plain text link — the current
  render shows a bare text link with no visible border, which is wrong.
- Legal footnote below the CTA stack (the one center-aligned element): "Đăng
  ký nghĩa là bạn chấp nhận bị dỗi khi seen không trả lời." / English
  equivalent, 11.5px, line-height 1.5, `colors.colorText` alpha 0.65. Must be
  legible — the current render shows it at near-zero contrast.

### Padding

- Hero block: safe-area top inset + 28px horizontal.
- CTA block: 20px horizontal, safe-area bottom inset + 20px.
- These sit off the 8pt `CupidSpacing` grid by design (already carried as
  named file-local constants per STORY-004 D4) — do not snap them onto
  standard spacing tokens.

## Resolving the AC5 "Dream Gradient" reference

AC5 references "Dream Gradient, pill radius, platform-adaptive button
treatment per `cupid-app-design-system` §3" as the general system CTA
vocabulary. For this specific screen, the locked design source's `isWelcome`
block explicitly overrides that general pattern with three distinct
per-provider treatments (solid dark / solid light / outlined) — none of
which use the Dream Gradient fill. Pill radius (999) and platform-adaptive
treatment (Apple gated to iOS) do apply, unchanged. Treat the design source
block as authoritative over the general phrasing: adding a gradient fill to
any of these three rows would itself be a new deviation, not a fix.

## What "match exactly" means for AC3/AC5

Compare the fresh rendered `design-reference-welcome-android.png` against
the fresh `implemented-welcome-<device>.png`, region by region, using the
structure above: hero alignment, accent-rule presence, tagline/sub-copy wrap
width and opacity, CTA fill/outline per row, pill radius, bottom-pinned vs.
centered CTA position, and footnote contrast. Font-rendering/anti-aliasing
differences between the HTML/CSS canvas renderer and Flutter are expected
and are not deviations; layout position, alignment, fill vs. outline choice,
and opacity are. Where a deviation is found, AC4 requires fixing it directly
in the screen's CTA row widgets (or wherever the current implementation
lives) and re-rendering both sides to confirm the fix — not re-documenting
the mismatch.

## Explicitly out of scope

- No new copy, CTA, or screen state — only the existing three provider rows
  and the footnote.
- Brand glyph assets (Apple  glyph, Google "G" SVG) and literal brand hex
  tokens stay deferred per STORY-004 D12/D13 unless this story's own
  WriteScope already covers `mobile/lib/design_system/` and
  `mobile/assets/**` — defer to Tech Lead's boundary read on this, not this
  spec.
- Light theme / `en` locale (OQ5) — dark + `vi` only, per story scope.
- Any screen other than `welcome`.

## Reference evidence

- Design source: `cupid-app-design-system/project/Cupid Screens.dc.html`
  lines 68-91.
- Prior corrected-state documentation (target values above are drawn from
  it):
  `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-004_welcome_design_fidelity/visual-fidelity/visual-fidelity-report.md`.
- Leading (non-authoritative, older-capture) evidence of current drift:
  `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-033_app_shell_design_system_deltas/visual-fidelity/design-reference-welcome-android.png`
  and
  `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-033_app_shell_design_system_deltas/visual-fidelity/implemented-welcome-emulator-5554.png`.
