---
story_status_recommendation: "DONE"
implementation_status_recommendation: "KEEP_CHECKED"
reviewed_at: 2026-08-25
reviewed_by: Reviewer
---

# Review Report: STORY-007 `--sky` Global Screen Backdrop Rollout

Outcome: DEFERRED_ONLY

## Reviewed Inputs

- Review gate: `compact-story-review`
- Scope Gate: `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-007_sky_backdrop_theme_rollout/review/scope-gate.md`
- Requirements: `../story_master.md` — `## Acceptance Criteria` (AC1-AC3 as
  patched by OQ-1/OQ-3), `## Open Question Impact` (OQ-1, OQ-2, OQ-3)
- Bug Report: `N/A`
- Diagnosis: `N/A`
- Fix Evidence: `N/A`
- UX: read indirectly — `../ux/uiux-spec.md` §3/§5 are quoted by the phase file
  and by the guard's own doc comments; not loaded whole for this compact gate
- Architecture: read indirectly — AD-3/AD-4/AD-5/AD-6 are quoted verbatim in
  `story_master.md` OQ-1/OQ-3, `master-plan.md` `## 2A`/`## 3A`, and the phase
  file; the executing copy of AD-3 is the `_allowlist` constant, which was read
  directly
- Coding Plan: `../coding-plan/master-plan.md`,
  `../coding-plan/phase-P1-backdrop-occlusion-guard-and-probes.md`
- Test Results: `../coding-plan/test-results.md`
- Previous review findings: `N/A`

## Reviewed Scope

- Story complexity: `complex`
- Bug status: `N/A`
- Code scope reviewed:
  - `mobile/test/design_system/shared_backdrop_occlusion_guard_test.dart` (new, read in full)
  - `mobile/test/design_system/shared_backdrop_occlusion_test.dart` (diff vs `BaseHead`, read in full)
- Evidence reviewed: `../coding-plan/test-results.md`; all four AD-6 PNGs opened
  and inspected visually, not merely listed
- Risk surfaces reviewed: all six rows of `master-plan.md` `## 3A`
- Critical gates reviewed: the seven gates enumerated in the scope gate, each
  re-measured by the Reviewer except the APK build (see Risk Surface table note)
- Backend targeted verification gates: `NOT_APPLICABLE`
- Story runtime startup smoke: `PASS` (scoped — zero production delta, see below)
- Frontend targeted verification gates: `NOT_APPLICABLE`
- Frontend discoverability/navigation integration: `NOT_APPLICABLE`
- Requirement frontend visual audit: `NOT_APPLICABLE`
- Mobile targeted verification gates: `PASS`
- Mobile discoverability/navigation integration: `PASS` — no entry point added or
  changed; every probe target is an existing reachable screen and the pair-gate
  probe mounts the real `PairGateShell` -> `AppShell` -> `HomeScreen` composition
  rather than a extracted sub-widget
- Requirement mobile visual audit: `PASS` at story scope (four AD-6 captures);
  requirement-level audit remains REQ-010 integration-review scope
- Story artifacts reviewed: `story_master.md`, `master-plan.md`, phase P1 file,
  `test-results.md`, `visual-evidence/`
