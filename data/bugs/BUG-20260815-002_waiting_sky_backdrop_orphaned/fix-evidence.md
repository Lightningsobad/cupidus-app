# Fix Evidence: BUG-20260815-002 Waiting Screen `_SkyBackdrop` Orphaned After STORY-032 Supersede

Bug id: BUG-20260815-002_waiting_sky_backdrop_orphaned
Owner: bug-fixer (Justin-BugFixer)
Work location: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
State: changes left uncommitted in the integration worktree for Scrum Master.

## Patch Summary

Resolution chosen: **(a) delete and retarget**. `CupidAppBackground` preserves
STORY-013's visual intent value-for-value; see `diagnosis.md` →
`## Delete-and-Retarget vs. Restore — Evidence` for the layer/star comparison
tables that back this, and `## Coverage Mapping` for where each retired
assertion now lives.

| File | Change |
| --- | --- |
| `mobile/lib/features/pairing/presentation/screens/waiting_screen.dart` | Deleted the orphaned `_SkyBackdrop` plus its exclusive private helpers `_CssEllipse`, `_skyPurpleWash`, `_skyMagentaWash`, `_skyTealWash`, `_TwinkleStar`, `_TwinkleStarState`. |
| `mobile/test/features/pairing/presentation/screens/waiting_screen_design_fidelity_test.dart` | `_harness()` now mounts `CupidAppBackground` through `MaterialApp.builder`, mirroring `cupid_app.dart:58-59`; the sky test asserts the successor renders behind the screen and the screen does not occlude it. |

```
git diff --stat
 .../presentation/screens/waiting_screen.dart       | 218 ---------------------
 .../waiting_screen_design_fidelity_test.dart       | 114 +++--------
 2 files changed, 32 insertions(+), 300 deletions(-)
```

No production behavior change: the deleted code was unreferenced (proven by the
`unused_element` warning itself and by `git grep`), so it painted nothing.

## Original Failure Recheck Gate

The bug reported two anchors in two modalities. Both are rechecked in their own
original modality.

### Recheck 1 — analyzer warning

Original anchor: `warning • The declaration '_SkyBackdrop' isn't referenced …
lib/features/pairing/presentation/screens/waiting_screen.dart:337:7 •
unused_element` — the integration branch's only analyzer warning.

Recheck modality: static analysis.
Same modality as original: YES.

Command:
```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit/mobile
/Users/alantravala/flutter/bin/flutter analyze lib test
```

Proof path: `mobile/lib/features/pairing/presentation/screens/waiting_screen.dart`
(the exact file and element named by the warning).

Expected result: zero `warning`-severity diagnostics.

Actual result:
```
                     warning count   error count   total
before this patch          1              0          81
after  this patch          0              0          80
```
The `_SkyBackdrop` line is gone and no replacement `unused_element` warning
appeared for the six helpers deleted alongside it. The 80 remaining diagnostics
are all `info` (`prefer_initializing_formals`, one `deprecated_member_use`) and
are untouched pre-existing branch state.

Result: PASS

### Recheck 2 — RED regression test

Original anchor: `waiting_screen_design_fidelity_test.dart:134`
`paints the --sky wash and twinkle stars over --bg` failing with
`Found 0 widgets with key [<'waiting_sky_backdrop'>]`.

Recheck modality: test execution.
Same modality as original: YES.

Command:
```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit/mobile
/Users/alantravala/flutter/bin/flutter test --reporter failures-only \
  test/features/pairing/presentation/screens/waiting_screen_design_fidelity_test.dart
```

Proof path:
`mobile/test/features/pairing/presentation/screens/waiting_screen_design_fidelity_test.dart`
(the exact suite that reported the failure).

Expected result: the sky test passes; the caption-typography test at `:188`
stays RED because it belongs to `BUG-20260814-003`.

Actual result: `+6 -1`, the single remaining failure being
`applies the design source typography and muted subtitle` with
`Expected: <13> Actual: <11.5>` — `BUG-20260814-003`'s signature, not this
bug's. The `waiting_sky_backdrop` failure no longer appears.

Result: PASS

