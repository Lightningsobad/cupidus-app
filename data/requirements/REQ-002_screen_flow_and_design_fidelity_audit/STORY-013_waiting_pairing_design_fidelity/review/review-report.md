# Review Report: STORY-013 Design Fidelity — Waiting For Pairing

Review type: `compact-story-review` · Round 3 (patch re-review of B4 / R1 + R2)
Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Story: STORY-013 — `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-013_waiting_pairing_design_fidelity/`
Lane: mobile · Complexity: trivial · Story-Class (handoff): standard
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-013`
BaseHead: `c285e63` · Round 3 commit: `2a92f37` (HEAD, clean worktree)

Outcome: DEFERRED_ONLY

## Scope Gate

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

- Review report path: `.../STORY-013_waiting_pairing_design_fidelity/review/review-report.md`
- Source files in scope (round-3 delta, `git diff c285e63..2a92f37`):
  `waiting_screen.dart` (+300/-73), `waiting_screen_design_fidelity_test.dart` (+95)
- Evidence in scope: `visual-fidelity/visual-fidelity-report.md` (ranged reads),
  `implemented-waiting-emulator-5560.png`, `design-reference-waiting-android.png`,
  round-2 `review-report.md`
- Critical gates: rendered mobile design fidelity (12e2/12e3 — both images opened,
  not counted), entry-point reachability (12e1), AC-1 exact-match discipline (14)
- Runtime smoke (12g): not required — `Complexity: trivial`. The fresh capture
  nevertheless shows the built app running on `emulator-5560` to first frame.
- Query keys: `--sky`, `twinkle`, `_SkyBackdrop`, `_CssEllipse`, `_TwinkleStar`,
  `skyGradient`, `iosShare`, `Color.fromRGBO`, `enableLightTheme`

## Outcome Rationale

The round-2 blocker is genuinely closed, and it is closed in the rendering, not
just in the report. I opened both PNGs rather than reading the `PASS` token: the
implemented capture now carries the purple top-left / magenta top-right / teal
bottom `--sky` wash and the three star particles, and the `ios_share` glyph is
present on the "Gửi lại" pill. Against the reference, no visible deviation
remains beyond the two substitutions triaged and accepted in earlier rounds.

The `--sky` transcription is also correct at the source level, not merely
plausible — see the verification below. The residual concerns are all latent or
architectural, none of them user-visible in the shipped configuration, so they
are deferred rather than blocking.

## Round-2 Finding Closure

| # | Round-2 finding | Status |
|---|---|---|
| B4 / R1 | Missing `ios_share` glyph on the resend CTA | **Closed.** `CupidIcons.iosShare = IconData(0xe6b8, …)` is registered in the shared registry at `cupid_icons.dart:104` — the registry was extended rather than forked, which is what round 2 asked for. `_ResendButton` renders `CupidIcon(CupidIcons.iosShare, size: 19)` + `SizedBox(width: 8)` + a `Flexible` label (`waiting_screen.dart:554-577`). The glyph is visible in the capture, so the cmap claim is confirmed by rendering, not by assertion. Landed before this round's BaseHead. |
| B4 / R2 | Flat `--bg` instead of the `--sky` gradient + star particles | **Closed.** `_SkyBackdrop` is painted as the first child of the body `Stack` (`waiting_screen.dart:104-106`), behind the existing `SafeArea` content. Wash and stars are both visible in the capture. |

### R2 transcription verified stop-for-stop against the source

`Cupid Screens.dc.html:26` defines `--sky` as three CSS radial layers. Each maps
exactly onto its Dart const (`waiting_screen.dart:274-316`):

| CSS layer (line 26) | Dart const | Match |
|---|---|---|
| `120% 70% at 15% -8%`, `rgba(123,47,190,.55)` → `transparent 62%` | `_skyPurpleWash` rx 1.2 / ry 0.7 / cx 0.15 / cy -0.08, stops `[0, 0.62]` | exact |
| `90% 55% at 95% 6%`, `rgba(255,75,140,.32)` → `transparent 60%` | `_skyMagentaWash` rx 0.9 / ry 0.55 / cx 0.95 / cy 0.06, stops `[0, 0.6]` | exact |
| `80% 50% at 50% 108%`, `rgba(0,201,167,.16)` → `transparent 62%` | `_skyTealWash` rx 0.8 / ry 0.5 / cx 0.5 / cy 1.08, stops `[0, 0.62]` | exact |

Three non-obvious details are handled correctly, and each one would have been a
visible defect if handled naively:

- **Layer order.** CSS paints the first-listed background layer on top. The
  `Stack` lists teal → magenta → purple, so purple ends up topmost
  (`waiting_screen.dart:337-351`). Reversed correctly.
- **Fade target.** CSS interpolates to `transparent` in premultiplied space, so
  it does not darken; Flutter's `Color.lerp` interpolates unpremultiplied and
  would fade through black. Each layer instead ends at its own RGB with zero
  alpha. Correct, and the test pins it (`wash.colors.last.r == wash.colors.first.r`).
- **`_CssEllipse` geometry.** I checked the matrix rather than trusting the
  dartdoc. Composition is `T(C) · S(w·rx/R, h·ry/R) · T(-center)` applied to a
  unit `RadialGradient` centered at `bounds.center` with radius
  `R = bounds.shortestSide`. That yields an ellipse centered at
  `(left + w·cx, top + h·cy)` with semi-axes `(w·rx, h·ry)` — exactly the CSS
  ending shape. The translate/scale/translate order is right, and the
  `shortestSide` divisor correctly cancels Flutter's `radius: 1`.

Stars (`Cupid Screens.dc.html:45-47`) also match: `14%/left 8%` 6px `#fff`
3.4s, `9%/right 16%` 4px `#FFD9EA` 4.6s delay .8s, `26%/right 7%` 5px `#CEB4FF`
5.2s delay 1.6s. The source's inline `opacity:.5` on the first star is correctly
ignored — a running CSS animation overrides inline style for animated
properties, so `.25 → 1` from the keyframes is what actually paints.
`twinkle` (line 35) is reproduced as a triangle wave with `Curves.easeInOut`
applied per half-interval, which is what CSS `ease-in-out` does per keyframe
interval; opacity `0.25 + 0.75·eased` and scale `0.85 + 0.3·eased` match the
`0%/100% → 50%` keyframe values.

