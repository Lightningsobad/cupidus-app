Outcome: DEFERRED_ONLY

# Review Report — STORY-033 App Shell Design System Deltas

Reviewer: Iris-QC
Mode: compact-story-review
Flow: parallel-story
Date: 2026-08-14
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-033`
BaseHead: `092c0af124f9c4df9a37a832104d91b3c0bd0037`
Reviewed HEAD: `bf0145077a08e3540012fae6c74bb42ace9f5666`
merge_eligible: true

## Review scope

This gate covers Deltas 2/3/4 only — AC2, AC3, AC4 — plus AC5 (test impact).

AC1 (Delta 1, the `skyGradient` app-shell backdrop) is OUT OF SCOPE. It was
transferred to STORY-032 by `architecture/solution.md` section 1 on
file-collision grounds and ratified by Scrum Master. This review neither
evaluates nor faults AC1; it is verified at REQ-002 requirement integration
review once STORY-032 lands. The AC1 transfer decision was not re-litigated
here.

## Diff scope check — PASS

`git diff 092c0af..bf01450` touches 14 files: 3 source files plus this story's
own artifacts (story_master, ux-spec, solution, test-results, visual-fidelity
report and its 6 PNGs).

| File | Change | Expected |
|---|---|---|
| `mobile/lib/design_system/adaptive/cupid_header.dart` | +1 -1 | yes (Delta 2) |
| `mobile/lib/design_system/tokens/cupid_typography_tokens.dart` | +1 -1 | yes (Delta 3) |
| `mobile/lib/design_system/tokens/cupid_color_tokens.dart` | +26 -8 | yes (Delta 4) |

No edit to `mobile/lib/design_system/theme/cupid_theme.dart` or
`mobile/lib/app/cupid_app.dart` — STORY-032's collision files are untouched, so
there is no out-of-scope violation and no predicted merge conflict against the
integration branch. No test file was modified. `git status` in the worktree is
clean.

## AC verdicts

### AC2 — `CupidHeader` Material back-arrow renders in pink ink — PASS

- Implementation matches `solution.md` section 2 exactly: the single
  `IconButton` argument in `_MaterialHeader` changed `colors.colorText` →
  `colors.colorAccentPink`. Nothing else in the header changed, and `_IosHeader`
  was correctly left alone (it already rendered the chevron in
  `colorAccentPink`), so both platform variants now read the same token.
- Verified against evidence, not just the diff: in
  `implemented-notifs-emulator-5554.png` the back arrow renders pink, matching
  `design-reference-notifs-android.png`. Independently reconfirmed on the
  `alarm` pair, a second screen with its own `CupidHeader`. Header title ink,
  weight and position are unchanged between reference and capture on both.
- Contrast: no new ADR-004b exception. `colorAccentPink` on an **icon** is an
  explicitly approved use per the dartdoc on `CupidColorTokens.light`, and iOS
  already did this.

### AC3 — `caption` renders at the design source's declared size — PASS

- `cupid_typography_tokens.dart` changed `fontSize: 13` → `11.5`; family,
  weight and every other style in the factory are untouched. `caption` was
  correctly NOT split into role-specific tokens, per `solution.md` section 3.
- First clause (size) verified on the `notifs` capture: the seven caption
  sub-labels and the three uppercase section labels (CRITICAL / ENGAGEMENT /
  INFO) match the reference in rendered size. Reconfirmed on `alarm`.
- Second clause (line count) verified on the same capture: the longest caption,
  the quoted Love Timeline sub-label `Nhắc kỷ niệm "ngày này năm xưa"`, sits on
  one line in both reference and capture.
- The "no layout was keyed to 13px" sweep is real and documented per call site,
  not asserted: the only site reading `type.caption.fontSize`
  (`cupid_tab_bar.dart:141-146`) and the only site with `maxLines: 1`
  (`expense_list_item.dart:102-109`) were both analysed and are benign, and the
  remaining sites size intrinsically.
- See F1 for the one residual evidence gap on this AC.

### AC4 — CTA gradient axis is 95deg, not 120deg — PASS

- The implementation trap flagged in `solution.md` section 4 was handled
  correctly. A **new** constant pair `_gradient95Begin` / `_gradient95End` was
  added rather than mutating the shared one, and only `gradientHot` was
  repointed — in **both** blocks (`cupid_color_tokens.dart:100-101` dark,
  `:165-166` light). `gradientDream` still reads `_gradient120Begin` /
  `_gradient120End` in both blocks (`:90-91`, `:155-156`), so it did not
  silently rotate. Colors and stops are unchanged (`#FF7FB6` → `#B78CF5`).
- Direction-vector math independently recomputed against the convention
  documented at the top of the file (CSS 0deg points to top, clockwise; vector
  `(sin θ, -cos θ)`, `begin` is its negation). For θ=95: `sin=0.9961946980917455`,
  `cos=-0.08715574274765817`, giving `end = (0.9962, 0.0872)` and
  `begin = (-0.9962, -0.0872)`. The committed values match, and the same formula
  reproduces the pre-existing 120deg pair, so the new pair is consistent with
  the established convention rather than ad hoc.
