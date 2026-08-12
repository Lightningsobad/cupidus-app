# Story Brief: STORY-017 Design Fidelity — Home Dashboard

- Actor: any paired user viewing the home dashboard.
- Capability: the home dashboard (days-counter, hero, tab bar) matches the
  locked design source exactly.
- Business value: visual/brand consistency for the app's main hub; user
  directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only. Days-counter uses Nunito 900 34pt Dream
  Gradient. Tab bar must follow the platform-adaptive pattern (§3), not one
  style on both platforms.
- Key edge/failure case: N/A beyond the platform-adaptive tab-bar check.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
