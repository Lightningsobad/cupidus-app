# Review Report: STORY-005 Design Fidelity — Login (Round 2)

Reviewer: Iris-QC (fresh reviewer, second pass)
Mode: compact-story-review (UI lane, design fidelity)
Scope: REQ-002 / STORY-005_login_design_fidelity
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-005`
Diff baseline: `8396273e6a5e6a2798557aa68864f0ef24cd939b..8b19291`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-005`
Round 1 outcome: PATCH_REQUIRED (PATCH-01, PATCH-02)

Outcome: PATCH_REQUIRED

## Verdict In One Line

The code is correct and I am accepting it: PATCH-01 and PATCH-02 are genuinely
resolved, the fidelity work holds, and I re-ran the full verification myself
rather than trusting the reported numbers. The one thing blocking this story is
that its own evidence artifact, `visual-fidelity/visual-fidelity-report.md`, was
never updated after the patch and now asserts the opposite of what shipped. That
file merges into the integration branch as the record for this screen, so it
cannot go in stating a false conclusion. See PATCH-03 — it is a documentation
edit only, no code change.

## PATCH-01 — Forgot-password touch target — RESOLVED

File: `mobile/lib/features/auth/presentation/screens/login_screen.dart:270-296`

The link is now wrapped in `ConstrainedBox(constraints: BoxConstraints(minHeight:
tapTarget))`, the exact repo-precedent mechanism named in round 1
(`clause_toggle_row.dart:50`), reading `context.cupidPlatform.tapTarget` rather
than a literal. I traced the layout rather than trusting the test: the
`ConstrainedBox` min-height propagates through `ButtonStyleButton`'s own
`ConstrainedBox` (whose `minimumSize: Size.zero` cannot shrink an incoming
minimum, because `BoxConstraints.enforce` clamps against the incoming
constraints), reaching the `Center(heightFactor: 1.0)` inside the button, whose
`size = constraints.constrain(...)` raises the box to 44/48. The `InkWell` sits
above that box in the chain, so the hit region really is the full height, not
just the painted text. Retaining `MaterialTapTargetSize.shrinkWrap` is correct
here and no longer a regression: it prevents Material's implicit 48pt padding
from double-counting against the explicit token, leaving the `ConstrainedBox` as
the single source of the hit height on both platforms.

The band compensation is sound. `forgotBandGap = max(0, (16*2 +
12.5*1.2 - tapTarget) / 2)` yields 1.5 on iOS (1.5 + 44 + 1.5 = 47, matching the
original `gap:16` + line + `gap:16` band) and 0 on Material, where the 48pt
minimum slightly exceeds the 47pt band. Measured against real font metrics
rather than the nominal 1.2 (SF Pro/Roboto resolve to ~1.17, so the pre-patch
band was ~46.65), the CTA moves down ~0.35pt on iOS and ~1.35pt on Material, and
the link text centre moves ~0.17pt / ~0.67pt. That is inside the tolerance round 1
set and is invisible at any device DPR. The `math.max(0, ...)` floor correctly
prevents a negative gap on Material.

## PATCH-02 — Register link — RESOLVED

File: `mobile/lib/features/auth/presentation/screens/login_screen.dart:379-408`

Same `ConstrainedBox` at `tapTarget`, wrapping the `GestureDetector`
(`HitTestBehavior.opaque`, so the whole box is hit-testable) around `Text.rich`.
`RenderParagraph` applies `constraints.constrain(...)`, so the box becomes 44/48
tall with the text painted at its top edge — which is exactly what is wanted
here: the rendered text stays flush against the 22pt gap above it and the hit
area grows downward into the 40pt of screen bottom padding, where nothing is
painted and nothing else is tappable. Zero pixel movement, confirmed by the new
assertion that `registerLink.top - socialRow.bottom == 22`.

## Independently Re-run Verification

I ran every command myself in the story worktree with Flutter on PATH; these are
my results, not the implementer's report.

| Command | Result |
|---|---|
| `flutter analyze` on the two changed files | `No issues found! (ran in 1.5s)` |
| `flutter test test/features/auth/presentation/screens/login_screen_test.dart` | `+13: All tests passed!` |
| `flutter test test/features/auth test/design_system` | `+63: All tests passed!` |
| `flutter test` (full suite) | `+933: All tests passed!` |

The 4 new tap-target cases are parameterised over both `CupidPlatform` values
and derive their expected minimum from `CupidPlatformTokens`, so they will track
a token change instead of freezing 44/48 as literals. Both assert `>= tapTarget`
on the real laid-out box via `tester.getSize`, which is the right level: it would
catch a regression that removed the `ConstrainedBox` or re-introduced a
shrink-wrapped hit box. No test was weakened or deleted; the counts moved
59 -> 63 and 929 -> 933, consistent with +4 additions and no regressions.

Note for anyone re-deriving the band arithmetic from the tests: the widget-test
font renders a line box exactly equal to `fontSize`, so in-test displacements are
larger than on-device. The band symmetry assertion (`epsilon: 0.5`) is
font-metric independent and holds either way.

## Acceptance Criteria

