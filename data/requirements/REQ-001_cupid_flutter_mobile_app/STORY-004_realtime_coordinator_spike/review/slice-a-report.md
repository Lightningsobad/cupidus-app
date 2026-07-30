Slice A Review — P0 (realtime contract) + P2 (socket transport)

Scope: mobile/lib/core/realtime/{realtime_event,realtime_failure,cupid_realtime,socket_transport}.dart,
mobile/test/core/realtime/{realtime_event_test,socket_transport_test}.dart

## P0 — Acceptance Criteria (phase-P0-realtime-contract.md §4)

| # | AC | Result |
|---|----|--------|
| 1 | Every name in architecture/solution.md §2 exists with declared signature, nothing renamed | PASS — `RealtimeStatus`, `RealtimeTransport`, `RealtimeEvent` (name/id/data/transport/receivedAt), `RealtimeCoordinator` (events/status/start/stop/emit/resync) all match the frozen contract verbatim |
| 2 | Classifier returns durable for event with uuid, ephemeral for one without | PASS — `isDurable => id != null`; tested for both cases in `realtime_event_test.dart` |
| 3 | Barrel is the only import surface; no transport package leaks through it | PASS — `cupid_realtime.dart` exports only `realtime_event.dart`/`realtime_failure.dart`; no socket_io_client/firebase_messaging import |
| 4 | `flutter pub get` resolves new packages, `flutter analyze` clean | UNVERIFIED — `flutter` toolchain not available in this review environment; not run |

## P2 — Acceptance Criteria (phase-P2-socket-transport.md §4)

| # | AC | Result |
|---|----|--------|
| 1 | Built option map carries current `idToken()` under `auth.token`; no log line contains the token | PASS — `setAuth({'token': initialToken})`; no print/log statements anywhere in the file; test asserts `transports`, `autoConnect: false`, `auth: {'token': 'token-initial'}` |
| 2 | Fake socket observes strictly connect -> joinRoom(<backend User.id>) -> ack -> live; no event before ack | PASS — `_handleConnect` awaits `emitWithAckAsync(joinRoom, roomKey)` before setting `_joined=true`/`live`; `_handleAny` gates on `_joined`; test explicitly fires an event before the ack and asserts it is dropped, then asserts it arrives after ack |
| 3 | Simulated reconnect re-emits joinRoom | PASS — `_handleConnect` reruns on every `onConnect`; test drives connect→ack→disconnect→connect→ack and asserts 2 joinRoom emits |
| 4 | `idTokenStream` emit does not trigger reconnect but updates next handshake | PASS — listener only mutates `socket.auth`; test asserts `connectCalls`/`disconnectCalls` unchanged, `capturedAuth` updated |
| 5 | `connect_error` triggers force-refreshed token + capped-backoff reconnect | PARTIAL — force-refresh + auth-map replace verified by code and test (`forceRefreshCalls == [false, true]`, `capturedAuth` updated). The "capped backoff reconnect" half is **not implemented or configured in this file** — the transport never sets `reconnectionDelay`/`reconnectionDelayMax` on `OptionBuilder`, and relies entirely on the vendor socket_io_client Manager's built-in defaults (undocumented assumption). Doc comment on the test acknowledges this delegation but there is no assertion anywhere (code or test) that a cap actually exists. Not blocking for a spike, but flag as a deferred gap — if the vendor default ever changes/is overridden elsewhere, nothing catches an uncapped retry storm. |
| 6 | Room key resolves to backend `User.id`; missing id raises typed failure, never falls back to Firebase uid | PASS for this file — `start()` throws `RealtimeRoomKeyUnavailableFailure` when the injected `backendUserId()` resolver returns null/empty, and the class has no Firebase-uid input at all so a silent fallback is structurally impossible here. Test confirms no socket factory call (`factoryCalls == 0`) when resolver returns null. NOTE: actual room-key **derivation** (`BackendUserIdStore`, `AuthRepository` wiring) lives in `backend_user_id_store.dart` / `auth_repository.dart`, which are outside this slice's file list — confirmed present in the full story diff (`backend_user_id_store.dart`, `backend_user_id_store_test.dart`, edited `auth_repository.dart`) but not reviewed here. Whichever slice covers those files must verify AC6's derivation half and AC7. |
| 7 | Existing 404 -> register fallback in `AuthRepository` still passes | OUT OF SLICE SCOPE — `auth_repository.dart` is not in this slice's file list; defer to the slice reviewing that file. |

## Additional correctness finding (not an explicit AC, but affects "no correctness/edge-case issues" charge)

- **Idempotency race in `SocketTransport.start()`** (`mobile/lib/core/realtime/socket_transport.dart:146-153`): the `_started` guard is checked at entry, but `_started = true` is only set *after* `await _backendUserId()` resolves. If `start()` is invoked a second time before the first call's `_backendUserId()` await completes, the guard does not block it — both invocations proceed to build a socket, and the second overwrites `_socket`/`_idTokenSubscription`, orphaning the first socket without disconnecting it (subscription leak). Both `cupid_realtime.dart`'s `RealtimeCoordinator.start()` doc and this file's own doc comment declare `start()` "idempotent," so this is a genuine (if narrow) violation of a documented guarantee. No test exercises concurrent/double `start()` calls. Not blocking for this spike-scope story (typical single-caller usage in P4 likely awaits sequentially), but should be tracked — either fix (set `_started = true` synchronously at entry, before any await) or explicitly note the caller-discipline assumption in a comment.

## Summary

All P0 AC1-3 and P2 AC1-4/AC6(partial) verified PASS against files in this slice. One deferred/non-blocking gap (AC5 backoff cap not implemented/asserted) and one non-blocking correctness finding (start() idempotency race) to carry into final synthesis. Build/analyze gate (P0 AC4) UNVERIFIED — no Flutter toolchain in this review environment. AC6 (derivation) and AC7 depend on files outside this slice (`backend_user_id_store.dart`, `auth_repository.dart`) — must be confirmed by whichever slice/pass covers them.
