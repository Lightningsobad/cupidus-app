# Story Master: STORY-013 Date Script Generator

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: New screen — date script generator; no existing design source,
UI/UX Designer to create spec.

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- STORY-003, STORY-005, STORY-006.

## User Story
As a user, I want a full before/during/after plan for a date given my
budget, timing, and what I know about my partner, so I'm not planning from
scratch.

## In Scope
1. Inputs: budget, duration, weather, season, relationship stage, and
   notebook (STORY-003) content.
2. A three-part (before/during/after) generated script.
3. Three exits: save as an activity card (STORY-006/STORY-007), save to the
   journal (STORY-005), or create an invite (once STORY-018 exists).

## Out of Scope
- Lunar-occasion-driven suggestions — deferred to STORY-019; this story
  ships without that input, treating it as absent rather than broken.
- The invite-export rendering itself (STORY-018) — this story only links to
  it as an exit once it exists.

## Acceptance Criteria
1. Given a user provides budget, duration, weather, season, and relationship
   stage, when generated, then a three-part (before/during/after) date
   script is produced.
2. Given the user has notebook entries (STORY-003), when generating, then
   the script incorporates relevant notebook content, complying with
   R-1g/R-1h/R-1i.
3. Given a generated script, when the user chooses an exit, then they can
   save it as an activity card or a journal entry; invite export is
   available only once STORY-018 exists.
4. Given no lunar/occasion data source exists yet (STORY-019 not built),
   when the script generates, then it omits lunar-occasion input entirely
   rather than showing a broken/empty field.
5. Given the script mentions the partner, when displayed, then it ends any
   partner-related content in a question to ask the real person, per R-1g.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO — new screen.
- Direct URL only acceptable: NO.

## Dependencies
- Depends on: STORY-003, STORY-005, STORY-006.
- Must not require any future story: confirmed — lunar-occasion input and
  invite export are explicitly optional/deferred, not required, so this
  story does not promise behavior only STORY-018/STORY-019 can deliver.

## Open Question Impact
NONE directly; STORY-014 and STORY-015 depend on this story existing as
their required non-home-screen entry point (SB-208).
