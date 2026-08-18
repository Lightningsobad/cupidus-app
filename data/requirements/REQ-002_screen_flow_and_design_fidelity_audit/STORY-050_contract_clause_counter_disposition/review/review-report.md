# Review Report: STORY-050 Contract Clause-Counter Row Disposition

Reviewer: Iris-QC
Review mode: compact-story-review (documentation-only rework gate)
Date: 2026-08-18
Story: `REQ-002_screen_flow_and_design_fidelity_audit/STORY-050_contract_clause_counter_disposition`
Retro-Type: RED-PATCH (rework) — named Reviewer gate required regardless of `Complexity: trivial`
BaseHead: `3b8ea09d7146f4a9c728bcee3daed921f9e6fca0`

Outcome: DEFERRED_ONLY

## Scope Gate

In scope for this review:

- `story_master.md` `## Product Owner Triage (2026-08-18)`, Dispositions 1 and 2.
- Independent verification of the F-1/F-2/F-3 citations against
  `STORY-039_love_contract_design_fidelity_hardening/visual-fidelity/visual-fidelity-report.md`.
- Independent verification of the A-1 quote against
  `STORY-015_love_contract_design_fidelity/visual-fidelity/visual-fidelity-report.md`.
- `CC-1` exclusion-id collision check across the STORY-015 / STORY-039
  fidelity-report id namespaces.
- Sufficiency of "keep-and-exclude" against the three options this story's own
  `## Background (Rework Item)` lists (keep-and-exclude / reposition / remove).
- Confirmation that zero code, UX, or architecture impact was missed.

Out of scope, deliberately not reviewed:

- The wider REQ-002 requirement and unrelated REQ-002 stories.
- STORY-015 / STORY-039 implementation code, tests, and their coding plans.
- Whether `req_master.md` should carry the propagated policy pointer (Scrum
  Master control-plane action, not this story's output).

## Diff Boundary Check

`git -C <Worktree> diff 3b8ea09` against `BaseHead` shows exactly one tracked
file changed — `data/retro-audit/rework-backlog.md` (+8/-2), the Scrum
Master-owned RWB-20260816-015 row moved `PENDING` -> `IN_PROGRESS` with the
STORY-050 opening note. Plus one untracked directory,
`STORY-050_contract_clause_counter_disposition/`, containing only
`story_master.md` and `scrum-master-checkpoint.md`.

Zero source, test, config, l10n, or `design_system/` files touched. This is the
expected and correct shape for `Implementation Lane: none (documentation-only)`,
not an evidence gap.

## Test Evidence

N/A, and correctly so. No build, test, lint, or typecheck command applies to
this story because it produces no executable change of any kind: no
`mobile/lib/features/love_contracts/` edit, no widget or token change, no new
UX spec, no architecture output, no l10n key change. Both dispositions are
documentation-only decisions about how two already-shipped, already-tested
design-vs-implementation divergences are classified in future fidelity
comparisons. Running the mobile suite here would re-execute STORY-039's already
recorded green run (`flutter test` `+1267 ~2`, exit 0) against an identical tree
and prove nothing about this story's output. The `guard-story-done-evidence.sh`
`visual-fidelity/` requirement likewise does not attach: it applies to UI-lane
stories that change a rendered surface, and this disposition changes none.

## Citation Verification

### Disposition 1 — F-1/F-2/F-3, verified exact

Verified against
`STORY-039_love_contract_design_fidelity_hardening/visual-fidelity/visual-fidelity-report.md`,
`## Confirmed Out Of Scope` lines 165-167, cross-checked against the same
report's D-3 (line 145), D-5 (line 147), D-6 (line 148), and the shared card
chrome table (line 108).

| Item | PO's stated value | Primary source | Verdict |
| --- | --- | --- | --- |
| F-1 token hue | reference (74,35,79) -> (71,34,81) vs app (75,45,87) -> (74,45,88) | line 165 + D-3 line 145 (identical wash endpoints) | Exact match |
| F-2 token type size | title ink 24px app vs 27px design source, 5-7px header-rhythm drift | line 166 (`27 vs 24 px`, `5-7 px header band drift`); D-6 line 148 bands reference 143/163/204 vs app 143/170/211 | Exact match |
| F-3 token padding | design-source side 20.3px, app snaps `CupidSpacing.md` = 16, measured 15.3px | line 167 and chrome table line 108 (`20` design source, `20.3` reference render, `15.3` app, delta 5.0) | Exact match |

The reference-first ordering convention used by that table (`20.3 vs 15.3`,
`(74,35,79) vs (75,45,87)`) confirms PO read `27 vs 24` correctly as
design-source 27 / app 24, not inverted.

Policy boundary consistency — confirmed. PO's stated boundary (policy covers
only a real `design_system/` token whose own scale-snap differs from the literal
mockup; it does NOT cover missing tokens, hardcoded non-token values, or
structural/layout/content deltas) is the same boundary STORY-039's report draws
itself. That report's R-4 explicitly separates the literal 12px DEF-1 row
geometry from "the excluded F-3 policy question", and DEF-1 / DEF-2 / DEF-2a /
D-1..D-13 are all recorded as real defects that were fixed, not excluded. No
contradiction found.

