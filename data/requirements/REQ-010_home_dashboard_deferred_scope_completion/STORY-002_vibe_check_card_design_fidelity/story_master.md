# Story Master: STORY-002 Vibe-Check Card Design Fidelity

Status: PENDING
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-010
Screen: Home dashboard — vibe-check card (`VibeEntryCard`, already mounted
in `home_screen.dart`)
Design reference: `cupid-app-design-system` (locked, confirmed by prior
`detect_design_source.py` runs under REQ-002)

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE.

## User Story
As a paired user viewing the Home dashboard, I want the vibe-check card to
match the locked design source's two-tile layout exactly, so I can
recognize and use today's vibe-check prompt as designed.

## In Scope
1. Re-audit the current vibe-check card (`VibeEntryCard`, already mounted
   on Home) against `cupid-app-design-system` for the enabled dark theme +
   `vi` locale configuration: the two-tile layout, spacing, color/
   design-token usage, and typography.
2. Correct every deviation found directly in the app code so the rendered
   card matches the design source exactly — this is a fix, not an audit
   report.

## Out of Scope
- Any change to the vibe-check submission logic, data model, or the vibe
  screen (`vibes/presentation/vibe_screen.dart`) it leads to — already
  shipped.
- Any new tap target or navigation destination beyond what the locked
  design source already specifies for this card.

## Acceptance Criteria
1. Given the Home dashboard rendered in the enabled dark theme + `vi`
   locale, when the vibe-check card is compared against
   `cupid-app-design-system`'s corresponding two-tile element, then
   layout, spacing, color/token usage, and typography match exactly with
   no visible deviation.
2. Given any deviation was found during this story's audit, when the story
   is delivered, then the deviation is corrected in the rendered app (not
   merely documented) and re-verified against the design source.
3. Given the card's existing tap behavior, when a user taps a tile, then it
   continues to reach the already-shipped vibe screen — no new entry point
   is introduced by this story.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the vibe-check card already mounted and
  reachable on the Home dashboard.
- Direct URL only acceptable: N/A — existing reachable surface, not new.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed.

## Open Question Impact
NONE.
