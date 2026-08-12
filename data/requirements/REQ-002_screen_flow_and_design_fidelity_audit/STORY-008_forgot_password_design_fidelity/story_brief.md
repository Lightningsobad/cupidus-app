# Story Brief: STORY-008 Design Fidelity — Forgot Password

- Actor: any user requesting a password reset.
- Capability: the forgot-password screen (form, all response states)
  matches the locked design source exactly.
- Business value: visual/brand consistency and trust during account
  recovery; user directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only.
- Key edge/failure case: error/invalid-email and submitted-confirmation
  state styling must match the design source.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
