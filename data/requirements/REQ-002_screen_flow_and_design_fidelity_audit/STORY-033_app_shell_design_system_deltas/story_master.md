# Story Master: STORY-033 App Shell Design System Deltas

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit) — shared design-system layer,
cross-screen
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE for this story's own execution — it is a standalone shared
  design-system fix scoped directly against the design source's
  tokens/canvases. Scrum Master should schedule it so that other
  in-flight Scope B design-fidelity stories consuming the same shared
  pieces (skyGradient backdrop, `CupidHeader`, `caption` text style, CTA
  gradient token) benefit before REQ-002's requirement integration review.

## Origin
Created as the ratified owner story for round-3 review finding F1 against
STORY-010
(`../STORY-010_onboarding_profile_design_fidelity/review/review-report.md`,
Action Items #1 and #5). STORY-010's `story_master.md` carries the full
"Product Owner Ruling — 2026-08-14" ratification record that scoped these
four deltas out of STORY-010's AC1/AC2 and into this story; that ruling is
reproduced in summary below so this story is self-contained.

**Ratifies round-3 review finding F1**: STORY-010's `VISUAL_FIDELITY: FAIL`
verdict against AC1/AC2 was unratified because four residual visual deltas
are real but all live in the shared `mobile/lib/design_system/` layer (and
the shared `CupidHeader` widget), strictly outside mobile-dev's declared
write scope for that story. These are design-system/shared-component
defects, not onboarding-screen defects — fixing them inside STORY-010 would
require expanding write scope into shared design-system files that every
other screen in this parallel wave also consumes, which is why the review
required a dedicated owner story rather than a per-screen patch. The review
also records (R-1) that this story is the load-bearing counterparty of
STORY-010's PASS and must not be deferred out of REQ-002 without an
accountable owner for these four deltas.

## Relationship To STORY-032 (Design System — App-Shell Background, Button &
Header Follow-Up)
STORY-032 is a separate, further-along story (PO+UX already complete,
awaiting Tech Lead) that overlaps this story on two of the same shared
pieces: the `skyGradient` ambient backdrop and `CupidHeader` styling.
STORY-032 additionally restyles `CupidPrimaryButton` (its overall gradient +
glow CTA treatment) and re-verifies STORY-008/STORY-013 against those fixes;
this story additionally owns the `caption` text-style size regression and
the shared CTA gradient axis fix (120deg -> 95deg), neither of which
STORY-032 covers. Recommended sequencing: land STORY-032 first (or
coordinate jointly) since it is further along, so this story's Tech Lead
pass can build on whatever shared-layer state STORY-032 leaves behind for
`skyGradient` and `CupidHeader` rather than both stories independently
editing the same files. This story is not a duplicate of STORY-032 — see
"Out of Scope" below for the explicit boundary.

## User Story
As a user moving through any screen in the app that uses the shared aurora
backdrop, the shared `CupidHeader`, the `caption` text style, or the shared
CTA gradient token, I want those shared design-system pieces to match the
locked design source exactly, so every screen that consumes them is
visually correct without each screen's own story having to re-implement
the same fix.

## In Scope
1. Add an ambient `skyGradient` backdrop widget in
   `mobile/lib/design_system/` that consumes the already-existing
   `skyGradient` CSS-string token in `cupid_color_tokens.dart` (currently
   defined but unconsumed by any widget) and renders the aurora wash +
   sparkle dots depicted in the design source's dark-theme canvases behind
   screen content, matching the design source's placement/opacity.
   Coordinate with STORY-032, which also touches this shared backdrop —
   see "Relationship To STORY-032" above.
2. Fix `CupidHeader`'s back-arrow ink color: currently renders in primary
   text ink; correct it to the pink ink specified by the design source for
   the header back-arrow, across every canvas that shows this header.
   Coordinate with STORY-032, which also touches `CupidHeader`.
