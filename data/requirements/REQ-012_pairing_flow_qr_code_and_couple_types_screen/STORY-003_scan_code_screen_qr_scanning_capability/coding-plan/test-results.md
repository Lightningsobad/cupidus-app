# STORY-003 Test Results

Worktree: `story-REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-003_scan_code_screen_qr_scanning_capability`
Toolchain: Flutter 3.44.1 / Dart 3.12.1

## P1 — Camera Permission Foundation

Status: PASS

### A1 closure — dependency resolution

`flutter pub add mobile_scanner permission_handler` resolved cleanly against
the already-declared `environment: sdk: ^3.12.1`. No SDK constraint bump was
needed, neither package is discontinued, and no substitution was made.

Resolved versions, quoted from `mobile/pubspec.lock`:

| Package | pubspec.lock `version:` |
|---------|-------------------------|
| `mobile_scanner` | `"7.4.0"` |
| `permission_handler` | `"12.0.3"` |
| `permission_handler_android` | `"13.0.1"` |
| `permission_handler_apple` | `"9.6.1"` |
| `permission_handler_platform_interface` | `"4.4.0"` |
| `permission_handler_html` | `"0.1.4+1"` |
| `permission_handler_windows` | `"0.2.2"` |

`mobile/pubspec.yaml` was edited append-only: exactly two lines added after
`share_plus: ^13.3.0`, with no reordering or reformatting, so the integration
merge with STORY-002 (which edits the same file) sees no whitespace noise.

### minSdk

**No `minSdk` change was required or made.** `mobile_scanner` 7.4.0 declares
`minSdk = 23`. `mobile/android/app/build.gradle.kts` inherits
`flutter.minSdkVersion`, which is `24` in this toolchain
(`flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt:26`).
24 > 23, so the manifest merge has nothing to reconcile. The P4 debug APK build
is the final confirmation.

### Targeted tests

```
flutter test test/features/pairing/presentation/camera_permission_gate_test.dart
```

```
00:00 +0: PermissionHandlerCameraGate.status asks for the camera permission, and nothing else
00:00 +1: PermissionHandlerCameraGate.status granted maps to granted
00:00 +2: PermissionHandlerCameraGate.status denied maps to denied
00:00 +3: PermissionHandlerCameraGate.status permanentlyDenied maps to permanentlyDenied
00:00 +4: PermissionHandlerCameraGate.status restricted maps to unavailable
00:00 +5: PermissionHandlerCameraGate.status limited and provisional map to granted, not to a dead end
00:00 +6: PermissionHandlerCameraGate.openSettings opens the OS page
00:00 +7: FakeCameraPermissionGate drives every state with no platform channel
00:00 +8: FakeCameraPermissionGate counts openSettings calls
00:00 +9: platform permission declarations Android manifest declares CAMERA
00:00 +10: platform permission declarations iOS Info.plist carries a camera usage description
00:00 +11: All tests passed!
```

11/11 passed. The real `PermissionHandlerCameraGate` mapping is exercised by
swapping `PermissionHandlerPlatform.instance` for a fake, so all six upstream
`PermissionStatus` values are covered with no platform channel, and
`permission_handler` types still stay out of the `CameraPermissionGate` public
signature.

### Static analysis

```
flutter analyze lib/features/pairing test/features/pairing
```

