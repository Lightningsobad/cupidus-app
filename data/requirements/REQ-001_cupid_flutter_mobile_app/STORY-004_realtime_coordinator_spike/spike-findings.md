# STORY-004 Spike Findings — RealtimeCoordinator (Socket.IO + FCM)

Date: 2026-07-30
Phase: P5 (final verification phase)

## 1. AC4 — Validated API Surface (Feature-Layer View)

The frozen public contract this spike validated is `architecture/solution.md`
§2 (`RealtimeCoordinator`, `RealtimeEvent`, `RealtimeStatus`,
`RealtimeTransport`), exported from the single barrel
`package:cupid_mobile/core/realtime/cupid_realtime.dart`. That document is
authoritative for the exact member signatures; this section does not restate
them and instead records what the harness proved about that surface:

- `events({Set<String>? names})` yields a merged, deduped, broadcast stream.
  Feature code (STORY-007/008/009) filters by `names` and switches on `name`;
  it never needs to branch on `transport` — proven by the dedup harness in
  `test-results.md` §3, which asserts on `id`/`name` only.
- `status` reports `offline -> connecting -> live -> degraded` transitions
  driven by the real app lifecycle, with no feature-layer involvement.
- `start()`/`stop()` are idempotent; `emit()` is socket-only and throws
  `RealtimeNotLiveFailure` outside `RealtimeStatus.live` (ADR-012h).
- `resync()` is a manual bounded page-1 gap-fill, automatically invoked once
  on every foreground transition (including the very first `start()`, which
  is modeled as a resume) after the persisted queue drains.

Downstream stories consume this surface as-is; none of it is restated here as
a second source of truth (`architecture/solution.md` §2 is authoritative
per §2 of that document).

## 2. Harness Results

See `test-results.md` for the full command log and the AC1-AC3 named-test
table. Summary: `flutter test test/core/` is 58/58 green, `flutter analyze`
is clean, and `flutter build apk --debug` succeeds. Every risk surface in
`coding-plan/master-plan.md` §3A is `pass` except the real-device background
push confirmation, which is a typed, in-spec deferral (§4 below).

## 3. Primary Finding — Two-Tier De-Duplication (ADR-012d)

The spike's central finding, carried back into `system_architecture_memory.md`
by the architecture pass, is that "de-duplication by server-assigned id"
(system ADR-008) is not universally implementable against the frozen backend:

- **Durable** events (`Message`, `Alarm` — carry a server uuid) are the only
  ones FCM can ever re-deliver, and are the only ones the LRU seen-id set
  (512 entries) needs to cover. The dedup harness proves this exactly-once
  property holds across both the socket-vs-queued-FCM overlap case and the
  foreground-FCM-discarded case.
- **Ephemeral** events (`ghostTyping`, `ghostStopTyping`, `messageSeen`,
  `messageDelivered`, `emojiStormReceived` — no id at all) cannot be deduped
  by definition, so the design never tries: they are dropped outright while
  not foreground and never persisted to the pending queue (proven by
  `ephemeral events are dropped while not foreground and are never queued`
  and the equivalent `PendingEventStore`/`fcmBackgroundMessageHandler` tests).

This resolves ADR-008 with zero backend change: classification is by id
presence, not a hand-maintained event-name allowlist, so a new backend event
never silently becomes undeduped-durable or wrongly-dropped-ephemeral.

A secondary structural finding (ADR-012g.1): discarding foreground FCM
messages outright — rather than relying on the LRU to catch the duplicate —
is what makes AC2's no-duplicate property structural instead of luck-dependent
on dedup completeness. The harness's second dedup test isolates exactly this
by asserting the surviving event's `transport` is `socket`, never the
discarded FCM copy.

## 4. Manual Operator Procedure — Real-Device Background Confirmation (Deferred, R9)

**Status: deferred manual operator procedure, not a phase gate.** R9 means
there is no backend FCM dispatch (`admin.messaging()` is never called; every
push is a `console.log` stub — `ADR-012e`), so there is nothing to trigger
this scenario automatically, and real-device/emulator lifecycle runs are
outside this lane's test scope (`phase-P5-verification.md` §4A). The full
injection procedure — obtaining a device FCM registration token, authenticating
against the FCM HTTP v1 API with `backend/service-account.json`, and posting a
payload shaped per ADR-012f — is documented in
`../deployment/configuration-guide.md` §"FCM / APNs Setup And Test-Push
Injection (STORY-004)". The operator-run steps once that payload is sent:

1. Background the app (do not force-quit) so the socket disconnects after the
   ~30s grace window (`RealtimeStatus.degraded`).
2. Send one FCM HTTP v1 test push for a durable event (a `Message` or `Alarm`
   uuid) per the configuration-guide procedure.
3. Foreground the app.
4. Observe exactly one `RealtimeEvent` for that id reach the app (e.g. via a
   temporary `events()` listener or log line), and confirm no duplicate
   arrives from a subsequent REST resync reconciliation.

This is explicitly **not** an untested claim: the underlying mechanics (queue
persistence, drain-then-resync ordering, dedup gate) are all covered by the
in-process harness in `test-results.md` §3-4. What is deferred is only the
real Android/iOS OS-level backgrounding and real FCM delivery path, which
requires a physical/emulated device and manual FCM HTTP v1 injection — neither
of which this lane provisions or runs.

## 5. Follow-Up Items For Epic-2 / Epic-3 (None Block This Spike)

- **R8** — the backend Socket.IO gateway (`chat.gateway.ts:39-57`) has no auth
  check. This spike sends the Firebase token in `handshake.auth.token`
  regardless (AC3), so the client is already correct the day the backend
  enforces it, but epic-2 production readiness still needs a separate backend
  decision before chat ships to production.
- **R9** — no backend FCM dispatch and no device-token registration/storage
  (`alarms.service.ts:151-157`, `vibes.service.ts:35`, `ghost-config.service.ts:48`
  are all stubs). Background reminders (D1, epic-3) cannot ship until the
  backend adds token registration, storage, and `admin.messaging()` dispatch
  at those three stub sites. This is why §4 above is a deferred manual
  procedure rather than an automated gate.
- **ADR-012h** — `POST /messages` is Firebase-authenticated but
  `MessagesService.create` emits nothing to the socket
  (`messages.service.ts:13-16`), so routing chat writes over authenticated
  REST to sidestep R8 is not viable; it would silently stop realtime fanout to
  the partner. v1 keeps chat writes on the socket; `POST /messages` remains
  the documented no-fanout fallback.
- **Room-key typing gap (resolved in-plan, not a follow-up risk, recorded for
  awareness)** — `POST /auth/login` does return the backend `User.id`
  (`auth.controller.ts:15-21`), but the OpenAPI spec declares no response
  schema so the generated client types the call `Response<void>`. P2 reads the
  id from the shared `Dio` instance instead of the typed client. A later
  backend story could add the login response schema so the typed client
  exposes the id directly, removing the need for that workaround.

None of R8, R9, or ADR-012h block this spike; all three are carried forward
as Scrum Master escalations for epic-2/epic-3 planning, consistent with
`architecture/solution.md` §7 and `coding-plan/master-plan.md` §6.

## 6. Next Owner

STORY-007/008/009 can consume `RealtimeCoordinator` directly from
`architecture/solution.md` §2 and this document, without reading
`coding-plan/master-plan.md` or the individual phase files.
