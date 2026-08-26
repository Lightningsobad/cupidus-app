# REQ-012 Configuration Guide — Camera Permission For QR Scanning

Scope: the Flutter app in `mobile/` and its two native host projects,
`mobile/android/` and `mobile/ios/`.

STORY-003 turns the join-code screen's "Quét QR" / "Scan QR" affordance into a
real device-camera scan. That is the first camera use anywhere in this app, so
it introduces store-facing and device-facing configuration that did not exist
before this requirement. Nothing here is a runtime-tunable setting: there is no
new environment variable, no new dart-define, and no new backend key. What
follows is build-time and store-submission configuration a release engineer has
to know about.

## New Third-Party Dependencies

Added to `mobile/pubspec.yaml` as direct dependencies:

| Package | Constraint | Resolved | Why |
|---------|------------|----------|-----|
| `mobile_scanner` | `^7.4.0` | `7.4.0` | Camera preview plus QR/barcode decoding (Google MLKit on Android, Vision on iOS). |
| `permission_handler` | `^12.0.1` | `12.0.3` | Runtime camera-permission request and the "open app settings" escape hatch. |

Transitive resolutions worth naming, because they are what actually ship in the
native builds (quoted from `mobile/pubspec.lock`):

| Package | Resolved |
|---------|----------|
| `permission_handler_android` | `13.0.1` |
| `permission_handler_apple` | `9.6.1` |
| `permission_handler_platform_interface` | `4.4.0` |
| `permission_handler_html` | `0.1.4+1` |
| `permission_handler_windows` | `0.2.2` |

### Why `permission_handler` is held at 12.x

`permission_handler` 13.0.1 is the current release and resolves cleanly, but its
Android implementation, `permission_handler_android` 14.0.0, sets
`compileSdk = 37`. Gradle resolves that to the platform hash `android-37`, and
the Android SDK no longer publishes a package under that name — the only API 37
platforms available are minor-versioned (`platforms;android-37.0`,
`android-37.1`, `android-37.2-beta*`). `flutter build apk --debug` therefore
fails before compiling any app code:

```text
Could not determine the dependencies of task
':permission_handler_android:compileDebugJavaWithJavac'.
> Failed to find target with hash string 'android-37' in:
  <ANDROID_SDK>
```

Raising the app's own `compileSdk` does not help: the failing module is the
plugin, which pins its own value. `permission_handler` 12.0.3 pulls
`permission_handler_android` 13.0.1, which compiles against an installed
platform, and its Dart API is unchanged for everything this story uses
(`Permission.camera.request()`, the six `PermissionStatus` values, and
`openAppSettings()`).

This is a version pin, not a package substitution — the same package, one major
version back. Lift it once `permission_handler_android` ships a release that
targets a platform the SDK actually publishes, or once the toolchain gains an
`android-37` package. Re-check with `flutter pub outdated` before upgrading and
re-run `flutter build apk --debug`, which is the only gate that catches this.

The last two resolve because `permission_handler` is an endorsed federated
plugin and pub always pulls every platform implementation. This app builds only
Android and iOS, so neither is compiled into a shipped artifact.

## Android

`mobile/android/app/src/main/AndroidManifest.xml` now declares:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

- `CAMERA` is a runtime (dangerous) permission. The declaration alone grants
  nothing; without it the runtime request is auto-denied and the scan overlay
  can only ever reach its denied state.
- `android:required="false"` is deliberate. If the feature were left implicitly
  required, Google Play would hide the app from cameraless devices. Scanning is
  an optional accelerator — manual code entry stays fully available — so the app
  must remain installable on those devices.

### minSdk

`mobile_scanner` 7.4.0 declares `minSdk = 23`. This app inherits
`flutter.minSdkVersion` in `mobile/android/app/build.gradle.kts`, which is `24`
for the pinned Flutter toolchain. 24 is already above 23, so **no minSdk change
was needed** and none was made. If a future change ever lowers the app's minSdk
below 23, the Android build will fail at manifest merge and will need an
explicit floor.

### Play Console

No new Data Safety declaration is required: scanned camera frames are decoded
on-device by MLKit and never leave the device. Only the decoded 6-character
pairing code is sent, to the pre-existing `/invitations/accept` endpoint — the
exact same call manual code entry already makes.

## iOS

`mobile/ios/Runner/Info.plist` now carries:

```xml
<key>NSCameraUsageDescription</key>
<string>Cupid needs access to your camera so you can scan your partner's pairing QR code.</string>
```

This key is mandatory. iOS terminates the app outright the first time it
requests camera access without a usage description, and App Store review rejects
builds whose purpose string is missing or generic. If the string is ever
localized or reworded, keep it specific about *scanning a partner's pairing QR
code* — a vague "needs your camera" is a known review-rejection reason.

`permission_handler` on iOS additionally gates each permission at compile time
through `PERMISSION_*` macros in `GCC_PREPROCESSOR_DEFINITIONS`. When those
macros are left unset, every handler compiles in, camera included. This
repository checks in no `mobile/ios/Podfile` — CocoaPods generates it on the
first iOS build — so there is nothing to change today. Anyone who later commits
a Podfile with the trim-the-binary macro allowlist must keep
`PERMISSION_CAMERA=1` in it, or the camera request will silently resolve to
denied on iOS only.

## Verification

An engineer picking this up can confirm the configuration without a device:

```bash
cd mobile
flutter test test/features/pairing/presentation/camera_permission_gate_test.dart
```

Two of those tests assert the manifest and plist declarations directly, so a
dropped permission fails CI rather than surfacing as a mystery denied camera on
a tester's phone.

On-device confirmation still needs a real handset — neither the Android emulator
nor the iOS simulator provides a camera that decodes a QR reliably.
