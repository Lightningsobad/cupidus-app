# Story Master: STORY-032 Design System — App-Shell Background, Button & Header Follow-Up

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit) — Design System Follow-Up
Screen: N/A — cross-cutting shared design-system components
(`CupidPrimaryButton`, `CupidHeader`, app-shell/background layer), not a
single screen.
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [x] Implementation (Development) — all 3 phases landed;
  `coding-plan/test-results.md`, `visual-fidelity/visual-fidelity-report.md`
- [ ] Review (Reviewer)

### Implementation Phase Status
Phases are defined in `coding-plan/master-plan.md`.
- [x] Phase 1 — shared app-shell background layer (AC1):
  `mobile/lib/design_system/tokens/cupid_sky_palette.dart`,
  `mobile/lib/design_system/theme/cupid_app_background.dart`, barrel
  exports, transparent `scaffoldBackgroundColor` in `cupid_theme.dart`,
  `MaterialApp.builder` wiring in `mobile/lib/app/cupid_app.dart`, plus the
  two cross-phase `pumpAndSettle` test edits.
- [x] Phase 2 — removed the 21 per-screen `Scaffold` `backgroundColor`
  overrides plus 8 locals they left unused, and captured the AC4 re-render
  evidence in `visual-fidelity/` (AC1, AC4).
- [x] Phase 3 — `CupidPrimaryButton` gradient/glow/54pt restyle and
  `CupidHeader` transparent-over-backdrop-blur restyle, with 3 added
  assertions in `mobile/test/design_system/adaptive_widgets_test.dart` and one
  deliberate narrowing of the Anti-Ghosting gradient assertion (AC2, AC3,
  AC5).

## Depends On
- NONE. No other story must land before this one starts.
- Sequencing guidance (for Scrum Master scheduling, not a hard workflow
  block): this story is a shared-foundation-flavored follow-up for the rest
  of REQ-002 Scope B. It should land before further Scope B screen stories
  close wherever practical, so those stories are not deferred on this same
  gap a second time. If it lands after some Scope B screen stories already
  close, the shared-component treatment on those screens must be
  re-verified against this story's fix.

## User Story
As a user navigating any screen in the app, I want the shared background
wash/star particles, primary CTA styling, and header styling to match the
locked design system exactly everywhere, not just on individually audited
screens, so the app feels visually consistent and intentional throughout.

## In Scope
1. Implement `CupidColorTokens.skyGradient` as a real rendered Flutter
   background (typed gradient plus star-particle wash), applied through a
   shared design-system layer so it paints automatically behind every
   screen that should carry it, instead of requiring a per-screen
   implementation. No existing widget currently wraps every screen this
   way today — `mobile/lib/core/navigation/app_shell.dart` is only the
   post-pairing tab shell, while pre-pairing screens (login, register, OTP,
   forgot-password, etc.) each mount their own independent `Scaffold` — so
   this includes introducing whatever shared layer is needed for the
   background to reach both pre-pairing and post-pairing screens without a
   per-screen fork.
2. Restyle `CupidPrimaryButton` so its CTA treatment (gradient + glow pill)
   matches the locked design source app-wide, replacing the current
   flat-color treatment.
3. Restyle `CupidHeader` so its Material styling (transparent/blurred
   surface, correct back-glyph treatment) matches the locked design source
   app-wide, replacing the current opaque header band.
4. Re-render and spot-check at least the two screens that already flagged
   this exact gap in review — Forgot Password (STORY-008) and Waiting For
   Pairing (STORY-013) — after the fix lands, to confirm the shared
   paint/restyle actually reaches them rather than remaining an unconsumed
   abstraction.

## Out of Scope
- Any screen-local visual defect already owned by its own per-screen
  design-fidelity story (Scope B) — this story only fixes the three shared
  design-system deviations (CTA, header, background) identified during
  review of STORY-008 and STORY-013.
- Light theme / `en` locale (OQ5) — same in/out pattern as sibling Scope B
  stories; dark theme + `vi` only.
