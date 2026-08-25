# UX Spec: STORY-003 Pet Preview Card Design Fidelity

- Requirement: `REQ-010_home_dashboard_deferred_scope_completion`
- Configuration audited: dark theme + `vi` locale (only configuration this
  requirement targets, per `req_master.md` Business Rules And Guardrails).
- Design source: `cupid-app-design-system/Cupid Screens.dc.html`, `isHome`
  block, pet card node — lines 291-303 (`onClick="{{ goPet }}"` container).
- Implementation: `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart`,
  mounted unchanged in `mobile/lib/features/home/presentation/home_screen.dart`.
- Read-only reuse targets (no change): `PetXpCard`'s progress-bar pattern
  (`mobile/lib/features/pet/presentation/widgets/pet_xp_card.dart` lines
  65-90) is the structural precedent for §3 below; `PetStatus.levelProgress`
  math (`mobile/lib/features/pet/data/pet_models.dart:90`) is unchanged.

## 0. Comparison scope

This spec covers only the **`PetReady` (has-pet) variant** of the card — the
only variant the design source depicts. `cupid-app-design-system` has no
mockup for the loading / locked / no-pet / load-failure compact states
(`_PreviewCompact`, `_PreviewLoading`); those states are pure app branches
with no design-source counterpart. Do not repaint them with the corrections
below — leave their existing plain `colorSurface` chrome as-is. This mirrors
the requirement's own guardrail for degrading honestly rather than inventing
a design for undepicted states (`req_master.md` STORY-006 guardrail).

Because `_PreviewShell` (`pet_preview_card.dart` lines 87-113) is currently
one shared chrome for all five state variants, this correction requires
splitting it into two chrome variants — a "ready" shell (§1 below) and the
existing plain shell kept as-is for the other four states. Exact split
mechanism (two widgets vs. a `bool` parameter) is Tech Lead's call.

Motion (`animation:breathe`, `float`, `shimmer` in the design source) is a
prototype flourish not reproducible or verifiable in the static-capture
fidelity method this requirement uses (screenshot vs. design render,
`STORY-017` precedent). Only the resting-frame visual (shape, color, opacity,
position) is gated by AC1; do not add a looping `AnimationController` for it,
consistent with how the existing hero-glow decorative circle in
`home_screen.dart` (lines 303-311) is a static `Positioned` `Container`, not
an animation.

## 1. Ready-state card chrome (replaces `_PreviewShell` for `PetReady` only)

| Property | Design source (`isHome` line 291) | Current (`pet_preview_card.dart`) | Correction |
|---|---|---|---|
| Background | `linear-gradient(130deg, rgba(255,127,182,.2), rgba(121,226,205,.16))` | flat `colors.colorSurface` | `LinearGradient` at 130°, stops `colors.colorAccentPink.withAlpha(51)` (20%) → `colors.colorMint.withAlpha(41)` (16%). `colorAccentPink` (`0xFFFF7FB6`) and `colorMint` (`0xFF79E2CD`) already match the design's raw pink/mint RGB exactly — use the tokens, not literal colors. |
| Border | `1px solid var(--line)` | none | `Border.all(color: colors.colorLine, width: 1)` — `colorLine` already equals `--line` exactly (`cupid_color_tokens.dart:86`). |
| Padding | `17px` | `EdgeInsets.all(CupidSpacing.md)` (16) | Keep — already the established 17px→16 token-rounding precedent this same file uses. |
| Corner radius | `var(--r-card)` | `platformTokens.radiusCard` | Keep — already correct. |
| Clip | `overflow:hidden` | none | Wrap in `ClipRRect` (same radius) so the decorative circle in §2 doesn't bleed past the card edge, matching the design's `overflow:hidden`. |

## 2. Decorative glow circle (missing — add)

Design source: `top:-14px; right:12%; width:74px; height:74px; border-radius:50%;
background: radial-gradient(circle, rgba(255,255,255,.26), transparent 70%)`.

Add inside the ready-shell's `Stack`, structurally following the existing
hero-glow precedent (`home_screen.dart` lines 303-311: `ClipRect`/`ClipRRect`
+ `Stack` + `Positioned` + `IgnorePointer` + `Container` with a
`RadialGradient` decoration, static, no `AnimationController`):
- `top: -14`, `width`/`height: 74`, circular (`shape: BoxShape.circle`).
- `RadialGradient(colors: [Colors.white.withAlpha(66), Colors.white.withAlpha(0)])`
  (`.26` alpha ≈ 66/255) — the design's radial stop pattern (opaque center
  fading to transparent by ~70% radius) needs a `stops` list, e.g.
  `[0.0, 0.7]`, to match `transparent 70%`.
