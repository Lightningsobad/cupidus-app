# UX Spec: STORY-001 Design System (platform x theme tokens + i18n infra)

Scope: REQ-001 / STORY-001_design_system
Source of truth: `cupid-mobile-design/Cupid App.dc.html` and
`cupid-mobile-design/Cupid Screens.dc.html` (identical CSS custom-property
block confirmed byte-for-byte in both files — treated as authoritative).
No screen-level design is specified here (out of scope per story_master.md).

## 1. Token Architecture Overview

Design source defines tokens along two independent axes, matching D3
(`ThemeExtension`-based, 1 widget tree, no forked screens):

- **Platform axis** (`data-plat="ios" | "md"`): shape/motion/typeface-stack
  tokens that do not change with theme.
- **Theme axis** (`data-theme="dark" | "light"`): color tokens that do not
  change with platform.

These two axes are orthogonal in the source (platform tokens are set once;
theme tokens are set once and apply under both `[data-plat="ios"]` and
`[data-plat="md"]`). Tech Lead should model this as (at minimum) two
`ThemeExtension` classes — one platform-scoped, one theme-scoped — composed
together, rather than one combinatorial 4-variant extension. This is a
grouping observation from the source structure, not an ADR decision; Tech
Lead owns the final `ThemeExtension` class design and the light/en
enablement-flag mechanism (story AC 3).

## 2. Platform Tokens (theme-independent)

| Token | iOS-style | Material-style | Notes |
|---|---|---|---|
| `radiusCard` | 26px | 24px | Card/content container corner radius |
| `radiusButton` | 999px (pill) | 999px (pill) | Same on both platforms |
| `radiusSheet` | 28px | 28px | Bottom sheet / modal corner radius |
| `radiusSmall` | 16px | 16px | Small chip/input corner radius |
| `safeTop` | 54px | 6px | Top safe-area allowance used by design frame |
| `safeBottom` | 24px | 6px | Bottom safe-area allowance used by design frame |
| `tapTarget` | 44pt | 48dp | Minimum interactive hit target (matches HIG/M3 minimums) |
| `fontStackUI` | `-apple-system, "SF Pro Text", system-ui, sans-serif` | `Roboto, system-ui, sans-serif` | UI/body font family per platform |
| `shadowElevation` | `0 10px 30px rgba(80,30,110,.18)` | `0 6px 18px rgba(80,30,110,.16)` | Card/sheet elevation shadow |

Icon family is shared across both platforms: **Material Symbols Rounded**
(design source notes SF Symbols as the intended substitute when building the
real iOS target — flag this as an open item for Tech Lead/mobile-dev: confirm
whether v1 uses Material Symbols on both platforms via Flutter, or swaps to
SF Symbols on iOS).

Icon fill states (apply as icon variant tokens, not new icon sets):

| Variant | font-variation-settings |
|---|---|
| default (filled) | FILL 1, wght 400, GRAD 0, opsz 24 |
| `line` (outline) | FILL 0, wght 350, GRAD 0, opsz 24 |
| `soft` | FILL 1, wght 300, GRAD -25, opsz 24 |

## 3. Theme Tokens (platform-independent)

