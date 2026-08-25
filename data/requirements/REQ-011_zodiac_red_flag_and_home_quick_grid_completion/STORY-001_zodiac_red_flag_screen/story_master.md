# Story Master: STORY-001 Zodiac Red Flag Screen — Conflict Index And Daily Tip

Status: PENDING
Complexity: complex
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-011
Screen: Zodiac Red Flag (new screen; currently unimplemented — registered in
`mobile/lib/main_preview.dart`'s `_notImplementedCanvasIds`, no
`mobile/lib/features/zodiac/` directory exists)
Design reference: `cupid-app-design-system` (`Cupid Screens.dc.html` lines
601-635, `isZodiac` block: red-flag header card, conflict-index card with
gradient bar and both partners' zodiac icons, 3-row daily-tip list,
disclaimer footer)

## Artifacts
- [x] Requirements (Product Owner) — this file
- [x] UX Design (UI/UX Designer)
- [x] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE. Ordered phases (backend content model/endpoint, then mobile
  consumption) live inside this one story, not as separate stories.

## User Story
As a paired user, I want to view a Zodiac Red Flag screen showing a
conflict-index reading and a daily tip based on my and my partner's real
zodiac signs, so I get a fun, personalized daily read about our
relationship dynamic.

## In Scope
1. Backend: a data model and static curated seed content for zodiac-sign-
   pair conflict-index readings (one entry per unordered sign-pair — 12
   same-sign + 66 cross-sign = 78 combinations) and a fixed pool of daily-
   tip content (icon + title + description), per this requirement's OQ1
   resolution (`requirements/requirements.md` "Open Question Triage").
2. Backend: an authenticated endpoint returning the current paired couple's
   personalized Zodiac Red Flag content for the current day — the
   conflict-index score + blurb for their real sign pair (read from each
   partner's existing `zodiacSign` profile field), and a daily tip selected
   deterministically for that day. Degrades honestly (explicit
   incomplete-profile signal, no fabricated content) when either partner's
   `zodiacSign` is unset.
3. Mobile: the new Zodiac Red Flag screen matching the locked design
   source — red-flag header card (headline + short body text), conflict-
   index card (score `/10`, gradient bar, both partners' zodiac icons using
   the existing custom-drawn `Zodiac Icon` set
   (`mobile/lib/design_system/icons/cupid_zodiac_icon.dart`)), the 3-row
   daily-tip list, and the disclaimer footer text.
4. Mobile: an honest degraded/empty state when the endpoint reports a
   partner's `zodiacSign` is missing — no fabricated pairing content.
5. Mobile: a direct in-app route to the screen for reachability/
   verification in this story (the Home quick-grid entry point is added by
   STORY-002, not this story).

## Out of Scope
- New profile-input collection for zodiac sign — already collected via the
  existing `zodiacSign` profile field
  (`backend/src/modules/users/entities/user.entity.ts`,
  `update-profile.dto.ts`, `me-profile-response.dto.ts`; computed/collected
  client-side via `mobile/lib/features/account/domain/zodiac.dart` and
  onboarding profile setup) — see this requirement's OQ2 resolution.
- The Home dashboard quick-grid tile / entry point — STORY-002.
- Any admin-authored or CMS content-authoring pipeline for conflict-index
  or daily-tip content — out of MVP scope per this requirement's OQ1
  resolution.
- Editorial/localization quality iteration on the 78 conflict-index entries
  or the tip pool beyond what is needed to ship a coherent first version —
  a content-quality follow-up, not blocking.
- Light theme / `en` locale dedicated visual QA — dark theme + `vi` locale
  is the enabled configuration, matching every closed REQ-002
  design-fidelity story and STORY-023's own OQ5 carve-out.

## Acceptance Criteria
1. Given two paired users each with a `zodiacSign` set on their profile,
   when either opens the Zodiac Red Flag screen, then it renders a
   conflict-index score, both partners' custom zodiac icons, and a daily
   tip computed from their real sign pair — not fixture/placeholder values.
2. Given the same couple opens the screen again on the same calendar day,
   when the rendered content is compared, then the conflict-index reading
   and daily tip are the same (deterministic per day); given they open it
   on a different calendar day, then the daily tip may differ.
3. Given a user whose partner has not set a `zodiacSign`, when they open
   the Zodiac Red Flag screen, then the screen shows an honest
   incomplete-profile state instead of fabricated pairing content.
4. Given the Zodiac Red Flag screen rendered in the enabled dark theme +
   `vi` locale, when compared against `cupid-app-design-system`'s
   corresponding screen, then layout, spacing, color/token usage, and
   typography match, and every zodiac sign icon uses the existing
   custom-drawn `Zodiac Icon` set (never a Unicode glyph), color-coded by
   element (Fire = peach/orange, Earth = mint, Air = lilac, Water = pink).
5. Given this story does not add a Home quick-grid entry point, when
   Development completes this story, then the screen is reachable via a
   direct in-app route for verification purposes.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO — new screen, no shipped implementation
  exists today.
- Direct URL only acceptable: YES — this story ships the screen itself;
  the Home quick-grid discoverability entry point is added by the
  dependent STORY-002, matching the precedent set by
  `REQ-006/STORY-001` (Home page shipped with direct-URL-acceptable
  reachability before later nav wiring).

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed — this story is fully
  functional and independently verifiable via its direct route; STORY-002
  only adds a second, additional entry point.

## Open Question Impact
NONE remaining. OQ1 (content source) and OQ2 (profile input) are resolved
in `requirements/requirements.md` "Open Question Triage" and carried into
this story's In Scope / Out of Scope above.
