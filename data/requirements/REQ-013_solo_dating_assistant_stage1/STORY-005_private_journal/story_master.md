# Story Master: STORY-005 Private Journal

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: New screen — private journal (C6); no existing design source, UI/UX
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
As a user, I want a private journal to write personal entries, so I have a
space that's mine even before Stage 2.

## In Scope
1. Create, read, and delete journal entries.
2. Private-by-default storage, deletable (XD4).
3. Built so that `REQ-014` G-2 (ii-b) symmetric-private-space treatment does
   not require a data-model rework later (Invariant Design Rule 6).

## Out of Scope
- Sharing, export, or any AI summarization.
- A paired/shared journal (`REQ-014` scope).

## Acceptance Criteria
1. Given a user writes a journal entry, when saved, then it is stored
   private-by-default with no partner visibility, and the data model does
   not assume future visibility without an explicit later action.
2. Given an entry exists, when deleted, then it is permanently removed
   (XD4).
3. Given the journal's design, when reviewed against `REQ-014` G-2 (ii-b) by
   Tech Lead at architecture time, then no schema rework is required to add
   the symmetric private-space treatment later.
4. Given no export capability exists, when any share/export action is
   searched for, then none is present.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO — new screen.
- Direct URL only acceptable: NO — reached from the main Stage-1
  navigation; exact entry point set by UI/UX Designer.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed — STORY-009, STORY-020, and
  STORY-021 depend on this story, not the reverse.

## Open Question Impact
NONE.
