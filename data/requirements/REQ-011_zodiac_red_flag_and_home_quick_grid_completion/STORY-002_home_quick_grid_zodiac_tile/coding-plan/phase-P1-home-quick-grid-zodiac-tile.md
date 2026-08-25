# Phase P1 – Home Quick Grid With Zodiac Red Flag Tile

## 1. Objective

Replace the full-width Synced Alarm entry in the Home card list with a
two-column quick-grid row holding the reshaped Synced Alarm tile and a new
Zodiac Red Flag tile that navigates to STORY-001's registered route.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-home-quick-grid-zodiac-tile.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/home/presentation/home_screen.dart`
  - `mobile/lib/design_system/icons/cupid_icons.dart`
  - `mobile/test/features/home/home_quick_grid_test.dart` (new)
  - `mobile/test/features/reminders/reminder_entry_point_test.dart` (only if its
    assertions depend on the old full-width shape)
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
  - `CupidIcons.autoAwesome` (folded into this phase; single in-lane consumer)
- Shared Interfaces Consumed:
  - `ZodiacRedFlagScreen.routeName` (`zodiac_red_flag_screen.dart:27`,
    registered `cupid_app.dart:68-71`)
- Risk Surfaces:
  - Quick-grid layout fidelity (AC1)
  - Zodiac route navigation (AC2)
  - Synced Alarm entry regression
  - Icon glyph correctness
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md`
    (sections 1 Key Discovery, 4 risk table, 4 Mobile Lane guardrails)
  - consumer contract: `ZodiacRedFlagScreen.routeName`
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC1-AC3
  - architecture: `../architecture/solution.md`
  - upstream phase outputs: none
  - UX constraints: `../ux/ux-spec.md` §3 (tile internals, tokens, keys), §3.1,
    §3.2, §5 (accessibility) — these carry the exact sizes and tokens
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one quick-grid row and its two tiles, plus the glyph
    constant they need
  - Source/Test File Count: 4
  - Split Required: NO
  - Split Rationale: one behavior cluster inside one lifecycle; splitting the
    icon constant out would isolate a one-line constant from its only consumer

## 2. Required Reads

- `../story_master.md`
- `../architecture/solution.md`
- `../ux/ux-spec.md` §3, §3.1, §3.2, §5

## 3. Tasks

1. Add `CupidIcons.autoAwesome`. Read the `auto_awesome` codepoint from the
   bundled `mobile/assets/fonts/MaterialSymbolsRounded-Variable.ttf` cmap with
   `fontTools`, per the convention documented at `cupid_icons.dart:9-11`. Do not
   copy it from Flutter's `Icons` class and do not guess. Document the confirmed
   codepoint in the doc comment like the neighbouring entries.
2. Add a private quick-grid tile widget in `home_screen.dart`: `Material` +
   `InkWell`, `padding: 16`, `borderRadius: context.cupidPlatform.radiusCard`,
   `color: colors.colorSurface`, card-consistent shadow; internals top-to-bottom
   are a 38x38 icon container (`radiusSmall`, accent at alpha 0.2, glyph
   `size: 22` at full-opacity accent), `SizedBox(height: 11)`, 14px/`w800` title
   in `colors.colorText`, `SizedBox(height: 3)`, 11.5px subtitle with
   `maxLines: 1` + `TextOverflow.ellipsis`. Wrap in
   `Semantics(button: true, excludeSemantics: true, label: '<title>. <subtitle>')`
   and `BoxConstraints(minHeight: context.cupidPlatform.tapTarget)`, matching
   `anti_ghost_entry_card.dart:121-126`.
3. Add `_QuickGridRow`: one `Row` with two `Expanded` tiles and a 12px gap.
4. Replace the `_ReminderEntryCard` call site (`home_screen.dart:210-217`) with
   `_QuickGridRow` at the same list position and the same `_cardGap` spacing
   above and below. Left tile: `CupidIcons.notificationsActive`,
   `colors.colorAmber`, `context.reminderNotificationsRowTitle`,
   `context.reminderNotificationsRowSubtitle`, unchanged
   `ReminderScheduleScreen` push, and the existing
   `Key('home_reminder_entry_card')`.
5. Right tile: `CupidIcons.autoAwesome`, `colors.colorPeach`, literal title
   `'Zodiac Red Flag'` (identical in vi and en, mirroring
   `zodiac_red_flag_screen.dart:40-42`), subtitle via the file-local
   `_viEn(context, 'Xem chỉ số xung đột hôm nay', "See today's conflict index")`
   — not an ARB key — `Key('home_zodiac_entry_tile')`, and
   `Navigator.of(context).pushNamed(ZodiacRedFlagScreen.routeName)` using the
   imported constant, never the literal route string.
6. Delete `_ReminderEntryCard` (`home_screen.dart:870-924`) once it is
   unreferenced; leave no dead widget behind.
7. Write `mobile/test/features/home/home_quick_grid_test.dart` covering AC1
   layout and AC2 navigation. The AC2 test must pump a `MaterialApp` carrying
   the same `routes:` entry as `cupid_app.dart:68-71` — pumping a bare
   `HomeScreen` throws "Could not find a generator for route".
8. Run the existing `reminder_entry_point_test.dart`. Only if it asserts on the
   old full-width shape, narrow the assertion to key + tap behavior and record
   the edit in `test-results.md`.

## 4. Acceptance Criteria

- Home renders exactly one `Row` containing both `Key('home_reminder_entry_card')`
  and `Key('home_zodiac_entry_tile')` as equal-width tiles, at the list position
  the Synced Alarm entry previously occupied, with `_cardGap` above and below.
- Tapping `Key('home_zodiac_entry_tile')` lands on `ZodiacRedFlagScreen`.
- Tapping `Key('home_reminder_entry_card')` still opens
  `ReminderScheduleScreen`, with title, subtitle, and glyph unchanged.
- No Dream Jar, Anti-Ghosting, tab-bar, or `ZodiacRedFlagScreen` change appears
  in the diff.

## 5. Planned Outputs

- Code files: the four paths in `## 1B` Write Scope.
- Notes or evidence: `coding-plan/test-results.md` with the targeted test run,
  the static-analysis/build gate, the confirmed `auto_awesome` codepoint and how
  it was read, and the AC1 visual-inspection note.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, Home dashboard presentation only
