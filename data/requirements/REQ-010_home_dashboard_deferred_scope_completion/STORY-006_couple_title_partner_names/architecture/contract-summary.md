# Cross-Lane Contract — REQ-010 STORY-006 Partner Display Name On `GET /users/me`

Authoritative source: `backend/src/modules/users` (STORY-006 phase P0).
Consumers: `mobile/lib/features/account/domain` + `mobile/lib/features/home`
(STORY-006 phase P1 — the couple title and partner avatar initial).

## 1. Envelope

Unchanged: `GET /users/me`, Bearer `firebase-jwt`, JSON object body. The
response is the caller's user row spread flat, plus one resolved partner key at
the same top level (no nested `partner` object):

```json
{
  "id": "user-123",
  "displayName": "Minh",
  "partnerId": "partner-456",
  "partnerDisplayName": "Linh",
  "coupleType": "SAME_CITY",
  "relationshipStartDate": "2024-01-01",
  "isGhostModeEnabled": true
}
```

Matching is textual: the consumer reads the key by literal string. A rename or
a dropped key produces **silent loss**, not a build or runtime error — the
mobile side maps it as `String?` and a missing key reads as `null`, which is a
legal AC3 state. Nothing fails loudly. That is why phase P0 exists.

## 2. Identifiers — copy exactly

| Purpose | Identifier | Bound config key / route |
|---------|------------|--------------------------|
| Partner's display name | `partnerDisplayName` | `GET /users/me` response, top level |
| Caller's display name (existing) | `displayName` | `GET /users/me` response, top level |
| Pairing presence (existing) | `partnerId` | `GET /users/me` response, top level |

Rules for the consumer side:

- Exact spelling `partnerDisplayName`. Near-misses that compile and silently
  read `null`: `partnerDisplayname`, `partner_display_name`, `partnerName`.
- Do not derive the partner's name from `partnerId` — it is an opaque id, not
  a name, and must not be rendered.
- Do not read the partner name from `ChatPartnerStore`
  (`mobile/lib/features/chat/data/chat_partner_store.dart`). It hydrates the
  same key but is chat-session-scoped state with its own clear/reset lifecycle;
  the Home header must read the profile response it already awaits.

## 3. `GET /users/me` partner fields

| Order | Key | Rendered/exposed as | Value contract |
|-------|-----|---------------------|----------------|
| 1 | `partnerDisplayName` | Second name in the couple title; source of the partner avatar initial | `string \| null`. `null` when the caller is unpaired, when `partnerId` points at a deleted row, or when the partner has no `displayName`. Never an empty-string sentinel from the backend, but the consumer must treat `""` as equivalent to `null`. |

- The backend owns resolution only. It does **not** trim, title-case, initial-ise,
  or compose the `"A & B"` string — all formatting is the consumer's.
- A missing key, an explicit `null`, and `""` are one single degraded state on
  the consumer side (AC3): render the caller's own name alone, with no `&`
  separator and no partner avatar initial.
- Extra keys on the response are ignored by the consumer; the read model maps
  only what it declares.

## 5. Deploy / rollout order

No ordering constraint. `partnerDisplayName` already ships in the deployed
`GET /users/me` response (`users.service.ts:30-40`), so the mobile consumer is
correct against both the current and the P0-hardened backend, and P0 is correct
with or without the mobile change. Wrong order is not observable in either
direction — the only failure mode is the silent-loss case in section 1, which
P0's controller spec is what prevents.

## 6. What the consumer must NOT do

- Must not substitute a placeholder (`"Partner"`, `"…"`, `"?"`) or the
  `partnerId` when the name is absent — AC3 and `ux/uiux-spec.md` §6.7 forbid it.
- Must not render an `&` separator with only one resolved name.
- Must not treat an absent partner name as an error state (no toast, banner,
  inline message, or retry affordance).
- Must not issue a second request to resolve the partner name.