```
Analyzing 2 items...

   info • Use an initializing formal to assign a parameter to a field. Try using an initialing formal ('this._acceptInvitation') to initialize the field • lib/features/pairing/presentation/joincode_cubit.dart:40:8 • prefer_initializing_formals
   info • Use an initializing formal to assign a parameter to a field. Try using an initialing formal ('this._getPartnerLink') to initialize the field • lib/features/pairing/presentation/pair_gate_cubit.dart:45:7 • prefer_initializing_formals
   info • Use an initializing formal to assign a parameter to a field. Try using an initialing formal ('this._createJoincodeCubit') to initialize the field • lib/features/pairing/presentation/screens/joincode_screen.dart:66:8 • prefer_initializing_formals
   info • Use an initializing formal to assign a parameter to a field. Try using an initialing formal ('this._createInviteCubit') to initialize the field • lib/features/pairing/presentation/screens/pairing_choice_screen.dart:28:8 • prefer_initializing_formals
   info • Use an initializing formal to assign a parameter to a field. Try using an initialing formal ('this._createJoincodeCubit') to initialize the field • lib/features/pairing/presentation/screens/pairing_choice_screen.dart:29:8 • prefer_initializing_formals
   info • Use an initializing formal to assign a parameter to a field. Try using an initialing formal ('this._createWaitingCubit') to initialize the field • lib/features/pairing/presentation/screens/waiting_screen.dart:28:8 • prefer_initializing_formals

6 issues found. (ran in 1.6s)
```

All 6 are pre-existing `prefer_initializing_formals` infos in files this phase
did not touch. Zero issues in `camera_permission_gate.dart` or its test. The
repo-wide baseline is 92 issues (info-level lints plus `unused_import` warnings
inside the generated `openapi/cupid_api` package); this phase adds none.

### Files changed

- `mobile/pubspec.yaml` (+2 lines, append-only)
- `mobile/pubspec.lock` (regenerated)
- `mobile/lib/features/pairing/presentation/camera_permission_gate.dart` (new)
- `mobile/test/features/pairing/presentation/camera_permission_gate_test.dart` (new)
- `mobile/android/app/src/main/AndroidManifest.xml` (CAMERA + optional camera feature)
- `mobile/ios/Runner/Info.plist` (`NSCameraUsageDescription`)
- `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/deployment/configuration-guide.md` (new)

## P2 — Payload Parser And Scan State Machine

Status: PASS

### Targeted tests

```
flutter test test/features/pairing/presentation/pairing_code_parser_test.dart test/features/pairing/presentation/scan_code_cubit_test.dart
```

47/47 passed (26 parser cases, 21 cubit cases). Named coverage for the phase's
required assertions:

| Required assertion | Test |
|--------------------|------|
| Malformed payload → State 4, zero network calls | `detection a malformed payload is rejected with zero network calls` — asserts `accept.codes` is empty |
| Valid payload → exactly one submit with the normalized code | `detection a valid payload submits exactly the normalized code` — asserts `accept.codes == ['ABC123']` from raw `https://cupid.app/join/abc123` |
| Repeated detections → one submit | `detection repeated detections during an in-flight submit send one` — four detections, `accept.codes == ['ABC123']` |
| Each permission status → its state | four `start resolves permission` tests, one per `CameraPermissionState` |
| `InvalidOrExpiredCodeFailure` → State 4, no close | `routing ... invalid or expired backend rejection -> State 4, no close` |
| Every other failure → close signal | four `every failure the overlay does not render closes it` tests |
| `JoincodeSuccess` → close signal | `routing ... success closes the overlay` |
| URL payload never degrades to `HTTPS:` | `a bare URL never degrades into the scheme prefix` |

The stub records the exact string handed to `acceptInvitation`, which is the
same seam manual entry uses — that is how AC2's "identical outcome" is checked
rather than assumed.

### Regression

```
flutter test test/features/pairing/
```

```
+189: All tests passed!
```

The whole pairing feature suite, including the untouched
`joincode_cubit_test.dart`, is green. `JoincodeCubit` was not modified.

Flaky-test note, recorded rather than hidden: an earlier run of the same
command reported one failure in
`test/features/pairing/presentation/invite_cubit_test.dart` —
`InviteCubit a profile read resolving after the code still pre-fills`. It is a
pre-existing, timing-sensitive test in a file this story does not touch and does
not import; it passed standalone and passed on the re-run of the full suite. It
is not a STORY-003 regression, but it is worth a look from whoever owns
`InviteCubit`.

### Static analysis

```
flutter analyze lib/features/pairing test/features/pairing
```

