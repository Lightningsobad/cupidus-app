# Retro Audit Report — STORY-002 api_client

Story: STORY-002 api_client (Requirement: REQ-001_cupid_flutter_mobile_app)
Story-Class: standard (ADR-010e, `architecture/solution.md`)
Implementation Lane: mobile (backend-client / non-UI plumbing)
Reviewer: Iris-QC (retro-audit)
Run Key: 2026-08-12:REQ-001:STORY-002:retro-audit

## Method

Independently re-verified against current `main` (control checkout, `BaseHead`
`f7d06fd4737cc7edbe6f6e33c205bf77fdf26f67`), not by re-reading the prior
CLEAN review report (used as context only per retro-audit rules):

- Read current source: `mobile/lib/core/network/cupid_api_client.dart`,
  `cupid_interceptor_slots.dart`, `cupid_error_interceptor.dart`,
  `cupid_api_failure.dart`, and test files
  `mobile/test/openapi/cupid_api_smoke_test.dart`,
  `mobile/test/core/network/cupid_interceptor_slots_test.dart`,
  `mobile/tool/generate_api_client.sh`.
- Confirmed tracked-file existence for the full Affected Components list via
  `git ls-files` (not treated alone as PASS evidence — combined with content
  read and execution below).
- Ran `flutter test` on the story's three test files directly
  (`test/openapi/cupid_api_smoke_test.dart`,
  `test/core/network/cupid_interceptor_slots_test.dart`,
  `test/core/network/cupid_error_interceptor_test.dart`): **10/10 passed**.
- Independently re-ran the full two-step generator
  (`npx @openapitools/openapi-generator-cli generate ...` then
  `dart pub get && dart run build_runner build --delete-conflicting-outputs`
  inside `mobile/openapi/cupid_api/`) against the vendored spec, then checked
  `git status --porcelain -- mobile/openapi/cupid_api mobile/openapi/cupid-api.json`:
  **empty** — genuinely idempotent regeneration on current `main`, not a
  re-read of stale evidence.
- Checked `git status --porcelain` for the whole repo before/after: only
  pre-existing unrelated changes (`scrum-master-checkpoint.md`,
  `retro-audit/` output dirs); no `backend/` drift, confirming AC4
  independently.

## AC-by-AC Traceability

| AC | Status | Evidence |
| --- | --- | --- |
| AC1 — Client code is generated (not hand-written) from the live `/api-docs` OpenAPI spec | PASS | `mobile/openapi/cupid-api.json` is a vendored 43,895-byte OpenAPI 3.0 document. `mobile/tool/fetch_openapi_spec.sh` (deliberate, live-backend fetch) and `mobile/tool/generate_api_client.sh` (offline, reads only the vendored file — read directly, confirms ADR-010c two-step split). Independently re-ran the offline generate step on current `main`: full `cupid_api` package (120 generated files incl. `lib/src/api/*.dart`, `lib/src/model/*.dart`, `.g.dart` outputs) reproduced byte-for-byte (see Method). No hand-edit markers found in `mobile/lib/core/network/` (the only hand-written layer). |
| AC2 — Every backend module in scope has typed models/methods available to feature stories | PASS | `git ls-files mobile/openapi/cupid_api/lib/src/api/` lists one generated API class per epic (`epic1_auth_api`, `epic1_invitations_api`, `epic1_love_contracts_api`, `epic1_users_api`, `epic2_communication_messages_api`, `epic3_daily_vibe_check_api`, `epic3_synced_alarms_api`, `epic23_ghost_config_anti_ghosting_api`, `epic4_love_pet_api`, `epic4_love_timeline_api`, `epic4_private_gallery_api`, `epic5_dream_jar_api`, `epic5_expenses_api`, `epic6_admin_configurations_api`, `epic6_data_export_api`, `uploads_api`, `app_api`) — a superset per ADR-010d's deliberate no-tag-filtering decision, with `admin`/`data-export` exclusion enforced at feature-story level as documented, not silently dropped. `test/openapi/cupid_api_smoke_test.dart` constructs a generated API class (`AppApi`) and a generated model (`CreateAlarmDto`, incl. `toJson()` round-trip) — independently re-run, both tests pass on current `main`. |
| AC3 — Regenerating the client from an unchanged spec produces no functional diff | PASS | Independently re-verified, not re-reading `test-results.md`/prior review: ran the complete offline pipeline (generator + `build_runner`) myself against the current `main` tree; `git status --porcelain` for `mobile/openapi/cupid_api` and `mobile/openapi/cupid-api.json` was empty afterward. Deterministic. |
| AC4 — No endpoint was added, removed, or changed to make generation work | PASS | `architecture/solution.md` records backend as read-only for this story (A1); `mobile/tool/generate_api_client.sh` operates only inside `mobile/`. Independently confirmed: repo-wide `git status --porcelain` before and after my regeneration run shows no `backend/` change. |

## Design Fidelity

`data/devops/system/design-fidelity-config.json` names a `design_source`
(`cupid-app-design-system`, `ui_surface: true` at project level). However,
STORY-002 owns zero UI/screen code: `architecture/solution.md` §4 "Affected
Components And Layers" lists only `mobile/openapi/**` (generated, non-UI),
`mobile/lib/core/config/cupid_api_config.dart`, and
`mobile/lib/core/network/*.dart` (Dio composition, interceptors, error
types) — no widget, no screen, no route. Confirmed by reading the four
hand-written `core/network/` source files directly: none import
`package:flutter/material.dart` widgets or render anything; `RequestContextInterceptor`
only sets HTTP headers. This matches the requirement's own scope statement
that API-client plumbing is "core client, no screens" (D5, `req_master.md`).
**Design Fidelity is NOT APPLICABLE for STORY-002** — confirmed by source
inspection, not asserted from the handoff note alone.

