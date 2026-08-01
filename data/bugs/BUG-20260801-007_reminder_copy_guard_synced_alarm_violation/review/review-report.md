# Bugfix Review — BUG-20260801-007

Scope: BUG-20260801-007_reminder_copy_guard_synced_alarm_violation
Reviewer: Iris-QC
Mode: bugfix-review
Diff baseline: working tree vs `c71875f`
Location: control checkout `/Users/alantravala/workspace/snapsofts/cupid-apps`, branch `main` (uncommitted working tree)

## Outcome

Outcome: CLEAN

## 1. Change set scope

`git status` / `git diff --stat c71875f` confirm exactly:

- `mobile/lib/l10n/arb/app_en.arb` (+2/-2)
- `mobile/lib/l10n/arb/app_vi.arb` (+3/-3)
- `mobile/test/features/account/presentation/screens/notification_settings_screen_test.dart` (+1/-1)
- `data/bugs/BUG-20260801-007_.../bug_master.md` (state -> `FIXED_AWAITING_REVIEW`, `BUG_FIX_COMPLETE: YES`)
- untracked `diagnosis.md`, `fix-evidence.md`, `scrum-master-checkpoint.md` for this bug

No unrelated production or test files touched. No scope creep.

`mobile/test/features/reminders/reminder_copy_guard_test.dart` is UNMODIFIED
(`git status` reports it clean). The `_forbiddenTokens` list still contains
`'báo thức'`, `'synced alarm'`, `'do not disturb'`, and `_forbiddenDependencies`
is intact. The guard was fixed against, not loosened — this is the central
correctness question for this bug and it is satisfied.

Generated l10n output is absent from the diff because
`mobile/.gitignore:41` ignores `/lib/l10n/generated/`; verified via
`git check-ignore -v`. Expected, not an omission.

## 2. Canonical copy fidelity

`mobile/lib/features/reminders/presentation/reminder_strings.dart:122-126`
(the already-approved STORY-009 source) declares:

- `reminderNotificationsRowTitle` -> vi `Nhắc nhở đồng bộ` / en `Synced Reminder`
- `reminderNotificationsRowSubtitle` -> vi `Nhắc trên cả hai máy` / en `Prompts on both phones`

New ARB values match verbatim in both locales:

- `app_en.arb:127-128`: `"Synced Reminder"`, `"Prompts on both phones"`
- `app_vi.arb:565,569`: `"Nhắc nhở đồng bộ"`, `"Nhắc trên cả hai máy"`

Independently corroborated against the governing UX spec
`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-009_nhac_nho_dong_bo/ux/uiux-spec.md:126-142`,
which mandates precisely these substitutions and states the display name
supersedes "Synced Alarm" everywhere. The fix adopts approved copy rather
than inventing new wording — the correct remedy for this class of defect.

The `app_vi.arb` description was also corrected: the previous
`"locale-invariant per design source"` justification was itself the wrong
premise that produced the bug, and it is now replaced with an accurate
ADR-002 supersession note.

## 3. Codegen regeneration

Regeneration confirmed on disk (`l10n.yaml` -> `output-dir: lib/l10n/generated`):

- `lib/l10n/generated/app_l10n_en.dart:431,434` -> `'Synced Reminder'`, `'Prompts on both phones'`
- `lib/l10n/generated/app_l10n_vi.dart:429,432` -> `'Nhắc nhở đồng bộ'`, `'Nhắc trên cả hai máy'`

No string literal anywhere under `mobile/lib` still carries `Synced Alarm`,
`Rings on both phones`, `Reo trên cả hai máy`, or `báo thức`.

## 4. Test assertion fidelity

`notification_settings_screen_test.dart:36` now asserts
`expect(find.text('Synced Reminder'), findsOneWidget)`. The harness
(lines 9-20) pins `locale: const Locale('en')` with the real
`AppL10n.localizationsDelegates`, so the assertion exercises the actual
English generated string through the real widget tree. It is an exact-text,
`findsOneWidget` assertion sitting alongside six unchanged sibling row
assertions — a faithful one-for-one update, not a weakened or tautological
one. No assertion was deleted or relaxed.

No other test, UI surface, or doc under `mobile/` references the old copy in
a now-inconsistent way. `notification_settings_screen.dart:110-111` consumes
the ARB keys, so it follows the corrected values automatically. Remaining
"Synced Alarm" occurrences are all legitimate and intentional:

- `reminder_copy_guard_test.dart` — the ban list and its test name
- `reminder_strings.dart:10` — `///` doc comment stating the rule
- `uiux-spec.md` — quotes the raw design source then records its supersession
- `mobile/openapi/` — frozen backend tag name, explicitly excluded by the guard

## 5. Gates re-run by reviewer

| Gate | Command | Result |
| --- | --- | --- |
| Target test | `flutter test test/features/account/presentation/screens/notification_settings_screen_test.dart` | PASS (5/5) |
| Copy guard | `flutter test test/features/reminders/reminder_copy_guard_test.dart` | PASS (2/2) |
| Full suite | `flutter test` | PASS 890/890, "All tests passed!" |
| Build Gate | `flutter build apk --debug` | PASS, `✓ Built build/app/outputs/flutter-apk/app-debug.apk` |
| Runtime Startup Gate | `mobile-app` readiness per `data/devops/system/runtime-command-registry.json:107-112` — widget-test signal `Key('home_screen_ready_signal')` | PASS (`test/widget_test.dart` "App boots to the home screen ready signal" green in the full run) |

Flutter SDK is not on PATH on this machine; resolved at
`$HOME/flutter/bin` per the registry's documented `sdk.resolutionOrder`.

The full suite is green, consistent with the claim that this was the last
known failure blocking the REQ-001 `development-local` readiness gate.

## 6. Non-blocking observation (no action required)

The new `app_vi.arb:567` description embeds the literal `"Synced Alarm"`, and
`flutter gen-l10n` propagates it into `lib/l10n/generated/app_l10n.dart:844`
as a `///` doc comment. It clears the guard only because the guard skips lines
whose trimmed form starts with `//` (`reminder_copy_guard_test.dart:53`). That
skip is deliberate and documented in the guard's own header comment, and the
same pattern already existed pre-fix at `app_l10n.dart:820` from the untouched
`app_vi.arb:551` description. So this introduces no new risk class and the
explanatory value of the description is worth keeping. Recorded for awareness
only; nothing to change.

## Verdict

All seven verification items independently reproduced. The fix targets the
true root cause (STORY-016 re-authored copy from a stale design source),
applies the minimum correct patch, adopts already-approved canonical values in
both locales, leaves the compliance guard untouched, and passes every gate
with a fully green suite.

Outcome: CLEAN
BUG_FIX_COMPLETE: YES
