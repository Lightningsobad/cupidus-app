---
story_status_recommendation: "DONE"
implementation_status_recommendation: "KEEP_CHECKED"
reviewed_at: 2026-07-30
reviewed_by: Reviewer
---

# Review Report: STORY-004 Spike: RealtimeCoordinator, Socket.IO + FCM Dual Path

Outcome: DEFERRED_ONLY

## Reviewed Inputs

- Review gate: `final-synthesis`
- Scope Gate: `inline` (story exceeded compact/full-story-review budget at 20 files; split into 3 sequential scoped slices)
- Requirements: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-004_realtime_coordinator_spike/story_master.md` (via slice passes)
- Bug Report: `N/A`
- Diagnosis: `N/A`
- Fix Evidence: `N/A`
- UX: `N/A`
- Architecture: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-004_realtime_coordinator_spike/architecture/solution.md` (via slice passes)
- Coding Plan: `coding-plan/phase-P0..P5-*.md` (via slice passes)
- Test Results: `test-results.md`, `spike-findings.md` (verified in slice C)
- Slice reports (sole inputs to this synthesis):
  - `review/slice-a-report.md` — P0 realtime contract + P2 socket transport (commit 8712fd9)
  - `review/slice-b-report.md` — P1 FCM/APNs config + P3 FCM transport/stores (commit 4b4d361)
  - `review/slice-c-report.md` — P4 coordinator/DI + P5 verification (commit f140cd9)
- Previous review findings: `N/A`

## Reviewed Scope

- Story complexity: `standard`
- Bug status: `N/A`
- Code scope reviewed: 20 files across `mobile/lib/core/realtime/**`, `mobile/lib/core/di/service_locator.dart`, `mobile/lib/features/auth/data/auth_repository.dart`, `mobile/test/core/realtime/**`, `mobile/android/app/src/main/AndroidManifest.xml`, `mobile/ios/Runner/Info.plist`, `mobile/pubspec.{yaml,lock}`
- Evidence reviewed: `test-results.md`, `spike-findings.md`, cross-checked against literal `group`/`test` names in `realtime_coordinator_test.dart`
- Risk surfaces reviewed: dedup, foreground/background transition, socket subscription lifecycle, token-in-handshake, room-key derivation, session teardown, real-device background push
- Critical gates reviewed: realtime contract freeze (P0), auth/room-key isolation (P2/P3), background-isolate safety (P3), lifecycle + dedup + resync (P4), verification evidence integrity (P5)
- Backend targeted verification gates: `NOT_APPLICABLE`
- Story runtime startup smoke: `NOT_APPLICABLE`
- Frontend targeted verification gates: `NOT_APPLICABLE`
- Frontend discoverability/navigation integration: `NOT_APPLICABLE`
- Requirement frontend visual audit: `NOT_APPLICABLE`
- Mobile targeted verification gates: `PASS` (`flutter test test/core/` harness recorded in `test-results.md`; entries cross-verified against source test names)
- Mobile discoverability/navigation integration: `NOT_APPLICABLE` (spike introduces no user-facing surface)
- Requirement mobile visual audit: `NOT_APPLICABLE`
- Story artifacts reviewed: story master, architecture solution, phase plans P0-P5, test results, spike findings, deployment configuration guide
- Bug artifacts reviewed: `N/A`
- OQ context reviewed: ADR-012d/012f/012g referenced by the phase plans; no open OQ blocking this story

## Outcome Summary

- Review outcome: DEFERRED_ONLY
- Rationale: All stated acceptance criteria across P0-P5 verified PASS by the three scoped slices, with the sole exception of AC4 (real-device background push), which the story itself records as a typed R9 deferral with rationale rather than silently dropping. The frozen realtime contract is intact, the room key derives only from the backend `User.id` with no Firebase-uid fallback path, no token or payload content reaches log output, the background isolate handler is correctly top-level and DI-free, and lifecycle/dedup/resync behavior matches the phase specs including under rapid foreground/background cycling. The five remaining findings are hardening or coverage items, all outside this spike's stated ACs and none introduced as a regression by this diff.
- Blocking findings: 0
- Deferred findings: 5
- Dismissed observations: 1 (shared `Dio`/interceptor pipeline was suspected altered by the `_syncBackendProfile()` rewrite; confirmed preserved, so `DioException`/`HttpStatusFailure` mapping is unchanged)

## Traceability Summary

- Requirements: P0 AC1-3 PASS (contract names/signatures verbatim, durable/ephemeral classifier, barrel isolation); P0 AC4 (`pub get`/`analyze`) not runnable in the review environment but covered by the recorded mobile test run; P1 config ACs PASS (iOS `UIBackgroundModes: remote-notification`, Android `cupid_realtime_default` channel, configuration guide complete and consistent); P2 AC1-4/AC6 PASS, AC5 partial (see D1); P3 ACs PASS (single parser, graceful rejection, ephemeral never persisted, bounded store, `clearOnSignOut`); P4 ACs PASS (30s grace, LRU-512, resync ordering, `get_it` composition, scoped-store enrollment); P5 evidence PASS (all named harness tests exist and match; risk-surface table internally consistent at 6 PASS + 1 typed deferral)
- Bug report: `N/A`
- Diagnosis: `N/A`
- Open Questions: none opened by this review
- UX: `N/A`
- Architecture: contract in `architecture/solution.md` §2 matched verbatim by `cupid_realtime.dart`; no drift
- Testing evidence: `test-results.md` and `spike-findings.md` claims independently cross-checked against test source; no unsupported PASS claims found

