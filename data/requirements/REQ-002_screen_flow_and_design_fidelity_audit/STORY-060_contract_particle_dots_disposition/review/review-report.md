# STORY-060 Review Report — Contract Decorative Particle Dots Disposition

Outcome: DEFERRED_ONLY

Review type: `compact-story-review` (standard story, RED-PATCH retro-hardening
RWB-20260816-028, fixes STORY-015). Round 2 re-review after a documentation-only
rework. Round 1 returned `PATCH_REQUIRED` on B-1.

Diff baseline `81175c5` (= current `HEAD`). `git status --porcelain -- mobile/`
is byte-identical to round 1: same 8 tracked changes plus the one untracked test
file, no new commit. No code, capture, or test evidence changed, so round 1's
verification of the implementation stands unrepeated.

## Scope Gate

- Review report path: this file.
- Round 2 re-read scope (ranged, no full re-reads of round-1 files):
  `visual-fidelity/visual-fidelity-report.md` lines 1-24, 86-175;
  `coding-plan/test-results.md` lines 186-203;
  `ux/uiux-spec.md` lines 112-196 (not read in round 1 — read now because AD-1's
  entire authority rests on it).
- Code re-verified for 12e1: `git grep LoveContractScreen|LoveContractEntryTile`
  over `mobile/lib`.
- Query keys: `AD-1`, `Route 2`, `Entry Point Reachability`,
  `Story Runtime Startup Smoke`.
- Carried forward from round 1, not re-verified: all implementation, test, and
  runtime evidence (unchanged on disk).

## Round 1 Findings — Disposition

| Finding | Status |
|---|---|
| B-1 — `VISUAL_FIDELITY: PASS` contradicted by the evidence pair; particles land 27-41 px above their reference positions | **CLOSED** via Route 2, see below |
| N-1 — missing `## Entry Point Reachability` section | CLOSED in substance; one token nit remains, D-1 |
| N-2 — non-canonical runtime smoke heading | CLOSED — now `## Story Runtime Startup Smoke` (`test-results.md:203`) |
| N-3 — AC2 test name overstates what it pins | Unchanged, still informational |
| N-4 — P1 red run recorded against the earlier assertion form | Unchanged, still informational |

### B-1 is genuinely closed, not re-asserted

I checked this specifically, because "documentation-only rework on a fidelity
finding" is exactly the shape a re-assertion would take. It is not one.

1. **The false claim is retracted, not softened.** Round 1's blocking premise —
   that the offset was "equally present in STORY-039's, STORY-049's,
   STORY-056's, and STORY-057's approved pairs" — is gone. The report now states
   the opposite in its own words (`visual-fidelity-report.md:124-133`): the
   residual is "**not** a general property of this evidence pair and no
   precedent from prior approved pairs covers it", citing my `x=200` column scan
   and the reason it does not transfer (first REQ-002 elements positioned as a
   fraction of a container).
2. **The deltas are recorded verbatim, including the visible consequence.**
   `AD-1`'s table reproduces all three measured centroid pairs, and
   `visual-fidelity-report.md:162-166` states in plain terms that the pink dot
   sits in the app-bar row rather than the card header band, the purple dot at
   the header band's lower edge rather than beside `§1`, and the white dot on
   the card's corner rather than above the `L`. Nothing is buried.
3. **The PASS is explicitly conditioned, at the top.**
   `visual-fidelity-report.md:14-21` states the verdict is conditioned on AD-1
   "not on absolute positional match with the reference PNG", so no later reader
   can mistake it for a positional-parity claim.
4. **Route 1 is recorded as available and declined**
   (`visual-fidelity-report.md:170-172`), so the choice is visible rather than
   implicit.

### The UX disposition is real and resolves the ambiguity I raised

