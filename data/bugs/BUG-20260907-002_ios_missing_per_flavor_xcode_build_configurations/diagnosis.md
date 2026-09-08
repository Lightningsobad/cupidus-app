# Diagnosis: BUG-20260907-002 iOS Missing Per-Flavor Xcode Build Configurations

Bug Id: BUG-20260907-002
Scope Classification: mobile (iOS build tooling / Xcode project configuration)
Input Anchors:
- `flutter build ios --debug --no-codesign` -> "You must specify a --flavor option to select one of the available schemes."
- `flutter build ios --debug --no-codesign --flavor Runner` -> "The Xcode project defines build configurations: Debug, Release, Profile / Flutter expects a build configuration named Debug-Runner or similar."
- `xcodebuild -list -project mobile/ios/Runner.xcodeproj` -> Build Configurations: Debug, Release, Profile

## Pre-Fix Reproduction Gate

Original failure anchor:
`flutter build ios --debug --no-codesign` exits non-zero before any Swift is
compiled, during Flutter's Xcode project inspection.

Reproduction method and modality:
Same modality as the report - direct CLI execution of the reported build
commands from `mobile/`, plus the reported `xcodebuild -list` inspection.

Exact commands:
```
cd /Users/alantravala/workspace/snapsofts/cupid-apps/mobile && PATH="$HOME/flutter/bin:$PATH" flutter build ios --debug --no-codesign
cd /Users/alantravala/workspace/snapsofts/cupid-apps/mobile && PATH="$HOME/flutter/bin:$PATH" flutter build ios --debug --no-codesign --flavor Runner
xcodebuild -list -project /Users/alantravala/workspace/snapsofts/cupid-apps/mobile/ios/Runner.xcodeproj
```

Expected failure:
Non-zero exit with the two flavor/build-configuration errors quoted in
`bug_master.md`.

Actual result (unflavored run, exit 1):
```
The Xcode project defines schemes: firebase-auth, firebase-core,
firebase-messaging, flutter-facebook-auth, flutter-secure-storage-darwin,
FlutterFramework, FlutterGeneratedPluginSwiftPackage, google-sign-in-ios,
image-picker-ios, mobile-scanner, permission-handler-apple, Runner, share-plus,
shared-preferences-foundation, sign-in-with-apple, sqflite-darwin,
sqlite3-flutter-libs
You must specify a --flavor option to select one of the available schemes.
```

Actual result (`--flavor Runner` run, exit 1):
```
The Xcode project defines build configurations: Debug, Release, Profile
Flutter expects a build configuration named Debug-Runner or similar.
```

Actual result (`xcodebuild -list`):
```
Targets: Runner, RunnerTests
Build Configurations: Debug, Release, Profile
Schemes: firebase-auth, firebase-core, firebase-messaging,
flutter-facebook-auth, flutter-secure-storage-darwin, FlutterFramework,
FlutterGeneratedPluginSwiftPackage, google-sign-in-ios, image-picker-ios,
mobile-scanner, permission-handler-apple, Runner, share-plus,
shared-preferences-foundation, sign-in-with-apple, sqflite-darwin,
sqlite3-flutter-libs
```

Environment: Xcode 26.2 (17C52), Flutter SDK at `~/flutter`.

Result: REPRODUCED
Blocker type: N/A

## Context Ledger

Anchors used: the two failing build commands, the `xcodebuild -list` scheme and
build-configuration listing, and the emitted Flutter tool error strings.

Files/ranges inspected: recorded in the Root Cause section below. No large-file
full reads were required beyond `bug_master.md` (small).

## Root Cause

The iOS project had no flavor dimension at all, while Android does.

- `mobile/android/app/build.gradle.kts` (lines 36-53) declares
  `flavorDimensions += "backend"` with `productFlavors { create("local"); create("prod") }`.
  The two flavors differ only by name (no `applicationIdSuffix`, no
  version suffix).
- `mobile/ios/Runner.xcodeproj/project.pbxproj` (pre-fix) declared exactly
  three build configurations - `Debug`, `Release`, `Profile` - across all three
  `XCConfigurationList` objects, and `xcshareddata/xcschemes/` contained only
  `Runner.xcscheme`. There was no `Debug-<flavor>` configuration and no
  per-flavor scheme for any flavor.

