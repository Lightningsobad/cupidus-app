# Phase P2 – Vibe Presentation Widgets And Copy

## 1. Objective

Build the props-only widgets the vibe screen composes: mood face glyph, 5-cell
mood grid, partner vibe card with the decorative nudge banner, 7-day history
strip, plus the feature-local localized copy.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-vibe-widgets.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P0
- Parallelizable: NO (independent of P1; either order is acceptable)
- Write Scope:
  - `mobile/lib/features/vibes/presentation/widgets/vibe_mood_face.dart`
  - `mobile/lib/features/vibes/presentation/widgets/vibe_mood_grid.dart`
  - `mobile/lib/features/vibes/presentation/widgets/partner_vibe_card.dart`
  - `mobile/lib/features/vibes/presentation/widgets/vibe_history_strip.dart`
  - `mobile/lib/features/vibes/presentation/vibe_strings.dart`
  - `mobile/test/features/vibes/presentation/widgets/vibe_widgets_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `VibeMoodFace(mood: VibeMood?)` — renders the `none` state for `null`
  - `VibeMoodGrid(selected:, enabled:, onPick:)`
  - `PartnerVibeCard(mood: VibeMood?)`
  - `VibeHistoryStrip(mine: List<VibeMood?>, partner: List<VibeMood?>)`
  - `VibeLocaleText` `BuildContext` extension
- Shared Interfaces Consumed:
  - P0 `VibeMood`
  - `mobile/lib/design_system/design_system.dart` tokens, theme context
- Risk Surfaces:
  - Accessibility semantics
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §3, §5, §6, §8,
    §9; `../architecture/solution.md` §4 D-010-4, D-010-6; existing precedent
    `mobile/lib/features/auth/presentation/auth_strings.dart`
  - consumer contract: P3 `VibeScreen`
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC1, AC2
  - architecture: `../architecture/solution.md` §4 D-010-4, D-010-6
  - OQ constraints: OQ5 — dark + `vi` are the enabled v1 locale/theme; keep both
    ARB-parity-compatible copy sets in the extension
  - upstream phase outputs: P0 `VibeMood`
  - UX constraints, if truly required: `../ux/uiux-spec.md` §3 (5-cell 3+2
    layout), §5 (partner card states, 4 nudge copy variants, decorative pill),
    §6 (strip layout, accurate copy), §8 (a11y), §9 (no new fork points)
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: all stateless vibe widgets + copy
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` §3, §5, §6, §8, §9
- `../architecture/solution.md` §4 (D-010-4, D-010-6)
- P0 `mobile/lib/features/vibes/domain/vibe_mood.dart`
- `mobile/lib/design_system/design_system.dart` and
  `mobile/lib/design_system/theme/cupid_theme_context.dart`
- `mobile/lib/features/auth/presentation/auth_strings.dart` (copy precedent)

## 3. Tasks

- `VibeMoodFace`: emoji/label glyph per `VibeMood`, plus the `none` state for
  `null`. Expose the mood label as the accessible name (UX §8) — never the emoji
  alone.
- `VibeMoodGrid`: 5 cells laid out 2 rows (3 + 2, centered) per UX §3; existing
  selected "on" pink-glow style vs "off" style from STORY-001 tokens; each cell
  meets the `--tap` minimum and exposes selected/toggled semantics; the whole
  grid is non-interactive when `enabled` is false (in-flight lock).
- `PartnerVibeCard`: mood face + label for a checked-in partner, or the existing
  "Chưa nói gì" / "Waiting…" state when `mood` is `null`; below it the nudge
  banner using the four existing copy variants (`sad`, `angry`, `tired`, other /
  no check-in). The CTA pill is **decorative only** (D-010-4): no tap target, no
  `button`/interactive semantics, no `cursor`-style affordance.
- `VibeHistoryStrip`: 7 columns oldest→newest with a day-of-week mono label,
  both partners' faces stacked with the existing connecting divider, `none` for
  missing days. Header copy is the accurate "7 ngày gần nhất" / "last 7 days"
  (A-2) — do not ship the "auto-deleted in 30d" claim.
- `vibe_strings.dart`: `VibeLocaleText` extension on `BuildContext` providing all
  vibe copy for `vi` and `en`, mirroring the `AuthLocaleText` shape. Do not edit
  `mobile/lib/l10n/**`.
- Use only existing design-system tokens and components; introduce no new token
  and no platform fork (UX §9, `test/design_system/no_fork_guard_test.dart`).

## 4. Acceptance Criteria

- The grid renders exactly 5 cells in a 3 + 2 centered layout with the correct
  labels; no `soft` cell exists.
- The selected cell renders the "on" style and reports selected semantics; all
  others report unselected.
- Every mood cell hit target meets the `--tap` minimum after the 3 + 2 layout.
- `enabled: false` makes every cell non-tappable.
- `PartnerVibeCard` renders the waiting state for `null` and the correct nudge
  copy variant for `sad`, `angry`, `tired`, and any other mood.
- The nudge pill exposes no interactive semantics.
- `VibeHistoryStrip` renders 7 columns and the `none` face for empty days.
- No new design token, no platform fork, no `mobile/lib/l10n/**` change.

## 5. Planned Outputs

- Code directories or files:
  `mobile/lib/features/vibes/presentation/widgets/`,
  `mobile/lib/features/vibes/presentation/vibe_strings.dart`
- Contracts or schemas: widget constructor signatures consumed by P3
- Requirement configuration guide updates: none
- Notes or evidence: widget test results recorded in P4

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile widget tests, `mobile/` package
- Required levels:
  - unit: nudge copy variant selection per mood
  - mobile build/type-check/static-analysis: `flutter analyze` clean
  - visual inspection: none in this phase (requirement-level audit only)
- Required checks: widget tests for cell count/layout, selected semantics,
  accessible names, `--tap` size, disabled grid, partner waiting state, strip
  7-column rendering with gaps, decorative pill has no interactive semantics
- Mobile discoverability / navigation integration: N/A for this phase (P3 owns
  the entry point)
- Minimum gates by risk surface:
  - Accessibility semantics → widget test on name + selected state + tap size,
    else `A11Y_UNVERIFIED`
- Required regression or contract coverage:
  `mobile/test/design_system/no_fork_guard_test.dart` and `theme_matrix_test.dart`
  must still pass
- Evidence format: concise rows in `coding-plan/test-results.md` (written in P4)
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" test test/features/vibes test/design_system`
  - Build/type-check/lint command when required:
    `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" analyze`
  - Required assertion evidence: widget finder counts, `Semantics` flags, hit
    target sizes, rendered copy strings

## 7. Status

- Status: DONE
- Evidence:
  - `VibeMoodFace`, `VibeMoodGrid`, `PartnerVibeCard`, `VibeHistoryStrip`, and
    `VibeLocaleText` (`vibe_strings.dart`) implemented as props-only widgets
    per §3–§4; no new design token, no platform fork, no
    `mobile/lib/l10n/**` edit.
  - `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" analyze lib/features/vibes test/features/vibes`
    → `No issues found!`
  - `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter" test test/features/vibes test/design_system`
    → `66 tests passed` (0 failed), including the new
    `vibe_widgets_test.dart` cases (5-cell/3+2 layout, selected semantics,
    `--tap` minimum, `enabled: false` lock, partner card copy variants,
    decorative-pill semantics, 7-column history strip) and no regression in
    `no_fork_guard_test.dart` / `theme_matrix_test.dart`.
- Last updated: 2026-07-30
