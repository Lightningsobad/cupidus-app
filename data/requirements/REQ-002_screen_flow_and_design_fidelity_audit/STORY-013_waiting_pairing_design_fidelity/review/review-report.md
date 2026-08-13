# Review Report: STORY-013 Design Fidelity — Waiting For Pairing

Review type: `compact-story-review` · Round 2 (patch re-review of B1, B2, B3)
Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Story: STORY-013 — `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-013_waiting_pairing_design_fidelity/`
Lane: mobile · Complexity: trivial · Story-Class (handoff): standard
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-013`
BaseHead: `8396273` · Round 1 commit: `c7a4199` · Round 2 commit: `fbc873d` (HEAD, clean)

Outcome: PATCH_REQUIRED

## Scope Gate

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

- Review report path: `.../STORY-013_waiting_pairing_design_fidelity/review/review-report.md`
- Source files in scope (round-2 delta, `git diff c7a4199 fbc873d`):
  `waiting_screen.dart` (+166/-21), `invite_screen.dart` (+2/-4),
  `main_preview.dart` (+68/-72), `waiting_screen_design_fidelity_test.dart` (+101)
- Evidence in scope: `visual-fidelity/visual-fidelity-report.md` (ranged reads),
  both PNGs in `visual-fidelity/`, `data/devops/system/design-fidelity-config.json`,
  round-1 `review-report.md`
- Critical gates: rendered mobile design fidelity (12e2/12e3 — images opened, not
  counted), entry-point reachability (12e1), AC-1 exact-text discipline (14)
- Runtime smoke (12g): not required — `Complexity: trivial`. The capture in
  evidence item 6 nevertheless shows the app launching to first frame on
  `emulator-5554` without a crash or error screen.
- Query keys: `VISUAL_FIDELITY`, `Design-Screen`, `--grad-hot`, `_CodeCard`,
  `_ResendButton`, `code:`, `ios_share`, `--sky`

## Outcome Rationale

All three round-1 findings were addressed as findings, and the code delivered
this round is sound. The story still cannot pass because the evidence it now
carries says so: `visual-fidelity-report.md:11` records `VISUAL_FIDELITY: FAIL`.
Under rule 12e2 a `FAIL` verdict is `PATCH_REQUIRED`, and I independently
confirmed both residual deltas by opening the two images rather than reading the
verdict token — they are real and visible, not bookkeeping.

The self-reported FAIL is the correct and honest call. R1 is closable inside this
story with a small scope widen. R2 is not closable by any single Scope B story and
needs a requirement-level decision before this story can be routed again — see the
escalation below, which is the actual thing blocking closure.

## Round-1 Finding Closure

| # | Round-1 finding | Status |
|---|---|---|
| B1 | No rendered images, no `VISUAL_FIDELITY` line | **Closed as an artifact obligation.** Both PNGs exist, open as real images, and a top-level verdict line is present. The verdict is `FAIL`. |
| B2 | Design screen id never resolved | **Closed.** `Design-Screen: waiting` recorded at `story_master.md:13` and report line 8. I opened `design-reference-waiting-android.png`: it depicts the hourglass pulse field, "Đang đợi Linh vào…", the "Mã của bạn" card and the two-button row — this is genuinely the waiting screen, not a neighbouring canvas state. |
| B3 | AC 1 recorded MET under a substituted standard | **Closed.** The code card and resend CTA are now built, rendered and tested; the report no longer claims AC 1 fully met and names R1/R2 as explicitly not met. The write-scope widen touched exactly one line, `invite_screen.dart:101` (`code: invitation.code`) at the existing `WaitingScreen(...)` construction. |

## Blocking Findings

### B4 — `VISUAL_FIDELITY: FAIL`: two visible deltas against the design reference (rules 12e2, 14)

Confirmed by reading `implemented-waiting-emulator-5554.png` against
`design-reference-waiting-android.png` directly:

- **R1 — missing `ios_share` glyph.** The reference's "Gửi lại" pill carries a
  share glyph before the label; the build's pill shows the label alone. Closable
  here: mobile-dev verified `ios_share` at `0xe6b8` in the bundled
  `MaterialSymbolsRounded-Variable.ttf` cmap. Fix is one registry line in
  `cupid_icons.dart` plus a `Row` + `SizedBox(width: 8)` + `CupidIcon(size: 19)`
  in `_ResendButton`. Inlining a raw `IconData` in the feature file was correctly
  refused — that would fork the registry `no_fork_guard_test` protects.
  - Owner: `@mobile-dev`, after `@scrum-master` widens `WriteScope` to
    `mobile/lib/design_system/icons/cupid_icons.dart`.
- **R2 — flat `--bg` instead of the `--sky` gradient + star particles.** The
  reference's upper field is a purple/magenta radial wash with star particles
  (`--sky`, three `radial-gradient` layers at `Cupid Screens.dc.html:26`); the
  build paints flat `colorBackground`. This is the dominant visible difference
  and is why the verdict is FAIL rather than PASS.
  - Owner: `@scrum-master` / REQ-002 requirement level. **Not** actionable by
    this story — see the escalation.

AC 1 requires "match **exactly** with no visible deviation". Two visible
deviations remain, so AC 1 is `FAIL` under rule 14. The report states this
accurately.

## Escalation — R2 blocks every Scope B story, not just this one

Round 1 raised this as D1 and it is now the binding constraint.
`CupidColorTokens.skyGradient` is a documentation-only `String` that no screen
paints, so every Scope B screen will differ from its reference by the background.
Routing STORY-013 back for "fix the FAIL" without resolving R2 produces a loop:
mobile-dev can close R1, and the verdict will still be FAIL.

Sibling Scope B stories (STORY-005, 006, 014, 015, 028) already closed `DONE`. I
could not compare their verdicts from inside this worktree — only STORY-013's
fidelity report is tracked on this branch — so `@scrum-master` should check
whether they recorded `PASS` against the same app-shell gap. If they did, the
requirement has an inconsistency to settle either way.

Two viable resolutions, both requirement-level:

1. Route an app-shell story that paints `skyGradient` at the root, then re-render
   the affected Scope B screens; or
2. Record an explicit REQ-002 scope decision that the shared app-shell background
   is excluded from per-screen fidelity, so per-story verdicts are judged on
   screen-owned elements only — and re-scope R2 out of this story's AC 1.

Under (2) this story would need only R1 before re-review.

## Deferred Findings

### D1 — `main_preview.dart` carries 140 lines of `dart format` churn for a one-line change

The only semantic edit is `code: 'CPD-8F2K'` on the `waiting` preview entry
(properly disclosed by the implementer as an out-of-`WriteScope` dev-only edit,
and legitimate — it is what lets the capture evidence the new card). The rest is
whole-file reformatting. Every Scope B story registers a screen in the same
`previewScreens` map, so this raises merge-conflict cost against siblings on
`codex/REQ-002...-integration`. Worth `@scrum-master` merge-ordering attention;
no correctness impact.

### D2 — share clipboard payload now duplicated verbatim in two files

`waiting_screen.dart` `_ResendButton._resend` and `invite_screen.dart:67-70`
independently build `'Cupid: $code\nhttps://cupid.app/pair?code=$code'` with the
same announcement string. Matching today, verified; they will drift when the
pairing deep-link URL changes. Extract to a shared constant in a follow-up.

## Verified Clean (no finding)

- **Both images are real and correct.** The implemented capture is the built app
  on `emulator-5554` showing this story's screen — not a placeholder, spinner,
  error frame or wrong screen.
- **`--grad-hot` sweep is correct.** The build's pink→purple CTA and code-text
  gradient initially read as a delta against the reference; it is not.
  `Cupid Screens.dc.html:23` defines
  `--grad-hot:linear-gradient(120deg,#FF7FB6,#B78CF5)`, and `colors.gradientHot`
  reproduces it. The reference's lighter right edge is the `--glow` bloom.
- **`_CodeCard` transcription** — `colorSurface`, 20dp radius (no token covers
  it), `elevationShadow`, `26/14` padding, 11px muted label, `labelMono` at
  `26`/`w500`, `letterSpacing: 26 * 0.14` = 3.64, and `ShaderMask(srcIn)` as the
  Flutter equivalent of `background-clip:text`. All match the source.
- **Nullable `code` handling** — card and CTA are both suppressed when `code` is
  null, the row collapses to the single refresh action, and a test pins the
  fallback so it cannot start rendering an empty card.
- **AC 4 (no new entry point)** — independently re-verified at
  `invite_screen.dart:97-104`: the existing `Navigator.push` to `WaitingScreen`
  gained one named argument and nothing else. No routing or `WaitingCubit`
  change in the diff.
- **AC 3 (design animation vocabulary)** — met; `pulseRing`/`bob` reproduced,
  confirmed in the capture as well as the widget test.
- **Static analysis / tests** — 4 `prefer_initializing_formals` infos, all on
  pre-existing constructor seams this diff did not touch; `flutter test` 76/76
  (was 73/73, +3 exactly the new cases). Accepted per rule 18 without rerun.

## Traceability

| Input | Used for |
|---|---|
| `story_master.md` | ACs, complexity, lane, `Design-Screen: waiting` (B2 closure) |
| round-1 `review-report.md` | exact B1/B2/B3 text and D1 carry-over |
| `git diff c7a4199 fbc873d` | round-2 changed-file inventory and read ranges |
| both `visual-fidelity/*.png` | 12e3 image verification — B1/B2 closure, B4 deltas |
| `visual-fidelity-report.md` | verdict line, D1-D9, R1/R2, verification evidence |
| `design-fidelity-config.json` | `ui_surface: true`, locked source — no scope-out applies |
| `Cupid Screens.dc.html:23,26` | `--grad-hot` and `--sky` definitions |
| `waiting_screen.dart`, `invite_screen.dart:55-104` | code verification, payload parity |

OQ discipline: OQ5 triage unchanged and still correct; ACs 1-4 unblocked, no
over-application. Configuration guide: not in scope — no setup, environment or
external integration surface touched.

## State Recommendation

- Leave `Implementation (Development)` unchecked in `story_master.md`
- Leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS`
- Resolve the R2 escalation at requirement level FIRST, then return to
  `@mobile-dev` for R1 with `cupid_icons.dart` added to `WriteScope`. Re-routing
  for R1 alone will not clear the FAIL verdict.
