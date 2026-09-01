# Story Master: STORY-010 Gift Idea Index

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: New screen — gift idea index; no existing design source, UI/UX
Designer to create spec.

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- STORY-003, STORY-006.

## User Story
As a user, I want to browse gift ideas indexed by Vietnamese occasion,
relationship stage, and what I've recorded about my partner, so I get
relevant, non-generic gift ideas without buying anything through the app.

## In Scope
1. Gift as an activity-card type within STORY-006's list.
2. Indexing by Vietnamese occasion × relationship stage × notebook
   (STORY-003) content.
3. A "free/no-cost gift" branch.
4. A timely reminder before the relevant occasion.

## Out of Scope
- Any commerce, purchase link, or affiliate integration — explicitly
  excluded by `req_master.md` Out of Scope and D-11 (SB-154).
- Handmade-specific mechanics — STORY-011.

## Acceptance Criteria
1. Given a user opens gift ideas, when browsing, then results are
   filtered/ranked by Vietnamese occasion, relationship stage, and notebook
   content when available.
2. Given the user has recorded no notebook entries, when browsing, then gift
   ideas still show a generic-but-relevant fallback, not an empty state.
3. Given a "no-cost gift" filter is applied, when used, then only $0 ideas
   display.
4. Given no commerce capability exists, when any gift idea is viewed, then
   there is no purchase link, price-to-buy CTA, or affiliate reference
   anywhere.
5. Given an occasion is approaching, when within a defined reminder window,
   then the user receives a timely, specific nudge — not a generic push
   blast.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO — new screen, entered via STORY-006's
  list as a gift-typed card.
- Direct URL only acceptable: NO.

## Dependencies
- Depends on: STORY-003, STORY-006.
- Must not require any future story: confirmed — works with or without
  STORY-019's lunar-calendar timing enhancement.

## Open Question Impact
OQ-3 (content-authoring/review resourcing) — BLOCKED for this story's
schedule/priority commitment until the user answers it (see
`requirements/requirements.md`).
