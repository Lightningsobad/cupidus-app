# STORY-004 Review — Slice C (P4 coordinator/DI wiring + P5 verification)

Scope: `realtime_coordinator.dart`, `service_locator.dart`, `auth_repository.dart`,
`realtime_coordinator_test.dart`, `pubspec.yaml`/`pubspec.lock`, `test-results.md`,
`spike-findings.md`. Diff base: `00938d8276c8a8a15671fcd1e671db55d2aa32dc`.

## Findings Table

| # | Item | Result | Notes |
|---|---|---|---|
| 1 | Lifecycle machine: ~30s grace before disconnect on background | PASS | `realtimeGraceDuration = Duration(seconds: 30)`; `_enterBackgroundGraceWindow` only starts the timer once (`??=`) and only when transitioning from foreground; grace cancelled correctly on `detached` and on return to foreground. |
| 2 | LRU-512 durable-event dedup | PASS | `_BoundedSeenIds(maxSeenIds=512)`; move-to-MRU-then-evict-oldest logic correct; covered by `LRU bound (ADR-012d: 512 entries)` test. |
| 3 | `resync()` on foreground/reconnect | PASS | `_enterForeground()` drains the pending queue then calls `resync()` only on the `!wasForeground` transition (including the modeled cold-start-as-resume case); queue-before-resync ordering matches ADR-012g.3 and is asserted by the added P5 harness test. |
| 4 | `clearOnSignOut()` wiring | PASS | Stops, clears LRU + dropped-count, clears `PendingEventStore` and `BackendUserIdStore`. Matches phase-P4 §3 spec exactly. |
| 5 | `service_locator.dart` DI wiring (get_it) | PASS | `RealtimeCoordinator` registered as `get_it` lazy singleton, composed from `SocketTransport`/`FcmTransport`/`PendingEventStore`/`BackendUserIdStore`, enrolled via `session.registerScopedStore(coordinator)`. Matches phase-P4 §2. Confirmed `backendUserIdStore`/`pendingEventStore` are *not* separately double-registered as scoped stores (only the coordinator is), so no double-teardown risk. |
| 6 | `auth_repository.dart` — AC6 wiring half (calls `BackendUserIdStore.updateFromLoginResponse` on login/register) | PASS | Call site `_backendUserIdStore?.updateFromLoginResponse(response.data)` after both `/auth/login` and `/auth/register` POSTs; verified against slice B's actual signature `void updateFromLoginResponse(Object? body)` — types match. |
| 7 | `auth_repository.dart` — AC7 (existing 404→register fallback still passes) | **UNVERIFIED** | See Finding A below — no automated test in the repo actually exercises this fallback path, before or after this diff. |
| 8 | `test-results.md`/`spike-findings.md` AC1-AC3 named harness tests are real and match `realtime_coordinator_test.dart` | PASS | Cross-checked all 4 coordinator-owned entries (2 dedup, 2 lifecycle/log) against literal `group`/`test` strings in the diff — exact match, including the P5-added `a background-injected event is drained on resume in order...` test. (The 2 `SocketTransport handshake` entries live in `socket_transport_test.dart`, out of this slice's scope — not re-verified, per slice-B ownership.) |
| 9 | AC4 real-device background push recorded as typed deferral (R9), not silently dropped | PASS | `spike-findings.md` §4 and `test-results.md` §4 both explicitly mark it "deferred manual operator procedure" / "Blocked — R9 (typed)" with the no-backend-dispatch rationale, per phase-P5 §3/§4. |
| 10 | 6-of-7 risk-surface PASS claim consistency | PASS | Table has 6 Pass rows (dedup, fg/bg transition, socket subscription, token-in-handshake, room-key, session-teardown) + 1 Blocked (real-device push) = matches phase-P5 §4A's 6 touched risk surfaces + the separately-tracked device-confirmation gate. |
| 11 | `realtime_coordinator_test.dart` coverage of lifecycle/dedup/resync/DI claims | PASS | All named AC1-AC3 coordinator tests present and match; also covers `emit` failure path, `start()` idempotence, `clearOnSignOut`, and DI registration (`getIt.isRegistered<RealtimeCoordinator>()`). |
| 12 | Grace timer / LRU interaction under rapid foreground/background cycling | PASS, no defect found | Traced the `sync: true` broadcast lifecycle stream: each handler mutates `_foreground` synchronously before its first `await`, so overlapping/rapid transitions see consistent state and the `wasForeground` guard prevents double-drain/double-resync even when async continuations from a prior transition are still pending. Grace timer is always cancelled before a new one is scheduled (`_cancelGraceTimer()` in `_enterForeground`/`_enterBackgroundImmediately`, `??=` guard in `_enterBackgroundGraceWindow`), so no duplicate/leaked timers under rapid cycling. |
| 13 | No payload/token in log output | PASS | `_log` calls at drop/discard sites log only ids/counts; asserted by `log output never contains payload contents or tokens` test. |

## Finding A (non-blocking, escalate) — AC7 has no automated regression coverage

`mobile/test/features/auth/data/auth_repository_test.dart` only tests
`AuthRepository.signOut()`. There is no test in the repository — before or
after this diff — that exercises `_syncBackendProfile()`'s
login-then-404-fallback-to-register path, and phase-P5's test command
(`flutter test test/core/`) does not run `test/features/auth/**` at all. The
handoff's AC7 claim ("existing 404→register fallback still passes") is
therefore not backed by any automated assertion in this repo; it is an
inference from code review, not a test result. This gap pre-dates this slice
(the fallback logic itself existed before STORY-004 touched this file) and is
not a regression introduced by this diff, but the change to
`_syncBackendProfile()` (swapping the generated `authControllerLogin`/
`authControllerRegister` calls for raw `_api.dio.post(...)`) is exactly the
kind of change this missing coverage should have caught if it were wrong.
Recommend a follow-up test added to `auth_repository_test.dart` covering the
404→register fallback and the `BackendUserIdStore` wiring, either in this
story or as a fast-follow — not a blocker for this spike story's own ACs.

Confirmed non-issue while investigating this: `_api.dio.post(...)` uses the
same shared `Dio` instance (with the full interceptor pipeline, including
`CupidErrorInterceptor`) as the generated `getEpic1AuthApi()` calls it
replaces — `CupidApiClient.create()` constructs one `Dio`, adds interceptors,
then passes it into `CupidApi(dio: dio, ...)`, whose generated `dio` getter
exposes that same instance. So the `DioException`/`HttpStatusFailure` mapping
this method depends on is preserved.

## Finding B (minor, non-blocking) — unguarded `event.id!` for misclassified durable events

`_classifySocketEvent` sets `id` to `null` when the payload's `id` field is
missing/empty/non-`String`. `_emitDeduped` force-unwraps `event.id!` for any
non-ephemeral event. If the backend ever emits a durable-classified event name
(e.g. `chat.messageCreated`) without a well-formed `id`, this throws at
runtime instead of failing gracefully. Not exercised by the harness (all test
fixtures always supply an id for durable events) and not a stated AC; a
hardening item for epic-2/epic-3, not a blocker for this spike.

## Deferred / Out-of-Scope (per handoff)

- `socket_transport_test.dart`, `backend_user_id_store_test.dart` and their
  P2 contract claims — owned by slice B, not re-verified here.
- `master-plan.md` full contents — not read; hygiene claims cross-checked only
  against the P4/P5 phase files and the on-disk `coding-plan/phase-P*.md`
  listing (exactly one file per phase id, P0-P5, confirmed).

No `Outcome:` line — reserved for the final synthesis report.
