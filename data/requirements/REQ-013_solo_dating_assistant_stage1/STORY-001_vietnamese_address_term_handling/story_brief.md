# Story Brief: STORY-001 Vietnamese Pair-Specific Address-Term Handling

- Actor: any Stage-1 user (solo, unpaired).
- Capability: resolve and apply natural Vietnamese pair address terms
  (anh/em and similar) across all Stage-1 copy referencing the user or their
  partner.
- Business value: every later Stage-1 story's copy reads naturally instead
  of generically; must land before content-heavy stories to avoid rework.
- Key business rules: preference is editable/deletable at any time (XD4); a
  safe neutral default exists so nothing ever renders a placeholder token.
- Key edge/failure case: no preference declared yet — must default safely,
  not block or crash.
- Existing system entry/discoverability seed: one-time setup/onboarding
  prompt; new capability, no existing screen to extend.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; no story-level OQs.
- Complexity and why: standard — touches many screens' copy but is a single
  resolution capability, not new architecture. Lane: shared.
- Dependencies: NONE.
