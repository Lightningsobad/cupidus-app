# UX Spec: STORY-032 Design System — App-Shell Background, Button & Header Follow-Up

Design reference: `cupid-app-design-system/project/Cupid Screens.dc.html`
(locked source), root app-frame block (lines 44-65) and the shared
`:root`/`[data-plat]` token block (lines 23-27). Cross-checked against the
authored `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-001_design_system/ux/uiux-spec.md`
sections 3 and 6, and against the two deferred findings this story formalizes
(STORY-008 review round 2 R2; STORY-013 review round 2 B4/R2).

Scope: dark theme + `vi` only (OQ5 out of scope, matches sibling Scope B
stories).

## 1. Shared background layer (AC1, AC4)

### 1.1 What the design source actually does

The mockup's single root frame div wraps **every** screen block in the file:

```
<div data-plat="{{ platAttr }}" style="...background:var(--sky),var(--bg);...position:relative;overflow:hidden">
  <!-- 3 fixed-position twinkle star particles, always present -->
  <div style="position:absolute;top:14%;left:8%;width:6px;height:6px;border-radius:50%;background:#fff;animation:twinkle 3.4s ease-in-out infinite"></div>
  <div style="position:absolute;top:9%;right:16%;width:4px;height:4px;border-radius:50%;background:#FFD9EA;animation:twinkle 4.6s ease-in-out .8s infinite"></div>
  <div style="position:absolute;top:26%;right:7%;width:5px;height:5px;border-radius:50%;background:#CEB4FF;animation:twinkle 5.2s ease-in-out 1.6s infinite"></div>
  <sc-if value="{{ showHeader }}">...header...</sc-if>
  <!-- per-screen sc-if blocks (isForgot, isWaiting, isJoinCode, ...) mount here -->
</div>
```

This is a **single shared wrapper reused for literally every screen** in the
source, not a per-screen background. That is the exact gap this story closes:
`CupidColorTokens.skyGradient` exists as a token (verbatim CSS string, by its
own dartoc — no widget renders it) and `cupid_theme.dart:43` sets
`scaffoldBackgroundColor: colorTokens.colorBackground` (flat fill) as the
global default, with no gradient/star layer anywhere in `mobile/lib/`.

Paint order (back to front): solid `colorBackground` → `skyGradient`'s 3
radial layers → 3 twinkle star particles → screen content.

### 1.2 Exact values to render (dark theme)

**skyGradient** — 3 elliptical radial-gradient layers, painted in this order
(same string already in `cupid_color_tokens.dart:66-70`):

| Layer | Size (w % x h %) | Center | Color → stop |
|---|---|---|---|
| 1 | 120% x 70% | 15%, -8% (above top edge) | `rgba(123,47,190,.55)` → transparent at 62% |
| 2 | 90% x 55% | 95%, 6% | `rgba(255,75,140,.32)` → transparent at 60% |
| 3 | 80% x 50% | 50%, 108% (below bottom edge) | `rgba(0,201,167,.16)` → transparent at 62% |