- `right: 12%` of the card's own width, not the screen's. The hero-glow
  precedent used a fixed px offset because it anchors to the full screen
  edge; this circle anchors to the card's own bounds, so resolve the 12%
  with `LayoutBuilder` (`right: constraints.maxWidth * 0.12`) rather than a
  guessed fixed pixel value.
- Wrap in `IgnorePointer` (matches precedent — purely decorative, must not
  intercept the card's tap target).

## 3. Content layout (sprite + name/level/status/XP)

Design source (lines 293-302), row-by-row:

1. Outer row: `display:flex; gap:15px; align-items:center` — sprite +
   content column. **Correction**: current `_PreviewReady` Row uses
   `crossAxisAlignment: CrossAxisAlignment.start`; change to
   `CrossAxisAlignment.center`. Gap 15px vs. current `CupidSpacing.md` (16) —
   keep (established rounding precedent).
2. Sprite: `74×74` — already correct (`BunSprite(size: 74)`), no change.
3. Content column, first row: `display:flex; align-items:baseline; gap:8px`
   — pet name **and** the level chip sit side-by-side on one baseline row.
   **Correction**: current code stacks them as two separate rows (level+mood
   chip first, name second). Restructure to one `Row` with
   `crossAxisAlignment: CrossAxisAlignment.baseline` +
   `textBaseline: TextBaseline.alphabetic`, `spacing`/`SizedBox(width: CupidSpacing.sm)`
   (8), containing:
   - Pet name: `font-family:Nunito; font-size:17px; font-weight:900`. No
     shared typography token matches this (`cardTitle` is 22px/w600 platform
     UI font — a different role, used elsewhere for contract/dialog titles;
     do not reuse it here). Construct directly:
     `TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 17, color: colors.colorText)`.
     This follows the same repo precedent as the presence-row couple name in
     `home_screen.dart` (Nunito 15/w800), which is also a raw literal, not a
     shared token — introducing a new shared token for this one-off role is
     optional and Tech Lead's call, not required by this spec.
   - Level chip: text is `"Lv.{level}"` **only** — the design shows no mood
     text in this badge. Drop the current `" · {moodLabel}"` suffix from the
     chip; `moodLabel` is not displayed as separate visible text anywhere on
     this card in the design source (only the one `petLine` caption below
     it — see step 4). Do not change `PetCubit`/mood computation logic
     (out of scope) — only what this badge renders.
     - Padding: `2px 7px` vs. current `EdgeInsets.symmetric(horizontal: CupidSpacing.sm, vertical: CupidSpacing.xs)` (8/4) — keep, already the closest available token pair (`xs` = 4 is the smallest spacing token; no real visible deviation).
     - Background: `rgba(255,127,182,.22)` — this is `colors.colorAccentPink.withAlpha(56)` (22%). Already documented elsewhere in this codebase as this exact mapping (`cupid_tab_bar.dart:48`) — reuse it, don't recompute.
     - **Correction**: background is currently `colors.colorSurfaceAlt` — wrong; must be `colorAccentPink` at 22% alpha per above.
     - Corner radius: `6px` flat rounded rect. **Correction**: current code uses `platformTokens.radiusButton` (999 — a full pill). Replace with a literal `BorderRadius.circular(6)` — no existing token equals 6.
     - Text: `font-family:'Roboto Mono'; font-size:10px; color:var(--pink)`. **Correction**: current style is `context.cupidType.labelMono.copyWith(color: colors.colorText)` — wrong color (must be `colorAccentPink`, not `colorText`) and missing the explicit `fontSize: 10` (`labelMono` intentionally carries no size — every call site must set one, exactly as `pet_xp_card.dart:58-59` already does for its own 12px readout).
4. `petLine` (status caption), `margin-top:3px`, `font-size:12px; color:var(--tx2)`.
   **Correction**: current style is `context.cupidType.caption.copyWith(color: colors.colorTextMuted)` — `colorTextMuted` matches `--tx2` correctly, but `caption` is documented (`cupid_typography_tokens.dart:46-52`) as owning the **13px** role only, explicitly stating "consumers of a smaller role must state their own design-source size rather than re-point this token." 12px is a smaller, distinct role — must be `context.cupidType.caption.copyWith(fontSize: 12, color: colors.colorTextMuted)`, following the same explicit-override pattern already used in `pet_xp_card.dart:58-59`. Vertical gap 3px vs. current `CupidSpacing.xs` (4) — keep (rounding precedent).
5. XP bar, `margin-top:10px`, track `height:8px; border-radius:5px; background:var(--surf)`, fill `background:var(--grad); width:{{petXpPct}}%`.
   - Gap before the bar: **correction** — current `SizedBox(height: CupidSpacing.md)` (16) vs. design's 10px; change to `CupidSpacing.sm` (8), the nearer available token.
   - Track color: **correction** — must be `colors.colorSurface` (`var(--surf)`), not `colorSurfaceAlt`. (Note this differs from `PetXpCard`'s own track, which correctly uses `colorSurfaceAlt` because *that* screen's card background is flat `colorSurface`; on *this* card the background is now the pink/mint gradient from §1, so the design's own literal `var(--surf)` token is the correct track color here — do not copy `PetXpCard`'s track color by habit.)
   - Height: `minHeight: 8` (was 6).
   - Fill: **correction** — must render as `colors.gradientDream` (the design's `var(--grad)` is `linear-gradient(120deg,#FF9CC4,#C79BF0 52%,#8FE6D3)`, which is exactly `gradientDream`'s stop set — confirm against `cupid_color_tokens.dart:114-123`), not a flat `colorAccentPink`. Flutter's built-in `LinearProgressIndicator.valueColor` cannot paint a gradient fill. Replace it with the exact structural pattern already used for this same math one screen over, `pet_xp_card.dart` lines 68-89: `ClipRRect` → `Stack` → `Positioned.fill(ColoredBox(track))` + `FractionallySizedBox(widthFactor: progress, child: DecoratedBox(BoxDecoration(gradient: colors.gradientDream)))`. `progress` stays `status.levelProgress.clamp(0.0, 1.0)` — same getter, unchanged math.
   - Corner radius: design's 5px and the current `radiusSmall` (16) both render identically as a full semicircular pill end on an 8px-tall bar (radius ≥ height/2 clamps visually) — no visible deviation, keep `platformTokens.radiusSmall` on the `ClipRRect`, do not chase the literal 5px.

## 4. Fixture-mode capture path (AC3)

The card currently shows its `PetFailure` compact state under the
design-fidelity preview harness because `PetCubit.load()` calls the real,
unauthenticated backend. Add a fixture path that resolves the card straight
to `PetReady` with known, design-plausible data (e.g. `Lv.3`, xp% matching
the design mock's ~full bar), mirroring `main_preview.dart`'s existing
`PREVIEW_HOME_FIXTURE` / `_previewHomeProfile` pattern (lines 824-847): a
`bool.fromEnvironment` dart-define gate that swaps in a fake data source
instead of hitting the network, with the fixture omitted leaving today's
live-repository behavior unchanged. `PetPreviewCard` already accepts a
`repository` override parameter built exactly for this kind of injection
(`pet_preview_card.dart:28-32` — "used by widget tests to inject a fake
without touching the global service locator"); wiring that override through
from `main_preview.dart` under a new fixture define (e.g.
`PREVIEW_PET_FIXTURE`) is the natural extension point. Exact plumbing
(how the fixture repository reaches `HomeScreen` → `PetPreviewCard`) is
Tech Lead's architecture call — this spec only fixes the required rendered
outcome: a fully-populated `PetReady` card, not an auth failure state, so §1-§3
above can be captured and compared against the design source.

## 5. Tap behavior (AC4) — no change

`_PreviewShell`'s `onTap: () => PetRoute.push(context)` is unchanged by this
story. Every state variant, including the corrected ready-state chrome,
keeps navigating to the already-shipped `PetScreen`. No new entry point.

## 6. Out of scope reminders

- No change to `pet/presentation/pet_screen.dart`, sprite art, mood/XP
  computation, or adoption gameplay.
- No new tap target beyond the card's existing single navigate-to-`PetScreen`
  action.
- Do not touch the compact-state (`_PreviewCompact`/`_PreviewLoading`) visuals
  — see §0.
