# Review Report: STORY-003 Design Fidelity — Splash (Round 2)

Review type: compact-story-review (re-review)
Story: STORY-003 (REQ-002, Scope B) — Lane `mobile`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-003`
Diff baseline: `5502c13` → `d7a17e5` (round-1 report → F-1 closing work)

Outcome: CLEAN

## Scope Gate

Scope gate path:
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-003_splash_design_fidelity/review/scope-gate.md`
(refreshed for this round. The handoff asked for an inline-only scope gate, but
`validate-reviewer-two-phase.sh` requires the separate file with
`Phase: SCOPE_GATE` / `SCOPE_GATE_COMPLETE: YES` even in compact mode, so the
file is written and the summary kept below for readers of this report.)

- Round-1 outcome was `PATCH_REQUIRED` for F-1 only (missing rendered
  design-fidelity evidence). This pass re-reviews F-1 closure.
- Diff since baseline is 5 files, all evidence: `story_master.md`,
  `visual-fidelity/visual-fidelity-report.md`, and three new PNGs.
  **No Dart file changed**, so the implementation the round-1 review already
  cleared is byte-identical.
- Files reviewed: the three PNGs (pixel-analysed, not just listed),
  `visual-fidelity-report.md`, `story_master.md`,
  `data/devops/system/design-fidelity-config.json`, `lib/main_preview.dart`.
- Query keys: `Design-Screen`, `VISUAL_FIDELITY`, AC 1-4, gradient ramp,
  element geometry, two-state capture.
- Phase 2 proceeded; no blocking finding.

## F-1 Closure — Verified

| Requirement | Result |
|---|---|
| `Design-Screen: splash` id present | PASS — line 8 |
| `VISUAL_FIDELITY:` verdict present | PASS — `PASS`, line 9 |
| Design-reference capture committed | PASS — `design-reference-splash-android.png`, 406x900, 154701 B, blob `1be069b` |
| Implemented settled capture committed | PASS — `implemented-splash-emulator-5554.png`, 405x900, 63868 B, blob `ff67de5` |
| Implemented pop-in capture committed | PASS — `implemented-splash-popin-emulator-5554.png`, 405x900, 62922 B, blob `caf1faf` |
| Quantitative per-element comparison | PASS — 10-row geometry table + 7-point gradient ramp |
| Rendered, not asserted-in-prose | PASS — both are real renders (verified by image inspection) |

`design-fidelity-config.json` confirms `ui_surface: true` with a `locked`
`claude-design` source, so the 12e2/12e3 rendered check was genuinely mandatory
and is now satisfied.

### Independent pixel verification

I re-measured the committed PNGs rather than trusting the report's numbers:

- **Gradient** — sampled down the right edge inside each render's own content
  box: max per-channel Δ of 8/255 across the seven sample heights (visually
  imperceptible). The `168deg #7B4FBE → #C2508F 55% → #4E8A87` ramp is
  faithfully reproduced.
- **Dots** — design runs at x `182-189 / 199-206 / 216-223`; implemented
  `182-188 / 198-206 / 215-222`. Exactly three dots, matching diameter and
  17 px pitch (= 9 px dot + 8 px gap at the render scale).
- **Wordmark** — design x `131..276` (146 px), implemented x `130..275`
  (146 px). Identical width and centring.
- **Scale is genuinely matched.** The wordmark and dot pitch agreeing to the
  pixel confirms both renders sit at the same px-per-logical-px, so the size
  comparisons in the report are valid.
- **Two-state claim** — comparing the settled and pop-in captures by region:
  wordmark rows max Δ 180 (16% of pixels differ, i.e. genuinely mid-`popIn`),
  while the pill label rows and plain gradient show max Δ 3-5, at the capture
  noise floor. The pill label band (rows 830-837) is present in **both**
  captures. This is real evidence for deviation 13 — the tap affordance renders
  from the first frame and is not gated on the dwell.
- **Centre-offset explanation checks out.** The design mock's gradient area is
  rows 48..868 (centre 458); the device gradient is rows 0..899 (centre 449.5).
  The difference is 8.5 px, which is exactly the residual the report attributes
  to the mock's chrome model. The implementation centring over the full screen
  is faithful to the design CSS (`min-height:100%`, no safe-area padding).

### Test and build evidence

- Targeted tests **independently re-run by me** in the story worktree:
  `splash_design_fidelity_test.dart`, `splash_screen_test.dart`,
  `no_fork_guard_test.dart` → **12/12 passed, exit 0**. The recorded evidence is
  accurate and current, not stale.
