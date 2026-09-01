# Story Master: STORY-014 Self-Authored Partner Portrait

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: New screen — self-authored portrait ("theo cách BẠN nhìn"); no
existing design source, UI/UX Designer to create spec. Position constraint:
must NOT be reachable from the home screen (SB-208).

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- STORY-003, STORY-013.

## User Story
As a user, I want to answer a questionnaire on my partner's behalf, based
only on what I've noticed, so I can reflect on the relationship without the
app inventing anything about them.

## In Scope
1. A questionnaire the user answers as if they were their partner.
2. Every output states "based on what YOU entered" directly in the layout
   (R-1, tier-3 condition).
3. Editable and deletable (XD4); never exportable (R-1f).
4. Entry point only from a date (STORY-013) or a gift flow (STORY-010,
   STORY-011) — never the home screen (SB-208).

## Out of Scope
- Any "accuracy check" against the real partner — that is `REQ-014`'s
  portrait-reconciliation reward moment (PHẦN 3, SB-189), explicitly out of
  `REQ-013` scope.

## Acceptance Criteria
1. Given a user completes the portrait questionnaire, when submitted, then
   all answers are self-declared by the user only — no data is pulled from
   any other source.
2. Given the portrait is displayed, when rendered, then "based on what YOU
   entered" appears directly in the layout, not a footnote.
3. Given the portrait exists, when the user edits or deletes it, then
   changes/deletion take effect immediately (XD4).
4. Given no export/share action exists, when searched for, then none is
   available (R-1f).
5. Given the home screen, when viewed, then there is no entry point to this
   feature there — it is only reachable from a date (STORY-013) or gift flow
   (STORY-010/STORY-011), per SB-208.
6. Given any portrait content references the partner's intent or feelings,
   when authored, then it is rejected — general pattern descriptions only,
   per R-1h.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO — new screen with a deliberately
  restricted entry point.
- Direct URL only acceptable: NO — reachable only via STORY-013 or
  STORY-010/STORY-011, per SB-208.

## Dependencies
- Depends on: STORY-003, STORY-013.
- Must not require any future story: confirmed.

## Open Question Impact
NONE directly. Governed by the amended `## Invariant Design Rules` R-1
tier-3 condition, R-1f, R-1h.
