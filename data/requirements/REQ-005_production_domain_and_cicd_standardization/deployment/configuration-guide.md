# REQ-005 Deployment Configuration Guide

Owner: DevOps. Source story: STORY-001 (`api.cupidus.app` hostname, origin
TLS, Cloudflare edge). Last updated: 2026-08-21.

## 1. Cloudflare API credential

- Name: `CLOUDFLARE_API_TOKEN` (proposed; not yet created — see status below).
- Required scope: `Zone:DNS:Edit` on the `cupidus.app` zone, at minimum, for
  `scripts/cloudflare/create-api-dns-record.sh`. The credential type required
  for Origin CA certificate issuance is **unverified** (see section 2) —
  Cloudflare's Origin CA endpoint may require an **Origin CA Key**, which is a
  distinct credential from a scoped Zone API token, not a superset of it.
- Where stored: intended to be a GitHub Actions secret, scope TBD.
- **Status: NOT CREATED.** `gh secret set` requires a target repo, and this
  `cupid-apps` checkout has no git remote configured (`git remote -v` is
  empty in both the story worktree and the control checkout). Creating the
  placeholder secret in a guessed repo was judged too risky (wrong-repo
  credential placement). **Needs a decision from the user/Scrum Master: which
  GitHub repository's Actions secrets should hold this credential** (the
  account has `hoak57uet/cupid-backend`, `hoak57uet/cupid-app-android`,
  `hoak57uet/cupid-app-ios`, among others — none confirmed as this project's
  CI target). Once confirmed, run:
  `gh secret set CLOUDFLARE_API_TOKEN --repo <owner>/<repo> --body <placeholder>`
  and populate the real value out-of-band.
- No real credential value was invented, guessed, or reused anywhere in this
  change (AC5).

## 2. Origin CA certificate

- **Status: NOT PROVISIONED.**
- Issuance mechanics (API endpoint, required credential type — scoped API
  token vs. Origin CA Key, offered validity periods) are **unverified**. The
  planning session flagged this as needing live verification
  (`architecture/solution.md` section 3, "Unverified third-party mechanics");
  this implementation session also had no `WebSearch`/`WebFetch`/`ToolSearch`
  available to perform that verification. Nothing about Origin CA issuance
  mechanics in this guide should be treated as fact until a session with live
  web access resolves it.
- Certificate/key install location (once provisioned): mounted read-only into
  the `nginx` container at `/etc/nginx/certs/` from `backend/certs/` on the
  VPS host (gitignored — see `.gitignore`, rule added in this change). The
  private key is generated on the VPS and must never leave it or enter this
  repository.
- Expected files: `backend/certs/api.cupidus.app.pem` (cert),
  `backend/certs/api.cupidus.app.key` (private key).
- **Issued/expiry date: NOT YET ISSUED — no dates to record.** This section
  must be updated with the actual issuance date, expiry date, and the exact
  renewal command the moment a certificate is provisioned; an unrecorded
  expiry is this design's primary undefended failure mode
  (`architecture/solution.md` section 5).

## 3. Zone SSL/TLS mode

- Current: unchanged by this story (zone SSL mode was **not** modified).
- Target: **Full (strict)**, but only after the origin is confirmed serving a
  valid Origin CA certificate on 443 (hard ordering constraint — raising the
  mode first causes a 526 outage). Not yet raised.

## 4. Published VPS ports

- `backend/docker-compose.yml`, `nginx` service (`vps` Compose profile only,
  local dev unaffected): now publishes `80:80` (existing) and `443:443` (new,
  this change). Certificate directory mounted read-only at
  `/etc/nginx/certs`.
- Live VPS container has **not** been updated with this compose change yet —
  only the repo-tracked file changed. Deploying it is a separate action from
  writing it.

## 5. `api-cupid.tikup.me` legacy hostname

- Disposition: **kept, unchanged, byte-for-byte** (AC3). The existing `server
  { listen 80; server_name api-cupid.tikup.me; ... }` block in
  `backend/nginx/default.conf` was not edited. A new, separate server block
  was added for `api.cupidus.app`.
- Per `architecture/contract-summary.md` section 2: this is a legacy name,
  not a supported client endpoint, kept alive only so this story does not
  break it, and may be removed by a later story. Its final
  keep/merge/remove disposition remains an open item, not decided by this
  story (per `requirements/requirements.md` "Out of scope").

## 6. DNS record

- `scripts/cloudflare/create-api-dns-record.sh`: idempotent, fail-closed
  script that creates a Cloudflare-**proxied** `A` record for
  `api.cupidus.app` -> `84.247.140.178`. Enumerates existing records first;
  refuses to mutate (non-zero exit, prints the conflicting record) if a
  non-matching `api` record already exists.
- **Status: written, not executed.** Requires `CLOUDFLARE_API_TOKEN` and
  `CLOUDFLARE_ZONE_ID` env vars, neither available in this session (section
  1).

## 7. Open blockers (see `STORY-001/coding-plan/test-results.md` for full evidence)

1. `SECRET_REQUIRED` — target GitHub repo for `CLOUDFLARE_API_TOKEN` unknown;
   needs a user/Scrum Master decision.
2. `ORIGIN_CERT_PROVISION_FAILED` — Origin CA issuance mechanics unverifiable
   in this session (no live web access); must be resolved before certificate
   provisioning, DNS creation, or SSL mode changes can proceed.

Until both are resolved, `https://api.cupidus.app` does not yet serve
anything — no REQ-006/REQ-007 client build should point at this host yet
(`architecture/contract-summary.md` section 4).
