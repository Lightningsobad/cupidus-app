# Story Master: STORY-010 Design Fidelity — Onboarding Profile Setup

Status: PENDING
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: profile (onboarding setup step), Epic 1 (Core connection /
onboarding), NO_CHROME / NO_TABS
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
As a user setting up my profile during onboarding, I want the screen to
match the locked design source exactly, so the app feels visually
consistent and trustworthy while I set up my identity.

## In Scope
1. Re-audit the current onboarding profile-setup screen (chromeless, no tab
   bar) against `cupid-app-design-system` for the enabled dark theme + `vi`
   locale configuration: avatar/photo upload slot (generic `<image-slot>`
   upload/crop widget), form field styling, spacing, color/design-token
   usage, and typography.
2. Correct every deviation found directly in the app code so the rendered
   screen matches the design source exactly — this is a fix, not an audit
   report.
3. This screen is distinct from the Epic 6 "Me / Profile" screen
   (STORY-029) — this story covers only the one-time onboarding profile
   setup step, not the ongoing profile-management screen.

## Out of Scope
- The Epic 6 "Me / Profile" screen — separate screen, separate story
  (STORY-029).
- Where this screen navigates to next — Scope A (STORY-001/STORY-002) owns
  inter-screen navigation correctness.
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Acceptance Criteria
1. Given the onboarding profile-setup screen rendered in the enabled dark
   theme + `vi` locale, when compared against `cupid-app-design-system`'s
   corresponding screen, then layout, spacing, color/token usage, and
   typography match exactly with no visible deviation.
2. Given any deviation was found during this story's audit, when the story
   is delivered, then the deviation is corrected in the rendered app (not
   merely documented) and re-verified against the design source.
3. Given the avatar/photo upload slot on this screen, when rendered in its
   empty and populated states, then it matches the design source's
   `<image-slot>` generic upload/crop widget styling exactly.
4. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current onboarding profile-setup
  screen, already reachable in the shipped app.
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
