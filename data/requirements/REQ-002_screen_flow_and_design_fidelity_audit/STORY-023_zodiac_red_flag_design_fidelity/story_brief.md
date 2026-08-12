# Story Brief: STORY-023 Design Fidelity — Zodiac Red Flag

- Actor: any paired user viewing the zodiac compatibility read.
- Capability: the screen's custom 12-sign zodiac icon set matches the
  locked design source exactly, including element color-coding.
- Business value: visual/brand consistency for a distinctive custom-icon
  feature; user directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only. Icons must be the custom-drawn set, never
  Unicode glyph substitutes; element color-coding (Fire/Earth/Air/Water)
  must match exactly.
- Key edge/failure case: N/A beyond the icon/color-coding fidelity check.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
