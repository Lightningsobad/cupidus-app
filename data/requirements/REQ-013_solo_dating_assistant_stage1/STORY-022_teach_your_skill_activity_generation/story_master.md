# Story Master: STORY-022 Teach-Your-Skill Activity Generation

Status: PENDING
Complexity: trivial
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: No new primary screen — generates an entry into the existing
curated activity list (STORY-006); UI/UX Designer to spec any distinct
card treatment.

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- STORY-004, STORY-006.

## User Story
As a user, I want the app to turn one of my own skills into a free "teach
your partner" activity card, so I have a no-cost, personal activity idea
generated from what I already know.

## In Scope
1. Reads the user's skill profile (STORY-004) and generates a "teach your
   [skill]" activity card into the curated activity list (STORY-006),
   flagged as free/no-cost (SB-206).

## Out of Scope
- Any scoring of skill quality or comparison between users' skills.
- Any change to STORY-004's or STORY-006's own data model — this story only
  reads from one and writes an entry into the other.

## Acceptance Criteria
1. Given the user has at least one skill in their skill profile (STORY-004),
   when this feature runs, then a "teach your [skill]" activity card is
   generated into the curated activity list (STORY-006).
2. Given the generated card, when displayed, then it is flagged as free/
   no-cost.
3. Given the user has no skills declared, when this feature runs, then no
   card is generated and no error is shown.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: generated card appears inside STORY-006's
  existing curated activity list.
- Direct URL only acceptable: N/A — not an independent screen.

## Dependencies
- Depends on: STORY-004, STORY-006.
- Must not require any future story: confirmed — deliberately kept last-tier
  per SB-174, not merged earlier into STORY-011 to respect tier ordering.

## Open Question Impact
NONE.
