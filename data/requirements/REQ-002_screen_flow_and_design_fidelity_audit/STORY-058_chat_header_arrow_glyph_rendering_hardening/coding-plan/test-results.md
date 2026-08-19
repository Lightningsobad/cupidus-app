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

NOT_APPLICABLE for this phase, by the phase's own test scope
(`phase-P0-separator-glyph-remedy.md` §1B: "Startup Smoke: NOT_APPLICABLE
(device work is the visual audit in section 6)"). The AC1/AC4 gate for this
story is the requirement mobile visual audit above, which is a device
build/install/launch/capture cycle on the harness entrypoint, not a
production-bootstrap smoke.

This story changes one string literal inside an already-rendered header and
touches no DI, bootstrap, routing, Firebase, or platform-channel code, so
there is no startup surface for it to regress. STORY-052's production
`lib/main.dart` cold-boot smoke remains the current evidence for that surface
and is unaffected by this change.

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
| Visual audit (AC1/AC4) | Android / dark / `vi` capture | `MATCH` |
| AC6 doc correction | `git diff --stat` on STORY-052 | 1 file, 1 insertion, 1 deletion |