- Debug preview build: recorded as `✓ Built app-debug.apk`. Corroborated
  independently — the implemented PNGs are live `adb exec-out screencap` output
  of the installed app, which cannot exist unless the build and install
  succeeded.
- `lib/main_preview.dart` verified to pin the audited configuration:
  `SplashScreen` mounted at line 390, `Brightness.dark` default at line 515,
  `Locale('vi')` at line 529.

## Non-Blocking Findings — Report Precision

The implementation is correct; these are places where the evidence report claims
more precision than its own data supports. None changes a conclusion. Worth
correcting if the report is reused as a template for the other Scope B stories.

### N-1 — Gradient tolerance stated as 4/255; measured 8/255

The report normalises sample heights against the full 900 px PNG. For the design
render that height includes ~48 px of top and ~31 px of bottom bezel, so its
samples land at a different fraction of the actual gradient. Measured against
each render's own content box the max Δ is 8/255, not 4/255. Still an excellent
match — only the stated figure is optimistic.

### N-2 — "Within 1 px of the design frame's 412x915" compares different boxes

The design PNG's 406x900 includes the device bezel; its screen content is
389x821 px (~395x835 logical). The device viewport is 411.4x914.3 logical. The
px-per-logical scale is the same (independently confirmed above), so element
sizes remain comparable — but the two viewports are not the same size, and the
same-scale conclusion is reached by a coincidence of framing rather than by the
stated arithmetic.

### N-3 — Two minor overstatements in the narrative

- "Correctly sized within ≤3 px" (Verdict) is contradicted by the report's own
  table row `Status line width +8 px`. The +8 px is consistent with text-shaping
  variance between the browser's and Flutter's rasterisation of an 11.5 px
  Vietnamese string — the widget test pins `fontSize: 11.5`, and the wordmark
  and dots match exactly, which rules out a scale or font-size error.
- "The status line and pill bands are byte-identical across both states" —
  measured max Δ is 3-5, i.e. identical within capture noise, not byte-identical.
  Likewise "only the wordmark changes" overlooks the dots, which shift ~6 px
  between captures because `bob` is an infinite animation at a different phase.
  Both are expected and harmless.

## Carried Forward From Round 1 (not re-litigated, not contradicted)

- **F-2 (CARRY-FORWARD)** — `SplashScreen` is not mounted in the shipped launch
  path; at this branch it is reachable only from `lib/main_preview.dart`. The
  round-2 diff touches no routing code, so this stands unchanged. Correctly out
  of STORY-003 scope (AC 4 is a no-change criterion; launch routing is
  STORY-001). **Must be confirmed at the REQ-002 integration review** — if
  STORY-001 does not mount it, no story owns it and the polished splash ships
  unreachable.
- **D-1 (DEFERRED)** — `story_master.md` still records `Complexity: trivial` /
  `Story-Class: trivial` while this handoff again declares `Story-Class:
  standard`. Unresolved; Scrum Master should reconcile. Note the runtime-smoke
  exemption rests on the `trivial` value.
- **Write-scope deviation** — `splash_palette.dart` (new) plus one `export` line
  in `design_system.dart`. Round 1 ruled this an acceptable additive token
  extension matching the `pet_hero_gradient.dart` precedent, forced by the
  `no_fork_guard_test.dart` colour-literal rule. Still disclosed in the report;
  **Scrum Master acknowledgement still outstanding**. No code change needed.

## Acceptance Criteria

| AC | Verdict | Basis |
|---|---|---|
| 1 — layout/spacing/color/typography match in dark + `vi` | **PASS** (was UNVERIFIED) | Rendered design-vs-implemented comparison now exists and holds under independent pixel measurement |
| 2 — deviations corrected in the app, not merely documented | PASS | 18 deviation rows are real code changes, unchanged since round 1 |
| 3 — design source's own loading treatment, no ad hoc spinner | PASS | Dots + status line + pill confirmed in both captured states; test asserts no `CircularProgressIndicator` |
| 4 — no new entry point | PASS | No routing code in the diff; `splash_screen_test.dart` 4/4 green |

## Recommendation

- Story status: ready for `DONE` — F-1 is closed with genuine, quantitative,
  committed rendered evidence.
- Check `Review (Reviewer)` in `story_master.md`.
- Record the write-scope acknowledgement for `splash_palette.dart`.
- Reconcile the D-1 classification mismatch.
- Register F-2 against the REQ-002 requirement integration review.
- N-1 to N-3 are report-accuracy notes only; no rework required and no reason to
  hold the story.

Blocking findings: 0
Non-blocking findings: 3 (N-1, N-2, N-3)
Deferred / carry-forward: 3 (F-2, D-1, write-scope acknowledgement)
