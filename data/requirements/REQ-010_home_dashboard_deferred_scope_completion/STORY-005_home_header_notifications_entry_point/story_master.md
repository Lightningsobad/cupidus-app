# Story Master: STORY-005 Home Header — Notifications Quick Access

Status: PENDING
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-010
Screen: Home dashboard — header notification action (`goNotifs`, currently
absent), navigates to the existing Notifications screen
(`account/presentation/screens/notification_settings_screen.dart`,
shipped and design-matched by REQ-002 `STORY-031`, `Status: DONE`)
Design reference: `cupid-app-design-system` (`Cupid Screens.dc.html`
lines 247-250)
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
As a paired user viewing the Home dashboard, I want a direct notifications
entry point in the header, so I can reach my notification preferences
without navigating through the account tab.

## In Scope
1. Add a notifications icon in the Home dashboard header, positioned and
   styled per the locked design source, including the design's
   unread-style indicator dot.
2. Tapping the icon navigates to the already-shipped Notifications screen
   (`notification_settings_screen.dart`) — no new screen is built.
3. The indicator dot shows only when a relevant unread/unconfigured state
   exists for the signed-in user; the exact "unread" signal is a UI/UX and
   Tech Lead detail to define using data already available to the
   Notifications feature — this story does not invent a new backend
   notification-tracking system.

## Out of Scope
- Any new notifications inbox, feed, or list screen. The governing design's
  "notifs" screen is the preferences screen already shipped by `STORY-031`;
  this story only adds a Home entry point to it.
- Any change to the Notifications screen's own content, toggles, or copy —
  already shipped and design-matched.

## Acceptance Criteria
1. Given the Home dashboard header, when rendered in the enabled dark
   theme + `vi` locale, then a notifications icon appears in the position
   and style defined by the locked design source.
2. Given the user taps the notifications icon, when navigation occurs,
   then the user lands on the existing Notifications screen — no new
   screen is built by this story.
3. Given there is no relevant unread/unconfigured state for the signed-in
   user, when the Home dashboard renders, then the indicator dot does not
   show.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO for the header icon (new); YES for the
  destination screen (already shipped and reachable elsewhere in the app).
- Direct URL only acceptable: N/A — the entry point is the Home header
  itself, always visible to any user on Home.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed.

## Open Question Impact
NONE.
