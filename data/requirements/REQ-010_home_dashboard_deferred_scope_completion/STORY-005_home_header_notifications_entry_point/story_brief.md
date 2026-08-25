# Story Brief: STORY-005 Home Header — Notifications Quick Access

- Actor: paired user viewing the Home dashboard.
- Capability: a new header notification icon (with unread-style indicator)
  navigates to the existing Notifications/preferences screen.
- Business value: faster discoverability of an already-shipped engagement
  feature; closes STORY-017 deferral F3 (header notification action,
  target route previously absent).
- Key business rules: destination is the existing `STORY-031` Notifications
  screen, not a new inbox/feed — no such feed exists in the shipped app or
  governing design.
- Key edge/failure case: indicator dot must default to hidden when no
  unread/unconfigured state exists.
- Existing system entry/discoverability seed: new entry point (header
  icon) on the existing, always-reachable Home dashboard screen, to an
  already-reachable destination screen.
- Direct AC/OQ anchors: AC1-3 in `story_master.md`; no open questions.
- Complexity and why: trivial — new icon plus navigation to an existing
  screen, no new feature logic. Lane: mobile.
- Dependencies: NONE.
