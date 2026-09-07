# Fix Evidence: BUG-20260907-002 iOS Missing Per-Flavor Xcode Build Configurations

Bug Id: BUG-20260907-002
BUG_FIX_COMPLETE: YES
Fixed By: Justin-BugFixer (bug-fixer), Mode `fix-bug`
Date: 2026-09-07
Diagnosis: `data/bugs/BUG-20260907-002_ios_missing_per_flavor_xcode_build_configurations/diagnosis.md`

## Fix Summary

Gave the iOS project the flavor dimension Android already had, so Flutter can
resolve a scheme and a build configuration for `local` and `prod`.

Chosen direction: option (a) from `bug_master.md` "Expected behavior"
(per-flavor configurations matching Android `local`/`prod`), not option (b)
(make iOS unflavored). Android genuinely declares `local` and `prod` product
flavors, so removing the iOS flavor dimension would have made the two platforms
diverge instead of converge.

## Files Changed

1. `mobile/ios/Runner.xcodeproj/project.pbxproj` (modified)
   - Added 18 `XCBuildConfiguration` objects: `Debug-local`, `Debug-prod`,
     `Release-local`, `Release-prod`, `Profile-local`, `Profile-prod` for each
     of the three configuration lists (project, `Runner` target,
     `RunnerTests` target).
   - Each new object is an exact clone of its base configuration (`Debug`,
     `Release`, or `Profile`) with only `name` changed, preserving
     `baseConfigurationReference` (`Debug.xcconfig` for `Debug-*`,
     `Release.xcconfig` for `Release-*` and `Profile-*`).
   - Registered all 18 in the `buildConfigurations` arrays of
     `97C146E91CF9000F007C117D` (project),
     `97C147051CF9000F007C117D` (Runner), and
     `331C8087294A63A400263BE5` (RunnerTests).
   - `defaultConfigurationName` left at `Release` on all three lists; no
     existing object was modified or removed.
2. `mobile/ios/Runner.xcodeproj/xcshareddata/xcschemes/local.xcscheme` (new)
   - Clone of `Runner.xcscheme`, preserving the "Run Prepare Flutter Framework
     Script" PreAction, the `Runner.app` / `RunnerTests.xctest` blueprint
     references, and `customLLDBInitFile`. Test/Launch/Analyze use
     `Debug-local`, Profile uses `Profile-local`, Archive uses `Release-local`.
3. `mobile/ios/Runner.xcodeproj/xcshareddata/xcschemes/prod.xcscheme` (new)
   - Same, with the `-prod` configurations.
4. `mobile/test/tooling/ios_android_flavor_parity_test.dart` (new)
   - Regression guard, see Regression Coverage below.

`Runner.xcscheme` was left untouched, so unflavored/IDE workflows keep working.
Total: 4 files, within the 12-file budget. No file inside the REQ-016/STORY-003
worktree or branch was read or written.

## Original Failure Recheck Gate

Same modality as original: YES - the same `flutter build ios` CLI invocations
from `mobile/` that the reporter ran, executed unpiped and in full.

Recheck commands and results (run after the patch was restored following the
A/B control below):

```
cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter build ios --debug --no-codesign --no-pub
  -> Xcode build done. 90.5s / Built build/ios/iphoneos/Runner.app / exit 0
cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter build ios --debug --no-codesign --flavor local --no-pub
  -> Xcode build done. 17.7s / Built build/ios/iphoneos/Runner.app / exit 0
cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter build ios --debug --no-codesign --flavor prod --no-pub
  -> Xcode build done. 39.4s / Built build/ios/iphoneos/Runner.app / exit 0
```

Both reported error strings are gone: neither "You must specify a --flavor
option to select one of the available schemes." nor "Flutter expects a build
configuration named Debug-Runner or similar." appears in any run.

`bug_master.md` asked for flavored builds to pass OR for iOS to stop requiring
`--flavor`. Both now hold, which is strictly stronger than the OR condition.

Result: PASS

### A/B control (proves the patch, not the environment, is the cause)

Because the unflavored build unexpectedly started passing too, causality was
verified rather than assumed:

1. Backed the patched files up to `/tmp/bugfix-002-backup/`.
2. `git checkout -- mobile/ios/Runner.xcodeproj/project.pbxproj` and moved
   `local.xcscheme` / `prod.xcscheme` aside.
3. Re-ran the unflavored build: still failed with the identical original error,
   and `--verbose` produced the stack quoted in `diagnosis.md`.
4. Restored the patched files and confirmed byte-identity with `diff -q`
   ("PATCH_RESTORED_AND_VERIFIED"), then ran the three rechecks above.

Baseline fails, patched passes, same machine and same session.

## Regression Coverage

`mobile/test/tooling/ios_android_flavor_parity_test.dart` reads the Android
product flavors out of `android/app/build.gradle.kts` and asserts, for every
flavor found, that `project.pbxproj` contains `Debug-<flavor>`,
`Release-<flavor>`, and `Profile-<flavor>` build configurations and that
`xcshareddata/xcschemes/<flavor>.xcscheme` exists. It is parity-driven, so
adding a future Android flavor without the iOS side fails the test instead of
silently reintroducing this bug.