8 issues, all info-level `prefer_initializing_formals`. Six are the pre-existing
ones from P1. The two new ones
(`scan_code_cubit.dart:68` / `:69`) are the same unavoidable false positive the
codebase already carries at `joincode_cubit.dart:40`, `pair_gate_cubit.dart:45`
and three other sites: the lint suggests `this._permissionGate`, but Dart
forbids a named parameter beginning with an underscore, so the suggested fix
does not compile. The private-field-plus-assignment form used here matches every
existing cubit in this feature.

### Files changed

- `mobile/lib/features/pairing/presentation/pairing_code_parser.dart` (new)
- `mobile/lib/features/pairing/presentation/scan_code_cubit.dart` (new)
- `mobile/test/features/pairing/presentation/pairing_code_parser_test.dart` (new)
- `mobile/test/features/pairing/presentation/scan_code_cubit_test.dart` (new)

## P3 — Scan Screen States

Status: PASS (one pre-existing unrelated failure, detailed below)

### Targeted tests

```
flutter test test/features/pairing/presentation/screens/scan_code_screen_test.dart
```

```
00:00 +1: State 1 — opening shows no camera and no error while permission resolves
00:00 +2: State 2 — live scanning mounts the camera preview exactly once
00:00 +3: State 2 — live scanning shows the aiming helper and the manual-entry way out
00:00 +4: State 3 — recognized a scanned code reaches the same pairing call manual entry uses
00:00 +5: State 3 — recognized drops the scanning helper copy on a hit
00:00 +6: State 3 — recognized a backend success closes the overlay on its own
00:00 +7: State 4 — invalid or expired a malformed payload shows the honest card, not a success
00:00 +8: State 4 — invalid or expired the camera keeps running under the card
00:00 +9: State 4 — invalid or expired Try again re-arms scanning immediately
00:00 +10: State 4 — invalid or expired the card steps aside on its own after ~3s
00:00 +11: State 4 — invalid or expired a backend rejection lands on the same card
00:00 +12: State 4 — invalid or expired the manual-entry link leaves with the manualEntry reason
00:00 +13: State 5 — permission denied explains the block and offers manual entry, no camera
00:00 +14: State 5 — permission denied the way out returns to manual entry
00:00 +15: State 6 — permanently denied points at Settings and keeps a second way forward
00:00 +16: State 6 — permanently denied Open Settings reaches the permission gate
00:00 +17: State 7 — camera unavailable states the limit plainly with one way forward
00:00 +18: close control is present and labelled in every state
00:00 +19: close control meets the 44x44 minimum hit target
00:01 +20: close control closing tears down the camera and reports dismissed
00:01 +21: failures ... AlreadyPairedFailure hands back to the screen below
00:01 +22: failures ... SelfInviteFailure hands back to the screen below
00:01 +23: failures ... InviterAlreadyPairedFailure hands back to the screen below
00:01 +23: All tests passed!
```

23/23 passed. Coverage of the phase's required assertions:

| Required assertion | Test |
|--------------------|------|
| Each of States 1-7 renders its own copy/controls | one or more tests per state group above |
| AC5 verifiable with no camera | every test drives the screen through the injected `ScanPreviewBuilder`; no `mobile_scanner` widget is built |
| Camera controller released on every exit | `_PreviewLifecycle.disposals` asserted on close, manual-entry exit, success, and each non-rendered failure |
| Camera keeps running under State 4 | `the camera keeps running under the card` — asserts `mounts == 1` and `disposals == 0` while the card shows |
| State 4 auto-dismiss | `the card steps aside on its own after ~3s` |
| `Mở Cài đặt` reaches the gate | `Open Settings reaches the permission gate` — `openSettingsCalls == 1` |
| Close control >=44x44 and labelled | `meets the 44x44 minimum hit target`, `is present and labelled in every state` |
| AC2 identity with manual entry | `a scanned code reaches the same pairing call manual entry uses` — the stub records `ABC123` from a raw URL payload |

### Regression

```
flutter test test/features/pairing/ test/design_system/
```

```
+297 -1: Some tests failed.
```

297 passed. The single failure is **pre-existing and unrelated to STORY-003**:

