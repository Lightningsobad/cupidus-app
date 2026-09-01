# Story Master: STORY-007 Activity Card Lifecycle

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: Extends STORY-006's activity list/card detail screens; no separate
screen — UI/UX Designer to define the lifecycle-state visuals.

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- STORY-006.

## User Story
As a user, I want an activity card to move through idea, scheduled, done,
and memory states, so I have a visible sense of progress and completion
instead of a static list.

## In Scope
1. A 4-state lifecycle (idea → scheduled → done → memory) on every activity
   card.
2. State-transition UI.
3. The "memory" state uses a photo as its primary storage/representation
   unit (C4/SB-08 decision), absorbed into this story rather than built as
   a separate story.

## Out of Scope
- Any streak, score, or ranking mechanic — explicitly forbidden as the
  reason this lifecycle exists instead (rule 1(f)).
- Notifications/reminders beyond what's needed to show state.

## Acceptance Criteria
1. Given a new card is created (from STORY-006 or STORY-008), when saved,
   then it starts in the "idea" state.
2. Given a user schedules a card, when they set a date, then it moves to
   "scheduled."
3. Given a scheduled card's date passes (or the user marks it), when
   actioned, then it moves to "done."
4. Given a done card, when the user attaches a photo, then it moves to
   "memory" state with the photo as its primary stored representation.
5. Given any state, when the user deletes the card, then it is permanently
   removed (XD4).
6. Given the lifecycle exists, when displayed, then no streak count, score,
   or ranking is shown anywhere (rule 1).

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO — extends STORY-006's new list/card
  surfaces.
- Direct URL only acceptable: NO — reached from the activity list.

## Dependencies
- Depends on: STORY-006.
- Must not require any future story: confirmed — STORY-021 depends on this
  story's "done" transition, not the reverse.

## Open Question Impact
NONE.
