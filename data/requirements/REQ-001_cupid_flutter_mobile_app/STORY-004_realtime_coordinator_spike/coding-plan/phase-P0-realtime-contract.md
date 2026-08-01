# Phase P0 – Realtime Contract Surface And Dependencies

## 1. Objective

Land the frozen public surface from `../architecture/solution.md` §2 plus the ADR-012d durable/ephemeral classifier, and add the three new packages, so every later phase codes against a fixed contract.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-realtime-contract.md`
- Owner: Mobile Developer
- Lane: Contract

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO (contract-first; P2-P4 consume it)
- Write Scope:
  - `mobile/pubspec.yaml`
  - `mobile/lib/core/realtime/realtime_event.dart`
  - `mobile/lib/core/realtime/realtime_failure.dart`
  - `mobile/lib/core/realtime/cupid_realtime.dart`
  - `mobile/test/core/realtime/realtime_event_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `RealtimeStatus`, `RealtimeTransport`, `RealtimeEvent`, `RealtimeCoordinator` (barrel `package:cupid_mobile/core/realtime/cupid_realtime.dart`)
  - durable/ephemeral classifier
  - `RealtimeNotLiveFailure` and sibling typed failures
- Shared Interfaces Consumed:
  - none
- Risk Surfaces:
  - Merged-stream dedup (AC1, AC2) — the classifier this phase produces is what makes ADR-012d implementable
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` §2 and ADR-012d
  - consumer contract: feature code filters by `names` and switches on `name`, never on `transport`
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC1, AC4
  - architecture: `../architecture/solution.md` §2, ADR-012d, ADR-012f
  - OQ constraints: ADR-006/010f/011 — hand-written, no codegen for realtime
  - upstream phase outputs: none
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO (P1 owns the FCM/APNs section)
  - Sections To Update: N/A
- Phase Sizing:
  - Behavior Slice: contract + event model + dependency availability
  - Source/Test File Count: 5
  - Split Required: NO

## 2. Required Reads

- `../story_master.md`
- `../architecture/solution.md` §2, ADR-012d, ADR-012f
- `master-plan.md` §3, §5

## 3. Tasks

- Add to `mobile/pubspec.yaml` dependencies: `socket_io_client`, `firebase_messaging`, `shared_preferences`. Add no dev/codegen dependency. Run `flutter pub get`.
- Create `realtime_event.dart` with `RealtimeStatus`, `RealtimeTransport`, and the `sealed class RealtimeEvent` exactly as declared in `../architecture/solution.md` §2 (`name`, `id`, `data`, `transport`, `receivedAt`). `name` must hold the exact frozen `CHAT_EVENTS` / `ALARM_EVENTS` string; do not introduce a local event enum that would need remapping.
- Implement the ADR-012d classification as a pure, testable function or getter: an event is **durable** when a server uuid is present, **ephemeral** when it is not. Name the known ephemeral events in a doc comment (`ghostTyping`, `ghostStopTyping`, `messageSeen`, `messageDelivered`, `emojiStormReceived`) but classify by id presence, not by an event-name allowlist, so a new backend event does not silently become undeduped-durable.
- Create `realtime_failure.dart` with the typed failures the surface throws, including `RealtimeNotLiveFailure` (thrown by `emit` when not `live`) and a failure for an unresolvable room key.
- Create the barrel `cupid_realtime.dart` exporting the public surface and declaring `abstract interface class RealtimeCoordinator` per §2. Document in the barrel that feature code must not import `socket_io_client` or `firebase_messaging` directly.
- Add `realtime_event_test.dart` covering classification and payload parsing for one durable and one ephemeral event.

## 4. Acceptance Criteria

- Every name in `../architecture/solution.md` §2 exists with the declared signature; nothing is renamed.
- The classifier returns durable for an event carrying a server uuid and ephemeral for one that does not.
- The barrel is the only import surface needed by a consumer; no transport package leaks through it.
- `flutter pub get` resolves the three new packages and `flutter analyze` is clean for the new files.

## 5. Planned Outputs

- Code directories or files: `mobile/lib/core/realtime/{realtime_event,realtime_failure,cupid_realtime}.dart`, `mobile/pubspec.yaml`
- Contracts or schemas: frozen §2 public surface, ADR-012d classification
- Requirement configuration guide updates: none in this phase
- Notes or evidence: none beyond the unit test

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `mobile/lib/core/realtime/`
- Required levels:
  - unit: classification (durable vs ephemeral) and payload parsing
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: `flutter pub get` resolves cleanly; no `socket_io_client` / `firebase_messaging` import appears outside `mobile/lib/core/realtime/`
- Minimum gates by risk surface: merged-stream dedup — classifier unit test passes for both classes
- Verification strategy:
  - Targeted tests/regression/contract checks: `flutter test test/core/realtime/realtime_event_test.dart`
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: classifier result per event class

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
