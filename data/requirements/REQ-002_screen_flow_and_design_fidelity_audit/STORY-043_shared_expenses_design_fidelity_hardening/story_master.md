# Story Master: STORY-043 Hardening - Shared Expenses Visual Fidelity Evidence

Status: DONE
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-028_shared_expenses_design_fidelity
Scope: Retro-hardening (RWB-20260816-011)
Screen: Shared Expenses, Epic 5 (Shared money goals)
Design-Screen: expense (confirm exact screen id via
`render-design-canvas.js --list-screens`)
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development) — round 2, action items 1-4 addressed
      (verified against disk: iOS PNGs re-captured post-review, F6/F7/AC3/M-1
      rows updated, provenance note added, no Dart change)
- [x] Review (Reviewer) — Iris-QC-8, round 2, Outcome: DEFERRED_ONLY, all 7
      ACs MET. Deferred: D-a (no regression test for N-1/N-2), D-b (M-3
      correction — applied by Scrum Master to STORY-028's own report), D-c
      (sharpened D-1/D-2/M-1 descriptions — split to RWB-20260816-021), D-d
      (residuals, pre-existing), D-e (tooling limitation, RWB-020), D-f
      (ellipsis clamp render-unverified, non-blocking)

## Background (Rework Item)
`data/retro-audit/rework-backlog.md` item RWB-20260816-011 (source: REQ-002
audit report, `retro-audit/audit-report.md`) found
STORY-028_shared_expenses_design_fidelity's Design Fidelity evidence had
zero rendered evidence either side — same IF-7-class gap already remediated
for `welcome` (STORY-035), `register` (STORY-036), `invite` (STORY-037),
`paired` (STORY-038), `contract` (STORY-039), `chat` (STORY-040),
`antighost` (STORY-041), and `timeline` (STORY-042).

STORY-028's own review (`STORY-028_shared_expenses_design_fidelity/review/review-report.md`,
Outcome: DEFERRED_ONLY) and its own
`visual-fidelity/visual-fidelity-report.md` must be read directly, not
re-derived, before this story is scoped. Key facts Product Owner must weigh
in scoping:

1. **Zero rendered evidence (confirms RWB-011):** the review report's own
   Residual risks section states plainly: "No on-device or emulator capture
   backs this review; the fidelity evidence is source-to-source plus widget
   tests." This is the exact defect this hardening story exists to fix —
   capture `implemented-expense-<device>.png` from the running
   `expense_history_screen.dart`, and render
   `design-reference-expense-<platform>.png` via
   `render-design-canvas.js --screen=expense` (confirm the exact screen id
   via `--list-screens` if `expense` does not resolve).
2. **25 deviations landed as code, source-to-source verified, never
   render-confirmed:** `expense_history_screen.dart` and
   `expense_list_item.dart` were corrected against
   `cupid-app-design-system` (`Cupid Screens.dc.html` lines 835-879) and the
   reviewer independently cross-checked every row of the spec table against
   source (padding, summary card, total typography, delta, chart bars,
   weekday labels, chips, list card, row, icon tile, row text, amount) — all
   confirmed MATCH by source comparison only, same re-verification posture
   as STORY-038 through STORY-042.
3. **D-1/D-2 (deferred, out of WriteScope, shared-component):** design
   source specifies exact FAB visual detail (`60x60`, `border-radius:20px`,
   `grad-hot` background, glow shadow, `27px` glyph) and iOS full-width CTA
   detail (`height:52px`, `grad-hot` background, glow, `15.5px w800` label,
   leading `add` glyph) that the *shared* `CupidAddAction`/
   `CupidPrimaryButton` components under `mobile/lib/design_system/adaptive/**`
   do not implement — both widgets are shared with Dream Jar, Gallery, and
   Home, so STORY-028's reviewer correctly deferred them to a
   design-system-scoped story rather than forking local copies. Product
   Owner should re-confirm these stay out of scope for this screen-scoped
   hardening story (same class as RWB-012/RWB-018's shared-component
   exclusion pattern) — if still open, they should route to their own
   split-out rework item rather than being pulled into this story.
4. **M-1 (FAB overlap risk, tied to D-1):** reasoned-not-observed risk that
   once D-1's 60x60 FAB lands, its top edge will visibly cover the last
   row's amount; not independently fixable without D-1, so it travels with
   D-1's disposition.
5. **M-2 (empty filtered result renders a bare card strip, cosmetic) and
   M-4 (1px gap, below visible-deviation threshold):** minor, non-blocking;
   Product Owner should re-confirm whether either qualifies as a real
   deviation once an actual render exists (M-2 is reachable by a single chip
   tap and may or may not be visible in practice), or stays deferred/noted.
6. **M-3 (docs-only, inaccurate justification in the visual-fidelity
   report):** not a code defect; re-confirm no code change needed.
7. **AC3 platform split (FAB vs. full-width CTA) already confirmed correct
   by source cross-check; still needs an actual dual-platform render to
   close the evidence gap, same as AC1/AC2.**

Exact remediation steps: see `rework-backlog.md` RWB-20260816-011 detail
section and STORY-028's own `story_master.md`/`review/review-report.md`
(already read, do not re-derive).
