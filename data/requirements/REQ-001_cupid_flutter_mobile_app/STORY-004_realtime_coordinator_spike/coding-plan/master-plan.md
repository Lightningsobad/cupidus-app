# Master Coding Plan – STORY-004 RealtimeCoordinator Spike (Socket.IO + FCM)

## 1. Planning Metadata

- Story ID: STORY-004
- Complexity: M / Story-Class `standard`
- Planning Owner: Tech Lead
- Source Requirements: `../story_master.md` (AC1-4, In/Out of Scope, Depends On)
- Source UX: WAIVED — no operator-facing UI surface (recorded in `../story_master.md` Architecture Pass)
- Source Architecture: `../architecture/solution.md` §2 (frozen public surface), ADR-012a-h, §4 Risk Surfaces
- OQ Constraints Source: `req_master.md` D0-D5, R2/R8; new R9 raised by `../architecture/solution.md` ADR-012e
- Review Input: none yet
- Requirement Configuration Guide: `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md`

## 2. Planning Goal

- Shared contract owner: Tech Lead for every name in `../architecture/solution.md` §2. Mobile Developer may not rename them.
- Contract-first phase required: YES (P0 lands `RealtimeEvent` + barrel before any transport)
- Parallel execution possible: PARTIAL — one mobile lane runs sequentially (single writer inside `mobile/lib/core/realtime/`); the DevOps native-config phase (P1) is the only phase that may run concurrently with mobile work.
- Critical path: P0 -> P2 -> P3 -> P4 -> P5
- Parallelism notes: matches `../architecture/solution.md` §8 — "one mobile lane plus one small DevOps configuration phase". Backend is frozen (A1) and there is no UI surface, so there is no second implementation lane. Do not split `core/realtime/` across concurrent mobile writers; every mobile phase touches the same module.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Connection Pattern | Producer Phase | Consumer Phase | Example Artifact / Payload |
|---|---|---|---|---|---|
| `RealtimeCoordinator` / `RealtimeEvent` / `RealtimeStatus` / `RealtimeTransport` | Tech Lead (`solution.md` §2) | Dart barrel `package:cupid_mobile/core/realtime/cupid_realtime.dart` | P0 | P2, P3, P4, P5 (+ STORY-007/008/009) | `Stream<RealtimeEvent> events({Set<String>? names})` |
| Durable-vs-ephemeral event classification (ADR-012d) | Tech Lead | pure function in `realtime_event.dart` | P0 | P3, P4 | durable = server uuid present; ephemeral = no id |
| `backendUserId` resolver (room key, `solution.md` §2) | Tech Lead | injected `Future<String?> Function()` backed by `BackendUserIdStore` | P2 | P4 | backend `User.id`, never Firebase uid |
| Pending background-event queue schema | Mobile Developer | bounded append-only JSON list in `SharedPreferences` (ADR-012g.4) | P3 | P4 | `{name,id,payload,receivedAt}` |
| FCM data payload contract (ADR-012f) | Tech Lead | `data.cupid_event` / `cupid_event_id` / `cupid_payload` | P1 (validation path), backend later (R9) | P3, P5 | `cupid_event_id` == entity uuid |
| Native FCM/APNs enablement | DevOps Engineer | APNs key in Firebase, iOS `UIBackgroundModes`, Android channel | P1 | P5 | `deployment/configuration-guide.md` FCM/APNs section |

## 3A. Risk Surfaces And Verification Contract

