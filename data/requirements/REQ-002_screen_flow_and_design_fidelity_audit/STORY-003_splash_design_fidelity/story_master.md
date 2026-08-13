# Story Master: STORY-003 Design Fidelity — Splash

Status: IN_PROGRESS
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: splash, Epic 1 (Core connection / onboarding), NO_CHROME / NO_TABS
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development) — `visual-fidelity/visual-fidelity-report.md`
- [ ] Review (Reviewer)

## Depends On
- NONE. Independent of every other Scope A/Scope B story; runs as part of
  the story-level-parallel wave for REQ-002 Scope B.

## User Story
As a user viewing the splash screen, I want it to match the locked design
source exactly, so that the app feels visually consistent, trustworthy, and
on-brand from the very first frame.

## In Scope
1. Re-audit the current splash screen (chromeless, no tab bar) against
   `cupid-app-design-system` for the enabled dark theme + `vi` locale
   configuration: branding/logo placement, nebula background (twinkling
   stars), spacing, color/design-token usage, and typography.
2. Correct every deviation found directly in the app code so the rendered
   screen matches the design source exactly — this is a fix, not an audit
   report.
3. This story covers splash's visual rendering only (branding/logo, nebula
   background, any loading treatment shown during the minimum-dwell hold);
   the auth-check session-resolution routing logic and its destination
   screen (home/login/welcome) is STORY-001 scope and is not duplicated
   here.

## Out of Scope
- The auth-check session-resolution routing logic and its destination
  screen — STORY-001 scope.
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Acceptance Criteria
1. Given the splash screen rendered in the enabled dark theme + `vi` locale,
   when compared against `cupid-app-design-system`'s corresponding screen,
   then layout, spacing, color/token usage, and typography match exactly
   with no visible deviation.
2. Given any deviation was found during this story's audit, when the story
   is delivered, then the deviation is corrected in the rendered app (not
   merely documented) and re-verified against the design source.
3. Given the splash's loading/session-check hold state, when rendered, then
   it uses the design source's own loading/branding treatment (no ad hoc
   spinner or placeholder not present in the design source).
4. Given the screen is reached through the app's existing normal launch
   sequence, when a user opens the app, then no new entry point is
   required — this story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current splash screen, already the
  first screen shown at app launch.
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