Percent size/position are relative to the painted surface (the full screen
body). There is no single Flutter `Gradient` that expresses 3 independently
positioned/sized ellipses in one object (per the token's own dartdoc) — this
needs either a `CustomPainter` drawing 3 `RadialGradient`-filled ellipses, or
a `Stack` of 3 `Positioned`/`Transform`-scaled circular `DecoratedBox`es with
`RadialGradient`. Either is acceptable; Tech Lead/mobile-dev choose the
mechanism, but the rendered result must reproduce the size/center/color/stop
values above losslessly (not an approximation to a single generic vignette).

**Star particles** — exactly 3, fixed positions relative to the full screen
frame (not scoped to a card), continuous loop, no user interaction:

| # | Position | Size | Color | Animation |
|---|---|---|---|---|
| 1 | top 14%, left 8% | 6x6 | `#FFFFFF` | 3.4s, no delay |
| 2 | top 9%, right 16% | 4x4 | `#FFD9EA` | 4.6s, 0.8s delay |
| 3 | top 26%, right 7% | 5x5 | `#CEB4FF` | 5.2s, 1.6s delay |

All 3 share the same `twinkle` motion: opacity oscillates 0.25 ↔ 1.0 and
scale oscillates 0.85 ↔ 1.15, ease-in-out, symmetric (0%→50%→100% = low→high→low),
looping forever. Each particle runs on its own duration/start-delay so they
are never in phase.

### 1.3 Where this shared layer must be adopted

The correct single integration point is **`mobile/lib/app/cupid_app.dart`**,
not a per-screen change and not only `app_shell.dart`. That file already
declares itself (see its own class doc) as "the only file allowed to compose
[flags, theme, localization] together" — the same boundary applies here:

- Add a new shared widget (design-system layer, e.g.
  `design_system/theme/cupid_app_background.dart` exposing something like
  `CupidAppBackground`) that paints §1.2's base fill + gradient + stars
  behind its `child`.
- Wire it in via `MaterialApp`'s `builder:` parameter in `cupid_app.dart`
  (currently unset), e.g. `builder: (context, child) => CupidAppBackground(child: child!)`.
  `MaterialApp.builder` wraps the `Navigator`'s entire output, so this one
  change reaches every pre-pairing screen (`PairGateShell` routing), every
  post-pairing tab (`AppShell`'s `Home`/`Chat`/`Gallery`), **and** every
  screen reached via a direct `Navigator.push` outside `AppShell`'s build
  method (`MeScreen`, `GhostSettingsScreen`) — those are pushed as
  independent routes and would NOT be covered by wrapping `AppShell`'s
  `Scaffold` alone. This is the concrete reason a single `AppShell`-level
  insertion is insufficient and the composition root is the right layer.
- Change `cupid_theme.dart:43`'s `scaffoldBackgroundColor` from
  `colorTokens.colorBackground` to `Colors.transparent`, so screens' own
  `Scaffold`s stop occluding the new global layer with an opaque flat fill.
- Remove the explicit `backgroundColor: colors.colorBackground` override
  currently set on individual screens' `Scaffold` (confirmed present in
  `login_screen.dart:180`, `register_screen.dart:145`,
  `waiting_screen.dart:91`, and equivalently in `forgot_screen.dart`) so they
  fall through to the new transparent theme default instead of re-painting a
  flat fill on top of the shared layer. `app_shell.dart`'s `Scaffold` already
  has no explicit `backgroundColor` override, so it needs no change at all —
  confirming the "no per-screen fork" goal for the post-pairing shell
  specifically.
- OTP (STORY-007) has no implementation yet (`Implementation` unchecked) —
  when it is built, it must mount through the same app-wide layer from day
  one; no separate spec needed since it inherits automatically once wired at
  the composition root.

**Explicit exclusion — Splash screen** (`splash_screen.dart`): already paints
its own full-bleed bespoke `SplashPalette.background`/`SplashPalette.glow`
gradient (STORY-003, already reviewed and DONE). It fully occludes whatever
sits behind it, so the new global layer is harmless there, but splash is not
in this story's scope and must not be re-verified or restyled here.

**Call-out — Welcome screen** (`welcome_screen.dart`): already renders its
own screen-local `LinearGradient` decoration (STORY-004, already DONE, not
in this story's re-verification set). Once the global theme default flips to
transparent, Tech Lead/mobile-dev must confirm welcome's own decoration still
fully covers its frame as before (build-time visual check only — not a new
acceptance criterion, and not part of AC4's required re-verification, which
names only Forgot Password and Waiting For Pairing).

## 2. CupidPrimaryButton (AC2)

Confirmed deviation (STORY-008 review round 2, R2), design source line 1524:
`height:54px; border-radius:var(--r-btn); background:var(--grad-hot); color:#fff; font-size:16.5px; font-weight:800; box-shadow:var(--glow)`.

Current `cupid_primary_button.dart:42-56`: flat `colors.colorAccentPink`
fill, `platformTokens.tapTarget` height (48 md / 44 ios), `type.body` label
(17px/w400), no gradient, no glow shadow.

Fix, scoped to exactly what STORY-008's review flagged (do not touch the
existing radius fork — see note below):

- **Height**: 54, both platforms (overrides `platformTokens.tapTarget` for
  this widget only — no shared height token equals 54; hoist a local named
  `const` the same way `_materialPrimaryCtaRadius` already is, citing this
  spec/the design source line).
- **Fill**: `colors.gradientHot` (already exists as a `LinearGradient`
  token — `#FF7FB6 → #B78CF5`, 120°). `ElevatedButton.styleFrom(backgroundColor:)`
  cannot express a gradient; the widget's internals need restructuring (e.g.
  `Ink`/`Container` with `BoxDecoration(gradient:)` behind an `InkWell`/
  `Material(color: Colors.transparent)` for ripple) — public API (`label`,
  `onPressed` constructor) stays unchanged.
- **Shadow**: `colors.glowShadow` (already exists as `List<BoxShadow>`),
  applied to the button's outer decoration.
- **Label**: 16.5px, `FontWeight.w800`, in `colors.colorText` (no separate
  "white" token exists; `colorText` = `#F7EEFB`, the closest documented role
  and already used by this widget — do not invent a raw `#fff` literal, which
  would fail the no-fork guard).
