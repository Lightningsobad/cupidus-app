# STORY-002 Home Dashboard Quick Grid — Zodiac Red Flag Tile — solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-25

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: AC1 requires a literal 2-column quick grid where the
  code today renders only full-width stacked entry cards; AC2 requires the
  first production consumer of STORY-001's already-registered named route.
- Architectural invariants / non-goals: no new screen, cubit, repository, or
  network call; Home stays a presentation-only composition; the Synced Alarm
  entry keeps its copy, glyph, tap target, and `Key('home_reminder_entry_card')`
  through the container reshape.
- Proposed technical direction: replace the single `_ReminderEntryCard` call
  site in `home_screen.dart` with one `_QuickGridRow` (`Row` + two `Expanded`
  tiles, 12px gap) at the identical list position and `_cardGap` rhythm; the
  left tile is the reshaped Synced Alarm entry, the right tile is the new
  Zodiac Red Flag entry pushing `ZodiacRedFlagScreen.routeName`.
- Why this fits the current system: `Row` + `Expanded` is the existing layout
  idiom in this file; there is no `GridView` precedent and two items do not
  justify introducing one.

### Key Discovery

Three code facts contradict the literal wording of the UX spec and must be
carried into implementation, or the phase will produce a broken build or a
false-passing test:

1. **There is no ARB pipeline on this surface.** UX §3.2 asks for two
   "l10n keys" named `home_zodiac_tile_subtitle`. `home_screen.dart` resolves
   every user-facing string through the file-local
   `_viEn(context, vi, en)` helper (`home_screen.dart:73`, wrapping
   `AuthLocaleText.viEn`), and `reminder_strings.dart:13` documents this as
   deliberately "not the `AppL10n` ARB pipeline". The UX intent (vi/en copy
   pair, verbatim strings) is preserved; the mechanism is `_viEn`, not an ARB
   key. Adding an ARB key here would be a new, inconsistent l10n path.
2. **The named-route rationale in UX §3.2 does not hold, but the decision
   still does.** `routeName` is a static on `ZodiacRedFlagScreen`
   (`zodiac_red_flag_screen.dart:27`), so referencing it requires importing the
   screen anyway — `pushNamed` does not avoid a cross-feature import. The named
   route is still ACCEPTED (section 6) because it keeps one registration source
   of truth, but the import is mandatory and the literal `'/zodiac/red-flag'`
   must never be typed into `home_screen.dart`.
3. **This story is the first `pushNamed` call site in `mobile/lib`.** The
   `routes:` map (`cupid_app.dart:68-71`) has never been exercised at runtime.
   A widget test that pumps a bare `HomeScreen` will throw
   "Could not find a generator for route"; the AC2 test must pump a
   `MaterialApp` carrying the same `routes:` entry. Related accepted
   limitation: `main_preview.dart` has no `routes:` map, so tapping the tile
   inside the preview harness throws. The harness is capture-only, so this is
   accepted, not fixed — do not add a preview route as scope creep.

## 3. Scope And Assumptions

- In Scope: `home_screen.dart` quick-grid composition (new private
  `_QuickGridRow` + tile widget, reshaped Synced Alarm entry, new Zodiac tile
  with named-route navigation), one new `CupidIcons` glyph constant, and the
  widget tests covering both tiles.
- Out Of Scope: `ZodiacRedFlagScreen` and its data layer, every other Home
  entry card (Dream Jar and Anti-Ghosting stay full-width), tab bar, app shell,
  and any live/personalized Zodiac data in the subtitle.
- Assumptions affecting design: the Product Owner's patched Out-of-Scope bullet
  ratifies UX §2 Option A — the Synced Alarm container reshape is required
  scope. Architecture does not re-triage that business decision.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `mobile/lib/features/home/presentation` (mobile app
  `mobile-app`).
- New or changed boundaries: none. Home gains a read-only navigation edge to
  the already-registered global zodiac route; no new dependency direction
  beyond an import of `ZodiacRedFlagScreen` for its route constant.