## Blocking Findings

None.

## On the STORY-032 overlap (handoff question)

The local fix does **not** need to be reverted or deferred, and it will not
create a painful double implementation. Everything R2 added is file-private:
`_CssEllipse`, `_skyPurpleWash`, `_skyMagentaWash`, `_skyTealWash`,
`_SkyBackdrop` and `_TwinkleStar`, plus one line inside the body `Stack`. When
STORY-032 lands a shared app-shell wash, removal is deleting those declarations
and the `Positioned.fill(child: _SkyBackdrop())` line — no caller outside this
file, no exported API, no test outside this story's own test file. Nothing here
should block the merge.

Two notes worth handing to STORY-032 rather than acting on here:

- `_CssEllipse` and `_TwinkleStar` are the genuinely reusable pieces. STORY-032
  should promote them into `design_system/` rather than re-derive the matrix
  math, which is the part most likely to be got subtly wrong a second time.
- STORY-032 should resolve D3 below at the same time, since a shared layer is
  the natural place to read the wash from the active theme.

## Deferred Findings

### D3 (new) — the wash is hardcoded to dark-theme values while the token file defines a distinct light `--sky`

`CupidColorTokens.dark()` and `.light()` carry different `--sky` strings
(`cupid_color_tokens.dart:66-70` vs `130-134`): dark is purple/magenta/teal,
light is pink `rgba(255,182,214,.72)` / lavender `rgba(206,180,255,.6)` / mint
`rgba(178,240,226,.5)`. `_SkyBackdrop` paints the dark triple unconditionally,
so under a light theme the screen would wash a dark purple field over the light
background.

Not user-visible today and correctly out of scope: `themeMode` is
`ThemeMode.dark` unless `CupidFeatureFlags.enableLightTheme` is set
(`cupid_app.dart:35-37`), the flag defaults to `false`, and
`feature_flags_test.dart:62` pins it false. `story_master.md:46-49` also puts
light-theme visual QA out of scope for this story.

It is still worth recording, because that same Out of Scope paragraph asks that
"token-level fixes should stay correct for all 4 combinations" — and this is a
screen-local paint rather than a token-level fix, so it does not inherit that
property. Owner: STORY-032, when the shared layer reads the wash from theme.

### D4 (new) — nine raw color literals now live under `lib/features`, which the no-fork guard's own contract reserves for `design_system/`

`no_fork_guard_test.dart:5-9` states that only `design_system/` may contain a
raw color literal (ADR-004 / `solution.md` D3). `waiting_screen.dart` now holds
nine (lines 277, 278, 292, 293, 307, 308, 357, 366, 376). The guard passes — I
ran it — but only because `_forbiddenPatterns` lists `Color(0x` and `Colors.`
and not `Color.fromRGBO`.

I am not treating this as blocking: the token that should have supplied these
values, `CupidColorTokens.skyGradient`, is an unrenderable CSS `String` that no
screen can consume, which is precisely the gap STORY-032 exists to close, and
the three star colors are theme-invariant inline styles in the source rather
than themed variables. But the gap is real and currently silent. Two follow-ups
for STORY-032: remove these literals as part of the shared layer, and consider
adding `Color.fromRGBO` to `_forbiddenPatterns` so the contract stops being
enforceable only by convention. Note that four pre-existing literals in
`lib/features/gallery/` would need the same treatment before that pattern can be
added.

### D1 (carried from round 2, still open) — `main_preview.dart` formatting churn

Not in the round-3 delta, but still on the branch relative to the integration
target. Every Scope B story registers a screen in the same `previewScreens` map,
so the whole-file reformatting still raises merge-conflict cost against
siblings. `@scrum-master` merge-ordering attention; no correctness impact.

