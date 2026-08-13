# Story Master: STORY-005 Design Fidelity — Login

Status: PENDING
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: login, Epic 1 (Core connection / onboarding), NO_CHROME / NO_TABS
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development) — mobile lane, evidence in
      `visual-fidelity/visual-fidelity-report.md`
- [ ] Review (Reviewer)
- [x] Patch round 1 (Mobile Developer) — PATCH-01/PATCH-02 from
      `review/review-report.md`: both auth links regained a `--tap` hit area
      (44pt iOS / 48pt Material) with no rendered-text movement beyond 0.5pt.

## Depends On
- NONE. Independent of every other Scope A/Scope B story; runs as part of
  the story-level-parallel wave for REQ-002 Scope B.

## User Story
As a user viewing the login screen, I want it to match the locked design
source exactly, so that the app feels visually consistent and trustworthy
while I authenticate.

## In Scope
1. Re-audit the current login screen (chromeless, no tab bar) against
   `cupid-app-design-system` for the enabled dark theme + `vi` locale
   configuration: form field styling, forgot-password link placement,
   primary CTA styling (platform-adaptive pill vs. Material filled button
   per §3), spacing, color/design-token usage, and typography.
2. Correct every deviation found directly in the app code so the rendered
   screen matches the design source exactly — this is a fix, not an audit
   report.
3. Audit form field states present in the design source (empty, focused,
   filled, error/validation) for token/style fidelity.

## Out of Scope
- Where login navigates to after success/failure, and whether login is the
  correct screen to show at all for a given state — Scope A
  (STORY-001/STORY-002) owns entry-point and inter-screen navigation
  correctness.
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Acceptance Criteria
1. Given the login screen rendered in the enabled dark theme + `vi` locale,
   when compared against `cupid-app-design-system`'s corresponding screen,
   then layout, spacing, color/token usage, and typography match exactly
   with no visible deviation.
2. Given any deviation was found during this story's audit, when the story
   is delivered, then the deviation is corrected in the rendered app (not
   merely documented) and re-verified against the design source.
3. Given each form-field state present in the design source (empty,
   focused, filled, error/validation), when rendered, then each state's
   styling matches the design source exactly.
4. Given the primary CTA on this screen, when rendered on iOS vs. Android,
   then it follows the platform-adaptive pattern from §3 (full-width pill
   on iOS, filled button with ripple on Android) rather than one style
   forced on both platforms.
5. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current login screen, already
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
