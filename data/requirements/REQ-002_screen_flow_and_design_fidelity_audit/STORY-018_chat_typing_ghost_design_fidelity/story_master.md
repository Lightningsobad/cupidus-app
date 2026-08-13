# Story Master: STORY-018 Design Fidelity — Chat & Typing Ghost

Status: PENDING
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: chat (+ Typing Ghost), Epic 2 (Communication), 5-tab chrome (chat
tab active)
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE. Independent of every other Scope A/Scope B story; runs as part of
  the story-level-parallel wave for REQ-002 Scope B.

## User Story
As a paired user chatting with my partner, I want the chat screen to match
the locked design source exactly, so the conversation feels visually
consistent, trustworthy, and appropriately private.

## In Scope
1. Re-audit the current chat screen (5-tab chrome, chat tab active) against
   `cupid-app-design-system` for the enabled dark theme + `vi` locale
   configuration: message bubble styling, Typing Ghost fading/struck-through
   treatment (`ghostFade` keyframe per §2), Level-1 device-only lock
   affordance (must be visible at all times per §5/§8), spacing, color/
   design-token usage, and typography.
2. Correct every deviation found directly in the app code so the rendered
   screen matches the design source exactly — this is a fix, not an audit
   report.

## Out of Scope
- The Typing Ghost consent/settings screen — separate screen, separate
  story (STORY-019).
- Where chat is reached from — Scope A owns tab navigation entry only where
  flagged; this story covers only the chat screen's own rendered content.
- Any new feature, new screen state, or new interaction not already present
  in the locked design source, including any persistence of Typing Ghost
  content (explicitly ephemeral/no persistence per the design source).
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Acceptance Criteria
1. Given the chat screen rendered in the enabled dark theme + `vi` locale,
   when compared against `cupid-app-design-system`'s corresponding screen,
   then layout, spacing, color/token usage, and typography match exactly
   with no visible deviation.
2. Given any deviation was found during this story's audit, when the story
   is delivered, then the deviation is corrected in the rendered app (not
   merely documented) and re-verified against the design source.
3. Given the Level-1 device-only lock affordance, when the chat screen is
   rendered, then the lock affordance is visible at all times, matching the
   design source's placement and styling.
4. Given a Typing Ghost deleted-but-typed-text moment, when rendered on the
   partner's screen, then it uses the design source's `ghostFade` keyframe
   (struck-through/fading), not an ad hoc treatment.
5. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current chat screen, already reachable
  in the shipped app.
- Direct URL only acceptable: N/A — existing reachable screen, not new.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed.

## Open Question Impact
OQ5 (light theme / `en` locale) only affects out-of-scope light/`en`
user-facing visual QA per this story's Out of Scope section; it does not
block any in-scope acceptance criterion.

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-5) are unblocked.
