# Fix Evidence: BUG-20260825-001 home_screen_design_mismatch

BUG_FIX_COMPLETE: NO
Outcome: `ESCALATE_TO_BACKLOG`

## Summary

The report reproduced on a real rendered screen and its cause is established:
the Home dashboard's remaining divergences from the design source are the
feature cards, header actions and screen backdrop that
`REQ-002 / STORY-017_home_dashboard_design_fidelity` explicitly declared **out
of its comparison region** (review finding `B5`, `CLOSED by scrum-master`) and
recorded as deferrals `F2`, `F3`, `F4`, `F6`, `F10`. Every element that story
*did* own (`R1`–`R7`: presence row, days counter, caption, milestone pill, card
rhythm, tab-bar styling, hero glow) still matches the design in this round's
capture. Nothing regressed, so no patch was applied.

Full analysis:
`data/bugs/BUG-20260825-001_home_screen_design_mismatch/diagnosis.md`.

## Files Changed

None. No source or test file was modified.

New evidence artifacts:
- `data/bugs/BUG-20260825-001_home_screen_design_mismatch/evidence/design/design-reference-home-android.png`
- `data/bugs/BUG-20260825-001_home_screen_design_mismatch/evidence/implemented-home-emulator-5554.png`
- `data/bugs/BUG-20260825-001_home_screen_design_mismatch/evidence/implemented-real-entrypoint-emulator-5554.png`

## Regression Test

Not added. There is no defect to guard: the screen matches its own approved
delivery decision, and the missing surfaces have no agreed target behaviour in
this codebase yet. Coverage belongs to the backlog stories that build them.

## Commands Run

| Command | Result |
| --- | --- |
| `node .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=cupid-app --list-screens` | 38 screen ids incl. `home` |
| `node .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=cupid-app --screen=home --platform=android --out=<evidence>/design` | `DESIGN_CANVAS: OK design-reference-home-android.png 406x900` |
| `cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter build apk --debug --target=lib/main_preview.dart --dart-define=PREVIEW=home` | `✓ Built app-local-debug.apk` (harness missing the fixture define — discarded) |
| `cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter build apk --debug --target=lib/main_preview.dart --dart-define=PREVIEW=home --dart-define=PREVIEW_HOME_FIXTURE=true` | `✓ Built app-local-debug.apk` |
| `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-local-debug.apk` | `Success` |
| `capture-mobile-screen.sh --out=<evidence> --label=home --device=emulator-5554 --platform=android --route="cupidpreview://screen/home" --settle-ms=5000 --max-edge=900` | `MOBILE_CAPTURE: OK implemented-home-emulator-5554.png 405x900` |
| `cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter build apk --debug` | `✓ Built app-local-debug.apk` |
| `adb -s emulator-5554 shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` | `Status: ok`, `LaunchState: COLD`, `TotalTime: 5200`, `Complete` |
| `adb -s emulator-5554 shell dumpsys activity activities` | `ResumedActivity: ... MainActivity` |
| `adb -s emulator-5554 shell pidof com.snapsofts.cupid` | `6095` |
| `adb -s emulator-5554 logcat -b crash -d -t 40` | 0 lines matching `com.snapsofts.cupid` |
| `adb -s emulator-5554 shell am force-stop com.snapsofts.cupid` | process gone (`pidof` exit 1) |
| `git log --oneline` on `home_screen.dart` and the three dashboard card widgets | no commit ever removed the hero block; the cards were authored as generic entry rows in `REQ-001` and never redesigned |

## Touched Risk Surfaces And Selected Minimum Gates

Risk surfaces a fix *would* touch: mobile feature UI across `anti_ghosting/`,
`vibes/`, `pet/`, the alarm/zodiac features, and the global theme
(`cupid_theme.dart`). Because no patch was applied, the minimum gate selected
for this run was the same-modality rendered reproduction, plus the build and
runtime-startup gates as tree-health evidence.

## Pre-Fix Reproduction Gate

Recorded in `diagnosis.md` → `## Pre-Fix Reproduction Gate`.
Modality: rendered Android emulator capture compared against the rendered
locked design source — the same modality as the report.
Result: REPRODUCED

Harness correction: the first capture omitted
`--dart-define=PREVIEW_HOME_FIXTURE=true` and therefore hid the hero header.
That render is a harness artefact and is documented and withdrawn in
`diagnosis.md`; the stored capture is the corrected, fixture-backed one.

## Original Failure Recheck Gate

Not applicable and intentionally absent: no patch was applied, so there is
nothing to recheck. `BUG_FIX_COMPLETE: YES` is therefore not claimed.

## Build Gate

Command: `cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter build apk --debug`
Result: PASS (`✓ Built build/app/outputs/flutter-apk/app-local-debug.apk`)

Recorded as supporting evidence that the impacted runtime builds on the current
tree. It does not substitute for a fix and is not offered as a completion gate.

## Runtime Startup Gate

Runtime Id: `mobile-app`
Registry: `data/devops/system/runtime-command-registry.json`
Command: `adb -s emulator-5554 shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
Ready Check: launcher activity reported as the resumed foreground activity on
`emulator-5554`, live pid, and an empty `logcat -b crash` for the package
Result: PASS (`Status: ok`, `LaunchState: COLD`, `Complete`; `ResumedActivity`
is `MainActivity`; `pidof` returned `6095`; 0 crash-log lines)
Shutdown: PASS (`adb -s emulator-5554 shell am force-stop com.snapsofts.cupid`;
`pidof` then exits 1 with no output)

The emulator itself was already running before this run and was left running.
The device display was never resized: `wm size` remains `1080x2400` and
`wm density` remains `420`.

## Recommended Backlog Scope

Suggested stories, in the order that would move the screen most:

1. Home dashboard feature cards — vibe two-tile card, Bún pet card
   (sprite/level/progress), and the anti-ghost alert banner. Closes `F3`/`F6`
   and is the single largest visual gap.
2. Home dashboard 2-column quick grid (`Synced Alarm`, `Zodiac Red Flag`, …).
   Depends on `STORY-023 Zodiac Red Flag`, currently `DEFERRED`.
3. Header share / notification actions — blocked until their target routes
   exist (`F3`).
4. Partner display name and the `Minh & Linh` couple title (`F4`) — needs a
   partner-profile API, i.e. a backend story first.
5. `--sky` global screen backdrop (`F10`) — a theme change affecting all 37
   screens, so it should be its own story with its own re-capture sweep.

## Remaining Risks / Unrelated Findings

- `PetPreviewCard` renders `Không thể tải Bún` under the preview harness
  because the harness has no authenticated backend. This is a capture-state
  gap, not a rendering defect; a follow-up story building the pet card should
  add a `PREVIEW_PET_FIXTURE`-style define, mirroring `PREVIEW_HOME_FIXTURE`.
- `main_preview.dart`'s `home` entry needs `PREVIEW_HOME_FIXTURE=true` to show
  the design's state, and this is easy to miss — it cost one full
  build/install/capture cycle in this run. Whoever takes the backlog stories
  above should read `STORY-017`'s visual-fidelity report §1 before capturing.
- The real entrypoint on an unauthenticated device lands on the pairing-choice
  screen, so Home is not reachable without a live paired session. Any future
  Home verification must use the preview harness or a seeded account.

## Reviewer Handoff Recommendation

Do **not** route to Reviewer. There is no patch to review.
Route back to Scrum Master for backlog conversion.
Future review report path if this ever becomes a bugfix:
`data/bugs/BUG-20260825-001_home_screen_design_mismatch/review/review-report.md`.
