# Coding Agent Guide – STORY-004

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in your phase `Primary Inputs Summary`.
Do not load unrelated UX, architecture, or system-memory files. UX is WAIVED for
this story — there is no `../ux/` spec to read.
`../architecture/solution.md` §2 and ADR-012a-h are the contract source of truth;
read the exact ADR your phase names rather than the whole document.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane. P1 is DevOps; P0, P2, P3, P4, P5 are Mobile.
3. The mobile phases are a single sequential lane — all of them write inside
   `mobile/lib/core/realtime/`. Do not run two mobile phases concurrently.
   P1 (DevOps) may run concurrently with any mobile phase; its write scope is disjoint.
4. Update phase status immediately when it changes.
5. Stop when the next actionable phase belongs to another owner.
6. Do not expand scope into migration, rollout, or contract areas not assigned to your phase.

## 4. Binding Guardrails

From `../architecture/solution.md` §4 Mobile Lane Handoff — violating any of these
invalidates the spike:

- Zero backend change (A1). Do not edit `backend/`, the OpenAPI spec, or regenerate `mobile/openapi/cupid_api`.
- `socket_io_client` and `firebase_messaging` may be imported only under `mobile/lib/core/realtime/`.
- Never key Socket.IO rooms by the Firebase uid — always the backend `User.id`.
- Never force a socket reconnect on token rotation.
- Never emit or queue ephemeral (no-id) events while not foreground.
- Never rename a name from `../architecture/solution.md` §2; it is the frozen contract for STORY-007/008/009.
- Never log a token or a payload body.

## 5. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the plan during implementation.
- Escalate to Scrum Master if the plan is materially wrong, or if a phase appears
  to require a backend change — the answer is escalation, not a backend edit.
