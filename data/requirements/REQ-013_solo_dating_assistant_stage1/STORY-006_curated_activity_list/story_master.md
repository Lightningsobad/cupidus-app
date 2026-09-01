# Story Master: STORY-006 Curated Cross-Stage Activity List

Status: PENDING
Complexity: complex
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: New screen — cross-stage activity list (C1); no existing design
source, UI/UX Designer to create spec.

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead) — must confirm the exact current backend
      module path/state of `dream_jar` before folding it in (see Open
      Question Impact below; unresolved, not blocking story creation).
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- STORY-001 (address-term copy conventions), STORY-002 (structured
  activity-card data foundation).

## User Story
As a user, I want to browse a curated list of 150-250 hand-edited activity
and date ideas with real price ranges, so I have concrete, non-generic ideas
instead of a blank page.

## In Scope
1. A curated content table of 150-250 hand-edited activity/date cards,
   shipped as a versioned, downloadable data package (same static-content
   pattern as `REQ-011`'s zodiac content).
2. Real VNĐ price ranges on each card.
3. Folding in the existing `dream_jar` module content as the "shared
   dreams" (future-tense) activity type within this same list.
4. Cards use the structured attributes from STORY-002 (duration, timeslot,
   season, headcount, booking-required, distance) when populated.

## Out of Scope
- Gift-specific indexing (STORY-010, STORY-011).
- Lifecycle states (STORY-007).
- Capture via pasted link or share sheet (STORY-008).
- Any AI-generated suggestion at runtime (never, rule 5) — content is
  authored offline and shipped as static data.

## Acceptance Criteria
1. Given a user opens the activity list, when it loads, then it shows a
   curated set of 150-250 hand-edited cards (shipped as a versioned data
   package), each with a real VNĐ price range.
2. Given `dream_jar`-sourced content exists, when displayed, then it appears
   as the "shared dreams" (future-tense) activity type within this same
   list, not a separate screen.
3. Given a card is shown, when viewed, then it displays the structured
   attributes from STORY-002 when populated.
4. Given the content-approval rule, when any card is authored, then it has
   passed human review before shipping (rule 5 clarification) — enforced at
   the content-authoring process level, not at runtime.
5. Given a user has no partner paired, when browsing, then the list works
   fully solo.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO — new screen; absorbs the existing but
  unwired `dream_jar` backend module (`backend/src/modules/` — exact path to
  be confirmed by Tech Lead).
- Direct URL only acceptable: NO — reached from the main Stage-1 navigation;
  exact entry point set by UI/UX Designer.

## Dependencies
- Depends on: STORY-001, STORY-002.
- Must not require any future story: confirmed — STORY-007, STORY-008,
  STORY-010 through STORY-022 depend on this story's list existing, not the
  reverse.

## Open Question Impact
- Pre-existing req_master OQ "exact MVP taxonomy/authoring source" —
  RESOLVED: same static, versioned curated-content-table pattern as
  `REQ-011`'s zodiac content.
- Pre-existing req_master OQ "confirm exact current backend module
  path/state of `dream_jar`" — UNRESOLVED, not blocking. This is a technical
  discovery question for Tech Lead at this story's architecture step, not a
  product decision.
- OQ-3 (content-authoring/review resourcing) — BLOCKED for this story's
  schedule/priority commitment until the user answers it (see
  `requirements/requirements.md`).
