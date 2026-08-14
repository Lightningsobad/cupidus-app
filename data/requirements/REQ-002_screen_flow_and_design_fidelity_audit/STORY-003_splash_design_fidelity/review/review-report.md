# Review Report: STORY-003 Design Fidelity — Splash

Story: STORY-003 Design Fidelity — Splash
Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Mode: compact-story-review
Round: 3 (supersedes round 1 at `d7a17e5` and round 2 `BLOCKED/WORKTREE_MISSING`)

Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-003`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-003`
BaseHead: `c60876f0679bdf87681c45b7d5535f8702b0accd`
HEAD reviewed: `f8efd21fe3a3f7071c1d39c9882753a6d1eb82f0`

Outcome: CLEAN

## Scope Gate

Worktree confirmed healthy: `git status --porcelain=v2 --branch` reports a
clean tree on the expected branch with HEAD at the expected
`f8efd21fe3a3f7071c1d39c9882753a6d1eb82f0`. Neither prior round's report was
treated as authoritative; this round reviews current HEAD fresh.

Six files changed since BaseHead, all inside STORY-003 scope (limit 8):

| File | Change |
|---|---|
| `mobile/lib/features/auth/presentation/screens/splash_screen.dart` | +48 / −65 — re-wires the visual fix into `build()` |
| `mobile/test/features/auth/presentation/splash_screen_test.dart` | +91 — three appended design-fidelity tests |
| `mobile/test/features/auth/presentation/screens/splash_design_fidelity_test.dart` | deleted (220 lines) in `f8efd21` |
| `.../visual-fidelity/visual-fidelity-report.md` | rewritten for this round |
| `.../visual-fidelity/implemented-splash-emulator-5554.png` | re-captured |
| `.../visual-fidelity/implemented-splash-popin-emulator-5554.png` | deleted |

No implementation code outside splash was touched. `initState`, `dispose`,
`_tryNavigate` and the ADR-5 invariant-2 comment are unchanged in the diff,
so STORY-001's routing surface is untouched.

## Dead-Code Regression Check (the reason this round exists)

BaseHead left STORY-003's visual work unreachable from `build()`. At HEAD the
fix is wired in: `splash_screen.dart:142-174` renders
`SplashPalette.background`, and the `Stack` reaches `_BreathingGlow`
(`:153`), `_Wordmark` (`:158`), `_BobbingDots` (`:160`) and `_StatusLine`
(`:167`). Every widget declared in the file is reachable from `build()`; the
former `_TapToContinue` is gone, replaced by `_StatusLine`.

## AC4 / ADR-6 Tap-Affordance Boundary

Verified. A scan of `splash_screen.dart` for `GestureDetector`, `InkWell`,
`onTap`, `TapToContinue`, `Chạm để tiếp tục` and `Tap to continue` returns a
single hit — the explanatory doc comment at `:366` stating the pill is
deliberately not reproduced. No gesture affordance gates navigation. The only
`IgnorePointer` is decorative, inside `_BreathingGlow` (`:266`).

Test coverage holds: `splash exposes no tap-to-continue path off the checking
state (AC4, ADR-6)` passes unmodified, and the new `splash status line uses
the design source caption treatment with no tap-affordance pill (AC1, AC3,
ADR-6)` asserts no `SplashPalette.pillFill` box is painted anywhere.

## Verification Re-run By Reviewer

Both gates were re-run in the worktree rather than taken on report:

| Command | Result |
|---|---|
| `flutter analyze lib/features/auth/presentation/screens/splash_screen.dart test/features/auth/presentation/splash_screen_test.dart` | 2 issues, both `info • prefer_initializing_formals` at `splash_screen.dart:38:8` and `:39:8`. Both sit on STORY-001's constructor, outside this diff. 0 errors, 0 warnings. |
| `flutter test test/features/auth/presentation/ test/design_system/no_fork_guard_test.dart` | `00:02 +62: All tests passed!` — includes the 9 splash tests and the color-literal fork guard. |

Matches the implementer's reported evidence.

## Acceptance Criteria

- **AC1** (layout/spacing/color/typography match in dark + `vi`) — MET. The
  two rendered captures agree on gradient ramp, glow orb, wordmark and dot
  row. The report's geometry table accounts for each residual (chrome model,
  `--safe-bot` inset, frozen-vs-live animation phase) with predicted values
  that land within 1 px of measurement.
- **AC2** (deviations corrected in code, not merely documented) — MET. All 15
  table rows are code changes in `splash_screen.dart`, each visible in the
  diff and pinned by a passing assertion or the device capture.
- **AC3** (design source's own loading treatment, no ad hoc spinner) — MET.
  Bobbing dots plus status line only; no `CircularProgressIndicator` in the
  diff or the capture.
- **AC4** (no new entry point) — MET, per the boundary check above.

The tap pill's omission is a deliberate, correctly-reasoned deviation: ADR-6
removed the affordance, so painting a dead pill would advertise an
interaction the screen does not offer. The report states this explicitly and
carries the resulting 56 px status-line offset as an explained consequence,
not silent drift. The story's "twinkling stars" wording is also correctly
resolved in favour of the locked design source, which declares no star field.

## Findings (all NON-BLOCKING)

1. **Stale evidence citation in `story_master.md`.** Lines 19-21 still list
   `visual-fidelity/implemented-splash-popin-emulator-5554.png`, which this
   round deleted. Scrum Master owns that file and should correct the bullet
   to the two-image set before marking the story DONE. Already self-reported
   by the implementer.
2. **`visual-fidelity-report.md` "Known failing test outside this write
   scope" (lines 283-298) is stale.** It says the file was left in place and
   raised as a blocker; commit `f8efd21` deleted it. The deletion itself is
   correct and well-justified — the file no longer compiled and asserted the
   discarded design.
3. **Coverage re-homing is narrower than the report claims.** Line 296 says
   the deleted file's still-valid assertions were re-homed. Three geometry
   assertions were not: glow orb 150 px at `top 22%` / `left 14%`, dot
   diameter 9 px with 8 px gaps, and the bottom block's 26 px safe-area
   offset. Those values are present in the code and measured in the device
   capture, so no AC is unevidenced, but the widget-test net is thinner than
   before. Worth a follow-up test if REQ-002 later regresses splash geometry.
4. **`SplashPalette.pillBorder` is now referenced by nothing** in `lib/` or
   `test/` (`pillFill` survives as the negative assertion). Removing it needs
   a write-scope extension; correctly escalated rather than taken
   unilaterally.

None of these block the story: all four are documentation or cleanup items,
and none contradicts shipped behaviour.

## Residual Risks

- The `popIn` entrance is verified by curve mapping and `_Wordmark`'s code
  rather than by a captured mid-animation frame. The report's explanation
  (capture round-trip is slower than the 700 ms animation) is credible and no
  AC depends on photographing it.
- `mobile/test/features/reminders/reminder_copy_guard_test.dart` fails on
  STORY-009's `permissions_screen.dart`. Confirmed outside this story's diff;
  routed to Scrum Master, not a STORY-003 defect.

REVIEW_COMPLETE
