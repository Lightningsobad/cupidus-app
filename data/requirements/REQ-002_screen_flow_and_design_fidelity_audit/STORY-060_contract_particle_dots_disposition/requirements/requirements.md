# STORY-060 Requirements: Contract Decorative Particle Dots Disposition

Retro-Type: RED-PATCH — Fixes STORY-015_love_contract_design_fidelity
Source: `data/retro-audit/rework-backlog.md` `## RWB-20260816-028`

This story's requirements work is a disposition framing, not a capability
scope. Per `story_master.md`, do not assume the particle dots are a missing
implementation element — that is exactly the question being framed here for
the UI/UX Designer to answer.

## Open Question (story-scoped, for UI/UX Designer to answer)

**OQ-060 — Does REQ-002 (or any design source it inherited) require
ambient/decorative particle-layer parity between a screen's shipped app and
its design canvas reference at all?**

Concretely, for the `contract` screen: the design reference
(`design-reference-contract-myunsigned-android.png`, `sha256` `2acd1045…14b3`,
byte-identical across STORY-039/STORY-049/STORY-056) renders three small
white decorative particle dots in the header band (top-right, above the `L`
of the display title, and right of the `§1` marker) that the current
implementation capture does not. This was most likely produced by an
ambient/animated particle layer in the design canvas that the current static
capture tooling does not reproduce — but that is a hypothesis, not a
confirmed finding; the Designer must inspect the design canvas source
directly (not only the exported PNG) to confirm whether the dots are:

- (a) a static design element the design canvas author intended to render in
  every state/capture, in which case shipped-app parity is expected and this
  is a genuine, undisclosed visual-fidelity gap; or
- (b) an ambient/animated canvas-only artifact of the authoring tool itself
  (e.g., a live particle-effect layer that only exists in the interactive
  canvas, not as a fixed design token), in which case it was never meant to
  ship and is not a gap.

**Generalization note:** this pattern was only surfaced on `contract`
because that is the screen a reviewer happened to open both PNGs for at
full resolution (STORY-056 finding DEF-1). It has not been ruled out on any
other screen's design reference. The Designer's disposition should be
written to generalize — i.e., state the underlying rule (e.g., "ambient
particle/animation layers in the design canvas are canvas-only and never
ship" or "particle dots are a static design element and must be matched
per-screen") rather than a `contract`-only finding, so a future reviewer who
finds the same dot pattern on another screen's reference can apply this
disposition without re-litigating it from scratch. This does not authorize
inspecting other screens now — see Scope below.

## Acceptance Criteria

- **AC1 (disposition recorded):** UI/UX Designer records a disposition
  decision — ship it, or `NOT_APPLICABLE` (canvas-only/decorative artifact)
  — for the `contract` screen's decorative particle dots in this story's
  `ux/uiux-spec.md`, backed by direct inspection of the design canvas source
  (`cupid-app-design-system/project/Cupid Screens.dc.html` or wherever the
  `contract` screen's canvas markup lives), not only the exported PNG. The
  disposition must state the generalized rule per the note above, not just
  the `contract`-specific fact.
- **AC2 (if "ship it"):** if the disposition is that the particles are meant
  to ship, the resulting AC set (written by this story or handed to Tech
  Lead/mobile-dev) must include a design-conformance criterion that names
  the `contract` screen id explicitly, so implementation and its
  visual-fidelity evidence are scoped to a named screen rather than inferred
  later. No implementation AC exists yet — Tech Lead scopes it after the
  Designer's disposition, per `story_master.md` `## Remediation Needed`.

  **Disposition confirmed: ship it.** UI/UX Designer's direct canvas-source
  inspection (`ux/uiux-spec.md`) found the three dots are unconditional
  markup at the shared root app-shell level in
  `cupid-app-design-system/project/Cupid Screens.dc.html` (lines 44-47,
  before any `sc-if` screen block, including `isContract` at line 129), not
  content local to the `contract` screen's own template. Concrete AC2:

  **AC2 (concrete): Contract screen design-conformance — ambient particle
  dots.** The `contract` screen (screen id `contract`) implementation must
  render the three ambient decorative particle dots defined in the design
  canvas source root app-shell (`cupid-app-design-system/project/Cupid
  Screens.dc.html` lines 44-47: approx. positions `top:14% left:8%` white,
  `top:9% right:16%` pale pink, `top:26% right:7%` pale purple, each with a
  continuous opacity/scale pulse), matching the design reference
  (`design-reference-contract-myunsigned-android.png`, `sha256`
  `2acd1045…14b3`) for the `contract` screen id, with visual-fidelity
  evidence scoped to that screen id. Because the canvas source defines this
  motif once at the shared app-shell root rather than per-screen, Tech Lead
  must scope the implementation at the shared screen-shell/adaptive layer
  (not a `contract`-only widget) so the same fix naturally covers every
  other screen sharing this root — while the design-conformance AC and its
  evidence stay scoped to naming `contract` per this AC's requirement.
- **AC3 (if "canvas-only / `NOT_APPLICABLE`"):** if the disposition is that
  the dots are a canvas-only decorative/animated artifact not meant to ship,
  no implementation AC is needed. The story's Review gate only needs to
  confirm the disposition note is recorded in `ux/uiux-spec.md` with the
  Designer's reasoning (source citation, not PNG-only), mirroring the
  `NOT_APPLICABLE`/accepted-difference precedent format in
  `STORY-047_pairing_chain_deviation_triage`'s `story_master.md` item 3a
  (avatar dashed-ring vs. filled glyph — confirmed at the source level,
  reasoned, "No AC").

## Scope

Out of scope for this story, regardless of the Designer's disposition,
unless the Designer's disposition explicitly names it as sharing this motif:

- `mobile/lib/features/expenses/presentation/screens/expense_history_screen.dart`
- `mobile/lib/features/gallery/presentation/widgets/gallery_empty_view.dart`
- Any other screen's rendering or design-reference inspection beyond
  `contract`.

Also out of scope for this Product Owner pass specifically:
- Opening or re-rendering the design canvas HTML (UI/UX Designer's job
  next).
- Deciding the ship-vs-`NOT_APPLICABLE` question (UI/UX Designer's
  decision).

## Open Question Impact

- **OQ Registry Reviewed:**
  `data/intake/bootstrap/conflicts_open_questions.md` — full "Open
  Questions (unresolved, blocking-relevant scope only)", "Assumptions
  Currently Carrying The Flow", and "Decisions Still Needed From The User"
  sections.
- **Impact on STORY-060:** None relevant — the one unresolved registry OQ
  (OQ5, light theme/EN locale enablement) concerns theme/locale coverage,
  not decorative motif parity. The registry's standing assumption that
  `cupid-mobile-design/` (the design canvas source) is authoritative and
  that deviations require a UX decision rather than a silent implementation
  choice is exactly why OQ-060 above is framed for the Designer to answer
  from the canvas source, not decided here. OQ-060 itself is story-scoped
  (answered by the Designer inside this story's artifacts) and is not being
  added to the global registry, since it does not require a user decision
  or block other stories.
