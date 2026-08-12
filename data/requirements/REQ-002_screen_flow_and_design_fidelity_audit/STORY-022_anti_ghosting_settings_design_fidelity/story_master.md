# Story Master: STORY-022 Design Fidelity — Anti-Ghosting Settings

Status: PENDING
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: Anti-Ghosting (threshold picker + Emoji Storm settings), Epic 3
(Daily engagement)
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
As a paired user configuring anti-ghosting behavior, I want the settings
screen to match the locked design source exactly, so the configuration
feels clear, lighthearted, and on-brand.

## In Scope
1. Re-audit the current Anti-Ghosting settings screen against
   `cupid-app-design-system` for the enabled dark theme + `vi` locale
   configuration: inactivity-threshold picker styling, penalty-type
   selector (Emoji Storm vs. count) styling, spacing, color/design-token
   usage, and typography.
2. Correct every deviation found directly in the app code so the rendered
   screen matches the design source exactly — this is a fix, not an audit
   report.

## Out of Scope
- The chat screen where the Emoji Storm penalty actually renders — that is
  STORY-018's scope (chat screen fidelity); this story covers only the
  settings/configuration screen.
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Acceptance Criteria
1. Given the Anti-Ghosting settings screen rendered in the enabled dark
   theme + `vi` locale, when compared against
   `cupid-app-design-system`'s corresponding screen, then layout, spacing,
   color/token usage, and typography match exactly with no visible
   deviation.
2. Given any deviation was found during this story's audit, when the story
   is delivered, then the deviation is corrected in the rendered app (not
   merely documented) and re-verified against the design source.
3. Given the threshold-picker and penalty-type selector components, when
   rendered, then their styling for every option/state present in the
   design source matches exactly.
4. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current Anti-Ghosting settings screen,
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