- Bug artifacts reviewed: `N/A`
- OQ context reviewed: OQ-1 (RESOLVED, two allowlist entries), OQ-2 (RESOLVED,
  scope reframing — judge against verification-and-guard, not "build a new
  primitive"), OQ-3 (RESOLVED, third allowlist entry)

## Outcome Summary

- Review outcome: DEFERRED_ONLY
- Rationale: every acceptance criterion is met and every gate is green under the
  Reviewer's own re-measurement, not only under the implementer's report. The
  hard constraint of this story — a zero-file `mobile/lib/**` change surface — is
  verified empty against `BaseHead`. The guard is well-built: depth-1-only
  argument scanning, string/comment/interpolation-aware, an explicitly documented
  blind spot, and a non-empty-inventory assertion so a broken path cannot pass as
  clean. Six findings are deferred; none of them is caused by this story's code
  and none of them is reachable inside its zero-lib-change constraint. Two of the
  six (D3, D4) are gaps in *recorded* evidence rather than in the work itself,
  and both were closed by direct Reviewer re-measurement, so they do not withhold
  approval.
- Blocking findings: 0
- Deferred findings: 6
- Dismissed observations: 1

## Traceability Summary

- Requirements:
  - story AC1 (reusable primitive, not per-screen duplication) -> already
    satisfied by shipped code; documented at `mobile/lib/app/cupid_app.dart:58-59`
    (`MaterialApp.builder` mounts `CupidAppBackground` above the `Navigator`) and
    `mobile/lib/design_system/theme/cupid_theme.dart:45`
    (`scaffoldBackgroundColor: Colors.transparent`). Per OQ-2 this is
    documentary, not new work.
  - story AC2 (every screen outside the ratified allowlist paints the wash) ->
    `shared_backdrop_occlusion_guard_test.dart` test 1, whole-inventory,
    0 violations across 38 production files; plus 10 runtime pixel probes.
  - story AC3 (no visual regression) -> AD-6 targeted pass, two intersections,
    four captures.
  - phase AC1-AC6 -> mapped row by row in the Risk Surface Gate Summary below.
- Bug report: `N/A`
- Diagnosis: `N/A`
- Open Questions: OQ-1, OQ-2, OQ-3 all RESOLVED before implementation; none
  reopened by the implementation, and the escalation rule (a fourth occluder must
  be escalated, never self-allowlisted) was correctly not triggered because the
  scan found no fourth occluder.
- Testing evidence: `../coding-plan/test-results.md` plus the Reviewer's
  independent re-runs recorded below.

## Independent Verification Performed By Reviewer

All commands run in the declared worktree at HEAD `32ce531`, with
`PATH="$HOME/flutter/bin:$PATH"`:

| Check | Command | Reviewer result |
|---|---|---|
| Production change surface (AC5) | `git diff --stat 964fc65e8e474ea4befa1389fffca1c466ea6920 HEAD -- mobile/lib` | Empty — ZERO files. Confirmed. |
| Committed change surface | `git diff --name-status 964fc65e8e474ea4befa1389fffca1c466ea6920 HEAD` | 7 files: 2 test, 1 test-results.md, 4 PNGs. Nothing outside the phase Write Scope. |
| Worktree cleanliness | `git status --porcelain` | Clean before the Reviewer wrote this report. |
| Guard + probes | `flutter test test/design_system/shared_backdrop_occlusion_guard_test.dart test/design_system/shared_backdrop_occlusion_test.dart` | `+12: All tests passed!`, EXIT=0. |
| Analyze (story files) | `flutter analyze test/design_system/shared_backdrop_occlusion_test.dart test/design_system/shared_backdrop_occlusion_guard_test.dart` | `No issues found!`, EXIT=0. |
| Full suite | `flutter test --reporter failures-only --no-pub` | `+1392 ~2: All other tests passed!`, EXIT=0. Exactly matches the implementer's claim. |
| Capture harness removed | test names emitted by the probe file in the run above | 10 permanent probes only; no `capture …` case, no `dart:io`/`dart:math` import in the committed probe file. Confirmed. |
| Probe helper unweakened (AC4) | `git diff <BaseHead> HEAD -- .../shared_backdrop_occlusion_test.dart` | Pure addition. `_expectSharedBackdropShowsThrough` and the six STORY-046 probes (AC2-AC7) have zero removed or modified lines. The `occluded.g > 0.5` negative control is intact. |
| AD-6 captures are real renders | opened all four PNGs | All four are genuine 430x932 dark+`vi` renders showing the wash, not splash frames or blanks. The pair-gate capture shows the couple hero present, confirming the `StubAccountRepository` probe-target fix landed. |

`flutter build apk --debug` was **not** re-run by the Reviewer, deliberately. The
APK build does not compile the test tree, and `mobile/lib/**` is byte-identical to
`BaseHead`, so a re-run would re-measure `BaseHead` rather than this story. The
implementer's two recorded green runs are accepted on that basis. The gates that
actually cover this story's change surface — analyze on the two test files and
the full test suite — were both re-measured directly.

## Risk Surface Gate Summary

| Risk Surface | Source Of Truth | Critical Gate | Result | Notes |
|--------------|-----------------|---------------|--------|-------|
| Someone "implements" the story literally and adds a second wash per screen | `master-plan.md` `## 2B` constraint 1; phase AC5 | `git diff -- mobile/lib` empty vs `BaseHead` | PASS | Re-measured by Reviewer. Empty. `CupidAppBackground` still has exactly one production mount point. |
| Guard written too broadly and flags legitimate component fills | phase AC2; `solution.md` §3.3 | 0 violations across the real tree | PASS | 38 production files, 0 violations. Depth-1-only scanning (`_depthOneArguments`) is what buys this, plus the `_alphaModulated` narrowing that keeps `paired_screen.dart` / `vow_screen.dart` translucent accents from becoming permanent false positives. |
| Guard written too narrowly and misses a computed opaque fill | accepted limit, phase Task 2 | limit documented in the guard header + AD-5 probes cover it | PASS | The header states the blind spot plainly (computed colour, conditional branch, partially-faded fill, deeply-buried full-bleed container) and names the runtime probes as the compensating control. `_alphaModulated`'s own doc comment separately calls out the partially-faded-stops case. Honest, not hand-waved. |
| Allowlist becomes a dumping ground | phase AC3; AD-3 | inline rationale per entry + freshness test | PASS | Three entries, each with a design-source or product-judgment citation and its ratifying OQ. Freshness test re-verified green. |
| New probe fails on `everyElement(isNull)` inside nested shells | phase AC4; AD-5 blocking constraint | 4 new + 6 existing probes green, helper unweakened | PASS | 10/10. The one probe failure during implementation (pair-gate negative control at `0.1058`) was correctly diagnosed as a harness defect — the probe pixel had slid onto an entry card because `AppShell` mounts `const HomeScreen()` with no `resolveProfile` seam — and fixed by making the harness render production's shape, **not** by lowering the `> 0.5` threshold. That is exactly the discipline the phase file demanded. |
| Scope disagreement: AC2 "every screen" vs. the allowlist | OQ-1 + OQ-3, RESOLVED pre-planning | N/A | PASS | AC2 patched; three entries ratified; no fourth occluder found, so the escalation rule was correctly never triggered. |
| AD-6 intersection 1 — top-third text contrast | phase Task 4.1 | measured WCAG ratios vs worst-case wash pixel | PASS with DEFERRED | `--tx` `#F7EEFB` at 5.87:1 clears AA. `--tx2` `#B4A6CE` at 2.94:1 does not — see D1. |
| AD-6 intersection 2 — home hero-glow double-stack | phase Task 4.2 | no banding / no over-brightness / no clipping | PASS | Independently confirmed from `ad6-home-hero-glow-dark-vi.png`: the hero glow's falloff blends into the shared magenta lobe with no stepped rings, the overlap core retains gradient detail rather than flattening to a saturated patch, and the `ClipRect` at `home_screen.dart:303` holds the glow inside the hero block. |
| Story runtime startup smoke | `AGENTS.md` scoped-smoke rule | scoped to impacted app | PASS | Correctly scoped. With a zero-file production change surface the shipped runtime is bit-identical to `BaseHead`, so there is no runtime delta to smoke; the compile-and-package path was still exercised via the APK build. No device launch claimed, and none is owed. |

## Blocking Finding Verification

- `N/A` — first review, no previous `PATCH_REQUIRED` findings.

## Blocking Findings

- None.

## Deferred Findings

**D1 — `--tx2` secondary text reaches only 2.94:1 over the brightest top-third
wash pixel (route to UX).**
`#B4A6CE` over the measured worst-case backdrop `#7c4e6c` gives 2.94:1, below
WCAG AA 4.5:1 and marginally below AA-large 3.0:1. Deferral is correct: this is a
pre-existing token/backdrop pairing that this story did not change and cannot
change inside its zero-lib-change constraint, and the fix is a UX decision
(re-tune `--tx2`, or lower the magenta lobe alpha), not a P1 code change. Primary
text `--tx` clears AA comfortably at 5.87:1, so the informational load of these
screens is not at risk.

One correction to the recorded rationale, which slightly understates the residual
risk: `test-results.md` line 436 says "None of the four captures place secondary
text there." Inspecting `ad6-chat-dark-vi.png` directly, the status banner row
immediately under the chat app bar does extend low-contrast secondary text into
the upper-right region where the magenta lobe is brightest. The deferral still
stands on its own merits — pre-existing, out of scope, UX-owned — but UX should
size this as "reachable in a real screen today", not "theoretical worst-case
pixel only".

**D2 — `_DaysCounter` overflows by 14px at 390dp logical width.**
`RenderFlex overflowed by 14 pixels on the right` in
`mobile/lib/features/home/presentation/home_screen.dart` (~`:500`) when the Home
hero renders at 390dp; the AD-6 capture frame was widened to 430x932 to work
around it. Unrelated to the backdrop layer, pre-existing, and untouchable inside
this story's constraint. 390dp is a real and common device class (iPhone
12/13/14), so this warrants a queued bug or follow-up story rather than sitting
only in a test-results appendix.

