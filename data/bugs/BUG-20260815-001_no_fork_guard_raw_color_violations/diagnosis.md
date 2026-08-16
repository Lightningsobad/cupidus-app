# Diagnosis: BUG-20260815-001 ADR-004 No-Fork Guard Red — Raw Color Literals

Bug id: BUG-20260815-001_no_fork_guard_raw_color_violations
Owner: bug-fixer (Justin-BugFixer)
Work location: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`

## Pre-Fix Reproduction Gate

Original failure anchor: ADR-004 no-fork/raw-color guard test —
`mobile/test/design_system/no_fork_guard_test.dart`, test
`AC 4 no-fork guard: features/app/core never fork on a raw color literal or
Platform.is*/defaultTargetPlatform`.

Reproduction modality: test execution (same modality as the reported failure —
this is a test-failure bug).

Command:
```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit/mobile
/Users/alantravala/flutter/bin/flutter test test/design_system/no_fork_guard_test.dart
```

Expected result (bug present): guard test FAILS listing 7 forbidden color
literals.

Actual result: FAILED (`00:00 +0 -1: Some tests failed.`), exit code 1, with
exactly the 7 reported violations:

```
lib/features/chat/presentation/screens/ghost_settings_screen.dart:211: forbidden pattern "Colors."
lib/features/chat/presentation/screens/ghost_settings_screen.dart:411: forbidden pattern "Colors."
lib/features/account/presentation/screens/notification_settings_screen.dart:359: forbidden pattern "Color(0x"
lib/features/reminders/presentation/screens/reminder_schedule_screen.dart:448: forbidden pattern "Colors."
lib/features/reminders/presentation/screens/reminder_schedule_screen.dart:449: forbidden pattern "Colors."
lib/features/reminders/presentation/screens/reminder_schedule_screen.dart:452: forbidden pattern "Colors."
lib/features/reminders/presentation/widgets/reminder_weekday_chips.dart:71: forbidden pattern "Colors."
```

Result: REPRODUCED — every reported anchor (file + line) matches the live
failure output 1:1.

Note vs bug report wording: the bug report describes these as raw
`Color(0x...)` literals. The guard actually flags 6 of the 7 under the
forbidden pattern `"Colors."` (Flutter's `Colors.*` const palette) and only
`notification_settings_screen.dart:359` under `"Color(0x"`. Same root-cause
family (ADR-004 raw color literal bypassing ThemeExtension tokens); the anchor
set is unchanged.

## Root Cause

The guard (`mobile/test/design_system/no_fork_guard_test.dart`) scans every
`.dart` file under `lib/features`, `lib/app`, `lib/core` for the substrings
`Color(0x`, `Colors.`, `Platform.is`, `defaultTargetPlatform`. Only
`lib/design_system/` is exempt, because that is where D3/ADR-004 says color
values may be declared.

Three stories each introduced a color value that has no equivalent in the
shared `CupidColorTokens` ThemeExtension, and each reached for the framework
constant instead of adding a design-system value. The guard is a whole-repo
scan, so none of the three story branches could see the failure in isolation;
it only turns red once STORY-019, STORY-021 and STORY-031 are merged onto the
integration branch.

Two distinct value families, both missing from the token set:

1. **Pure-white on-accent foreground** (3 violations). A `#fff` glyph or
   toggle knob painted on top of `CupidColorTokens.gradientHot`. No shared
   token exposes this: `colorSurface` is `#FFFFFF` in the light theme but
   `#241B42` in dark, so it is not a substitute.
   - `ghost_settings_screen.dart:211` — `Colors.white` hero glyph.
   - `ghost_settings_screen.dart:411` — `Colors.white` toggle knob.
   - `notification_settings_screen.dart:359` — `Color(0xFFFFFFFF)` toggle knob
     (same component pattern, written as a hex literal instead).

2. **"No paint"** (4 violations). Not a design color at all — the caller needs
   the absence of a fill.
   - `reminder_schedule_screen.dart:448,449,452` — the confirm CTA's
     `DecoratedBox` wrapper paints the gradient and the glow, so the inner
     `ElevatedButton` must suppress its own background/disabled-background/
     shadow. This is the same construction as
     `design_system/adaptive/cupid_primary_button.dart:63,65`, which is legal
     only because it lives inside `lib/design_system/`.
   - `reminder_weekday_chips.dart:71` — `Material(color: Colors.transparent)`
     used purely as an ink host for the chip's `InkWell`.

## Fix Strategy

Family 1: add one additive design-system value,
`OnAccentPalette.foreground` in
`mobile/lib/design_system/tokens/on_accent_palette.dart`, exported from the
`design_system.dart` barrel — mirroring the existing `SplashPalette` /
`CouplePresencePalette` / `PetHeroGradient` precedent for design-source values
that no shared token carries. All three screens already import the barrel, so
no new imports are needed. No existing shared token is modified.

Family 2: `reminder_weekday_chips.dart` switches to
`Material(type: MaterialType.transparency)`, the repo-wide idiom for a
transparent ink host (~15 existing call sites in `lib/features`).
`reminder_schedule_screen.dart` declares a file-private
`const Color _transparent = Color.fromARGB(0, 0, 0, 0);`, mirroring the
`love_contracts/presentation/widgets/add_clause_sheet.dart:21` precedent for
transparent chrome that is not a design token.

Every substitution is value-identical to what it replaces
(`Colors.white` == `Color(0xFFFFFFFF)` == `OnAccentPalette.foreground`;
`Colors.transparent` == `Color.fromARGB(0, 0, 0, 0)`;
`Material(color: transparent)` == `Material(type: MaterialType.transparency)`
at elevation 0), so rendering is unchanged by construction.

## Changed Files

- `mobile/lib/design_system/tokens/on_accent_palette.dart` (new)
- `mobile/lib/design_system/design_system.dart` (barrel export)
- `mobile/lib/features/chat/presentation/screens/ghost_settings_screen.dart`
- `mobile/lib/features/account/presentation/screens/notification_settings_screen.dart`
- `mobile/lib/features/reminders/presentation/screens/reminder_schedule_screen.dart`
- `mobile/lib/features/reminders/presentation/widgets/reminder_weekday_chips.dart`

6 files, all inside the integration worktree, left uncommitted for Scrum
Master.

## Not In Scope

The full `flutter test` suite is still RED on this branch with 8 failures that
are unrelated to this bug (caption typography fidelity, `waiting_sky_backdrop`,
home-screen ready signal, ADR-002 copy guard on `permissions_screen.dart`).
Those belong to BUG-20260814-003, BUG-20260814-004 and BUG-20260815-002 and
were not touched here. See the Regression Evidence section of
`fix-evidence.md`.
