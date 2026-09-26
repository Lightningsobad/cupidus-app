# REQ-016 Integration Build & Runtime Evidence

Scope: closes review-report.md F-I2 action item 5 (`## Integration Build &
Runtime`) and confirms D-I2 (`BUG-20260923-001` residual risk).

Branch: `codex/REQ-016_solo_stage1_relationship_assistant-integration`
HEAD verified: `753d2a863b630ec3629cb1cba898bac1f0e075f8`
Date: 2026-09-26
Runtime id: `mobile-app` (`data/devops/system/runtime-command-registry.json`)

## Integration Build & Runtime

- Build: PASS — `flutter pub get && flutter build apk --debug --split-per-abi`
  run from `mobile/` on this Worktree's HEAD. Completed in 85.2s
  (`Running Gradle task 'assembleLocalDebug'... 85.2s`). Produced:
  - `build/app/outputs/flutter-apk/app-armeabi-v7a-local-debug.apk`
  - `build/app/outputs/flutter-apk/app-arm64-v8a-local-debug.apk`
  - `build/app/outputs/flutter-apk/app-x86_64-local-debug.apk`
  `--split-per-abi` was added to the registry's plain `flutter build apk
  --debug` to keep the installed artifact small enough for the emulator per
  the repo's known oversized-monolithic-debug-APK install failure; this is
  the same build task (`assembleLocalDebug`), not a different build. Build
  emitted only pre-existing, non-fatal warnings (Gradle native-access
  restriction notice, KGP-application notice for `home_widget` /
  `mobile_scanner` / `sign_in_with_apple`) — no compile error, no task
  failure.
- Runtime/Smoke: PASS — real app-launch smoke on Android emulator
  `emulator-5554` (`sdk_gphone64_arm64`), using the registry's readiness
  probe:
  1. `adb -s emulator-5554 shell cmd package uninstall -k com.snapsofts.cupid`
     then `adb -s emulator-5554 install -r
     build/app/outputs/flutter-apk/app-arm64-v8a-local-debug.apk` —
     `Success` / `Success`.
  2. `adb -s emulator-5554 shell am start -W -n
     com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` —
     `Status: ok`, `LaunchState: WARM`, `TotalTime: 2408`, `Complete`,
     exit 0.
  3. Poll loop on `adb -s emulator-5554 shell dumpsys activity activities`
     for `ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
     — matched on the first poll (foreground, resumed, not just started).
  4. `adb -s emulator-5554 logcat -d -t 500 "*:E"` after launch — 38
     error-level lines total, all `AppHibernationService: Package
     com.snapsofts.cupid is not installed ...` (stale pre-install-time
     noise from the uninstall step, timestamped before the launch); zero
     `AndroidRuntime`/`FATAL EXCEPTION` lines for `com.snapsofts.cupid`. No
     crash.
  5. Clean shutdown: `adb -s emulator-5554 shell am force-stop
     com.snapsofts.cupid` per the registry's `shutdownCommand`, exit 0.

`Runtime: NOT_APPLICABLE` was not used; a device was available
(`emulator-5554`, already booted) and the smoke ran against a real launched
process, not a widget test.

## D-I2 confirmation — BUG-20260923-001 (`test/core/database/`, 11 tracked reds)

`BUG-20260923-001` (`data/bugs/BUG-20260923-001_drift_schema_version_migration_test_lag/bug_master.md`)
tracked 11 failures in 3 files (`chapter_closure_migration_test.dart`,
`calendar_event_state_migration_test.dart`,
`relationship_labels_migration_test.dart`) asserting a stale landed
`schemaVersion` (`7`/`8`) against the then-live `9`, reproduced at
STORY-005/P7's BaseHead `9ab00f48`.

Re-run at this integration HEAD (`753d2a86`, live `schemaVersion = 10` per
`cupid_database.dart:86`):

```
cd mobile && flutter test test/core/database/
```

Result: **`All tests passed!` — 104/104, 0 failures.** The 11 previously
tracked reds do not reproduce here — this is a full pass, not merely
"version-number lag confirmed and still red." Between `BUG-20260923-001`'s
report date (2026-09-23, `schemaVersion 9`) and this HEAD (`schemaVersion
10`, STORY-013's v7→v9 renumber), the three affected test files' frozen
version assertions were brought current as part of the later merges — no
migration break, and the ladder's own test evidence is now green at
integration level, closing D-I2's "no green migration-test evidence" gap.
`BUG-20260923-001` itself remains on record as historical/non-blocking per
its own Resolution section; this file is the closure evidence its
Resolution section anticipated ("queue when repo-wide test health work is
prioritized" — superseded here because the fix already landed as a side
effect of the sibling schema-version merges, not a dedicated bug-fixer pass).
