# Retro Audit: STORY-004 realtime_coordinator_spike

Story: STORY-004 Spike — RealtimeCoordinator (Socket.IO + FCM)
Requirement: REQ-001_cupid_flutter_mobile_app
Run Key: 2026-08-12:REQ-001:STORY-004:retro-audit
Reviewer: Iris-QC (retro-audit)

## Substantive Findings - STORY-004

Run Key: 2026-08-12:REQ-001:STORY-004:retro-audit
Story: STORY-004

### AC-by-AC Traceability

| AC | Status | Evidence |
| --- | --- | --- |
| AC1 — single event reaches the app whether delivered via socket or FCM, feature layer doesn't need to know which path | PASS | `mobile/lib/core/realtime/realtime_coordinator.dart:172-177` `events({Set<String>? names})` filters only by `name`, never `transport` (comment at `cupid_realtime.dart:1-5` states this is the frozen contract rule). `mobile/test/core/realtime/realtime_coordinator_test.dart:205-278` group `RealtimeCoordinator dedup (ADR-012d, AC1/AC2)`: test `the same durable id delivered via the socket and via a queued FCM replay yields exactly one event` (line 206) and test `a foreground FCM message is discarded while resumed, and the socket event for the same id still arrives exactly once` (line 240) both directly assert `events.where((e) => e.id == ...)` has length 1. |
| AC2 — foreground/background transitions do not duplicate or drop events in test scenarios | PASS | `realtime_coordinator_test.dart:280-431` group `lifecycle transition machine (ADR-012g)`: test `resumed -> paused -> resumed (grace not elapsed) produces no duplicate and no dropped durable event, and preserves order` (line 281) and test `a background-injected event is drained on resume in order, followed by resync catch-up events, with no duplicate and no dropped durable event` (line 380) directly assert ordered, non-duplicated, non-dropped event delivery across foreground/background cycling, including a genuine FCM-only delivery case (`e2`, line 417-421, "no socket delivery for this id at all... genuine no-drop case"). |
| AC3 — socket connection sends the Firebase token in `handshake.auth.token` | PASS | `mobile/lib/core/realtime/socket_transport.dart:164-168`: `(io.OptionBuilder()...).setAuth({'token': initialToken}).build()` — `socket_io_client`'s `OptionBuilder.setAuth` populates the `auth` map that the vendor client sends as `handshake.auth` on connect, so the token lands at `handshake.auth.token` server-side exactly as the AC requires. Token-rotation on `_idTokenStream` (line 156-162) updates `_socket.auth` for the next handshake without forcing a reconnect. |
| AC4 — findings and resulting API surface documented for Tech Lead's ADR | PASS | `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-004_realtime_coordinator_spike/spike-findings.md` §1 "AC4 — Validated API Surface (Feature-Layer View)" documents the frozen `RealtimeCoordinator`/`RealtimeEvent`/`RealtimeStatus`/`RealtimeTransport` surface and what the harness proved about it; §3 "Primary Finding — Two-Tier De-Duplication (ADR-012d)" documents the durable-vs-ephemeral classification finding; §5 documents R8/R9/ADR-012h follow-ups explicitly carried forward for epic-2/epic-3 planning rather than silently dropped. `architecture/solution.md` §2 is cited as the authoritative ADR-equivalent contract document that `cupid_realtime.dart` matches verbatim (confirmed by direct code read — the exported members in `cupid_realtime.dart:18-42` match the findings doc's description one-for-one). |

### Design Fidelity

Not UI-bearing — the project-level `design-fidelity-config.json` names a locked `design_source` and has `ui_surface: true`, and the story's `Implementation Lane` is `mobile`, but this specific story renders no screen: direct inspection of `mobile/lib/core/realtime/` (`realtime_coordinator.dart`, `cupid_realtime.dart`, `realtime_event.dart`, `realtime_failure.dart`, `socket_transport.dart`) shows zero Flutter widgets, routes, or screens — the only Flutter import is `package:flutter/widgets.dart` for `AppLifecycleListener`, a non-UI lifecycle hook. `story_master.md` explicitly places "Feature-specific realtime UI (chat typing-ghost, anti-ghosting, reminders)" in **Out of Scope**, assigning it to epic-2/epic-3 stories instead. No Design Fidelity table is produced; this is a service-layer/core spike with no owned screen.

### Open Question Relevance

| OQ | Relevant? | Blocked Scope | Approval/Triage Source | Classification Impact |
| --- | --- | --- | --- | --- |
| R8 — backend Socket.IO gateway has no auth check (`chat.gateway.ts:39-57`) | Yes — this story's AC3 exists specifically as the client-side forward-compat mitigation for R8 | Backend auth enforcement (not this story's deliverable) | `conflicts_open_questions.md` "Decisions Still Needed From The User" row: explicitly scoped as "the actual backend fix requires a decision... Not required to unblock foundation/bootstrap work; must be resolved before epic-2 chat ships to production." Story correctly stays in scope (sends token) and correctly does NOT attempt the backend fix (Out of Scope section, `story_master.md`). Also re-escalated in `spike-findings.md` §5 and story_master.md "Open Items For Downstream Roles." | None — properly disclosed and escalated, not a silent scope cut |
| R9 — no backend FCM dispatch / no device-token registration | Relevant to AC1/AC2/AC4 real-device confirmation, not a central OQ registry item (Tech Lead risk from `req_master.md`) | Real-device background push confirmation (deferred, operator-run manual procedure) | `spike-findings.md` §4 records this as a typed, in-spec deferral with rationale (no backend dispatch to trigger the scenario), not silently dropped; `review/review-report.md` Risk Surface table marks it `DEFERRED (R9)`, not `PASS`, and states it "does not gate this story." Consistent handling — deferred with rationale, not a silent AC drop, and does not invalidate AC1/AC2 since those are proven by the in-process harness independent of the real-device leg. | None — typed deferral, correctly non-blocking per story's own scope statement |
| OQ5 — light theme & EN locale in v1 | No | N/A | N/A | N/A |

### OQ Discipline Findings

- No scope was silently cut or assumed because of an OQ. R8 is explicitly out of scope for this story (by design — client-side mitigation only, backend fix requires a separate decision) and is re-escalated in two places (`spike-findings.md` §5, `story_master.md` "Open Items For Downstream Roles"), consistent with the central OQ registry's framing of R8 as "not required to unblock foundation work; must be resolved before epic-2 chat ships to production."
- R9 (real-device background push) is a typed deferral with an explicit, reasoned rationale (`spike-findings.md` §4) rather than an unstated gap; the prior review (`review/review-report.md`) independently confirms this is tracked as `DEFERRED (R9)`, not silently marked PASS.
- No contract/data-model drift found that isn't already covered by an existing OQ or explicit story scope statement.

## Implementation Defects Or Unverified Behavior

- Independently reproduces prior review finding D5 (`review/review-report.md`): `realtime_coordinator.dart:353` force-unwraps `event.id!` in `_emitDeduped` for any non-ephemeral event; `_classifySocketEvent` (line 363-377) can yield `id: null` for a malformed/missing socket payload id, which would throw at runtime rather than degrade gracefully. Not exercised by the test harness and not a stated AC — hardening item, not an AC failure, consistent with the prior review's classification.
- No new defects found beyond what the prior review already recorded (D1-D5); this audit independently confirms AC1-AC4 pass on current code and tests, not by reusing the prior review's PASS claims.

Story-level Substantive Verdict: CLEAN
Classification Impact: GREEN
REVIEW_COMPLETE: YES
