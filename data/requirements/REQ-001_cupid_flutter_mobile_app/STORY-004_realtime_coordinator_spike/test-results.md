# STORY-004 Test Results — Phase P5 Verification

Date: 2026-07-30
Scope: AC1-AC3 prototype harness verification, mobile build/analysis gate,
and per-risk-surface disposition for `coding-plan/master-plan.md` §3A.

## 1. Automated Commands Run

| Command | Result |
|---|---|
| `flutter pub get` (mobile/) | Pass |
| `flutter test test/core/` | Pass — 58/58 tests green |
| `flutter analyze` | Pass — 0 errors. 34 pre-existing info/warning items, none in `core/realtime/**` beyond style-only `prefer_initializing_formals` info lints already present from P0-P4 (constructor style predates this phase; not a regression). See §5 for a stale-cache note. |
| `flutter build apk --debug` (registry `mobile-app.buildCommand`) | Pass — `✓ Built build/app/outputs/flutter-apk/app-debug.apk` |

## 2. Master-Plan.md Hygiene (Verification Task 1)

- `coding-plan/master-plan.md` §5 uses the required Phase Overview table
  schema (Phase / Owner / Lane / Depends On / Parallelizable / Write Scope /
  Primary Inputs / Planned Outputs / Test Scope / Status).
- Confirmed exactly one canonical `phase-Px-*.md` file per phase id (P0-P5),
  matching the "Phase file mapping" table 1:1. No duplicate phase files exist
  under `coding-plan/`.

## 3. AC1-AC3 Named Harness Tests

| AC | Named Harness Test | File | Result |
|---|---|---|---|
| AC1 (single event via either transport, feature layer transport-agnostic) | `RealtimeCoordinator dedup (ADR-012d, AC1/AC2) > the same durable id delivered via the socket and via a queued FCM replay yields exactly one event` | `mobile/test/core/realtime/realtime_coordinator_test.dart` | Pass |
| AC1 (foreground FCM never double-delivers with the socket) | `RealtimeCoordinator dedup (ADR-012d, AC1/AC2) > a foreground FCM message is discarded while resumed, and the socket event for the same id still arrives exactly once` | `mobile/test/core/realtime/realtime_coordinator_test.dart` | Pass |
| AC1 (socket subscription gate: no event before `joinedRoom` ack) | `SocketTransport handshake (ADR-012b/c) > observes strictly connect -> joinRoom(<backend User.id>) -> ack -> live, and surfaces no event received before the ack` | `mobile/test/core/realtime/socket_transport_test.dart` | Pass |
| AC2 (resumed -> paused -> resumed, no dup/no drop, order preserved) | `lifecycle transition machine (ADR-012g) > resumed -> paused -> resumed (grace not elapsed) produces no duplicate and no dropped durable event, and preserves order` | `mobile/test/core/realtime/realtime_coordinator_test.dart` | Pass |
| AC2 (background injection drained on resume, order preserved across queue + resync) | `lifecycle transition machine (ADR-012g) > a background-injected event is drained on resume in order, followed by resync catch-up events, with no duplicate and no dropped durable event` (added this phase) | `mobile/test/core/realtime/realtime_coordinator_test.dart` | Pass |
| AC2 (grace window: no premature disconnect, degraded once grace elapses) | `lifecycle transition machine (ADR-012g) > the socket is not disconnected before the grace window elapses, and disconnects to RealtimeStatus.degraded once it does` | `mobile/test/core/realtime/realtime_coordinator_test.dart` | Pass |
| AC3 (handshake auth map carries the current id token) | `SocketTransport handshake (ADR-012b/c) > the built option map carries setTransports/disableAutoConnect and the current idToken() under auth.token` | `mobile/test/core/realtime/socket_transport_test.dart` | Pass |
| AC3 (token/payload never appears in diagnostic log output) | `log output never contains payload contents or tokens > dropped-duplicate and discarded-FCM log lines omit payload data` | `mobile/test/core/realtime/realtime_coordinator_test.dart` | Pass |

## 4. Risk Surfaces (`coding-plan/master-plan.md` §3A) — One Row Each

| Risk Surface | Disposition | Evidence |
|---|---|---|
| Merged-stream dedup (AC1, AC2) | Pass | Two dedup tests in §3 above; also LRU-bound eviction test (`LRU bound (ADR-012d: 512 entries) > an id evicted from the bound is no longer treated as seen`) |
| Foreground/background transition (AC2) | Pass | Three lifecycle tests in §3 above, plus `ephemeral events are dropped while not foreground and are never queued` |
| Socket subscription (AC1) | Pass | `SocketTransport handshake` tests in §3 above, plus `a simulated reconnect re-emits joinRoom` |
| Token in handshake (AC3) | Pass | Two AC3 tests in §3 above |
| Room key correctness | Pass | `SocketTransport room key (§2 backendUserId) > raises RealtimeRoomKeyUnavailableFailure ...` and `BackendUserIdStore.updateFromLoginResponse` suite (never falls back to `uid`) |
| Session teardown | Pass | `clearOnSignOut (AC4) > clears the LRU, the pending queue, the room key, and disconnects` |
| Real-device background push confirmation (live FCM injection through a backgrounded/killed app) | Blocked — R9 (typed) | No backend FCM dispatch exists (`ADR-012e`), so there is no automatable trigger; per phase spec this is a deferred manual operator procedure, not a phase test gate. Procedure recorded in `spike-findings.md` §4 and `../deployment/configuration-guide.md` §"FCM / APNs Setup And Test-Push Injection (STORY-004)". |

## 5. Note On The `flutter analyze` Command

The worktree's local `mobile/build/` cache (gitignored, not a tracked source
path) contained a vendored CocoaPods source checkout
(`build/ios/SourcePackages/checkouts/flutterfire/tests/**`) with its own
unrelated compile errors, pre-dating this phase's work and unrelated to any
file this story touches. `flutter clean` followed by `flutter pub get`
removed the stale cache; the full-package `flutter analyze` above is the
result after that regeneration and is clean (0 errors). No source, build, or
config file was edited to reach this result.
