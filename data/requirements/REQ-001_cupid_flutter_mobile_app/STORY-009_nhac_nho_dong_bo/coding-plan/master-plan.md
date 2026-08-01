# Master Coding Plan – Nhắc Nhở Đồng Bộ (Synced Reminder)

## 1. Planning Metadata

- Story ID: STORY-009
- Complexity: M (standard)
- Planning Owner: Tech Lead
- Source Requirements: `../story_master.md`
- Source UX: `../ux/uiux-spec.md` §2–§8
- Source Architecture: `../architecture/solution.md`
- OQ Constraints Source: `../architecture/solution.md` §3 Open Question Constraints
- Review Input: none yet
- Requirement Configuration Guide: `../../deployment/configuration-guide.md`
  (update NOT required — no env var, secret, or integration change)

## 2. Planning Goal

- Shared contract owner: Tech Lead (`../architecture/solution.md` §4 D1–D5)
- Contract-first phase required: YES (P0 fixes wire events + reminder model)
- Parallel execution possible: NO (single mobile lane, sequential dependency chain)
- Critical path: P0 -> P1 -> P2 -> P3 -> P4 -> P5
- Parallelism notes: one lane only. P2 and P3 both consume P1 but both edit
  presentation files that P4 then wires, so they stay sequential to avoid
  overlapping edits to `service_locator.dart` and the icon constants.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Connection Pattern | Producer Phase | Consumer Phase | Example Artifact / Payload |
|---|---|---|---|---|---|
| Frozen `alarms` wire events | backend (frozen) | Socket.IO via `RealtimeCoordinator` | P0 (mirrors) | P1, P3 | `emit('setAlarm', {time: '2026-07-31T06:30:00.000Z', userId: '<User.id>'})` |
| `SyncedReminder` + `ReminderStage` | Tech Lead / P0 | in-process Dart model | P0 | P1, P2, P3 | `status: 'pending_confirmation'`, `stopperIds: []` -> `ReminderStage.needsMyConfirmation` |
| `ReminderRepository` | P0 | `get_it` singleton | P0 | P1, P3 | `Stream<SyncedReminder>` + `Future<SyncedReminder?> load()` |
| `ReminderScheduleBloc` | P1 | `flutter_bloc` | P1 | P2, P4 | `ReminderScheduleState.bothConfirmed` |
| `ReminderStrings` (canonical vi/en copy) | P2 | `context.viEn(vi, en)` extension | P2 | P3, P4 | `ReminderStrings.ruleCard` |
| `ReminderOverlayHost` | P3 | widget mounted above the shell | P3 | P4 | `ReminderOverlayHost(child: HomeScreen())` |

## 3A. Risk Surfaces And Verification Contract

| Risk Surface | Source Of Truth | Consumer Contract | Minimum Gate | Required Dependency | Blocker If Gate Cannot Run |
|---|---|---|---|---|---|
| Realtime reminder events | `backend/src/modules/alarms/alarm.constants.ts`, `mobile/lib/core/realtime/cupid_realtime.dart` | `ReminderRepository` stream + emit payloads | unit tests over a fake `RealtimeCoordinator` covering 5 inbound + 3 outbound events | P0 | BLOCKED; no live-backend hand verification |
| Copy compliance AC2/AC3 | `../ux/uiux-spec.md` §2–§4, ADR-002 | `ReminderStrings` is the sole user-facing copy source | `reminder_copy_guard_test.dart` static scan of `mobile/lib/**` | P4 | BLOCKED — story cannot pass review |
| Native-alarm non-goal AC4 | `../story_master.md` Out of Scope | no alarm / local-notification plugin in `mobile/pubspec.yaml` | dependency assertion in the same guard test | P4 | BLOCKED |
| Client-side 5-minute timeout | `../architecture/solution.md` §4 D4 | timer clears overlay locally, emits nothing | cubit test with injected timer seam asserting zero outbound emits | P3 | BLOCKED |
| Overlay mount + a11y | `../ux/uiux-spec.md` §3, §7 | one host above the shell | widget test: semantics announcement, non-gesture dismiss, safe-area padding | P3 | BLOCKED |
| Entry-point discoverability | ADR-009, `mobile/lib/core/navigation/app_shell.dart` | home exposes a reminder action | widget test: home tap reaches schedule screen; `Key('home_screen_ready_signal')` still pumps | P4 | BLOCKED (runtime readiness key) |

## 4. Lane Summary

