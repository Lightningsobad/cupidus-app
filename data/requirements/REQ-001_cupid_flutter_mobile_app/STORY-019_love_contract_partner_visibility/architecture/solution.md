# Architecture Solution: STORY-019 — Love Contract Partner Visibility

Story: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-019_love_contract_partner_visibility/story_master.md`
Complexity: standard | Implementation Lane: shared (backend + mobile)
Context Mode: Brownfield | Run Mode: coding-plan (+ requested solution note)
Supersedes for this feature: STORY-006 `architecture/solution.md` ADR-006c
(creator-only capability), which the retro-audit ruled a build defect.

## 1. Key Discovery

Beyond the three defects in `story_master.md`, the current mobile sign flow
adds a fourth hazard that this architecture must close:
`LoveContractBloc._onSignHoldCompleted` calls `saveClauses()` (`POST
/love-contracts`) immediately before `sign()`. `LoveContractsService.create()`
upserts **by `requesterId`**. So the moment the partner can reach the sign
action, their hold gesture would create a *second* contract row with the
partner as requester, permanently splitting the couple's contract state. The
partner path must therefore be sign-only on the client, with a server-side
guard as the durable backstop (ADR-019e).

## 2. Published Contract

Authoritative: `architecture/contract-summary.md` (response shape, `viewerRole`,
`PATCH /love-contracts/sign` semantics, error codes). Do not restate it here.

## 3. Decisions

**ADR-019a — `partnerId` is denormalized at write time, with a lazy repair.**
`create()` reads the requester's `User.partnerId` (same pattern as
`dream-jar.service.ts:24-30`) and writes it onto the row. Because every row
already in the database has `partnerId = null`, and because pairing can happen
*after* contract creation, a single private resolver
`findContractForUser(userId)` is the only lookup used by both `getMyContract()`
and `sign()`. It resolves in strict precedence: (1) rows where the caller is
requester or partner, newest first; (2) only if none, the row where the
caller's own `User.partnerId` is the requester — and when that clause hits a
row with `partnerId = null`, it backfills `partnerId` once. Precedence order is
load-bearing: it guarantees a caller who owns a contract never gets resolved
onto their partner's row. No schema change, no migration (AC1).

**ADR-019b — reuse `PATCH /love-contracts/sign`, branch on the caller.**
Rejected: a separate partner route. The client cannot know its role until
*after* the fetch resolves, so a role-specific URL would make the sign action
depend on load order, and a second route would duplicate the resolver, the
idempotency rule, and the 404 case. The endpoint's user intent ("sign my side
of my contract") is identical for both parties; only the column written
differs. Path, method, and request body are unchanged, so the generated
`Epic1LoveContractsApi` client needs no regeneration.

**ADR-019c — "both signed" is derived from the two timestamps, never from
`status`.** No fourth enum value: `story_master.md` "Out of Scope" forbids new
statuses beyond `SIGNED_PARTNER`, and a `signed_both` value would need a
migration plus a backfill for a state the timestamps already express exactly.
`status` degrades to "who signed most recently" and is retained only for
existing backend queries; it is no longer a client state signal. This answers
`ux/uiux-spec.md` §4 with option (b).

**ADR-019d — the server computes `viewerRole`, the client does not.** The
mobile layer has no backend user id: the AC4 gate (`love_contract_gate_repository.dart`)
reads only `displayName` and `partnerId` from `GET /users/me`. Threading an id
through the gate, DI, bloc, and model to compare against `requesterId` is a
wider blast radius than one server-computed field, and it would put the
requester/partner decision in two places. `viewerRole` is added to every
love-contracts response, computed from the already-authenticated caller.
`LoveContract.fromJson` stays a pure function of its payload.

**ADR-019e — the partner never writes clauses.** Client: the bloc branches the
completed-hold handler — requester runs `saveClauses()` then `sign()`, partner
runs `sign()` only — and the screen hides the clause add/toggle affordances for
the partner viewer ("no renegotiation/editing flow for the partner"). Server:
`create()` throws `ConflictException` when the resolver shows the caller is the
partner of an existing contract. Both halves are required; the server guard is
what makes the split-state failure in §1 unreachable regardless of client
version.

**ADR-019f — editing clauses resets both signatures.** The existing upsert
already resets `signedAtRequester` when a signed contract is edited. With a
second signer, it must also null `signedAtPartner` and drop back to `CREATED`,
otherwise the partner stays bound to clauses they never signed.

## 4. Boundaries And Ownership

| Surface | Owner | Contract |
|---|---|---|
| `partnerId` population, resolver, backfill | backend-dev | ADR-019a |
| sign role branching, idempotency, 409 guard | backend-dev | ADR-019b/019e |
| `viewerRole` + timestamps in the response | backend-dev (authoritative) | `contract-summary.md` |
| viewer-aware `ContractSignStatus` mapping | mobile-dev | ADR-019c/019d |
| partner sign-only flow, clause read-only | mobile-dev | ADR-019e |
| AC4 pairing gate | unchanged — no lane may modify | STORY-006 |

## 5. AC4 Regression Guard (explicitly not weakened)

The gate is client-side and untouched: `love_contract_entry_tile.dart` hides
the entry for `partnerId == null` and `LoveContractGateRoute` re-asserts on
route open, failing closed. Nothing in this story reads or relaxes it. The new
server code cannot open a path for an unpaired user either: `partnerId` is
written only when `user.partnerId` is set, and clause (2) of the resolver
requires a non-null `User.partnerId` on the caller. Both lanes carry an
explicit AC4 regression test (P1, P3).

## 6. Risk Surfaces And Verification Contract

| Risk surface | Minimum gate | Blocker condition |
|---|---|---|
| Duplicate contract row via partner `POST` (§1) | P1 409-guard unit test + P2 bloc test asserting no `saveClauses` on the partner path | either test absent or failing |
| Resolver precedence picks the partner's row | P1 unit test: caller who owns a contract AND is partner on another resolves to their own | ambiguous resolution |
| Mislabeled sign state (AC3) | P2 unit tests over all 4 timestamp combinations x 2 viewer roles | any cell mapped to the wrong state |
| Signature survives a clause edit (ADR-019f) | P1 unit test asserting both timestamps null after edit | either timestamp retained |
| AC4 weakened | P1 unpaired-caller test + P3 existing entry-tile/gate tests still green | any gate test modified to pass |

Runtime registry ids: `backend-api` (build `npm run build`, test `npm test`),
`mobile-app` (test `flutter test`, build `flutter build apk --debug`).
No env var, secret, or third-party integration changes — no
`deployment/configuration-guide.md` update is owned by this story.

## 7. Assumptions

- **A-1 (mobile copy).** `ux/uiux-spec.md` §2 calls the both-signed visual
  "unchanged from STORY-006 §5 `bothSigned`", but that state was never
  implemented and has no l10n key: the signed card's status line is hardcoded
  to "waiting for partner", which is wrong once both have signed. P3 adds
  `loveContractBothSignedNamed`/`Neutral` for that line and keeps the existing
  `loveContractSignedByMe` heading. Low risk, no new visual component.
- **A-2.** `PartnerDisplayName` is already viewer-relative (each side's
  "partner" is the other person), so §3's `otherPartyName` needs no new
  plumbing; the Neutral fallback covers the unresolved-name case.

TECH_LEAD_COMPLETE: YES
