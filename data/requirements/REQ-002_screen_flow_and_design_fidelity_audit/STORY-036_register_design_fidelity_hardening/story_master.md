# Story Master: STORY-036 Hardening - Register Screen Visual Fidelity Evidence

Status: DONE
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-006_register_design_fidelity
Scope: Retro-hardening (RWB-20260816-003)
Screen: register, Epic 1 (Core connection / onboarding), NO_CHROME / NO_TABS
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)
Design-Screen: register

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) (SKIPPED:trivial)
- [x] Architecture (Tech Lead) (SKIPPED:trivial)
- [x] Implementation (Development)
- [x] Review (Reviewer)

## Review Record

Cycle 1 (Iris-QC-2, `compact-story-review`): `Outcome: DEFERRED_ONLY`.
AC1-5 all PASS with independently verified evidence (rendered pair
cross-checked, AC2 root-cause re-derived and confirmed correct though the
report's line-1472 citation was imprecise, AC3 uncomposed-state reasoning
checked against the design source, AC5 diff confirmed to touch no
navigation file). Governed header-chrome deviation independently verified
against STORY-002's UX spec NO_CHROME rule. 0 blocking findings. 3 deferred
findings, none requiring rework before closure: DEF-1 (fix rationale cites
the wrong design-source line for the line-height value — the value itself
is correct, empirically re-derived, not transcribed), DEF-2 (residual ~2.8dp
password-card gap, same root-cause class, left for a future pass),
DEF-3 (verification table undercounted auth test suite pass count by 1;
immaterial to verdict). Full detail: `review/review-report.md`.

## Background (Rework Item)
`data/retro-audit/rework-backlog.md` item RWB-20260816-003 (source: REQ-002
audit report, `retro-audit/audit-report.md`) found
STORY-006_register_design_fidelity's Design Fidelity row `UNVERIFIED`: its own
`visual-fidelity/` directory holds only `visual-fidelity-report.md`, no
images either side — the same IF-7-class gap already remediated for the
`welcome` screen in `STORY-035_welcome_design_fidelity_hardening`. Note also
that STORY-006's own `story_master.md` currently records `Status: PENDING`
with the `Review (Reviewer)` artifact unchecked, even though
`req_master.md`'s `## User Stories` table and the retro audit both treat it
as a completed/DONE screen — Product Owner should reconcile this discrepancy
as part of scoping this hardening story, not assume it away.

Exact remediation needed (per `rework-backlog.md`):
1. Capture `implemented-register-<device>.png` from the running app (dark
   theme + `vi` locale, per STORY-006's own configuration).
2. Render `design-reference-register-<platform>.png` via
   `render-design-canvas.js --screen=register`.
3. Re-compare both renders against STORY-006's existing AC1-4 (layout,
   spacing, color/token usage, typography, form-field validation states); if
   any deviation is found by the rendered comparison, correct it in the app
   code — this is a fix, not merely a re-documentation.
4. Place the matched, same-screen evidence pair in this story's own
   `visual-fidelity/` directory with a `visual-fidelity-report.md` recording
   `VISUAL_FIDELITY: PASS`.

## Depends On
- NONE. Independent of every other REQ-002 hardening item; must not reopen
  STORY-006's, STORY-034's, or STORY-035's closed git boundary/branch.

## User Story
As a Product Owner verifying REQ-002's design fidelity claims, I want the
register screen's fidelity evidence to be a real rendered-to-rendered
comparison (implemented app screenshot vs. rendered design canvas), so that
STORY-006's `PASS` claim for this screen is backed by proof instead of a
literal CSS/HTML-vs-widget-tree reading.

## In Scope
1. Capture `implemented-register-<device>.png` from the running app in the
   enabled dark theme + `vi` locale configuration (STORY-006's own
   configuration), and render
   `design-reference-register-<platform>.png` via
   `render-design-canvas.js --screen=register`.
2. Re-compare the two rendered images against STORY-006's existing AC1-4
   scope: layout, spacing, color/token usage, typography, and form-field
   validation states (empty, focused, filled, error).
3. If the rendered-to-rendered comparison surfaces any deviation not caught
   by STORY-006's original literal-code audit, correct it directly in the
   app code — this is a fix, not a re-documentation exercise.
4. Place the matched, same-screen evidence pair
   (`implemented-register-<device>.png` and
   `design-reference-register-<platform>.png`) in this story's own
   `visual-fidelity/` directory, with a `visual-fidelity-report.md` that
   records `VISUAL_FIDELITY: PASS` once both images match.

## Out of Scope
- Where register navigates to after success/failure — remains Scope A
  (STORY-001/STORY-002) territory, unchanged from STORY-006.
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet). Confirmed still unresolved-but-non-blocking in
  `conflicts_open_questions.md`; consistent with STORY-006's and
  STORY-035's own precedent, no dedicated light/`en` rendered pass is
  required for this hardening story.
- Re-litigating STORY-006's Review Rework Patch (P1/P2/P3, already applied
  and recorded in STORY-006's own `story_master.md`) — those fixes stand;
  this story only adds the missing rendered evidence and fixes anything the
  rendered comparison newly surfaces.

## Acceptance Criteria
1. Given the register screen rendered in the enabled dark theme + `vi`
   locale, when `implemented-register-<device>.png` is compared against
   `design-reference-register-<platform>.png` (rendered via
   `render-design-canvas.js --screen=register`), then layout, spacing,
   color/token usage, and typography match exactly with no visible
   deviation.
2. Given any deviation is found by this rendered-to-rendered comparison,
   when the story is delivered, then the deviation is corrected in the
   app code (not merely documented) and re-verified with a fresh render
   pair.
3. Given each form-field validation state present in the design source
   (empty, focused, filled, error), when rendered, then each state's
   styling matches the design source exactly.
4. Given the comparison is complete and passing, when the story is
   delivered, then this story's own `visual-fidelity/` directory contains
   the matched `implemented-register-<device>.png` and
   `design-reference-register-<platform>.png` image pair plus a
   `visual-fidelity-report.md` recording `VISUAL_FIDELITY: PASS`.
5. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current register screen, already
  reachable in the shipped app via its existing navigation path — unchanged
  by this story.
- Direct URL only acceptable: N/A — existing reachable screen, not new.

## Dependencies
- Depends on: NONE (confirms `## Depends On` above).
- Must not require any future story: confirmed.
- Must not reopen STORY-006's, STORY-034's, or STORY-035's closed git
  boundary/branch: confirmed.

## Open Question Impact
Re-checked against `data/intake/bootstrap/conflicts_open_questions.md`: OQ5
(light theme / `en` locale) is the only open question touching this
screen's scope. It remains unresolved-but-non-blocking there, deferred to
Product Owner story breakdown per its own working assumption, and is
already excluded from this story's Out of Scope for the same reason
STORY-006 and STORY-035 excluded it — dark + `vi` is the only enabled
user-facing configuration in v1. No other open item in the registry
touches the register screen or this story's evidence-pairing scope.

### Scope Items BLOCKED in this story
- None. No open question blocks any in-scope acceptance criterion.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-5) are unblocked.
