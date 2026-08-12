# Story Brief: STORY-003 Design Fidelity — Splash

- Actor: any user opening the app (splash is the first screen shown).
- Capability: the splash screen's visual rendering (branding, nebula
  background, loading treatment) matches the locked design source exactly.
- Business value: visual/brand consistency from the first frame; user
  directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only. Routing/navigation logic is explicitly
  out of scope here (STORY-001 owns it) — this story is visual-only.
- Key edge/failure case: the loading/session-check hold state must use the
  design source's own treatment, not an ad hoc placeholder.
- Existing system entry/discoverability seed: existing first-launch screen,
  no new entry point.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; OQ5 does not block this
  story (see Open Question Impact).
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE. Coordinate scope boundary with STORY-001 (routing
  logic) but no delivery dependency.
