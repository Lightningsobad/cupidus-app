# STORY-050: Contract Clause-Counter Row Disposition

Status: DONE
Retro-Type: RED-PATCH
Fixes: STORY-015_love_contract_design_fidelity
Complexity: trivial
Story-Class: standard
Implementation Lane: mobile (evidence-capture only — PO triage confirmed no
code/UX/architecture change; this lane exists solely to satisfy the DONE
visual-evidence gate for the `contract` screen this disposition covers)

## Artifacts

- [x] Requirements (Product Owner) — this file, `## Product Owner Triage (2026-08-18)`. Both findings dispositioned keep-and-exclude; no code/UX/architecture change required.
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial (PO triage requires no UX change)
- [x] Architecture (Tech Lead) — SKIPPED:trivial (PO triage requires no architecture change)
- [x] Implementation (Development) — evidence-capture only, no code diff. `visual-fidelity/visual-fidelity-report.md`, `VISUAL_FIDELITY: PASS` (Alex-Mobile-Dev, 2026-08-18). Confirms the clause-counter row (CC-1) as rendered: present, absent from the design source, first child of the clause-list block, `type.caption`/`colorTextMuted`, backing the backend's 20-clause cap — matching `## Product Owner Triage (2026-08-18)` Disposition 2. Evidence pair reused byte-for-byte from STORY-049 after confirming the `contract` screen is unchanged since that capture (`git diff d58da5f..HEAD -- mobile/lib/ cupid-app-design-system/` empty).
- [x] Review (Reviewer) — `review/review-report.md`, Outcome: DEFERRED_ONLY (Iris-QC, 2026-08-18). Disposition-substance approved; non-blocking finding V-1 (factual correction to a justification aside, not the decision) deferred to `req_master.md` propagation. Does not need to be redone for the evidence-capture addendum below (no disposition-substance change).

## Background (Rework Item)

Source: `data/retro-audit/rework-backlog.md` — RWB-20260816-015, surfaced by
`STORY-039_love_contract_design_fidelity_hardening`'s reviewer
(`review/review-report.md`, finding V-2) while re-verifying STORY-015's
`contract` screen.