| Token | Dark | Light |
|---|---|---|
| `colorBackground` | `#171129` | `#FFF6FB` |
| `colorSurface` | `#241B42` | `#FFFFFF` |
| `colorSurfaceAlt` | `#2E2456` | `#FFEEF7` |
| `colorLine` (divider/border) | `rgba(247,238,251,.11)` | `#F7DFEC` |
| `colorText` | `#F7EEFB` | `#3E2645` |
| `colorTextMuted` | `#B4A6CE` | `#8A6D97` |
| `colorAccentPink` | `#FF7FB6` | `#E8558F` |
| `colorAccentPinkDark` | `#F0609E` | `#D2417B` |
| `colorAccentPurple` | `#B78CF5` | `#9A63E8` |
| `colorAccentPurpleDark` | `#8E5FD6` | *(not overridden in light — reuse dark value; flag to Tech Lead/mobile-dev to confirm before build)* |
| `colorAccentLilac` | `#D9C2FF` | `#B78CF5` |
| `colorMint` (success/trust role) | `#79E2CD` | `#22B398` |
| `colorGreen` (success role, duplicate of mint in dark) | `#79E2CD` | `#22B398` |
| `colorButter` / `colorAmber` (warning role) | `#FFD79E` / `#FFC97E` | `#DE9A31` / `#DE9A31` |
| `colorPeach` | `#FFAB93` | `#EF7F5F` |
| `colorRed` (danger/destructive role) | `#FF6F91` | `#EA5578` |
| `colorGhost` (muted/inactive role) | `#B4A6CE` | `#A793B4` |
| `glowShadow` | `0 8px 28px rgba(255,107,168,.34)` | `0 8px 24px rgba(255,107,168,.26)` |
| `skyGradient` (screen background decoration) | `radial-gradient(120% 70% at 15% -8%, rgba(123,47,190,.55), transparent 62%), radial-gradient(90% 55% at 95% 6%, rgba(255,75,140,.32), transparent 60%), radial-gradient(80% 50% at 50% 108%, rgba(0,201,167,.16), transparent 62%)` | `radial-gradient(120% 70% at 12% -10%, rgba(255,182,214,.72), transparent 62%), radial-gradient(90% 55% at 96% 4%, rgba(206,180,255,.6), transparent 60%), radial-gradient(80% 50% at 50% 108%, rgba(178,240,226,.5), transparent 62%)` |
| `gradientDream` (hero/CTA/days-counter) | `linear-gradient(120deg,#FF9CC4,#C79BF0 52%,#8FE6D3)` | same (not theme-overridden in source) |
| `gradientHot` | `linear-gradient(120deg,#FF7FB6,#B78CF5)` | same (not theme-overridden in source) |

`colorAccentPurpleDark` (`--purple-d`) has no light-theme override in either
source file. This is a design-source gap, not an error on my part to
resolve: escalate to Tech Lead/mobile-dev at build time to confirm whether
the dark value (`#8E5FD6`) should carry over unchanged in light theme, or
whether a light-safe value is needed (dark-optimized purple may under-contrast
on white surfaces — see Section 5).

## 4. Typography and Spacing (shared across all 4 combinations)

| Role | Spec |
|---|---|
| Display (days counter, contract title) | Nunito, weight 900, 34pt |
| Card title | 22pt, weight 600 |
| Body | 17pt — rendered via platform `fontStackUI` (SF Pro on iOS, Roboto on Material) |
| Caption (timestamps, metadata) | 13pt |
| Label/mono (tags, badges) | Roboto Mono, weight 400/500 |

Font family stack loaded in source: Nunito (400/600/700/800/900), Roboto
(400/500/700), Roboto Mono (400/500), Material Symbols Rounded.

Spacing scale — base 8pt grid:

| Token | Value |
|---|---|
| `spaceXs` | 4px |
| `spaceSm` | 8px |
| `spaceMd` | 16px |
| `spaceLg` | 24px |
| `spaceXl` | 32px |
| `spaceXxl` | 48px |

## 5. Combined 4-Combination Matrix

All 4 build targets = platform token set x theme token set (Section 2 x
Section 3, composed, not forked). Confirmed buildable from source for all 4:

| Combination | Platform tokens | Theme tokens |
|---|---|---|
| iOS / dark | Section 2 "iOS-style" column | Section 3 "Dark" column |
| iOS / light | Section 2 "iOS-style" column | Section 3 "Light" column |
| Material / dark | Section 2 "Material-style" column | Section 3 "Dark" column |
| Material / light | Section 2 "Material-style" column | Section 3 "Light" column |

This satisfies AC 1. Per OQ5/story_master.md, only **dark + `vi`** is
user-facing at v1; the other 3 combinations must still build and pass visual
QA even though not user-selectable (Tech Lead defines the enablement-flag
mechanism gating this — AC 3).

### Accessibility flag: light-theme accent text contrast

Computed contrast ratios (WCAG relative luminance):

- Dark theme, `colorText` (`#F7EEFB`) on `colorBackground` (`#171129`):
  ~16.2:1 — passes AA/AAA for all text sizes.
