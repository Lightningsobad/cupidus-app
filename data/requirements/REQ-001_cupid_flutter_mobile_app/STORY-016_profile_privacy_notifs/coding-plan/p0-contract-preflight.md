# P0 — Contract Preflight: RISK-1 Verification

Mode: mobile-implementation (P0 only)
Scope: REQ-001 / STORY-016_profile_privacy_notifs
Reference: `architecture/solution.md` §4.5 RISK-1, §5 P0

## RISK-1 — Result: REPRODUCED

`@IsUrl()` (no options) on `UpdateProfileDto.photoUrl`
(`backend/src/modules/users/dto/update-profile.dto.ts:37-40`) **rejects** the
bare-localhost URL format that `UploadsService.getUpdloadUrl`
(`backend/src/modules/uploads/uploads.service.ts:8-15`) produces under default
config (`HOST` unset → `localhost`, `PORT` unset → `3000`).

### How this was verified

A true HTTP end-to-end run (`POST /uploads` → `PATCH /users/me`) against a
live NestJS instance was attempted first and found **not runnable in this
environment**, independent of RISK-1 itself:

- `backend/src/main.ts:8-14` calls `require('../service-account.json')` and
  `admin.initializeApp(...)` unconditionally at bootstrap (Firebase Admin).
  `backend/service-account.json` is **absent** in this worktree — the process
  cannot boot at all without it.
- Full e2e would additionally require a running Postgres (`docker-compose.yml`
  service) and a valid Firebase JWT to pass the `firebase-jwt` `AuthGuard` on
  both `POST /uploads` and `PATCH /users/me`.
- Provisioning Firebase credentials, seeding a DB, or minting a Firebase JWT is
  DevOps/infra scope, not mobile-dev's, and none of it is confirmed to exist
  for local dev in this repo yet.

Given that, RISK-1 was verified directly against the **actual production
validator**, not a reimplementation: a standalone script loaded
`class-validator@0.14.3` (the exact version resolved by `backend/package.json`
`^0.14.3`, confirmed via the sibling main checkout's installed
`node_modules/class-validator/package.json`, since this worktree has no
`node_modules` installed), applied the bare `@IsUrl()` decorator (no options —
identical to the DTO's usage) to a probe class, and ran `validate()` against
the literal string shape `UploadsService.getUpdloadUrl` emits.

### Exact results

```
class-validator version: 0.14.3
{"url":"http://localhost:3000/uploads/test.jpg","valid":false,"errorConstraints":[{"isUrl":"photoUrl must be a URL address"}]}
{"url":"http://localhost/uploads/test.jpg","valid":false,"errorConstraints":[{"isUrl":"photoUrl must be a URL address"}]}
{"url":"http://api.example.com/uploads/test.jpg","valid":true,"errorConstraints":[]}
```

- `http://localhost:3000/uploads/test.jpg` (default-config upload URL,
  hostname + port, no TLD) — **rejected** by `@IsUrl()`.
- `http://localhost/uploads/test.jpg` (no port) — **rejected**, same reason.
- `http://api.example.com/uploads/test.jpg` (real TLD) — **accepted**.

This confirms class-validator's default `@IsUrl()` requires a TLD-bearing host
(`require_tld` defaults to `true`) and that bare `localhost` — with or without
a port — never satisfies it, matching the solution doc's prediction exactly.

### Conclusion

Under default local config (`HOST` unset), `POST /uploads` followed by
`PATCH /users/me { photoUrl: <upload URL> }` **will 400** on the second call.
This reproduces solution.md's RISK-1 as a real, currently-blocking contract
break for the avatar upload flow (§4.5, §5 P2), not a hypothetical.

Per solution.md's explicit instruction: this is an environment/config issue
(`HOST` needs to resolve to a TLD-bearing hostname, e.g. via a devops-owned
local dev domain or a real deployed host), **not** a client bug, and must
**not** be worked around by rewriting/validating the URL client-side. Scrum
Master should route a `HOST` config decision to DevOps before P2's avatar-flow
UI is built against a live upload, or P2 should stub/mock the avatar-save step
until the config lands.

BLOCKER-1 / BLOCKER-2 decision status (per solution.md §2, checked against
`requirements/requirements.md` per this handoff): the handoff states both are
now resolved — AC3 is device-local-only (option A) and AC2 is view-only
(option A) — but this P0 pass did not re-verify that document itself (out of
this handoff's stated scope, which is RISK-1 only). Confirm before P4 begins.

MOBILE_COMPLETE: YES
