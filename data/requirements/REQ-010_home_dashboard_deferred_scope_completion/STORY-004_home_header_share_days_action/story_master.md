# Story Master: STORY-004 Home Header — Share Days-Together Action

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: mobile
Requirement: REQ-010
Screen: Home dashboard — header share action (`goShareDays`, currently
absent; `home_screen.dart` paints no header actions today)
Design reference: `cupid-app-design-system` (`Cupid Screens.dc.html`
lines 247-250)

## Artifacts
- [x] Requirements (Product Owner) — this file
- [x] UX Design (UI/UX Designer)
- [x] Architecture (Tech Lead)
- [x] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE.

## User Story
As a paired user viewing the Home dashboard, I want to share our
days-together milestone from the header, so I can celebrate it outside the
app.

## In Scope
1. Add a share icon in the Home dashboard header, positioned and styled per
   the locked design source.
2. Tapping the icon opens the OS native share sheet with shareable content
   reflecting the current days-together count already shown on Home
   (reusing the share-sheet integration pattern already used in
   `pairing/presentation/screens/invite_screen.dart`).

## Out of Scope
- Any custom-designed share image/card generation beyond what is directly
  derivable from data already rendered on Home (day count, milestone text).
- The pairing "Share invite" flow on `invite_screen.dart` — a different,
  already-shipped screen; this story only reuses its share-sheet
  integration pattern, not its scope.
- Any backend change — the days-together count is already available
  client-side on Home.

## Acceptance Criteria
1. Given the Home dashboard header, when rendered in the enabled dark
   theme + `vi` locale, then a share icon appears in the position and
   style defined by the locked design source.
2. Given the user taps the share icon, when the OS share sheet opens, then
   it contains shareable text reflecting the current days-together count
   already displayed on Home.
3. Given the share sheet is dismissed without selecting a target, when the
   user returns to the Home dashboard, then no error state or crash
   occurs.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO — this is a new header icon on the
  existing, already-reachable Home dashboard screen.
- Direct URL only acceptable: N/A — the entry point is the Home header
  itself, always visible to any user on Home.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed.

## Open Question Impact
NONE.

## Story Runtime Startup Smoke
- Scope: Flutter mobile app only (the impacted surface). No backend or web
  service was started.
- Command: `flutter build apk --debug -t lib/main_preview.dart
  --dart-define=PREVIEW=home --dart-define=PREVIEW_HOME_FIXTURE=true`, then
  `adb -s emulator-5554 install -r` + launch.
- Result: PASS — the app cold-starts on `emulator-5554` (sdk gphone64 arm64,
  Android 16 / API 36) and renders the Home dashboard with the new header
  share action visible. No plugin-registration failure and no crash, which is
  the load-bearing check because `share_plus` is the app's first native-share
  plugin.
- Evidence: `coding-plan/test-results.md` → `## Story Runtime Startup Smoke`.

## Entry Point Reachability
- Entry point: the share icon in the always-visible Home hero header. There is
  no separate route to reach.
- Reachable: YES — mounted on the Home dashboard as rendered, asserted by
  widget key `home_header_share_action` as a descendant of `home_couple_hero`,
  and photographed on device in
  `visual-fidelity/implemented-home-android.png`.
- Gating: renders only when a day count renders (`days != null`), per AC.
