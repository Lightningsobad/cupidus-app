# Story Brief: STORY-009 Design Fidelity — Permissions

- Actor: any user granting device permissions during onboarding.
- Capability: the permissions screen (cards, icons, all states) matches the
  locked design source exactly.
- Business value: visual/brand consistency and trust while requesting
  device permissions; user directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only. Icons must be Material Symbols Rounded,
  never emoji (§2 iconography rule).
- Key edge/failure case: granted vs. not-yet-decided card state styling
  must match the design source.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
