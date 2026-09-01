# Story Master: STORY-003 Relationship Notebook

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: New screen — relationship notebook; no existing design source, UI/UX
Designer to create spec.

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE.

## User Story
As a user, I want a private notebook to record my partner's preferences and
events I've learned, so I can hold onto useful details without relying on
memory.

## In Scope
1. Structured entry fields: size, allergy, disliked item, topic of interest,
   important date, "said they like X," fear.
2. A one-tap "just heard" quick-capture free-text field.
3. Private-by-default, deletable (XD4), never exportable (R-1f).
4. Copy/prompts for structured fields steer toward preferences/events, not
   behavior/frequency (R-1i).

## Out of Scope
- Any auto-suggestion or inference drawn from notebook content — consumed by
  STORY-010, STORY-011, STORY-013, STORY-014, STORY-015, not built here.
- Any export or sharing capability (never, R-1f).
- A dedicated "hàng rào" (Tầng 0) story — its rules are this story's AC.

## Acceptance Criteria
1. Given a user opens the notebook, when they add an entry, then they can
   choose a structured field type or write a free "just heard" note.
2. Given an entry exists, when the user deletes it, then it is permanently
   removed (XD4).
3. Given the notebook exists, when any export/share action is attempted,
   then none is available anywhere in the UI (R-1f).
4. Given a structured "preference/event" field, when the UI prompts for it,
   then the prompt copy steers toward preferences/events, not behavior or
   frequency (R-1i) — e.g. "what they like," not "how often they X."
5. Given no partner has paired, when the notebook is used, then it works
   fully solo.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO — new screen.
- Direct URL only acceptable: NO — reached from the main Stage-1 navigation;
  exact entry point set by UI/UX Designer.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed — the notebook has standalone
  value as a private record even before any downstream feature consumes it.

## Open Question Impact
OQ-2 (one "ngăn" vs many) affects this story's information architecture —
NOT BLOCKED, deferred to UI/UX Designer at design time (see
`requirements/requirements.md`).
