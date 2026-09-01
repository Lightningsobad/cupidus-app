# Story Master: STORY-018 Invite Export

Status: PENDING
Complexity: complex
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: New screen — invite export/share flow; no existing design source,
UI/UX Designer to create spec.

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- STORY-006.

## User Story
As a user, I want to turn an activity card into a shareable invite image or
card, so I can invite my partner without the app tracking whether they saw
it or answered.

## In Scope
1. Render any activity card (STORY-006/STORY-007) as a shareable
   image/card via a mock-formal template, a mad-libs style template, and a
   voice/tone choice.
2. Output built as a renderable "payload" object (SB-125) so `REQ-014` can
   later extend it into a two-way link without a redesign.

## Out of Scope
- Any read receipt, view tracking, or delivery confirmation (R-1b).
- Any two-way link/response mechanism — that is `REQ-014` scope, built on
  top of this story's payload shape without modifying it here.

## Acceptance Criteria
1. Given an activity card, when exported, then the user can choose between
   a mock-formal template and a mad-libs style template, plus a voice/tone
   option.
2. Given an export is generated, when inspected, then it contains no
   tracking mechanism of any kind — no read receipt, no view pixel, no
   delivery confirmation (R-1b).
3. Given the recipient does not respond, when the sender returns to the app,
   then nothing in the app implies the recipient saw or ignored it — a clean
   decline/no-response experience (R-1c).
4. Given the export content, when authored, then any joke content targets
   only the sender, never the recipient (R-1d).
5. Given the export's internal data shape, when inspected by Tech Lead, then
   it is structured as a renderable payload object suitable for later
   extension into a two-way link (SB-125) — this AC constrains data shape,
   not UI.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: extends STORY-006/STORY-007 activity cards
  with an export action.
- Direct URL only acceptable: NO — reachable from an existing activity
  card's action menu.

## Dependencies
- Depends on: STORY-006.
- Must not require any future story: confirmed — payload shape anticipates
  REQ-014 without requiring it.

## Open Question Impact
NONE.
