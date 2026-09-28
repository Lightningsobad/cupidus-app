# REQ-017 Integration Build & Runtime Evidence

Scope: F-I1 (rule 12g3) from the REQ-017 requirement integration review —
requirement-level integration build + runtime smoke, explicitly required as an
install-over-existing-data migration smoke (not a fresh install), because this
requirement's core change is a Drift `schemaVersion` bump (10 → 11).

Branch: `codex/REQ-017_checkin_notebook_capture-integration`
HEAD verified: `c41c1556583e90c6e9627bd0af002124a8951a22`
Date: 2026-09-28
Runtime id: `mobile-app` (`data/devops/system/runtime-command-registry.json`)

## Integration Build & Runtime

- Build: PASS — flutter build apk --debug --split-per-abi, run twice (v10
  baseline and v11 Worktree HEAD), full detail in the two dated bullets below.
- Build (pre-migration baseline, schemaVersion 10): PASS —
  `flutter pub get && flutter build apk --debug --split-per-abi` run from
  `mobile/` in a separate scratch worktree
  (`git worktree add --detach .../scratch-req017-premigration
  0198e32ddd3f8bad6a4d5274fd7b5ebeae9158b1`), the last commit on this
  integration branch still at `schemaVersion = 10`, immediately before
  STORY-001's merge. Produced:
  - `build/app/outputs/flutter-apk/app-armeabi-v7a-local-debug.apk`
  - `build/app/outputs/flutter-apk/app-arm64-v8a-local-debug.apk`
  - `build/app/outputs/flutter-apk/app-x86_64-local-debug.apk`
  Only pre-existing, non-fatal Gradle/KGP notices (native-access restriction,
  KGP-application notice for `home_widget` / `mobile_scanner` /
  `sign_in_with_apple`) — no compile error, no task failure. This build was
  never installed over the assigned Worktree's own build output; the scratch
  worktree's working tree is fully separate from the assigned Worktree.