- Light theme, `colorText` (`#3E2645`) on `colorBackground` (`#FFF6FB`):
  ~12.6:1 — passes AA/AAA for all text sizes.
- Dark theme, `colorAccentPink` (`#FF7FB6`) on `colorSurface` (`#241B42`):
  ~6.8:1 — passes AA for normal text.
- **Light theme, `colorAccentPink` (`#E8558F`) on `colorSurface`
  (`#FFFFFF`): ~3.4:1 — fails AA for normal/small text (needs 4.5:1), passes
  only for large text (≥18pt, or ≥14pt bold) and non-text UI elements
  (icons, borders, focus rings, which need 3:1).**

Acceptance rule for downstream screen stories: `colorAccentPink` /
`colorAccentPurple` in **light theme** may be used for large text, icons, and
decorative accents, but must not be used as body/caption text color on
`colorSurface`/`colorBackground` — use `colorText` or `colorTextMuted` for
small text instead. This rule should be encoded as a lint/reference note in
the token layer (e.g. doc comment on the light `ThemeExtension`) so future
screen stories don't reintroduce a contrast failure.

## 6. Adaptive Widget Behavior (the "4 named adaptive widgets" per D3)

Design source's platform-adaptation table maps directly to 4 adaptive
widget categories. UX behavior per category (naming/implementation is Tech
Lead's decision):

| Category | iOS behavior | Material behavior |
|---|---|---|
| Tab bar | Translucent background, icon 26pt + label 10pt | Pill-shaped active-state indicator |
| Header | Large title, back = chevron + text label | Top app bar, back = arrow icon only |
| Primary CTA | Full-width pill button, `radiusButton` = 999px | Filled button, 20dp corner radius, ripple feedback on press |
| Add-new action | `+` button in nav bar | FAB (floating action button), bottom-right corner |

These 4 categories must be the only points of platform forking (per D3: "1
widget tree ... no forked screens"); everything else (layout, copy, spacing,
color) stays identical between platforms and is driven purely by the shared
token set in Sections 2-4.

## 7. i18n / ARB Infrastructure Notes

Design source confirms both `vi` and `en` copy exist in the prototype,
toggled via a `data-lang` attribute (`vi` shown by default, `en` swapped in
via `[data-lang="en"]` CSS rules — see `[data-en]`/`[data-vi]` selectors in
both source files). This validates that dual-locale copy already exists
per-screen in the design source and can be extracted into ARB key/value pairs
screen-by-screen when each screen story is built; **extracting the actual ARB
string content is out of scope for this story** (no screen implementation
here) — flagging as a forward note for screen-story UX passes, not an AC of
this story.

Per OQ5/story_master.md AC 2-3: ARB infra must resolve strings in either
locale via the pipeline, but only `vi` is user-selectable at v1; `en` stays
built but not exposed in user-facing settings.

## 8. Assumptions / Open Items

- `colorAccentPurpleDark` has no light-theme override in source (Section 3) —
  escalate to Tech Lead/mobile-dev at build time.
- Icon family: source uses "Material Symbols Rounded" for both platforms in
  the web prototype, but notes SF Symbols as the intended real-iOS
  substitute. Recommend Tech Lead/mobile-dev confirm final choice: Material
  Symbols everywhere (simpler, 1 asset set, matches D3's "no forked" intent)
  vs. platform-native icon fonts (closer to native feel, adds a fork point).
  This UX spec does not resolve it — flagging as a decision Tech Lead should
  make given it affects the "no forked" principle in D3.
- Contrast rule for light-theme pink/purple accents on text (Section 5) must
  be carried into the `ThemeExtension` documentation so later screen stories
  don't violate it.

## Completion

`UX_COMPLETE: YES`

Token names/values for all 4 platform x theme combinations are confirmed
against `cupid-mobile-design/` (cross-checked identical in both source
files) and documented above. No design-source gaps block delivery; the one
gap found (`colorAccentPurpleDark` light override) is flagged as a
build-time confirmation item, not a blocker to starting implementation.
