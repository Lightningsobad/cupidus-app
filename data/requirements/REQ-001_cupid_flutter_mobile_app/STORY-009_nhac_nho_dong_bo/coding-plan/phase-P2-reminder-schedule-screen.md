# Phase P2 – Canonical Copy And Schedule Screen

## 1. Objective

Land the single canonical vi/en copy file for this feature and build the Synced
Reminder schedule screen on top of P1's bloc.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-reminder-schedule-screen.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/reminders/presentation/reminder_strings.dart`
  - `mobile/lib/features/reminders/presentation/screens/reminder_schedule_screen.dart`
  - `mobile/lib/features/reminders/presentation/widgets/reminder_time_stepper.dart`
  - `mobile/lib/features/reminders/presentation/widgets/reminder_weekday_chips.dart`
  - `mobile/lib/design_system/icons/cupid_icons.dart`
  - `mobile/test/features/reminders/reminder_schedule_screen_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `ReminderStrings` — the only source of this feature's user-facing text
  - `ReminderScheduleScreen`
- Shared Interfaces Consumed:
  - P1 `ReminderScheduleBloc` / `ReminderScheduleState`
  - `mobile/lib/features/auth/presentation/auth_strings.dart`
    (`AuthLocaleText.viEn` extension pattern)
  - `mobile/lib/design_system/design_system.dart` tokens and adaptive widgets
- Risk Surfaces:
  - Copy compliance AC2/AC3
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §2 (exact strings), §6
    (responsive), §7 (accessibility), §8 (design system reuse)
  - consumer contract: `ReminderStrings` reused by P3 and by the future
    notifications story
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §4 Mobile Lane Handoff
  - OQ constraints: ADR-002/D1 wording; ASSUMPTION-1 (no auto-repeat claim)
  - upstream phase outputs: P1 bloc and state
  - UX constraints: `../ux/uiux-spec.md` §2, §6, §7, §8
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one screen plus its two owned widgets and the copy file
  - Source/Test File Count: 5 source (one is an additive edit) + 1 test
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` §2, §6, §7, §8
- `../architecture/solution.md` §4 Mobile Lane Handoff
- P1 outputs (`reminder_schedule_bloc.dart`, `reminder_schedule_state.dart`)
- `mobile/lib/features/auth/presentation/auth_strings.dart`
- `mobile/lib/design_system/icons/cupid_icons.dart` and `cupid_icon.dart`

## 3. Tasks

- Create `ReminderStrings` following the STORY-003 pattern: a
  `BuildContext` extension using `context.viEn(vi, en)` so vi/en resolve from the
  ambient `Locale`. Do not migrate to the `AppL10n` ARB pipeline. Transcribe the
  strings verbatim from `../ux/uiux-spec.md` §2 and also include the §4
  notifications row strings ("Nhắc nhở đồng bộ" / "Synced Reminder", "Nhắc trên
  cả hai máy" / "Prompts on both phones") plus the §4 banner text with the
  Do-Not-Disturb clause **deleted**, so the future notifications story reuses
  these instead of the raw design copy.
- Every string must use "nhắc nhở đồng bộ" / "synced reminder". No string may
  contain "báo thức", "Synced Alarm", "reo"/"ring" bell language, or any
  Do-Not-Disturb claim. Include the §2 rule-card copy with its 5-minute timeout
  caveat, which is the user-facing statement backing the P3 timeout behaviour.
- Build `ReminderScheduleScreen`: hero card (eyebrow label, large time display,
  +/- steppers), weekday chip row, the two-up partner confirmation row, the
  three mutually exclusive primary-action states driven by
  `ReminderStage` (`needsMyConfirmation`, `awaitingPartner`, `bothConfirmed`),
  and the rule card. Keep the partner confirmation row inside the screen file.
- Render the partner confirmation state as text **plus** colour, never colour
  alone (`../ux/uiux-spec.md` §7).
- Extract `ReminderTimeStepper` and `ReminderWeekdayChips` as the two owned
  widgets. The chip row edits local state only (ASSUMPTION-1); it must not imply
  a recurring schedule in any label.
- Responsive rule (`../ux/uiux-spec.md` §6): single column; on wider widths cap
  card content at the existing mobile max width and centre it rather than
  stretching the large time display.
- Add the glyph constants this story needs to `CupidIcons` additively
  (`notificationsActive`, `remove`, `hourglass`, `swipeRight`, `check`). Resolve
  each codepoint against the bundled
  `mobile/assets/fonts/MaterialSymbolsRounded-Variable.ttf` codepoint list —
  do not guess a codepoint. Never add an alarm-clock glyph.
- Show `RealtimeNotLiveFailure` / API failure as an inline retry affordance wired
  to the P1 retry event.

## 4. Acceptance Criteria

- `ReminderStrings` is the only file in this phase containing literal
  user-facing text; the screen and widgets read every string from it.
- No string in the phase output contains "báo thức", "Synced Alarm", or a
  Do-Not-Disturb claim (verified statically in P4).
- The primary action renders exactly one of the three states for a given
  `ReminderStage`.
- Partner confirmation state is conveyed by text plus colour.
- No alarm-clock glyph is referenced anywhere.
- `flutter analyze` is clean and the existing test suite stays green.

## 5. Planned Outputs

- Code: the five `mobile/lib/**` files listed in Write Scope
- Contracts: `ReminderStrings`, `ReminderScheduleScreen`
- Notes: none

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile-app`), widget tests
- Required levels:
  - unit: `ReminderStrings` resolves vi under `Locale('vi')` and en otherwise
  - integration: widget test pumping `ReminderScheduleScreen` with a seeded bloc
    state for each of the three stages, asserting the expected CTA and the
    absence of the other two
  - mobile build/type-check/static-analysis: `flutter analyze` clean
  - visual inspection: confirm the added glyphs render (no blank glyph box) in
    the widget test golden-free assertion or a manual pump check
- Required checks: partner state text present alongside colour; rule-card copy
  includes the 5-minute caveat
- Mobile discoverability / navigation integration: deferred to P4 (this phase
  builds the screen; P4 makes it reachable)
- Minimum gates by risk surface:
  - Copy compliance AC2/AC3: strings unit test here, static guard in P4
    (BLOCKED without both)
- Required regression or contract coverage: existing `mobile/test/**` stays green
- Evidence format: concise rows appended by P5 to `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: `flutter test test/features/reminders/`
  - Static analysis: `flutter analyze`

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
