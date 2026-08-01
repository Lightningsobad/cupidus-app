# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
`../architecture/solution.md` §2 is the contract summary — read it instead of
the whole solution unless your phase cites a specific ADR.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane. This story is single-lane (Mobile), sequential P0 -> P5.
3. Update phase status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand phase scope into migration, rollout, or contract areas not assigned to your phase.
6. Stop and escalate if the work requires an unresolved OQ decision the phase does not already resolve.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the plan during implementation.
- Escalate if the plan is materially wrong.

## 5. STORY-007 Standing Guardrails

These are decided. Do not reopen them inside a phase; escalate to Scrum Master
if you believe one is wrong.

- **No offline write queue, anywhere** (OQ4 / ADR-007). No pending, queued,
  outbox, retry, or sendState column, field, or code path. A failed send throws,
  keeps the draft in the composer, and stops.
- **Sends go over the socket only.** Never `POST /messages` to send — it fans
  out nothing, so the partner would receive nothing (ADR-012h).
- **The sender never receives its own `newMessage`.** The gateway targets
  `receiverId` only. Your own bubble comes from the awaited `emit()` ack.
- **Attachments are OUT** (ADR-013a). Remove the composer image icon; do not
  ship it disabled.
- **Never emit `markDelivered`** (ADR-013d). The backend's `WHERE status='sent'`
  filter would then permanently block `markAsSeen` from persisting, regressing
  the read tick on history reload.
- **No partner presence** (ADR-013c). No green dot, no status line. Never derive
  partner presence from your own `RealtimeStatus`.
- **Ghost content is memory-only.** Never write it to Drift, never to
  `shared_preferences`, never to a log.
- **Realtime only through the barrel** `package:cupid_mobile/core/realtime/cupid_realtime.dart`.
  Filter by `names`, switch on `name`, never branch on `transport`.
- **Do not read or import STORY-005 pairing source files.** They may not be
  merged. The AC5 gate is `GET /users/me`.`partnerId`.
- **Do not touch `core/realtime/pending_event_store.dart`.** Migrating it to
  Drift is STORY-004's deferred item, not this story's scope.
- `core/` never imports `features/`. Drift tables live in `core/database/`.
