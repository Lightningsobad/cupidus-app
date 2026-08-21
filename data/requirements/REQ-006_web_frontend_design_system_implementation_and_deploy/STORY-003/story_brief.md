# Story Brief: STORY-003 Zodiac Compatibility Preview Page

## Identity

- Parent requirement: REQ-006 Web frontend implementation from design system & production deploy
- Story master: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-003/story_master.md`
- Final story requirements artifact: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-003/requirements/requirements.md`

## Brief

- Actor: visitor curious about the app's astrology/compatibility feature.
- Capability: a "Zodiac" page reachable from the shared nav, showing a
  sample daily compatibility read (two signs, 3 metric bars, a text nudge),
  all 12 zodiac signs with dates, the 4 elements grouping, and a weekly
  "most in-sync pairs" leaderboard.
- Business value: previews a differentiated in-app feature to build interest
  and trust before download.
- Key business rules or guardrails: content is presentational/sample data
  only (no backend); all figures/labels are static design-source content
  reproduced verbatim in both VI and EN, not live computed data.
- Key edge or failure case: none — content is static and always fully
  populated.
- Existing system entry / discoverability seed: reachable via the "Zodiac"
  item in the shared header nav established in STORY-001; direct URL also
  acceptable.
- Complexity: standard — new screen.
- Why this complexity: introduces a new screen with several distinct
  visual sub-components (compatibility ring, progress bars, grids); no new
  architecture beyond STORY-001.
- Implementation lane seed: frontend.
- Depends on: STORY-001 (shared chrome, nav route, framework).

## Direct Anchors

- Requirement AC / BR anchors: `requirements/requirements.md` Coverage Map
  row "Zodiac compatibility preview page"; design source section `isZodiac`
  in `cupid-app-design-system/Cupid Web.dc.html`.
- Open Question anchors: None directly (inherits OQ-REQ006-2 resolution:
  no backend dependency — figures are static sample content, not live-
  computed).
- Related story dependencies: STORY-001.

## Scope Seed

### In Scope

- Sample daily compatibility card (2 signs, ring %, 3 metric bars, nudge
  text).
- All 12 zodiac signs grid with dates.
- 4 elements grouping (fire/earth/air/water).
- Weekly top-6-pairs leaderboard section.

### Out of Scope

- Any live/computed compatibility calculation or user-input zodiac
  selection (not in the design source; this is a static preview page only).
- Backend/API integration.
