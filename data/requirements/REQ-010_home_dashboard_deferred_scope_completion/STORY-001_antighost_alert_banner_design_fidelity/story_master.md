# Story Master: STORY-001 Anti-Ghost Alert Banner Design Fidelity

Status: PENDING
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-010
Screen: Home dashboard — anti-ghost alert banner (`AntiGhostEntryCard`,
already mounted in `home_screen.dart`)
Design reference: `cupid-app-design-system` (locked, confirmed by prior
`detect_design_source.py` runs under REQ-002)
Design-Screen: home

## Artifacts
- [x] Requirements (Product Owner) — this file
- [x] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [x] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE.

## User Story
As a paired user viewing the Home dashboard, I want the anti-ghost alert
banner to match the locked design source exactly, so the dashboard's visual
presentation is trustworthy and consistent with the rest of the app.

## In Scope
1. Re-audit the current anti-ghost alert banner (`AntiGhostEntryCard`,
   already mounted on Home) against `cupid-app-design-system` for the
   enabled dark theme + `vi` locale configuration: layout, spacing,
   color/design-token usage, typography, and copy ("Seen 5 phút rồi đấy" or
   equivalent).
2. Correct every deviation found directly in the app code so the rendered
   banner matches the design source exactly — this is a fix, not an audit
   report.

## Out of Scope
- Any change to the underlying anti-ghosting detection/business logic or
  the anti-ghosting screen/flow the banner leads to — both already shipped.
- Any new tap target or navigation destination beyond what the locked
  design source already specifies for this banner.

## Acceptance Criteria
1. Given the Home dashboard rendered in the enabled dark theme + `vi`
   locale, when the anti-ghost alert banner is compared against
   `cupid-app-design-system`'s corresponding element, then layout, spacing,
   color/token usage, typography, and copy match exactly with no visible
   deviation.
2. Given any deviation was found during this story's audit, when the story
   is delivered, then the deviation is corrected in the rendered app (not
   merely documented) and re-verified against the design source.
3. Given the banner's existing tap behavior, when a user taps it, then it
   continues to reach the already-shipped anti-ghosting screen/flow — no
   new entry point is introduced by this story.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the anti-ghost alert banner already
  mounted and reachable on the Home dashboard.
- Direct URL only acceptable: N/A — existing reachable surface, not new.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed.

## Open Question Impact
NONE.

## Story Runtime Startup Smoke
The app was launched on Android emulator `emulator-5554` via
`flutter run -t lib/main_preview.dart` (`--dart-define=PREVIEW=home
--dart-define=PREVIEW_HOME_FIXTURE=true`) and the Home dashboard reached its
loaded state, rendering the corrected `AntiGhostEntryCard` banner
(`MOBILE_CAPTURE: OK ... 405x900 171096`, confirmed a genuine populated Home
frame, not a splash frame).
Result: PASS

## Entry Point Reachability
`AntiGhostEntryCard` is already mounted on `HomeScreen` (existing shipped
surface, no new entry point added by this story) and is visible in the
accepted capture. The passing test `tapping the card from HomeScreen pushes
AntiGhostScreen` (`anti_ghost_entry_card_test.dart`) proves the tap reaches
`AntiGhostScreen`.
Reachable: YES
