# Story Master: STORY-003 Pet Preview Card Design Fidelity

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: mobile
Requirement: REQ-010
Screen: Home dashboard — pet preview card (`PetPreviewCard`, already
mounted in `home_screen.dart`)
Design reference: `cupid-app-design-system` (locked, confirmed by prior
`detect_design_source.py` runs under REQ-002)
Design-Screen: home

## Artifacts
- [x] Requirements (Product Owner) — this file
- [x] UX Design (UI/UX Designer)
- [x] Architecture (Tech Lead)
- [x] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE.

## User Story
As a paired user viewing the Home dashboard, I want the pet preview card to
match the locked design source exactly and to render its real state during
design-fidelity verification, so I can trust the dashboard reflects our
pet's actual status.

## In Scope
1. Re-audit the current pet preview card (`PetPreviewCard`, already mounted
   on Home) against `cupid-app-design-system` for the enabled dark theme +
   `vi` locale configuration: layout, spacing, color/design-token usage,
   and typography.
2. Correct every deviation found directly in the app code so the rendered
   card matches the design source exactly — this is a fix, not an audit
   report.
3. The card currently renders a load-failure state under the design-
   fidelity preview/capture harness because that harness has no
   authenticated backend session — a capture-state gap, not a rendering
   defect. Add a fixture-mode path for this card (mirroring the existing
   `PREVIEW_HOME_FIXTURE` pattern) so the card's real rendered state can be
   captured and verified against the design source.

## Out of Scope
- Any change to the pet feature's own gameplay, adoption, mood, or sprite
  logic (`pet/presentation/pet_screen.dart` and related) — already shipped.
- Any new tap target or navigation destination beyond what the locked
  design source already specifies for this card.

## Acceptance Criteria
1. Given the Home dashboard rendered in the enabled dark theme + `vi`
   locale with the fixture-mode path active, when the pet preview card is
   compared against `cupid-app-design-system`'s corresponding element,
   then layout, spacing, color/token usage, and typography match exactly
   with no visible deviation.
2. Given any deviation was found during this story's audit, when the story
   is delivered, then the deviation is corrected in the rendered app (not
   merely documented) and re-verified against the design source.
3. Given the design-fidelity preview/capture harness used to verify this
   story, when the Home screen is rendered for audit, then the pet card
   shows its real fixture-backed rendered state, not an authentication
   load-failure placeholder.
4. Given the card's existing tap behavior, when a user taps it, then it
   continues to reach the already-shipped pet feature — no new entry point
   is introduced by this story.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the pet preview card already mounted and
  reachable on the Home dashboard.
- Direct URL only acceptable: N/A — existing reachable surface, not new.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed.

## Open Question Impact
NONE.

## Story Runtime Startup Smoke
- Scope: `mobile-app` only (the sole runtime this story touches).
- Command: `flutter build apk --debug --flavor local -t lib/main_preview.dart
  --dart-define=PREVIEW=home --dart-define=PREVIEW_HOME_FIXTURE=true
  --dart-define=PREVIEW_PET_FIXTURE=true`, then installed and launched on
  `emulator-5554` via
  `am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`.
- Result: PASS — the app started and painted the Home dashboard with a
  populated `PetReady` pet card; no crash, no red error screen, no uncaught
  exception. Evidence:
  `visual-fidelity/implemented-home-android-emulator-5554.png` (405x900).
- Registry `buildCommand` (`flutter build apk --debug`) also ran clean:
  `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk`.

## Entry Point Reachability
- Surface: the pet preview card on the Home dashboard.
- Reachable: YES. The card stays mounted in the same Home card-column
  position (`home_screen.dart`), and tapping it still pushes the pet feature
  through `PetRoute.push` from every state.
- Evidence: visible in the runtime capture above, and asserted by
  `pet_preview_card_design_fidelity_test.dart` group
  "AC4 the tap contract survives the shell split" (ready card through the
  glow, locked card, and the shared `Semantics(button: true)` label), plus
  `home_screen_test.dart` group "STORY-003: the pet preview fixture seam".
- No new navigation entry point was added by this story.