Why the unflavored invocation also failed (not just the flavored one): the iOS
host app resolves its Flutter plugins through Swift Package Manager, so
`xcodebuild -list` reports 16 SPM package schemes alongside `Runner` (17 total,
quoted in the reproduction gate above). Flutter's
`XcodeProjectInfo.definesCustomSchemes`
(`packages/flutter_tools/lib/src/ios/xcodeproj.dart:676`) is
`!(schemes.contains('Runner') && schemes.length == 1)`, so with the SPM schemes
present the tool classifies the project as scheme-customised and takes the
flavored resolution path.

Exact failing frame, captured from a `--verbose` run against the unpatched
project:

```
#1  XcodeProjectInfo.reportFlavorNotFoundAndExit (package:flutter_tools/src/ios/xcodeproj.dart:721:7)
#2  XcodeBasedProject.buildSettingsForBuildInfo (package:flutter_tools/src/xcode_project.dart:288:12)
#3  IosProject._parseProductName (package:flutter_tools/src/xcode_project.dart:888:55)
#4  IosProject.productName (package:flutter_tools/src/xcode_project.dart:876:29)
#5  BuildableIOSApp.fromProject (package:flutter_tools/src/ios/application_package.dart:118:33)
#6  _BuildIOSSubCommand.runCommand (package:flutter_tools/src/commands/build_ios.dart:978:44)
```

`xcode_project.dart:286-289` is:

```dart
scheme ??= info.schemeFor(buildInfo);
if (scheme == null) {
  info.reportFlavorNotFoundAndExit();
}
```

So scheme/configuration resolution for the host app dead-ended for every
invocation shape: unflavored hit `reportFlavorNotFoundAndExit` at
`xcodeproj.dart:721`, and `--flavor Runner` got past scheme selection but then
failed `buildConfigurationFor`, because no `Debug-Runner` configuration existed.
Both messages in the report are two exits from the same missing-flavor-dimension
cause, not two independent defects.

Root cause family: iOS build-tooling configuration gap - Android/iOS flavor
parity was never established in `project.pbxproj` or the shared scheme set.

## Cluster Boundary

In scope for this bug: the missing per-flavor Xcode build configurations and
shared schemes in `mobile/ios/Runner.xcodeproj`, plus a regression guard that
holds Android and iOS flavor sets in parity.

Explicitly out of scope (separate root-cause family, already tracked):
`BUG-20260907-001_mobile_repo_wide_preexisting_test_failures` covers
`flutter test` unit/widget failures. Nothing in this fix touches Dart product
code or those suites.

Also out of scope: per-flavor value differentiation (distinct bundle ids, API
base URLs, display names, or entitlements per flavor). Android's own `local`
and `prod` flavors are value-identical today, so introducing iOS-only
differentiation would be new product scope, not a fix. The new configurations
deliberately mirror that: exact clones of their base configuration with only
`name` changed.

## Risk Surfaces

- `project.pbxproj` is a machine-generated plist; a malformed edit breaks every
  Xcode operation. Mitigated by `plutil -lint` plus `xcodebuild -list` and three
  real builds.
- The new configuration names embed the build mode as a prefix
  (`Debug-local`, `Release-prod`, ...). Flutter's `xcode_backend` derives the
  build mode by case-insensitive substring match on `CONFIGURATION`, so the
  prefix form is required; a `local-Debug` form would silently mis-detect mode.
- Schemes are named lowercase (`local`, `prod`) to match the Android flavor
  ids. Flutter's `schemeFor` falls back to a case-insensitive unique match
  (`xcodeproj.dart:712-714`), so `--flavor local` resolves the `local` scheme.
- Adding schemes to `xcshareddata` makes them visible to every Xcode user and
  to CI. `git check-ignore` returns exit 1 for both new scheme files, so they
  are tracked, not ignored.

## Scope Classification

Single-cluster mobile iOS build configuration fix. 4 files touched, well inside
the 12-file budget. No story worktree was entered; all edits are in the control
checkout on `main`.
