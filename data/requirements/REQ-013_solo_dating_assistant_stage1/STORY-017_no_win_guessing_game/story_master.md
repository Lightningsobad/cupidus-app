# Story Master: STORY-017 No-Win Guessing Game

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: New screen — no-win guessing game; no existing design source, UI/UX
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
As a user, I want to play a guessing game about my partner that has no
winner or score, so I get curiosity and reflection instead of a
false-confidence verdict.

## In Scope
1. A guessing game with no score and no winner.
2. Output is always framed as "3 places we see differently" (or similar
   difference-framing), never a correctness verdict.
3. Real answers are explicitly locked/unavailable — reconciling guesses
   against the actual partner's answers is Stage 2 (REQ-014) scope only.

## Out of Scope
- Any scoring, ranking, or "you got X% right" mechanic (R-1).
- Unlocking real answers — that requires the partner's own input, which does
  not exist in solo REQ-013 scope; explicitly deferred to REQ-014.

## Acceptance Criteria
1. Given a user completes the game, when the result is shown, then no score,
   percentage, or winner is displayed.
2. Given a result is shown, when displayed, then it is framed as "places we
   see differently," not a correctness judgment.
3. Given the user looks for real/actual answers, when searched for, then
   none are available in this story — the app states this is unlocked later
   with a partner's participation (REQ-014), without naming implementation
   detail.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO — new standalone screen.
- Direct URL only acceptable: acceptable — no position constraint noted in
  source material for this story.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed — explicitly designed to
  stand alone without REQ-014.

## Open Question Impact
NONE.
