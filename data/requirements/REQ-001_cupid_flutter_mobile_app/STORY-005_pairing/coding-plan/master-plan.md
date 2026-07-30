# Coding Plan: STORY-005 Pairing (Epic-1 1:1 connection)

Scope: REQ-001 / STORY-005_pairing · Complexity M · Story-Class standard
Implementation lane: **mobile-dev only** (confirmed — see D1/D4; no backend
change is required and none is permitted, `invitations` is A1-frozen).
Runtime registry id: `mobile-app` (`data/devops/system/runtime-command-registry.json`).
Configuration impact: **none** — no new env var, secret, or third-party
integration, so `deployment/configuration-guide.md` is not downstream.

Note on artifact shape: the handoff `WriteScope`/`OutputPath` for this run
authorize only this file, so phase detail is inline here instead of in
`phase-P*.md` files. Widen WriteScope if separate phase files are required.

## 1. Resolved Decisions (the four UX-spec §7 open items)

### D1 — Inviter `waiting` → `paired` transition: **poll `GET /users/me`**

Decision: the `waiting` screen polls `GET /users/me` and transitions to
`paired` when `partnerId` is non-null. Foreground-only, bounded, with a manual
refresh affordance retained per UX §7.

Rejected alternative — socket/FCM via the STORY-004 `RealtimeCoordinator`:
the coordinator exists (`mobile/lib/core/realtime/`) but has **no backend event
source for pairing**. STORY-004 `spike-findings.md` §5 records R8 (the
Socket.IO gateway `chat.gateway.ts` has no auth) and R9 (no backend FCM
dispatch, no device-token registration). `invitations.service.acceptInvitation`
emits nothing. Wiring a `pair.established` event would require changing the
A1-frozen `invitations` module plus gateway auth work — both out of scope.
Polling is the only mechanism reachable from the mobile lane alone.

Poll contract (fixed, do not improvise): interval 3s for the first 60s, then
10s; hard stop at 10 minutes or at code `expiresAt`, whichever is sooner; stop
immediately on `partnerId != null`, on screen dispose, and on app background;
resume on foreground. Poll failures are silent (keep waiting, do not surface a
transient error); only a terminal stop surfaces the manual-refresh fallback.

### D2 — Couple-type picker + "Continue → Fingerprint Vow" CTA: **excluded**

Confirmed out of scope. No AC covers them and the `invitations` module has no
couple-type endpoint. `invite` is scoped to the code-display + share/copy card
only. Do not build them; do not stub them.

### D3 — Unpair / leave flow: **confirmed absent from the backend**

`invitations.controller.ts` exposes exactly `POST /invitations/generate`,
`POST /invitations/accept`, `POST /invitations/validate`, and two debug GETs
(`test-generate-debug`, `test-validate-debug`). There is no unpair/leave/delete
endpoint and `users.controller.ts` has no partner-clearing route. Per
`story_master.md`'s own open item this is flagged forward to Scrum Master / PO,
**not** assumed: no unpair UI is planned in this story.

### D4 — Generated-client typing gap: **hand-construct via the shared `Dio`**

Confirmed: every `Epic1InvitationsApi` method returns `Future<Response<void>>`
and `invitationsControllerAccept`/`Validate` take no `code` parameter, so the
generated client cannot send the required body or read `code`/`expiresAt`.

Decision: follow the precedent already set in STORY-003
(`mobile/lib/features/auth/data/auth_repository.dart:94-112`) — call
`_api.dio.post<Object?>('/invitations/...')` from a feature repository and
parse the body by hand. This keeps `CupidAuthInterceptor` and
`CupidErrorInterceptor` (`CupidApiFailure` mapping) in the path.

Rejected alternative — regenerate against a corrected OpenAPI spec: it requires
editing Swagger decorators inside the A1-frozen `invitations` module and
regenerates the shared `mobile/openapi/cupid_api` package used by every lane.
Recommend a separate backlog item for documentation-only Swagger enrichment;
it does not belong in this story.

## 2. Contracts Used

| Call | Request | Success shape used | Failures mapped |
|---|---|---|---|
| `POST /invitations/generate` | none (bearer) | `code` (6 upper-hex), `expiresAt` (ISO, 24h TTL) | generic |
| `POST /invitations/accept` | `{ code }` | `{ success: true }` | 404, 400, 409×3 |
| `GET /users/me` | none (bearer) | `partnerId` (nullable), partner display fields | generic |

`POST /invitations/validate` is **not** used. UX §5 marks the "about to pair
with {name}" preview as optional polish and warns it cannot confirm success;
omit it to avoid a misleading pre-check.

Error mapping owner is P0. The three 409s are distinguished by response
`message` (`You are already paired with a partner`, `Cannot invite yourself`,
`This person is already paired with a partner`) into distinct sealed failure
cases, then rendered per UX §5. Never surface a raw backend string.

