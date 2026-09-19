# REQ-016 Configuration Guide — Phase Widget Host Configuration

Scope: the native host configuration the phase widget (STORY-012) needs on both
platforms. Application logic lives in Dart; nothing here is a runtime setting a
user can change, and nothing here is read at runtime by the app.

The identifier contract itself is authoritative in
`../STORY-012_phase_status_and_widget/architecture/contract-summary.md` §1–§2.
This guide only says where each identifier has to be typed for a build to
produce a working widget.

## The Shared Identifiers

| What | Value | Declared in |
|------|-------|-------------|
| App Group | `group.com.snapsofts.cupid` | `mobile/ios/Runner/Runner.entitlements`, `mobile/ios/CupidPhaseWidget/CupidPhaseWidget.entitlements`, `widgetAppGroupId` in `mobile/lib/features/phase_status/data/home_widget_bridge.dart` |
| iOS widget kind | `CupidPhaseWidget` | `CupidWidgetContract.kind` in the extension, `widgetIosName` in the bridge |
| iOS extension bundle id | `com.snapsofts.cupid.CupidPhaseWidget` | `PRODUCT_BUNDLE_IDENTIFIER` on the `CupidPhaseWidget` target |
| Android provider | `com.snapsofts.cupid.CupidPhaseWidgetProvider` | `mobile/android/app/src/main/AndroidManifest.xml`, `widgetAndroidProviderName` in the bridge |
| Deep link | `cupidapp://card/<card_id>`, fallback `cupidapp://home` | `CupidPhaseWidgetProvider.kt`, `CupidPhaseWidget.swift` |

`applicationId` is `com.snapsofts.cupid` on every flavor (REQ-008 deliberately
sets no `applicationIdSuffix`), so there is exactly one App Group and one
provider for all of `local` and `prod`. A future flavor suffix would fork both
and is a breaking change for this widget.

`native_copy_scan_test.dart` reads these values back out of the source files, so
a typo on either native side fails `flutter test` rather than shipping a blank
widget.

## iOS

### Minimum deployment target: 14.0

`home_widget`'s Swift package declares an iOS 14.0 minimum, and WidgetKit itself
starts at 14.0. All nine `IPHONEOS_DEPLOYMENT_TARGET` entries in
`mobile/ios/Runner.xcodeproj/project.pbxproj` were raised from 13.0 to 14.0 for
this requirement. Lowering any of them back breaks the build with
`Target Integrity (Xcode): The package product 'home-widget' requires minimum
platform version 14.0`.

This is a product-visible change: iOS 13 devices can no longer install the app.

### The extension target

`mobile/ios/CupidPhaseWidget/` holds the whole extension — one Swift file, an
`Info.plist` whose `NSExtensionPointIdentifier` is
`com.apple.widgetkit-extension`, and an entitlements file. The target is
embedded into Runner through a **Embed App Extensions** copy-files phase
(destination `PlugIns`).

Two ordering rules the project depends on:

1. **Embed App Extensions must sit before Flutter's `Thin Binary` phase.** With
   it after, Xcode reports `Cycle inside Runner; building could produce
   unreliable results` and the build fails, because `Thin Binary` reads the
   finished `Runner.app` that the copy is still writing into.
2. **The extension must carry every build configuration Runner has** — all nine:
   `Debug`, `Release`, `Profile` and the six flavored ones (`Debug-local`,
   `Debug-prod`, `Release-local`, `Release-prod`, `Profile-local`,
   `Profile-prod`). A configuration present on Runner but missing on the
   extension fails only on the flavor nobody built locally.

Both rules are asserted by `native_copy_scan_test.dart`, which parses
`project.pbxproj` directly.

The extension inherits `FLUTTER_BUILD_NAME`/`FLUTTER_BUILD_NUMBER` because its
base configuration references the same `Flutter/Debug.xcconfig` and
`Flutter/Release.xcconfig` as Runner. This is what keeps the `.appex` version in
lockstep with the app version; App Store validation rejects a mismatch.

