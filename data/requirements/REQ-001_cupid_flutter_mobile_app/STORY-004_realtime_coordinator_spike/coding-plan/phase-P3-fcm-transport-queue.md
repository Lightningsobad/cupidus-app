# Phase P3 – FCM Transport And Persisted Pending Queue

## 1. Objective

Parse the ADR-012f FCM payload into the same `RealtimeEvent` model the socket produces, and persist background-delivered events in a bounded queue that survives process death.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-fcm-transport-queue.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P0, P2
- Parallelizable: NO (single mobile writer inside `core/realtime/`)
- Write Scope:
  - `mobile/lib/core/realtime/fcm_transport.dart`
  - `mobile/lib/core/realtime/pending_event_store.dart`
  - `mobile/test/core/realtime/fcm_transport_test.dart`
  - `mobile/test/core/realtime/pending_event_store_test.dart`
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
  - FCM transport with an injectable message source (so P5 can drive a fake)
  - `PendingEventStore`: bounded append-only JSON list in `SharedPreferences`, implementing `SessionScopedStore`
- Shared Interfaces Consumed:
  - P0 barrel: `RealtimeEvent`, durable/ephemeral classifier
  - P1 Android notification channel id (from `../../deployment/configuration-guide.md`)
- Risk Surfaces:
  - Foreground/background transition (AC2)
  - Cross-user queue leakage on device sharing
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` ADR-012f, ADR-012g.4
  - consumer contract: the coordinator (P4) drains the queue through the dedup gate
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC1, AC2
  - architecture: `../architecture/solution.md` ADR-012f, ADR-012g
  - OQ constraints: R9 — there is no server dispatch, so the transport is exercised via FCM HTTP v1 injection, not a backend push; F5/ADR-007 — Drift is not built, so the queue uses `SharedPreferences` for now
  - upstream phase outputs: P0 surface, P1 channel id
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO (read-only consumer of the P1 section)
  - Sections To Update: N/A
- Phase Sizing:
  - Behavior Slice: background delivery ingestion and durable persistence
  - Source/Test File Count: 4
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` ADR-012f, ADR-012g
- `master-plan.md` §3, §3A, §6
- `phase-P0-realtime-contract.md` §5
- `../../deployment/configuration-guide.md` FCM/APNs section (channel id only)

## 3. Tasks

- Implement one parser from the ADR-012f `data` map (`cupid_event`, `cupid_event_id`, `cupid_payload`) into `RealtimeEvent`, reusing the same event model as the socket leg so a single parser serves both transports. `cupid_event_id` becomes `RealtimeEvent.id`; if it is missing, the event is ephemeral and must not be persisted.
- Reject/ignore any message whose `data` map lacks `cupid_event`, and log the rejection without payload contents.
- Register the foreground handler and a **top-level** background handler in this file. The background handler must not touch `get_it` or any in-memory state (it runs in a separate isolate); its only side effect is appending to `PendingEventStore`.
- Implement `PendingEventStore` as a bounded append-only JSON list in `SharedPreferences` (ADR-012g.4): a fixed maximum length with oldest-first eviction, so the queue cannot grow unbounded. Document in the file that this is a deliberate placeholder to be migrated to Drift when F5 lands.
- Implement `SessionScopedStore.clearOnSignOut()` on the store so a second user on the same device cannot inherit queued events.
- Do not persist ephemeral events at all: they are meaningless once backgrounded and are never FCM-delivered (ADR-012d).
- Do not drop or transform events based on `transport`; classification is by id presence only.

## 4. Acceptance Criteria

- A well-formed ADR-012f payload parses into a `RealtimeEvent` whose `name` and `id` match the injected values and whose `transport` reflects the FCM leg.
- A payload missing `cupid_event` is rejected without throwing into the isolate, and nothing is persisted.
- An event with no `cupid_event_id` is treated as ephemeral and is not persisted.
- The queue never exceeds its bound; the oldest entry is evicted first.
- A persisted queue survives a store re-instantiation (round-trip through `SharedPreferences`).
- `clearOnSignOut()` leaves the queue empty.
- No log line contains payload contents.

## 5. Planned Outputs

- Code directories or files: `mobile/lib/core/realtime/{fcm_transport,pending_event_store}.dart`
- Contracts or schemas: pending-queue JSON entry shape `{name,id,payload,receivedAt}`
- Requirement configuration guide updates: none
- Notes or evidence: none beyond unit tests

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `mobile/lib/core/realtime/`
- Required levels:
  - unit: ADR-012f payload parse (valid, missing `cupid_event`, missing `cupid_event_id`), queue bound and eviction order, persistence round-trip, `clearOnSignOut`
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: no real `firebase_messaging` channel invoked in tests (injected fake message source); `firebase_messaging` imported only under `core/realtime/`; the background handler references no `get_it` symbol
- Minimum gates by risk surface:
  - Foreground/background transition (AC2): a background-injected durable event is present in the queue after persistence
  - Cross-user queue leakage: queue empty after `clearOnSignOut()`
- Verification strategy:
  - Targeted tests/regression/contract checks: `flutter test test/core/realtime/`
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: parsed event fields and queue contents before/after eviction and teardown

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
