# Test Results — STORY-006 Phase P0 (Backend: `partnerDisplayName` contract lock)

## Scope

Phase P0 — `phase-P0-users-me-partner-name-contract-lock.md`. Adds
`MeProfileResponseDto` (Swagger-only), `@ApiOkResponse` annotation on
`UsersController.getProfile`, and a new controller-level regression spec.
`users.service.ts` and `users.service.spec.ts` were not modified.

## Commands And Results

### Targeted unit tests

Command: `cd backend && npx jest src/modules/users`

```
PASS src/modules/users/users.service.spec.ts
PASS src/modules/users/users.controller.spec.ts

Test Suites: 2 passed, 2 total
Tests:       10 passed, 10 total
Snapshots:   0 total
Time:        0.988 s
```

- `users.service.spec.ts`: 7 pre-existing tests, unmodified, all pass —
  confirms `getProfileWithPartner` paired/unpaired/dangling-`partnerId`/null-
  `displayName` coverage is untouched.
- `users.controller.spec.ts`: 3 new tests, all pass — delegation to
  `getProfileWithPartner` (not `findByFirebaseUid`), `partnerDisplayName`
  present on the result, caller identity keys (`id`, `displayName`,
  `partnerId`, `isGhostModeEnabled`) preserved alongside it.

### Build / type-check

Command: `cd backend && npm run build`

```
> backend@0.0.1 build
> nest build
```

Exit code: 0. No TypeScript errors.

## Files Changed

- `backend/src/modules/users/dto/me-profile-response.dto.ts` (new) —
  `MeProfileResponseDto`, Swagger schema type only.
- `backend/src/modules/users/users.controller.ts` — added
  `@ApiOkResponse({ type: MeProfileResponseDto })` on `getProfile`; method body
  unchanged (still delegates to `usersService.getProfileWithPartner`).
- `backend/src/modules/users/users.controller.spec.ts` (new).

## Acceptance Criteria Verification

- `GET /users/me` documented in Swagger with `partnerDisplayName` and its
  nullable contract — DTO declares `partnerDisplayName: string | null` with
  the section-3 nullable semantics in its `@ApiProperty` description.
- Runtime response body unchanged — no interceptor, `plainToInstance`,
  `@Exclude`/`@Expose`, or serialization option introduced; `getProfile` still
  returns `this.usersService.getProfileWithPartner(req.user.uid)` directly.
- Controller-level spec fails if `getProfile` stops delegating to
  `getProfileWithPartner` or if `partnerDisplayName` disappears — asserted via
  `serviceMock.getProfileWithPartner` call check and `result.partnerDisplayName`
  assertion.
- `users.service.ts` and `users.service.spec.ts` untouched — confirmed by not
  editing either file; their existing 7 tests still pass unmodified.
