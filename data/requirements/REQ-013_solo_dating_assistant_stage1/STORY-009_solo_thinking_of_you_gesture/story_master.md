# Story Master: STORY-009 Solo "Thinking Of You" Journal Gesture

Status: PENDING
Complexity: trivial
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: Small addition to an existing Stage-1 surface (home or journal
entry point); no existing design source, UI/UX Designer to place it.

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- STORY-005.

## User Story
As a user, I want a one-tap "thinking of you" gesture, so I can quickly note
the feeling even though it doesn't go anywhere since my partner isn't in the
app yet.

## In Scope
1. A single-tap action that writes one entry into the private journal
   (STORY-005), timestamped.

## Out of Scope
- Any paired/sent version of this gesture — `REQ-014` GI3 scope.
- Any notification, delivery, or recipient — none exists in Stage 1.

## Acceptance Criteria
1. Given a user taps the gesture, when tapped, then one entry is written to
   the private journal (STORY-005) with a timestamp.
2. Given the gesture exists, when tapped, then nothing is sent anywhere and
   no recipient exists.
3. Given the journal entry it creates, when the user deletes it, then it is
   permanently removed (XD4), same as any other journal entry.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO — small new affordance; exact placement
  set by UI/UX Designer.
- Direct URL only acceptable: NO.

## Dependencies
- Depends on: STORY-005.
- Must not require any future story: confirmed.

## Open Question Impact
NONE.
