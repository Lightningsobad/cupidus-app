# Story Brief: STORY-004 Home Header — Share Days-Together Action

- Actor: paired user viewing the Home dashboard.
- Capability: a new header share icon opens the OS share sheet with the
  couple's days-together milestone.
- Business value: growth/social sharing of a relationship milestone;
  closes STORY-017 deferral F3 (header share action, target route
  previously absent).
- Key business rules: reuse the share-sheet integration pattern already
  present in `invite_screen.dart`; no backend change needed (day count is
  already client-side).
- Key edge/failure case: dismissing the share sheet without picking a
  target must not error or crash.
- Existing system entry/discoverability seed: new entry point (header
  icon) on the existing, always-reachable Home dashboard screen.
- Direct AC/OQ anchors: AC1-3 in `story_master.md`; no open questions.
- Complexity and why: standard — new UI element plus a real (if small)
  native-integration behavior, not a pure visual tweak. Lane: mobile.
- Dependencies: NONE.
