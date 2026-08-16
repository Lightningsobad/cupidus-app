# Fix Evidence: BUG-20260816-001 Welcome Screen Backdrop + Google CTA Brand Mark

BUG_FIX_COMPLETE: YES

Bug id: BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark
Scope classification: mobile (Flutter)
Impacted Runtime Service/App: mobile-app
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
BaseHead: `10c05c3`

## Fix Summary

Added the missing three-stop brand backdrop gradient as a **new design-system
token** (`CupidColorTokens.gradientBrandBackdrop`) and pointed the welcome
screen's backdrop at it instead of the reversed two-stop *button* token
`gradientHot` (R2-1). Gave the screen's private `_FilledCta` an optional
leading-brand-mark slot mirroring `login_screen.dart`'s `_SocialButton`, and
wired the Google CTA to the already-existing `CupidBrandMark.google` at the
design source's 20px/9px geometry (R2-2).

No raw color literal was introduced under `lib/features` — the ADR-004 no-fork
guard was re-run and is green. `gradientHot`'s own value is untouched, so no
existing button changed.

## Files Changed

Production (2):

- `mobile/lib/design_system/tokens/cupid_color_tokens.dart` — new
  `gradientBrandBackdrop` token (`165deg`, `#7B2FBE 0% / #FF4B8C 58% /
  #FF3366 100%`) plus its `_gradient165Begin/End` vectors, wired through the
  const ctor, `.dark()`, `.light()`, field list, `copyWith`, and `lerp`.
- `mobile/lib/features/auth/presentation/screens/welcome_screen.dart` —
  backdrop now `colors.gradientBrandBackdrop`; local 165deg constants removed
  (moved into the token); `_FilledCta` gained `mark`/`markSize`/`markGap`;
  Google CTA passes `CupidBrandMark.google` at 20px mark / 9px gap.

Test (1):

- `mobile/test/features/auth/presentation/screens/welcome_screen_test.dart` —
  the gradient test previously **pinned the defect**
  (`gradientHot.colors.reversed`); rewritten to assert the new token and the
  design-source values, plus a new Google brand-mark test.

`git diff --stat 10c05c3`: 3 files changed, 136 insertions(+), 30 deletions(-).

Bug artifacts added (untracked before commit):
`data/bugs/BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark/`
(`diagnosis.md`, `fix-evidence.md`, `visual-recheck/`).

## Original Failure Recheck Gate

Original anchor: rendered `welcome` screen mismatches the locked design canvas
— (R2-1) pale backdrop from the reversed button gradient, (R2-2) no Google
brand mark on the CTA.

Recheck modality: **rendered visual on a real running app**, Android emulator
`emulator-5560` (1080x2400), preview harness `lib/main_preview.dart` with
`--dart-define=PREVIEW=welcome`.

Same modality as original: **YES** — the bug was raised from a screenshot
comparison and is rechecked by a screenshot comparison against the same design
reference. The widget tests below are supporting evidence only.

Exact proof path:

```
cd <worktree>/mobile
flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=welcome
adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk
adb -s emulator-5560 shell am force-stop com.snapsofts.cupid
adb -s emulator-5560 shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
adb -s emulator-5560 exec-out screencap -p > implemented-welcome-emulator-5560.png
```

Captures (both taken this run, same device, same harness):

- Before: `visual-recheck/before-welcome-emulator-5560.png` (at BaseHead `10c05c3`)
- After: `visual-recheck/implemented-welcome-emulator-5560.png`
- Design reference:
  `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-033_app_shell_design_system_deltas/visual-fidelity/design-reference-welcome-android.png`

### Comparison against the design reference

Backdrop sampled on the vertical centre line at the gradient's own stops:

| Stop | Design source | Before (defect) | After (this fix) |
|---|---|---|---|
| 0% | `#7B2FBE` | `#B78CF5` | **`#7B2FBE`** |
| 58% | `#FF4B8C` | `#E184D0` | **`#FF4B8C`** |
| 100% | `#FF3366` | `#FF7FB6` | **`#FF3366`** |