## 3. Phase Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|---|---|---|---|---|---|---|---|---|---|
| P0 | mobile-dev | mobile | NONE | NO | `mobile/lib/features/pairing/data/**`, `mobile/lib/core/di/service_locator.dart`, `mobile/test/features/pairing/data/**` | §1 D1/D4, §2 | `pairing_repository.dart`, `pairing_invitation.dart`, `partner_link.dart`, `pairing_failure.dart`, `partner_link_poller.dart`, DI registration | `flutter test` unit: body parse, 6-hex code, `expiresAt`, each 409 → distinct failure, poll stop conditions | DONE |
| P1 | mobile-dev | mobile | P0 | NO | `mobile/lib/features/pairing/presentation/pair_gate_cubit.dart`, `mobile/lib/app/cupid_app.dart`, `mobile/lib/core/navigation/app_shell.dart`, `mobile/test/features/pairing/presentation/pair_gate_cubit_test.dart` | UX §6, AC4 | shell-level paired/unpaired gate + pairing-stack routes + discoverable "Pair with your partner" entry action | `flutter test` widget: unpaired → pairing stack and no tab bar; paired → tab shell; entry action reachable | DONE |
| P2 | mobile-dev | mobile | P0, P1 | YES (with P3) | `mobile/lib/features/pairing/presentation/screens/invite_screen.dart`, `waiting_screen.dart`, `invite_cubit.dart`, `waiting_cubit.dart`, `mobile/test/features/pairing/presentation/invite_*` | UX §3, §7, AC1 | inviter path: code card, live `expiresAt` countdown, share/copy, → `waiting` + poll wiring | `flutter test` widget: idempotent re-generate does not flash, countdown from `expiresAt`, copy announces, poll → `paired` | PENDING |
| P3 | mobile-dev | mobile | P0, P1 | YES (with P2) | `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart`, `joincode_cubit.dart`, `mobile/lib/features/pairing/presentation/pairing_strings.dart`, `pairing_failure_text.dart`, `mobile/test/features/pairing/presentation/joincode_*` | UX §4, §5, AC2, AC3 | invitee path: single-field 6-char entry, "Pair up", inline error for all five conditions | `flutter test` widget: success → `paired`; each failure renders its vi/en line inline, button re-enables, no modal | PENDING |
| P4 | mobile-dev | mobile | P2, P3 | NO | `mobile/lib/features/pairing/presentation/screens/paired_screen.dart`, `mobile/test/features/pairing/presentation/paired_screen_test.dart` | UX §4, §8, §9 | shared celebration screen, both arrival paths converge, decorative animation excluded from semantics | `flutter test` widget: reachable from both paths, live-region announce on auto-navigation | PENDING |
| P5 | mobile-dev | mobile | P4 | NO | `mobile/test/**`, story `test-results.md` | all ACs | AC→test traceability, `flutter analyze` + `flutter test` green | `flutter analyze`, `flutter test` (full suite) | PENDING |

Phase-file rule: each id above is canonical; no duplicate `P{id}` planned.

## 4. Cross-Phase Invariants

- P0 owns every HTTP call and every failure classification. P2/P3/P4 must not
  touch `Dio`, string-match backend messages, or construct paths.
- Copy corrections from UX §3 are binding: render the code as returned (6
  uppercase hex, no dash), say "6-character code", and drive expiry from
  `expiresAt` (24h) — never the mockup's "15 minutes" string.
- No new design tokens, icons, or animation primitives (UX §8). Reuse STORY-001
  components and the STORY-003 inline-error and button-disable patterns.
- The pairing code is one accessible string; the joincode input is one
  accessible field behind six visual boxes (UX §9).

## 5. Verification Contract

| Risk surface | Minimum gate | Blocker |
|---|---|---|
| Invitation body parse / typing gap (D4) | P0 unit tests over recorded response bodies | wrong-shaped parse or `Response<void>` reintroduced |
| Couple-only enforcement (AC3) | P3 widget test per 409 case | any backend message shown raw, or a case falling through to a generic error |
| Poll lifecycle (D1) | P0 unit + P2 widget test | unbounded poll, poll surviving dispose/background, or battery-unsafe interval |
| Shell gating (AC4) | P1 widget test | any paired-only surface reachable while unpaired |

Excluded by policy: backend e2e, Playwright/browser e2e, traces, scenario
reruns, repository-root script gates, and runtime startup smoke.

## 6. Open Items Escalated (not resolved in this plan)

- **D3 unpair/leave** — no backend support. Needs PO/Scrum Master decision on
  whether a future story adds the endpoint. Blocks nothing in STORY-005.
- **D2 couple-type picker** — needs PO confirmation that it belongs to a
  separate story, per UX §7.
- **Swagger enrichment for `invitations`** — backlog candidate arising from D4;
  not actionable inside this A1-frozen scope.

PLAN_COMPLETE
