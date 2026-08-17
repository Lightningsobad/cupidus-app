# Story Master: STORY-044 Hardening - Private Gallery Visual Fidelity Evidence

Status: DONE
Complexity: standard
Story-Class: standard
Implementation Lane: devops (tool phase) then mobile (evidence phase),
sequential — the mobile phase cannot produce real evidence until the
`--click` flag exists on `render-design-canvas.js`
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-026_private_gallery_design_fidelity
Scope: Retro-hardening (RWB-20260816-010)
Screen: Private Gallery, canvas id `gallery`, Epic 4 (Shared relationship
growth)
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`) — only the `galleryOpen` `<sc-if>` state block
(`Cupid Screens.dc.html` L736-751) is the valid comparison target.
Runtime-Smoke: WAIVED — evidence-only phase; zero app-code delta vs BaseHead
db413549e2 (`git diff --stat db413549e2d0c877e1ce3a01f1d7b1b3e8394a6f --
mobile/` confirmed empty by Scrum Master 2026-08-18). Recorded per
`review/review-report.md` finding B1 remedy 2 (reviewer may not edit this
file). Resolves B1.

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:no-new-ux-content (reuses the
      already-approved `galleryOpen` design reference and STORY-026's own
      findings; no new screen, flow, interaction, or responsive/a11y
      decision — only a render-tooling fix and evidence re-verification)
- [x] Architecture (Tech Lead) — `architecture/solution.md` +
      `coding-plan/master-plan.md` + `coding-plan/phase-P0-render-canvas-click-flag.md`
      + `coding-plan/phase-P1-gallery-rendered-fidelity-evidence.md`. Verified
      complete against disk (4 files, no truncation) despite an API-error idle
      notification from the Tech Lead session. Key finding: story's own line
      citations are 8 lines stale vs. current `Cupid Screens.dc.html`;
      solution.md section 1 KD1 is now the authoritative citation source for
      implementers. Tool file `render-design-canvas.js` is gitignored
      (`.gitignore:5`) — P0's durable deliverable is a committed patch +
      contract note inside `coding-plan/`, not a diff of the tool itself.
- [x] Implementation (Development) — P0 (devops) DONE:
      `coding-plan/render-design-canvas-click.patch` +
      `coding-plan/tool-contract-click-flag.md` + `coding-plan/test-results.md`
      (AC1/AC2/AC3 PASS). P1 (mobile) DONE:
      `visual-fidelity/design-reference-gallery-android.png` +
      `visual-fidelity/implemented-gallery-emulator-5560.png` (STORY-026's
      original capture, byte-identical, paired per AC5) +
      `visual-fidelity/visual-fidelity-report.md`
      (`VISUAL_FIDELITY: PASS`, `In-Scope-Deviations-Found: 0`). Both phases
      independently verified against disk (checksums, git status, full report
      reads) — no code changes required to `gallery_grid_view.dart`/
      `gallery_tile.dart`. Reviewer cycle 1 (`Iris-QC-9`) found B1 (missing
      story-level runtime startup smoke, rule 12g) — closed via the
      `Runtime-Smoke: WAIVED` line above (remedy 2, scrum-master-owned).
- [x] Review (Reviewer) — cycle 1 `PATCH_REQUIRED` (B1 only, 1 blocking + 2
      deferred findings, no AC failed); cycle 2 `completion/resume`
      `Outcome: DEFERRED_ONLY` (B1 resolved, AC1-AC7 all PASS unchanged,
      D-1/D-2 carried forward as deferred). RWB-20260816-010 RESOLVED.

## Background (Rework Item)
`data/retro-audit/rework-backlog.md` item RWB-20260816-010 (source: REQ-002
audit report, `retro-audit/audit-report.md`) found
STORY-026_private_gallery_design_fidelity's own `visual-fidelity-report.md`
header records `Design-Reference-Render: BLOCKED
(DESIGN_CANVAS_STATE_FORCE_UNSUPPORTED)` — no `design-reference-gallery-*`
image exists at all; only `implemented-gallery-emulator-5560.png`. STORY-026
itself is `DONE` with Reviewer `Outcome: DEFERRED_ONLY` (value-by-value
comparison against source instead of a rendered pair, explicitly disclosed
as a known gap, not a silent one).

STORY-026's own report (`visual-fidelity/visual-fidelity-report.md` section
8.1, "Why the `galleryOpen` design reference could not be rendered") must be
read directly, not re-derived, before this story is scoped. Key facts
Product Owner must weigh:

1. **Root cause is tool capability, not story defect.**
   `render-design-canvas.js` only supports `--screen=`, `--theme=`/`--lang=`,
   and `--hide=` controls (confirmed by the report against tool source and
   the canvas `--list-screens` inventory: `toggles` is exactly
   `["dark","light","vi","en"]`, no unlocked gallery variant exists as a
   screen id). Reaching `galleryOpen` requires one in-frame click on the
   `doUnlock` CTA (`Cupid Screens.dc.html` L733 `onClick="{{ doUnlock }}"`,
   state written at L410 `unlock = (side) => this.setState(...)`) — a
   supported prototype interaction, but not expressible through any existing
   renderer flag.
2. **STORY-026's report already proposes an exact tool fix.** Add a generic
   pre-shutter interaction flag to `render-design-canvas.js` — e.g.
   `--click=<css selector>` (repeatable), applied after the `--screen` click
   and before the hide/freeze/shutter sequence, failing with a typed
   `DESIGN_CANVAS_CLICK_TARGET_MISSING` when the selector matches nothing.
   For this screen the target selector is the `doUnlock` CTA inside the
   `[data-plat="md"]` frame. This is `.ai-team-bundle/runtime/tools/
   render-design-canvas.js`, bundle tooling outside STORY-026's own
   WriteScope — same devops-anchored pattern as RWB-020
   (`STORY-042_love_timeline_design_fidelity_hardening`'s tooling gap,
   currently `PENDING`, not yet fixed).
3. **Workarounds were considered and rejected by STORY-026's own report:**
   `visual-capture.js` has no interaction support and wrong device frames;
   editing the locked design bundle to seed `unlockedA: true` defeats the
   fidelity gate's purpose; reusing REQ-001's
   `design-reference-gallery-android.png` is the wrong state
   (`galleryLocked`); hand-rolling a Playwright script would bypass the
   locked pipeline's hide/freeze/frame guarantees and would not be
   byte-comparable to sanctioned renderer output. Product Owner should not
   re-open these as alternatives without a new reason.
4. **Two remediation paths, per `rework-backlog.md` RWB-20260816-010:**
   (a) implement the `--click` flag in `render-design-canvas.js`, then
   render `design-reference-gallery-<platform>.png` with `galleryOpen`
   forced, then re-verify STORY-026's evidence against a real image pair; or
   (b) an explicit, durable Scrum Master/PO exemption recording that the
   value-by-value comparison stands in for the two-image comparison for this
   specific state — no such exemption currently exists, and path (a) is
   preferred since RED-PATCH remediation expects real evidence, not a scope
   exemption, when a viable fix exists.
5. **Two-lane story.** Unlike STORY-035 through STORY-043 (single mobile
   lane), this hardening story needs a devops-owned tool change before the
   mobile-owned render/re-verification step can run. Product Owner and Tech
   Lead should scope Complexity/Story-Class/Implementation Lane accordingly
   (likely `standard`, devops phase then mobile phase, sequential
   dependency — the mobile phase cannot produce real evidence until the
   flag exists).

Exact remediation steps: see `rework-backlog.md` RWB-20260816-010 detail
section and STORY-026's own `story_master.md`/`visual-fidelity/
visual-fidelity-report.md` section 8.1 (already read, do not re-derive).
