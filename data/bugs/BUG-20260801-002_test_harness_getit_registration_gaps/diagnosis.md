# Diagnosis: BUG-20260801-002_test_harness_getit_registration_gaps

## Root cause (verified)

`mobile/lib/core/di/service_locator.dart` correctly registers both
`CouplePairingStore` (`registerLazySingleton`, ~line 147) and
`ChatPartnerStore` (`registerLazySingleton`, ~line 252) in the real app's
composition root. This is **not** a production DI defect — confirmed by
direct reading of the full file before touching anything.

Both crashes are test-fixture gaps:

1. `CouplePairingStore is not registered inside GetIt` — thrown building
   `_TimelineEntryPointGate` (`mobile/lib/features/home/presentation/home_screen.dart:133`,
   via `HomeScreen._defaultResolvePairingStatus` at line 72, which calls
   `getIt<CouplePairingStore>().resolve()`). `_TimelineEntryPointGateState`
   evaluates this eagerly in a `late final` field initializer
   (`late final Future<PairingStatus> _pairingStatus =
   widget.resolvePairingStatus();`), so any test that mounts `HomeScreen`
   (directly, or via `AppShell`) without either registering
   `CouplePairingStore` in `getIt` or supplying `HomeScreen`'s
   `resolvePairingStatus` override throws synchronously on build.
2. `ChatPartnerStore is not registered inside GetIt` — thrown building
   `AppShell` (`mobile/lib/core/navigation/app_shell.dart:76`,
   `late final ChatPartnerStore _partnerStore = widget._partnerStore ??
   getIt<ChatPartnerStore>();`). This field is *always* evaluated because
   `AppShell.build()` unconditionally wraps its content in `ChatEntryGate
   (partnerStore: _partnerStore, ...)`. `AppShell` has override hooks for
   `partnerStore`/`chatRepository`/`coordinator`/`backendUserIdStore`/
   `consentStore`, but **no** override hook for `HomeScreen`'s internal
   `CouplePairingStore` need — this asymmetry is why item 1 cannot always be
   avoided just by using `AppShell`'s own constructor parameters.

## Scope correction vs. the handoff's reproduction (verified, not assumed)

The handoff named two failures reproducing in `widget_test.dart` /
`app_shell.dart`. Direct `flutter test` reproduction before any fix showed
the *same two* GetIt gaps additionally affecting five more files not named
in the handoff (some previously fully masked because `AppL10n.of` null
crashes, fixed separately under `BUG-20260801-001`, threw even earlier in
the same build for `app_shell_test.dart`):

- `mobile/test/widget_test.dart` (the registry readiness gate itself) —
  `CouplePairingStore`.
- `mobile/test/app/feature_flags_test.dart` — `CouplePairingStore`.
- `mobile/test/core/navigation/app_shell_test.dart` (both "paired" and
  "unpaired" cases) — `CouplePairingStore`.
- `mobile/test/features/gallery/gallery_cubit_test.dart` ("AppShell gallery
  destination" group) — `ChatPartnerStore`.
- `mobile/test/features/reminders/reminder_entry_point_test.dart` —
  `ChatPartnerStore` + `CouplePairingStore` (mounts bare `AppShell()`, so
  both `ChatEntryGate` and `HomeScreen`'s Home tab are unconditionally
  built).
- `mobile/test/features/vibes/presentation/vibe_screen_test.dart` ("tapping
  the vibe entry card..." test) — `CouplePairingStore` (mounts `HomeScreen`
  directly with no override).
- `mobile/test/features/pet/presentation/pet_entry_point_test.dart`
  ("regression: home_screen_ready_signal" test) — `CouplePairingStore`
  (mounts `HomeScreen` directly with no override).

All seven files above are now fixed (see fix-evidence.md). Zero occurrences
of `"is not registered inside GetIt"` remain anywhere in the full-suite
`flutter test` output, confirmed across three consecutive full runs.

## Newly-unmasked, out-of-scope findings (do not silently fix; report only)

Fixing the GetIt gap let the build proceed further and unmasked several
**distinct, pre-existing** defects unrelated to dependency injection. None
of these were introduced by this fix; each is a genuinely separate bug that
was previously hidden behind the earlier GetIt crash, matching the same
discovery pattern that produced this bug's own record under
`BUG-20260801-001`.

1. **`app_shell_test.dart` stale `InkWell` tab-count assertion** (both
   "paired" and "unpaired" cases). `app_shell.dart`'s tab bar now always
   includes an unconditional Gallery tab item (STORY-013) in addition to
   Home (always) and Chat (conditional on pairing). The test's
   `findsNWidgets(2)` / `findsNWidgets(1)` assertions predate STORY-013 and
   were never updated; the actual current counts are 3 (paired) / 2
   (unpaired). `BUG-20260801-001`'s fix-evidence.md already surfaced this
   symptom in its unpaired case but did not give it its own tracked item —
   confirming it here as its own finding since both cases now reach it.
2. **`gallery_cubit_test.dart` / `vibe_screen_test.dart` /
   `pet_entry_point_test.dart` — `AppL10n.of(context)` null-check crashes**,
   same defect *pattern* already tracked by `BUG-20260801-003` (missing
   `localizationsDelegates`/`supportedLocales` in a test's bare
   `MaterialApp`), but confirmed here through **additional crash sites**
   not yet listed in that bug's `bug_master.md`:
   - `gallery_cubit_test.dart`'s "AppShell gallery destination" group pumps
     `MaterialApp(theme: ..., home: const AppShell())` with no
     `localizationsDelegates`; the crash site is
     `app_shell.dart:203`'s FAB `tooltip: AppL10n.of(context)
     .app_shell_account_entry_tooltip` (not `_AntiGhostEntryCardChrome`,
     the site `BUG-20260801-003` currently names).
   - `pet_entry_point_test.dart`'s regression test's harness also lacks the
     delegates; the crash site there is `DreamJarEntryCard`
     (`home_screen.dart:119`), not `_AntiGhostEntryCardChrome` as
     `BUG-20260801-003` currently assumes.
   `vibe_screen_test.dart`'s crash site does match `BUG-20260801-003`'s
   `_AntiGhostEntryCardChrome` prediction.
   Recommend `BUG-20260801-003`'s `bug_master.md` be updated with these
   confirmed additional crash sites/files before that bug is picked up.
3. **`reminder_entry_point_test.dart` — structural test-harness gap**,
   unrelated to GetIt or `AppL10n`. The test asserts
   `expect(find.byType(ReminderOverlayHost), findsOneWidget)`, but
   `ReminderOverlayHost` is mounted only by `PairGateShell`
   (`mobile/lib/core/navigation/pair_gate_shell.dart:78`), which this
   test's harness never composes — it pumps bare `const AppShell()`
   directly. `ReminderOverlayHost` can never appear in this widget tree as
   currently written; the assertion was unreachable dead code, masked
   entirely by the GetIt crash until now. This needs a new bug record (no
   existing bug tracks it).

Items 1-3 above are all confirmed via direct reproduction and root-caused
to their exact source line, but are explicitly out of this bug's declared
scope (test-harness *GetIt registration* gaps only) and were left
untouched, per the "do not fix pre-existing out-of-scope items" constraint.
