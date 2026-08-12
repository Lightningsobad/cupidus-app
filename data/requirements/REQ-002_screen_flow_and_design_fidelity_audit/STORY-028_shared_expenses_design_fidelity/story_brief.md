# Story Brief: STORY-028 Design Fidelity — Shared Expenses

- Actor: any paired user logging a shared expense.
- Capability: the Shared Expenses screen matches the locked design source
  exactly, including its intentional platform-adaptive add-expense action.
- Business value: visual/brand consistency plus preserving a deliberate
  native-feel platform-adaptation precedent; user directive is 100% match,
  not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only. Platform-adaptive FAB-vs-full-width-CTA
  for the same action (§3) must be preserved exactly, not unified.
- Key edge/failure case: must not accidentally "fix" the intentional
  per-platform difference into a single treatment.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
