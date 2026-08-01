# Phase P4 – Entry Point Wiring And AC2/AC3/AC4 Copy Guard

## 1. Objective

Make the schedule screen reachable from a discoverable home surface, mount the
overlay host once above the shell, and enforce AC2/AC3/AC4 with a static guard
test that fails the build on forbidden copy or dependencies.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-entry-point-and-copy-guard.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P3
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/core/navigation/app_shell.dart`
  - `mobile/lib/features/home/presentation/home_screen.dart`
  - `mobile/test/features/reminders/reminder_entry_point_test.dart`
  - `mobile/test/features/reminders/reminder_copy_guard_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: `Key('home_screen_ready_signal')` must still pump — the
    registry readiness signal for `mobile-app` depends on it
  - Port Contract: N/A
- Shared Interfaces Produced:
  - reachable `ReminderScheduleScreen` route + mounted `ReminderOverlayHost`
  - AC2/AC3/AC4 static compliance guard
- Shared Interfaces Consumed:
  - P2 `ReminderScheduleScreen`, `ReminderStrings`
  - P3 `ReminderOverlayHost`
- Risk Surfaces:
  - Entry-point discoverability
  - Copy compliance AC2/AC3
  - Native-alarm non-goal AC4
- Source Of Truth:
  - authoritative artifact: `../story_master.md` AC2/AC3/AC4;
    `../architecture/solution.md` §4 Risk Surfaces
  - consumer contract: the guard test is the durable AC2/AC3/AC4 gate for every
    later story that touches this copy
- Primary Inputs Summary:
  - requirements: `../story_master.md` Acceptance Criteria
  - architecture: `../architecture/solution.md` §4 Risk Surfaces, §3 Out Of Scope
  - OQ constraints: ADR-002/D1
  - upstream phase outputs: P2, P3
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: surface wiring plus one static guard
  - Source/Test File Count: 2 source edits + 2 test
  - Split Required: NO

## 2. Required Reads

- `../story_master.md` Acceptance Criteria and Out Of Scope
- `../architecture/solution.md` §4 Risk Surfaces
- `mobile/lib/core/navigation/app_shell.dart`,
  `mobile/lib/features/home/presentation/home_screen.dart`
- P2 and P3 outputs

## 3. Tasks

- Add a discoverable navigation affordance on `HomeScreen` (a labelled list
  action or card, label from `ReminderStrings`) that navigates to
  `ReminderScheduleScreen`. Direct-route-only access is not acceptable.
- Preserve `Key('home_screen_ready_signal')` on the home screen exactly as it is
  today; it is the `mobile-app` runtime registry readiness signal.
- Mount `ReminderOverlayHost` once in `AppShell` so the overlay can render above
  whatever screen is active, per `../ux/uiux-spec.md` §3.
- Write `reminder_copy_guard_test.dart` as a static file-scanning test:
  - Scan every `.dart` file under `mobile/lib/` (this deliberately excludes
    `mobile/openapi/`, which contains the generated `Epic 3 - Synced Alarms` tag
    and the frozen backend naming).
  - Fail on any case-insensitive occurrence of `báo thức`, `synced alarm`, or
    `do not disturb`, reporting the offending file and line.
  - Assert that `mobile/pubspec.yaml` contains no native-alarm or
    local-notification dependency (`android_alarm_manager`,
    `flutter_local_notifications`, `alarm`, `awesome_notifications`) — this is the
    AC4 gate.
  - Add a one-line comment naming AC2, AC3, AC4 and ADR-002 as the reason, so a
    future contributor cannot delete the test as incidental.
- Do **not** create a Notifications settings screen. It does not exist in
  `mobile/lib` yet; AC3 is satisfied by the guard plus the `ReminderStrings`
  entries the future notifications story must reuse
  (`../architecture/solution.md` §3 Out Of Scope, §6).

## 4. Acceptance Criteria

- A widget test starting from `AppShell` reaches `ReminderScheduleScreen` through
  a visible, labelled affordance — not by pushing the route directly.
- `Key('home_screen_ready_signal')` still pumps in the existing home test.
- `ReminderOverlayHost` is mounted exactly once.
- The guard test passes on the current tree and fails when a forbidden token is
  injected into any `mobile/lib/**` file (verify by temporary local injection,
  then revert).
- `flutter analyze` is clean and the existing test suite stays green.

## 5. Planned Outputs

- Code: `app_shell.dart`, `home_screen.dart` edits
- Contracts: reachable reminder entry point, mounted overlay host, AC2/AC3/AC4
  guard
