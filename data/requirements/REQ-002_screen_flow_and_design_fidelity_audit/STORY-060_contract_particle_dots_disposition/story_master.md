# STORY-060: Contract Decorative Particle Dots Disposition

Status: DONE
Retro-Type: RED-PATCH
Fixes: STORY-015_love_contract_design_fidelity
Complexity: standard
Story-Class: standard
Implementation Lane: shared (Product Owner OQ/scope framing, then UI/UX
Designer cross-screen disposition decision at the REQ-002 requirement-level
`integration-review/mobile-visual-audit.md`; if the answer is "ship it",
Tech Lead + mobile-dev scope and implement; if the answer is "canvas-only
decorative/animated artifact, not meant to ship", this story closes as a
documented `NOT_APPLICABLE` disposition with no code change)
Requirement: REQ-002
Scope: Retro-hardening (RWB-20260816-028)

## Gap (from rework-backlog.md RWB-20260816-028, do not re-derive)

STORY-056's reviewer (finding DEF-1) independently opened both PNGs in that
story's fresh same-state evidence pair for the `contract` screen and found
the design reference (`design-reference-contract-myunsigned-android.png`)
renders three small white decorative particle dots — at the card's top-right
inside the header band, immediately above the `L` of the display title, and
to the right of the `§1` marker — that the implementation capture
(`implemented-contract-requesterunsigned-emulator-5560.png`) does not.
STORY-056's own `visual-fidelity-report.md` "New deviations found: NONE" is
accurate only with respect to the five AC2-named elements (header band,
clause rows, divider, CTA/hold-to-sign affordance, encryption footer); it
does not cover this dot difference because the dots are not part of any of
those five elements.

The design reference is byte-identical (`sha256` `2acd1045…14b3`) to the one
STORY-039 and STORY-049 already rendered and compared against, so this
predates STORY-056 and was not made worse by it. Most likely an
ambient/animated particle layer in the design canvas that the current
capture tooling does not reproduce, rather than a missing implementation
element — but this has not been confirmed, only hypothesized.

Full detail: `data/retro-audit/rework-backlog.md` `## RWB-20260816-028`.

## Remediation Needed (do not expand scope beyond this)

This story exists to answer a disposition question, not to assume an
implementation is required:

1. Product Owner: frame the open question as a scoped OQ — does REQ-002 (or
   any predecessor requirement naming the `contract` design source) require
   ambient/decorative particle-layer parity with the design canvas at all?
   Note in the framing that this dot motif may recur on other screens' design
   references beyond `contract` (cross-screen, not `contract`-only), so the
   disposition decision should be written to generalize.
2. UI/UX Designer: answer the question at the REQ-002 requirement-level
   `integration-review/mobile-visual-audit.md`, inspecting the design canvas
   directly (not just the exported PNG) to determine whether the dots are a
   static design element or an ambient/animated canvas-only artifact.
3. Branch on the answer:
   - If the particles are meant to ship: Tech Lead scopes the smallest
     implementation (likely a `contract`-screen-local decorative layer, not a
     `design_system/adaptive/` change unless the motif is confirmed
     cross-screen), then mobile-dev implements, with an acceptance criterion
     asserting conformance to the design reference for the `contract` screen
     id (and any other screen id the disposition names in scope).
   - If the particles are a canvas-only decorative/animated artifact not
     meant to ship: no code change. Record the disposition (`NOT_APPLICABLE`)
     in this story with the Designer's reasoning, mirroring the
     RWB-20260816-024 Chrome Rules disposition precedent
     (`STORY-047_pairing_chain_deviation_triage`).
4. Do not touch `expense_history_screen.dart`, `gallery_empty_view.dart`, or
   any other screen's rendering unless the Designer's disposition explicitly
   names it as sharing this motif.

## Artifacts
- [x] Requirements (Product Owner) — OQ-060 disposition framing + AC1-AC3
  (branch-conditional), `requirements/requirements.md`
- [x] UX Design (UI/UX Designer) — disposition: SHIP IT, `ux/uiux-spec.md`
- [x] Architecture (Tech Lead) — `architecture/solution.md` +
  `coding-plan/master-plan.md` + P1/P2 phase files. Root cause is a paint-order
  bug in the existing shared `CupidAppBackground` star layer, not a missing
  element; fix is shell-level with no `contract`-screen code change.
- [x] Implementation (Development) — P1 (shell particle paint order + `contract`
  AC2 conformance test) and P2 (retire the duplicate `CupidStarField`) complete
  and green, with runtime smoke: `coding-plan/test-results.md`. No
  `mobile/lib/features/love_contracts/` production diff.
  Reviewer round-1 `PATCH_REQUIRED` (`review/review-report.md`) closed by a
  **documentation-only** rework — no code change, no re-capture, no test re-run:
  - **B-1 → Route 2, ACCEPTED DIFFERENCE.** AC2 closes on the dispositioned
    difference `AD-1` in `visual-fidelity/visual-fidelity-report.md`, not on
    absolute positional match. The particles render at their token-exact
    fractional positions but 27-41 px above the reference PNG's centres, because
    the implementation mounts the layer full-screen while the reference renderer
    insets it in a mockup chassis. UI/UX Designer decided this is the faithful
    reading of the canvas source (`ux/uiux-spec.md` Route-2 addendum; same
    disposition family as STORY-010/STORY-047 `CC-1`). The report's false
    "equally present in prior approved pairs" precedent claim was removed and
    the measured deltas table recorded.
  - **N-1** — `## Entry Point Reachability` section added to
    `coding-plan/test-results.md` (`contract` is a pre-existing entry point; no
    new capability or surface).
  - **N-2** — smoke heading renamed to the canonical
    `## Story Runtime Startup Smoke`; content unchanged.
- [x] Review (Reviewer) — round 1 `PATCH_REQUIRED` (B-1, N-1, N-2), closed by a
  documentation-only rework (no code, no re-capture, no re-test). Round 2
  `Outcome: DEFERRED_ONLY` (`review/review-report.md`): B-1 genuinely closed
  via `AD-1` accepted-difference disposition (`ux/uiux-spec.md` Route-2
  addendum, verified directly by the reviewer); N-1/N-2 closed, including the
  literal `Reachable: YES` line (D-1). 5 deferred notes (D-1..D-5),
  informational only; D-5 records `AD-1` as the governing disposition for any
  recurrence of ambient-particle offset elsewhere in REQ-002.
