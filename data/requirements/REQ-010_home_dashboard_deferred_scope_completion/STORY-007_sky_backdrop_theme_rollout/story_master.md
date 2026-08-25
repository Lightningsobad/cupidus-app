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
- [x] UX Design (UI/UX Designer) — `ux/uiux-spec.md`
- [x] Architecture (Tech Lead) — `architecture/solution.md`,
  `coding-plan/master-plan.md`, `coding-plan/coding-agent-guide.md`,
  `coding-plan/phase-P1-backdrop-occlusion-guard-and-probes.md`
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
2. Given any screen in the app except the ratified backdrop-exception
   allowlist (`splash_screen.dart`, design-source-backed;
   `gallery_viewer_screen.dart`, product-judgment media-legibility
   exception; `welcome_screen.dart`, design-source-backed), when rendered
   in the enabled dark theme + `vi` locale configuration, then it paints
   the `--sky` backdrop behind its content exactly as the design source
   specifies, replacing the current flat background paint. Allowlisted
   screens retain their existing opaque root fill by design and must not
   be flagged as a regression.
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
- **OQ-1 (blocking) — RESOLVED: allowlist accepted, both exceptions
  ratified.** Tech Lead's whole-app occlusion audit found exactly two
  screens that paint an opaque root fill over the shared `--sky` backdrop:
  `splash_screen.dart` (design-source-backed —
  `Cupid Screens.dc.html:1418` gives splash its own full-bleed gradient;
  not a real debate) and `gallery_viewer_screen.dart` (product judgment —
  a media viewer where the purple/magenta wash behind letterboxed photos
  would degrade viewing and shift perceived photo color). Both exceptions
  are accepted. AC2 above is patched to read "every screen except the
  ratified allowlist." No production code change is required by this
  story unless a future decision reverses the gallery viewer exception —
  that reversal would be a design change, not a bug fix, and is out of
  scope here.
- **OQ-3 (blocking) — RESOLVED: third allowlist entry ratified.**
  Mobile-dev's Phase P1 Task 1 whole-app occlusion audit found a third
  screen painting an opaque root fill over the shared `--sky` backdrop:
  `welcome_screen.dart:147`
  (`mobile/lib/features/auth/presentation/screens/welcome_screen.dart`),
  which wraps its `Scaffold` body in a `DecoratedBox` using
  `colors.gradientBrandBackdrop` (`0xFF7B2FBE` / `0xFFFF4B8C` /
  `0xFFFF3366`, fully opaque). This is a value-for-value transcription of
  the design source's `isWelcome` block
  (`cupid-app-design-system/Cupid Screens.dc.html:69`,
  `linear-gradient(165deg,#7B2FBE 0%,#FF4B8C 58%,#FF3366 100%)`) — the
  same design-source-backed basis already accepted for `splash_screen.dart`
  under OQ-1, not an accidental deviation or a product-judgment call.
  Runtime-proven via a temporary, fully-reverted probe (negative control
  failed with `occluded.g = 0.19215686274509805`, i.e. `0x2F`, the green
  channel of `#7B2FBE`, confirming the welcome gradient paints over a
  forced sentinel color). Ratified as a third backdrop-exception allowlist
  entry, same basis as `splash_screen.dart`. AC2 above is patched to add
  `welcome_screen.dart` to the allowlist. No `mobile/lib` change is
  required by this disposition; if implementation later needs an explicit
  anti-regression guard update (per Tech Lead architecture AD-4) to
  recognize the new allowlist entry, that is Tech Lead/mobile-dev
  follow-up work, not a Product Owner scope change.
- **OQ-2 (non-blocking) — RESOLVED: framing correction, no AC change.**
  In Scope items 1-2 above describe building and applying a `--sky`
  theming primitive; the primitive already exists and is already mounted
  globally above the Navigator, so that work is already done by prior
  code, not new work in this story. The delivered work for this story is
  the whole-app occlusion audit, the two-screen exception allowlist above,
  and a durable anti-regression guard (per Tech Lead architecture AD-4)
  that prevents a screen from silently reintroducing an opaque root fill.
  The review gate should judge this story against that reality, not
  against a literal "build + roll out a new primitive" reading of In
  Scope items 1-2. AC1 and AC3 are unaffected.

## Rollout Note
This is a cross-cutting change with a wide blast radius (shared theme file
consumed by every screen). Complexity is classified `complex` on that
basis even though it is mechanically one shared-token change; Tech Lead
should scope verification breadth (representative screen sample vs. full
37-screen pass) in the coding plan.