### Register the `cupidapp` URL scheme on Runner

`mobile/ios/Runner/Info.plist` must declare the widget's deep link scheme,
otherwise iOS has nobody to hand `cupidapp://card/<card_id>` to and a tap on the
widget does nothing at all — the widget's only affordance. The build, the tests
and the App Store validation all stay green without it, so it has to be checked
by reading the file:

```xml
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLName</key>
		<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<string>cupidapp</string>
		</array>
	</dict>
</array>
```

`Runner/Info.plist` is one of the files `flutter create .` rewrites, so re-add
this block after any platform-folder regeneration. `native_copy_scan_test.dart`
reads the scheme back out of `CupidPhaseWidgetProvider.kt` and asserts the plist
registers that same value.

### Apple Developer portal

Signed builds (anything other than `--no-codesign`) additionally need, once per
team:

- the App Group `group.com.snapsofts.cupid` created under Identifiers →
  App Groups;
- the capability enabled on **both** App IDs, `com.snapsofts.cupid` and
  `com.snapsofts.cupid.CupidPhaseWidget`;
- provisioning profiles for both regenerated afterwards.

`DEVELOPMENT_TEAM` is `7TG552SW73` with `CODE_SIGN_STYLE = Automatic`, so Xcode
handles the refresh once the portal side exists. Missing this step produces
`Provisioning profile ... doesn't include the com.apple.security.application-groups
entitlement` at signing time, never at build time — an unsigned CI build will
not catch it.

## Android

The widget needs no configuration beyond the manifest `<receiver>` that P4
added, and it deliberately adds **no** permission. The three
`<uses-permission>` entries in `mobile/android/app/src/main/AndroidManifest.xml`
(`READ_MEDIA_IMAGES`, `POST_NOTIFICATIONS`, `CAMERA`) all predate this
requirement; `POST_NOTIFICATIONS` is the Android 13+ runtime permission the
reminder surface uses, not the widget.

`android:updatePeriodMillis="0"` in
`mobile/android/app/src/main/res/xml/cupid_phase_widget_info.xml` is load-bearing:
it tells the system never to poll the provider. The payload is pushed from Dart
on mount, on resume, and on a card status change. Any non-zero value here
reintroduces the `WIDGET-STALE` risk the phase was written to avoid.

## Recovery After Regeneration

`flutter create .`, a platform-folder regeneration, or a merge that takes
"theirs" on `project.pbxproj` will silently drop the iOS half of this setup.
`flutter build ios` still succeeds — it just produces an app with no widget.
`flutter test test/features/phase_status/native_copy_scan_test.dart` is the
check that fails loudly; run it after any such operation.

To restore by hand:

1. Re-raise all `IPHONEOS_DEPLOYMENT_TARGET` entries to `14.0`.
2. Re-add the `CupidPhaseWidget` app-extension target with the nine
   configurations, `PRODUCT_BUNDLE_IDENTIFIER =
   com.snapsofts.cupid.CupidPhaseWidget`, `INFOPLIST_FILE =
   CupidPhaseWidget/Info.plist`, `CODE_SIGN_ENTITLEMENTS =
   CupidPhaseWidget/CupidPhaseWidget.entitlements`, `SKIP_INSTALL = YES`, and
   the Flutter xcconfig as its base configuration.
3. Re-add `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements` on all nine
   Runner configurations.
4. Re-add the Embed App Extensions phase before `Thin Binary`, and the Runner →
   `CupidPhaseWidget` target dependency.

The files under `mobile/ios/CupidPhaseWidget/` and
`mobile/ios/Runner/Runner.entitlements` are tracked in Git and survive
regeneration; only the project file needs repair.

## Verification

```bash
flutter test test/features/phase_status/
flutter build ios --debug --no-codesign --flavor local
flutter build apk --debug --flavor local
```

The iOS build is only meaningful if `CupidPhaseWidget.appex` appears under
`build/ios/iphoneos/Runner.app/PlugIns/`. The build stays green when the target
exists but is not embedded, so check the directory rather than the exit code.
