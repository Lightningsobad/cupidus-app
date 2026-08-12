# Story Master: STORY-026 Design Fidelity — Private Gallery

Status: PENDING
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: Private Gallery, Epic 4 (Shared relationship growth) — Level-1 data
sensitivity
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
As a paired user viewing our Private Gallery, I want the screen — including
its lock affordance — to match the locked design source exactly, so the
sensitive-content protection feels visually clear and trustworthy.

## In Scope
1. Re-audit the current Private Gallery screen against
   `cupid-app-design-system` for the enabled dark theme + `vi` locale
   configuration: grid/list layout, lock-affordance component styling
   (required per the Level-1 data sensitivity model, §5/§8 of UX system
   memory), spacing, color/design-token usage, and typography.
2. Correct every deviation found directly in the app code so the rendered
   screen matches the design source exactly — this is a fix, not an audit
   report.
3. Confirm the Level-1 lock affordance (re-auth/PIN gate visual cue) is
   present and styled per the design source; if missing or mis-styled,
   correct it as part of this story's fix.

## Out of Scope
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Any change to the underlying re-auth/PIN-gate logic itself — this story
  covers only the visual lock-affordance treatment on this screen, not
  authentication implementation.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Acceptance Criteria
1. Given the Private Gallery screen rendered in the enabled dark theme +
   `vi` locale, when compared against `cupid-app-design-system`'s
   corresponding screen, then layout, spacing, color/token usage, and
   typography match exactly with no visible deviation.
2. Given any deviation was found during this story's audit, when the story
   is delivered, then the deviation is corrected in the rendered app (not
   merely documented) and re-verified against the design source.
3. Given the Level-1 data sensitivity classification of this screen, when
   rendered, then the lock/re-auth affordance visual cue is present and
   styled exactly per the design source.
4. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current Private Gallery screen,
  already reachable in the shipped app.
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
- All acceptance criteria (1-4) are unblocked.