`ux/uiux-spec.md:112-182` is a genuine Designer decision, not an implementer
assertion — and it answers the open question in B-1 with source evidence I did
not have in round 1. Round 1 noted the container question was genuinely
ambiguous (`Cupid Screens.dc.html:44`'s root div is `height:100%`). The addendum
resolves it: the source's own idiom for the safe area is
`padding: var(--safe-top)` applied *locally to the header* (line 50), not an
inset, margin, or reduced height on the shared root box the particles read their
percentages from. Had the author intended the particle coordinate space to
exclude the status bar, the accommodation would sit at the root box where
everything inherits it. It does not, and there is no second inset box in the
subtree. So the full-screen Flutter mount is the faithful reading, and the
reference PNG's ~47 px top / ~33 px bottom band is mockup chrome from the
rendering harness.

That argument is independently checkable against the markup I read in round 1
(`Cupid Screens.dc.html:44-50`) and it holds. It also explains my own
content-alignment measurement rather than contradicting it: the header's local
padding is precisely why the titles align within 3 px while only the
percentage-positioned layer is offset. Accepting the difference on that basis is
sound, and it is the same category as the STORY-010 / STORY-047 avatar
dashed-ring disposition (authoring-tool chrome, not product UI).

## Deferred Findings

- **D-1** (`mobile-dev`, one line — do this before the DONE gate runs): the
  `## Entry Point Reachability` section has the concrete path and the
  no-new-surface rationale but no literal `Reachable: YES` line, which rule
  12e1 names and which the DONE gate may grep for. The substance is verified,
  not taken on trust: `LoveContractEntryTile` is mounted on the Home screen
  (`mobile/lib/features/home/presentation/home_screen.dart:192`) and pushes
  `LoveContractScreen` (`love_contract_entry_tile.dart:175`), so `contract` is
  reachable through a discoverable tile, not direct-URL-only. This is a token
  nit, not a missing gate — but it is cheaper to add now than to have the gate
  bounce the story.
- **D-2** (cosmetic): `AD-1` cites the precedent as "STORY-010 / STORY-047's
  `CC-1`". `CC-1` is STORY-050's label for the clause-counter row; the avatar
  dashed-ring precedent is STORY-047 `story_master.md` item 3a. The UX addendum
  cites it correctly; only the fidelity report's label is mixed.
- **D-3** (informational, carried from round 1 N-3):
  `love_contract_particle_dots_test.dart` is named for "the three ambient
  particle dots" but pins only `stars[1]`. The rationale is documented and
  sound, and the capture covers the other two; the name overstates the pin.
- **D-4** (informational, carried from round 1 N-4): P1's recorded pre-fix red
  run shows the earlier `greaterThan(0.7)` assertion rather than the final
  `closeTo(token, 0.02)` form. The pin holds under the final form — derivable
  from the report's own measured control `ff402f60` — so this is an inference
  step, not a gap.
- **D-5** (accepted difference, now governed): `AD-1` — the particle layer
  renders against the full screen rather than the reference renderer's inset
  box, landing 27-41 px higher in absolute pixels. Dispositioned ACCEPTED by
  UI/UX Designer (Route 2). Recorded here so requirement-level integration
  review inherits it: if the same dot motif appears offset on another screen's
  reference, AD-1 governs and it should not be re-litigated per-screen.

## Traceability

- Requirements: AC1 PASS, **AC2 PASS on AD-1's terms** (dots present on
  `contract` at token-exact fractional positions; absolute offset accepted by
  UX disposition), AC3 not applicable (disposition is SHIP IT).
- UX: `ux/uiux-spec.md` SHIP IT + Route-2 addendum, both verified against
  `Cupid Screens.dc.html:44-50`.
- Architecture: `architecture/solution.md` DEC-1/DEC-2 honoured — verified
  round 1, unchanged.
- Plan/evidence (round 1, unchanged): P1 14/14, P2 25/25, full suite 1319/2/0
  vs the 1314/2 baseline, scoped rerun 31/31, all five cross-phase invariants
  held, `## Story Runtime Startup Smoke` passing on `emulator-5560`.
- Critical gates: widget/pixel regression PASS, `flutter analyze` PASS,
  full-suite regression PASS, mobile runtime startup smoke PASS, rendered design
  fidelity PASS-with-AD-1, entry-point reachability PASS (verified in code).
- Configuration guide: not applicable, no setup/configuration impact.
- Out-of-review-scope per handoff, not re-litigated:
  `verify-backend-runtime-gate.sh` empty-port probe bug, `~/flutter/bin` PATH.

## Recommendation

- Keep `Implementation (Development)` checked; check `Review (Reviewer)`.
- Story status `DONE`, with D-1 applied first as a one-line edit.
- Carry D-5 (`AD-1`) into REQ-002 integration review as the governing
  disposition for ambient particle-layer offsets on any screen.