**D3 — phase AC2's injected-violation run is not recorded in `test-results.md`.**
Phase AC2 and `## 6 Verification strategy` both require recording a deliberate
temporary edit that makes the guard fail with the seeded screen's `file:line`,
alongside the clean run. Only the clean run (38 files, 0 violations) is recorded.

Not blocking, because the property that run exists to prove — that the guard is
not vacuous — is proven by a *stronger* and durable mechanism that the Reviewer
verified executing: the AC3 freshness test calls the same `_violationsIn()` used
by AC2 against all three real allowlisted occluders and fails if any of them
stops producing a violation. `splash_screen.dart` and `gallery_viewer_screen.dart`
exercise the `backgroundColor:` branch and `welcome_screen.dart` exercises the
`body: DecoratedBox(...)` branch, so **both** detector paths are proven live on
every CI run rather than once in a log. That also discharges the phase Task 2
rule-5 instruction to verify the detector would flag `welcome_screen.dart` if it
were not allowlisted. The gap is documentary only: `test-results.md` should say
this substitution is being made instead of leaving the review gate to derive it.

**D4 — the `welcome_screen` negative-control figure and its revert statement are
absent from `test-results.md`.**
Phase Task 1 and Task 5 require recording the `occluded.g = 0.19215686274509805`
probe evidence and confirming the temporary probe was fully reverted. Neither
appears in `test-results.md`. Not blocking: the figure is durably recorded in
`story_master.md` `## Open Question Impact` OQ-3, and the Reviewer confirmed the
revert independently — the committed probe-file diff is a pure addition with no
`welcome` probe and no capture harness, and the `mobile/lib` diff is empty.

