# Story Master: STORY-017 Design Fidelity — Home Dashboard

Status: PENDING
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: home dashboard, Epic 2 (Communication), 5-tab chrome (home tab
active)
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE. Independent of every other Scope A/Scope B story; runs as part of
  the story-level-parallel wave for REQ-002 Scope B.

## User Story
As a paired user viewing my home dashboard, I want it to match the locked
design source exactly, so the app's main hub feels visually consistent and
trustworthy every time I open it.

## In Scope
1. Re-audit the current home dashboard (5-tab chrome, home tab active)
   against `cupid-app-design-system` for the enabled dark theme + `vi`
   locale configuration: couple-presence signal, days-counter display
   (Nunito 900, 34pt, per §2 type scale), Dream Gradient hero treatment,
   platform-adaptive tab bar (translucent icon+label on iOS vs. pill active
   indicator on Android per §3), spacing, color/design-token usage, and
   typography.
2. Correct every deviation found directly in the app code so the rendered
   screen matches the design source exactly — this is a fix, not an audit
   report.

## Out of Scope
- The onboarding/pairing chain's entry into home (vow → home) — Scope A
  (STORY-002) owns that transition; this story covers the home screen's own
  rendered content once reached.
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Acceptance Criteria
1. Given the home dashboard rendered in the enabled dark theme + `vi`
   locale, when compared against `cupid-app-design-system`'s corresponding
   screen, then layout, spacing, color/token usage, and typography match
   exactly with no visible deviation.
2. Given any deviation was found during this story's audit, when the story
   is delivered, then the deviation is corrected in the rendered app (not
   merely documented) and re-verified against the design source.
3. Given the days-counter display, when rendered, then it uses the Nunito
   900 34pt display type per §2 and the Dream Gradient treatment per the
   design source.
4. Given the bottom tab bar on iOS vs. Android, when rendered, then it
   follows the platform-adaptive pattern from §3 (translucent icon 26 +
   label 10 on iOS, pill active indicator on Android) rather than one style
   forced on both platforms.
5. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current home dashboard, already
  reachable in the shipped app.
- Direct URL only acceptable: N/A — existing reachable screen, not new.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed.

## Open Question Impact
OQ5 (light theme / `en` locale) only affects out-of-scope light/`en`
user-facing visual QA per this story's Out of Scope section; it does not
block any in-scope acceptance criterion.

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-5) are unblocked.