3. Fix the `caption` text style's declared size: currently 13px, which
   causes elements authored at smaller sizes (11/11.5/12.5px, per canvas
   `profile`) to render oversized and, in at least one observed case (the
   onboarding profile-setup screen's zodiac helper text), wrap to two
   lines instead of the design source's one line. Correct the `caption`
   text style token's declared size to match the design source, and
   re-verify that layouts which depended on the old (incorrect) size no
   longer wrap unexpectedly.
4. Fix the shared CTA gradient axis token: currently 120deg; correct to
   the design canvas's 95deg. This is the gradient angle token only, not
   `CupidPrimaryButton`'s overall restyle (owned by STORY-032).

## Out of Scope
- Any design-system token or widget not named in the four items above.
- `CupidPrimaryButton`'s overall gradient/glow CTA restyle and the
  STORY-008/STORY-013 re-verification against it — owned by STORY-032.
  This story only touches the shared CTA gradient axis token (item 4
  above), not the button's broader visual treatment.
- Any screen-specific content, copy, or interaction logic — this story
  touches only the shared `mobile/lib/design_system/` layer (and
  `CupidHeader`, the directly corresponding shared widget) that the four
  named deltas live in.
- Re-running or re-authoring other stories' visual-fidelity reports. Once
  this story lands, screens whose remaining open deltas were exactly these
  four items may re-verify and update their own reports/status, but that
  re-verification belongs to each of those stories, not to this one.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Cross-Screen Impact (expected and intended)
This story fixes shared components consumed by every screen in the current
design-fidelity audit wave. Landing these fixes is expected to also
correct the same visual deltas on other screens (including, but not
limited to, STORY-010's onboarding profile-setup screen) that consume
`mobile/lib/design_system/`'s `skyGradient` token, `CupidHeader`, the
`caption` text style, or the shared CTA gradient token. This is intended:
each fix here should move every screen in the live parallel wave that uses
the affected shared piece, rather than each screen re-implementing the
same correction independently.

## Acceptance Criteria
1. Given any screen in the app that renders behind the ambient
   `skyGradient` backdrop per the design source's dark-theme canvases,
   when compared against the design source, then the aurora wash and
   sparkle dots are present and match the design source's
   placement/opacity — not flat background color.
2. Given `CupidHeader`'s back-arrow on any screen that shows it, when
   compared against the design source, then the arrow renders in the
   design source's pink ink, not primary text ink.
3. Given any text rendered in the `caption` text style, when compared
   against the design source, then the rendered size matches the design
   source's declared size for that style, and any layout that previously
   wrapped only because of the oversized `caption` style (including the
   onboarding profile-setup screen's zodiac helper text) now renders on
   the design source's intended number of lines.
4. Given the shared CTA gradient, when rendered on any screen that uses
   it, then its axis matches the design canvas's 95deg, not 120deg.
5. Given the existing design-system contract tests sibling stories rely on
   (for example STORY-032's no-fork guard, adaptive-widget, and contrast
   tests), when this story's change lands, then all such existing tests
   continue to pass, and any test intentionally updated to reflect the new
   shared treatment is called out explicitly rather than silently changed.

## System Integration And Discoverability
- UI-facing story: YES — indirectly, through every screen that consumes
  the four fixed shared pieces.
- Existing user-visible surface: the shared `mobile/lib/design_system/`
  layer and `CupidHeader`, both already live and consumed across the
  shipped app.
- Direct URL only acceptable: N/A — shared component/token layer, not a
  standalone screen.

## Dependencies
- Depends on: NONE for this story's own execution.
- Downstream: STORY-010's AC1/AC2 (per its "Product Owner Ruling" section)
  and any other Scope B design-fidelity story sharing the same four
  deltas treat this story as their owner for those specific deltas; those
  stories do not block on this story completing to reach their own DONE,
  since the deltas are explicitly excluded from their acceptance criteria.

## Open Question Impact
OQ5 (light theme / `en` locale) only affects out-of-scope light/`en`
user-facing visual QA per this story's Out of Scope section; it does not
block any in-scope acceptance criterion.

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-5) are unblocked.
