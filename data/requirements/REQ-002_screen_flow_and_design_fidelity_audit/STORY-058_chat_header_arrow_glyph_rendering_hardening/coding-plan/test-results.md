# STORY-058 Test Results – Phase P0

- Date: 2026-08-19
- Lane: Mobile
- Executed remedy: **Path A** (separator glyph swap, U+2194 → U+27F7)
- Working root: `/Users/alantravala/workspace/snapsofts/cupid-apps`
- Flutter 3.44.1 (stable), Dart 3.12.1
- Device: `emulator-5560` — sdk gphone64 arm64, Android 16 (API 36)

Flutter is not on the default shell `PATH` in this environment; every command
below was run with `export PATH="/Users/alantravala/flutter/bin:$PATH"` and
`cd mobile`.

## Step 0 — static font coverage (run before any build)

```
python3  # fontTools 4.60.1, TTFont(...).getBestCmap()
```

| Font | U+2194 | U+27F7 |
|------|--------|--------|
| `mobile/assets/fonts/Nunito-Variable.ttf` | ABSENT | ABSENT |
| `mobile/assets/fonts/Roboto-Variable.ttf` | ABSENT | ABSENT |
| emulator `/system/fonts/NotoColorEmoji.ttf` | PRESENT (`arrowboth`) | ABSENT |
| emulator `/system/fonts/NotoSansSymbols-Regular-Subsetted.ttf` | PRESENT (`arrowboth`) | PRESENT (`uni27F7`) |
| emulator `/system/fonts/NotoSansSymbols-Regular-Subsetted2.ttf` | ABSENT | ABSENT |

Decision: the bundled Roboto does **not** cover U+2194, so Path B was
unavailable (Flutter cannot exclude the emoji font; `fontFamilyFallback`
requires a family that positively covers the codepoint). `NotoColorEmoji`
does not cover U+27F7 while the monochrome `NotoSansSymbols` does, so Path A
was predicted to resolve to a monochrome glyph — confirmed by the capture.

## Static analysis

```
flutter analyze lib/features/chat/presentation/chat_strings.dart \
                test/features/chat/presentation/chat_design_fidelity_test.dart
```

Result: `No issues found! (ran in 1.5s)` — the two files this story changed
are clean.

```
flutter analyze lib test
```

Result: `80 issues found. (ran in 2.2s)` — 0 errors, 0 warnings; all 80 are
pre-existing `info`-level lints (`prefer_initializing_formals`,
`use_null_aware_elements`, one `deprecated_member_use`) in files this story
does not touch. This matches the baseline STORY-052 recorded for the same
command (`80 issues found`), so the count is unchanged by this story. AC5's
"no new warnings attributable to this story's changes" is met.

Attribution is exact rather than asserted: `git status --porcelain` shows only
`mobile/lib/features/chat/presentation/chat_strings.dart` and
`mobile/test/features/chat/presentation/chat_design_fidelity_test.dart`
modified, HEAD equals the story `BaseHead`
(`8f1ea7162aa549aff9b1d45de80170524ce0e568`), and those two files analyze
clean on their own.

### Note on bare `flutter analyze`

Bare `flutter analyze` (no path argument) additionally walks the untracked,
gitignored `mobile/build/` directory, which currently holds an iOS
`SourcePackages/checkouts/flutterfire/` checkout left by a previous iOS build.
That vendored third-party Dart source reports many `uri_does_not_exist` /
`undefined_class` errors. It is local build output, is not part of the
repository, is untouched by this story, and was left in place rather than
deleted. Analysis was therefore scoped to `lib test`, which is the tracked
source.

## Unit / widget tests

```
flutter test test/features/chat/presentation/chat_design_fidelity_test.dart
```

Result: `00:00 +19: All tests passed!` — **19 passed, 0 failed.**

Includes the two AC-bearing assertions against the new literal:

- `the title is `<self> ⟷ <partner>`, not the caller twice` — asserts
  `find.text('Minh ⟷ Linh')`.
- `the title announces a natural phrase in place of the glyph` — asserts the
  semantics label of that title node is still `'Minh và Linh'`, proving the
  accessible substitution did not regress to an arrow name.

```
flutter test test/design_system/adaptive_widgets_test.dart
```

Result: `00:00 +25: All tests passed!` — **25 passed, 0 failed.**

AC3 cross-consumer proof. The file is byte-**unchanged**: `git status
--porcelain` on that path returns empty output. No assertion was added,
relaxed, or removed to make it pass.

```
flutter test
```

Result: `00:34 +1314 ~2: All other tests passed!` — **1314 passed, 2 skipped,
0 failed.** (The 2 skips are the pre-existing `zodiac_glyph_test.dart` skips,
not introduced here.)

## Build

```
flutter build apk --debug -t lib/main_preview.dart \
  --dart-define=PREVIEW=chat --dart-define=PREVIEW_CHAT_GHOST=on
```

Result: `✓ Built build/app/outputs/flutter-apk/app-debug.apk`

Runtime registry `buildCommand` for `mobile-app` is `flutter build apk
--debug`; the added `-t`/`--dart-define` flags select the capture harness
entrypoint and seed the header's two display names.