| Risk Surface | Source Of Truth | Consumer Contract | Minimum Gate | Required Dependency | Blocker If Gate Cannot Run |
|---|---|---|---|---|---|
| Merged-stream dedup (AC1, AC2) | ADR-012d | `events()` yields each durable id exactly once | Unit: same `Message.id` injected through both fake transports -> exactly 1 event | fake transports only | none |
| Foreground/background transition (AC2) | ADR-012g | no duplicate, no drop, order preserved | Unit: fake `AppLifecycleListener` drives resumed -> paused -> resumed; queue drained through the dedup gate | fake lifecycle + fake transports | R9: no backend FCM dispatch, so a real-device run is a manual operator procedure, not a phase gate |
| Socket subscription (AC1) | ADR-012b | `joinedRoom` ack observed before `RealtimeStatus.live` | Unit: fake socket asserts `connect` -> `emit('joinRoom', backendUserId)` -> ack -> `live` | fake socket | live-backend confirmation is deferred to the manual procedure in P5 |
| Token in handshake (AC3) | ADR-012c + STORY-003 §2 | `handshake.auth.token` == current `CupidSession.idToken()` | Unit: built option map carries the token; diagnostics/log output never contains it | fake session | none |
| Room key correctness | `solution.md` §2 `backendUserId` | backend `User.id`, never Firebase uid | Unit: resolver returns the `id` from the `POST /auth/login` body; missing id raises a typed failure instead of falling back to uid | none | none (generated client types the body `void` — see §6 Risks) |
| Session teardown | `solution.md` §2 lifecycle contract | `clearOnSignOut()` disconnects, clears LRU + queue + room key | Unit: after `clearOnSignOut()` no queued event and no cached room key survive | fake stores | none |

## 4. Lane Summary

