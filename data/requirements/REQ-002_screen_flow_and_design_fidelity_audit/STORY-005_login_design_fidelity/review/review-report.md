# Review Report: STORY-005 Design Fidelity — Login

Reviewer: Iris-QC
Mode: compact-story-review (UI lane, design fidelity)
Scope: REQ-002 / STORY-005_login_design_fidelity
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-005`
Diff baseline: `8396273e6a5e6a2798557aa68864f0ef24cd939b..HEAD`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-005`

Outcome: PATCH_REQUIRED

## Summary

The design-fidelity work itself is accurate and well-evidenced. I re-derived
every D-01..D-12 claim directly from the locked design source rather than
trusting the implementer's report, and all twelve hold. The screen now matches
`Cupid Screens.dc.html` lines 1425-1457 on layout order, spacing, tokens and
typography.

One blocking regression was introduced inside this story's own WriteScope: the
forgot-password link's touch target was shrunk from the framework default
(>= 48pt) to its bare text box (~15pt). This is being deferred on the stated
grounds that fidelity and the `--tap` minimum conflict. That premise does not
hold — see PATCH-01. The fix is layout-neutral, costs no visible deviation, and
lives in the one file this story owns, so it is not eligible for deferral.

## Independent Verification Against The Locked Design Source

Source of truth read directly: `cupid-app-design-system/project/Cupid Screens.dc.html`,
`isLogin` block, lines 1425-1457, plus CSS variables at lines 23-27. Token
values cross-checked against `mobile/lib/design_system/tokens/cupid_typography_tokens.dart`
and `cupid_platform_tokens.dart`.

| AC | Verdict | Evidence |
|---|---|---|
| AC 1 — layout/spacing/color/typography match exactly | MET for the rendered surface | Root order and uniform 16px gap (line 1426) match the widget tree at `login_screen.dart:187-380`. Screen padding 12/20/40, header padding 14/4, heading centered Nunito 900 @27 (`display` is Nunito/w900/34 -> `copyWith(fontSize: 27)`), subtitle 13px `--tx2` at +7 (`caption` is 13px, so no override needed), field gap 11, card 13/16 at `--r-card` + `--shadow`, label 11px/.06em -> 0.66 letter-spacing uppercase, input 16px `--tx` borderless, forgot 12.5/w700 `--pink` flush right, divider 11.5px with 1px `--line` rules and 12px gaps at 2px vertical margin, social row 50px/1.5px `--line`/14px w700 at `--r-btn`, register 13px `--tx2` with w700 `--pink` emphasis at +6 (implemented as `_sectionGap + _registerLinkMarginTop` = 22). All confirmed against the source lines. |
| AC 2 — deviations corrected, not merely documented | MET | 300 insertions / 66 deletions in `login_screen.dart`; every D-id maps to a real code change, not a note. |
| AC 3 — form-field states | MET | Empty/focused/filled verified against lines 1432-1439: `InputBorder.none` removes the Material focused underline, matching the source's `outline:none`; no placeholder invented, since the source authors a static sibling micro-label. Error state is not authored in the source and correctly follows REQ-001 STORY-003 §6 without contradicting it. |
| AC 4 — platform-adaptive CTA | MET | `CupidPrimaryButton` retained; no platform fork introduced in feature code; `no_fork_guard_test` still green. The source's 54px/`--grad-hot` treatment is a shared design-system delta, correctly deferred as DEF-04. |
| AC 5 — no new entry point | MET | `SignInCubit` wiring, `SignInSuccess -> HomeScreen`, `_openForgot`, `_openRegister` unchanged; Scope A boundary respected. |

Ordering fix D-09 (Google first, then Apple on iOS / Facebook on Material) is
confirmed correct against lines 1449-1454. Token mapping shows no drift.

## Blocking Findings

### PATCH-01 — Forgot-password touch target regression (required)

File: `mobile/lib/features/auth/presentation/screens/login_screen.dart:256-274`

```dart
style: TextButton.styleFrom(
  padding: EdgeInsets.zero,
  minimumSize: Size.zero,
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
),
```

Why this is blocking rather than a deferrable UX question:

1. `--tap` is not an external accessibility opinion imported from outside the
   story. It is authored in this story's own locked design source, at
   `Cupid Screens.dc.html:24` (`--tap:44px`, iOS) and `:25` (`--tap:48px`, MD),
   and the source applies it to its own tappable elements (lines 52, 241, 242).
   AC 1 makes that source authoritative.
2. It is a regression, not a pre-existing gap. Before this story the link was a
   stock `TextButton`, which inherits `MaterialTapTargetSize.padded` (no global
   override exists in `mobile/lib/design_system`), giving a >= 48pt hit area.
   It is now the text box, roughly 15pt tall.
