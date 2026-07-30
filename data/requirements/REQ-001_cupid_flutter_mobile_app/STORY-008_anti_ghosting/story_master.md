# Story Master: STORY-008 Epic-2 — Anti-Ghosting Configuration

Status: PENDING
Complexity: S
Epic: epic-2 (communication)
Story-Class: standard
Requirement: REQ-001
Backend module: `backend/src/modules/ghost-config/`
Design reference: `cupid-mobile-design/` — chat/settings screen group (exact
screen ids to be confirmed by UI/UX Designer).

## Depends On
- STORY-001, STORY-002, STORY-003, STORY-004 (realtime signal for
  ghosting detection). Soft dependency on STORY-007 (chat is where
  ghosting is detected/surfaced).

## User Story
As a paired user, I want the app to help detect and surface when my partner
has gone quiet ("ghosting") per our agreed configuration, so silence doesn't
get misread as something worse.

## In Scope
- Configuring anti-ghosting thresholds/behavior per the `ghost-config`
  backend contract.
- Surfacing the anti-ghosting state/signal in the chat experience.

## Out of Scope
- Any `ghost-config` endpoint change (A1 frozen).
- The typing-ghost indicator itself (that's part of STORY-007's realtime
  chat scope) — this story is about ghosting *detection/config*, a distinct
  backend module.

## Acceptance Criteria
1. A paired user can view/set anti-ghosting configuration options exposed by
   the backend contract.
2. The configured anti-ghosting state is visibly surfaced somewhere in the
   chat experience (exact placement per UI/UX Designer).
3. Unpaired users cannot access this configuration.

## Role Completion

- [x] Architecture (Tech Lead) — `architecture/solution.md` v1.0 (ADR-1..ADR-6)
  and `coding-plan/` (master-plan + P0-P4 + coding-agent-guide), 2026-07-30.

## Open Items For Downstream Roles
- UI/UX Designer: confirm exact screen/placement for the anti-ghosting
  signal relative to STORY-007's chat screens.
- [DONE — Tech Lead] Architecture (Tech Lead): `architecture/solution.md`
  (v1.0, ADR-1..ADR-6) plus the shared coding plan at
  `coding-plan/master-plan.md` (P0-P4, mobile-only lane). Key decisions:
  ADR-1 — the data layer uses a hand-written repository over the shared
  `CupidApi.dio` rather than the generated
  `Epic23GhostConfigAntiGhostingApi`, because every generated ghost-config
  method is typed `Future<Response<void>>` (the backend declares no Swagger
  response schema) and would statically discard all three read bodies;
  precedent is `AuthRepository._syncBackendProfile`. ADR-2 — pull-model
  refresh only (screen entry, foreground resume, post-mutation refetch, and a
  single 60s timer live only while the chat row is visible and foregrounded),
  since `GhostConfigService.create()` only logs a stub and no FCM dispatch
  exists (STORY-004 R9); this resolves UX spec §6 item 3. ADR-3 — AC2's chat
  surfacing ships as an exported `GhostStateRow(partnerId:)` mount seam, not
  a chat-file edit, because `mobile/lib/features/chat/**` is STORY-007-owned
  and absent from this story's `BaseHead`; the one-line mount is a Scrum
  Master scheduling item for STORY-007 or requirement integration, and AC2
  end-to-end evidence is deferred to it. ADR-4 — State B vs State C is
  derived from `proposedBy` against `BackendUserIdStore`, presentation only,
  never as the authorization decision. ADR-5 — only `timeoutMinutes` (1-120)
  and the single-select `penalty` enum exist, so the mockup's
  public-countdown toggle, sound-override toggle, and custom emoji grid are
  dropped with nothing invented in their place (resolves UX §6 item 1).
  ADR-6 — no withdraw action, since the frozen contract has no cancel
  endpoint. Two constraints flagged for implementation: `HomeScreen` is still
  the foundation placeholder carrying the runtime registry readiness key
  `home_screen_ready_signal`, so its edit must be additive and preserve that
  key; and `service_locator.dart`, `cupid_icons.dart`, `home_screen.dart`,
  and both ARB files are shared with sibling parallel stories, so all edits
  are append-only. Requirement configuration guide: NOT_APPLICABLE (no env,
  secret, port, or registry change).