- Backend required: NO
- Frontend required: NO
- Mobile required: YES
- DevOps required: NO
- Initial implementation owner: Mobile Developer
- Final verification owner: Mobile Developer (P5)
- Shared contract owner: Tech Lead
- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` (registry readiness is
    a `flutter test` widget signal on `Key('home_screen_ready_signal')`, already
    covered by the P5 test run; `flutter run` needs an interactive device),
    build command source: runtime registry `buildCommand`
    (`flutter build apk --debug`)

## 5. Phases Overview

The following table is mandatory. Keep all columns exactly as shown so Scrum
Master and implementation agents can route phases without guessing.

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|------|-------|------|------------|----------------|-------------|----------------|-----------------|------------|--------|
| P0 | Mobile Developer | Contract | None | NO | `mobile/lib/features/reminders/data/reminder_wire_events.dart`, `mobile/lib/features/reminders/domain/synced_reminder.dart`, `mobile/lib/features/reminders/domain/reminder_stage.dart`, `mobile/lib/features/reminders/data/reminder_repository.dart`, `mobile/test/features/reminders/synced_reminder_test.dart`, `mobile/test/features/reminders/reminder_repository_test.dart` | `../architecture/solution.md` §4 D1/D2/D3/D5 | wire-event constants, reminder model + stage derivation, repository with socket writes and REST hydration | unit tests, `flutter analyze` | DONE |
| P1 | Mobile Developer | Mobile | P0 | NO | `mobile/lib/features/reminders/presentation/reminder_schedule_bloc.dart`, `mobile/lib/features/reminders/presentation/reminder_schedule_state.dart`, `mobile/lib/features/reminders/data/reminder_local_prefs.dart`, `mobile/lib/core/di/service_locator.dart`, `mobile/test/features/reminders/reminder_schedule_bloc_test.dart`, `mobile/test/features/reminders/reminder_local_prefs_test.dart` | `../architecture/solution.md` §4 D1/D3, §3 ASSUMPTION-1; P0 outputs | schedule bloc + state, local weekday/timeout-notice prefs, DI registration | unit tests, `flutter analyze` | DONE |
| P2 | Mobile Developer | Mobile | P1 | NO | `mobile/lib/features/reminders/presentation/reminder_strings.dart`, `mobile/lib/features/reminders/presentation/screens/reminder_schedule_screen.dart`, `mobile/lib/features/reminders/presentation/widgets/reminder_time_stepper.dart`, `mobile/lib/features/reminders/presentation/widgets/reminder_weekday_chips.dart`, `mobile/lib/design_system/icons/cupid_icons.dart`, `mobile/test/features/reminders/reminder_schedule_screen_test.dart` | `../ux/uiux-spec.md` §2, §6, §7, §8; P1 outputs | canonical vi/en copy file, schedule screen, stepper + weekday widgets, additive glyph constants | widget tests, `flutter analyze` | DONE |
| P3 | Mobile Developer | Mobile | P2 | NO | `mobile/lib/features/reminders/presentation/reminder_firing_cubit.dart`, `mobile/lib/features/reminders/presentation/widgets/reminder_firing_overlay.dart`, `mobile/lib/features/reminders/presentation/reminder_overlay_host.dart`, `mobile/lib/core/di/service_locator.dart`, `mobile/test/features/reminders/reminder_firing_cubit_test.dart`, `mobile/test/features/reminders/reminder_firing_overlay_test.dart` | `../architecture/solution.md` §4 D4/D5; `../ux/uiux-spec.md` §3, §6, §7; P2 outputs | firing cubit with 5-minute client timeout, firing overlay, overlay host, DI registration | unit + widget tests, `flutter analyze` | DONE |
| P4 | Mobile Developer | Mobile | P3 | NO | `mobile/lib/core/navigation/app_shell.dart`, `mobile/lib/features/home/presentation/home_screen.dart`, `mobile/test/features/reminders/reminder_entry_point_test.dart`, `mobile/test/features/reminders/reminder_copy_guard_test.dart` | `../architecture/solution.md` §4 Risk Surfaces; `../story_master.md` AC2/AC3/AC4; P3 outputs | discoverable home entry point, overlay host mount, AC2/AC3/AC4 static guard test | widget test, static guard test, `flutter analyze` | DONE |
| P5 | Mobile Developer | Mobile Verification | P4 | NO | `mobile/test/features/reminders/**`, `coding-plan/test-results.md` | phase `## 6. Test Scope` sections of P0–P4 | full mobile verification run + `test-results.md` | `flutter analyze`, `flutter test`, `flutter build apk --debug` | DONE |

The final phase must be a verification phase for `standard` and `complex`
stories. Tech Lead work is incomplete until that phase file exists.

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | `phase-P0-reminder-contract-and-data.md` |
| P1 | `phase-P1-reminder-schedule-state.md` |
| P2 | `phase-P2-reminder-schedule-screen.md` |
| P3 | `phase-P3-reminder-firing-overlay.md` |
| P4 | `phase-P4-entry-point-and-copy-guard.md` |
| P5 | `phase-P5-verification.md` |

Artifact hygiene:

- Each phase id in the table above maps to exactly one canonical
  `phase-Px-*.md` file.
- Do not leave duplicate files for the same phase id.
- Backend/frontend/mobile implementation phases must fit one specialist lifecycle
  (roughly six source/test files max) or be split.
- Implementation phase test scopes must not include backend e2e/test_e2e,
  Playwright/browser e2e, traces, or scenario reruns.

## 6. Risks And Notes

- Risks: see `../architecture/solution.md` §7. The two carried into planning are
  ASSUMPTION-1 (no server-side recurrence field, so no auto-repeat claim in copy)
  and R9 (no server FCM dispatch, so no background delivery claim anywhere).
- OQ-driven constraints: ADR-002/D1 wording — every user-facing string says
  "nhắc nhở đồng bộ" / "synced reminder" and never "báo thức" / "Synced Alarm";
  no Do-Not-Disturb-override claim; no native or OS-level alarm integration; no
  backend change (A1).
- Migration / rollout notes: none. Additive feature slice plus four edited files.
- Notes: `service_locator.dart` is edited in both P1 and P3; the phases are
  sequential so the edits cannot conflict, and each phase registers only the
  types it creates. The Notifications settings screen is deliberately not built
  in this story (it does not exist in `mobile/lib` yet) — AC3 is satisfied by the
  P4 static guard plus the canonical `ReminderStrings` entries that the future
  notifications story must reuse.
