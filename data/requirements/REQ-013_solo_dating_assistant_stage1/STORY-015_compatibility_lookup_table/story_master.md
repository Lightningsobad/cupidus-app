# Story Master: STORY-015 Compatibility Lookup Table

Status: PENDING
Complexity: complex
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-013
Screen: New screen — compatibility lookup ("bảng tra ăn khớp"); no existing
design source, UI/UX Designer to create spec. Position constraint: must NOT
be reachable from the home screen (SB-208).

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- STORY-003, STORY-013.

## User Story
As a user, I want to see a range-based compatibility read on my relationship
based on self-declared traits, so I get a lightweight, honest reflection
rather than a flattering score.

## In Scope
1. A 12×12 (144-cell) zodiac lookup table and a 16×16 (256-cell) MBTI lookup
   table, both hand-authored, all inputs self-declared.
2. A fixed output "quartet": an easy-match spot, an easy-friction spot, one
   activity to try, and one question to ask (R-1g).
3. Display as a descriptive range, never a percentage (D-14).
4. Entry point only from a date (STORY-013) or a gift flow (STORY-010,
   STORY-011) — never the home screen (SB-208).

## Out of Scope
- Any dynamic or model-generated scoring — deterministic table lookup only
  (rule 5).
- Percentage display — explicitly excluded (D-14).

## Acceptance Criteria
1. Given both self-declared zodiac and/or MBTI type, when looked up, then
   the result comes from the static 144-cell or 256-cell hand-authored
   table — no runtime computation beyond table lookup.
2. Given a result is shown, when displayed, then it is a descriptive range
   ("this pairing tends to clash early, ease later"), never a percentage.
3. Given a result is shown, when displayed, then it always includes all four
   quartet elements: an easy-match spot, an easy-friction spot, one activity
   to try, and one question to ask.
4. Given every lookup cell, when authored, then it contains at least one
   point of friction, never praise only (content-approval rule).
5. Given the home screen, when viewed, then there is no entry point to this
   feature there — only reachable from a date or gift flow (SB-208).
6. Given the result references the partner, when displayed, then it
   complies with R-1g (ends in a question) and R-1h (no asserted
   intent/feelings).

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
- OQ-3 (content-authoring/review resourcing) — BLOCKED for this story's
  schedule/priority commitment; 144+256 cells is the single largest content
  line item named in OQ-3.
- Governed directly by the amended `## Invariant Design Rules` R-1 tier-3
  condition, R-1g, R-1h, and the content-approval rule.
