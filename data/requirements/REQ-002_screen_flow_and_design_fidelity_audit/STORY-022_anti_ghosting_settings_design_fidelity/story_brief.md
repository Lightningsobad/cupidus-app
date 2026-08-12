# Story Brief: STORY-022 Design Fidelity — Anti-Ghosting Settings

- Actor: any paired user configuring anti-ghosting behavior.
- Capability: the settings screen (threshold picker, penalty-type selector)
  matches the locked design source exactly.
- Business value: visual/brand consistency for a configuration screen; user
  directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only. Does not cover where Emoji Storm renders
  in chat (STORY-018's scope).
- Key edge/failure case: N/A beyond per-option/state styling checks.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