- Verified visually at full bleed: `implemented-welcome-emulator-5554.png` runs
  pink at the left edge to purple at the right on a near-horizontal axis with
  only a slight downward tilt. A 120deg wash would climb visibly across the
  frame; it does not.
- Regression control confirmed independently: the `alarm` capture's hero card
  (`gradientDream`) still renders on the steeper 120deg diagonal, pink through
  purple to mint. The two tokens are genuinely decoupled.
- The stale-`--grad-hot` rationale is carried in a dartdoc on the new pair, so a
  future reader will not "correct" 95deg back to the dead 120deg source
  variable.

### AC5 — existing tests unchanged and still passing — PASS

- `flutter test` → `EXIT_CODE=0`, `+920: All tests passed!`
- `flutter analyze lib/design_system` → `No issues found!`; repo-wide analyze
  shows 94 pre-existing infos/warnings, none in a touched file.
- `flutter build apk --debug` → `EXIT_CODE=0`.
- Zero test files modified, confirmed independently by the diff, not only by the
  lane's own claim. `solution.md` section 5 predicted this for all four
  governing contract tests and the prediction held, so AC5's "called out
  explicitly" clause has nothing to disclose. No assertion was weakened to make
  a test pass.

## Findings

### F1 — DEFERRED — AC3's named case has no visual capture, only a static read

AC3 explicitly names the onboarding profile-setup screen's zodiac helper text
as the case that must return to one line. That specific screen was NOT
captured. The `profile` preview entry wraps `AccountRepository.fetchProfile()`
in a `FutureBuilder` requiring an authenticated Firebase session
(`--dart-define=PREVIEW_EMAIL` / `PREVIEW_PASSWORD`), no such credential exists
in the repository, and the screen never left its spinner.

Accepted as deferred rather than blocking, for three reasons:

1. The substitute evidence is a static widget-tree read showing
   `profile_edit_screen.dart:223-226` is a plain `Text` in a `Column` with no
   `maxLines` and no fixed height, and `:272-278` is intrinsically sized.
2. The physical argument is sound and one-directional: reducing font size in a
   `Text` with no `maxLines` and no fixed height cannot increase line count, and
   cannot introduce clipping. The failure mode this AC guards against is not
   reachable by this change.
3. The line-count half of AC3 is directly captured on eleven other caption sites
   across two screens, including the longest string.

The lane handled this correctly — it discarded the spinner capture and said so,
rather than filing a spinner as evidence or burying a caveat in a passing
report. Route: direct confirmation lands naturally when STORY-010's onboarding
screen is re-verified at REQ-002 requirement integration review. No STORY-033
rework.

### F2 — INFORMATIONAL — out-of-scope deltas correctly attributed away

The visual-fidelity report records seven reference-vs-capture differences that
no STORY-033 AC covers and no STORY-033 file could fix (flat backdrop, 3-tab vs
5-tab bar, unexpected FAB, truncated banner copy, stacked weekday chips,
`gradientDream` hero card in a backend-error state, `welcome` composition).
Spot-checked against the captures: the attributions hold. In particular the
stacked weekday chips on `alarm` are caused by per-chip
`ConstrainedBox(minWidth: tapTarget)` exceeding the card's inner width — a
smaller caption strictly improves horizontal fit, so Delta 3 cannot be the
cause. These are routing input for requirement integration review, not deferred
items against this story.

### F3 — INFORMATIONAL — minor doc count drift, no action

`solution.md` section 3 estimates "~50" `type.caption` call sites; the
visual-fidelity sweep counts 75 across 29 files. The sweep is the later and
authoritative count and is exhaustive; the estimate was never load-bearing.

## Residual risks

- AC1 remains unowned inside STORY-033 by design. It is load-bearing for
  STORY-010's PASS and must not close without STORY-032 landing. `solution.md`
  section 1.3 additionally flags that STORY-032 must be confirmed to cover the
  **sparkle dots**, not just the aurora wash, or the dots become an unowned
  residual delta. This is Scrum Master's open item, already recorded, restated
  here so it is not lost at integration review.
- `gradientHot` is consumed by 17 files. The axis change reaches all of them
  automatically. Visual confirmation exists on two of those surfaces (`notifs`
  toggles, `welcome` full-bleed); the rest are covered by the shared-token
  argument rather than per-screen capture, which is proportionate for a
  single-property token change.

## Verdict

Deltas 2/3/4 are implemented exactly as specified in `solution.md` section 6,
with correct handling of the two traps that specification called out (do not
mutate the shared 120deg pair; do not touch `_IosHeader`). Gates are green,
no test was edited, and the diff stays strictly inside this story's write scope
with no encroachment on STORY-032's files.

Verdict basis: one deferred evidence-coverage item (F1), no defect and no
rework required. The verdict line is declared once, at the top of this report.

merge_eligible: true
