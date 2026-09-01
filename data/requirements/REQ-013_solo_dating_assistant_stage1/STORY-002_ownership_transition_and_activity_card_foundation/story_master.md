# Story Master: STORY-002 Ownership Transition + Structured Activity-Card Foundation

Status: PENDING
Complexity: complex
Story-Class: shared-foundation
Implementation Lane: shared
Requirement: REQ-013
Screen: No dedicated screen — data-ownership model + activity-card schema
foundation underlying every other Stage-1 story.

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead) — owns the actual ownership-transition data
      model; this file scopes user-visible behavior and the business
      requirement for structured activity-card attributes (SB-76) only, per
      `req_master.md` Story Seeds note that M2 is Tech-Lead-owned
      architecture work.
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE. This is the shared-foundation story every other STORY-013 story and
  every `REQ-014` story depends on (`req_master.md` Dependencies).

## User Story
As a solo user, I want the app to work fully on my own account without
requiring a partner's account, and to transition smoothly to shared
ownership when my partner eventually joins, so that Stage 1 is fully usable
alone and Stage 2 doesn't require rebuilding my data.

## In Scope
1. Solo-mode operation: every core Stage-1 capability functions without a
   paired partner or any `coupleId`-shaped assumption blocking it.
2. The business-level concept of an ownership transition ("graduation")
   moment when a partner joins — user-visible behavior only, not the
   `REQ-014` invite UX itself.
3. The structured activity-card data foundation (SB-76): every activity card
   supports price (VNĐ range), duration, time-of-day window, season,
   headcount, a booking-required flag, and distance.

## Out of Scope
- The actual invite/pairing UX and any `REQ-014` mutual-consent mechanics
  (`REQ-014` C0 scope).
- Any AI involvement (rule 5).
- Prescribing the underlying data model — that is Tech Lead's architecture
  decision; this story states the user-visible and business requirements
  only.

## Acceptance Criteria
1. Given a new user with no partner paired, when they use any Stage-1
   feature (activity list, journal, notebook, skill profile), then it
   functions fully without a paired partner.
2. Given a user later pairs (via an out-of-scope `REQ-014` mechanism), when
   ownership transitions, then no Stage-1 solo data is lost or requires
   manual re-entry.
3. Given an activity card is created, when saved, then it stores price (VNĐ
   range), duration, time-of-day window, season, headcount, booking-required
   flag, and distance, even when left blank.
4. Given existing code paths assume a `coupleId`, when a solo user exercises
   them, then no `coupleId`-shaped error occurs.

## System Integration And Discoverability
- UI-facing story: PARTIAL — mostly a data-foundation story; any visible
  surface (e.g. a "solo mode" indicator) is minimal and Tech-Lead/UX-defined.
- Existing user-visible surface: NO — this is the largest, riskiest
  foundation item in the whole breakdown (`req_master.md` Story Seeds:
  Impact 5 / Effort 5).
- Direct URL only acceptable: N/A — foundation story.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed — every other Stage-1 story
  depends on this one, not the reverse.

## Open Question Impact
NONE directly; OQ-3 (content-authoring resourcing) does not block this
story — see `requirements/requirements.md` Open Question Triage.
