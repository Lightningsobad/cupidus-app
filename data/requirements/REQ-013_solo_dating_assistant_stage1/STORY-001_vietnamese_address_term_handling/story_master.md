# Story Master: STORY-001 Vietnamese Pair-Specific Address-Term Handling

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: Cross-cutting copy layer — no single screen; new screen/spec TBD by
UI/UX Designer for the one-time address-term preference prompt.

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE.

## User Story
As a user, I want the app to address my partner and me using natural
Vietnamese pair terms (anh/em and similar forms), so that copy feels natural
instead of generic or robotic.

## In Scope
1. A central address-term resolution capability used by every Stage-1
   screen's copy that refers to "you," "your partner," or "the two of you."
2. A one-time, simple preference choice (or sensible default) captured during
   setup for the pair's address terms.
3. Editable/deletable preference, applied immediately across the app on
   change.

## Out of Scope
- A general i18n framework rework or support for languages other than
  Vietnamese.
- Any change to app navigation structure.
- Content authored by later stories (STORY-006 and on) — this story only
  builds the resolution capability those stories' copy will use.

## Acceptance Criteria
1. Given a new user completes setup, when address-term preference isn't yet
   declared, then the app prompts a one-time simple choice (or applies a
   sensible default) for the pair's address terms.
2. Given a pair-term is set, when any Stage-1 screen renders copy referencing
   the user or partner, then it uses the correct declared term form, not a
   generic placeholder.
3. Given the user changes their address-term preference, when saved, then it
   is editable and deletable (XD4) and immediately reflected across the app.
4. Given no explicit preference exists, when copy renders, then a safe
   neutral default is shown rather than a placeholder token or crash.

## System Integration And Discoverability
- UI-facing story: YES (the one-time preference prompt); otherwise a
  cross-cutting copy capability.
- Existing user-visible surface: NO — new capability.
- Direct URL only acceptable: NO — reached through setup/onboarding.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed — this story only builds the
  resolution capability; it does not require any content story to exist.

## Open Question Impact
NONE.