Authority — confirmed. The elevation from a STORY-039-local AC1 exclusion to a
requirement-wide policy is not PO overreach: STORY-039's own `story_master.md`
(lines 66-78) records the reviewer's instruction that F-1/F-2/F-3 are
"systemic... NOT screen-local", that "Deciding them once at requirement level is
cheaper than re-litigating per story", and that Product Owner "should record
whichever disposition it chooses... explicitly". Disposition 1 is exactly the
recorded decision that source artifact asked for.

### Disposition 2 — A-1, verified exact

Verified against
`STORY-015_love_contract_design_fidelity/visual-fidelity/visual-fidelity-report.md`,
`## Assumptions And Retained App-Only Elements`, lines 186-190. PO's quoted text
is verbatim, with a single ellipsis eliding the subject clause. Source reads:

> A-1 — Clause counter (`{n}/20 điều khoản`) and the empty-selection hint are
> not in the design source. They are shipped REQ-001 affordances covered by
> existing tests; removing them would be a functional change, which this story's
> Out of Scope section excludes. They were kept and re-homed inside the clause
> list block, styled with `type.caption` / `colorTextMuted`.

The `type.caption` / `colorTextMuted` styling cited in CC-1 matches line 190.

Mis-filing claim — confirmed. STORY-039's report `### Observed but not a fidelity
defect` (lines 172-178) does state the counter "belongs to the F-5 copy family",
while that report's own F-5 row (line 168) scopes F-5 to the subtitle copy diff
and STORY-039's `story_master.md` (lines 79-82) scopes F-5 to the add-clause copy
diff. Under either reading the clause-counter row is not F-5, so PO's core claim
— the row was mis-filed and its original A-1 disposition lost visibility — holds
against the primary sources.

### CC-1 collision check — no collision

Id namespaces in use across both fidelity reports, read in full:

- STORY-015 report (263 lines): `D-1`..`D-13`, `A-1`..`A-3`, `DF-1`..`DF-3`.
- STORY-039 report (248 lines): `DEF-1`, `DEF-2`, `DEF-2a`, `DEF-3`,
  `D-1`..`D-13`, `F-1`, `F-2`, `F-3`, `F-5`, `R-1`..`R-5`.
- Adjacent ids referenced by these artifacts: `V-2` (STORY-039 review finding),
  `F-1`..`F-5` (STORY-015 review finding namespace).

No `CC-` prefix exists anywhere in either report. `CC-1` is free.

## Findings

### V-1 (non-blocking, deferred) — the "gapped F-series" rationale is factually wrong

`story_master.md` lines 138-142 justify the `CC-1` label by saying it avoids
"extending the already-gapped F-series (F-4 is undefined in either report)".

That parenthetical is true only of the two `visual-fidelity-report.md` files. The
F-series does not originate in either of them — it is STORY-015's **reviewer**
finding namespace, and `F-4` is defined there. STORY-039's own `story_master.md`
(lines 38-40) quotes it directly:

> **F-4 (independently confirms RWB-006):** "No rendered evidence... For a story
> whose AC1 is phrased as a visual comparison this is an evidence gap."

F-4 is therefore absent from STORY-039's `## Confirmed Out Of Scope` table
because STORY-039 **resolved** it — closing that evidence gap is the entire
reason STORY-039 exists — not because the series is gapped. The series is
contiguous F-1..F-5.