**D5 — `test-results.md`'s allowlist summary table gives splash a substantively
wrong rationale.**
Line 102 paraphrases splash as "pre-theme boot frame; the backdrop is not mounted
yet". That is not the ratified basis and is not accurate: `CupidAppBackground` is
installed by `MaterialApp.builder` above the `Navigator`, so splash sits under it
like any other route. The real OQ-1 basis is design-source-backed — `Cupid
Screens.dc.html:1418` gives splash its own full-bleed linear gradient on purpose.
The `welcome` row is similarly thinned to "full-bleed art treatment" with the
design-source citation dropped.

Not blocking, because the authoritative copy is the `_allowlist` constant in
`shared_backdrop_occlusion_guard_test.dart:32-47`, which the Reviewer read
directly and which carries the correct, fully-cited rationale for all three
entries. The risk is that a future maintainer reads the evidence doc rather than
the constant and concludes splash is exempt for a timing reason, which would
invite the wrong fix. Worth correcting in `test-results.md` when it is next
touched.

**D6 — `test-results.md` lines 315-327 quote a stale pre-commit git snapshot.**
That block shows `1 file changed, 302 insertions(+)` and a `git status` listing
the guard test as untracked. The committed tree is 7 files / 1325 insertions.
Cosmetic and self-superseded by the `### Fresh-session re-verification` section
further down, which quotes the correct post-commit state.

## Dismissed Observations

**Dismissed — the `verify-implementation-build-runtime-gate.sh` hold.**
The implementation lane hit a session-scoped false positive: the gate replays
every build/test command that exited non-zero during a session, and one such
command targeted the temporary AD-6 capture harness by `--plain-name`. That
harness was deleted before commit exactly as the phase plan required, so the
replayed command cannot exit 0 again by construction. Re-adding scaffolding
purely to satisfy a replay would have been worse than the hold, and it was
correctly not done. This carries no signal about code quality and was excluded
from the verdict. The Reviewer did not attempt to reproduce it, per the handoff.
Independently, every gate this hold was standing in for has now been re-measured
green from a clean session.

## Implementation Action Items

- None required for approval. D1 and D2 need product/UX routing by Scrum Master;
  D3-D6 are `test-results.md` corrections that can ride along with any future
  touch of that file and must not gate this story.

## Workflow State Recommendation

- Story status: `DONE`
- Bug status: `N/A`
- `Implementation (Development)`: `KEEP_CHECKED` — the implementation is complete
  and independently verified; Scrum Master should mark the currently-unchecked
  `- [ ] Implementation (Development)` box in `story_master.md` as checked
  alongside `- [ ] Review (Reviewer)`.
- `Review (Reviewer)`: `CHECK`
- Next step: Scrum Master marks STORY-007 `DONE`, makes
  `codex/REQ-010_home_dashboard_deferred_scope_completion-STORY-007` merge
  eligible into
  `codex/REQ-010_home_dashboard_deferred_scope_completion-integration`, and
  routes D1 to the UI/UX Designer as a token/backdrop contrast decision and D2 to
  the bug queue as a pre-existing 390dp layout overflow. Neither is a REQ-010
  integration blocker.
- State update owner: `scrum-master` only. Reviewer does not edit story or
  requirement status files.
