# Fix Evidence: BUG-20260814-001 Chrome Header Breach

Bug id: BUG-20260814-001_chrome_header_breach_forgot_password_otp_permissions_onboarding
Scope classification: mobile (Flutter)
Impacted Runtime Service/App: mobile-app
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
BaseHead: `83d456f90a9d5fe34851b6b8efa194f58945040c`

## Fix Summary

Removed the `appBar: CupidHeader(...)` composition from the four chromeless
onboarding-chain screens named in the bug report, and removed the guard suite's
`_trackedHeaderBreaches` pin so the AC4 header assertion now applies
unconditionally to every chain node. No shared/composition-layer code changed;
see `diagnosis.md` for why this is a four-call-site cluster rather than one
shared defect.

## Files Changed

Production (4):

- `mobile/lib/features/auth/presentation/screens/forgot_screen.dart`
- `mobile/lib/features/auth/presentation/screens/otp_screen.dart`
- `mobile/lib/features/onboarding/presentation/screens/permissions_screen.dart`
- `mobile/lib/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart`

Test (6):

- `mobile/test/core/navigation/chain_chrome_guard_test.dart` — pin removed, header assertion made unconditional
- `mobile/test/features/auth/presentation/screens/forgot_screen_test.dart` — header test inverted into a no-chrome regression assertion
- `mobile/test/features/auth/presentation/screens/auth_leg_edges_test.dart` — `forgot -> login` back leg now driven by platform back, matching the chromeless `register` leg precedent
- `mobile/test/features/auth/otp_screen_test.dart` — dropped the removed header title assertion
- `mobile/test/features/onboarding/permissions_screen_test.dart` — dropped the removed header title assertion
- `mobile/test/features/onboarding/presentation/screens/onboarding_profile_setup_screen_test.dart` — extended to assert no `AppBar`

`git diff --stat` vs BaseHead: 10 files changed, 30 insertions(+), 79 deletions(-).

`welcome_screen.dart` was NOT touched (tracked separately as BUG-20260816-001),
and no screen outside the four reported routes was modified.

## Original Failure Recheck Gate

Same modality as original: YES

The bug was reported from two modalities and was rechecked in both.

### Modality 1 — widget-render guard test (the reported failure anchor)

Command:
`cd mobile && flutter test test/core/navigation/chain_chrome_guard_test.dart --reporter expanded`

- Before fix, pin removed: 4 failures, one per reported route, each
  `<route> grew a header AC4 forbids`
- After fix: 17/17 passed, 0 failures, with the header assertion now
  unconditional for every chromeless chain node

### Modality 2 — rendered visual recheck on a real running app

The bug is a visual/design defect, so a code read is not sufficient. All four
routes were rendered on Android emulator `emulator-5560` (1080x2400) and
screenshotted.

- `forgot_password` — reached through the live app flow
  (welcome -> login -> tap "Quên mật khẩu?"): renders with no header. Hardware
  back then returned to `login`, confirming the spec's
  `forgot_password --back--> login` leg survives the header removal.
- `otp` — rendered via the `lib/main_preview.dart` harness
  (`--dart-define=PREVIEW=otp`): no header.
- `permissions` — same harness: no header; content starts at the
  "Cho phép vài thứ nhé" title directly under the status bar with correct
  `SafeArea` inset.
- `onboarding_profile_setup` — same harness (`PREVIEW=profile` with
  `--dart-define=PREVIEW_PROFILE=fixture`): no header; avatar slot is the
  topmost content.

Result: PASS

## Build Gate

Command: `flutter build apk --debug`
Working dir: `<worktree>/mobile`
Result: PASS (exit 0) — `✓ Built build/app/outputs/flutter-apk/app-debug.apk`

### Static analysis

Command: `flutter analyze lib test --no-fatal-infos --no-fatal-warnings`
Result: PASS (exit 0) — 0 errors, 0 warnings.

Note: plain `flutter analyze lib test` exits 1 on this tree because of 80
pre-existing `info`-level lints (`prefer_initializing_formals`,
`use_null_aware_elements`, one `deprecated_member_use`). The count is 80 both
before and after this change, and none of them are in a file this fix touched.
The handoff baseline of "0 errors/0 warnings" is met exactly.

### Test suite

Command: `flutter test`
Result: PASS (exit 0) — 1246 passed, 2 skipped, 0 failures.