- Backend required: NO (A1 — backend frozen, zero change)
- Frontend required: NO
- Mobile required: YES (primary lane)
- DevOps required: YES (P1 only)
- Initial implementation owner: Mobile Developer (P0)
- Final verification owner: Mobile Developer (P5)
- Shared contract owner: Tech Lead
- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` (registry readiness is a widget-test signal, not a boot probe; no app entry point or runtime command changes), command/source runtime registry `mobile-app.buildCommand` / `testCommand`

Entry-point note (skill rule 13a): this story ships no user-facing capability — UX is WAIVED and no screen, route, or navigation affordance is added. The equivalent reachability wiring for this non-UI capability is the `get_it` lazy-singleton registration plus `SessionScopedStore` enrollment in P4; without it the coordinator would be an orphaned module. No navigation phase is required or permitted.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|------|-------|------|------------|----------------|-------------|----------------|-----------------|------------|--------|
| P0 | Mobile Developer | Contract | None | NO | `mobile/pubspec.yaml`, `mobile/lib/core/realtime/realtime_event.dart`, `realtime_failure.dart`, `cupid_realtime.dart`, `mobile/test/core/realtime/realtime_event_test.dart` | `../architecture/solution.md` §2, ADR-012d, ADR-012f | frozen public surface + event model + durable/ephemeral classifier + 3 new pubspec deps | unit (classification/parsing), `flutter analyze` | NOT_STARTED |
| P1 | DevOps Engineer | DevOps | P0 | YES (with P2-P4) | `mobile/ios/Runner/Info.plist`, `mobile/android/app/src/main/AndroidManifest.xml`, `../../deployment/configuration-guide.md` | `../architecture/solution.md` §2 DevOps contract, ADR-012f, §4 DevOps Lane Handoff | iOS remote-notification background mode, Android default notification channel, APNs-key + FCM HTTP v1 injection procedure documented | static config review, no tests | NOT_STARTED |
| P2 | Mobile Developer | Mobile | P0 | NO | `mobile/lib/core/realtime/socket_transport.dart`, `backend_user_id_store.dart`, `mobile/lib/features/auth/data/auth_repository.dart`, `mobile/test/core/realtime/socket_transport_test.dart`, `mobile/test/core/realtime/backend_user_id_store_test.dart` | `../architecture/solution.md` ADR-012a/b/c, §2 auth + `backendUserId` contracts | single socket transport with two-step joinRoom handshake, token-in-handshake, backoff reconnect, room-key store | unit (handshake order, auth map, backoff, room key), `flutter analyze` | NOT_STARTED |
| P3 | Mobile Developer | Mobile | P0, P2 | NO | `mobile/lib/core/realtime/fcm_transport.dart`, `pending_event_store.dart`, `mobile/test/core/realtime/fcm_transport_test.dart`, `mobile/test/core/realtime/pending_event_store_test.dart` | `../architecture/solution.md` ADR-012f/012g.4 | FCM transport parsing the ADR-012f payload, background handler, bounded persisted pending queue | unit (payload parse, queue bound, persistence round-trip), `flutter analyze` | NOT_STARTED |
| P4 | Mobile Developer | Mobile | P2, P3 | NO | `mobile/lib/core/realtime/realtime_coordinator.dart`, `mobile/lib/core/realtime/cupid_realtime.dart`, `mobile/lib/core/di/service_locator.dart`, `mobile/test/core/realtime/realtime_coordinator_test.dart` | `../architecture/solution.md` §2, ADR-012d/012g | coordinator impl: lifecycle machine, merge + LRU dedup, status stream, emit/resync, `clearOnSignOut`, DI registration | unit (dedup, transition, teardown), `flutter analyze` | NOT_STARTED |
| P5 | Mobile Developer | Mobile Verification | P0, P1, P2, P3, P4 | NO | `mobile/test/core/realtime/**`, `test-results.md`, `spike-findings.md` | all phase `## 6. Test Scope` sections, `../architecture/solution.md` §4 risk table | AC1-4 prototype harness, `test-results.md`, `spike-findings.md` (AC4 findings + manual operator procedure) | `flutter test`, `flutter analyze`, `flutter build apk --debug` | NOT_STARTED |

The final phase (P5) is the verification phase for this `standard` story.

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | `phase-P0-realtime-contract.md` |
| P1 | `phase-P1-fcm-apns-config.md` |
| P2 | `phase-P2-socket-transport.md` |
| P3 | `phase-P3-fcm-transport-queue.md` |
| P4 | `phase-P4-coordinator-lifecycle.md` |
| P5 | `phase-P5-verification.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file; no duplicates exist.
- Every mobile phase is sized to 4-5 source/test files, inside one specialist lifecycle.
- No phase plans backend e2e, Playwright/browser e2e, mobile e2e, emulator/simulator lifecycle commands, signing, store upload, traces, scenario reruns, repository-root local script gates, or runtime startup smoke.

## 6. Risks And Notes

- Risks:
  - **R2 (high, this story's reason to exist)**: socket/FCM reconciliation. Mitigated by ADR-012d/012g and gated in P4/P5.
  - **R8 (high, out of scope)**: backend Socket.IO gateway has no auth check. P2 sends the token anyway (AC3) so the client is correct the day the backend enforces it. Not a gate on any phase here; epic-2 production readiness still needs the backend decision.
  - **R9 (high, new, out of scope)**: backend has no FCM dispatch and no device-token storage — every push is a `console.log` stub. Consequence for this plan: the FCM leg is validated by injecting messages through the FCM HTTP v1 API with the existing `backend/service-account.json` (zero backend change, A1-safe), documented as an operator procedure in P1/P5. Phase gates use fake transports and never depend on a real push. Background reminders (D1, epic-3) cannot ship until the backend adds token registration, storage, and `admin.messaging()` dispatch.
  - `POST /messages` emits nothing to the socket (ADR-012h) — recorded for epic-2 only; no phase here depends on it.
  - **Room-key typing gap (new, resolved in-plan)**: `POST /auth/login` does return the backend user entity (`backend/src/modules/auth/auth.controller.ts:15-21`), so the `User.id` needed for `joinRoom` is available at runtime — but the OpenAPI spec declares no response schema, so the generated client types it `Response<void>` (`mobile/openapi/cupid_api/lib/src/api/epic1_auth_api.dart:32`) and the body is not reachable through the typed call. P2 therefore reads it from the shared `Dio` instance that already carries the interceptor pipeline, keeping the existing 404 -> register fallback intact. Do not regenerate the client and do not change the backend.
  - Ephemeral events cannot be deduped at all (ADR-012d); P3/P4 must drop them while not foreground rather than attempt dedup.
- OQ-driven constraints: D1/ADR-002 — reminders are notifications, never Critical Alerts or real alarms; P1 must not request the Critical Alerts entitlement. ADR-006/010f/011 — no codegen for realtime; the module stays hand-written. ADR-007 — resync is a page-1 REST refetch reconciled by `id`; there is no cursor or socket replay.
- Migration / rollout notes: additive module, no data migration. The `SharedPreferences` pending queue is deliberately temporary — migrate to Drift when F5 lands (ADR-012g.4).
- Notes: guardrails from `../architecture/solution.md` §4 Mobile Lane Handoff are binding — no backend edits; no `socket_io_client` / `firebase_messaging` import outside `mobile/lib/core/realtime/`; never key rooms by the Firebase uid; never force a reconnect on token rotation; never emit ephemeral events while backgrounded.
