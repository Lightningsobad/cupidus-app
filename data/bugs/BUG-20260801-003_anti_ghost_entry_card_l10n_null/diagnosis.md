# Diagnosis: BUG-20260801-003_anti_ghost_entry_card_l10n_null

## Root cause

Same defect family as `BUG-20260801-001_app_shell_chat_gate_l10n_null`: this
is a test-fixture gap, not a production defect. The generated
`AppL10n.of(context)` accessor
(`mobile/lib/l10n/generated/app_l10n.dart:71`) performs a hard null-check
(`Localizations.of<AppL10n>(context, AppL10n)!`) that only resolves when an
ancestor `Localizations` widget was built with `AppL10n.delegate`, wired via
`localizationsDelegates`/`supportedLocales` on a `MaterialApp`. The
production composition root (`mobile/lib/app/cupid_app.dart`) always wires
this correctly via `AppL10n.localizationsDelegates` /
`AppL10n.supportedLocales`. The three affected test files built bare
`MaterialApp(...)` harnesses that omitted this wiring, so any production
widget in the pumped tree that calls `AppL10n.of(context)` throws
`_TypeError: Null check operator used on a null value`.

Confirmed before fixing: `service_locator.dart` and `app_shell.dart`'s tab
composition were not touched or altered — this bug's scope is limited to
test-harness `MaterialApp` wiring in the three files below. GetIt gaps in
`gallery_cubit_test.dart` and `pet_entry_point_test.dart` were already
resolved by `BUG-20260801-002`'s commit `d667861`; reproduction below
confirms both files now fail on this `AppL10n.of` defect only, with zero
GetIt errors — no regression.

## Crash sites (3)

1. `_AntiGhostEntryCardChrome`
   (`mobile/lib/features/anti_ghosting/presentation/widgets/anti_ghost_entry_card.dart:125`)
   calls `AppL10n.of(context)`. Reached when `HomeScreen` is pumped by
   `mobile/test/features/vibes/presentation/vibe_screen_test.dart`'s
   `_materialHarness` helper (used by the "tapping the vibe entry card"
   test), which built a bare `MaterialApp` with no l10n delegates.

2. `app_shell.dart:203`'s FAB tooltip calls `AppL10n.of(context)`. Reached
   when `AppShell()` is pumped by
   `mobile/test/features/gallery/gallery_cubit_test.dart`'s "AppShell
   gallery destination" test group, which built a bare `MaterialApp` with no
   l10n delegates.

3. `DreamJarEntryCard`
   (`mobile/lib/features/dream_jar/presentation/widgets/dream_jar_entry_card.dart:22`)
   calls `AppL10n.of(context)`. Reached via `home_screen.dart:119` when
   `HomeScreen` (through `PetPreviewCard`) is pumped by
   `mobile/test/features/pet/presentation/pet_entry_point_test.dart`'s
   shared `_harness(Widget child)` helper (used by every test in the file,
   including the readiness-gate regression test), which built a bare
   `MaterialApp` with no l10n delegates.

## Reproduction (baseline, before fix)

`flutter test` on the three target files
(`test/features/vibes/presentation/vibe_screen_test.dart`,
`test/features/gallery/gallery_cubit_test.dart`,
`test/features/pet/presentation/pet_entry_point_test.dart`) showed each
crash site throwing `_TypeError: Null check operator used on a null value`
at `app_l10n.dart:71:55`, with zero `"is not registered inside GetIt"`
occurrences (confirming the GetIt gap from BUG-002 is already resolved in
these files and this bug is scoped purely to the l10n wiring gap).

## Fix pattern (matches BUG-001 precedent)

Add `import 'package:cupid_mobile/l10n/generated/app_l10n.dart';` and
`localizationsDelegates: AppL10n.localizationsDelegates,` /
`supportedLocales: AppL10n.supportedLocales,` to each affected test
harness's `MaterialApp`. See `fix-evidence.md` for the exact per-file
edits and verification.

## Out-of-scope items observed, not touched

- `pair_gate_cubit_test.dart` constructor mismatch — pre-existing,
  unrelated.
- `reminder_copy_guard_test.dart` — pre-existing, unrelated.
- `app_shell_test.dart` (paired/unpaired) stale `InkWell` tab-count
  assertions — `BUG-20260801-004`, not touched.
- `reminder_entry_point_test.dart`'s structurally-unreachable
  `ReminderOverlayHost` assertion — `BUG-20260801-005`, not touched.
- ~76 `prefer_initializing_formals` lints — pre-existing, unrelated.