```
test/design_system/no_fork_guard_test.dart: AC 4 no-fork guard ... [E]
  Expected: empty
    Actual: [
              'lib/features/pet/presentation/widgets/pet_preview_card.dart:229: forbidden pattern "Colors."',
              'lib/features/pet/presentation/widgets/pet_preview_card.dart:230: forbidden pattern "Colors."'
            ]
```

Evidence that it is not a STORY-003 regression: `git diff --name-only 2f36219`
lists neither `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart`
nor `mobile/test/design_system/no_fork_guard_test.dart`, so both are
byte-identical to `BaseHead`. The guard is a pure static scan over file
contents, and its reported findings name only that untouched pet file — none of
this story's new files. Fixing it is a pet-feature change outside this story's
write scope; it is flagged here for Scrum Master to queue separately.

### Guard caught during this phase, and fixed

The first run of this suite also failed
`test/design_system/shared_backdrop_occlusion_guard_test.dart` on this story's
own new file:

```
'lib/features/pairing/presentation/screens/scan_code_screen.dart:141: Scaffold(backgroundColor: colors.colorBackground) paints an opaque root fill over the shared --sky wash'
```

Fixed at the source rather than allowlisted: the `backgroundColor` was removed
so the Scaffold stays transparent like every other screen, and the shared `--sky`
wash mounted once at `cupid_app.dart:59` shows through. The camera surface
covers it on the states that have one, so the rendered result is unchanged where
it matters. The guard now passes.

### Static analysis

```
flutter analyze lib/features/pairing test/features/pairing
```

```
8 issues found. (ran in 1.8s)
```

Unchanged from the P2 baseline: the same 8 info-level
`prefer_initializing_formals` entries, 6 pre-existing plus the 2 unavoidable
ones in `scan_code_cubit.dart`. `scan_code_screen.dart`, `scan_code_route.dart`
and the new widget test contribute zero issues.

### Notes

- `ScanCodeRoute` is a `PageRouteBuilder` fading in over
  `scanCodeFadeDuration` (150ms), pushed opaque so the join-code screen below
  stays mounted with its typed characters intact. It wraps the screen in
  `BlocProvider<JoincodeCubit>.value` — the join-code screen's own instance, not
  a new one, which is the mechanism behind AC2.
- The route resolves to `ScanCodeExit.dismissed` or `ScanCodeExit.manualEntry`
  so P4 can decide whether to restore focus to the code row.
- Icons: `CupidIcons` carries none of the scan-screen glyphs and
  `lib/design_system/` is outside this story's write scope, so `close`,
  `photo_camera`, `error` and `no_photography` are file-local `IconData`
  constants following the `_contentPasteIcon` precedent at
  `joincode_screen.dart:14`. Each codepoint was read from the bundled
  `assets/fonts/MaterialSymbolsRounded-Variable.ttf` cmap with `fontTools`.

### Files changed

- `mobile/lib/features/pairing/presentation/screens/scan_code_screen.dart` (new)
- `mobile/lib/features/pairing/presentation/scan_code_route.dart` (new)
- `mobile/test/features/pairing/presentation/screens/scan_code_screen_test.dart` (new)

## P4 — Quét QR Entry Point, Wiring, And Preview Coverage

### Widget tests — join-code screen

```
flutter test test/features/pairing/presentation/joincode_screen_test.dart
```

```
+22: All tests passed!
```

Five of the 22 are new, in group `STORY-003 Quét QR entry point`:

1. The `Quét QR` pill renders beside the existing `Dán` pill, asserted by
   x-offset rather than by widget order, so a future column layout fails it.
2. Tapping the pill pushes `ScanCodeRoute` and the overlay renders.
3. **AC2 parity.** The same `acceptInvitation` stub is driven twice against a
   freshly-keyed `MaterialApp` — once by typing `3F9A2B`, once by delivering the
   QR payload `https://cupid.app/join/3f9a2b` through the overlay's own
   `onDetected` seam. The recorded calls are
   `<String>['3F9A2B', '3F9A2B']`, and both runs land on the paired route with
   the overlay gone. Identical outcome, not merely a successful one.