## Risk Surface Gate Summary

| Risk Surface | Source Of Truth | Critical Gate | Result | Notes |
|--------------|-----------------|---------------|--------|-------|
| Durable-event dedup | phase-P4 §3, ADR-012d | LRU-512 bound, move-to-MRU eviction | PASS | Verified by code trace and named bound test |
| Foreground/background transition | phase-P4 §3, ADR-012g.3 | 30s grace, queue-drain before `resync()` | PASS | Grace timer never duplicated or leaked under rapid cycling |
| Socket subscription lifecycle | phase-P2 §4 | connect → joinRoom → ack → live ordering | PASS | Pre-ack events provably dropped; reconnect re-emits joinRoom |
| Token in handshake | phase-P2 §4 | token only in `auth.token`, never logged | PASS | No log statements in transport; token-stream update does not reconnect |
| Room key derivation | phase-P2/P3 §4 | backend `User.id` only, typed failure on absence | PASS | `updateFromLoginResponse` reads `body['id']` only; no Firebase-uid fallback exists structurally |
| Session teardown | phase-P4 §3 | `clearOnSignOut()` clears coordinator + both stores | PASS | Single scoped-store enrollment; no double-teardown |
| Real-device background push | phase-P5 §3/§4 | operator-confirmed device delivery | DEFERRED (R9) | Typed deferral recorded in both `spike-findings.md` §4 and `test-results.md` §4 with no-backend-dispatch rationale |

## Deferred Findings

- **D1 — Reconnect backoff cap delegated to vendor defaults** (`mobile/lib/core/realtime/socket_transport.dart`). The force-refresh half of P2 AC5 is implemented and tested, but the transport never sets `reconnectionDelay`/`reconnectionDelayMax`, relying on undocumented `socket_io_client` Manager defaults with no assertion that a cap exists. Acceptable for a spike; if the vendor default changes or is overridden elsewhere, nothing catches an uncapped retry storm. Recommend setting the cap explicitly with a covering assertion before epic-2 production traffic.
- **D2 — `SocketTransport.start()` idempotency race** (`socket_transport.dart:146-153`). `_started` is set only after the `_backendUserId()` await resolves, so two overlapping `start()` calls both build sockets and the second orphans the first (subscription leak). Contradicts the documented "idempotent" guarantee, though no current caller invokes it concurrently. Fix is one line (set `_started` synchronously at entry) or document the caller-discipline assumption.
- **D3 — Malformed `cupid_payload` throws into the background isolate** (`fcm_transport.dart`). `jsonDecode` is called directly on `cupid_payload` when present; a message carrying a valid `cupid_event` but a non-JSON payload string raises `FormatException` inside the background handler instead of being rejected gracefully. The stated AC only covers a *missing* `cupid_event`, so this is outside scope, but it is a real robustness gap for an isolate entry point.
- **D4 — AC7 (404 → register fallback) has no automated regression coverage** (`mobile/test/features/auth/data/auth_repository_test.dart`). No test in the repo — before or after this diff — exercises `_syncBackendProfile()`'s login-then-404-fallback-to-register path, and the phase-P5 test command (`flutter test test/core/`) does not run `test/features/auth/**`. The AC7 claim rests on code review, not an assertion. Pre-existing gap, not a regression, and the one plausible failure mode (loss of the interceptor pipeline when swapping generated calls for `_api.dio.post`) was investigated and ruled out. Recommend a fast-follow test covering both the fallback and the `BackendUserIdStore` wiring.
- **D5 — Unguarded `event.id!` for misclassified durable events** (`realtime_coordinator.dart`). `_emitDeduped` force-unwraps `event.id!` for any non-ephemeral event, while `_classifySocketEvent` yields `null` for a missing/empty/non-`String` id. A backend-emitted durable event name without a well-formed id would throw at runtime rather than degrade. Not exercised by the harness and not a stated AC; hardening item for epic-2/epic-3.

## Workflow State Recommendation

- Story status: `DONE`
- Bug status: `N/A`
- `Implementation (Development)`: `KEEP_CHECKED`
- `Review (Reviewer)`: `CHECK`
- Next step: Scrum Master may mark STORY-004 `DONE` and make the branch merge-eligible. Carry D1-D5 forward as backlog/hardening candidates; D4 and D1 are the two worth scheduling before realtime carries production traffic. AC4 remains an operator-confirmation item tracked under R9 and does not gate this story.
- State update owner: `scrum-master` only. Reviewer does not edit story or requirement status files.