Expected result: all three stops equal the design source
`linear-gradient(165deg,#7B2FBE 0%,#FF4B8C 58%,#FF3366 100%)`.
Actual result: **pixel-exact on all three stops.**

Google CTA: the multicolour "G" now renders immediately left of
"Tiếp tục với Google", matching the design reference's glyph-then-label row.
Before, the CTA was a bare centred label.

Foreground legibility (the reported consequence): the wordmark, tagline,
78%-alpha sub-copy, accent rule, 50%-alpha outlined "Dùng email" border and
65%-alpha 11.5px footnote all now read against the saturated backdrop, as in
the design reference. Side-by-side against the reference, the remaining visible
differences are the status-bar clock/icons and the reference image's device
bezel — no screen-content difference was found.

Result: **PASS**

## Build Gate

Command: `flutter build apk --debug`
Working dir: `<worktree>/mobile`
Registry: `data/devops/system/runtime-command-registry.json`, runtime `mobile-app` (`buildCommand`)
Result: **PASS** (exit 0) — `✓ Built build/app/outputs/flutter-apk/app-debug.apk`

### Static analysis

Command: `flutter analyze lib test --no-fatal-infos --no-fatal-warnings`
Result: **PASS** (exit 0) — **0 errors, 0 warnings**.

80 pre-existing `info` lints remain (`prefer_initializing_formals`,
`use_null_aware_elements`, one `deprecated_member_use`) — the same count as the
BUG-20260814-001 baseline, and none in a file this fix touched. The handoff
baseline of "0 analyze errors / 0 warnings" is met exactly.

### Test suite

Command: `flutter test` (registry `testCommand`)
Result: **PASS** (exit 0) — **1247 passed, 2 skipped, 0 failures.**

Baseline reconciliation: the handoff quoted 1247, but the *current* tree
baseline is 1246 — BUG-20260814-001 deleted exactly one obsolete pin-list test
(documented in its own fix-evidence). This fix adds exactly one test
(`Google CTA carries the multicolour brand mark before its label`) and rewrites
one in place, so 1246 + 1 = 1247. No test was skipped, weakened, or silenced.

Targeted run before the full suite:
`flutter test test/features/auth/presentation/screens/welcome_screen_test.dart test/design_system/no_fork_guard_test.dart --reporter expanded`
-> 8/8 passed, including the ADR-004 no-fork guard.

## Runtime Startup Gate

Runtime Id: `mobile-app`
Registry: `data/devops/system/runtime-command-registry.json`
Device: `emulator-5560` (`MOBILE_DEVICE_SERIAL`)

Install: `adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk` — exit 0

Command (verbatim from the registry `readiness.command`):

```
adb -s "$MOBILE_DEVICE_SERIAL" shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity >/dev/null && for _ in $(seq 1 30); do adb -s "$MOBILE_DEVICE_SERIAL" shell dumpsys activity activities | grep -q "ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity" && exit 0; sleep 2; done; exit 1
```

Ready Check: `MainActivity` reported as `ResumedActivity` — exit code **0**
(registry `expectExitCode: 0`).
Result: **PASS**

Shutdown command: `adb -s "$MOBILE_DEVICE_SERIAL" shell am force-stop com.snapsofts.cupid` — exit code **0**
Shutdown: **PASS**

Device left in the expected state: the preview-harness APK used for the visual
recheck was replaced by a freshly built **normal** debug APK before the final
readiness probe, so the emulator no longer carries the preview entrypoint.
This readiness check is separate from and in addition to the visual recheck
above.

Scope note: scoped smoke of the impacted app only. DevOps' separate Integration
Build & Runtime evidence for this round was not re-run or duplicated.

## Regression Coverage

The defect cannot be reintroduced silently:

- `welcome_screen_test.dart` no longer pins the defect. It asserts the
  decoration *is* `CupidColorTokens.dark().gradientBrandBackdrop`, **and**
  independently pins the three design-source colors, the `[0.0, 0.58, 1.0]`
  stops and the 165deg vectors, so the token itself cannot drift either.