- **Radius — do not change**: the source's raw `--r-btn` custom property is
  `999px` for both `[data-plat="ios"]` and `[data-plat="md"]` in the generated
  mockup, but the **authored** `ux/uiux-spec.md` section 6 "Primary CTA" row
  (the contract this widget's own dartdoc already cites) explicitly documents
  the current fork: iOS pill (`radiusButton`, 999) vs Material 20dp corner
  radius. STORY-008 review round 2's own "Required follow-up" for R2 lists
  only height/fill/shadow/label — it does not ask for a radius change. Keep
  `_materialPrimaryCtaRadius` and the iOS `platformTokens.radiusButton` fork
  exactly as-is.

## 3. CupidHeader (AC3)

Design source header block (line 50), used identically for both platform
attrs (only `--safe-top` spacing differs by platform, not the surface
treatment): `background:transparent; backdrop-filter:blur(16px)`. Back
control glyph (line 52): `font-size:26px; color:var(--pink)` — i.e.
`colors.colorAccentPink`.

Current state:
- `_MaterialHeader` (`cupid_header.dart:152-176`): opaque `AppBar` with
  `backgroundColor: colors.colorSurface`, `elevation: 0` — no transparency,
  no blur. Back icon `IconButton` is colored `colors.colorText` (wrong —
  should be `colors.colorAccentPink`, matching the design source's `--pink`
  glyph color and matching what the iOS variant already does correctly).
- `_IosHeader` (`cupid_header.dart:69-133`): opaque `Container` with
  `color: colors.colorBackground` — no transparency, no blur. Back chevron
  color is already correct (`colors.colorAccentPink`).

Fix, both platform variants (the design source does not fork opacity/blur by
platform, so this is not a platform-adaptive difference — apply to both):

- Replace the opaque fill (`colorSurface` on Material, `colorBackground` on
  iOS) with a transparent surface behind a `BackdropFilter` using
  `ImageFilter.blur(sigmaX: 16, sigmaY: 16)` — no color tint/scrim on top,
  matching the source's literal `background:transparent` (no
  `rgba(...)`-tinted overlay). This is also why the header must actually blur
  rather than just go transparent: the header sits over the animated
  sky-gradient/star layer from §1, and the design's intent is for that motion
  to visibly blur as it passes under the header, not show through crisply.
- Material `_MaterialHeader`: change the back `IconButton`'s `color` from
  `colors.colorText` to `colors.colorAccentPink`.
- iOS `_IosHeader`: no color change needed (already `colorAccentPink`).
- Minor, non-blocking: source specifies the back glyph at 26px; the current
  `Icon(...)` calls pass no explicit `size` (Flutter default 24). Align to
  26px on both variants while this file is touched — flagged as a small
  spec-accuracy fix, not a separate blocking AC.
- `elevation: 0` and `titleTextStyle`/`type.cardTitle` styling stay unchanged
  — not part of the flagged deviation.

## 4. Re-verification after the fix (AC4)

Forgot Password (`forgot_screen.dart`) and Waiting For Pairing
(`waiting_screen.dart`) both currently mount `Scaffold(backgroundColor:
colors.colorBackground, ...)` directly and both already use
`CupidPrimaryButton`/`CupidHeader` indirectly through shared widgets or (for
Waiting, which is `NO_CHROME` — no header) directly reference
`colors.colorBackground`. Once §1's `Scaffold` `backgroundColor` override is
removed from both files and the global layer/theme change lands, re-render
both screens in dark theme + `vi` and confirm: the sky-gradient wash and 3
twinkle stars are visible behind their content, and (Forgot Password only,
since Waiting has no header/CTA per its `NO_CHROME` design) the restyled CTA
and header are visible. This directly satisfies AC4 — it is the same
mechanism fix reaching both previously-deferred findings, not a re-audit of
either screen's other content.

## 5. Contract-test guardrail (AC5)

- The no-fork guard test scans for raw color literals / raw platform
  branches in screen files; removing a `backgroundColor:` override and
  deleting one property does not introduce either, so it should continue to
  pass unmodified.
- `CupidPrimaryButton`/`CupidHeader` remain the only widgets branching on
  platform for their own internal layout (D3) — this fix changes values
  inside the existing platform branches, it does not add new ones.
- If any existing adaptive-widget or contrast test asserts today's flat
  `colorAccentPink` CTA fill, today's opaque header `AppBar`/`Container`
  color, or today's `colors.colorText` back-icon color as the *expected*
  value, that assertion is now stale and must be updated to assert the new
  gradient/glow/blur/accent-pink values instead — call this out explicitly
  in the implementation handoff per AC5's "intentionally updated, not
  silently changed" requirement; do not leave it passing against the old
  value by accident.

## Open items for Tech Lead

- Exact mechanism for rendering the 3-layer radial gradient
  (`CustomPainter` vs stacked `DecoratedBox`s) and the exact new widget's
  file placement/name (`CupidAppBackground` is a suggested name, not
  binding).
- Confirm no other call site already relies on `MaterialApp.builder` being
  unset in `cupid_app.dart` before adding one.
- Confirm removing `login_screen.dart`/`register_screen.dart`/
  `forgot_screen.dart`/`waiting_screen.dart`'s explicit `Scaffold`
  `backgroundColor: colors.colorBackground` is safe given each screen's
  current widget tests (some may assert on `Scaffold.backgroundColor`
  directly — if so, update the assertion to expect the new transparent
  default, per the AC5 "explicitly called out" requirement above).
