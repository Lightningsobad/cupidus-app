# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md` — especially `## 2A. Scope Reality` and
  `## 2B. Hard Constraints`. This story is not what its title says it is.
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.

For this story both open questions are **RESOLVED** in `../story_master.md`
`## Open Question Impact` — read that section before coding, and do not reopen
either one:

- OQ-1: the two-screen backdrop-exception allowlist (`splash_screen.dart`,
  `gallery_viewer_screen.dart`) is **ratified**. Both screens keep their opaque
  root fill. AC2 reads "every screen except the ratified allowlist."
- OQ-2: the story's In Scope items 1-2 ("build and roll out the primitive") are
  stale. The primitive already exists and is already mounted globally. The real
  deliverable is audit + allowlist + anti-regression guard.

Dark theme + `vi` locale is the only configuration to verify.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope. In this story specifically:
   - `mobile/lib/**` is **read-only**. The expected production change surface is
     zero files. Do not "fix" either allowlisted screen.
   - Never apply `CupidAppBackground` or a `--sky` gradient per screen. The wash
     is mounted once at `mobile/lib/app/cupid_app.dart:59`; a second application
     double-paints it and reintroduces `BUG-20260815-002`.
   - `mobile/pubspec.yaml` is out of scope — hand-roll the guard's scanner, do
     not add `analyzer` or any other dependency.
   - `backend/`, `mobile/openapi/`, and `mobile/lib/l10n/` are out of scope.
   - Do not weaken `_expectSharedBackdropShowsThrough`'s
     `everyElement(isNull)` assertion or lower a probe threshold to make a probe
     pass. A failing probe means you found a real occluder.
   - Do not add a fifth runtime probe beyond the four named in P1 Task 3.
6. Stop and escalate rather than editing `mobile/lib/` or growing the allowlist.
   P1 Task 1 is an ordered prerequisite: if the re-verified occluder set is not
   exactly the two ratified files, that is an escalation, not a code change.
   Adding an allowlist entry is a reviewable design decision.
7. Stop and escalate if a probe's negative control stops showing the green
   sentinel — the probe pixel is then no longer meaningful and the test proves
   nothing.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.
