# REQ-012 Integration Build & Runtime Evidence (IF-1 close-out)

Scope: DevOps integration-level build/runtime verification of the merged
whole on the integration branch worktree
(`codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-integration`,
BaseHead `b31de7d238aabda9d969219e6feb8e8c3096d8da`), closing integration
reviewer finding IF-1 (no integration build/runtime verification existed,
only per-story evidence).

## Integration Build & Runtime

Build: PASS
Runtime-Smoke: PASS

### Commands run and outcomes

1. `flutter pub get` (in `mobile/`)
   - Result: PASS. Dependency resolution confirms the documented
     `permission_handler` pin holds on the merged whole: `permission_handler`
     resolved to `12.0.3` (satisfies `^12.0.1` in `pubspec.yaml`) and
     `permission_handler_android` resolved to `13.0.1`, not the `14.0.0`
     version that sets `compileSdk = 37` and breaks the Android SDK platform
     hash resolution documented in
     `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/deployment/configuration-guide.md`.

2. `flutter build apk --debug` (in `mobile/`)
   - Result: PASS. `Running Gradle task 'assembleLocalDebug'... 49.0s` then
     `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk`. No errors;
     only expected non-blocking Gradle/KGP warnings (native access restricted
     method warning, and a KGP-application-by-plugin warning naming
     `mobile_scanner` and `sign_in_with_apple`, both informational upstream
     Flutter deprecation notices, not build failures).

3. Runtime/emulator smoke (reused already-running `emulator-5554`, no new
   device booted)
   - Installed the just-built APK: `adb -s emulator-5554 install -r
     build/app/outputs/flutter-apk/app-local-debug.apk` -> `Success`.
   - Launched per the runtime registry's `mobile-app` readiness probe
     (`data/devops/system/runtime-command-registry.json`): `adb -s
     emulator-5554 shell am start -W -n
     com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` ->
     `Status: ok`, `LaunchState: COLD`,
     `Activity: com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`.
   - Polled `adb -s emulator-5554 shell dumpsys activity activities` for the
     resumed foreground activity per the registry's readiness command; matched
     on the first poll (`READINESS_EXIT=0`).
   - Shutdown per the registry's `shutdownCommand`: `adb -s emulator-5554
     shell am force-stop com.snapsofts.cupid`, confirmed
     `visible=false ... isExiting` in a follow-up `dumpsys activity
     activities`. The reused emulator itself was left running (it was already
     running before this task and was not started by this task).

4. `flutter test test/features/pairing`
   - Result: PASS. `All tests passed!` (234 tests, `00:07 +234`).

5. `flutter analyze lib/features/pairing lib/main_preview.dart
   test/features/pairing`
   - Result: PASS (no errors or warnings). 8 `info`-level lint suggestions
     only, all `prefer_initializing_formals` style suggestions across
     `joincode_cubit.dart`, `pair_gate_cubit.dart`, `scan_code_cubit.dart`,
     `joincode_screen.dart`, `pairing_choice_screen.dart`, and
     `waiting_screen.dart`. None are errors or warnings; the non-zero
     `flutter analyze` exit code reflects the presence of `info`-level issues
     only.

## Scope note

This verification covers build/runtime/test/analyze of the merged
integration branch only. It does not re-litigate story-level review findings
and did not touch any story's own artifacts.