The implemented `love_contract` screen renders a `2/20 điều khoản`
clause-counter row that the design canvas (`Cupid Screens.dc.html`, the
`contract` screen node) does not paint, pushing the rendered clause list
~26 image px lower than the design reference. STORY-015's own
`visual-fidelity-report.md` filed this delta under "the F-5 copy family",
but STORY-039's `## Out of Scope` scopes F-5 specifically to the
add-clause-row copy diff (`Thêm điều khoản riêng` vs. design's `Thêm điều
khoản của riêng tụi mình`, tracked separately as RWB-20260816-025) — so the
clause-counter row itself is currently unclassified, not excluded, and
STORY-039's AC1 exclusion list only names F-1/F-2/F-3.

Not blocking (Core Rule 7): the counter is a pre-existing REQ-001 product
affordance backing the 20-clause cap on `love_contract`, not introduced by
STORY-015 or STORY-039, and removing or repositioning it is a product-copy
decision outside a fidelity-hardening story's authority — hence this
retro-hardening triage story rather than a direct patch.

Originally stated remediation (RWB-20260816-015): Product Owner / Tech Lead
to give this row an explicit disposition — keep-and-exclude (add it to
STORY-015/STORY-039's exclusion list alongside F-1/F-2/F-3 with a stated
reason), reposition (find a design-source placement/token this row can map
to), or remove (drop the counter from the implemented screen) — rather than
leaving it filed under the F-5 copy family it does not belong to.

Reviewer-recommended framing (RWB-20260816-015's own remediation note):
resolve this alongside STORY-015/STORY-039's F-1/F-2/F-3 token-vs-source
policy question in the same triage pass, since both are about how the
implemented `love_contract` screen may legitimately diverge from the
design canvas rather than about a broken render. Product Owner should
locate F-1/F-2/F-3's original definitions in STORY-015's or STORY-039's own
`visual-fidelity-report.md` before triaging this item, rather than assuming
they are in the central OQ registry (`conflicts_open_questions.md` has no
F-1/F-2/F-3 entries as of this story's opening).

## Product Owner Triage (2026-08-18)

Both items below are dispositioned **keep-and-exclude**. Neither requires a
code, UX, or architecture change, so `Complexity: trivial` and
`Implementation Lane: none` (header fields above updated accordingly).

### Disposition 1 — F-1/F-2/F-3 token-vs-source policy (requirement-level)

Findings, from STORY-039's `visual-fidelity/visual-fidelity-report.md`
(lines 165-167 — the authoritative definition; STORY-015's own report used
a different labeling scheme and does not define F-1/F-2/F-3):

- **F-1 — token hue vs. design-source hue.** The header wash and `--surf`
  channel differ from the literal mockup RGB (reference (74,35,79) ->
  (71,34,81) vs. app (75,45,87) -> (74,45,88)).
- **F-2 — token type size vs. design-source size.** Contract title ink
  height is 24px from the app's type-scale step vs. 27px in the design
  source, producing a 5-7px header-rhythm drift.
- **F-3 — token padding vs. design-source padding.** Sign-section
  horizontal padding is 20.3px (near-exact) in the design source; the app
  snaps to `CupidSpacing.md` = 16px, measured at 15.3px.

**Decision: keep-and-exclude, elevated from a STORY-039-local AC1 exclusion
to a standing REQ-002-wide policy.** Wherever an implemented screen already
draws from a real `design_system/` token (color, type-scale, or spacing
step) and the only divergence from the literal design-source pixel value is
that token's scale-snap — not a missing token, not a hardcoded arbitrary
value, not a structural/content difference — the divergence is accepted
design-system behavior, not a fidelity defect, and does not need
per-screen re-litigation in future REQ-002 fidelity stories.

Reasoning:
1. All three recorded instances are sub-perceptual/cosmetic with zero
   functional impact: a few-point RGB channel offset, a 3px type-ink
   height delta, and a ~4-5px padding snap.
2. Chasing literal-pixel parity would mean either forking one-off values
   per screen away from the shared token scale (breaking the scale's
   consistency/maintainability purpose for a gain no user perceives) or
   redesigning the token scale itself — both disproportionate to a
   few-px/hue delta.
3. STORY-039's reviewer already flagged this class as systemic ("will
   recur on every remaining REQ-002 Scope A screen"); a standing policy,
   not per-screen re-litigation, is the proportionate fix.

Boundary — what this policy does **not** cover: it applies only when the
app already uses a real `design_system/` token whose own value legitimately
differs from the literal mockup at that scale step. It does not cover
missing tokens (e.g. RWB-20260816-016's `colorOnAccent` gap), hardcoded
non-token values, or structural/layout/content deltas (e.g. the DEF-1/
DEF-2/D-item classes already fixed in STORY-039) — those remain in-scope
defects for their own fidelity stories.

Recommendation for Scrum Master: since this elevates a screen-local
exclusion to a requirement-wide policy, propagate a short pointer to this
disposition into `req_master.md` (or wherever REQ-002's shared fidelity
policy is tracked) so later REQ-002 stories can cite it directly instead of
reopening F-1/F-2/F-3-shaped findings. No Tech Lead architecture change is
implied (no token-scale edit proposed here), but since the reviewer
originally framed this as needing a "Scrum Master / Tech Lead call," a
one-line Tech Lead FYI when this policy is propagated is worth doing — not
a blocking gate on this disposition.

### Disposition 2 — `contract` clause-counter row (`2/20 điều khoản`)

STORY-015's own original `visual-fidelity/visual-fidelity-report.md`
(`## Assumptions And Retained App-Only Elements`, finding **A-1**) already
dispositioned this exact row at STORY-015 time: "Clause counter... not in
the design source. They are shipped REQ-001 affordances covered by existing
tests; removing them would be a functional change, which this story's Out
of Scope section excludes. They were kept and re-homed inside the clause
list block." STORY-039's later re-audit used a different labeling scheme
(F- prefix, for the token/copy-family findings) and mis-filed this row
under F-5 — which STORY-039's own `## Out of Scope` scopes specifically to
the add-clause-row copy diff, not this row — losing the original A-1
disposition's visibility. That mis-filing, not an open defect, is what
created this triage item. (STORY-049's own report independently notes the
same fact: "the clause counter row (already dispositioned as A-1 in
STORY-015)".)

**Decision: keep-and-exclude**, confirming and re-affirming STORY-015's
original A-1 call, not reopening it. Give it its own named exclusion item —
deliberately not "F-6", to avoid extending the already-gapped F-series
(F-4 is undefined in either report) with a finding that isn't actually a
token-policy item:

- **CC-1 — clause-counter row (`{n}/20 điều khoản`).** Not in the design
  source. Pre-existing REQ-001 product affordance backing the 20-clause
  cap, not introduced by STORY-015 or STORY-039. Kept and re-homed inside
  the clause-list block (`type.caption` / `colorTextMuted`), per STORY-015's
  A-1. Excluded from STORY-015/STORY-039 AC1 fidelity comparisons —
  deliberately not "fixed".

Reasoning: the row is functional (backs a real, tested 20-clause limit),
its absence from the mockup predates neither the limit nor the row itself
being introduced by fidelity work, and both "reposition" (inventing a
design-source placement the canvas does not define) and "remove" (dropping
real user-facing information for a cosmetic-only gain) would trade product
value for pixel-parity with no product upside — outside a
fidelity-hardening story's authority, per this story's own Core Rule 7
note.

### Ready to close (superseded 2026-08-18 — see `## DONE Evidence Gate` below)

No further phases required. UX Design, Architecture, Implementation, and
Review are all N/A for this story: both dispositions are documentation-only
exclusion-list decisions, with no `mobile/lib/features/love_contracts/`
code change, no new UI/UX spec, and no Tech Lead architecture output.
Recommend Scrum Master mark this story's `## Artifacts` UX/Architecture/
Implementation/Review rows `SKIPPED:trivial`/N/A and close the story on this
triage alone.

## DONE Evidence Gate (2026-08-18)

Reviewer `Iris-QC` (`review/review-report.md`, Outcome: DEFERRED_ONLY)
approved this story's disposition substance and recommended "Scrum Master may
mark STORY-050 DONE." Attempting that transition, `guard-story-done-evidence.sh`
blocked `Status: DONE` for this `contract`-screen story without its own
`visual-fidelity/visual-fidelity-report.md` recording `VISUAL_FIDELITY: PASS`
plus `implemented-contract-*.png` / `design-reference-contract-*.png` in this
story's own directory — PO's and Reviewer's "documentation-only, no evidence
needed" reasoning does not exempt the DONE gate itself, consistent with this
campaign's own precedent: STORY-047 and STORY-049 both initially looked like
pure triage/no-render items and both still closed only after producing real
`contract`/`profile`/`joincode`-screen renders under this same gate.

Implementation Lane reopened to `mobile`, scoped to evidence-capture only —
no disposition change, no code diff. A very recent `contract`-screen capture
already exists at
`STORY-049_contract_unsigned_state_render_coverage/visual-fidelity/`
(`implemented-contract-requesterunsigned-emulator-5560.png`,
`design-reference-contract-mysigned-attempt-android.png`,
`design-reference-contract-myunsigned-android.png`) — Mobile Dev may reuse
that capture if the screen is confirmed unchanged since, or recapture if
simpler. Either way this story needs its own
`visual-fidelity/visual-fidelity-report.md` with `VISUAL_FIDELITY: PASS`
confirming the clause-counter row (CC-1) as rendered, before Scrum Master can
re-attempt `Status: DONE`.