- Shared patterns reused: `Row` + `Expanded` layout idiom, `_viEn` copy helper,
  `Semantics(button: true, excludeSemantics: true)` + `BoxConstraints(minHeight:
  tapTarget)` chrome from `anti_ghost_entry_card.dart:121-126`, and
  `context.cupidPlatform` / `colors` design tokens (`colorAmber`, `colorPeach`,
  `colorSurface`, `radiusCard`, `radiusSmall`).

### Affected Modules

- Mobile: `features/home/presentation`, `design_system/icons`, and the matching
  `mobile/test` widget-test modules.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Quick-grid layout fidelity (AC1) | `cupid-app-design-system` `Cupid Screens.dc.html` Home node (lines 305-326) + `ux/ux-spec.md` §3 | Single `Row` with two equal `Expanded` tiles, 12px gap, tile internals and tokens exactly per UX §3; no `GridView`, no change to sibling cards | Widget test asserts both tile keys render inside one `Row` at the old list position, plus visual inspection of Home in dark theme + `vi` against the design node | `DESIGN_SOURCE_UNAVAILABLE` — record the deviation, do not approximate from memory |
| Zodiac route navigation (AC2) | `ZodiacRedFlagScreen.routeName = '/zodiac/red-flag'` (`zodiac_red_flag_screen.dart:27`), registered at `cupid_app.dart:68-71` | Push the constant, never the literal; AC2 test pumps a `MaterialApp` carrying the same `routes:` entry (see Key Discovery 3) | Widget test taps `Key('home_zodiac_entry_tile')`, pumps, and asserts `ZodiacRedFlagScreen` is on screen | `ROUTE_CONTRACT_MISSING` — stop if the route constant or registration is absent |
| Synced Alarm entry regression | `mobile/test/features/reminders/reminder_entry_point_test.dart` + `Key('home_reminder_entry_card')` | Key, copy getters, glyph, and `ReminderScheduleScreen` push preserved verbatim through the reshape | Existing reminder entry-point test passes unmodified | If it asserts on the old full-width shape, narrow the assertion to key + tap target and record the edit as evidence |
| Icon glyph correctness | Bundled `mobile/assets/fonts/MaterialSymbolsRounded-Variable.ttf` cmap (`cupid_icons.dart:9-11`) | Read the `auto_awesome` codepoint from the bundled font cmap via `fontTools`; never copy it from Flutter's `Icons` class or from memory | Mobile static analysis passes and visual inspection shows the intended glyph, not tofu or a neighbouring glyph | `CMAP_LOOKUP_UNAVAILABLE` — stop and report; do not guess a codepoint |

### Lane Handoff

#### Mobile Lane

- Responsibilities: all of section 3 In Scope, in one phase.
- Authoritative inputs: `story_master.md`, `ux/ux-spec.md` §3-§5, this file.
- Guardrails:
  - Do not add an ARB/`AppL10n` key; use `_viEn` (Key Discovery 1).
  - Do not hardcode `'/zodiac/red-flag'`.
  - Do not introduce `GridView`, `Wrap`, or `StaggeredGrid` for two tiles.
  - Do not fetch or render live `ZodiacConflictIndex` data in the subtitle.
  - Do not touch Dream Jar, Anti-Ghosting, tab bar, or `ZodiacRedFlagScreen`.
  - Do not remove or rename `Key('home_reminder_entry_card')`.
  - Do not invent the icon codepoint.

## 5. Non-Functional Impact

- Vietnamese and English subtitles differ in length; both tiles must stay equal
  height, so the subtitle is `maxLines: 1` + `TextOverflow.ellipsis` and the
  tile carries `BoxConstraints(minHeight: context.cupidPlatform.tapTarget)` —
  wrapping subtitles would break the grid rhythm at large text scales.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| `Navigator.pushNamed(ZodiacRedFlagScreen.routeName)` | STORY-001 registered the route precisely for screens "pushed above the shell" (`cupid_app.dart:65-67`); keeps one registration source of truth and makes AC2 assertable by route name | ACCEPTED | Requires the import anyway and requires the AC2 test to pump a `MaterialApp` with the routes map |
| `MaterialPageRoute(builder: (_) => const ZodiacRedFlagScreen())` | Matches every other Home entry card and works in the `main_preview` harness | REJECTED | Would leave the registered route with zero production consumers and duplicate the screen's entry contract in two places |