Note on the retargeted assertion: the harness change is load-bearing rather
than decorative. Without `builder: … CupidAppBackground(…)` no
`CupidSkyPainter` exists in the tree and `whereType<CupidSkyPainter>().single`
throws on the empty iterable, so the test cannot pass vacuously. This follows
from the finder's construction; it was not separately executed against a
reverted harness.

## Build Gate

Command:
```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit/mobile
/Users/alantravala/flutter/bin/flutter build apk --debug
```

Actual result:
```
✓ Built build/app/outputs/flutter-apk/app-debug.apk
BUILD_EXIT=0
```

Result: PASS

Static analysis of the changed files is covered by Recheck 1 above
(`flutter analyze lib test`: 0 errors, 0 warnings).

## Runtime Startup Gate

Registry: `data/devops/system/runtime-command-registry.json`
Runtime Id: `mobile-app`
Device: `emulator-5560`

Install command:
```
adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk
-> Performing Streamed Install
   Success
   INSTALL_EXIT=0
```

Startup command:
```
adb -s emulator-5560 shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
```

Ready Check (registry readiness probe — poll `dumpsys activity activities` for
the resumed activity, 30 attempts × 2s):
```
adb -s emulator-5560 shell dumpsys activity activities \
  | grep -q "ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity"
-> READY_OK
```

Result: PASS

Shutdown:
```
adb -s emulator-5560 shell am force-stop com.snapsofts.cupid
-> FORCE_STOP_EXIT=0
adb -s emulator-5560 shell dumpsys activity activities | grep -c "ResumedActivity.*com.snapsofts.cupid/..."
-> 0
```

Shutdown: PASS

## Regression Evidence

Scope covers everything the handoff required: the waiting screen's whole test
directory, the STORY-013 regression file, and every test file that touches
`CupidAppBackground` (`test/design_system/cupid_app_background_test.dart`,
`test/app/feature_flags_test.dart`, `test/widget_test.dart` — established by
`git grep -n "CupidAppBackground" -- mobile/test`).

Command:
```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit/mobile
/Users/alantravala/flutter/bin/flutter test --reporter failures-only \
  test/features/pairing \
  test/design_system \
  test/app/feature_flags_test.dart \
  test/widget_test.dart
```

Actual result: `+144 -4`. All four failures are pre-existing and owned by other
queued bugs; none is introduced by this patch:

| Failing test | Symptom | Owner |
| --- | --- | --- |
| `joincode_screen_design_test.dart` — heading and sub-copy use the design source display/caption roles | caption `13` vs `11.5` | `BUG-20260814-003` (registry row names `joincode_screen_design_test.dart:107`) |
| `waiting_screen_design_fidelity_test.dart:188` — applies the design source typography and muted subtitle | caption `13` vs `11.5` | `BUG-20260814-003` (registry row names `waiting_screen_design_fidelity_test.dart:238`, the pre-patch line number of this same assertion) |
| `feature_flags_test.dart` — CupidApp resolves dark theme mode and vi locale with flags off, and the runtime readiness key still resolves | `home_screen_ready_signal` not found | `BUG-20260814-002` (registry row names `feature_flags_test.dart` RED, "no widget reaches `home_screen_ready_signal`") |
| `widget_test.dart:85` — App boots to the home screen ready signal | `Found 0 widgets with key [<'home_screen_ready_signal'>]` | `BUG-20260814-002` (registry row names `widget_test.dart` RED) |

Attribution basis, not assumption:
- All four were already RED in the pre-patch full-suite baseline recorded in
  `data/bugs/BUG-20260815-001_no_fork_guard_raw_color_violations/fix-evidence.md`,
  which was measured before any change to `waiting_screen.dart`.
- Two of them were re-observed RED in *this* bug's own Pre-Fix Reproduction Gate
  run, before the patch existed.
- Causation is structurally impossible in the other direction: the deleted code
  was unreferenced (that is precisely what the `unused_element` warning
  asserted, independently confirmed by `git grep -n "_SkyBackdrop" -- mobile`
  returning only the declaration), so removing it cannot change any rendered
  tree; and the only other edit is inside the one test file whose own results
  are reported above.

`test/design_system` — including `cupid_app_background_test.dart`, the successor
component's own suite — is fully green.

Result: PASS, no regression attributable to this patch.
