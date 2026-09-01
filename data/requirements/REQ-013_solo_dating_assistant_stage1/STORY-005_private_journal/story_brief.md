# Story Brief: STORY-005 Private Journal

- Actor: solo user writing personal entries.
- Capability: private-by-default, deletable journal (C6) built to already
  satisfy `REQ-014` G-2 (ii-b) symmetric-private-space treatment.
- Business value: foundational private space; also the write-target for
  STORY-009 (thinking-of-you gesture), STORY-020 (end-of-day ritual), and
  STORY-021 (post-date reflection).
- Key business rules: deletable (XD4); no export/share ever, in this
  requirement.
- Key edge/failure case: none new — plain CRUD with a privacy default.
- Existing system entry/discoverability seed: new screen; entry point set by
  UI/UX Designer.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; no story-level OQs.
- Complexity and why: standard — CRUD screen with a forward-compatibility
  constraint for `REQ-014`, no new architecture pattern. Lane: shared.
- Dependencies: NONE.
