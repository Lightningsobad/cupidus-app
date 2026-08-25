# Story Master: STORY-002 Home Dashboard Quick Grid — Zodiac Red Flag Tile

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-011
Screen: Home dashboard — 2-column quick grid (currently renders only the
`Synced Alarm` tile; the design's Home node specifies a 2-column
`Synced Alarm` + `Zodiac Red Flag` layout)
Design reference: `cupid-app-design-system` (`Cupid Screens.dc.html` Home
node, 2-column quick-grid layout)

## Artifacts
- [x] Requirements (Product Owner) — this file
- [x] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- STORY-001 (Zodiac Red Flag screen). This tile's tap target navigates to
  STORY-001's screen and route; it cannot be implemented or verified before
  STORY-001's route exists.

## User Story
As a paired user viewing the Home dashboard, I want a `Zodiac Red Flag`
tile in the quick grid alongside `Synced Alarm`, so I can discover and
reach the Zodiac Red Flag feature the way the design intends and the Home
dashboard matches the design's 2-column layout.

## In Scope
1. Add the `Zodiac Red Flag` tile to the Home dashboard's quick grid,
   positioned and styled per the locked design source's 2-column layout,
   alongside the existing `Synced Alarm` tile.
2. Wire the tile's tap target to navigate to STORY-001's Zodiac Red Flag
   screen/route.

## Out of Scope
- The Zodiac Red Flag screen's own content, backend, or personalization
  logic — fully owned by STORY-001; this story only adds the entry point.
- Any change to the `Synced Alarm` tile's content, icon glyph, or
  navigation target — already shipped and design-matched. The tile's
  presentation container may be reshaped from a full-width row into a
  half-width grid tile (per AC1's 2-column layout requirement); that
  reshape is in scope and is not a change to the tile itself.
- Any other Home dashboard region (presence row, counter, hero caption,
  milestone pill, card rhythm, tab-bar styling, header actions, couple
  title, `--sky` backdrop) — already `DONE` under REQ-010, out of scope
  here.

## Acceptance Criteria
1. Given the Home dashboard rendered in the enabled dark theme + `vi`
   locale, when compared against `cupid-app-design-system`'s Home node,
   then the quick grid shows both `Synced Alarm` and `Zodiac Red Flag`
   tiles in the design's 2-column layout with no visible deviation.
2. Given a paired user taps the `Zodiac Red Flag` tile, when navigation
   completes, then the user lands on STORY-001's Zodiac Red Flag screen.
3. Given the Home dashboard is reached through its existing normal
   navigation path, when a user arrives, then no new top-level entry point
   is required — this story only adds a tile inside the already-reachable
   Home dashboard.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO — new tile on the existing,
  already-reachable Home dashboard quick grid.
- Direct URL only acceptable: N/A — the entry point is the Home quick grid
  itself, always visible to any user on Home.

## Dependencies
- Depends on: STORY-001 (Zodiac Red Flag screen/route must exist first).
- Must not require any future story: confirmed.

## Open Question Impact
NONE. OQ1/OQ2 are STORY-001-scoped content/data decisions; this story only
adds a navigation tile.
