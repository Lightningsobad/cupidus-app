# Story Brief: STORY-001 App Launch / Session-Based Entry Routing Correction

- Actor: any user opening the Cupid app from a cold/terminated state.
- Capability: the app resolves the user's actual session state at launch and
  routes to the matching screen (home / login / welcome), instead of a fixed
  or incorrect default.
- Business value: users never land on a confusing or wrong screen when
  opening the app; directly fixes a user-confirmed defect.
- Key business rules: valid session → home; expired/invalid prior session →
  login; no session at all → welcome. Splash holds a minimum 2s dwell and
  only routes once session resolution completes. The routing decision runs
  once per cold launch, not on every foreground/background resume of an
  already-running session.
- Key edge/failure case: session check still in progress must not cause a
  premature/flickering redirect (AC4); resuming a still-valid running session
  must not re-trigger the full routing decision (AC5).
- Existing system entry/discoverability seed: this is the app's own launch
  sequence (splash) — no new entry point, only its routing outcome changes.
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; no OQ blocks this story.
- Complexity and why: standard — new architecture decision needed (session-
  resolution mechanism, cold-launch vs. resume detection), Lane: shared (UX +
  Tech Lead input required before implementation).
- Dependencies: NONE. Independent of STORY-002 and all Scope B stories.
