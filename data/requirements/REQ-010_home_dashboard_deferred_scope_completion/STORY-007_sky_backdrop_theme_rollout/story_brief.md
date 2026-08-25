# Story Brief: STORY-007 `--sky` Global Screen Backdrop Rollout

- Actor: any Cupid app user, on every screen.
- Capability: every screen paints the design's `--sky` three-layer radial
  backdrop wash instead of the current flat scaffold background.
- Business value: consistent, on-brand visual atmosphere app-wide; closes
  STORY-017 deferral F10, scoped as its own cross-cutting story per the
  requirement's explicit instruction not to bundle it into a Home-only
  story.
- Key business rules: shared theme change only — no per-screen foreground
  content changes; dark theme + `vi` locale is the required verification
  configuration, other combinations must stay token-correct but are not a
  dedicated QA pass.
- Key edge/failure case: must not regress contrast/readability on any
  existing screen.
- Existing system entry/discoverability seed: applies to all existing,
  already-reachable screens — no new entry point.
- Direct AC/OQ anchors: AC1-3 in `story_master.md`; no open questions.
- Complexity and why: complex — one shared-token change but with a
  ~37-screen blast radius requiring careful regression verification.
  Lane: mobile.
- Dependencies: NONE.
