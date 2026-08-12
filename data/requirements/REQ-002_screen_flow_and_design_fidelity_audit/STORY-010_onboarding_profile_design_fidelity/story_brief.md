# Story Brief: STORY-010 Design Fidelity — Onboarding Profile Setup

- Actor: any user setting up their profile during onboarding.
- Capability: the onboarding profile-setup screen (avatar upload, form)
  matches the locked design source exactly.
- Business value: visual/brand consistency and trust during identity setup;
  user directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only. Distinct from the Epic 6 "Me / Profile"
  screen (STORY-029) — do not merge scope.
- Key edge/failure case: avatar upload slot's empty vs. populated state
  styling must match the design source.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
