# Diagnosis: BUG-20260814-004 Triage-Pending — Guard-Red / Registry Mismatch / Splash Compile Error

Bug id: BUG-20260814-004_triage_pending_guard_registry_splash_family
Owner: bug-fixer (Justin-BugFixer)
Work location: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`

## Triage Verdict

The three reported anchors do **not** share a root cause. They are three
unrelated findings, and only one of them is a live defect:

| Anchor | Reproduces? | Verdict |
| --- | --- | --- |
| (a) `"Synced Alarm"` in `permissions_screen.dart:80-81` | YES | Real defect, fixed here. |
| (b) `_notImplementedCanvasIds` still lists `permissions` | NO | Registry is already correct; report is stale. |
| (c) `splash_design_fidelity_test.dart` compile error, `SplashScreen` missing `resolvePairingStatus` | NO | Anchor is misattributed; no such test file exists and the parameter belongs to `HomeScreen`, where it is present and exercised by passing tests. |

Because (b) and (c) do not reproduce as defects, there is nothing to split
into a separate bug and nothing further to fix. Evidence for each is below.

## Pre-Fix Reproduction Gate

Modality: test execution (the reported anchors are failing / non-compiling
tests, so running them is the reported failures' native modality).

### Anchor (a) — REPRODUCED

Command:
```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit/mobile
/Users/alantravala/flutter/bin/flutter test test/features/reminders/reminder_copy_guard_test.dart
```

Expected result (bug present): copy guard fails on the banned token in
`permissions_screen.dart:80-81`.

Actual result: FAILED, exit code 1:
```
00:00 +0 -1: mobile/lib string literals never say "báo thức"/"Synced Alarm"/"Do Not Disturb" (AC2/AC3, ADR-002) [E]
  Expected: empty
    Actual: [
              'lib/features/onboarding/presentation/screens/permissions_screen.dart:80: forbidden token "synced alarm"',
              'lib/features/onboarding/presentation/screens/permissions_screen.dart:81: forbidden token "synced alarm"'
            ]
00:00 +1 -1: Some tests failed.
```

Result: REPRODUCED — both reported lines match exactly.

Scope correction to the bug report: the report pairs
`no_fork_guard_test.dart` with `reminder_copy_guard_test.dart` for anchor (a).
`no_fork_guard_test.dart` is the ADR-004 raw-color guard and has no `"Synced
Alarm"` rule; it was RED for an unrelated reason and is now GREEN
(BUG-20260815-001). Anchor (a) is carried solely by
`reminder_copy_guard_test.dart`.

### Anchor (c) — NOT REPRODUCED

The named test file does not exist on this branch:
```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit
find mobile -type f -name "*splash*"
-> mobile/test/features/auth/presentation/splash_screen_test.dart
   mobile/lib/design_system/tokens/splash_palette.dart
   mobile/lib/features/auth/presentation/screens/splash_screen.dart
```
There is no `splash_design_fidelity_test.dart` anywhere under `mobile/`.

The splash test that does exist compiles and passes:
```
/Users/alantravala/flutter/bin/flutter test test/features/auth/presentation/splash_screen_test.dart
-> +9: All tests passed!
```

The `resolvePairingStatus` named parameter is a `HomeScreen` API, not a
`SplashScreen` API:
```
git grep -n "resolvePairingStatus" -- mobile
-> mobile/lib/features/home/presentation/home_screen.dart:106,111,117,194,195,712,716,726
   plus 9 passing test files that pass it to HomeScreen
```
It exists, is wired, and is exercised by currently-passing tests
(`home_screen_test.dart`, `timeline_entry_point_test.dart`,
`anti_ghost_entry_card_test.dart`, `pet_entry_point_test.dart`,
`vibe_screen_test.dart`, `expenses_entry_point_test.dart`,
`vibe_screen_test.dart`).

Result: NOT REPRODUCED. The anchor appears to have been transcribed against
the wrong widget and a test filename that was never merged. No defect to fix.

### Anchor (b) — NOT REPRODUCED

See `## Anchor (b) Evidence` below.

## Anchor (a) Root Cause

`reminder_copy_guard_test.dart` enforces ADR-002 by scanning the string-literal
contents of every non-comment line under `mobile/lib` for the forbidden tokens
`báo thức`, `synced alarm`, and `do not disturb` (case-insensitive).

`permissions_screen.dart` builds the notifications permission card's body copy
with a hardcoded `context.viEn(...)` pair naming the feature `Synced Alarm` in
both locales:

```dart
body: context.viEn(
  'Synced Alarm và Emoji Storm cần cái này. Tối đa 15 cái/ngày.',
  'Synced Alarm and Emoji Storm need this. Max 15 a day.',
),
```

The canonical product wording for that feature already exists on this branch at
`mobile/lib/features/reminders/presentation/reminder_strings.dart:19,145`:
`viEn('Nhắc nhở đồng bộ', 'Synced Reminder')`. The onboarding screen was
authored against the pre-ADR-002 feature name and never reconciled with it, so
the string is a plain copy defect, not a guard defect and not a token/theming
issue. The guard rule and the canonical strings are both correct as-is.

Relationship to `BUG-20260801-007` (DONE): that bug fixed the same banned token
in **REQ-001 STORY-016 ARB copy**. This occurrence is a different, later-merged
call site — a literal inline in REQ-002 onboarding Dart source, not in an ARB
file — so the earlier fix does not and cannot cover it.

Fix applied (`permissions_screen.dart:80-81`), copy-only, no API/behavior
change:

```dart
body: context.viEn(
  'Nhắc nhở đồng bộ và Emoji Storm cần cái này. Tối đa 15 cái/ngày.',
  'Synced Reminder and Emoji Storm need this. Max 15 a day.',
),
```

## Anchor (b) Evidence

Reported symptom: `main_preview.dart`'s `_notImplementedCanvasIds` may still
list `permissions`, so the preview harness would render a "not implemented"
placeholder for a screen that is in fact implemented.

Observed on this branch — `permissions` is **not** in the not-implemented set:

`mobile/lib/main_preview.dart:244`
```dart
const Set<String> _notImplementedCanvasIds = <String>{
  'shareapprove', 'shareedit', 'shareok', 'sharepick',
  'themedetail', 'themes', 'zodiac',
};
```

and `permissions` has a real registered entry at `mobile/lib/main_preview.dart:192`
(`PreviewScreenEntry` wired to the live `PermissionsScreen`), so the preview
registry and the code agree.

Result: NOT REPRODUCED. The registry-vs-code mismatch was presumably real when
the bug was filed and has since been closed by the story that landed the
screen. No change needed, nothing to split out.

## Changed Files

| File | Change |
| --- | --- |
| `mobile/lib/features/onboarding/presentation/screens/permissions_screen.dart` | Lines 80-81: `Synced Alarm` → canonical `Nhắc nhở đồng bộ` (vi) / `Synced Reminder` (en). Copy-only. |

One file, two lines. No new files, no token/theme changes, no API changes.

## Not In Scope

- Anchors (b) and (c): proven non-reproducing above; no patch, and no
  `TRIAGE_SPLIT_REQUIRED` blocker is warranted because there is no live defect
  behind either to carry into a new bug.
- The `no_fork_guard_test.dart` mis-pairing in the bug report for anchor (a) —
  recorded as a scope correction above; that guard's actual RED was
  `BUG-20260815-001`, already DONE.
- Other REPORTED bugs on this branch (`BUG-20260814-001/002/003`,
  `BUG-20260815-002`) are untouched.
