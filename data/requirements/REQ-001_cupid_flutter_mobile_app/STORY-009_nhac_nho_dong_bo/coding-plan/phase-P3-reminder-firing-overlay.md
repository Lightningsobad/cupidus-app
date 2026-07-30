# Phase P3 – Firing Overlay, Client Timeout, Accessibility

## 1. Objective

Render the foreground in-app firing overlay above any active screen, enforce the
client-side 5-minute timeout, and meet the overlay accessibility contract.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-reminder-firing-overlay.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/reminders/presentation/reminder_firing_cubit.dart`
  - `mobile/lib/features/reminders/presentation/widgets/reminder_firing_overlay.dart`
  - `mobile/lib/features/reminders/presentation/reminder_overlay_host.dart`
  - `mobile/lib/core/di/service_locator.dart`
  - `mobile/test/features/reminders/reminder_firing_cubit_test.dart`
  - `mobile/test/features/reminders/reminder_firing_overlay_test.dart`
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
  - `ReminderFiringCubit`, `ReminderFiringOverlay`, `ReminderOverlayHost`
- Shared Interfaces Consumed:
  - P0 `ReminderRepository`, `SyncedReminder`
  - P1 `ReminderLocalPrefs` (`reminder.pending_timeout_notice`)
  - P2 `ReminderStrings`, `CupidIcons` glyphs
- Risk Surfaces:
  - Client-side 5-minute timeout
  - Overlay mount + a11y
  - Realtime reminder events
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` §4 D4 and D5;
    `../ux/uiux-spec.md` §3, §6, §7
  - consumer contract: `ReminderOverlayHost` mounted once by P4
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §4 D4, D5
  - OQ constraints: ADR-002 — no native alarm, no locally scheduled
    notification plugin, no Do-Not-Disturb claim
  - upstream phase outputs: P0–P2
  - UX constraints: `../ux/uiux-spec.md` §3 (overlay), §6 (safe areas), §7 (a11y)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one overlay surface plus its cubit and mount host
  - Source/Test File Count: 4 source (one is an edit) + 2 test
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` §4 D4, D5
- `../ux/uiux-spec.md` §3, §6, §7
- P0–P2 outputs
- `mobile/lib/core/di/service_locator.dart`

## 3. Tasks

- Implement `ReminderFiringCubit`: opens on a `triggerAlarm` event from
  `ReminderRepository.events()`, holds the firing `SyncedReminder` and the
  per-partner dismissed flags, dismisses on user action by calling
  `ReminderRepository.dismiss`, and closes fully on `alarmFullyStopped`.
- Implement the D4 timeout exactly: start a 5-minute timer when the overlay
  opens; on expiry clear the overlay locally and set
  `reminder.pending_timeout_notice`. **Do not** emit `stopAlarm` on expiry — that
  wire event means "this user swiped" and would falsely record the user as a
  stopper. Inject the timer/clock as a constructor seam so tests do not wait five
  real minutes.
- Apply D5: `alarmStoppedByPartner` is ephemeral, so the partner-dismissed flag
  may be missed while backgrounded. On overlay open and on return to foreground,
  refresh from `ReminderRepository.load()` `stopperIds` rather than trusting the
  live event alone.
- Build `ReminderFiringOverlay` per `../ux/uiux-spec.md` §3: full-screen scrim,
  the `notificationsActive` glyph in the shaking badge (keep the `shake`
  animation, never an alarm-clock glyph), body copy, per-partner state labels,
  the swipe dismiss affordance, and the waiting-on-partner state. All text comes
  from `ReminderStrings`.
- Accessibility (`../ux/uiux-spec.md` §7): announce the overlay as an
  alert-level interruption on open (`SemanticsService.announce`), move focus to
  the dismiss action, and provide a **non-gesture activatable dismiss button**
  equivalent to the swipe with an accessible label. Honour `--safe-top` /
  `--safe-bot` equivalent safe-area insets so the CTA never sits under a system
  inset.
- Show the timeout acknowledgment: when `reminder.pending_timeout_notice` is set,
  surface a brief non-blocking notice on next app open and clear the flag.
- Implement `ReminderOverlayHost` as a widget that wraps a child and renders the
  overlay above it when the cubit is firing. It must not depend on a specific
  screen and must be mountable once, above the shell.
- Register `ReminderFiringCubit` in `service_locator.dart`.
- Do not add any plugin, platform channel, or scheduled local notification. The
  overlay is foreground-only, matching AC4 and `../architecture/solution.md` §3
  ASSUMPTION-2.

## 4. Acceptance Criteria

- Timer expiry clears the overlay locally and produces **zero** outbound wire
  emits.
- A user dismiss produces exactly one `stopAlarm` emit.
- `alarmFullyStopped` closes the overlay for the viewer.
- The overlay is announced to screen readers on open and exposes a non-gesture
  dismiss button with an accessible label.
- No new entry in `mobile/pubspec.yaml`.
- No alarm-clock glyph and no Do-Not-Disturb claim anywhere in the output.
- `flutter analyze` is clean and the existing test suite stays green.

## 5. Planned Outputs

- Code: the four `mobile/lib/**` files listed in Write Scope
- Contracts: `ReminderFiringCubit`, `ReminderOverlayHost`
- Notes: none

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile-app`), unit + widget tests
- Required levels:
  - unit: open on `triggerAlarm`; dismiss emits exactly one `stopAlarm`; timeout
    expiry emits nothing and sets the pending-notice flag; `alarmFullyStopped`
    closes; foreground refresh re-derives partner dismissal from `stopperIds`
  - integration: widget test pumping `ReminderOverlayHost` over a stub child,
    asserting the overlay appears above it, the semantics announcement fires,
    the non-gesture dismiss button exists and triggers the same action as the
    swipe, and safe-area padding is applied
  - mobile build/type-check/static-analysis: `flutter analyze` clean
  - accessibility: semantics announcement and dismiss-button label asserted in
    the widget test
- Required checks: `mobile/pubspec.yaml` unchanged by this phase
- Mobile discoverability / navigation integration: the host is built here and
  mounted in P4
- Minimum gates by risk surface:
  - Client-side 5-minute timeout: cubit test with the injected timer seam
    (BLOCKED if it cannot run)
  - Overlay mount + a11y: widget test above (BLOCKED if it cannot run)
- Required regression or contract coverage: existing `mobile/test/**` stays green
- Evidence format: concise rows appended by P5 to `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: `flutter test test/features/reminders/`
  - Static analysis: `flutter analyze`
  - Required assertion evidence: zero-emit assertion on timeout expiry

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
