# Story Master: STORY-020 Solo End-Of-Day Closing Ritual

Status: PENDING
Complexity: trivial
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: New micro-touchpoint — end-of-day closing prompt; no existing design
source, UI/UX Designer to create spec.

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- STORY-005.

## User Story
As a user, I want a small end-of-day closing prompt when I've just gotten
home, so I can quickly capture a thought before the day fades.

## In Scope
1. A lightweight prompt tied to the "just got home" touchpoint (~23h,
   GI7 solo), writing directly to the private journal (STORY-005).

## Out of Scope
- Any partner-facing content — solo journal write only.
- Any push-notification scheduling infrastructure — Tech Lead scope to
  determine trigger mechanism; this story defines only the user-visible
  prompt and its journal write behavior.

## Acceptance Criteria
1. Given the user opens the app at/near the "just got home" touchpoint, when
   the closing prompt appears, then it offers a quick one-tap or short-text
   capture.
2. Given the user submits the prompt, when saved, then the entry is written
   to the private journal (STORY-005) with the same privacy defaults
   (private-by-default, deletable).
3. Given the user dismisses the prompt, when dismissed, then no entry is
   created and no repeated nagging occurs in the same session.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: writes into STORY-005's private journal.
- Direct URL only acceptable: N/A — a contextual micro-touchpoint, not a
  primary navigable screen.

## Dependencies
- Depends on: STORY-005.
- Must not require any future story: confirmed.

## Open Question Impact
NONE.
