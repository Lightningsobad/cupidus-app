# Diagnosis: BUG-20260801-001_app_shell_chat_gate_l10n_null

## Root cause (verified, not the unverified bug_master.md hypothesis as-is)

`mobile/lib/core/navigation/app_shell.dart:203` calls
`AppL10n.of(context).app_shell_account_entry_tooltip` while building the
account-hub `FloatingActionButton`. `AppL10n.of` is a hard null-check
(`Localizations.of<AppL10n>(context, AppL10n)!`,
`mobile/lib/l10n/generated/app_l10n.dart:71`) that only succeeds when an
ancestor `Localizations` widget was built with `AppL10n.delegate` in its
`localizationsDelegates` list. The app's real composition root,
`mobile/lib/app/cupid_app.dart`, wires this correctly
(`localizationsDelegates: AppL10n.localizationsDelegates`). The failing test
harness does not:

`mobile/test/core/navigation/app_shell_test.dart`'s `_harness()` helper
pumps `AppShell` directly inside a bare `MaterialApp(theme: ..., home:
AppShell(...))` with no `localizationsDelegates`/`supportedLocales` at all.
This harness predates both the FAB tooltip (added by the STORY-015 merge)
and the Timeline entry point (STORY-012); it was never updated when
`app_shell.dart` gained an `AppL10n.of` dependency, so `Localizations.of`
returns `null` and the `!` throws, exactly matching the reported stack
(`AppL10n.of` -> `_AppShellState.build` closure -> `ChatEntryGate.build`).

This is a **test-fixture gap**, not a production defect: `main`'s
`CupidApp`/real app boot path always supplies the delegate.

## Correction to bug_master.md's working hypothesis

bug_master.md states all 10 `flutter test` failures share this exact crash
signature. That is **not accurate** — confirmed by direct reproduction
before and after this fix:

- Only `app_shell_test.dart`'s two tests ("paired: ..." and "unpaired: ...")
  hit this literal `AppL10n.of` / `ChatEntryGate` crash. Both are now fixed
  (see fix-evidence.md).
- `mobile/test/features/vibes/presentation/vibe_screen_test.dart` and
  `mobile/test/features/pet/presentation/pet_entry_point_test.dart` hit the
  *same defect pattern* (missing `AppL10n` delegate in a bare `MaterialApp`
  test harness) but through a **different production widget** —
  `_AntiGhostEntryCardChrome` (`mobile/lib/features/anti_ghosting/presentation/widgets/anti_ghost_entry_card.dart:125`)
  — which is outside this bug's declared scope (`app_shell.dart` /
  `chat_entry_gate.dart` only).
- `mobile/test/widget_test.dart` (the registry readiness gate),
  `mobile/test/app/feature_flags_test.dart`,
  `mobile/test/features/gallery/gallery_cubit_test.dart`, and
  `mobile/test/features/reminders/reminder_entry_point_test.dart` fail from
  an entirely unrelated root cause: `Bad state: GetIt: Object/factory with
  type CouplePairingStore is not registered inside GetIt` (thrown building
  `_TimelineEntryPointGate`, `mobile/lib/features/home/presentation/home_screen.dart:133`,
  via `HomeScreen._defaultResolvePairingStatus` at line 72), or the sibling
  `ChatPartnerStore is not registered inside GetIt` thrown building
  `AppShell` itself (`mobile/lib/core/navigation/app_shell.dart:76`) in
  `gallery_cubit_test.dart`/`reminder_entry_point_test.dart`. Neither of
  these involves `AppL10n` at all. Git history shows
  `app_shell_test.dart` was last substantively touched in STORY-007 (P4),
  before STORY-012 added the Timeline entry point's `CouplePairingStore`
  dependency to `HomeScreen` — this GetIt gap predates STORY-015 and was
  simply masked because the (later-introduced) `AppL10n` crash threw first,
  earlier in `AppShell.build()`, before the framework ever descended into
  building `HomeScreen`'s children.
- `pair_gate_cubit_test.dart` and `reminder_copy_guard_test.dart` are the
  two constraint-listed pre-existing/out-of-scope failures.

Net: this bug's actual, in-scope defect (the `app_shell.dart` /
`chat_entry_gate.dart` `AppL10n.of` null crash) is fixed and verified. The
broader "10 failures, one root cause" framing in bug_master.md is
incorrect; the remaining failures are separate, previously-undiscovered
defects (see fix-evidence.md "Blocker" section).