- New screens, new navigation, or new entry points.
- Re-verifying every already-DONE Scope B screen story (STORY-005,
  STORY-006, STORY-011, STORY-014, STORY-015, STORY-028, etc.) against this
  fix — this story's acceptance bar covers only the two screens that raised
  the finding (STORY-008, STORY-013). Whether the other already-closed
  screens also need re-verification against the same shared-component gap
  is a separate Scrum Master scheduling decision, not part of this story.

## Acceptance Criteria
1. Given the shared design-system layer after this story's fix, when any
   screen that should inherit the shared background is rendered in dark
   theme + `vi`, then it shows `CupidColorTokens.skyGradient`'s purple/
   magenta radial wash and star particles, not a flat `colorBackground`
   fill.
2. Given `CupidPrimaryButton` rendered anywhere in the app in dark theme +
   `vi`, when compared against the locked design source, then its CTA
   treatment (gradient + glow) matches exactly, with no visible flat-color
   deviation.
3. Given `CupidHeader` rendered anywhere in the app in dark theme + `vi`,
   when compared against the locked design source, then its Material
   treatment (transparent/blurred surface, glyph styling) matches exactly,
   with no visible opaque-band deviation.
4. Given the Forgot Password screen (STORY-008) and the Waiting For Pairing
   screen (STORY-013) specifically, when re-rendered after this story's fix
   lands, then both screens visibly show the shared background wash and
   restyled CTA/header, confirming the shared-layer fix reaches
   already-reviewed screens rather than remaining an unconsumed
   abstraction.
5. Given the existing design-system contract tests sibling stories rely on
   (for example the no-fork guard, adaptive-widget, and contrast tests),
   when this story's change lands, then all such existing tests continue to
   pass, and any test intentionally updated to reflect the new shared
   treatment is called out explicitly rather than silently changed.

## System Integration And Discoverability
- UI-facing story: YES — a cross-cutting shared visual layer, not a single
  new screen.
- Existing user-visible surface: every screen that currently renders
  `CupidPrimaryButton`, `CupidHeader`, or a screen background, all already
  reachable in the shipped app.
- Direct URL only acceptable: N/A — no new screen or route.

## Relationship To STORY-033 (App Shell Design System Deltas)
STORY-033 (`../STORY-033_app_shell_design_system_deltas/story_master.md`,
originated on STORY-010's branch as round-3 review finding F1's ratified
owner story) overlaps this story on two shared pieces: the `skyGradient`
ambient backdrop and `CupidHeader` styling (back-arrow ink specifically).
STORY-033 additionally owns two deltas this story does not cover — the
`caption` text-style sub-13px sizing/wrap regression and the shared CTA
gradient axis fix (120deg -> 95deg) — and does not cover this story's
`CupidPrimaryButton` restyle. Recommended sequencing (scrum-master,
2026-08-14): this story is further along (PO+UX complete, awaiting Tech
Lead) and should land first or be coordinated jointly with STORY-033's Tech
Lead pass, so both stories are not independently editing the same
`skyGradient`/`CupidHeader` shared-layer files.

## Dependencies
- Depends on: NONE.
- Source findings this story formalizes: STORY-008 review round 2
  (`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-008_forgot_password_design_fidelity/review/review-report.md`,
  `Outcome: DEFERRED_ONLY`, deviations D-1/D-2/D-3) and STORY-013 review
  round 2
  (`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-013_waiting_pairing_design_fidelity/review/review-report.md`,
  `Outcome: PATCH_REQUIRED`, Blocking Finding B4/R2) independently
  identified the same shared-component gap and both name it as blocking
  further per-screen closure without a requirement-level fix.
- Must not require any future story: confirmed — this story is
  self-contained once the shared design-system layer is implemented.

## Open Question Impact
OQ5 (light theme / `en` locale) only affects out-of-scope light/`en`
user-facing visual QA per this story's Out of Scope section; it does not
block any in-scope acceptance criterion.

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-5) are unblocked.
