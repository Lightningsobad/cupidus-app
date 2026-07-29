# Story Master: STORY-002 API Client (generated from OpenAPI)

Status: PENDING
Complexity: M
Epic: Foundation
Story-Class: standard (recommend Tech Lead re-evaluate as shared-foundation
in coding-plan if many later stories touch generated client internals
concurrently)
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
- Tech Lead: pick and pin the OpenAPI generator tool/config in the ADR;
  confirm whether this story should be reclassified `shared-foundation` for
  parallel scheduling purposes.
