# Requirements: STORY-044 Hardening - Private Gallery Visual Fidelity Evidence

Requirement: REQ-002
Retro-Type: RED-PATCH (RWB-20260816-010)
Fixes: STORY-026_private_gallery_design_fidelity

## Business Rationale

REQ-002's completeness audit surfaced that STORY-026's own
`visual-fidelity-report.md` header records
`Design-Reference-Render: BLOCKED (DESIGN_CANVAS_STATE_FORCE_UNSUPPORTED)` —
no `design-reference-gallery-*` image exists at all, on either side of the
comparison, because reaching the `galleryOpen` `<sc-if>` state
(`Cupid Screens.dc.html` L736-751) requires a click on the `doUnlock` CTA
(L733) that no existing `render-design-canvas.js` flag can express. STORY-026
is `DONE` with Reviewer `Outcome: DEFERRED_ONLY`: its comparison substituted a
value-by-value read of the prototype source for a real rendered-pair
comparison, and disclosed that substitution rather than hiding it.

Unlike STORY-035's hardening gap (a comparison-method gap where both sides
could already be rendered), this gap is a tool-capability gap: the renderer
itself cannot reach the state that needs to be captured. STORY-026's own
report already proposes the fix — a generic pre-shutter interaction flag,
`--click=<css selector>` (repeatable), applied after the `--screen`
navigation and before the hide/freeze/shutter sequence, failing with a typed
`DESIGN_CANVAS_CLICK_TARGET_MISSING` when the selector matches nothing. This
story implements that fix, then produces the real evidence pair STORY-026
could not, and re-verifies STORY-026's existing `galleryOpen` findings
against it.

A stakeholder can observe the outcome directly: `render-design-canvas.js`
gains a reusable click-before-capture capability (available to any future
screen needing an in-frame interaction, not just this one), and the
`gallery` screen's `galleryOpen` state has a real rendered evidence pair
proving it matches `cupid-app-design-system`, with any deviation that pair
surfaces fixed in the running app, not just documented.

## Scope

In scope and out of scope are fixed by the governing rework plan in
`story_master.md` (`## In Scope`, `## Out of Scope`) once Tech Lead confirms
lane boundaries, and are not restated in full here to avoid drift. Summary
for traceability:

- Tool phase (devops-owned): add a `--click=<css selector>` flag (repeatable)
  to `.ai-team-bundle/runtime/tools/render-design-canvas.js`. It must not
  regress any existing `--screen=`/`--theme=`/`--lang=`/`--hide=` behavior
  used by other screens' captures (including the STORY-035..043 hardening
  set).
- Evidence phase (mobile-owned, depends on the tool phase): render
  `design-reference-gallery-<platform>.png` with `galleryOpen` forced via the
  new flag, targeting the `doUnlock` CTA selector inside the
  `[data-plat="md"]` frame; re-verify STORY-026's existing `galleryOpen`
  value-by-value findings (`visual-fidelity-report.md` sections 2-3) against
  the new rendered pair; refresh `implemented-gallery-*` evidence if it does
  not already pair cleanly (same state/device/theme/locale) with the new
  reference.
- Screen: Private Gallery only, `galleryOpen` state only (the already-locked
  `galleryLocked` state is not in scope — REQ-002's completeness audit did
  not flag it).
- No exemption/waiver path is in scope. Per `story_master.md` Background
  point 4, the tool-fix path is preferred and no exemption currently exists
  to fall back to.
- The workarounds STORY-026's own report already considered and rejected
  (`visual-capture.js`, editing the locked design bundle, reusing REQ-001's
  wrong-state `design-reference-gallery-android.png`, a hand-rolled
  Playwright script) stay out of scope and must not be re-opened without a
  new concrete reason.

## Acceptance Criteria

1. Given `render-design-canvas.js`'s existing `--screen=`, `--theme=`/
   `--lang=`, and `--hide=` flags, when a new `--click=<css selector>` flag
   (repeatable) is added, then each selector's click is applied after the
   `--screen` navigation and before the hide/freeze/shutter capture
   sequence, matching the tool-fix STORY-026's own report proposes in
   section 8.1.
2. Given the new `--click` flag is invoked with a selector that matches no
   element in the rendered frame, when the render is attempted, then the
   tool fails cleanly with a typed `DESIGN_CANVAS_CLICK_TARGET_MISSING`
   error — no silent no-op and no partial or corrupt output file is written.
3. Given the new `--click` flag exists, when any existing screen capture is
   re-run without a `--click` argument (or with an already-passing
   selector), then that screen's rendered output is unchanged — no
   regression to other screens' captures, including the STORY-035..043
   hardening set.
4. Given the `doUnlock` CTA selector inside the `[data-plat="md"]` frame
   (`Cupid Screens.dc.html` L733), when
   `render-design-canvas.js --screen=gallery --click=<doUnlock selector>` is
   run, then a real `design-reference-gallery-<platform>.png` is produced
   showing the `galleryOpen` `<sc-if>` state block (L736-751), replacing
   STORY-026's `Design-Reference-Render: BLOCKED
   (DESIGN_CANVAS_STATE_FORCE_UNSUPPORTED)` status.
5. Given the new `design-reference-gallery-<platform>.png` from AC4, when the
   existing `implemented-gallery-emulator-5560.png` is compared against it
   for same state/device/theme/locale pairing, then either they already pair
   cleanly, or a fresh `implemented-gallery-*` capture is produced so this
   story's own `visual-fidelity/` directory holds a real, matched,
   same-state evidence pair.
6. Given the evidence pair from AC4-5, when STORY-026's existing
   `galleryOpen` value-by-value findings (`visual-fidelity-report.md`
   sections 2-3) are re-verified against the rendered pair, then each
   finding is confirmed or corrected against the real rendered reference,
   and this story's own `visual-fidelity-report.md` records the re-verified
   outcome (`VISUAL_FIDELITY: PASS` or the corrected result).
7. Given any deviation the rendered `galleryOpen` comparison surfaces (as
   opposed to STORY-026's prior value-by-value-vs-source method), when the
   story is delivered, then it is corrected directly in the app code, not
   merely re-documented, and re-verified by re-rendering and re-comparing.

## Open Question Impact

- **OQ5 (light theme / `en` locale)**: re-checked against the central
  registry (`data/intake/bootstrap/conflicts_open_questions.md`) and
  `req_master.md`. Still unresolved at the registry level and still does not
  block any AC above — consistent with STORY-026's own precedent (only dark
  theme / `vi` locale is enabled for users). No AC above requires light
  theme or `en` locale rendering.
- No other open or resolved item in the central registry constrains this
  story's tool-fix or rendered-evidence scope.