- The same test asserts `isNot(gradientHot.colors.reversed)`, so the exact
  regression reported here fails by name if anyone re-derives the backdrop
  from the button token.
- A new test asserts the Google CTA contains exactly one
  `CupidBrandMarkIcon`, that its `mark` is `CupidBrandMark.google`, that it
  renders at 20x20, and that it sits *before* the label horizontally.
- `no_fork_guard_test.dart` (unmodified) keeps the new hex literals confined to
  `lib/design_system/`.

## Commands Run

| # | Command | Result |
|---|---------|--------|
| 1 | `flutter pub get` | exit 0 |
| 2 | `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=welcome` (pre-fix) | exit 0 |
| 3 | install + launch + `screencap` (pre-fix) | defect reproduced on both R2-1 and R2-2 |
| 4 | `flutter test <welcome_screen_test> <no_fork_guard_test> --reporter expanded` | 8/8 pass |
| 5 | `flutter analyze lib test --no-fatal-infos --no-fatal-warnings` | exit 0, 0 errors / 0 warnings |
| 6 | `flutter test` | exit 0, 1247 passed / 2 skipped |
| 7 | `flutter build apk --debug` | exit 0 |
| 8 | preview APK rebuild + install + launch + `screencap` (post-fix) | both defects cleared |
| 9 | normal APK rebuild + `flutter`-free `adb install -r` | exit 0 |
| 10 | registry readiness probe | exit 0 |
| 11 | registry shutdown command | exit 0 |

`flutter` was invoked with `PATH="/Users/alantravala/flutter/bin:$PATH"`; the
SDK is not on the default PATH in this environment (as the registry `sdk` block
records).

## Same-Family Downstream Failures

None surfaced. R2-1 and R2-2 were cleared together in this pass as one cluster
(rationale in `diagnosis.md` § Root-Cause Family And Cluster Boundary). No new
same-family anchor remains open, so no
`BLOCKER: BUGFIX_CLUSTER_CONTINUE_REQUIRED` is needed.

## Remaining Risks

- **Low — requirement-level screenshot not overwritten by design.** Bug Fixer
  must not edit `data/requirements/`, and
  `integration-review/mobile-screenshots/implemented-welcome-emulator-5560.png`
  is Round 2's evidence-of-record for a review that is still open. The fresh
  capture is therefore stored at
  `data/bugs/BUG-20260816-001_.../visual-recheck/implemented-welcome-emulator-5560.png`.
  If Round 2 "Required To Clear" item 3 wants the requirement-level file
  refreshed in place, Scrum Master or Reviewer should copy it across — the file
  is byte-identical to what a re-capture would produce.
- **Low — only the `welcome` screen was re-captured.** Per the handoff this was
  scoped to one screen, not the full 31-screen audit. Other screens' captures
  are unchanged and unaffected: `gradientHot`'s value did not change and the new
  token has exactly one consumer.
- **Low — `gradientBrandBackdrop` currently has a single call site.** If other
  screens in the design source use the same 165deg brand backdrop, they should
  adopt this token rather than re-approximating; that is a fidelity-audit
  question, not a regression of this fix.
- **None outstanding on scope.** No other screen, token value, or test was
  touched.

## Reviewer Handoff Recommendation

Ready for bugfix review.

- Review report path (Reviewer writes this):
  `data/bugs/BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark/review/review-report.md`
- Diff baseline for review: `git -C <worktree> diff 10c05c3`
- Suggested review focus: (1) confirm adding a `required` parameter to the
  `CupidColorTokens` const constructor is the right call versus an optional one
  — the full suite compiling proves no construction site was missed, but it is
  a public-ish token contract change; (2) confirm the 20px/9px welcome mark
  geometry versus login's 19px/8px is intended design-source divergence and not
  something to unify; (3) confirm storing the re-capture under the bug
  directory instead of overwriting the Round 2 review screenshot is the
  preferred handling.
