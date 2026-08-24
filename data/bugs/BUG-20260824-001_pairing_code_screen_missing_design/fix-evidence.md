# Fix Evidence: BUG-20260824-001 pairing_code_screen_missing_design

BUG_FIX_COMPLETE: NO
Outcome: `ESCALATE_TO_BACKLOG`

## Summary

The reported defect reproduced on a real rendered screen, and its cause is
established: the `invite` node's couple-type picker and continue CTA were never
implemented, by an explicit reviewer-approved decision in STORY-011 and
STORY-037. Implementing them is new product scope plus an onboarding-flow
change, not a narrow design-fidelity patch, so no patch was applied.

Full analysis: `data/bugs/BUG-20260824-001_pairing_code_screen_missing_design/diagnosis.md`.

## Files Changed

None. No source or test file was modified.

New evidence artifact:
- `data/bugs/BUG-20260824-001_pairing_code_screen_missing_design/evidence/reproduction-invite-emulator-5554.png`

## Regression Test

Not added. There is no defect to guard: the app matches its own approved
delivery decision, and the missing block has no agreed target behaviour yet.
Coverage belongs to the backlog story that decides the interaction.

## Commands Run

| Command | Result |
| --- | --- |
| `"$HOME/Library/Android/sdk/emulator/emulator" -avd Medium_Phone_API_36.0 -no-snapshot-save` (background) | `emulator-5554 device` |
| `cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter build apk --debug` | `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` |
| `cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter build apk --debug --target=lib/main_preview.dart --dart-define=PREVIEW=invite` | `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` |
| `adb -s emulator-5554 install build/app/outputs/flutter-apk/app-local-debug.apk` | first attempt `IOException: Requested internal only, but not enough space`; after `adb uninstall com.snapsofts.cupid`, `Success` |
| `adb -s emulator-5554 shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` | `Status: ok`, `Complete` |
| `adb -s emulator-5554 exec-out screencap -p` | captured `evidence/reproduction-invite-emulator-5554.png` |
| `git log --follow` / `git show --stat 9aa0aed` / `git diff 0808f71 3d74a75 -- cupid-app-design-system` | design-source drift attributed to `support.js` only; invite markup change isolated to `3d74a75` (2026-08-20) |

## Touched Risk Surfaces And Selected Minimum Gates

Risk surfaces that a fix *would* touch: frontend interaction (mobile),
onboarding routing, and the `CupidProfile.coupleType` persistence contract.
Because no patch was applied, the minimum gate selected for this run was the
same-modality rendered reproduction only.

## Pre-Fix Reproduction Gate

Recorded in `diagnosis.md` → `## Pre-Fix Reproduction Gate`.
Modality: rendered Android emulator capture (same modality as the report).
`Result: REPRODUCED`.

## Original Failure Recheck Gate

Not applicable and intentionally absent: no patch was applied, so there is
nothing to recheck. `BUG_FIX_COMPLETE: YES` is therefore not claimed.

## Build Gate

Command: `cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter build apk --debug`
Result: PASS (`✓ Built build/app/outputs/flutter-apk/app-local-debug.apk`)

Recorded as supporting evidence that the touched runtime builds on the current
tree. It does not substitute for a fix, and it is not offered as a completion
gate.

## Runtime Startup Gate

Runtime Id: `mobile-app`
Registry: `data/devops/system/runtime-command-registry.json`
Command: `adb -s emulator-5554 shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
Ready Check: registry `readiness.command` — launcher activity reported as the
resumed foreground activity on `emulator-5554`
Result: PASS (`Status: ok`, `LaunchState: COLD`, `Complete`; screen captured
from the running process)
Shutdown: DEFERRED — the emulator and app were intentionally left running so a
follow-up story or the Reviewer can re-capture the same screen without a
20-minute rebuild/install cycle. Shut down with
`adb -s emulator-5554 shell am force-stop com.snapsofts.cupid` and
`adb -s emulator-5554 emu kill`.

Caveat for whoever reuses this device: the installed `com.snapsofts.cupid` on
`emulator-5554` is the `main_preview.dart` preview entrypoint pinned to
`PREVIEW=invite`, not the normal app entrypoint.

## Remaining Risks / Unrelated Findings

- `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`
  has no design node any more: `3d74a75` deleted `isPairingChoice` from
  `Cupid Screens.dc.html` on 2026-08-20. Same family as this bug, same blocker.
- The design source's post-invite target changed from `waiting` to `vow`; the
  app still routes to `waiting`. Needs the same product/UX decision.
- `detect_design_source.py`'s `DESIGN_SOURCE_DRIFTED` signal is real but
  benign for this screen — the drifted bytes are `support.js`, not screen
  markup. The design lock can be re-baselined without re-auditing the invite
  markup.

## Reviewer Handoff Recommendation

Do **not** route to Reviewer. There is no patch to review.
Route back to Scrum Master for backlog conversion.
Future review report path if this ever becomes a bugfix:
`data/bugs/BUG-20260824-001_pairing_code_screen_missing_design/review/review-report.md`.