- Required levels:
  - unit/widget: `mobile/test/features/home/home_quick_grid_test.dart` plus the
    existing `mobile/test/features/reminders/reminder_entry_point_test.dart`
  - mobile build/type-check/static-analysis: `flutter analyze` on `mobile/`
    (resolve the SDK via `FLUTTER_SDK_PATH`, default `$HOME/flutter`)
  - visual inspection: Home in dark theme + `vi` locale compared against the
    design source Home node, using the existing `main_preview.dart` harness
- Required checks:
  - AC1: both tile keys inside one `Row`, equal-width `Expanded`, at the
    preserved list position
  - AC2: tap on the zodiac tile resolves the named route to `ZodiacRedFlagScreen`
  - Regression: reminder entry-point test still passes
- Mobile discoverability / navigation integration: the tile is the discoverable
  surface and lives on the already-reachable Home dashboard; no new top-level
  entry point (AC3).
- Minimum gates by risk surface: as stated in `../architecture/solution.md`
  section 4 — do not restate the gate text here.
- Required regression or contract coverage: `Key('home_reminder_entry_card')`
  must keep resolving for existing tests.
- Evidence format: command + pass/fail summary and assertion excerpts in
  `coding-plan/test-results.md`; one Home capture for the AC1 note.
- Verification strategy:
  - Targeted tests: `flutter test test/features/home/home_quick_grid_test.dart
    test/features/reminders/reminder_entry_point_test.dart` from `mobile/`
  - Build/type-check: `flutter analyze`
  - Required assertion evidence: AC1 layout assertion and AC2 navigation
    assertion quoted in `test-results.md`
- Trap: when capturing the Home frame for the AC1 note, confirm the capture is
  the rendered Home screen and not a splash/loading frame — a splash-frame
  capture silently invalidates the comparison.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-25