## Open Question Relevance

| OQ | Relevant? | Blocked Scope | Approval/Triage Source | Classification Impact |
| --- | --- | --- | --- | --- |
| OQ4 — Offline storage (Drift vs `hydrated_bloc`) | No | N/A — `architecture/solution.md` explicitly scopes Drift/ADR-007 as untouched by this story ("the generated client is stateless and cache-unaware") | RESOLVED (ADR-007) per `conflicts_open_questions.md` | None |
| OQ5 — Light theme & EN locale in v1 | No | N/A — no UI/i18n surface in this story | Deferred to `design_system` story per `conflicts_open_questions.md` | None |
| R8 — Socket.IO auth gap | No | N/A — this story is REST-only (ADR-006 scopes generation to REST; sockets are STORY-004) | Open, but blocking target is epic-2/STORY-004/007, not STORY-002 | None |
| D1/Critical-Alerts copy conflict | No | N/A — no alarm/notification UI in this story | Open, blocking target is `design_system`/epic-3 | None |
| Firebase service-account key exposure | No | N/A — no credential handling in this story (`architecture/solution.md` §5: "no credential handling in this story") | User decision recorded 2026-07-29 (rotate later, no agent action) | None |
| Nginx VPS-target ambiguity | No | N/A — deployment/devops scope, not client codegen | Open, unrelated lane | None |
| Mobile bundle id placeholder | No | N/A — app packaging, not this story's scope | Open, non-blocking | None |

No open question in `data/intake/bootstrap/conflicts_open_questions.md`
targets STORY-002's scope (API-client generation, interceptor pipeline,
error mapping). No scope was removed, assumed, or deferred in this story
under cover of an OQ.

## OQ Discipline Findings

- None. This story introduces no scope cut that depends on an OQ resolution
  either way.

## Implementation Defects Or Unverified Behavior

- None found. One notable positive: `cupid_interceptor_slots.dart`'s
  `diagnostics` slot now carries `LogInterceptor(requestHeader: false)` with
  an inline comment citing "ADR-011d, cross-story correction" and a
  dedicated test (`diagnostics token leak (ADR-011d)` in
  `cupid_interceptor_slots_test.dart`) proving the `Authorization` header
  value is never logged. This is a later cross-story fix layered onto
  STORY-002's files (a real security improvement — bearer tokens would
  otherwise have leaked to debug logs once STORY-003 populated the `auth`
  slot) and is functioning correctly on current `main`; it does not indicate
  a defect in STORY-002 itself, it indicates the codebase evolved correctly
  after handoff. No `get_it`/`injectable`/`freezed` were introduced (ADR-010f
  respected, confirmed by reading the four `core/network/` files — no such
  imports present).
- Contract boundaries from `architecture/solution.md` §2 hold on current
  `main`: single public import surface, `Dio` constructed only in
  `cupid_api_client.dart`, `CupidApi(..., interceptors: const [])` correctly
  suppresses the generated client's own default auth interceptors so the
  four named slots remain the sole auth plug point, slot order
  (`requestContext, auth, diagnostics, errorMapping`) matches the
  Interceptor Pipeline Contract exactly, and `CupidErrorInterceptor.onError`
  rethrows via `handler.next` (not `handler.resolve`) — errors are never
  swallowed.

## Substantive Findings - STORY-002

Run Key: 2026-08-12:REQ-001:STORY-002:retro-audit
Story: STORY-002

### AC-by-AC Traceability
| AC | Status | Evidence |
| --- | --- | --- |
| AC1 (spec generated, not hand-written) | PASS | Vendored spec + independently re-run offline generator, byte-identical output on current `main` |
| AC2 (typed models/methods for in-scope modules) | PASS | Generated API classes for every in-scope epic + independently re-run smoke test (2/2 pass) |
| AC3 (deterministic regeneration) | PASS | Independently re-ran full generate+build_runner pipeline; `git status --porcelain` empty |
| AC4 (backend untouched) | PASS | Repo-wide `git status --porcelain` before/after shows no `backend/` change |

### Design Fidelity
| Screen | Design Reference | Implemented Capture | Result | Deviation |
| --- | --- | --- | --- | --- |
| N/A | N/A | N/A | NOT APPLICABLE | Story owns zero UI/screen code — confirmed by reading `architecture/solution.md` §4 Affected Components and all four hand-written `core/network/*.dart` files (no widget/screen/route present) |

### Open Question Relevance
| OQ | Relevant? | Blocked Scope | Approval/Triage Source | Classification Impact |
| --- | --- | --- | --- | --- |
| OQ4 (offline storage) | No | N/A | RESOLVED (ADR-007) | None |
| OQ5 (light theme/EN) | No | N/A | Deferred to `design_system` story | None |
| R8 (Socket.IO auth gap) | No | N/A | Open, targets STORY-004/007 | None |
| D1/Critical-Alerts copy | No | N/A | Open, targets `design_system`/epic-3 | None |
| Firebase key exposure | No | N/A | User decision 2026-07-29 | None |
| Nginx VPS target | No | N/A | Open, devops lane | None |
| Bundle id placeholder | No | N/A | Open, packaging lane | None |

### OQ Discipline Findings
- No OQ-driven scope cut in this story; no discipline issue found.

Story-level Substantive Verdict: CLEAN
Classification Impact: GREEN
REVIEW_COMPLETE: YES
