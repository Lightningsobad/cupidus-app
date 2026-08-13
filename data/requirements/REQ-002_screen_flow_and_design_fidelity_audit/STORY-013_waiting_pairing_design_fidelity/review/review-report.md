# Review Report: STORY-013 Design Fidelity — Waiting For Pairing

Review type: `compact-story-review`
Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Story: STORY-013 — `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-013_waiting_pairing_design_fidelity/`
Lane: mobile · Complexity: trivial · Story-Class (handoff): standard
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-013`
BaseHead: `8396273e6a5e6a2798557aa68864f0ef24cd939b` · Implementation commit: `c7a4199`

Outcome: PATCH_REQUIRED

## Scope Gate

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

- Review report path: `.../STORY-013_waiting_pairing_design_fidelity/review/review-report.md`
- Source/test files in scope (from `git diff <BaseHead> --stat`, 4 files):
  - `mobile/lib/features/pairing/presentation/screens/waiting_screen.dart` (+172/-31)
  - `mobile/test/features/pairing/presentation/screens/waiting_screen_design_fidelity_test.dart` (new, 162 lines)
  - `.../STORY-013_waiting_pairing_design_fidelity/story_master.md` (+2/-1)
  - `.../STORY-013_waiting_pairing_design_fidelity/visual-fidelity/visual-fidelity-report.md` (new, 224 lines)
- Evidence files in scope: `visual-fidelity/visual-fidelity-report.md`; `data/devops/system/design-fidelity-config.json`; `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/visual-fidelity/design-reference-waiting-android.png`
- Touched risk surfaces: mobile interaction, mobile navigation/discoverability (AC 4 assertion only), design-token usage
- Critical gates verified: rendered design-fidelity evidence (12e2/12e3), entry-point reachability (12e1), tap targets vs `CupidPlatformTokens`, shared-token/sibling-widget regression, static analysis + widget tests
- Query keys: `WaitingScreen(`, `skyGradient`, `radiusButton`, `tapTarget`, `pulseRing`, `Design-Screen`, `VISUAL_FIDELITY`
- Runtime startup smoke (12g): not required — story `Complexity: trivial`
- Phase 2 proceeded; review completed with blocking findings.

## Outcome Rationale

The code changes themselves are competent and token-disciplined: the `pulseRing`/`bob`
reconstruction, typography roles, padding and the refresh-button styling are all
traceable to the design source and backed by a real widget test. The story fails on
evidence and on the exact text of AC 1, not on code quality.

This story carries **no rendered image evidence at all** and **no `VISUAL_FIDELITY`
verdict line**, while the repository's own design reference for this screen shows
elements the implementation does not render. Under skill rules 12e2/12e3 a prose
comparison is not the artifact, and under rule 14 the acceptance criterion text
controls over a narrowed restatement of it.

## Blocking Findings

### B1 — No rendered visual-fidelity images for this story (rules 12e2, 12e3)

`visual-fidelity/` contains only `visual-fidelity-report.md`. Verified via
`git ls-files -o -c -- <story dir>`: no `implemented-waiting-<device>.png`, no
`design-reference-waiting-<device>.png`.

`data/devops/system/design-fidelity-config.json` records `ui_surface: true` and a
`locked: true` `design_source` (`type: claude-design`, `project_dir:
cupid-app-design-system/project`, `screens_from: canvas`). Neither audited scope-out
applies, so the rendered mobile capture+compare is mandatory and non-waivable.

The report also never emits a top-level `VISUAL_FIDELITY: PASS` / `FAIL` line — the
verdict token the story review gate and the DONE gate both read is simply absent.

Capture is available: `mobile/lib/main_preview.dart:395` already constructs
`WaitingScreen(expiresAt: ...)`, so the preview entrypoint this lane uses for device
capture exists and needs no new code.

- Owner: `@mobile-dev`
- Action: capture the implemented screen on the provided device/emulator and render
  the design reference for the same screen into
  `.../STORY-013_waiting_pairing_design_fidelity/visual-fidelity/`, then add a
  top-level `VISUAL_FIDELITY:` verdict with per-state deltas.

### B2 — Design screen id never resolved; audit cites a file outside the configured entry (rule 12e2)

`story_master.md` records no `Design-Screen: <id>`, and the report identifies its
source of truth as `cupid-app-design-system/project/Cupid Screens.dc.html` lines
1572-1589. The locked config's `entry` is `Cupid App.dc.html` with
`screens_from: canvas`, meaning screens are canvas states addressed by id via
`render-design-canvas.js --screen=<id>`.

The line ranges cited are plausible and internally consistent, but with no resolved
canvas screen id and no rendered reference, the choice of screen is unverifiable by
anyone downstream — which is precisely the failure mode 12e2 names.

- Owner: `@mobile-dev`
- Action: resolve and record `Design-Screen: <id>` in `story_master.md` and the
  visual-fidelity report, and render the reference from that id.

### B3 — AC 1 recorded MET under a substituted standard (rule 14)

AC 1: "layout, spacing, color/token usage, and typography match **exactly with no
visible deviation**."
Report: "AC 1 ... MET **for every element the screen renders**."

Those are different standards. Reading the repository's existing design reference for
this screen
(`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/visual-fidelity/design-reference-waiting-android.png`)
against `waiting_screen.dart`, three elements present in the design are absent from
the build:

| Design element | Status in build | Report's own note |
|---|---|---|
| "Mã của bạn" code card (`--surf`, mono code, `--grad-hot`) | absent | O1, write scope |
| "Gửi lại" gradient primary CTA | absent | O2, write scope |
| `--sky` gradient + twinkle background | absent (flat `colorBackground`) | dismissed as app-shell scope |

Their absence also changes the button row: the design shows two side-by-side buttons,
the build shows one full-width action at `maxWidth: 300`.

The write-scope constraint behind O1/O2 is real and correctly reasoned — threading
`invitation.code` requires `invite_screen.dart:102`, which was outside the declared
scope, and shipping an always-null optional parameter would be worse. The defect is
the bookkeeping: a scope-limited story recorded AC 1 as MET. AC 1 is not met by the
delivered screen.

- Owner: `@scrum-master`
- Action: either widen this story's write scope to include
  `mobile/lib/features/pairing/presentation/screens/invite_screen.dart` so O1/O2 can
  be delivered, or split O1/O2 into a follow-up story and record AC 1 as partially
  met with the split referenced. Do not close AC 1 as MET as written.

## Deferred Findings

### D1 — `skyGradient` is a documentation-only token no screen renders

Verified: `mobile/lib/design_system/tokens/cupid_color_tokens.dart:209` declares
`final String skyGradient`, and the only consumers repo-wide are the token class's own
`copyWith`/`lerp` and `mobile/test/design_system/contrast_test.dart:95,102`. No screen
paints it.

The report's classification is accurate — this is an app-shell gap shared by every
screen in REQ-002, not a `waiting`-specific deviation, and fixing it inside one story
would fork the shell. Route it to a dedicated shell story or the requirement
integration review rather than to STORY-013.

Note that until it is fixed, *no* Scope B story can honestly certify AC 1's "no
visible deviation" — every screen will differ from its reference by the background.
Worth deciding at requirement level before more Scope B stories close.

## Verified Clean (no finding)

- **Tap targets** — the refresh `OutlinedButton` is `height: 50`, above
  `CupidPlatformTokens.tapTarget` for both platforms (`ios() = 44` at
  `cupid_platform_tokens.dart:34`, `material() = 48` at `:55`). It is the screen's only
  interactive element. `context.cupidPlatform.radiusButton` is used correctly
  (`= 999`, pill on both platforms, `:29` and `:50`).
- **No shared-widget regression** — changes are confined to private widgets
  (`_PulsingHold`, `_PulseRing`, `_WaitingView`) inside `waiting_screen.dart`. No
  design-system or shared pairing widget was touched, so invite/joincode/paired are
  unaffected.
- **`_PulseRing` alpha composition is correct** — the `0.7 * (1 - eased)` envelope
  multiplied by the `0.4`/`0.35` border alpha reproduces CSS `opacity` × `rgba()`
  compositing, matching `rgba(255,127,182,.4)` under the `pulseRing` keyframe. This
  reads like a double-dimming bug and is not one.
- **AC 4 (no new entry point)** — independently verified, not taken on trust:
  `git grep "WaitingScreen("` returns `invite_screen.dart:102` (the real push),
  `waiting_screen.dart:20` (the declaration) and `main_preview.dart:395` (preview).
  No routing or `WaitingCubit` polling code appears in the diff.
- **AC 3 (design animation vocabulary)** — met. `CircularProgressIndicator` is absent
  and the test asserts the ring scale actually advances between frames rather than
  merely existing.
- **Static analysis / tests** — the one `flutter analyze` info
  (`prefer_initializing_formals`, line 25) is on the pre-existing `_createWaitingCubit`
  seam, untouched by this diff. Accepted per rule 18 without rerun; the blocking
  findings are evidence-shaped and a rerun would not move them.

## Traceability

| Input | Used for |
|---|---|
| `story_master.md` | complexity, lane, AC 1-4, scope boundaries, OQ5 triage |
| `git diff 8396273 -> c7a4199` | changed-file inventory and read ranges |
| `waiting_screen.dart` | AC 1/2/3 code verification, tap target, token usage |
| `waiting_screen_design_fidelity_test.dart` | AC 3 animation assertion, typography/button assertions |
| `visual-fidelity-report.md` | claimed deviations D1-D7, O1-O3, verification evidence |
| `design-fidelity-config.json` | `ui_surface: true`, locked `design_source`, canvas addressing |
| `design-reference-waiting-android.png` (REQ-001/STORY-018) | independent check of B3's missing elements |
| `cupid_platform_tokens.dart`, `cupid_color_tokens.dart` | tap target, radius, `skyGradient` |

OQ discipline: OQ5 (light theme / `en` locale) is triaged in `story_master.md` with
explicit blocked/not-blocked sections; ACs 1-4 are correctly recorded as unblocked and
the implementation did not over-apply the OQ. No finding.

Configuration guide: not in scope — no setup, environment, or external integration
surface was touched.

## State Recommendation

- Uncheck `Implementation (Development)` in `story_master.md`
- Leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS`
- Return to `mobile-dev` for B1 and B2; `scrum-master` decision required on B3's write
  scope before B3 can be actioned.
