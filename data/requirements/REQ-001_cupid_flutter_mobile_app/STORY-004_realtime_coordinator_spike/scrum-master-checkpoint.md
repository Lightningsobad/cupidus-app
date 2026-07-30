# Scrum Master Checkpoint — REQ-001 / STORY-004

Scope: STORY-004 Spike — RealtimeCoordinator (Socket.IO + FCM)
Story-Class: standard
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-001_cupid_flutter_mobile_app-STORY-004`
Branch: `codex/REQ-001_cupid_flutter_mobile_app-STORY-004`
BaseHead: `df8d5097f89ab6c556a7e5b7269f45929b42f6a5`

## Completed Steps

| Step | Role | Mode | Outcome | Artifact |
|---|---|---|---|---|
| Product Owner breakdown | product-owner | requirement-breakdown | DONE | `story_master.md`, `story_brief.md` |
| UX spec | ui-ux-designer | — | SKIPPED (waived) | no operator-facing UI; technical spike only |
| Architecture | tech-lead | architecture-solution | DONE 2026-07-30 | `architecture/solution.md` |
| Coding plan | tech-lead | coding-plan | DONE 2026-07-30 | `coding-plan/master-plan.md`, `coding-plan/phase-P0..P5`, `coding-plan/coding-agent-guide.md` |

## Architecture Outcome

- ADR-012a-h created; refines system ADR-008 (`data/architecture/system/system_architecture_memory.md` §7).
- All four ACs have a named contract and a verification gate (see solution §4 Risk Surfaces).
- Frozen API surface for STORY-007/008/009 is solution §2 (`RealtimeCoordinator`, `RealtimeEvent`, `RealtimeStatus`).
- System memory updated: ADR-008 refinement, R9 + chat-write-fanout rows in §8, §11 history row.

## Coding Plan Outcome (2026-07-30)

- `coding-plan/master-plan.md` created with the required Phase Overview schema;
  6 phases, each mapped to exactly one canonical phase file.
- P0 contract (Mobile) -> P2 socket transport + room key (Mobile) -> P3 FCM
  transport + pending queue (Mobile) -> P4 coordinator lifecycle/dedup/DI
  (Mobile) -> P5 verification + spike findings (Mobile). P1 FCM/APNs config
  (DevOps) depends on P0 and is the only phase parallelizable with mobile work.
- Implementation Lane: shared (mobile-dev + devops). The mobile phases are a
  single sequential writer lane inside `mobile/lib/core/realtime/`; no parallel
  multi-writer mobile work is planned, matching architecture §8.
- Runtime registry id `mobile-app`. Story-level runtime startup smoke NOT
  required. Configuration guide FCM/APNs section owned by P1.
- No entry-point/navigation phase: no UI surface (UX WAIVED). Reachability
  wiring for this non-UI capability is the `get_it` + `SessionScopedStore`
  registration in P4.

## Next Valid Step

Mobile Developer for STORY-004 phase **P0** (`coding-plan/phase-P0-realtime-contract.md`).

- P0 is contract-first and blocks every other phase.
- After P0 lands, P1 (DevOps) may run concurrently with P2 -> P3 -> P4.
- P5 is the verification phase and requires P0-P4 plus P1.

## Open Escalations For Scrum Master

Neither blocks this spike; both block later epics.

1. **R9 (new)** — backend has no server-side FCM dispatch and no device-token
   storage. Every push is a `console.log` stub; `firebase-admin` is used for
   `verifyIdToken` only. The spike is validatable by injecting FCM messages via
   the FCM HTTP v1 API (zero backend change, A1-safe), but background reminders
   (D1, epic-3) cannot ship until the backend adds token registration, storage,
   and `admin.messaging()` dispatch at the three stub sites.
2. **R8 workaround is closed off** — `POST /messages` is authenticated but emits
   nothing to the socket, so writes cannot be moved to REST to dodge the socket
   auth gap (ADR-012h). R8 still blocks epic-2 production readiness.
3. **Contract confirmation — RESOLVED during coding-plan (2026-07-30)**.
   `POST /auth/login` does return the backend user entity
   (`backend/src/modules/auth/auth.controller.ts:15-21`), so the `User.id` needed
   for `joinRoom` is available at runtime. Residual caveat, handled in plan phase
   P2: the OpenAPI spec declares no response schema, so the generated client
   types it `Response<void>`
   (`mobile/openapi/cupid_api/lib/src/api/epic1_auth_api.dart:32`) and the id is
   not reachable through the typed call. P2 reads it from the shared `Dio`
   instance instead. No backend change, no client regeneration. Optional
   follow-up for a later backend story: add the login response schema so the
   typed client exposes the id.

## Guards / Do Not Re-read

- `architecture/solution.md` §2 is the authoritative downstream contract. Do not
  re-derive the auth-token exposure design — STORY-003 §2 and ADR-011a own it.
- Do not request or design any backend change under this story.
