# Contract Summary: love-contracts (STORY-019)

Authoritative cross-lane contract for STORY-019. Backend (`backend-api`) owns
it; mobile (`mobile-app`) consumes it. Supersedes the STORY-006 ADR-006c
creator-only contract.

## Response Envelope

All three endpoints return the contract row plus one computed field. Paths,
methods, and request bodies are unchanged from STORY-006 — the generated
`mobile/openapi` client needs no regeneration.

| Field | Type | Notes |
|---|---|---|
| `id` | string (uuid) | unchanged |
| `clauses` | string[] | unchanged |
| `status` | `created` \| `signed_requester` \| `signed_partner` | "who signed most recently". **Not** a client state signal (ADR-019c). No new enum value. |
| `signedAtRequester` | ISO string \| null | authoritative signal for the requester's signature |
| `signedAtPartner` | ISO string \| null | authoritative signal for the partner's signature |
| `viewerRole` | `requester` \| `partner` | **new.** Computed per request from the authenticated caller (ADR-019d) |
| `requesterId`, `partnerId`, `createdAt`, `updatedAt` | as today | not consumed by mobile |

## Endpoints

| Endpoint | Caller | Behavior |
|---|---|---|
| `GET /love-contracts/my-pending` | either party | Resolves via `findContractForUser`. Returns `null` when neither party has a contract. Backfills a null `partnerId` on a pre-pairing row (ADR-019a). |
| `PATCH /love-contracts/sign` (no body) | either party | Requester sets `signedAtRequester` + `status = signed_requester`; partner sets `signedAtPartner` + `status = signed_partner`. Idempotent: re-signing returns the row unchanged, never an error. `404` only when no contract exists for either party. |
| `POST /love-contracts` | **requester only** | `409 Conflict` when the caller is the partner of an existing contract (ADR-019e). Editing clauses on a signed contract resets `status` to `created` and nulls **both** timestamps (ADR-019f). |

## Client Derivation Rule (ADR-019c)

```
viewerSigned = viewerRole == requester ? signedAtRequester : signedAtPartner
otherSigned  = viewerRole == requester ? signedAtPartner   : signedAtRequester

both null                 -> unsigned
viewerSigned only         -> signedByMe
otherSigned only          -> partnerAlreadySigned   (new, uiux-spec.md §3)
both set                  -> bothSigned
```

Missing/unknown `viewerRole` falls back to `requester`, and any missing field
falls back to null — `fromJson` must still never throw.

## Consumer Obligations

- The partner path is sign-only: never `POST /love-contracts` when
  `viewerRole == partner`, and never show clause add/toggle affordances.
- `status` must not be read to pick a UI state.
- The AC4 pairing gate (`GET /users/me` → `partnerId`) is unchanged and must
  not be relaxed by either lane.