| AC | Verdict | Basis |
|---|---|---|
| AC 1 — layout/spacing/colour/typography match exactly | MET for the delivered surface, with DEF-01/02/03/04 open | I re-read the locked source myself (`Cupid Screens.dc.html` lines 1425-1457 and the CSS vars at 23-27) and confirmed the screen padding 12/20/40, uniform `gap:16`, header `padding:14px 0 4px`, Nunito 900/27 centred heading, 13px `--tx2` subtitle at +7, `gap:11` field group, `--surf`/`--r-card`/`--shadow` cards at 13/16, 11px/.06em uppercase `--tx2` micro-labels, borderless 16px `--tx` inputs, 12.5/700 `--pink` flush-right forgot link, the 11.5px flanked divider at `margin:2px 0`, the 50px/1.5px `--line`/14px-700 social row, and the 13px `--tx2` register line with pink emphasis at +6. No token drift. |
| AC 2 — deviations corrected, not documented | MET | Every D-01..D-12 entry maps to real code, not a note. |
| AC 3 — form-field states | MET | Empty/focused/filled match lines 1432-1439; `InputBorder.none` correctly removes the Material focus underline against the source's `outline:none`. Error state is unauthored in the source and follows REQ-001 STORY-003 §6 without contradicting it. |
| AC 4 — platform-adaptive CTA | MET | `CupidPrimaryButton` retained, no platform fork in feature code, `no_fork_guard_test` green. |
| AC 5 — no new entry point | MET | `SignInCubit` wiring, `SignInSuccess -> HomeScreen`, `_openForgot`, `_openRegister` untouched by both commits. |

## Blocking Finding

### PATCH-03 — Evidence artifact contradicts the shipped code (documentation only)

File: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-005_login_design_fidelity/visual-fidelity/visual-fidelity-report.md`

The patch commit updated `story_master.md` but not the fidelity report. Three
places are now false:

1. Lines 98-105, "Reviewer Note", still reads: *"Matching the design source
   exactly makes the ... link's hit area its own text box (roughly 17pt tall),
   below the 44/48 `--tap` minimum ... Fidelity was chosen."* The shipped code
   does the opposite, and does so at no fidelity cost. This is the part that
   matters: STORY-003, STORY-004 and the other REQ-002 auth screens are being
   audited in the same wave, and a sibling implementer reading this note would
   reasonably conclude that dropping below `--tap` is the accepted house
   resolution for inline text links. It also invites a resolved question to be
   re-opened at requirement integration review.
2. Line 59, D-07, lists the fix as `padding: EdgeInsets.zero`,
   `MaterialTapTargetSize.shrinkWrap` with no mention of the `--tap`
   `ConstrainedBox` or the `forgotBandGap` compensation — incomplete rather than
   wrong, but it is the row a reader consults for this element.
3. Lines 127-136, Verification, report 59 / 929 / "9 widget tests". The current
   figures are 63 / 933 / 13.

Required: correct the Reviewer Note to record that the `--tap` minimum and AC 1
were both satisfied (hit area expanded into transparent space; no visible
deviation), extend D-07 with the `ConstrainedBox`/`forgotBandGap` mechanism, and
refresh the three verification numbers. No code change is required and no code
re-verification is required — the code carries this reviewer's approval as it
stands at commit `8b19291`.

Re-review scope: the three edits above, in one file. This does not need another
Reviewer spawn; Scrum Master can confirm the edits directly under the
lightweight validation gate and then treat this report's verdict as CLEAN.

## Accepted Deferrals — Unchanged

DEF-01 (`visibility_off` icon, needs a new `CupidIcons` codepoint read from the
bundled font cmap), DEF-02 (biometric row, needs `local_auth` plus platform
config and an open Tech Lead scope question), DEF-03 (brand SVGs, needs a
renderer and a `pubspec.yaml` `assets:` section), DEF-04 (CTA `--grad-hot` /
54px / `--glow` / 16.5px-800 delta in the shared `CupidPrimaryButton`) and
DEF-05 (CTA child slot for the inline spinner) all stand as correctly deferred.

Explicitly confirming the question this round was asked to settle: **DEF-04 is
not a re-block on STORY-005.** `cupid_primary_button.dart` is shared by welcome,
register, forgot and OTP; changing it from inside this story's WriteScope would
silently restyle four screens owned by other REQ-002 stories. AC 4 makes the
adaptive widget authoritative for this screen, and it is satisfied. Routing this
to a dedicated design-system story before REQ-002 integration review closes is
the right resolution.

The distinction that separates DEF-01..05 from PATCH-01..03: the deferrals each
require a file outside this story's WriteScope. All three patch findings were
inside it.

## Scrum Master Lightweight Validation — Addendum

PATCH-03's three required edits (Reviewer Note, D-07 row, Verification
numbers) were applied directly to `visual-fidelity-report.md` under the
lightweight validation gate this reviewer authorized above — no code change,
no re-spawn. Per this report's own instruction ("Scrum Master can confirm the
edits directly under the lightweight validation gate and then treat this
report's verdict as CLEAN"), this story's effective outcome is now CLEAN and
it is merge-eligible.

## Residual Risks

- Until the design-system story lands, this screen's CTA remains visibly off
  source (solid `--pink` at `tapTarget` height vs. 54px `--grad-hot` with
  `--glow`), and the password eye, biometric row and brand marks are absent.
  AC 1 is therefore not fully closed for the login screen at requirement level,
  even though it is closed for everything this story could deliver. Requirement
  integration review should not read STORY-005 as "login is pixel-exact".
- The off-scale constants (12/20/40, 16, 11, 13/16, 27, 50, 12.5) are file-local
  named constants and are now duplicated across several REQ-002 screens.
  `_forgotLineBoxHeight` adds a hardcoded 1.2 line-height assumption that is
  ~2.5% off real SF Pro/Roboto metrics; harmless at this magnitude, but it is a
  layout constant derived from a browser default rather than from the font, and
  it will silently drift if the UI font family changes.
- Verification remains widget-tree assertion based; no rendered-pixel diff
  against the design source was produced, so "match exactly" rests on metric
  equivalence. Acceptable at this tier.
- Build verification only. No device or emulator run.