### D2 (carried from round 2, still open) — share clipboard payload duplicated

`waiting_screen.dart:519` and `invite_screen.dart:67-70` independently build
`'Cupid: $code\nhttps://cupid.app/pair?code=$code'`. Verified still identical
today; they will drift when the pairing deep-link changes. Extract to a shared
constant in a follow-up.

## Verified Clean (no finding)

- **Rendered fidelity (12e3).** Both images opened directly. The implemented
  capture is the built app on `emulator-5560` showing this story's screen —
  correct wash, correct stars, correct share glyph, hourglass pulse field, "Mã
  của bạn" card with the `--grad-hot` code text, two-button row. The two
  remaining text differences against the reference ("Đang chờ người ấy..." vs
  the mockup's hardcoded "Đang đợi Linh vào…", and "Làm mới" vs the
  prototype-only "Giả lập: Linh vào") are the substitutions already triaged and
  accepted in round 2, not new deltas.
- **Pulse-ring difference is animation phase, not a defect.** The outer ring
  reads fainter and wider in the capture than in the reference render. That is
  the `pulseRing` 2.4s expand-and-fade loop sampled at a different phase; the
  keyframes themselves were verified in round 2.
- **Subtitle wraps one word earlier** than the reference (`maxWidth: 270` vs the
  mockup's width). Both render as two centered lines with identical copy,
  typography and color. Reflow, not a token deviation — not raised as a finding.
- **Static analysis.** Re-run on `lib/features/pairing`: 9 issues, all
  `prefer_initializing_formals` infos on pre-existing constructor seams this
  diff does not touch. No errors, no warnings, nothing introduced by the delta.
  (The commit message's "one pre-existing info" undercounts the per-directory
  run; immaterial to the verdict.)
- **Tests re-run, not accepted on report.** `no_fork_guard_test.dart` 1/1 passed;
  `waiting_screen_design_fidelity_test.dart` 7/7 passed, including the new
  `paints the --sky wash and twinkle stars over --bg` case. The new test is
  substantive rather than tautological: it pins layer order, per-layer stops,
  the zero-alpha same-hue fade, star colors, star centers measured at 800x600
  (`64+3, 84+3` etc., correct against the CSS percentages), and two points on
  the twinkle curve. I re-derived the `0.625` expectation at 850ms of a 3400ms
  period independently — it is right.
- **AC 4 (no new entry point).** The round-3 diff touches only
  `waiting_screen.dart` and its test. No routing, no `WaitingCubit`, no
  `invite_screen.dart` change. Reachability is unchanged from the round-2
  verification at `invite_screen.dart:97-104`.
- **AC 3 (design animation vocabulary).** Strengthened this round — `twinkle` is
  now a third source keyframe reproduced rather than invented, alongside
  `pulseRing`/`bob`.
- **Backdrop does not affect behavior or a11y.** `_SkyBackdrop` sits behind the
  content in the body `Stack`; `DecoratedBox` does not set `hitTestSelf`, so
  taps pass through, and `DecoratedBox`/`SizedBox`/`Opacity`/`Transform` emit no
  semantics nodes, so nothing new is announced. Controllers are disposed
  (`_TwinkleStarState.dispose`).

## Traceability

| Input | Used for |
|---|---|
| round-2 `review-report.md` | exact B4/R1/R2 text, D1/D2 carry-over |
| `story_master.md` | ACs 1-4, complexity, light-theme Out of Scope (D3) |
| `git diff c285e63..2a92f37` | round-3 changed-file inventory and read ranges |
| both `visual-fidelity/*.png` | 12e3 image verification — B4 closure |
| `visual-fidelity-report.md:1-70` | verdict line, round/config framing |
| `Cupid Screens.dc.html:26,35,44-47` | `--sky`, `twinkle`, star particle transcription check |
| `waiting_screen.dart:104-106,233-445,508-584` | backdrop, matrix, twinkle, resend CTA |
| `cupid_color_tokens.dart:66-70,130-134` | dark vs light `--sky` divergence (D3) |
| `cupid_icons.dart:100-104` | `iosShare` registry entry (R1 closure) |
| `no_fork_guard_test.dart:5-23` | guard contract vs `Color.fromRGBO` gap (D4) |
| `cupid_app.dart:35-37`, `feature_flags_test.dart:62` | light theme flag-off (D3 severity) |

OQ discipline: OQ5 triage unchanged and still correct — D3 is recorded inside
that triage, not used to reopen it. Configuration guide: not in scope — no
setup, environment or external integration surface touched.

## State Recommendation

- Mark `Implementation (Development)` checked in `story_master.md`
- Mark `Review (Reviewer)` checked
- Story status: eligible for `DONE` (`Outcome: DEFERRED_ONLY`)
- Story branch is merge-eligible into
  `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`; sequence it
  against sibling Scope B stories with D1 in mind
- Hand D3 and D4 to STORY-032 as inputs to the shared app-shell wash