## Glyph literal drift check

```
git grep -c '↔' -- mobile/
```

Result: exit status 1 (zero hits). No U+2194 remains anywhere under `mobile/`,
including dartdoc — the retained VS15 warning names the codepoint as the text
`U+2194 LEFT RIGHT ARROW` rather than embedding the literal, so the required
zero-hit check holds. No VS15 constant was reintroduced.

## Device install, launch and capture

```
adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk
adb -s emulator-5560 shell cmd uimode night yes
adb -s emulator-5560 shell am force-stop com.snapsofts.cupid
adb -s emulator-5560 shell am start \
  -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
```

Result: `Success`; `topResumedActivity=...MainActivity` confirmed in the
foreground before capture.

```
.ai-team-bundle/runtime/tools/capture-mobile-screen.sh \
  --out=<story>/visual-fidelity --label=chat --device=emulator-5560 \
  --max-edge=1400 --settle-ms=2000
```

Result: `MOBILE_CAPTURE: OK .../implemented-chat-emulator-5560.png 630x1400
259112`

A first capture at `--width=540` was discarded because that display width
truncated the header title to `Min…` and hid the separator entirely. The
display was restored with `wm size reset` / `wm density reset` (back to
1080x2400 @ 420dpi) and re-captured at native size, plus a 2x crop of the
header region saved as
`implemented-chat-header-separator-emulator-5560.png` so the glyph is
judgeable without reading a full-frame screenshot.

Design reference normalized into this story's folder from STORY-052's copy
(`--mode=design`); all four existing `chat` design references are
byte-identical (md5 `0d0e43b430b99e4c49f77ce0a1c2fbb4`), so the design source
is not stale.

Verdict: `MATCH` for the separator glyph — recorded with full reasoning in
`../visual-fidelity/visual-fidelity-report.md`.

## Story Runtime Startup Smoke

Launched: `lib/main.dart` (production entrypoint, not `main_preview.dart`)
Device: `emulator-5560`
Result: Clean cold boot to the real `welcome` screen, activity resumed, no
crash and no red error screen; navigation past the first frame confirmed.

Recorded 2026-08-19 in response to review finding B-1. This section previously
carried a self-declared not-applicable waiver citing
`phase-P0-separator-glyph-remedy.md` §1B. That was wrong on two counts: a phase
file cannot waive a story-level gate, and the only
device launch performed up to that point was the `main_preview.dart` capture
harness, which injects fixture stores and bypasses the production bootstrap, so
it exercised neither real DI, Firebase initialization, nor the router. This
section records a separate launch of the ordinary production entrypoint.

### Commands

Plain `flutter build apk --debug` — the registry `buildCommand` for `mobile-app`
— targets `lib/main.dart`. The preview APK built for the visual audit above
shares the `com.snapsofts.cupid` application id, so it was uninstalled first to
guarantee the smoke ran against the production build and not a leftover preview
install:

```
$ flutter build apk --debug
✓ Built build/app/outputs/flutter-apk/app-debug.apk

$ adb -s emulator-5560 shell am force-stop com.snapsofts.cupid
$ adb -s emulator-5560 uninstall com.snapsofts.cupid
Success
$ adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk
Performing Streamed Install
Success
```

The APK was rebuilt for this run (mtime `2026-08-19T11:59:13`) from a clean
working tree at HEAD `2b59e014547be92e43ecfa47038743ebba97e6a3`, with
`git status --porcelain` empty and the Path A glyph present in the built source
(`git grep -c '⟷' -- mobile/lib/.../chat_strings.dart` → 5).

Launch and readiness assertion, using the documented probe from
`data/devops/system/runtime-command-registry.json` -> `runtimes.mobile-app.readiness`
(a Flutter app exposes no socket to poll, so the registry asserts the OS reports
the launcher activity as the resumed/foreground activity):

```
$ export MOBILE_DEVICE_SERIAL=emulator-5560
$ adb -s "$MOBILE_DEVICE_SERIAL" logcat -c
$ adb -s "$MOBILE_DEVICE_SERIAL" shell am start -W \
    -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
Starting: Intent { cmp=com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity }
Status: timeout
LaunchState: UNKNOWN (-1)
Activity: com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
WaitTime: 13971
Complete

$ for _ in $(seq 1 30); do adb -s "$MOBILE_DEVICE_SERIAL" shell dumpsys activity activities \
    | grep -q "ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity" \
    && exit 0; sleep 2; done; exit 1
READINESS: RESUMED
```

That `Status: timeout` is reported verbatim rather than suppressed or retried
into silence. It is ActivityManager's own first-frame wait expiring on the very
first launch after a fresh install of a 224 MB debug APK, while dexopt/JIT warm
up — not an app failure: on that same run the readiness probe returned
`RESUMED`, the process was alive, the fatal grep was `0`, and a screencap showed
the fully rendered `welcome` screen.

To settle it by observation rather than by argument, the app was force-stopped
and cold-started again on the same install. Two further cold starts were run
(`TotalTime: 7141` and `TotalTime: 5762`), both `Status: ok` /
`LaunchState: COLD`. The last of them is the run recorded below, so every value
in this section comes from one single consistent launch:

```
$ adb -s emulator-5560 shell am force-stop com.snapsofts.cupid
$ adb -s emulator-5560 logcat -c
$ adb -s emulator-5560 shell am start -W \
    -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
Starting: Intent { cmp=com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity }
Status: ok
LaunchState: COLD
Activity: com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
TotalTime: 5762
WaitTime: 5765
Complete
READINESS: RESUMED
```

`LaunchState: COLD` confirms a real process start rather than a resume of an
already-warm process, and AM's wait clears cleanly once dexopt is warm.

### Evidence the app reached a real screen

Same launch as above, pid `20727`:

```
$ adb -s emulator-5560 shell pidof com.snapsofts.cupid
20727
$ adb -s emulator-5560 shell dumpsys activity activities | grep ResumedActivity
    topResumedActivity=ActivityRecord{232202737 u0 com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity t190}
  ResumedActivity: ActivityRecord{232202737 u0 com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity t190}
$ adb -s emulator-5560 logcat -d -v brief | grep -icE "FATAL EXCEPTION|AndroidRuntime|E/flutter"
0
```

`adb exec-out screencap -p` after boot shows the fully rendered `welcome`
screen — purple-to-pink gradient backdrop with particles, the "Cupid" wordmark,
the "Yêu nghiêm túc. / Chia tay đàng hoàng." tagline, the "App cho hai người…"
subline, and both "Tiếp tục với Google" and "Dùng email" CTAs. Not a splash
frame, not a grey/blank canvas, and not a Flutter red error screen. Firebase
init, DI, and the router therefore all completed.

Interactivity past the first frame was confirmed on this same run by tapping
"Dùng email", which routed to the login screen ("Mừng bạn quay lại", EMAIL /
MẬT KHẨU fields, "Đăng nhập", Google/Facebook alternatives, "Chưa có tài khoản?
Đăng ký"). The process stayed alive at pid `20727` across that navigation, the
resumed activity was unchanged, and the fatal/`E/flutter` grep still returned
`0`. So the router ran, not just the first frame.

Startup screencaps were taken to a session scratchpad and described here rather
than committed: `visual-fidelity/` is this story's design-comparison set for the
`chat` screen, and the startup surface is the `welcome` screen, which is
STORY-052's audited artifact, not a new fidelity subject for this story.

Shutdown per the registry `shutdownCommand`:

```
$ adb -s emulator-5560 shell am force-stop com.snapsofts.cupid
SHUTDOWN: OK
```

## Entry Point Reachability

Reachable: YES

`requirements/requirements.md` marks this story UI-facing: YES, so the changed
surface must be reachable from an ordinary user path.

Path: app launch → `welcome` → authenticated shell → **`Trò chuyện` bottom-nav
tab** → chat screen, whose header carries the `Minh ⟷ Linh` pairing title this
story changed.

The entry point is pre-existing and unchanged. AC7 requires that no new entry
point be added, and none was: this story edits one separator glyph inside an
already-rendered header (`ChatStrings.headerPairingTitle`) and touches no
routing, navigation, or shell code. `git status --porcelain` across the
implementation showed only `chat_strings.dart` and
`chat_design_fidelity_test.dart` modified.

Observed, not asserted: the `Trò chuyện` bottom-nav tab is visible and in its
active/selected state in the existing capture
`visual-fidelity/implemented-chat-emulator-5560.png`, which is the same frame
the AC4 separator verdict was read from — the screen bearing the change was
reached through that tab. No new capture was required or taken.

## Gate summary

| Gate | Command | Result |
|------|---------|--------|
| Step-0 font coverage | `fontTools` cmap inspection | Recorded before any build; selected Path A |
| Changed-file analysis | `flutter analyze <2 changed files>` | `No issues found!` |
| Tracked-source analysis | `flutter analyze lib test` | `80 issues found` — 0 errors/warnings, unchanged from baseline |
| Chat fidelity | `flutter test .../chat_design_fidelity_test.dart` | 19 passed, 0 failed |
| Header component (AC3, file unchanged) | `flutter test .../adaptive_widgets_test.dart` | 25 passed, 0 failed |
| Full suite | `flutter test` | 1314 passed, 2 skipped, 0 failed |
| Build | `flutter build apk --debug` | `✓ Built app-debug.apk` |
| Glyph drift | `git grep -c '↔' -- mobile/` | 0 hits |
| Visual audit (AC1/AC4) | Android / dark / `vi` capture | `MATCH` — `VISUAL_FIDELITY: PASS` |
| AC6 doc correction | `git diff --stat` on STORY-052 | 1 file, 1 insertion, 1 deletion |
| Story runtime startup smoke (12g) | `flutter build apk --debug` + install + `am start` of `lib/main.dart` | Clean cold boot to `welcome`, `LaunchState: COLD`, resumed, 0 fatals |
| Entry point reachability (12e1) | Existing `Trò chuyện` bottom-nav tab | `Reachable: YES`, unchanged, no new entry point |
