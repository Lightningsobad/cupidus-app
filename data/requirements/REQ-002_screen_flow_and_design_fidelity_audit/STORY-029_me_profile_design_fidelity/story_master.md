# Story Master: STORY-029 Design Fidelity — Me / Profile

Status: PENDING
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: Me / Profile (5-tab bottom nav "me" tab), Epic 6 (Account, privacy,
notifications) — Level-3 data
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE. Independent of every other Scope A/Scope B story; runs as part of
  the story-level-parallel wave for REQ-002 Scope B.

## User Story
As a paired user viewing my own profile after pairing, I want the Me /
Profile screen to match the locked design source exactly, so account
management feels polished and on-brand.

## In Scope
1. Re-audit the current Me / Profile screen (the post-pairing "me" tab in
   the 5-tab bottom nav — home/chat/pet/money/me — distinct from the
   onboarding profile-setup screen covered by STORY-010) against
   `cupid-app-design-system` for the enabled dark theme + `vi` locale
   configuration: profile summary layout, account-settings entry list,
   spacing, color/design-token usage, and typography.
2. Correct every deviation found directly in the app code so the rendered
   screen matches the design source exactly — this is a fix, not an audit
   report.

## Out of Scope
- The onboarding profile-setup screen — that is STORY-010's scope (Epic 1,
  pre-pairing, no chrome).
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Acceptance Criteria
1. Given the Me / Profile screen rendered in the enabled dark theme + `vi`
   locale, when compared against `cupid-app-design-system`'s corresponding
   screen, then layout, spacing, color/token usage, and typography match
   exactly with no visible deviation.
2. Given any deviation was found during this story's audit, when the story
   is delivered, then the deviation is corrected in the rendered app (not
   merely documented) and re-verified against the design source.
3. Given this screen displays Level-3 sensitivity data (per §8 of UX system
   memory), when rendered, then any data-sensitivity-specific visual
   treatment specified in the design source is present and correct.
4. Given the screen is reached through the existing 5-tab bottom nav "me"
   tab, when a user arrives at it, then no new entry point is required —
   this story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current Me / Profile screen, already
  reachable in the shipped app via the "me" tab.
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
- All acceptance criteria (1-4) are unblocked.
