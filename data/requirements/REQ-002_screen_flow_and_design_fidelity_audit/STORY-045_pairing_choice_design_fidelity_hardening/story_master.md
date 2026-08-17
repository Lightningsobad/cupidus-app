# Story Master: STORY-045 Hardening - Pairing Choice Surface/CTA Styling Fidelity

Status: DONE
Complexity: trivial
Story-Class: standard
Implementation Lane: mobile
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-002_onboarding_pairing_navigation
Scope: Retro-hardening (RWB-20260816-012)
Screen: Pairing Choice (`pairing_choice`), onboarding/pairing navigation
flow
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`) — `design-reference-pairingchoice-android.png`
(already rendered by STORY-034, reusable as-is; content/structure already
MATCH per that story's reviewer).

Note: `Story-Class: standard` here reflects the already-created Git Story
Boundary class from this story's boundary-start call (BoundaryState json),
per `complexity-routing.md`'s distinction that `Story-Class` classifies the
Git Story Boundary, not routing complexity — it is intentionally not equal
to `Complexity: trivial` (the routing/lane-consistency field) here.

## Artifacts
- [x] Requirements (Product Owner) — `requirements/requirements.md`
- [x] UX Design (UI/UX Designer) (SKIPPED:trivial)
- [x] Architecture (Tech Lead) (SKIPPED:trivial)
- [x] Implementation (Development)
- [x] Review (Reviewer) — `review/review-report.md`, `Outcome: DEFERRED_ONLY`,
  0 blocking / 3 deferred findings. All 6 ACs PASS. DF1 (new short-viewport
  regression) split to `RWB-20260816-022`; DF2/DF3 non-blocking notes.
  RWB-20260816-012 RESOLVED.

## Background (Rework Item)
`data/retro-audit/rework-backlog.md` item RWB-20260816-012 (source:
`STORY-034_pairing_choice_canvas_addition`'s reviewer, `review/review-report.md`
finding D1) — read directly, not re-derived, before this story is scoped.

STORY-034 added the first-ever `pairing_choice` design-reference render.
That render made a **pre-existing** gap in `STORY-002_onboarding_pairing_navigation`
(DONE/merged) visible for the first time: content and structure MATCH the
design, but the app build's surface/CTA styling does not apply the design
system's tokens. This gap was NOT introduced or worsened by STORY-034 and
was explicitly out of STORY-034's own `## Out of Scope` (no STORY-002 app
code changes there).

Four concrete deviations (STORY-034 reviewer's D1, already measured against
the real rendered pair):
1. **Background** — reference: purple→magenta gradient with small particle
   accents; implemented: flat dark navy, no gradient, no particles.
2. **Primary pill CTA** — reference: pink→purple gradient with glow
   (`var(--grad-hot)` + `var(--glow)`); implemented: flat solid pink, no
   gradient, no glow.
3. **Type scale** — implemented title and pill label render visibly larger,
   so the pill label wraps to two lines and the title wraps at a different
   word than the reference.
4. **Title vertical offset** — sits lower in the implementation (~32% vs
   ~23% down) than the reference.

Exact remediation needed: route to the `mobile` lane to bring the pairing
choice screen implementation onto the design system's gradient surface,
gradient+glow CTA, and type scale, matching
`design-reference-pairingchoice-android.png` (already rendered — do not
re-render unless the implementation-side capture needs a fresh pairing
image after the fix).

Unlike STORY-044 (two-lane, devops then mobile), this item has no tooling
gap — the design-reference image already exists and is reusable. This is
expected to be single-lane mobile app-code work: apply existing design
tokens to an existing screen, then produce fresh AC-paired rendered
evidence (implementation capture after the fix, paired against the
existing reference) per this requirement's standard design-fidelity gate.

Product Owner and Tech Lead should confirm Complexity/Story-Class
accordingly (likely `trivial` or `standard` — four token-level style
deltas on one existing screen, no new screen/flow/persistence/integration
surface).

Exact remediation steps: see `rework-backlog.md` RWB-20260816-012 detail
section and STORY-034's own `review/review-report.md` finding D1 (already
read, do not re-derive).
