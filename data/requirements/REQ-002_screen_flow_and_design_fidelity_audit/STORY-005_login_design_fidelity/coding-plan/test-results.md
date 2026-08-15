# STORY-005 Test Results

## Story Runtime Startup Smoke

Locale/theme toggle mechanism used: none required. `mobile/lib/app/cupid_app.dart`
reads `CupidFeatureFlags.enableLightTheme` / `enableEnLocale`
(`mobile/lib/core/config/cupid_feature_flags.dart`), both `bool.fromEnvironment`
with `defaultValue: false`. With no `--dart-define` overrides, `themeMode` is
`ThemeMode.dark` and `locale` is hard-coded `Locale('vi')` — the app's
build-time default already IS the dark theme + `vi` locale configuration this
story audits, so no device-level or in-app toggle was set.

### Android (emulator-5560)
- `backend-api` dependency: already reachable, `GET /api-docs-json` → 200,
  no start needed.
- Device: reused existing running emulator `emulator-5560` (adb state
  `device`), per `launch.subcommands.android` reuse rule.
- Build/install: `flutter build apk --debug --dart-define=CUPID_API_BASE_URL=http://10.0.2.2:3000`
  → `build/app/outputs/flutter-apk/app-debug.apk`, installed via
  `adb -s emulator-5560 install -r`.
- Readiness probe (registry `mobile-app.readiness.command`): `am start -W`
  reported `Status: timeout` (first-frame wait quirk, not a failure signal)
  but the subsequent `dumpsys activity activities` poll confirmed
  `ResumedActivity` for `com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
  within the 90s timeout.
- **Result: PASS**
- Raw capture: `adb -s emulator-5560 exec-out screencap -p` →
  `visual-fidelity/raw-capture/login-android.png` (confirmed via image
  read: unauthenticated entry screen, Vietnamese copy, no chrome/tab bar).
- Shutdown: `adb -s emulator-5560 shell am force-stop com.snapsofts.cupid`
  → exit 0.
- **Shutdown: PASS**

### iOS
- `xcode-select -p` resolves (`/Applications/Xcode.app/Contents/Developer`),
  but `xcrun simctl list devices available` and
  `xcrun simctl list runtimes` both returned no entries — no iOS Simulator
  runtime/device is installed on this machine, so
  `launch.subcommands.ios` has no device to reuse or boot.
- **Result: BLOCKED — typed blocker `IOS_NO_SIMULATOR`** (from
  `runtimes.mobile-app.launch.typedBlockers` in
  `data/devops/system/runtime-command-registry.json`).
- No iOS capture was taken; no shutdown applicable.
