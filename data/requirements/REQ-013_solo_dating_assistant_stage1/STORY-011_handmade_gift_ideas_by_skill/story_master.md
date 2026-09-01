# Story Master: STORY-011 Handmade Gift Ideas By Skill

Status: PENDING
Complexity: complex
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: New screen — handmade gift ideas; no existing design source, UI/UX
Designer to create spec.

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- STORY-003, STORY-004, STORY-006.

## User Story
As a user, I want gift ideas generated from my own skills and what I know
about my partner, so I can make something meaningful instead of buying
something generic.

## In Scope
1. A skill (STORY-004) × notebook (STORY-003) matrix producing recipe-style
   gift ideas.
2. Indexing by hours required, never by VNĐ cost (SB-196).
3. Step-by-step recipe format (reusing the SB-17 recipe structure).
4. A "doable in 2 hours tonight" filter.
5. A simpler-alternative fallback when time is short, never a "go buy
   something" fallback.

## Out of Scope
- Any monetary indexing.
- Any suggestion when the skill profile is empty — falls back to STORY-010's
  general gift index instead of inventing content.

## Acceptance Criteria
1. Given a user has at least one declared skill (STORY-004) and at least one
   notebook entry (STORY-003), when they open handmade gift ideas, then the
   matrix produces at least one relevant recipe-style idea.
2. Given an idea is shown, when displayed, then it is indexed by time
   required in hours, never by VNĐ cost.
3. Given the "doable in 2 hours tonight" filter is applied, when used, then
   only ideas meeting that time budget display.
4. Given a filtered idea doesn't fit the user's time budget, when they are
   short on time, then the app offers a simpler version of the same idea,
   not a "go buy something" fallback.
5. Given the user has zero declared skills, when they open this feature,
   then they are guided to STORY-004's skill profile or shown STORY-010's
   general gift index instead of an empty dead-end.
6. Given an idea references the notebook, when displayed, then it complies
   with R-1i (preferences/events only, no behavior-based content).

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO — new screen, entered via the gift flow
  (STORY-010) or directly from the skill profile (STORY-004).
- Direct URL only acceptable: NO.

## Dependencies
- Depends on: STORY-003, STORY-004, STORY-006.
- Must not require any future story: confirmed.

## Open Question Impact
OQ-3 (content-authoring/review resourcing) — BLOCKED for this story's
schedule/priority commitment; also the highest-implementation-risk story in
the requirement per PHẦN 2 ("~80% người dùng trả lời 'không có'" risk if
skill prompts are worded like a CV — mitigated by STORY-004's broad
prompts).
