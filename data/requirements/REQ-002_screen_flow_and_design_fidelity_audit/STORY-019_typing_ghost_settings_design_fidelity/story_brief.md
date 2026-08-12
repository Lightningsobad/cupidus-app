# Story Brief: STORY-019 Design Fidelity — Typing Ghost Consent/Settings

- Actor: any paired user deciding whether to enable Typing Ghost.
- Capability: the consent/settings screen (mutual-consent toggle states,
  lock affordance) matches the locked design source exactly.
- Business value: visual/brand consistency and clarity for a consent
  decision; user directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only. Level-1 lock affordance must always be
  visible (§5/§8).
- Key edge/failure case: pending-partner-acceptance toggle state styling
  must match the design source.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
