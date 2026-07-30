# Phase P4 – Bun Sprite And Icon Glyphs

## 1. Objective

Build the five-state `BunSprite` vector widget in pure Flutter and add the five
Material Symbols glyphs this story needs to the design-system icon set.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-bun-sprite.md`
- Owner: Mobile Developer
- Lane: Mobile / UI

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: YES (independent of P2 and P3)
- Write Scope:
  - `mobile/lib/features/pet/presentation/widgets/bun_sprite.dart`
  - `mobile/lib/design_system/icons/cupid_icons.dart` (additive constants only)
  - `mobile/test/features/pet/presentation/widgets/bun_sprite_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `BunSprite({required BunSpriteState state, required double size})`
  - `CupidIcons.restaurant`, `sportsEsports`, `lock`, `pets`, `celebration`
- Shared Interfaces Consumed:
  - P1 `BunSpriteState`
- Risk Surfaces:
  - New icon codepoints
  - Mood → sprite mapping (visual half)
- Source Of Truth:
  - authoritative artifact: `cupid-mobile-design/Bun Sprite.dc.html` and
    `Bun Pet Art.dc.html` for shape/palette; bundled
    `mobile/assets/fonts/MaterialSymbolsRounded-Variable.ttf` cmap for codepoints
  - consumer contract: `../ux/uiux-spec.md` §3, §6, §8
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §4 Mobile Lane Handoff
    guardrails
  - UX constraints: `../ux/uiux-spec.md` §3 (five states, no `sleep`), §6 (fixed
    206/74/46 sizes), §8 (`bob` idle motion, Material Symbols Rounded only)
  - upstream phase outputs: P1 `BunSpriteState`
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one presentational widget + icon constants
  - Source/Test File Count: 2 source + 1 test
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` §3, §6, §8
- `../architecture/solution.md` §4 Mobile Lane Handoff
- `mobile/lib/design_system/icons/cupid_icons.dart`
- `cupid-mobile-design/Bun Sprite.dc.html` (shape and palette reference only)

## 3. Tasks

- Implement `BunSprite` as composed Flutter widgets and/or `CustomPaint`. No new
  pub dependency, no SVG package, no `assets:` entry, no Lottie.
- Support exactly the five `BunSpriteState` values. There must be no `sleep`
  branch and no time-of-day logic anywhere in the widget.
- Accept `size` and render correctly at the three UX sizes (206, 74, 46) by
  scaling internal geometry proportionally rather than branching on size.
- Implement the idle `bob` motion inside the sprite; keep it a small
  `AnimatedBuilder`/implicit animation and make sure it respects
  `MediaQuery.disableAnimations` (reduce-motion) by holding a static pose.
- Mark the sprite decorative for screen readers: `ExcludeSemantics` or a single
  `Semantics(label: 'Bun the pet', image: true)`. Mood is conveyed by the pill
  and status line, not the sprite (`../ux/uiux-spec.md` §7).
- Add `restaurant`, `sportsEsports`, `lock`, `pets`, and `celebration` to
  `CupidIcons`. Read each codepoint from the bundled
  `MaterialSymbolsRounded-Variable.ttf` cmap (for example with `fontTools`'
  `ttx`/`TTFont` cmap dump) and record the verified value in the doc comment,
  matching the style of the existing three constants. Do not copy codepoints from
  memory or from another icon font.
- Widget tests as described in Test Scope.

## 4. Acceptance Criteria

- `BunSprite` renders without exception for all five states at sizes 206, 74,
  and 46.
- `flutter analyze` reports no new issues; `pubspec.yaml` is unchanged.
- Each new `CupidIcons` constant has a doc comment naming the glyph and the
  cmap-verified codepoint.
- With `disableAnimations: true`, the sprite pumps to a settled frame (no
  pending timers) so widget tests do not hang.
- No `sleep` state, streak, badge, or per-species art exists in the widget.

## 5. Planned Outputs

- Code files: the two source files in Write Scope.
- Contracts: `BunSprite` widget API and the five icon constants.
- Notes or evidence: the cmap lookup method used, recorded in the icon doc
  comments.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile`), widget layer
- Required levels:
  - widget: `bun_sprite_test.dart` — pump all five states at all three sizes,
    assert no exceptions and a settled frame under reduce-motion; assert each
    new `CupidIcons` constant carries `fontFamily == 'Material Symbols Rounded'`
  - visual inspection: manual comparison of the five states against
    `Bun Sprite.dc.html`, recorded as a one-line note
  - mobile build/type-check/static-analysis: `flutter analyze` clean
- Required checks: `cd mobile && flutter test test/features/pet/presentation/widgets/bun_sprite_test.dart`
  and `cd mobile && flutter analyze`
- Mobile discoverability / navigation integration: N/A for this phase (P8 owns it)
- Minimum gates by risk surface:
  - Icon codepoints: family assertion in tests plus the documented cmap lookup
  - Mood → sprite visual half: five-state pump test
- Required regression or contract coverage: run the existing
  `test/design_system` suite after the `CupidIcons` edit.
- Evidence format: concise rows in `coding-plan/test-results.md` at P9.
- Verification strategy:
  - Targeted tests: `bun_sprite_test.dart` plus `test/design_system` regression
  - Build/type-check command: `flutter analyze`
  - Required assertion evidence: pumped states and icon font-family assertions

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
