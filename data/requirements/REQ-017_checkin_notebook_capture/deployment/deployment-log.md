# Requirement Deployment Log: REQ-017 Ghi vào sổ tay từ màn check-in 23h

## 1. Metadata

- Requirement ID: REQ-017_checkin_notebook_capture
- Requirement Master: `data/requirements/REQ-017_checkin_notebook_capture/req_master.md`
- System DevOps Memory: `data/devops/system/devops_system_memory.md` (§2 Environment Matrix, `development-local` row)
- Requirement Configuration Guide: NOT CREATED — no new setup/config/key-acquisition surface (see §3)
- Last Updated: 2026-09-28

## 2. Environment Status

| Environment | Trigger Rule | Last Attempt | Status | Location / Endpoint | Notes |
|-------------|--------------|--------------|--------|---------------------|-------|
| development-local | automatic after requirement DONE when configured | 2026-09-28 | DEPLOYED | Android emulator `emulator-5554` (`com.snapsofts.cupid`), backend-api `http://127.0.0.1:21020` | Mobile-only story; backend-api unchanged, already running on shared devstack tenant |
| staging | explicit user instruction only | | NOT_REQUESTED | | |
| production | explicit user instruction only | | NOT_REQUESTED | | |

## 3. Latest Attempt

- Target Environment: development-local
- Trigger: automatic post-requirement deployment (REQ-017 `DONE`, merged to `main` at merge_sha `5fd1f448e7b1d091b123b1358d1a4579e3c01eab`)
- Inputs Used:
  - `data/requirements/REQ-017_checkin_notebook_capture/req_master.md`
  - `data/requirements/REQ-017_checkin_notebook_capture/scrum-master-checkpoint.md`
  - `data/devops/system/devops_system_memory.md` §2 Environment Matrix (`development-local` row), §3 Development-Local Policy
  - `data/devops/system/runtime-command-registry.json` (`mobile-app` runtime entry: readiness command, `dependsOn: [backend-api]`)
- Scope: REQ-017 STORY-001 is mobile-only (`mobile/`); no backend/web surface changed. Touched risk surfaces verified against the current `main` HEAD (commit `ed692a49`) source-of-truth files, not against prior review artifacts:
  1. Schema/migration `schemaVersion` 10→11 — `mobile/lib/core/database/cupid_database.dart:86` (`schemaVersion => 11`) and the `else if (from < 11)` branch (lines 153–162) adding the three nullable `notebook_entries` origin columns via `addColumn` only (no destructive recreate), matching the device-authoritative-data constraint documented in the file's own migration comment.
  2. Local storage content pack — `mobile/assets/data/req017/checkin_capture.v1.json` present, valid JSON, `schema_id: req017.checkin_capture.v1`, 9 vi-locale items (question, optional label, kind chips, hint, error/retry, notebook origin strings).
  3. Mobile navigation mount — `CheckinCaptureBlock` imported and instantiated in `mobile/lib/features/phase_status/presentation/evening_check_in_sheet.dart` (2 references: import + widget usage), i.e. the check-in 23h sheet.
- Commands / Steps Run:
  1. `devstack use --check` → `"adopted": true`, `"envDrift": []`.
  2. `devstack port check` → `ok no port conflicts`.
  3. Confirmed `emulator-5554` already booted (`adb devices`) and `backend-api` already reachable (`GET http://127.0.0.1:21020/api-docs-json` → `200`), so backend-api needed no redeploy — REQ-017 did not touch it.
  4. `flutter pub get` (mobile/) — succeeded.
  5. `flutter test test/core/database/context_notebook_migration_test.dart test/features/context_notebook/checkin_capture_content_repository_test.dart test/features/context_notebook/checkin_capture_content_test.dart test/features/phase_status/checkin_capture_block_test.dart test/features/phase_status/evening_check_in_sheet_test.dart` — scoped to the three risk surfaces above (not the full suite, which has a known pre-existing non-REQ-017 baseline red — see `[[project_full_suite_test_baseline_red]]` memory) — result: `+70 ~2` (70 passed, 2 intentionally skipped), 0 failed.
  6. `flutter build apk --debug --split-per-abi` — built `app-armeabi-v7a-local-debug.apk`, `app-arm64-v8a-local-debug.apk`, `app-x86_64-local-debug.apk`.
  7. `adb -s emulator-5554 install -r app-arm64-v8a-local-debug.apk` (matches emulator's `ro.product.cpu.abi=arm64-v8a`; `-k` uninstall first to keep the emulator's seeded session data) — `Success`.
  8. Runtime registry `mobile-app` readiness command: `adb shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` + polling `dumpsys activity activities` for `ResumedActivity` — matched within the 90s bound, printed `READY`.
  9. Re-checked `dumpsys activity activities` — `com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` still `ResumedActivity` (no crash-to-background).
  10. `adb logcat -d -t 300 "*:E"` filtered for `com.snapsofts.cupid`/`FATAL`/`AndroidRuntime` — no matches (no crash/exception signal).
  11. Registry shutdown command: `adb shell am force-stop com.snapsofts.cupid` — clean.
- Result: PASS. All three touched risk surfaces confirmed present and correct on `main` HEAD; scoped test suite green; live install + launch on a real device produced no crash and no error-level log signal; clean shutdown.
- Fixes Applied: none required — no in-scope deployment or runtime integration issue found.
- Configuration Guide Updated: NO — REQ-017 introduces no new environment variable, secret, third-party integration, webhook, or manual operator setup step. `req_master.md` `## Configuration Documentation` `Status: NOT_REQUIRED` confirmed still accurate.
- Remaining Blockers / User Actions: none.

## 4. History

| Date | Environment | Trigger | Result | Notes |
|------|-------------|---------|--------|-------|
| 2026-09-28 | development-local | automatic (requirement DONE) | PASS | First deployment for this requirement; scoped mobile-app verification (schema migration, content pack, nav mount) + live device install/launch smoke, backend-api unchanged and already running |