4. A dismissed scan (via the overlay's `Close` control) leaves the partially
   typed `3F9` and its slot glyphs untouched.
5. A denied camera permission still reaches `Nhập mã thủ công` /
   `Enter code manually`, so the pill can never trap a user without a camera.

The AC2 test needs the `appKey` seam added to `_harness`: `pumpWidget` against
the same `MaterialApp` identity keeps the Navigator stack, so the second run
started on the already-pushed paired route. Distinct keys (`typed_run` /
`scanned_run`) rebuild the Navigator from scratch.

`_openScanOverlay` deliberately does not use `pumpAndSettle`: State 1 renders an
indefinite progress indicator while the permission future is outstanding, so the
tree never settles.

### Regression

```
flutter test test/features/pairing/
```

```
+217: All tests passed!
```

```
flutter test test/features/pairing/presentation test/design_system/
```

```
+279 -1: Some tests failed.
```

The single failure is the **same pre-existing, out-of-scope**
`no_fork_guard_test.dart` hit on `pet_preview_card.dart:229-230` recorded under
P3 above. `pet_preview_card.dart` does not appear in this worktree's
`git status`, so it is byte-identical to `BaseHead`.

### Static analysis

```
flutter analyze lib/features/pairing lib/main_preview.dart test/features/pairing
```

```
8 issues found. (ran in 2.9s)
```

The unchanged baseline: 8 info-level `prefer_initializing_formals`. The
`main_preview.dart` registry entry and builder contribute zero issues.

A whole-project `flutter analyze` is not usable here — it walks
`build/ios/SourcePackages/checkouts/flutterfire/…` and emits thousands of
pre-existing errors from vendored checkouts unrelated to this story. The scoped
invocation above is the gate.

### Android build gate

```
flutter build apk --debug
```

```
✓ Built build/app/outputs/flutter-apk/app-local-debug.apk
```

This gate initially failed, and closing it changed a dependency:

```
Could not determine the dependencies of task
':permission_handler_android:compileDebugJavaWithJavac'.
> Failed to find target with hash string 'android-37' in:
  /Users/<user>/Library/Android/sdk
```

`permission_handler` 13.0.1 pulls `permission_handler_android` 14.0.0, which
pins `compileSdk = 37`. `sdkmanager --list` publishes no `platforms;android-37`
package at all — only minor-versioned `37.0`, `37.1`, `37.2-beta*` — and raising
the app's own `compileSdk` cannot help because the failing module is the plugin,
which pins its own. `permission_handler` was therefore held at `^12.0.1`
(resolves 12.0.3 → `permission_handler_android` 13.0.1), which compiles against
an installed platform and whose Dart API is unchanged for everything this story
uses. This is a version pin on the same package, not a substitution of a
different one; the reasoning and the lift condition are recorded in
`deployment/configuration-guide.md`.

### Design fidelity — preview harness on `emulator-5554`

`main_preview.dart` gained a `scan` entry. The state is a compile-time define,
so each capture below is its own build:

```
flutter build apk --debug -t lib/main_preview.dart \
  --dart-define=PREVIEW=scan --dart-define=PREVIEW_SCAN_STATE=<state>
adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-local-debug.apk
adb -s emulator-5554 shell am force-stop com.snapsofts.cupid
adb -s emulator-5554 shell am start -n \
  com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
.ai-team-bundle/runtime/tools/capture-mobile-screen.sh \
  --out=<story>/visual-fidelity --label=scan-<state> \
  --device=emulator-5554 --settle-ms=30000
```

| File | State | Result |
|------|-------|--------|
| `visual-fidelity/implemented-joincode-two-pill-row-emulator-5554.png` | join-code screen | `Dán` and `Quét QR` share one row, equal width, above `Ghép đôi`. |
| `visual-fidelity/implemented-scan-live-emulator-5554.png` | State 2, scanning | Pink viewfinder, `Đưa camera vào mã QR của người ấy`, `Nhập mã thủ công`, close control. |
| `visual-fidelity/implemented-scan-invalid-emulator-5554.png` | State 4, invalid | Error card inside the viewfinder: `Mã QR không hợp lệ hoặc đã hết hạn`, `Thử lại`, `Nhập mã thủ công`. |
| `visual-fidelity/implemented-scan-denied-emulator-5554.png` | State 5, denied | `Cupid cần quyền camera để quét mã QR` over `Nhập mã thủ công`. |
| `visual-fidelity/implemented-scan-blocked-emulator-5554.png` | State 6, blocked | `Cupid cần quyền camera trong Cài đặt để quét mã QR`, `Mở Cài đặt`, plus the manual-entry way out. |
| `visual-fidelity/implemented-scan-unavailable-emulator-5554.png` | State 7, no camera | `Không thể mở camera trên thiết bị này` over `Nhập mã thủ công`. |

Three things about these captures are worth writing down, because each one cost
a wrong capture first:

- **`--width` is a device resize, not an image resize.** Passing
  `--width=540` without a matching `--density` left the emulator rendering at a
  ~206dp logical viewport, which produced a spurious `RIGHT OVERFLOWED BY 9.8
  PIXELS` banner on the join-code screen and an error card that filled the
  screen edge-to-edge. A raw `adb exec-out screencap -p` taken seconds apart
  showed the correct layout, and a widget-test probe at true phone metrics
  reported no overflow. Every capture above is taken with no `--width` at all,
  so the device renders at its native 1080x2400 / density 420 and only the
  output file is downscaled by the default `--max-edge=900`.
- **The preview entry point is slow to first real frame.** `main()` runs
  Firebase init plus `bootstrapPreviewSession()`, so a capture under ~20s of
  settle returns the Flutter splash. 30s is reliable.
- **State 4 auto-dismisses.** `_PreviewScanSurface` re-emits the invalid payload
  on a 500ms timer rather than once, because the screen returns to State 2 after
  ~3s; a single emission would leave most captures on the scanning state. The
  emit is on a timer rather than in `initState` for a second reason: the preview
  builder runs inside the overlay's own `BlocConsumer` build, where a cubit emit
  would be a `markNeedsBuild` during build.

### Design-fidelity defect found by looking, and fixed

The first State 4 capture showed the error card as a soft-edged stadium rather
than a card. `_InvalidCard` was using `platformTokens.radiusButton`, which is
`999` on both platforms — the pill radius — on a ~280dp-wide container. Changed
to `platformTokens.radiusCard` (24 Material / 26 iOS), which is what the token's
own doc comment describes ("Card/content container corner radius") and is
consistent with `_Viewfinder` in the same file already using `radiusSheet`. The
re-capture above shows a correctly bounded card. Suites re-run green afterwards.

This is exactly the class of defect the widget tests could not catch: nothing
asserts a radius value, and the layout is legal either way.

### Notes

- The star particles visible over the black camera surface are app-wide,
  intentional behaviour from `cupid_app_background.dart`, whose doc comment
  records that the design source authors them as `position:absolute` siblings
  that CSS paints above in-flow screen content. Not introduced here, and
  `cupid_app_background.dart` is outside this story's write scope.
- The preview camera surface is a plain black `ColoredBox`, authored inside
  `main_preview.dart` rather than shipped from `lib/features`, because the
  capture machine has no camera. `Colors.black` is safe there specifically:
  `no_fork_guard_test.dart` scans `lib/features`, `lib/app` and `lib/core`, and
  `lib/main_preview.dart` is in none of them.

### Files changed

- `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart`
  (two-pill row, scan wiring, `scanPermissionGate`/`scanPreviewBuilder` seams)
- `mobile/lib/features/pairing/presentation/screens/scan_code_screen.dart`
  (`_InvalidCard` radius token)
- `mobile/lib/main_preview.dart` (`scan` preview entry)
- `mobile/test/features/pairing/presentation/joincode_screen_test.dart`
  (5 new tests, `appKey`/`scanPermission`/`scanHook` harness seams)
- `mobile/pubspec.yaml`, `mobile/pubspec.lock` (`permission_handler` pin)
- `data/requirements/REQ-012_.../deployment/configuration-guide.md` (pin
  rationale)
- `visual-fidelity/visual-fidelity-report.md` (requirement mobile visual audit)

### Requirement mobile visual audit

`../visual-fidelity/visual-fidelity-report.md` closes the P4 §6 audit gate.
Verdict `VISUAL_FIDELITY: PASS_WITH_FLAGGED_DELTA`.

The entry-point row is compared line by line against
`Cupid Screens.dc.html:1630-1633`; the five captured overlay states are compared
against `../ux/ux-spec.md` States 2, 4, 5, 6 and 7, because the design canvas has
no `sc-if` block for the scan surface at all — only the UX spec authors it.
States 1 and 3 are transient (≤400ms) and are covered by widget tests instead of
a frame grab; no `MOBILE_VISUAL_AUDIT_STATE_MISSING` is raised.

One delta needs a Reviewer/UI-UX decision, report §4.1: `ux-spec.md:104-106` and
`:175` put the State 4 message card at `var(--r-btn)`, which
`Cupid Screens.dc.html:24-25` defines as `999px`. On a card-shaped surface that
renders as a stadium blob, so `scan_code_screen.dart:388` uses `radiusCard`.
Deliberate deviation from the literal spec text, reverted by one token if the
spec is held to win. Four further deltas (§4.2-§4.5) are recorded as intentional
or pre-existing and need no action.

## Story Runtime Startup Smoke

Scope: mobile-app (impacted service/app for this story).
Runtime Id: mobile-app
Registry: data/devops/system/runtime-command-registry.json (runtimes.mobile-app)
Command: `flutter build apk --debug` (build) + `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-local-debug.apk` (install) + registry-backed readiness command (launch/poll), all from `mobile/`
Ready Check: `runtimes.mobile-app.readiness.command` (adb shell am start -W then poll dumpsys activity activities for ResumedActivity), followed by `runtimes.mobile-app.readiness.shutdownCommand`
Result: PASS
Shutdown: PASS

Owner: Scrum Master, run directly per `../coding-plan/master-plan.md`
§4 ("startup smoke REQUIRED — story-level gate run by Scrum Master after P4,
not inside any implementation phase"), not delegated to mobile-dev (ordinary
`continue` mobile-dev handoffs are restricted from emulator/device runtime
work; `guard-broad-handoff.sh [GENERIC]` — targeted unit/component/integration/
build evidence only for that lane).

Device: `emulator-5554`, already running (not booted by this smoke — booting an
emulator is a separate concern from this gate; the smoke only launches/stops the
app on an already-live device).

Steps, using the `mobile-app` runtime registry entry
(`data/devops/system/runtime-command-registry.json`):
1. `buildCommand`: `flutter build apk --debug` in `mobile/` (worktree HEAD at
   the time of this smoke) — built `build/app/outputs/flutter-apk/app-local-debug.apk`
   cleanly (Gradle `assembleLocalDebug`, KGP plugin warnings only, no errors).
2. Installed the built debug APK directly via
   `adb -s emulator-5554 install -r <path-to-app-local-debug.apk>` (the
   registry's own `flutter install -d emulator-5554` targets the release-flavor
   artifact, which this debug build does not produce; `adb install` against the
   actual debug APK path is the correct install step for a debug build, and
   that is the command used above).
3. Ran the registry's exact `readiness.command` (launch `MainActivity` with
   `am start -W`, poll `dumpsys activity activities` for
   `ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
   up to 30 × 2s) — resumed/foreground within the first poll, exit 0.
4. Ran the registry's exact `readiness.shutdownCommand`
   (`am force-stop com.snapsofts.cupid`) to leave the device clean.

Shutdown: Confirmed via step 4. Result/Shutdown: PASS, app stopped cleanly, no
process left running.

Scope: this smoke only exercises the app launching to its first screen on an
already-live device (`am start` / resumed-activity probe); it does not exercise
the STORY-003 scan flow, camera permission prompt, or QR decode path — that
functional coverage is the widget tests and the visual-fidelity states above.

## Entry Point Reachability

Reachable: YES

Path: `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart`,
the `Quét QR` pill (this is the discoverable entry path into `ScanCodeRoute`).
The supporting evidence is the P4 widget-test narrative above and is not
restated here.

The scan entry point is the `Quét QR` pill on the join-code screen, and it is
reachable by a user, not only by a test that navigates directly to
`ScanCodeRoute`:

- The pill renders beside the existing `Dán` pill on the join-code screen
  (asserted by x-offset, not widget order).
- Tapping the pill pushes `ScanCodeRoute` and the overlay renders.
- A denied camera permission still reaches `Nhập mã thủ công` /
  `Enter code manually`, so the pill cannot trap a user without a camera.

Both the typed and the scanned path drive the same `acceptInvitation` seam to
the same paired route (AC2 parity), so the entry point leads to the same
terminal state as the pre-existing manual path.

## P4 Re-run — Visual-Fidelity Rework (VF-1..VF-6)

Appended 2026-08-26, after Scrum Master accepted rework for the six findings in
`../visual-fidelity/visual-fidelity-report.md` §4.6. The P4 entry above is the
pre-rework record and is left untouched.

Baseline for this pass: `BaseHead` `ea58d0fb8edd1421f58aefd40ca31f97eaf57258`.
Changed files: `scan_code_screen.dart` and its widget test — nothing else.

### Commands

- `flutter test test/features/pairing` → `+223: All tests passed!`
  (217 before, plus the six new fidelity cases below)
- `flutter analyze lib/features/pairing lib/main_preview.dart test/features/pairing`
  → `8 issues found`, all `info • prefer_initializing_formals`, byte-for-byte
  the pre-existing baseline. `flutter analyze` exits 1 on `info`, so the
  non-zero status here is the tool's convention, not a new diagnostic.

### New pinning tests — `group('design fidelity')`

One case per accepted finding, each asserting the measurable property rather
than widget order:

| Case | Asserts |
| --- | --- |
| VF-1 | `Key('scan_line')` present in State 2, absent once the payload is invalid |
| VF-2 | helper top − viewfinder bottom ≈ 22dp, and helper sits above the manual-entry link |
| VF-3 | invalid card width == screen width − 52 (26dp inset per side) |
| VF-4 | viewfinder border alpha 1.0 live, 0.35 while the card is up |
| VF-5 | message `fontSize` 15, `FontWeight.w700`, `height` 1.4 |
| VF-6 | `CupidPrimaryButton` renders exactly 270dp wide |

### Harness change worth flagging to review

The VF-1 scan line is a repeating `AnimationController`, so `pumpAndSettle` can
never return while State 2 is the visible state. Two things absorb that:

1. `_Viewfinder` **stops** the controller (not merely hides the line) whenever
   the frame is `recognized` or `dimmed`, so States 3 and 4 still settle
   normally and no ticker runs behind a modal card.
2. A `_pumpScanning` helper replaces `pumpAndSettle` at exactly three sites
   where State 2 is what is on screen — inside `openResolved`, after
   `tap('Try again')`, and after the ~3s auto-dismiss pump. It pumps the fade
   duration explicitly, following the precedent this file already set for
   State 1's spinner.

No assertion was weakened or removed to accommodate the animation; the other
`pumpAndSettle` calls are untouched because their states have no live ticker.

### Known non-regression

`no_fork_guard_test` still reports `pet_preview_card.dart:229-230` for the
forbidden `Colors.` substring. That file is byte-identical to `BaseHead`
(`git diff ea58d0f -- mobile/lib/features/pet` is empty), so the hit is
pre-existing and out of this story's scope, exactly as recorded in the P4 entry
above.

### Device evidence

Five implemented screenshots re-captured on `emulator-5554` at this commit and
re-paired against the unchanged design references; see
`../visual-fidelity/visual-fidelity-report.md` §1 and §4.6. Verdict moved from
`FAIL` to `PASS` for VF-1..VF-6, with one new low-severity observation (VF-7)
logged open rather than silently fixed.
