---
story: STORY-004_home_header_share_days_action
requirement: REQ-010_home_dashboard_deferred_scope_completion
phase: P0
written_by: mobile-dev
written_at: 2026-08-25
---

Result: PASS

All commands below were run in the story worktree
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-010_home_dashboard_deferred_scope_completion-STORY-004`,
from `mobile/`, with `PATH="${FLUTTER_SDK_PATH:-$HOME/flutter}/bin:$PATH"`
(the Flutter SDK is not on the default PATH on this machine).

## Resolved share dependency

Phase §5 requires the resolved version and the source the call signature came from
to be recorded, because guessing a `share_plus` API from memory is the specific
failure mode this story was scoped against.

| Field | Value |
| --- | --- |
| Package | `share_plus` |
| Resolved version | **13.3.0** |
| Added by | `flutter pub add share_plus` (recorded in `mobile/pubspec.yaml` + `mobile/pubspec.lock`) |
| Transitives added | `share_plus_platform_interface 7.2.0`, `url_launcher_linux`, `url_launcher_platform_interface`, `url_launcher_web`, `url_launcher_windows` |
| Dart SDK constraint | package requires `>=3.10.0 <4.0.0`; this app pins `^3.12.1` — compatible, so `SHARE_PACKAGE_UNRESOLVED` does **not** apply |
| Call signature source | `~/.pub-cache/hosted/pub.dev/share_plus-13.3.0/README.md` §"Share Text" and `~/.pub-cache/hosted/pub.dev/share_plus-13.3.0/lib/share_plus.dart` — both read directly, not recalled |
| API used | `SharePlus.instance.share(ShareParams(text: ..., sharePositionOrigin: ...))` |
| API deliberately NOT used | the static `Share.share(String)` / `Share.shareUri` / `Share.shareXFiles` — all carry `@Deprecated('Use SharePlus.instance.share() instead')` in `lib/share_plus.dart:106-244` of this version |
| `sharePositionOrigin` | supplied from `context.findRenderObject()`; per the README's "iPad" section it is optional in 13.3.0 (the popover falls back to screen centre rather than crashing), but an accurate origin is still recommended, so it is passed |
| Platform channel | `dev.fluttercommunity.plus/share`, method `'share'`, args map keys `text`/`subject`/`title`/`uri`/`originX..originHeight`/`paths`/`mimeTypes`; return `''` maps to `ShareResultStatus.dismissed` — read from `share_plus_platform_interface-7.2.0/lib/method_channel/method_channel_share.dart:19-31,41-53,155-164` |

No Android manifest or iOS `Info.plist` entry was added: the resolved package's own
README lists none as required for plain-text sharing. `mobile/android/app/src/main/AndroidManifest.xml`
and `mobile/ios/Runner/Info.plist` are therefore unmodified, matching the write-scope
condition ("only if the resolved package's own README requires").

## Static analysis

```
flutter analyze lib/features/home test/features/home
```

```
Analyzing 2 items...
No issues found! (ran in 2.0s)
```

Note on the whole-package run: bare `flutter analyze` over `mobile/` exits 1 with
several hundred errors, **all** of them inside
`mobile/build/ios/SourcePackages/checkouts/flutterfire/**` — pre-existing iOS build
artifacts checked out by CocoaPods/SwiftPM, not source in this repository, and not
touched by this story. `flutter analyze lib test` reports 75 issues, all `info`
severity, all in unrelated pre-existing files, and **zero** in any home file. The
phase §6 gate ("`flutter analyze` clean on `home_screen.dart`") is met:

```
flutter analyze lib/features/home/presentation/home_screen.dart
No issues found! (ran in 7.7s)
```

## Widget tests

```
flutter test test/features/home/
```

```
00:01 +20: All tests passed!
```

20 tests, 0 failures. The 13 pre-existing tests in this directory (Dream Jar card,
no-AppBar/AC5, presence signal, Gallery entry card, timeline entry point ×5, days
counter) all still pass unchanged — the phase §6 regression requirement.

The 7 tests added by this phase:

| # | Test | Asserts |
| --- | --- | --- |
| 1 | AC1: header share action renders with the §1 tokens and the Material `share` glyph | key `home_header_share_action` present and a descendant of `home_couple_hero`; `icon == CupidIcons.share`; `size == 23`; `fill == 0` (line variant); `color == Color(0xFFB4A6CE)`; box `48 x 38` |
| 2 | AC1: the iOS platform branch renders the `ios_share` glyph | under `CupidPlatformOverride(platform: CupidPlatform.ios)`, `icon == CupidIcons.iosShare` |
| 3 | AC1: `_PresenceRow` keeps its leading position once the actions row is added | `getTopLeft(find.text('Minh')).dx < getTopLeft(shareKey).dx` |
| 4 | AC2: tapping opens the OS share sheet with the §2 `vi` payload | `calls.single['text'] == '247 ngày bên nhau rồi 💕'`; `subject`/`uri`/`paths` all null |
| 5 | AC2: the payload follows the active locale | under `Locale('en')`, `calls.single['text'] == '247 days together 💕'` |
| 6 | AC3: dismissing the sheet surfaces no error or snackbar | after tap + `pumpAndSettle`, no `SnackBar`; counter and share action still present |
| 7 | no start date means nothing to share | profile without `relationshipStartDate` → share key `findsNothing` |

Phase §6 requires the share-tap test to assert the **composed payload string**, not
merely that a handler fired. Tests 4 and 5 do exactly that by installing a mock
handler on the plugin's real `MethodChannel('dev.fluttercommunity.plus/share')` via
`tester.binding.defaultBinaryMessenger.setMockMethodCallHandler` and capturing the
arguments map the plugin actually sends. This asserts the string end-to-end through
the production `SharePlus` call path, and required **no** test-injection API on
`HomeScreen`. The same handler answers `''`, which
`MethodChannelShare._statusFromResult` maps to `ShareResultStatus.dismissed`, so
test 6 exercises the real AC3 dismissal path rather than a simulated one.

## Build gate

```
flutter build apk --debug
```

```
Running Gradle task 'assembleLocalDebug'...                        13.7s
✓ Built build/app/outputs/flutter-apk/app-local-debug.apk
```

This is the load-bearing gate for this story: `share_plus` is the app's **first**
native-share plugin, so a successful Gradle assemble proves the new Android plugin
registers and the manifest merge is clean. (The first, cold run of the same command
took 71.9s; the 13.7s figure above is the warm re-run.)

## Story Runtime Startup Smoke

Scoped to the impacted app (the Flutter mobile app); no backend or web service was
started.

```
flutter build apk --debug -t lib/main_preview.dart \
  --dart-define=PREVIEW=home --dart-define=PREVIEW_HOME_FIXTURE=true
```

```
Running Gradle task 'assembleLocalDebug'...                        15.9s
✓ Built build/app/outputs/flutter-apk/app-local-debug.apk
```

```
adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-local-debug.apk
adb -s emulator-5554 shell am force-stop com.snapsofts.cupid
adb -s emulator-5554 shell monkey -p com.snapsofts.cupid -c android.intent.category.LAUNCHER 1
```

```
Performing Streamed Install
Success
Events injected: 1
```

Result: PASS — the app cold-starts on `emulator-5554` (sdk gphone64 arm64, Android 16
/ API 36, already running; no device was created, booted, wiped or repaired) and
renders the Home dashboard with the header share action visible. No plugin
registration failure, no missing-plugin exception, no crash.

Entry Point Reachability: REACHABLE — `home` is a registered `main_preview.dart`
screen (`previewScreens['home']`, `wrapInShell: true`) and `PREVIEW_HOME_FIXTURE=true`
seeds a paired profile with `relationshipStartDate` = today − 247d, so the
`days != null` branch that gates the share action is the branch that rendered.

## Visual-fidelity capture

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=mobile \
  --entry="Cupid App.dc.html" --location=<worktree>/cupid-app-design-system \
  --screen=home --platform=android --theme=dark --lang=vi \
  --out=<story>/visual-fidelity
```

```
DESIGN_CANVAS: OK .../visual-fidelity/design-reference-home-android.png 406x900
```

```
.ai-team-bundle/runtime/tools/capture-mobile-screen.sh --device=emulator-5554 \
  --lease-exec -- <install + launch + capture>
```

```
MOBILE_CAPTURE: OK .../visual-fidelity/implemented-home-emulator-5554.png 405x900 152814
```

Renamed to `implemented-home-android.png` so the implemented and design artifacts
carry the same `<screen>-<device>` suffix, matching the REQ-009 precedent. A second,
un-downscaled 1080x2400 capture of the same frame was taken to a scratch path for
pixel measurement only and is not part of the delivered evidence.

Verdict recorded in
`visual-fidelity/visual-fidelity-report.md` → `VISUAL_FIDELITY: PASS`, with two
specified deviations (V1 accessibility tap-target inset, V2 STORY-005 bell absent).

## Acceptance Criteria coverage

Quoting phase §4 verbatim, in order:

| Phase §4 criterion | Evidence |
| --- | --- |
| "A share icon renders in the Home hero header at the §1 position, size, glyph, and colour, on both platform branches, in dark theme + `vi` locale (AC1)." | tests 1 and 2 (Material and iOS glyph branches, `vi` host locale); visual-fidelity report "Comparison" table — glyph identity, ink box 16.8x18.3dp, `#B4A6CE`, vertical centring Δ0.19dp, flush right inset, captured android/dark/vi |
| "Tapping it invokes the native share sheet with exactly the §2 text for the currently displayed day count, in the active locale (AC2)." | tests 4 and 5, asserting the exact payload map sent on the real plugin channel, in `vi` and `en` |
| "The share icon does not render when `relationshipStartDate` is null." | test 7 |
| "Dismissing the sheet produces no error state, snackbar, or crash (AC3)." | test 6, driven through the real `'' → ShareResultStatus.dismissed` mapping; `_ShareDaysAction._share` deliberately does not inspect the returned `ShareResult` |
| "`_PresenceRow` keeps its existing appearance and position; existing Home tests still pass." | test 3 (presence row still leads the row, left of the share action); all 13 pre-existing tests in `test/features/home/` pass unchanged (20/20 total) |

Phase §3 Task 3's structural requirement — "Structure the actions row so STORY-005
can append a second icon as a sibling with a `2`px gap without touching the share
subtree" — is satisfied by `_HeaderActionsRow(actions: List<Widget>)`, which
gap-joins its children with `_headerActionGap`. Recorded as V2 in the
visual-fidelity report.

## Blockers

None. `SHARE_PACKAGE_UNRESOLVED` does not apply — `share_plus 13.3.0` resolved
cleanly against the app's `^3.12.1` Dart SDK constraint, and no clipboard-copy
substitute was introduced.
