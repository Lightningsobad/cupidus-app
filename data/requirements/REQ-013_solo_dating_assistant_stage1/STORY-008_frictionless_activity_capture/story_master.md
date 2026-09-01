# Story Master: STORY-008 Frictionless Activity Capture

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: Extends STORY-006's activity list with a capture entry point; OS
share-sheet integration is platform-level, not a screen.

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- STORY-006.

## User Story
As a user, I want to turn a pasted link or a shared item from another app
into an activity card with one action, so adding ideas has near-zero
friction.

## In Scope
1. Paste-a-link → activity-card creation.
2. OS share-sheet target so external content can be sent directly into the
   app as a new card.

## Out of Scope
- Automatic content scraping beyond what's needed to populate a card's
  title/link (deterministic metadata extraction only).
- Any AI parsing of shared content (never, rule 5).

## Acceptance Criteria
1. Given a user pastes a link into the app, when submitted, then a new
   activity card is created referencing that link.
2. Given a user shares a link from another app via the OS share sheet, when
   Cupid is selected as the target, then a new activity card is created
   without leaving the source app first.
3. Given a card is created this way, when viewed, then it appears in the
   same list as STORY-006's curated cards, in the "idea" state (STORY-007).
4. Given link metadata can't be fetched, when the card is created, then it
   still saves with at least the raw link, without failing silently.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO — extends STORY-006's list with a new
  capture path plus an OS-level share-sheet target.
- Direct URL only acceptable: NO — reached via paste action or OS share
  sheet.

## Dependencies
- Depends on: STORY-006.
- Must not require any future story: confirmed.

## Open Question Impact
NONE.