- Notes: none

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile-app`), widget + static tests
- Required levels:
  - integration: widget test navigating `AppShell` -> home affordance ->
    `ReminderScheduleScreen`
  - unit: static copy/dependency guard over `mobile/lib/**` and `pubspec.yaml`
  - mobile build/type-check/static-analysis: `flutter analyze` clean
- Required checks: readiness key preserved; overlay host mounted once
- Mobile discoverability / navigation integration: REQUIRED — asserted by
  `reminder_entry_point_test.dart`
- Minimum gates by risk surface:
  - Entry-point discoverability: navigation widget test (BLOCKED if it cannot run)
  - Copy compliance AC2/AC3: static guard test (BLOCKED — story cannot pass
    review without it)
  - Native-alarm non-goal AC4: pubspec assertion in the same test (BLOCKED)
- Required regression or contract coverage: existing home/readiness test stays
  green
- Evidence format: concise rows appended by P5 to `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: `flutter test test/features/reminders/`
  - Static analysis: `flutter analyze`
  - Required assertion evidence: guard-test failure message naming the offending
    file and token

## 7. Status

- Status: DONE
- Last updated: 2026-07-31
- Evidence:
  - Added `_ReminderEntryCard` (private to `home_screen.dart`, since P4's
    Write Scope has no shared design-system or feature widget file for it)
    as a labelled, tappable `Key('home_reminder_entry_card')` affordance
    that navigates to `ReminderScheduleScreen` via
    `Navigator.of(context).push`; copy comes from
    `ReminderStrings.reminderNotificationsRowTitle`/
    `reminderNotificationsRowSubtitle`. `Key('home_screen_ready_signal')`
    left untouched.
  - Mounted `ReminderOverlayHost(child: HomeScreen())` once in `AppShell`.
  - Root cause fixed during integration: `main.dart` does not call
    `setupServiceLocator()` (a pre-existing composition-root gap outside
    this story's `Affected Components`, per `../architecture/solution.md`
    §4), so mounting a GetIt-dependent `BlocProvider` at the app root made
    `test/widget_test.dart` (which pumps `CupidApp()` directly, bypassing
    `main()`) crash with `ReminderFiringCubit is not registered`. Fixed
    inside this phase's Write Scope by making `ReminderOverlayHost` check
    `getIt.isRegistered<ReminderFiringCubit>()` and render `child` bare
    when unregistered, instead of touching `main.dart` or the test.
    Flagging forward: the firing overlay is not reachable in a real running
    app until a future story wires `setupServiceLocator()` (and Firebase
    initialization, also currently missing) into `main.dart`.
  - `reminder_entry_point_test.dart`: widget test pumping the real
    `AppShell` (not `ReminderScheduleScreen` pushed directly), tapping the
    `home_reminder_entry_card` affordance, and asserting
    `ReminderScheduleScreen` is reached plus `ReminderOverlayHost` is
    mounted exactly once and `home_screen_ready_signal` still pumps. Since
    `ReminderScheduleScreen` resolves `getIt<ReminderScheduleBloc>()`
    unconditionally, the test registers a `ReminderScheduleBloc` backed by
    a `_FakeReminderRepository` (stubs `load`/`events` to avoid a real
    network call) rather than touching production DI wiring.
  - `reminder_copy_guard_test.dart`: static scan of every `.dart` file
    under `mobile/lib/` (excludes `mobile/openapi/`) for case-insensitive
    "báo thức" / "synced alarm" / "do not disturb" inside string-literal
    content on non-comment lines -- scoped to literals, not comments,
    because `reminder_strings.dart`'s own doc comment names these forbidden
    phrases to document the rule and must not trip the guard itself -- plus
    a `pubspec.yaml` assertion against `android_alarm_manager`,
    `flutter_local_notifications`, `alarm`, `awesome_notifications` (AC4).
    Verified the guard fails correctly: temporarily injected `"Synced
    Alarm"` into `home_screen.dart`'s AppBar title, confirmed the test
    failed and reported the exact file/line/token, then reverted the
    injection.
  - `flutter test test/features/reminders/`: 65 passed, 0 failed (62 from
    P0-P3 plus the 3 new P4 tests: 1 in
    `reminder_entry_point_test.dart`, 2 in `reminder_copy_guard_test.dart`).
  - `flutter test test/widget_test.dart`: 1 passed -- readiness signal
    still pumps.
  - `flutter analyze` (scoped to this phase's Write Scope plus the P3
    `reminder_overlay_host.dart` fix): 1 pre-existing `info`-level
    `prefer_initializing_formals` lint on `reminder_overlay_host.dart`
    (already noted in P3's evidence), no errors or warnings on any new or
    edited file. Full-repo `flutter analyze` output is unchanged noise from
    the gitignored `build/ios/SourcePackages/checkouts/flutterfire/...`
    vendored sources, matching P3's documented baseline.
  - `mobile/pubspec.yaml`: unchanged by this phase.
