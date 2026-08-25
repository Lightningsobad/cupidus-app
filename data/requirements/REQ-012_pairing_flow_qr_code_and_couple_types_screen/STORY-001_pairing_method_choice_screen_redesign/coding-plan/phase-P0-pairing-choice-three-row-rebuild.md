# Phase P0 – Pairing-Choice Three-Row Rebuild

## 1. Objective

Rebuild `PairingChoiceScreen`'s body as the design source's `isPairStart`
layout — header block, three token-driven option rows, privacy note — with row 3
reusing row 2's existing join-code push edge, and add the four Material Symbols
glyphs the rows need.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-pairing-choice-three-row-rebuild.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`
  - `mobile/lib/design_system/icons/cupid_icons.dart`
  - `mobile/lib/design_system/tokens/cupid_color_tokens.dart` (only if a 140deg
    alignment pair must be added for the header badge gradient)
  - `mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
- Shared Interfaces Produced:
  - `CupidIcons.joinLeft`, `.qrCode2`, `.dialpad`, `.qrCodeScanner`
- Risk Surfaces:
  - Missing glyph codepoints
  - No-fork colour guard
  - Header badge gradient axis
  - Existing screen tests assert the old two-option shape
  - Chrome / stack-root guards
  - Stale design reference for AC4
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` sections 1 and 4
  - layout/copy/iconography: `../ux/ux-spec.md` sections 2, 3, 4, 8
- Primary Inputs Summary:
  - requirements: `../story_master.md` (AC1-AC4, In Scope, Out Of Scope)
  - architecture: `../architecture/solution.md`
  - UX constraints: `../ux/ux-spec.md` sections 2-4 and 8 — this phase's exact
    spacing, tints, glyph names, and row-to-destination mapping live only there
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one screen rebuilt plus the glyph constants it consumes
  - Source/Test File Count: 4 (5 if the gradient constant is needed)
  - Split Required: NO
  - Split Rationale: one behavior cluster, inside one specialist lifecycle; the
    three rows are one pattern applied three times, not three phases.

## 2. Required Reads

- `../story_master.md`
- `../architecture/solution.md`
- `../ux/ux-spec.md` sections 2, 3, 4, 8

## 3. Tasks

1. Add `joinLeft`, `qrCode2`, `dialpad`, `qrCodeScanner` to `CupidIcons`,
   each with the dartdoc form the file already uses ("confirmed in the bundled
   font's cmap at 0x…"). Verify each codepoint against the bundled
   `MaterialSymbolsRounded-Variable.ttf` cmap before committing it. If a glyph
   cannot be confirmed, stop and report it — do not substitute a nearby glyph.
2. Replace the body of `PairingChoiceScreen.build` with the UX spec section 2
   structure: header badge → title → subtitle → row 1 → row 2 → row 3 →
   privacy note. Keep the `Scaffold(key: const Key('pairing_stack'))` with no
   `AppBar`, keep `SafeArea` + `SingleChildScrollView`, and set the outer
   padding from the design block rather than reusing the old
   `fromLTRB(28, 150, 28, 0)` that was tuned for two buttons.
3. Implement one private row widget used three times, parameterised by icon,
   tile background, icon colour, title, body, chevron colour, `onTap`, and an
   `isPrimary` flag that switches the pink-tinted border plus `colors.glowShadow`
   on for row 1 only. Wrap each row in `InkWell`/`GestureDetector` with the
   app's standard pressed feedback and `Semantics(button: true)`.
4. Wire the taps: row 1 → the existing `_openInvite`; rows 2 AND 3 → the same
   existing `_openJoincode`, with no flag, argument, or branch distinguishing
   them.
5. Derive every colour from `context.cupidColors` bound to a local:
   `colorAccentPink`/`colorAccentPurple`/`colorMint`/`colorText` with
   `.withValues(alpha:)` at the UX spec's alphas; `gradientHot` for row 1's
   tile fill; `colorSurface`, `colorLine`, `colorTextMuted` for row shells and
   secondary text. No `Color(0x`, no `Colors.` anywhere under `lib/features`.
6. Set each row's accessible name to title + body per UX spec section 7, and
   mark the chevron and lock icons decorative so they are not announced.
7. Use `PairingStrings.viEn` for every `vi`/`en` string pair added by this
   phase.
8. Rewrite the three shape-dependent cases in `pairing_choice_screen_test.dart`
   (`renders both entry actions`, `the primary action opens invite`, `the
   secondary action opens joincode directly`) against the three-row layout, and
   add a case asserting rows 2 and 3 both land on `JoincodeScreen`. Leave the
   `AC4/AC5 back edges` group and the rotated-viewport case behaviourally
   intact.
9. Do NOT implement the "later, look around first" link. `../architecture/solution.md`
   D1 records why; adding a home destination is out of scope for this phase.

## 4. Acceptance Criteria

- Exactly three option rows render, in the order create / enter code / scan QR,
  with no residual `CupidPrimaryButton` + `TextButton` pair (AC1).
- Row 1 opens `InviteScreen`; rows 2 and 3 both open `JoincodeScreen` through
  the same method (AC2, AC3).
- Row 1 carries the pink-tinted border, glow shadow, gradient tile, white icon,
  and pink chevron; rows 2-3 carry the neutral border, tinted tile, and neutral
  chevron (AC4).
- Header badge, title, subtitle, and privacy note match UX spec section 2 copy
  in both `vi` and `en` (AC1, AC4).
- No `AppBar` and no tab chrome; the screen still scrolls on a rotated short
  viewport (AC4, existing guards).

## 5. Planned Outputs

- Code files: the four paths in `Write Scope`.
- Notes or evidence: one row per required check in `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `mobile-app`
- Required levels:
  - unit/widget: `mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`
  - mobile build/type-check/static-analysis: `flutter analyze` on `mobile/`
- Required checks:
  - `flutter test test/features/pairing/`
  - `flutter test test/design_system/no_fork_guard_test.dart`
  - `flutter test test/design_system/icon_variant_test.dart`
  - `flutter test test/design_system/gradient_axis_test.dart`
  - `flutter test test/core/navigation/chain_chrome_guard_test.dart`
- Mobile discoverability / navigation integration: assert the screen still
  mounts as the `PairGateUnpaired` branch and that each of the three rows
  pushes its destination from a tap on the row itself — not from a direct
  constructor call.
- Minimum gates by risk surface: the per-surface `Verification Gate` column in
  `../architecture/solution.md` section 4.
- Required regression or contract coverage: the existing `AC4/AC5 back edges`
  group and the rotated-viewport case must still pass unmodified in behaviour.
- Evidence format: one concise row per check in `coding-plan/test-results.md`.
- Requirement mobile visual audit: YES — compare against a freshly captured
  `isPairStart` frame (`Cupid Screens.dc.html` lines 1571-1615), not
  `design-reference-pairingchoice-android.png`, which was captured from a block
  id that no longer exists in the design source.
- Verification strategy:
  - Targeted tests: the five `flutter test` invocations above.
  - Build/type-check command: `flutter analyze`.
  - Required assertion evidence: rendered row count and order, the `IconData`
    on each row, and the pushed route type for each of the three taps.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-25
