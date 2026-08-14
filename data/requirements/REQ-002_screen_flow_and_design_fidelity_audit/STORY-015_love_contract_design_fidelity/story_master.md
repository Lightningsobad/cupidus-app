# Story Master: STORY-015 Design Fidelity — Love Contract

Status: PENDING
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: contract (Love Contract), Epic 1 (Core connection / onboarding),
NO_CHROME / NO_TABS
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development) — `visual-fidelity/visual-fidelity-report.md`
- [ ] Review (Reviewer)

## Depends On
- NONE. Independent of every other Scope A/Scope B story; runs as part of
  the story-level-parallel wave for REQ-002 Scope B.

## User Story
As a paired user reviewing our Love Contract, I want the screen to match the
locked design source exactly, so the ritual feels intentional and on-brand.

## In Scope
1. Re-audit the current Love Contract screen (chromeless, no tab bar)
   against `cupid-app-design-system` for the enabled dark theme + `vi`
   locale configuration: contract clause display, clause-id mono type
   treatment per §2, dual-confirmation sign affordance styling, spacing,
   color/design-token usage, and typography.
2. Correct every deviation found directly in the app code so the rendered
   screen matches the design source exactly — this is a fix, not an audit
   report.
3. Audit per-partner sign-status states present in the design source
   (unsigned, self-signed/awaiting-partner, both-signed) for token/style
   fidelity, per STORY-019's already-delivered per-viewer sign-state
   pattern (REQ-001).

## Out of Scope
- Where this screen navigates to next (fingerprint vow) — Scope A
  (STORY-001/STORY-002) owns inter-screen navigation correctness.
- The underlying sign/acknowledge business logic and endpoint behavior
  (already delivered in REQ-001 STORY-006/STORY-019) — this story is visual
  fidelity only, not a functional change.
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Acceptance Criteria
1. Given the Love Contract screen rendered in the enabled dark theme + `vi`
   locale, when compared against `cupid-app-design-system`'s corresponding
   screen, then layout, spacing, color/token usage, and typography match
   exactly with no visible deviation.
2. Given any deviation was found during this story's audit, when the story
   is delivered, then the deviation is corrected in the rendered app (not
   merely documented) and re-verified against the design source.
3. Given each per-partner sign-status state present in the design source
   (unsigned, self-signed/awaiting-partner, both-signed), when rendered,
   then each state's styling matches the design source exactly.
4. Given the contract clause ids on this screen, when rendered, then they
   use the mono type treatment per the design source.
5. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current Love Contract screen, already
  reachable in the shipped app.
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
