# Phase P4 – Coordinator: Lifecycle Machine, Dedup, DI Wiring

## 1. Objective

Implement `RealtimeCoordinator`: one merged deduped stream, the never-two-live-sources lifecycle machine, `emit`/`resync`/`stop`, session teardown, and the DI registration that makes the module reachable.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-coordinator-lifecycle.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2, P3
- Parallelizable: NO (single mobile writer inside `core/realtime/`)
- Write Scope:
  - `mobile/lib/core/realtime/realtime_coordinator.dart`
  - `mobile/lib/core/realtime/cupid_realtime.dart`
  - `mobile/lib/core/di/service_locator.dart`
  - `mobile/test/core/realtime/realtime_coordinator_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - the concrete `RealtimeCoordinator` implementation behind the §2 interface
  - `get_it` lazy-singleton registration (ADR-011g pattern) plus `SessionScopedStore` enrollment
- Shared Interfaces Consumed:
  - P0 barrel and classifier
  - P2 socket transport and `backendUserId` resolver
  - P3 FCM transport and `PendingEventStore`
- Risk Surfaces:
  - Merged-stream dedup (AC1, AC2)
  - Foreground/background transition (AC2)
  - Session teardown
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` §2, ADR-012d, ADR-012g
  - consumer contract: features filter by `names` and switch on `name`; they never branch on `transport`
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC1, AC2
  - architecture: `../architecture/solution.md` §2, ADR-012d, ADR-012g
  - OQ constraints: ADR-007 — resync is a page-1 REST refetch reconciled by `id`; there is no cursor and no socket replay
  - upstream phase outputs: P2 and P3 transports and stores
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: N/A
- Phase Sizing:
  - Behavior Slice: merge + dedup + lifecycle + wiring
  - Source/Test File Count: 4
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` §2, ADR-012d, ADR-012g
- `master-plan.md` §3, §3A, §4, §6
- `phase-P2-socket-transport.md` §5, `phase-P3-fcm-transport-queue.md` §5

## 3. Tasks

- Implement the §2 interface exactly: `events({names})` as a broadcast stream, `status`, idempotent `start()`, `stop()`, `emit()` (socket-only, throws `RealtimeNotLiveFailure` when not `live`), `resync()`.
- Dedup durable events through a bounded LRU seen-id set of 512 entries (ADR-012d). Ephemeral events (no id) are not deduped and are dropped whenever the app is not foreground.
- Implement the ADR-012g lifecycle machine with an injectable lifecycle source (`AppLifecycleListener` in production, a fake in tests):
  - `resumed`: socket connected + joined; foreground FCM `onMessage` is **discarded** — this is what makes AC2's no-duplicate property structural rather than luck-dependent;
  - `inactive`/`paused`/`hidden`: hold the socket for a ~30s grace, then disconnect; background messages persist to the queue. The grace exists because iOS fires `inactive`/`paused` for the notification shade, app switcher, and incoming calls, and disconnecting on the first signal causes reconnect storms;
  - `detached`: background isolate persists only;
  - back to `resumed`: reconnect and re-`joinRoom`, drain the queue **through the same dedup gate**, then run a bounded REST resync.
- Never have two live sources at once. The socket is authoritative while foreground; FCM only matters while not foreground. The LRU covers only the grace-window overlap.
- Implement `resync()` as a bounded page-1 `GET /messages` refetch reconciled by `id` (ADR-007/ADR-012g.3). Do not invent a `since` cursor and do not request a backend change.
- Report `RealtimeStatus.degraded` when the socket is down but the FCM path is still viable; `offline`, `connecting`, `live` per §2.
- Implement `clearOnSignOut()`: disconnect, clear the seen-id LRU, the pending queue, and the cached room key.
- Register the coordinator as a `get_it` lazy singleton (ADR-011g pattern) and enroll it as a `SessionScopedStore` in `service_locator.dart`. This registration is the reachability wiring for this non-UI capability; without it the module is orphaned.
- Log connection-state transitions and dropped-duplicate counts only. Never log payload contents or tokens.

## 4. Acceptance Criteria

- The same durable `Message.id` injected through both fake transports yields exactly one event on `events()` (AC1, AC2).
- A foreground FCM message is discarded while `resumed`, and the socket event for it still arrives exactly once.
- Driving the fake lifecycle `resumed -> paused -> resumed` produces no duplicate and no dropped durable event, and preserves order.
- The socket is not disconnected before the grace window elapses.
- Ephemeral events are dropped while not foreground and are never queued.
- `emit()` throws `RealtimeNotLiveFailure` when status is not `live`.
- `start()` called twice opens only one connection.
- After `clearOnSignOut()` the LRU, queue, and room key are empty and the socket is disconnected.
- Features can consume the stream without importing any transport package.

## 5. Planned Outputs

- Code directories or files: `mobile/lib/core/realtime/realtime_coordinator.dart`, updated barrel, updated `mobile/lib/core/di/service_locator.dart`
- Contracts or schemas: the §2 surface, now backed by a concrete implementation
- Requirement configuration guide updates: none
- Notes or evidence: dropped-duplicate counter observable in logs

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `mobile/lib/core/realtime/` and `mobile/lib/core/di/`
- Required levels:
  - unit: dedup across both fake transports, foreground-FCM discard, lifecycle transition matrix, grace-window timing with a fake clock, LRU bound, `emit` failure path, `start()` idempotence, `clearOnSignOut`
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: DI registration resolves the coordinator through `get_it`; no transport package import outside `core/realtime/`; no payload or token in log output
- Mobile discoverability / navigation integration: NOT_APPLICABLE — no user-facing surface (UX WAIVED). The DI registration plus `SessionScopedStore` enrollment above is the required reachability wiring for this capability.
- Minimum gates by risk surface:
  - Merged-stream dedup: one event per durable id
  - Foreground/background transition: no duplicate, no drop, order preserved across the fake lifecycle
  - Session teardown: everything cleared
- Required regression or contract coverage: existing `service_locator.dart` registration tests still pass
- Verification strategy:
  - Targeted tests/regression/contract checks: `flutter test test/core/`
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: emitted event count per injected id, and status transition sequence

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
