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

## Architecture Outcome

- ADR-012a-h created; refines system ADR-008 (`data/architecture/system/system_architecture_memory.md` §7).
- All four ACs have a named contract and a verification gate (see solution §4 Risk Surfaces).
- Frozen API surface for STORY-007/008/009 is solution §2 (`RealtimeCoordinator`, `RealtimeEvent`, `RealtimeStatus`).
- System memory updated: ADR-008 refinement, R9 + chat-write-fanout rows in §8, §11 history row.

## Next Valid Step

Tech Lead `Mode: coding-plan` for STORY-004.

- A shared coding plan IS required (Story-Class `standard`).
- But it is **effectively single-lane**: one mobile lane (~8-10 files in
  `mobile/lib/core/realtime/`, so split into sequential mobile phases per the
  6-file phase-sizing rule) plus one small DevOps configuration phase.
- Backend is frozen and untouched; there is no UI surface, so no
  frontend/entry-point phase applies.
- Configuration guide: REQUIRED (FCM/APNs section).

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
3. **Contract confirmation needed** — Socket.IO rooms are keyed by the backend
   `User.id`, not the Firebase uid. Confirm `POST /auth/login` returns that id;
   otherwise epic-2's socket joins a room nobody emits to and fails silently.

## Guards / Do Not Re-read

- `architecture/solution.md` §2 is the authoritative downstream contract. Do not
  re-derive the auth-token exposure design — STORY-003 §2 and ADR-011a own it.
- Do not request or design any backend change under this story.