```
cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter test test/tooling/ios_android_flavor_parity_test.dart
  -> 00:00 +3: All tests passed! / exit 0
```

Negative control (proves the guard is not a no-op): with
`local.xcscheme` temporarily moved aside, the same run fails with
`ios/Runner.xcodeproj/xcshareddata/xcschemes/local.xcscheme is missing`,
exit 1; after restoring the file it passes again, exit 0.

## Build Gate

Narrowest project-appropriate commands for the touched surface (the iOS build
pipeline of the `mobile-app` runtime), run unpiped:

```
plutil -lint mobile/ios/Runner.xcodeproj/project.pbxproj
  -> OK

xcodebuild -list -project mobile/ios/Runner.xcodeproj
  -> Build Configurations: Debug, Release, Profile, Debug-local, Debug-prod,
     Release-local, Release-prod, Profile-local, Profile-prod
  -> Schemes now include: local, prod, Runner

cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter build ios --debug --simulator --flavor local --no-pub
  -> Xcode build done. 143.3s / Built build/ios/iphonesimulator/Runner.app / exit 0

cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter test test/tooling/ios_android_flavor_parity_test.dart
  -> All tests passed / exit 0
```

Plus the three device builds in the Original Failure Recheck Gate, all exit 0.

Result: PASS

## Runtime Startup Gate

Runtime Id: `mobile-app`
Registry path: `data/devops/system/runtime-command-registry.json`
Applicability: applies - `mobile-app` is the runtime whose iOS build path this
bug broke. Its `launch.subcommands.ios` boots a simulator via `xcrun simctl`,
and `readiness.iosCommand` is the registry-defined readiness probe.

Registry `launch.path` is `scripts/run-mobile.sh` with `interactive: true` and
`ciSafe: false`, so its non-interactive `simctl` equivalent was executed
directly and the registry `readiness.iosCommand` was run verbatim.

Commands:

```
xcrun simctl boot DE4B4E1A-2653-440B-A41A-0ED8DA27BE56   # iPhone 17, iOS 26.3
xcrun simctl bootstatus DE4B4E1A-2653-440B-A41A-0ED8DA27BE56   -> Finished, exit 0
cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter build ios --debug --simulator --flavor local --no-pub
  -> Built build/ios/iphonesimulator/Runner.app, exit 0
xcrun simctl install DE4B4E1A-2653-440B-A41A-0ED8DA27BE56 build/ios/iphonesimulator/Runner.app
  -> exit 0
```

Ready check (registry `readiness.iosCommand`, verbatim, `timeoutSecs: 90`,
`applicationId: com.snapsofts.cupid`):

```
xcrun simctl launch "$MOBILE_DEVICE_UDID" com.snapsofts.cupid && \
  for _ in $(seq 1 30); do \
    xcrun simctl spawn "$MOBILE_DEVICE_UDID" launchctl list | grep -q com.snapsofts.cupid && exit 0; \
    sleep 2; \
  done; exit 1
  -> com.snapsofts.cupid: 80412
  -> READINESS_EXIT=0
```

Visual confirmation that the flavored build actually reaches first frame, not
just a live process:
`data/bugs/BUG-20260907-002_ios_missing_per_flavor_xcode_build_configurations/evidence/ios-runtime-startup-local-flavor.png`
shows the Cupid onboarding screen rendered in Vietnamese with the DEBUG banner
and the "Tiep tuc voi Apple" / "Tiep tuc voi Google" / "Dung email" actions.

Shutdown:

```
xcrun simctl terminate DE4B4E1A-2653-440B-A41A-0ED8DA27BE56 com.snapsofts.cupid  -> exit 0
xcrun simctl shutdown DE4B4E1A-2653-440B-A41A-0ED8DA27BE56                        -> exit 0
```

Result: PASS

## Residual Risks

- `Debug-local` / `Debug-prod` are currently byte-identical to `Debug` apart
  from `name`, so the flavors carry no behavioral difference yet. That matches
  Android, where `local` and `prod` are also value-identical today. Actual
  per-flavor values (API base URL, bundle id suffix, display name) are product
  scope for a future story, not part of this fix.
- Xcode may reorder or rewrite `project.pbxproj` if a developer edits build
  settings through the IDE. The parity test catches an accidental drop of the
  configurations; it does not pin their exact ordering, deliberately.
- The `RunnerTests` target received the same six configurations for
  consistency; no test scheme currently selects them.
- Not verified: release/archive signing with the new configurations
  (`--no-codesign` was used throughout, matching the reported command). Archive
  actions point at `Release-<flavor>`, which inherits `Release.xcconfig`
  unchanged, so no signing behavior was altered.

## Reviewer Handoff Recommendation

Ready for bugfix review. Suggested report path:
`data/bugs/BUG-20260907-002_ios_missing_per_flavor_xcode_build_configurations/review/review-report.md`

Review focus:
- `project.pbxproj` structural integrity and that no pre-existing object was
  mutated (only additions plus `buildConfigurations` array entries).
- Scheme configuration mapping (`Debug-*` for run/test/analyze, `Profile-*` for
  profile, `Release-*` for archive).
- That the fix deliberately does not introduce per-flavor value differences.
