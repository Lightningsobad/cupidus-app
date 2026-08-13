# Story Master: STORY-004 Design Fidelity — Welcome

Status: PENDING
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: welcome, Epic 1 (Core connection / onboarding), NO_CHROME / NO_TABS
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development) — mobile lane
- [ ] Review (Reviewer)

## Implementation Evidence
- Corrected screen:
  `mobile/lib/features/auth/presentation/screens/welcome_screen.dart`
- Fidelity report (11 deviations fixed, 2 deferred):
  `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-004_welcome_design_fidelity/visual-fidelity/visual-fidelity-report.md`
- Regression pin (6 new widget tests):
  `mobile/test/features/auth/presentation/screens/welcome_screen_test.dart`
- Verification: `flutter analyze lib/features/auth test/features/auth` clean;
  `flutter test test/features/auth test/design_system test/widget_test.dart test/core/navigation`
  → 61 passed.
- Deferred to follow-up (outside this story's WriteScope): Apple/Google brand
  glyph assets (`mobile/assets/**` + `pubspec.yaml`) and literal brand hex
  tokens (`mobile/lib/design_system/`). Both detailed in the fidelity report.

## Depends On
- NONE. Independent of every other Scope A/Scope B story; runs as part of
  the story-level-parallel wave for REQ-002 Scope B.

## User Story
As a user viewing the welcome screen, I want it to match the locked design
source exactly, so that the app's first impression is visually consistent,
trustworthy, and on-brand.

## In Scope
1. Re-audit the current welcome screen (chromeless, no tab bar) against
   `cupid-app-design-system` for the enabled dark theme + `vi` locale
   configuration: hero/marketing content layout, nebula background,
   spacing, color/design-token usage, typography, and the sign-in vs.
   create-account CTA styling (Dream Gradient CTA per §2).
2. Correct every deviation found directly in the app code so the rendered
   screen matches the design source exactly — this is a fix, not an audit
   report.

## Out of Scope
- Whether welcome is the correct destination for a given session state, and
  where its CTAs navigate to — Scope A (STORY-001/STORY-002) owns entry-
  point and inter-screen navigation correctness; this story covers only the
  screen's own rendered content.
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Acceptance Criteria
1. Given the welcome screen rendered in the enabled dark theme + `vi`
   locale, when compared against `cupid-app-design-system`'s corresponding
   screen, then layout, spacing, color/token usage, and typography match
   exactly with no visible deviation.
2. Given any deviation was found during this story's audit, when the story
   is delivered, then the deviation is corrected in the rendered app (not
   merely documented) and re-verified against the design source.
3. Given the sign-in and create-account CTAs on this screen, when rendered,
   then their styling (Dream Gradient, pill radius, platform-adaptive
   button treatment per §3) matches the design source exactly.
4. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current welcome screen, already
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
- All acceptance criteria (1-4) are unblocked.
