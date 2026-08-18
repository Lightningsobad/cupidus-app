# Cross-Lane Contract — REQ-002 / STORY-052 `GET /users/me` partner identity

Authoritative source: `backend/src/modules/users` (STORY-052 phase P0).
Consumers: `mobile/lib` (STORY-052 phase P1) — `ChatPartnerStore`, which feeds
the chat header pairing title and the presence chip.

## 1. Envelope

Unchanged envelope: the existing authenticated `GET /users/me`, which already
returns the caller's own `users` row as a bare JSON object (no wrapper, no
`data` envelope). One key is appended; nothing else moves.

```json
{
  "id": "3f1c…",
  "displayName": "Minh",
  "partnerId": "9ab2…",
  "partnerDisplayName": "Linh",
  "isGhostModeEnabled": true
}
```

Matching is textual on the JSON key. The generated Dart client models this path
as `Response<void>` and is **not** used here, so a key mismatch produces no
build error on either side — it surfaces as a silently `null` field and a
degraded header. That silence is why the key spelling rule below matters.

## 2. Identifiers — copy exactly

| Purpose | Identifier | Bound config key / route |
|---------|------------|--------------------------|
| Caller's own name | `displayName` | `GET /users/me` |
| Paired partner's name | `partnerDisplayName` | `GET /users/me` |
| Paired partner's id | `partnerId` | `GET /users/me` |

Rules for the consumer side:

- `partnerDisplayName` is exact-spelling, lowerCamelCase. Near-misses that fail
  silently: `partner_display_name`, `partnerName`, `partnerDisplayname`.
- Append-only: do not reorder or rename any existing key. `displayName` keeps
  its current meaning — **the caller's own name**. Do not "fix" it to mean the
  partner; three existing readers depend on the current meaning
  (`love_contract_gate_repository.dart`, `couple_pairing_store.dart`,
  `chat_partner_store.dart`).
- Do not read partner identity from `PartnerDisplayName`
  (`core/di/service_locator.dart:75`). That provider is registered as
  `() => null` and is superseded for chat by this contract.

## 3. `GET /users/me` — the two identity fields

| Order | Key | Rendered/exposed as | Value contract |
|-------|-----|---------------------|----------------|
| existing | `displayName` | `ChatPartnerStore.selfDisplayName` | `string \| null`. The caller's own name. Unchanged by this story. |
| new | `partnerDisplayName` | `ChatPartnerStore.partnerDisplayName` | `string \| null`. The paired partner's `displayName`. |

- The backend owns resolution and returns `null` — never an error, never an
  empty string, never a placeholder — in all three of these cases: `partnerId`
  is null (unpaired); `partnerId` points at a row that no longer exists; the
  partner row's own `displayName` is null.
- The backend does not trim, title-case, or otherwise normalize either name.
  Presentation-only transforms (first-character uppercase for the chip avatar
  initial) belong to the mobile lane.
- No other partner field is exposed. The partner's `email`, `firebaseUid`,
  `photoUrl`, and remaining columns stay server-side.
- A missing key must be treated as `null` by the consumer, not as an error.

## 5. Deploy / rollout order

Backend first, but neither ordering breaks. Old client + new backend: the extra
key is ignored by every existing `Map` read. New client + old backend:
`partnerDisplayName` is absent, the consumer reads `null`, and the header
degrades to exactly what it renders today. Both directions are silent and safe,
so this is a sequencing preference for verification, not a release gate.

## 6. What the consumer must NOT do

- Do not keep a bare `ChatPartnerStore.displayName` getter alive after the
  split. Its whole purpose is to force every call site through the compiler; a
  compatibility alias reintroduces the exact silent self-for-partner defect this
  contract exists to remove.
- Do not derive the partner name from `partnerId`, from the local session, or
  from any invitation-time value.
- Do not treat `null` as "loading". The store exposes a plain synchronous
  getter with no pending state; `null` means "no partner name available".