Baseline reconciliation: the handoff baseline was 1247 passing. This fix deletes
exactly one test — `every tracked header breach is still a chain node`, which
existed only to validate the `_trackedHeaderBreaches` pin list and cannot
outlive it. 1247 - 1 = 1246. No test was skipped, weakened, or silenced to reach
green.

## Runtime Startup Gate

Runtime Id: `mobile-app`
Registry: `data/devops/system/runtime-command-registry.json`
Device: `emulator-5560`

Install command: `flutter install -d emulator-5560 --debug` — exit 0

Readiness command (verbatim from the registry):

```
adb -s "$MOBILE_DEVICE_SERIAL" shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity >/dev/null && for _ in $(seq 1 30); do adb -s "$MOBILE_DEVICE_SERIAL" shell dumpsys activity activities | grep -q "ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity" && exit 0; sleep 2; done; exit 1
```

Ready check: exit 0 — `MainActivity` reached `ResumedActivity`.
Result: PASS

Shutdown command: `adb -s "$MOBILE_DEVICE_SERIAL" shell am force-stop com.snapsofts.cupid` — exit 0
Shutdown: PASS

Device left in the expected state: the preview-harness APK used for the visual
recheck was replaced by a freshly built normal debug APK before the final
readiness probe, so the emulator no longer carries the preview entrypoint.

Scope note: this is a scoped smoke of the impacted app only. DevOps' separate
Integration Build & Runtime evidence for this round was not re-run or duplicated.

## Regression Coverage

The defect can no longer be reintroduced silently:

- `chain_chrome_guard_test.dart` now asserts `findsNothing` for both
  `CupidHeader` and `AppBar` on **every** chromeless chain node, with no
  exemption mechanism left in the file. Any future screen that adds an app bar
  inside the chain fails this suite by name.
- `forgot_screen_test.dart` gained a dedicated
  `renders no header chrome (AC4 applies to every chain node)` test asserting
  no `CupidHeader`, no `AppBar`, and no back-arrow icon.
- `onboarding_profile_setup_screen_test.dart` asserts no `AppBar`.
- `auth_leg_edges_test.dart` now pins the `forgot -> login` back leg to the
  platform back gesture, so the navigation contract is covered independently of
  any header affordance.

## Commands Run

| # | Command | Result |
|---|---------|--------|
| 1 | `flutter test test/core/navigation/chain_chrome_guard_test.dart --reporter expanded` (unmodified tree) | 18/18 pass, defect pinned — reproduction signal |
| 2 | same, after removing `_trackedHeaderBreaches` | 4 failures, one per reported route |
| 3 | same, after the four screen fixes | 17/17 pass |
| 4 | `flutter analyze lib test --no-fatal-infos --no-fatal-warnings` | exit 0, 0 errors / 0 warnings |
| 5 | `flutter test` | exit 0, 1246 passed / 2 skipped |
| 6 | `flutter build apk --debug` | exit 0 |
| 7 | `flutter install -d emulator-5560 --debug` | exit 0 |
| 8 | registry readiness probe | exit 0 |
| 9 | registry shutdown command | exit 0 |

`flutter` was invoked with `PATH="/Users/alantravala/flutter/bin:$PATH"`; the
SDK is not on the default PATH in this environment.

## Remaining Risks

- **Low — back affordance is now platform-only on `forgot_password`.** The spec
  locks the transition but not the affordance, and this matches the sibling
  chromeless `register` leg. If UI/UX later wants an in-content back control on
  chromeless nodes, that is a design decision, not a regression of this fix.
- **Low — the four screens' design sources still contain header blocks.** A
  future fidelity pass that re-derives a screen from its design source could
  reintroduce the header. The now-unconditional guard suite catches that in CI.
- **None outstanding on scope.** `welcome_screen.dart` (BUG-20260816-001)
  remains unfixed by design.

## Reviewer Handoff Recommendation

Ready for bugfix review.

- Review report path (Reviewer writes this):
  `data/bugs/BUG-20260814-001_chrome_header_breach_forgot_password_otp_permissions_onboarding/review/review-report.md`
- Suggested review focus: (1) confirm the `uiux-spec` Chrome Rules vs design
  source precedence call recorded in `diagnosis.md` "Stop-Rule Check" is the
  one Reviewer would make; (2) confirm the `auth_leg_edges_test.dart` back-leg
  rewrite still satisfies `uiux-spec.md:34`; (3) confirm the 1247 -> 1246 test
  count delta is the single pin-list test and nothing else.
- Diff baseline for review: `git -C <worktree> diff 83d456f90a9d5fe34851b6b8efa194f58945040c`
