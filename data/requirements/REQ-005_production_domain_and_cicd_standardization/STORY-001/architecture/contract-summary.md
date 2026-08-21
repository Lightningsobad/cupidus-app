# Cross-Lane Contract — REQ-005 Production API host

Authoritative source: VPS host Caddy edge + `cupidus.app` Cloudflare zone
(STORY-001).
Consumers: REQ-006 (web) and REQ-007 (mobile), which set this as their
production API base URL.

## 1. Envelope

Unchanged transport: the same HTTP API already served by `backend:3000`. This
story changes only how it is *addressed*. Production base URL:

```
https://api.cupidus.app
```

Scheme is `https` and is not optional — port 80 on this host is not a supported
client entry point. A consumer that hardcodes `http://` or the raw IP
`84.247.140.178` gets a redirect or a certificate error at runtime, not a build
error, so this is a silent-until-production class of mistake.

## 2. Identifiers — copy exactly

| Purpose | Identifier | Bound config key / route |
|---------|------------|--------------------------|
| Production API origin | `https://api.cupidus.app` | consumer's production API base-URL env var |
| Legacy host (do NOT adopt) | `api-cupid.tikup.me` | none — pre-existing, plain HTTP, disposition undecided |

Rules for the consumer side:

- Exact spelling is `api.cupidus.app`. Near-misses that will resolve to nothing:
  `api.cupid.app`, `api-cupid.cupidus.app`, `api-cupidus.app`.
- Do NOT reuse `api-cupid.tikup.me`. It is a legacy name kept alive only so this
  story does not break it; it is not a supported client endpoint and may be
  removed by a later story.
- Do NOT ship the raw VPS IP in any client build.

## 3. Runtime properties the consumer can rely on

| Property | Value | Value contract |
|----------|-------|----------------|
| TLS | Public Cloudflare edge certificate | Publicly trusted; standard client TLS validation succeeds with no pinning and no custom trust store |
| Proxy | Cloudflare-proxied (orange cloud) | Requests traverse the Cloudflare edge; client IP arrives at the backend via `X-Forwarded-For`, not the socket peer |
| Certificate pinning | NOT SUPPORTED | The edge certificate rotates on Cloudflare's schedule. A mobile client that pins a leaf certificate will break without warning. |

## 4. Deploy / rollout order

STORY-001 must be live and verified before any REQ-006/REQ-007 build points at
this host. Wrong order is loud, not silent: consumer builds pointed at
`api.cupidus.app` before it resolves fail with DNS/connection errors in
every environment, which is why no consumer should treat this host as available
until STORY-001 is DONE.

## 5. What the consumer must NOT do

- Do not pin certificates (see section 3) — the mobile lane is the likely
  offender here.
- Do not assume the socket peer address is the end user; read `X-Forwarded-For`.
- Do not re-point DNS, change the zone SSL mode, or edit the VPS
  `/etc/caddy/Caddyfile` site block from a consumer requirement. This host's
  configuration is owned by REQ-005, and the Caddyfile is shared with an
  unrelated live production site.

## 6. Origin-side facts (NOT consumer values)

Recorded here only because STORY-002 shares this origin. REQ-006 and REQ-007
must not read anything from this section into a client build.

| Fact | Value | Rule |
|------|-------|------|
| TLS terminator | Host Caddy on the VPS, site block `api.cupidus.app` | No container may bind host port 80 or 443 — Caddy owns them for a shared tenant |
| Backend published host port | Selected by STORY-001, recorded in `deployment/configuration-guide.md`; loopback-bound, and NOT `3000` | STORY-002's `docker-compose.prod.yml` and its `GET http://127.0.0.1:<backend port>/` health gate must use the identical port |