3. It breaks a codebase-wide invariant. `platformTokens.tapTarget` is enforced
   at eight sites: `core/navigation/app_shell.dart:169`,
   `design_system/adaptive/cupid_add_action.dart:32`, `cupid_tab_bar.dart:111`,
   `cupid_header.dart:103` and `:163`, `cupid_primary_button.dart:44`,
   `features/love_contracts/presentation/widgets/clause_toggle_row.dart:50`,
   and `love_contract_entry_tile.dart:91`. The `MaterialTapTargetSize.shrinkWrap`
   added here is the **only** occurrence in all of `mobile/lib`.
4. The stated fidelity-vs-accessibility tradeoff is not real. The link sits in a
   vertical band of `16 + text + 16` (the uniform root `gap:16px` of line 1426)
   in which the 32pt of gap is empty background, and it is right-aligned inside a
   full-width row whose entire left side is also empty background. Growing the
   *hit area* into space that paints nothing moves zero pixels. AC 1 governs
   visible deviation; a transparent hit region is not visible.

Required change: raise the link's hit area to `context.cupidPlatform.tapTarget`
while keeping the rendered text position byte-identical. The repo-precedent
mechanism is `ConstrainedBox(constraints: BoxConstraints(minHeight:
platformTokens.tapTarget))`, as used at `clause_toggle_row.dart:50`. Because the
band (~47pt) and the minimum (44/48) are near-identical, the two flanking
`SizedBox(height: _sectionGap)` at lines 255 and 275 must be rebalanced so the
total band is unchanged; net text movement should be <= ~1pt. Expanding the hit
area leftward costs nothing and needs no compensation at all. Keep the text
flush right so the existing assertion at
`login_screen_test.dart:166-169` continues to hold, and add a tap-target
assertion to that suite.

Do not resolve this by adding symmetric padding without compensating the
flanking gaps — that would push the CTA down ~31pt and would be a genuine AC 1
violation.

### PATCH-02 — Register link, same class (fix alongside PATCH-01)

File: `mobile/lib/features/auth/presentation/screens/login_screen.dart:354-380`

The register link moved from a stock `TextButton` (>= 48pt) to a
`GestureDetector` wrapping `Text.rich`, giving a hit box of roughly 18pt tall.
Severity is lower than PATCH-01 because `CrossAxisAlignment.stretch` keeps it
full-width horizontally, but the vertical regression is the same and the fix is
free: there is a 22pt gap above (line 353) and 40pt of screen bottom padding
below to absorb the expansion with no pixel movement.

## Accepted Deferrals

DEF-01 through DEF-05 are correctly classified and are **not** part of this
patch. Each needs a change outside `login_screen.dart`: a new `CupidIcons`
constant whose codepoint must be read from the bundled font cmap (DEF-01), a
`local_auth` dependency plus platform config and an unresolved Tech Lead scope
question (DEF-02), an SVG renderer and an `assets:` section in `pubspec.yaml`
(DEF-03), a shared `CupidPrimaryButton` change affecting welcome/register/
forgot/otp (DEF-04), and a new child slot on that same shared widget (DEF-05).

This is the same design-system-scope pattern already recorded on the sibling
auth screens in REQ-002. Recommend Scrum Master route DEF-01/DEF-03/DEF-04 as a
single design-system story rather than five per-screen follow-ups, since they
converge on the same two files.

The distinction that decides PATCH-01: DEF-01..05 cannot be delivered from
within this story's WriteScope. The tap-target regression can, and was
introduced by this story.

## Residual Risks

- DEF-04 leaves the primary CTA visually off-source (solid `--pink` at
  `tapTarget` height vs. the source's 54px `--grad-hot` with `--glow`). AC 4 is
  still satisfied because it makes the adaptive widget authoritative, but AC 1
  will not be fully closed for this screen until the shared button lands.
- Off-scale constants (12/20/40, 11, 13/16, 27, 50) are carried as file-local
  named constants. Correct for fidelity and consistent with the
  `_materialPrimaryCtaRadius` precedent, but these values are now duplicated
  across several REQ-002 screens and will need consolidation.
- No rendered-pixel diff against the design source was produced; verification is
  widget-tree assertion based. Acceptable at this tier, but exact-match claims
  in AC 1 rest on metric equivalence, not image comparison.

## Verification Evidence Reviewed

`flutter analyze` on the two changed files reports `No issues found!`; the 94
repo-wide issues are pre-existing (`prefer_initializing_formals`, generated
`openapi/**` unused imports). Targeted `test/features/auth test/design_system`
passes 59; full suite passes 929. New suite
`mobile/test/features/auth/presentation/screens/login_screen_test.dart` adds 9
widget tests across both platform silhouettes in dark + `vi`. Pre-existing
`splash_screen_test.dart` session-expired assertion and `no_fork_guard_test`
remain green. Build verification only; no device or emulator run.

Re-review scope after patch: `login_screen.dart` forgot-password and register
link regions plus the updated test assertions. No re-verification of D-01..D-12
is required.
