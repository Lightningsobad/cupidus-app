# Story Master: STORY-028 Design Fidelity — Shared Expenses

Status: PENDING
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: Shared Expenses, Epic 5 (Shared money goals)
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
As a paired user logging a shared expense, I want the Shared Expenses
screen — including its platform-adaptive add-expense action — to match the
locked design source exactly, so the experience feels native on both
platforms and on-brand.

## In Scope
1. Re-audit the current Shared Expenses screen against
   `cupid-app-design-system` for the enabled dark theme + `vi` locale
   configuration: expense list/entry layout, the platform-adaptive
   add-expense action (FAB on one platform, full-width CTA on the other,
   per §3 platform adaptation table), spacing, color/design-token usage,
   and typography.
2. Correct every deviation found directly in the app code so the rendered
   screen matches the design source exactly — this is a fix, not an audit
   report.
3. Preserve the platform-adaptive precedent for the same add-expense action
   exactly as designed (FAB vs. full-width CTA per platform) — do not
   collapse it to a single cross-platform treatment.

## Out of Scope
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Changing the platform-adaptive pattern itself to a single unified
  treatment — the per-platform difference is an intentional design
  decision, not a deviation to fix.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Acceptance Criteria
1. Given the Shared Expenses screen rendered in the enabled dark theme +
   `vi` locale, when compared against `cupid-app-design-system`'s
   corresponding screen, then layout, spacing, color/token usage, and
   typography match exactly with no visible deviation.
2. Given any deviation was found during this story's audit, when the story
   is delivered, then the deviation is corrected in the rendered app (not
   merely documented) and re-verified against the design source.
3. Given the add-expense action on iOS-equivalent and Android-equivalent
   platform targets, when rendered, then each platform uses its own design-
   source-specified treatment (FAB vs. full-width CTA) exactly, with the
   platform difference preserved rather than unified.
4. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current Shared Expenses screen,
  already reachable in the shipped app.
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
