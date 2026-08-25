# Story Master: STORY-007 `--sky` Global Screen Backdrop Rollout

Status: PENDING
Complexity: complex
Story-Class: standard
Implementation Lane: mobile
Requirement: REQ-010
Screen: every screen in the app (shared root screen frame / theme)
Design reference: `cupid-app-design-system` (`Cupid Screens.dc.html`
line 26 defines `--sky` as three stacked radials; line 44 applies it to
the root screen frame wrapping every screen)

## Artifacts
- [x] Requirements (Product Owner) — this file
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE.

## User Story
As any Cupid app user, I want every screen to show the app's signature
`--sky` backdrop wash, so the app's visual atmosphere is consistent and
on-brand everywhere, not just on the screens already fixed.

## In Scope
1. Implement the `--sky` backdrop (three-layer radial wash) as a shared
   theming primitive, replacing the current flat
   `scaffoldBackgroundColor: colorBackground` paint (`cupid_theme.dart`)
   applied to the root screen frame.
2. Apply the backdrop across every screen in the app (the design source
   applies it to the root frame wrapping all ~37 screens) for the enabled
   dark theme + `vi` locale configuration.
3. Verify no visual regression (contrast, readability, overlapping
   elements) is introduced on any screen by the new backdrop layer.

## Out of Scope
- Any change to per-screen foreground content, layout, or component-level
  design-fidelity findings owned by other stories or other requirements —
  this story only adds the shared backdrop layer.
- Light theme / `en` locale — still infra-only per prior `OQ5` disposition;
  the token should stay correct for all 4 combinations since tokens are
  shared, but no dedicated light/`en` visual QA pass is required.

## Acceptance Criteria
1. Given the `--sky` backdrop token defined in the locked design source
   (three stacked radials applied to the root screen frame), when
   implemented in the shared theme, then it is available as a reusable
   theming primitive rather than duplicated per screen.
2. Given any screen in the app, when rendered in the enabled dark theme +
   `vi` locale configuration, then it paints the `--sky` backdrop behind
   its content exactly as the design source specifies, replacing the
   current flat background paint.
3. Given the backdrop is applied globally, when any existing screen's own
   foreground content is rendered, then no visual regression (contrast,
   readability, overlapping elements) is introduced by the new backdrop
   layer.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: every existing, already-reachable screen
  in the app; this story changes their shared backdrop only, not their
  reachability.
- Direct URL only acceptable: N/A — applies to existing reachable screens,
  not new.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed.

## Open Question Impact
NONE.

## Rollout Note
This is a cross-cutting change with a wide blast radius (shared theme file
consumed by every screen). Complexity is classified `complex` on that
basis even though it is mechanically one shared-token change; Tech Lead
should scope verification breadth (representative screen sample vs. full
37-screen pass) in the coding plan.
