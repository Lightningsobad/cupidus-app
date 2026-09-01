# Story Master: STORY-012 Conversation Starters

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: New screen — conversation starters (mồi chuyện); no existing design
source, UI/UX Designer to create spec.

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- STORY-001, STORY-006.

## User Story
As a user, I want a library of conversation-starter ideas plus scheduled
seasonal events, so I always have something relevant to talk about or plan
around.

## In Scope
1. Bản A — evergreen, topic-tagged conversation-starter cards, static
   content.
2. Bản A+ — scheduled seasonal events (movies, matches, festivals,
   exhibitions), shipped as a dated data package, never containing negative
   or distressing content.
3. A+ items convert directly into an activity card (STORY-006/STORY-007).

## Out of Scope
- Bản B — a real, live news feed. Explicitly excluded; `REQ-014` may
  re-evaluate it.

## Acceptance Criteria
1. Given a user opens conversation starters, when browsing, then evergreen
   topic-tagged cards (bản A) are available regardless of date.
2. Given a seasonal scheduled event is within its active window, when
   displayed, then it appears as an A+ card with its date, and never
   contains negative or distressing content.
3. Given a user taps "turn into an activity," when an A+ card is selected,
   then a new activity card is created (STORY-006/STORY-007) pre-filled from
   that event.
4. Given the library, when authored, then it ships as static versioned
   content (rule 5) — no live feed integration exists anywhere in this
   story.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO — new screen.
- Direct URL only acceptable: NO.

## Dependencies
- Depends on: STORY-001, STORY-006.
- Must not require any future story: confirmed — works with or without
  STORY-019's lunar-calendar enhancement.

## Open Question Impact
OQ-3 (content-authoring/review resourcing) — BLOCKED for this story's
schedule/priority commitment until the user answers it.