- Build (this Worktree's actual HEAD, schemaVersion 11): PASS —
  `flutter pub get && flutter build apk --debug --split-per-abi` run from
  `mobile/` on `c41c1556`. Produced the same three
  `build/app/outputs/flutter-apk/app-*-local-debug.apk` artifacts in the
  assigned Worktree. Same pre-existing non-fatal warnings only, no compile
  error, no task failure.
- Runtime/Smoke: PASS — real app-launch smoke on Android emulator
  `emulator-5554`, install-over-existing-data (no uninstall, no
  `--uninstall-only`) so the pre-migration data created below survived into
  the post-migration launch. See `### Migration Verification` for the full
  seeded-data walkthrough; runtime steps on the v11 build:
  1. `adb -s emulator-5554 install -r
     build/app/outputs/flutter-apk/app-arm64-v8a-local-debug.apk` (assigned
     Worktree's HEAD build) — `Success`, no prior uninstall, existing app data
     preserved.
  2. `adb -s emulator-5554 shell am start -W -n
     com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` —
     `Status: timeout`, `LaunchState: UNKNOWN (-1)`, `WaitTime: 25497`. This
     reflects `am start -W`'s full-window-draw completion wait timing out
     during the migration's cold-start work, not a launch failure: the
     readiness probe (poll `dumpsys activity activities` for
     `ResumedActivity`) below confirms the activity was actually resumed well
     inside that window.
  3. Poll loop on `adb -s emulator-5554 shell dumpsys activity activities`
     for `ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
     — matched on the first poll (~2s after install), i.e. the activity was
     foreground/resumed well before `am start -W`'s own wait gave up.
     Screenshots confirm the same: `/tmp/req017_postmigration_screen.png`
     (loading spinner immediately after launch) then
     `/tmp/req017_postmigration_screen2.png` (5s later, fully rendered
     authenticated home screen, no crash/black screen).
  4. `adb -s emulator-5554 logcat -d -t 500 "*:E"` after launch — 37
     error-level lines total (`/tmp/req017_crash_scan.txt`), all accounted
     for as benign/pre-existing noise, none referencing
     `com.snapsofts.cupid`'s own runtime failure or the Drift migration:
     - 1 line: `ashmem: Pinning is deprecated since Android Q...` — generic
       platform/ashmem deprecation notice, unrelated to this app.
     - 31 lines: `GeneratedPluginRegistrant: Error registering plugin
       flutter_facebook_auth ... The SDK has not been initialized ...` plus
       its stack trace — a known, pre-existing non-fatal plugin-registration
       warning (no Facebook App ID configured in local/debug builds); it does
       not stop plugin registration for any other plugin and does not affect
       app launch, navigation, or the Drift database layer.
     - 4 lines: `HwcComposer`/`HWComposer: getLuts failed ... UNSUPPORTED
       (8)` — emulator GPU/display-compositor capability-query noise, a host
       emulator limitation unrelated to `com.snapsofts.cupid` or to Drift.
     - Zero `AndroidRuntime`/`FATAL EXCEPTION` lines, zero lines mentioning
       `drift`, `migration`, `onUpgrade`, `schema`, `cupid_database`,
       `VmMigrationException`, or `MigrationError`. No crash.
  5. Clean shutdown: `adb -s emulator-5554 shell am force-stop
     com.snapsofts.cupid` per the registry's `shutdownCommand`, exit 0.

`Runtime: NOT_APPLICABLE` was not used; a device was available
(`emulator-5554`, already booted) and the smoke ran against a real launched
process with an install-over-existing-data migration path, not a widget test
and not a fresh install.

### Migration Verification (schemaVersion 10→11, install-over-existing-data)

A fresh install was deliberately avoided for this smoke because it would hide
exactly the migration risk this requirement introduces (STORY-001's Drift
`schemaVersion` bump 10 → 11). The verification instead installed the v11
build directly over a real, app-generated v10 database:

1. **Seeding real v10 data.** In the scratch worktree (`0198e32d`,
   `schemaVersion = 10`), the pre-migration APK was installed fresh on
   `emulator-5554`. The app's Drift database (`CupidDatabase`) is
   `registerLazySingleton` in `mobile/lib/core/di/service_locator.dart`, so it
   is only created on first DAO access, which requires an authenticated
   session. Rather than hand-edit any sqlite file, an authenticated session
   was seeded through the app's own real backend/auth path:
   - Registered a throwaway test account via the local backend's
     `POST /auth/register`.
     
     read the 6-digit code from the local `devstack` mailpit REST API, then
     completed `POST /auth/verify-otp` to obtain a real `accessToken`.
   - Wrote that token/email/userId into the app's own
     `shared_prefs/FlutterSharedPreferences.xml` under the exact keys
     `JwtTokenProvider` reads (`flutter.cupid_jwt_access_token`,
     `flutter.cupid_user_email`, `flutter.cupid_user_id`, confirmed from
     `mobile/lib/core/auth/jwt_token_provider.dart`), via `adb push` +
     `run-as cp`, so the app launched already authenticated — this seeds the
     *session*, not the database.
   - With a real authenticated session, used real UI interaction (typing +
     tapping Save, coordinates read from `uiautomator dump` bounds, not
     estimated) to create one "Sổ tay người yêu" entry and one journal entry,
     which the app itself persisted through its normal Drift DAOs.
   - Confirmed the resulting database exists and is real, app-written data:
     extracted it with `adb exec-out run-as com.snapsofts.cupid cat
     app_flutter/cupid.sqlite > /tmp/cupid_premigration_check.sqlite` (the
     file lives at `app_flutter/cupid.sqlite`, i.e. Flutter's documents
     directory, not the conventional Android `databases/` subdirectory) and
     inspected it locally with `sqlite3`: `PRAGMA user_version` = `10`,
     `journal_entries` = 1 row, `notebook_entries` = 1 row, alongside the
     rest of the app's normal table set. Cleaned up the local copy afterward.
   - App was force-stopped cleanly (`am force-stop`) before moving to the
     install-over step.
2. **Install-over command.** From the assigned Worktree
   (`c41c1556`, `schemaVersion = 11`):
   `adb -s emulator-5554 install -r
   build/app/outputs/flutter-apk/app-arm64-v8a-local-debug.apk` — no prior
   `adb uninstall`, no `flutter install --uninstall-only`; this is a
   same-package reinstall (`pm install -r`) that preserves existing app data,
   the same mechanism Android's own in-place-update path uses.
3. **Post-migration evidence — logs.** A targeted grep of
   `adb logcat -d` for `drift|migration|onUpgrade|schema|cupid_database|
   VmMigrationException|MigrationError` right after launch
   (`/tmp/req017_migration_logcat.txt`) returned exactly one line, an
   unrelated Google Play Services log
   (`AppInstallOperation: FDL Migration::InstallIntentOperation by FDL
   Module`) that is a Play Services "FDL module" install-operation log, not a
   reference to this app's own database migration. No Drift exception, no
   `onUpgrade` failure, no schema-mismatch error anywhere in the log window.
   The full `*:E` crash scan (above, 37 lines) independently confirms zero
   lines implicating `com.snapsofts.cupid` or Drift.
4. **Post-migration evidence — data.** After the install-over launch and a
   clean force-stop, the live database was re-extracted the same way
   (`adb exec-out run-as com.snapsofts.cupid cat app_flutter/cupid.sqlite >
   /tmp/cupid_postmigration_check.sqlite`) and inspected: `PRAGMA
   user_version` now reads **`11`** (migration actually ran, not merely
   "no error logged"), and the pre-existing rows survived the migration
   intact — `journal_entries` = 1 row, `notebook_entries` = 1 row, matching
   the pre-migration counts exactly. Local copy deleted after inspection.

Together, (3) and (4) confirm the v10 → v11 Drift migration ran during the
install-over launch with no error and with full data survival — this is the
specific risk F-I1 was raised to cover.
