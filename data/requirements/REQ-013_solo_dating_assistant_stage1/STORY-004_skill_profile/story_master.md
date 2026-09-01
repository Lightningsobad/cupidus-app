# Story Master: STORY-004 Skill Profile ("Phiên Bản Tôi")

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: New screen — skill profile; no existing design source, UI/UX
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
As a user, I want to declare my own skills broadly, including intangible
things like "good memory" or "knows good food spots," so the app can later
turn what I'm good at into gift and activity ideas.

## In Scope
1. Onboarding/profile flow asking about skills in deliberately broad terms,
   with example prompts covering intangible skills, not just craft/hobby
   skills.
2. Editable, deletable skill list (XD4).

## Out of Scope
- Any consumption of skills into gift ideas (STORY-011) or activity
  generation (STORY-022) — built here as data only.
- A resume/CV-style skill taxonomy.
- Any scoring or ranking of skills (rule 1(f)).

## Acceptance Criteria
1. Given a user opens their skill profile, when prompted, then example
   categories include intangible skills (memory, food knowledge, listening)
   alongside craft/hobby skills.
2. Given a user has no obvious craft skill, when using the broad prompts,
   then they can still record at least one skill without hitting a dead-end
   empty state.
3. Given a skill entry exists, when deleted, then it is permanently removed
   (XD4).
4. Given the skill profile is viewed, when displayed, then it is a simple
   editable list — no score, rank, or leaderboard framing (rule 1(f)).

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO — new screen.
- Direct URL only acceptable: NO — reached from onboarding/profile
  navigation; exact entry point set by UI/UX Designer.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed — the profile has standalone
  value as a self-declared list even before STORY-011/STORY-022 consume it.

## Open Question Impact
NONE. Note: OQ-3 (content-authoring resourcing) does not apply — this
story's content is entirely user-authored, not hand-edited preset content.
