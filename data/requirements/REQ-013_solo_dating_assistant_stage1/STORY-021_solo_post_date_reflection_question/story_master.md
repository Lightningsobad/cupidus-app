# Story Master: STORY-021 Solo Post-Date Reflection Question

Status: PENDING
Complexity: trivial
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: New micro-touchpoint — post-date reflection prompt; no existing
design source, UI/UX Designer to create spec.

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- STORY-005, STORY-007.

## User Story
As a user, I want a short reflection question after a date is marked done,
so I can capture how it went while it's fresh.

## In Scope
1. A reflection prompt tied to the "waiting" touchpoint (KY2 solo),
   triggered by an activity card entering the "done" state (STORY-007),
   writing to the private journal (STORY-005).

## Out of Scope
- Any partner-facing content — solo journal write only.
- Any scoring/rating of the date or the partner (R-1).

## Acceptance Criteria
1. Given an activity card transitions to "done" (STORY-007), when the
   transition completes, then a short reflection prompt is offered.
2. Given the user answers, when saved, then the entry is written to the
   private journal (STORY-005) with the same privacy defaults.
3. Given the prompt content, when authored, then it never asks the user to
   score, rate, or rank the date or the partner (R-1).
4. Given the user dismisses the prompt, when dismissed, then no entry is
   created and no repeated nagging occurs.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: triggered from STORY-007's "done" state,
  writes into STORY-005's private journal.
- Direct URL only acceptable: N/A — a contextual micro-touchpoint.

## Dependencies
- Depends on: STORY-005, STORY-007.
- Must not require any future story: confirmed.

## Open Question Impact
NONE.
