# Story Master: STORY-001 Design System (platform x theme tokens + i18n ARB infra)

Status: DONE
Complexity: L
Epic: Foundation
Story-Class: shared-foundation
Requirement: REQ-001 (`data/requirements/REQ-001_cupid_flutter_mobile_app/req_master.md`)
Design reference: `cupid-mobile-design/` (read-only) — 2 platform variants
(iOS/Material) x 2 themes (dark/light), ~31 screens total.

## Depends On
- NONE (first story, must land before all other REQ-001 stories per req_master
  R7: doing this later forces rework across all 31 screens).

## User Story
As the Flutter codebase itself (technical foundation, no direct end-user
persona), it needs one shared design-token + localization layer so every
future screen renders correctly on both iOS and Material and in both
supported languages without per-screen forking.

## In Scope
- Design tokens for all 4 combinations: platform (iOS-style, Material-style)
  x theme (dark, light).
- `ThemeExtension`-based token architecture (per D3): 1 widget tree, no forked
  screens per platform/theme.
- i18n ARB infrastructure for `vi` (default) and `en`, wired to the intended
  Flutter localization pipeline.
- Enablement flags so only dark + `vi` are switched on for v1 launch, while
  light theme and `en` locale remain built and switchable later.

## Out of Scope
- Any actual screen implementation (epic stories build screens on top of this).
- Enabling light theme or `en` locale for end users at v1 (infra only — see
  OQ5 resolution below).

## Acceptance Criteria
1. Token set exists and is buildable for all 4 platform x theme combinations
   (iOS/dark, iOS/light, Material/dark, Material/light).
2. i18n ARB files exist for `vi` and `en`; app can resolve strings in either
   locale via the ARB pipeline.
3. At v1 launch, the app defaults to and only exposes dark theme + `vi`
   locale through user-facing settings; light theme and `en` remain present
   in code/config but not user-selectable, gated behind a flag Tech Lead
   defines in the ADR.
4. No screen-specific forking: a later screen story consumes tokens through
   `ThemeExtension` + the named adaptive widgets (D3), not platform-specific
   widget trees.

## Open Questions Resolved Here
- **OQ5** (light theme & EN in v1?): resolved — build all 4 combinations,
  enable only dark + `vi` at v1. See
  `data/requirements/REQ-001_cupid_flutter_mobile_app/requirements/requirements.md`
  for full triage.

## Open Items For Downstream Roles
- [DONE — UI/UX Designer] Token names/values confirmed against
  `cupid-mobile-design/`; UX spec for the 4-combination token set at
  `ux/uiux-spec.md`. One design-source gap flagged for Tech Lead/mobile-dev
  build-time confirmation: `colorAccentPurpleDark` has no light-theme
  override in source. One contrast rule flagged: light-theme
  `colorAccentPink`/`colorAccentPurple` fail AA for small text on
  surface/background — reserve for large text/icons only.
- [DONE — Tech Lead] Architecture (Tech Lead): enablement-flag mechanism
  defined as ADR-004a (build-time `const bool.fromEnvironment` flags gating
  exposure, not existence) in `architecture/solution.md`; this closes AC 3's
  dependency. Same solution also resolves the two UX-flagged items
  (ADR-004c `colorAccentPurpleDark` light carry-over, ADR-004d Material
  Symbols Rounded on both platforms) and encodes the ADR-004b light-accent
  contrast rule. Shared coding plan at `coding-plan/master-plan.md`
  (P0–P6, mobile-dev single lane).
- [DONE — Mobile Developer] Implementation (Development): all 7 coding-plan
  phases (P0-P6) complete, verified in `coding-plan/test-results.md` (full
  evidence, 6-row risk-surface gate summary all PASS, AC1-4 traceability).
  Full `flutter test` 42/42 passed, `flutter analyze` clean, registry
  `flutter build apk --debug` gate passed. Ready for the Reviewer gate.
- [DONE — Reviewer] Review (Reviewer): Tier 3 scoped-slice + fresh
  final-synthesis (`Iris-QC` x3 slices, `Iris-QC-2` final-synthesis). One
  blocking finding (ADR-004d single-icon-family violation, 4 call sites in
  `cupid_header.dart`/`cupid_add_action.dart`) routed back to Mobile
  Developer, fixed, and re-verified by `Iris-QC-2` directly against current
  file contents (independently re-extracted the bundled variable-font cmap).
  `review/review-report.md` — `Outcome: CLEAN`.
