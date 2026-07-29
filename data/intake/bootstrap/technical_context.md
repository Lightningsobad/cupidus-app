# Technical Context

Normalized from S1-S5 (see `source_register.md`). This is the confirmed
technical baseline; Tech Lead should write the ADR/system architecture memory
from this table, not rediscover the option space.

## Architecture Decisions Already Closed (D0-D5)

| # | Decision | Content | Consequence |
|---|----------|---------|-------------|
| D0 | Client platform | Flutter, replacing native iOS (SwiftUI) | `_bmad-output/planning-artifacts/architecture.md` client section is SUPERSEDED |
| D1 | Alarms | v1 only needs strong-enough sync reminders, not real system alarms | No Critical Alerts entitlement request; no native alarm module; epic-3 wording changes to "nhắc nhở đồng bộ" |
| D2 | State management | Bloc (Cubit for CRUD screens, full Bloc for rituals + realtime) | Pair with `freezed` + `get_it`/`injectable`; `bloc_test`; consider `hydrated_bloc` |
| D3 | Adaptive UI | Follow design, keep iOS/Material variants | One widget tree + `ThemeExtension` (platform × theme) + 4 named adaptive widgets; no per-screen forking |
| D4 | Package archetype | Pragmatic Feature-First, single package (converged via PMI) | Defer melos monorepo and Pigeon until actually needed |
| D5 | API client | Generated from OpenAPI (Swagger already enabled at `backend/src/main.ts`, `/api-docs`) | Removes most hand-written data layer; locks client-server contract |

## Existing Backend (Frozen Contract, A1)

- NestJS app at `backend/` — has its own nested `.git` (separate history from
  repo root).
- ~59 REST endpoints, 2 Socket.IO gateways, Firebase Auth.
- OpenAPI/Swagger enabled at `backend/src/main.ts`, served at `/api-docs`.
- Per-epic backend behavior documented at `docs/backend/backend/epic-{1..6}-*.md`.
- Backend package manifest, Dockerfile, `docker-compose.yml`, and nginx config
  already exist under `backend/`.
- Constraint A1: client work must not require backend contract changes.

## Existing Design Source

- `cupid-mobile-design/` — read-only prototype (`Cupid Screens.dc.html`,
  `Cupid App.dc.html`, `android-frame.jsx`, `ios-frame.jsx`, icon/sprite
  assets). ~31 screens, iOS + Material variants, dark + light themes, VI + EN
  copy. Treated as the UX source of truth for the new client; do not edit.

## Runnable Foundation Status (as observed at bootstrap start)

- Repository root (`cupid-apps`) has **zero git commits** — `git log` fails
  with "does not have any commits yet". All top-level content
  (`.gitignore`, `.mcp.json`, `_bmad-output/`, `backend/`, `cupid-mobile-design/`,
  `data/`, `docs/`) is untracked at the root.
- No `scripts/setup.sh`, `scripts/build.sh`, `scripts/start-dev.sh`, or
  `scripts/start-prod.sh` at repo root.
- No `data/devops/system/runtime-command-registry.json`.
- No Flutter mobile app project exists yet anywhere in the repo — only the
  design prototype (`cupid-mobile-design/`) and the old superseded
  `_bmad-output/` planning corpus.
- Backend (`backend/`) itself appears runnable in isolation (package.json,
  Dockerfile, docker-compose.yml present) but is not wired into any root-level
  script or runtime registry entry yet.

## Proposed Foundation Build Order (exploratory — Tech Lead confirms in ADR)

1. `design_system` + tokens (platform × theme) + i18n ARB — shared-foundation,
   before any feature work (risk R7: high impact if deferred).
2. `api_client` generated from OpenAPI `/api-docs` (D5).
3. Firebase auth + refresh-token interceptor.
4. Spike `RealtimeCoordinator` (unifies Socket.IO + FCM foreground/background)
   — highest risk item, R2.
5. Feature work by epic-1 → epic-6 (excluding admin/data-export).

## Risk Table (Impact / Mitigation)

| Risk | Impact | Effort to mitigate | Action |
|------|--------|--------------------|--------|
| R2 socket/FCM unification | High | Medium | Spike `RealtimeCoordinator` first |
| R7 design_system done late | High | Low | Foundation story first, before any feature |
| R6 Bloc/Cubit discipline | Medium | Low | Lock conventions + lint in ADR |
| R3 libsodium FFI | Medium | Medium | Spike dual-platform build early, before epic-4 |
| R4 low-end Android perf | Medium | Low | Benchmark on one low-end Android device |
| R1 alarm scope (already reduced) | Low | Low | PO wording fix only (epic-3) |
| R5 UI drift | Low | Low | Golden tests for atoms + ~6 representative screens |
| R8 Socket.IO auth gap (new, from Tech Lead system-foundation) | High (production) | N/A — client cannot fix, backend A1 frozen | Client sends Firebase token in `handshake.auth.token` now (forward-compatible); backend fix is a user decision, see `conflicts_open_questions.md` — must resolve before epic-2 ships to production |

## Architecture Foundation Update (post Tech Lead system-foundation pass)

- System Architecture Memory: `data/architecture/system/system_architecture_memory.md`
  (ADR-001..ADR-009). D0-D5 codified as ADR-001..005; ADR-006 narrows D5 —
  the generated OpenAPI client covers **REST only**; both Socket.IO gateways
  are absent from the OpenAPI doc, so the realtime layer (`RealtimeCoordinator`)
  stays hand-written. Chat `SEND_MESSAGE` is socket-only (no REST send
  endpoint) — epic-2 is hard-blocked on the RealtimeCoordinator spike, not
  merely improved by it (raises R2 scheduling weight).
- ADR-007 resolves OQ4 (see `conflicts_open_questions.md`).
- ADR-009: Mobile scaffold target confirmed as `mobile/` at repo root, Dart
  package `cupid_mobile`, feature-first layout (`lib/core/`,
  `lib/design_system/`, `lib/features/<feature>/{data,domain,presentation}/`),
  vendored OpenAPI spec at `mobile/openapi/cupid-api.json` (backend requires
  `service-account.json` to boot, so the client cannot generate against a live
  server — spec must be vendored).
- Backend confirmed: 16 modules under `backend/src/modules/`, no global route
  prefix, Swagger UI at `/api-docs`, spec JSON at `/api-docs-json`, bearer
  scheme id `firebase-jwt`.
- Naming trap for Product Owner: backend module/gateway is literally named
  `alarms` (`TRIGGER_ALARM` events). Per D1/ADR-002 the transport name stays;
  the "alarm" wording must not leak into UI copy ("nhắc nhở đồng bộ" only).
- Foundation build order (confirmed, supersedes the earlier exploratory list
  above): **F0** runnable foundation (initial commit + mobile scaffold + root
  scripts + runtime registry — prerequisite because `git-story-boundary.sh`
  needs a `BaseHead`) -> **F1** design_system + i18n -> **F2** api_client ->
  **F3** auth -> **F4** RealtimeCoordinator spike -> **F5** Drift persistence
  (new, before epic-2) -> **F6** epics 1-6.
- Runtime registry will need ids `backend-api` and `mobile-app` (DevOps,
  not yet created).
