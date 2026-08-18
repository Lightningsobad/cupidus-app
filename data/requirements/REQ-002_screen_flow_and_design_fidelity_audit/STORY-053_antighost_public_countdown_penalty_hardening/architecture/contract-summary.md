# STORY-053 Cross-Lane Contract — `publicCountdown`

Self-contained. The mobile lane can implement from this file alone, without
reading `solution.md` and without reading backend source.

## 1. Field

| Name | Wire JSON key | Type | Required in POST body | Default | Nullable in response |
|------|---------------|------|-----------------------|---------|----------------------|
| `publicCountdown` | `publicCountdown` | boolean | NO | `true` | NO (once P1 ships) |

The key is spelled exactly `publicCountdown` (lower camel case) in both
directions. It is **not** a `Penalty` enum member and must never be encoded as
one.

## 2. Producer — `POST /ghost-config` request body

Existing body, one key added:

```json
{ "timeoutMinutes": 15, "penalty": "emoji_storm", "publicCountdown": false }
```

- `publicCountdown` is optional. Omitting it persists `true`.
- Validation: `@IsOptional() @IsBoolean()`. A non-boolean value is a 400, same
  envelope as every other DTO violation on this route.

## 3. Producer — response bodies

`POST /ghost-config`, `GET /ghost-config`, `GET /ghost-config/pending`,
`PATCH /ghost-config/:id/approve`, `PATCH /ghost-config/:id/reject` all return
the full `GhostConfig` record and therefore all gain the key:

```json
{
  "id": "…", "coupleId": "…",
  "timeoutMinutes": 15, "penalty": "emoji_storm", "publicCountdown": false,
  "proposedBy": "…", "approvedBy": null, "status": "pending_approval",
  "createdAt": "…", "updatedAt": "…"
}
```

`GET /ghost-config/storm-status/:partnerId` is **unchanged** — it returns
`{eligible, penalty}` only and must not gain the field.

## 4. Consumer read rule

Mobile parses it as `json['publicCountdown'] as bool? ?? true`.

The nullable-tolerant read is mandatory, not defensive habit: it lets the mobile
phase build and ship against a backend that has not yet deployed P1, and the
fallback (`true`) is byte-identical to what the persisted column default
produces, so the two can never disagree.

## 5. Deploy order

None required. P1 and P2 are independently deployable in either order:

- Backend before mobile: older clients omit the key from the POST body
  (`@IsOptional()`) and ignore it in responses.
- Mobile before backend: the `?? true` read covers the absent key. The extra
  POST body key is silently **stripped**, not rejected — the global pipe is
  `new ValidationPipe({ whitelist: true })` with `forbidNonWhitelisted` unset
  (`backend/src/main.ts:18`), so an undeclared key is removed rather than
  producing a 400. The setting simply does not persist until P1 ships.

## 6. Storage note (backend lane only)

The schema runs `synchronize: true` and the repository has no
`backend/src/migrations/` directory. Declaring the column with `default: true`
is the whole storage change — do not author a migration file. Pre-existing rows
backfill to `true` on boot, which is the default the acceptance criteria
require.