Impact on the decision: none. Choosing a non-F id remains correct, and on a
stronger reason than the one given: `F-*` is another story's reviewer finding
namespace, and minting a new member of it from a downstream triage story would be
worse hygiene than opening `CC-`. Only the stated justification needs correcting,
not the label.

Deferred rather than PATCH_REQUIRED: it is a parenthetical aside, the decision it
supports is independently sound (the row is not a token-policy item), and the
correction belongs in whatever text Scrum Master propagates into `req_master.md`
rather than in a reopened PO pass. Whoever writes that pointer must not carry the
"gapped F-series" phrasing forward.

### V-2 (advisory) — CC-1 narrows A-1's original two-element scope

A-1 covers two retained app-only elements: the clause counter **and** the
empty-selection hint. `CC-1` restates only the counter row. This is correct for
this story's triage scope (RWB-20260816-015 named only the counter), and A-1
remains untouched and authoritative for the hint, so nothing is lost today. But
if the exclusion list is propagated forward as "CC-1", the empty-selection hint
must keep citing A-1 or it will become the next unclassified app-vs-design delta
of exactly the shape this story exists to close.

## Option Sufficiency And Missed-Impact Check

All three options this story's `## Background` lists were addressed, with
reasoning, and "keep-and-exclude" is sufficient:

- **keep-and-exclude** (chosen) — the row backs a real, tested 20-clause cap; it
  predates both STORY-015 and STORY-039; STORY-015 already reached this same
  conclusion as A-1. Confirming a prior disposition is the minimum-change
  outcome, and it is the one the primary source already supports.
- **reposition** — correctly rejected. The design canvas paints no placement for
  this row, so any reposition would invent a design-source mapping that does not
  exist, which is not fidelity work.
- **remove** — correctly rejected. It would drop user-facing information backing
  a tested product limit for cosmetic-only gain, i.e. a functional/product-copy
  change outside a fidelity-hardening story's authority (this story's own Core
  Rule 7 note, and STORY-015's A-1 reasoning).

Missed impact — none found:

- Code: none. `love_contract_screen.dart` and both DEF widgets are untouched and
  need no change under either disposition.
- Tests: none. The 20-clause cap test (`the 20-clause cap disables the
  add-clause action`) continues to exercise the row; excluding it from a fidelity
  comparison does not weaken that coverage.
- UX: none. No rendered surface changes, so no spec, no accessibility delta.
- Architecture: none. Disposition 1 proposes no token-scale edit, so no Tech Lead
  gate is implied. PO's "one-line Tech Lead FYI when the policy is propagated"
  is a reasonable courtesy and correctly marked non-blocking.

## Residual Risks

1. **The policy is inert until propagated.** Disposition 1's value is entirely in
   later REQ-002 stories being able to cite it. Until Scrum Master lands the
   pointer in `req_master.md`, the policy lives only in a closed triage story's
   `story_master.md` and F-1/F-2/F-3-shaped findings will keep being reopened
   per screen. Already tracked in this story's checkpoint as a post-CLEAN action;
   flagged here so it is not lost if that checkpoint is superseded.
2. **Standing-policy blast radius.** Disposition 1 pre-approves a class of future
   divergences across every remaining REQ-002 screen. Its boundary clause is the
   only thing keeping it from becoming a blanket "tokens are always fine" excuse,
   so the boundary text must travel with the policy pointer, not just the
   headline decision.
3. **Collision check basis.** The `CC-1` clearance was established against both
   `visual-fidelity-report.md` files read in full plus the ids those artifacts
   reference. The two review reports were not opened directly (out of scope for
   this gate). Residual collision risk is negligible given no `CC-` prefix
   appears in any artifact examined.

## Recommendation

Approve and close. Both citations are verbatim-accurate against primary sources,
the disposition is within Product Owner authority and is in fact the decision
STORY-039's reviewer explicitly requested, all three remediation options were
weighed, `CC-1` is collision-free, and zero code/UX/architecture impact was
missed.

Scrum Master may mark STORY-050 `DONE` and resolve RWB-20260816-015. When
propagating the policy pointer into `req_master.md`, carry Disposition 1's
boundary clause verbatim and drop the "already-gapped F-series" phrasing per
finding V-1.

Outcome rationale: `DEFERRED_ONLY` rather than `CLEAN` because finding V-1 is a
real factual inaccuracy in the delivered artifact that is being deferred, not a
zero-finding pass. Nothing found blocks closure.

REVIEW_COMPLETE: YES
