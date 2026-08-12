# P1 — Backend: partner resolution, partner signing, viewer role

Owner: backend-dev | Lane: backend | Depends On: NONE | Runtime id: `backend-api`
Contract: `../architecture/contract-summary.md` (authoritative — do not deviate)
Status: DONE

## 1. Goal

Make the paired partner a first-class party on the love contract: visible in
`getMyContract()`, able to sign, and identifiable to the client via
`viewerRole`. AC1, AC2, AC3 (server half), AC4 (regression guard).

## 2. Write Scope

- `backend/src/modules/love-contracts/love-contracts.service.ts`
- `backend/src/modules/love-contracts/love-contracts.controller.ts`
- `backend/src/modules/love-contracts/love-contracts.module.ts`
- `backend/src/modules/love-contracts/dto/love-contract-response.dto.ts` (new)
- `backend/src/modules/love-contracts/love-contracts.service.spec.ts`

## 3. Implementation

**Partner lookup.** The service needs the caller's `User` row. Inject the
`User` repository the way `dream-jar.service.ts` does
(`@InjectRepository(User)` + `TypeOrmModule.forFeature([LoveContract, User])`
in the module) rather than injecting `UsersService`; the module already imports
`UsersModule` for the controller, and the repository route keeps the service's
unit test a plain repository mock.

**`findContractForUser(userId)` (private, ADR-019a).** The single lookup used
by both `getMyContract()` and `sign()`. Strict precedence:

1. `findOne({ where: [{ requesterId: userId }, { partnerId: userId }], order: { createdAt: 'DESC' } })`.
2. Only if step 1 is empty: read the caller's `User`; if `user.partnerId` is
   set, `findOne({ where: { requesterId: user.partnerId }, order: { createdAt: 'DESC' } })`.
   If that row's `partnerId` is null, set it to `userId` and save once (lazy
   backfill for rows created before pairing or before this fix).

Precedence must not be reordered: a caller who owns a contract must always
resolve to their own row.

**`create()`.** Read the caller's `User` and set `partnerId: user.partnerId ??
null` on the new row. On the existing-row upsert path: if
`findContractForUser` shows the caller is the **partner** (not the requester)
of an existing contract, throw `ConflictException` (ADR-019e). When the
requester edits clauses on a contract in any signed state, reset `status` to
`CREATED` and null **both** `signedAtRequester` and `signedAtPartner`
(ADR-019f). Also backfill `partnerId` on the upsert path if it is still null
and the user is now paired.

**`sign()` (ADR-019b).** Resolve with `findContractForUser`; `404` only when
nothing resolves. Then branch on `contract.requesterId === userId`:
requester sets `signedAtRequester = new Date()` and `status =
SIGNED_REQUESTER`; partner sets `signedAtPartner = new Date()` and `status =
SIGNED_PARTNER`. If the caller's own timestamp is already set, return the row
unchanged without saving (idempotent, matching today's "already signed" return
rather than throwing). Never clear the other party's timestamp.

**Response DTO.** `LoveContractResponseDto.from(contract, viewerId)` returns
the row's fields plus `viewerRole: contract.requesterId === viewerId ?
'requester' : 'partner'`. All three controller actions return it; `my-pending`
still returns `null` when there is no contract. Keep the existing
`@ApiOperation` annotations and add the DTO as the documented response type.

## 4. Do Not

- Add a `ContractStatus` enum value, a column, or a migration.
- Add a partner-specific route, or change any existing path/method/body.
- Touch the AC4 pairing gate or any `users` module behavior.

## 5. Interfaces Published

`viewerRole` on every love-contracts response, and the sign/create semantics in
`../architecture/contract-summary.md`. P2 consumes these; do not rename.

## 6. Test Scope

`backend/src/modules/love-contracts/love-contracts.service.spec.ts` — extend
the existing repository-mock suite (add a `User` repository mock):

- `create` writes `partnerId` from the paired `User.partnerId`, and leaves it
  null for an unpaired requester.
- `create` throws `ConflictException` when the caller is the partner of an
  existing contract.
- `create` on a signed contract resets status to `CREATED` and nulls **both**
  timestamps.
- `getMyContract` resolves for the partner via the `partnerId` branch, and via
  the step-2 fallback + backfill when `partnerId` is null.
- Resolver precedence: a caller who is requester on one row and partner on
  another resolves to their own row.
- `sign` as requester sets `signedAtRequester`/`SIGNED_REQUESTER`; as partner
  sets `signedAtPartner`/`SIGNED_PARTNER` and preserves
  `signedAtRequester`.
- `sign` is idempotent for a party that already signed.
- `sign` throws `NotFoundException` for an unpaired caller with no contract
  (AC4 regression guard).
- `viewerRole` is `requester` for the creator and `partner` for the other side.

Gate: `cd backend && npm test -- love-contracts` green and `npm run build`
clean. Record evidence in `coding-plan/test-results.md` before
`BACKEND_COMPLETE: YES`. No e2e, no runtime startup smoke.
