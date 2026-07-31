# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
If the phase names OQ constraints, read `../architecture/solution.md` §3
`Open Question Constraints` before coding and do not implement blocked scope.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not assigned to your lane.
6. Stop and escalate if the assigned work requires an unresolved OQ decision that the phase does not already resolve.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.

## 5. STORY-014 Hard Constraints

- Phases run strictly P1 → P2 → P3 → P4 → P5 → P6. Nothing here is parallel:
  every UI phase appends to the shared `app_en.arb` / `app_vi.arb`.
- A1 freeze: never modify `backend/**`, `mobile/openapi/**`, or
  `mobile/pubspec.yaml`. If a task seems to need one, stop and escalate to
  Scrum Master — it is a separate story.
- ADR-014a: no client-side encryption, no `libsodium`/FFI, no crypto
  dependency, and no "end-to-end encrypted" copy, lock, or shield affordance on
  any Dream Jar surface.
- ADR-014g: reach the API through `CupidApi.dio` inside
  `DreamJarRepository` only. Do not use the generated `Epic5DreamJarApi` (every
  method returns `Response<void>`), and never call `Dio` from a cubit or widget.
- ADR-014c: `targetAmount`, `currentAmount`, and `Contribution.amount` arrive as
  JSON **strings** from the backend `decimal` columns. Decode tolerantly.
- The story text calls Dream Jar a wish list; the real feature is a shared
  monetary savings jar. Build the savings jar and read `master-plan.md` §2 for
  the AC1-AC3 mapping.
- Deferred, do not implement: edit/archive/delete jar, the 4th custom-amount
  tile and the `note` input, a currency selector, a "show archived" toggle,
  realtime push freshness.
- All user-facing strings go through both ARB files with matching keys; all
  styling comes from `mobile/lib/design_system/**`.
