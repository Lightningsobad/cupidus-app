# Cross-Lane Contract — REQ-011 Zodiac Red Flag Today

Authoritative source: `backend/src/modules/zodiac` (STORY-001).
Consumers: `mobile/lib/features/zodiac` STORY-001 (screen + degraded state);
`mobile/lib/features/home` STORY-002 (pushes `ZodiacRedFlagScreen` only — it
does not call this endpoint).

## 1. Envelope

`GET /zodiac/red-flag/today`, `@UseGuards(JwtAuthGuard)`, no query params, no
request body. Always HTTP `200` for an authenticated caller — the
incomplete-profile case is a payload state, not a 4xx. `401` only for a missing
or invalid token; `500` only for an unexpected server fault.

The body is a discriminated union on `status`. Matching is textual on the
`status` string; an unrecognised `status` must be treated by mobile as
`incomplete_profile` (fail honest), never as `ready`.

```json
{
  "status": "ready",
  "contentDate": "2026-08-25",
  "conflictIndex": { "score": 7, "scoreMax": 10, "headline": "…", "body": "…" },
  "partners": [
    { "role": "self",    "displayName": "Minh", "zodiacSign": "cancer" },
    { "role": "partner", "displayName": "Linh", "zodiacSign": "pisces" }
  ],
  "dailyTips": [
    { "id": "tip-04", "icon": "videocam",   "tint": "mint",  "title": "…", "body": "…" },
    { "id": "tip-09", "icon": "block",      "tint": "pink",  "title": "…", "body": "…" },
    { "id": "tip-02", "icon": "local_cafe", "tint": "amber", "title": "…", "body": "…" }
  ]
}
```

```json
{ "status": "incomplete_profile", "contentDate": "2026-08-25", "missing": ["partner_zodiac"] }
```

An `incomplete_profile` body carries **no** `conflictIndex`, `partners`, or
`dailyTips` key at all, so a partial-render bug cannot fabricate content.

## 2. Identifiers — copy exactly

| Purpose | Identifier | Bound config key / route |
|---------|------------|--------------------------|
| Endpoint | `/zodiac/red-flag/today` | `ZodiacController` @Controller('zodiac') |
| Payload state | `ready`, `incomplete_profile` | `status` |
| Missing reason | `partner_link`, `self_zodiac`, `partner_zodiac` | `missing[]` |
| Partner slot | `self`, `partner` | `partners[].role` |
| Sign key | 12 lowercase names: `aries`…`pisces` | `partners[].zodiacSign` |
| Tip tint | `mint`, `pink`, `amber`, `lilac`, `peach` | `dailyTips[].tint` |
| Tip icon | `videocam`, `block`, `local_cafe`, `nightlight`, `favorite`, `chat_bubble`, `savings`, `self_improvement` | `dailyTips[].icon` |

Rules for the consumer side:

- `zodiacSign` is lowercase on the wire and feeds
  `CupidZodiacSign.tryParse` unchanged. Do not TitleCase it, do not re-derive
  the sign from `birthday`, and never render a Unicode zodiac glyph.
- `tint` and `icon` are closed vocabularies but must be parsed with a
  `default:` branch (neutral `colorTextMuted` tile + `favorite` glyph), not an
  exhaustive `switch` that throws — the pool grows append-only.
- Do not reuse `/zodiac` for any other capability; the module owns the prefix.

## 3. `ready` fields

| Order | Key | Rendered/exposed as | Value contract |
|-------|-----|---------------------|----------------|
| 1 | `contentDate` | Card 1 eyebrow date | `YYYY-MM-DD`, server-local calendar day. Client renders this, never `DateTime.now()` |
| 2 | `conflictIndex.score` | Card 2 score | integer, `0 <= score <= scoreMax` |
| 3 | `conflictIndex.scoreMax` | Card 2 `/N` suffix + bar fill | integer, currently `10`. Fill = `score / scoreMax`; do not hardcode `10` or `70%` |
| 4 | `conflictIndex.headline` / `.body` | Card 1 headline + body | non-empty `vi` strings, per sign pair, date-independent |
| 5 | `partners` | Card 2 icon discs | exactly 2 entries, `partners[0].role == "self"` always |
| 6 | `partners[].displayName` | label under each disc | may be `null`; fall back to the sign's `viLabel`, never a placeholder name |
| 7 | `dailyTips` | Card 3 rows | **exactly 3** entries, distinct `id`s, stable order |

- Backend owns sign normalization, tip selection, and date computation. Mobile
  formats `contentDate` for display and computes the bar fraction; it derives
  nothing else.
- An unexpected extra key is ignored. A missing required key in a `ready` body
  is a contract violation — surface the generic error state, do not substitute.

## 4. `incomplete_profile` fields

| Order | Key | Rendered/exposed as | Value contract |
|-------|-----|---------------------|----------------|
| 1 | `contentDate` | not rendered in state 2c | same contract as above |
| 2 | `missing` | not rendered — copy is neutral | non-empty, ascending-stable subset of the three reasons |

`missing` exists for logging and future copy, not for branching: mobile shows
one neutral 2c card for every non-`ready` status and must not name a partner.

## 5. Deploy / rollout order

Backend first. Mobile calling this route before it exists gets `404`, which the
existing `CupidApi` interceptor maps to a `CupidApiFailure` — loud, and the
screen shows its error state. The reverse order is harmless: the endpoint has
no client-visible side effect and no writer.

## 6. What the consumer must NOT do

- Do not compute the conflict-index score, blurb, or tip selection on device —
  AC2 determinism is a backend property; two devices must agree.
- Do not treat `incomplete_profile` as an error, and do not render Card 1/2/3
  with zeros, placeholders, or fixture signs in that state.
- Do not add a shuffle/regenerate affordance or re-fetch on resume expecting
  different content within the same `contentDate`.
