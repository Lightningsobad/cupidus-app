# Story Master: STORY-002 API Client (generated from OpenAPI)

Status: DONE
Complexity: M
Epic: Foundation
Story-Class: standard (CONFIRMED by Tech Lead, ADR-010e — later stories consume
the merged output read-only and never write `mobile/openapi/**` or
`mobile/lib/core/network/**`)
Requirement: REQ-001

## Depends On
- STORY-001 (sequence recommendation per req_master proposed order; not a
  hard technical dependency — this story has no UI, tech-lead to confirm).

## User Story
As the Flutter codebase, it needs a generated, contract-locked HTTP client
from the backend's OpenAPI spec so every feature story consumes typed
endpoints instead of hand-written data-layer code (D5).

## In Scope
- Client generation pipeline from `/api-docs` (Swagger, `backend/src/main.ts`).
- Typed request/response models for all backend modules this requirement
  touches (excludes `admin`, `data-export` per req_master out-of-scope).
- Base HTTP client wiring (interceptor slots for auth — actual auth logic is
  STORY-003).

## Out of Scope
- Auth/token logic itself (STORY-003).
- Any backend endpoint change or addition — backend contract is frozen (A1).
  If generation reveals a gap needed for a later story, that is an escalation
  to Scrum Master, not a silent backend change.

## Acceptance Criteria
1. Client code is generated (not hand-written) from the live `/api-docs`
   OpenAPI spec.
2. Every backend module in scope (see `requirements.md` cross-story notes)
   has typed models/methods available to feature stories.
3. Regenerating the client from an unchanged spec produces no functional
   diff (repeatable/deterministic generation).
4. No endpoint was added, removed, or changed to make generation work.

## Open Items For Downstream Roles
- [DONE — Tech Lead] Architecture (Tech Lead):
  `architecture/solution.md` (v1.0, ADR-010a..f). Generator pinned to
  `openapi-generator-cli` `dart-dio` with `serializationLibrary:
  json_serializable` (ADR-010a); output is a committed local package
  `mobile/openapi/cupid_api/` consumed by a `path` dependency, never
  hand-edited (ADR-010b); pipeline is two-step — deliberate `fetch` from the
  live `/api-docs-json` plus fully offline, deterministic `generate` from the
  vendored `mobile/openapi/cupid-api.json` (ADR-010c, AC1 + AC3); the whole
  spec is generated without tag filtering, so `admin`/`data-export` exclusion
  stays a feature-story concern (ADR-010d, AC2). Base HTTP wiring is a
  four-slot ordered Dio pipeline (`requestContext, auth, diagnostics,
  errorMapping`); STORY-003 replaces only the `auth` slot occupant and must
  not reorder slots. No DI container, no `freezed`, no token logic in this
  story (ADR-010f). Story-Class `standard` CONFIRMED (ADR-010e).
  Implementation plan: `coding-plan/master-plan.md` (single `mobile` lane,
  P0-P4 sequential, phase detail inline in §6).
- [Tech Lead -> Scrum Master] Scheduling: STORY-003 must declare
  `Depends-On: STORY-002`; `mobile/pubspec.yaml` is a shared-file contention
  surface for the parallel lock scope.
- [Tech Lead -> Mobile Developer] P0 hard blocker: exporting the spec needs a
  bootable backend (`backend/service-account.json`). If unavailable, escalate;
  do not hand-write the spec (A1).
