# Story Brief: STORY-005 Design Fidelity — Login

- Actor: any user authenticating on the login screen.
- Capability: the login screen (form fields, CTA, all field states) matches
  the locked design source exactly.
- Business value: visual/brand consistency and trust during authentication;
  user directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only. Platform-adaptive CTA pattern (§3) must
  be preserved (pill on iOS, filled button on Android), not collapsed to one
  style.
- Key edge/failure case: form-field error/validation state styling must
  match the design source, not an ad hoc error treatment.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
