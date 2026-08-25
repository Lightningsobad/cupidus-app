# Story Brief: STORY-001 Zodiac Red Flag Screen — Conflict Index And Daily Tip

- Actor: paired Cupid app user.
- Capability: a new Zodiac Red Flag screen showing a conflict-index reading
  and a daily tip personalized to the couple's real zodiac sign pair, with
  a backend content model/endpoint behind it.
- Business value: closes the last blocker on REQ-010's parked Home
  quick-grid item and ships a personalized daily-engagement feature the
  design source already specifies.
- Key business rules: content is a static curated table (78 unordered
  sign-pair conflict-index entries + a fixed daily-tip pool), selected
  deterministically per couple per day; never fabricate content for a
  couple whose zodiac signs aren't both known; zodiac icons must use the
  existing custom-drawn `Zodiac Icon` set, never Unicode glyphs.
- Key edge/failure case: a partner's `zodiacSign` is unset — must degrade
  to an honest incomplete-profile state, not fabricated pairing content.
- Existing system entry/discoverability seed: new screen; this story ships
  a direct in-app route (Direct URL only acceptable: YES); the Home
  quick-grid tile is a separate, dependent story (STORY-002).
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; OQ1/OQ2 resolved at
  requirement level, no story-level open questions remain.
- Complexity and why: complex — new backend data model + content seed +
  endpoint, new mobile screen, real personalization logic across 78
  sign-pair combinations, and an honest-degradation edge case. Lane:
  backend + mobile (phased inside this one story).
- Dependencies: NONE.
