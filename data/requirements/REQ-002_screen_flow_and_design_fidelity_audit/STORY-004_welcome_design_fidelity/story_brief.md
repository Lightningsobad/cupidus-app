# Story Brief: STORY-004 Design Fidelity — Welcome

- Actor: any user on the welcome screen (first-time or logged-out).
- Capability: the welcome screen matches the locked design source exactly,
  including its sign-in/create-account CTA styling.
- Business value: visual/brand consistency for the first-impression screen;
  user directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only. Where CTAs navigate to is Scope A's
  concern, not this story's.
- Key edge/failure case: CTA styling must match the platform-adaptive
  pattern (§3), not a single style forced on both platforms.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
