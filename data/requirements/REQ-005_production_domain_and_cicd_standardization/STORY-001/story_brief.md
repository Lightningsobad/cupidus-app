# Story Brief: STORY-001 Point api.cupidus.app at the production backend API

## Identity

- Parent requirement: `data/requirements/REQ-005_production_domain_and_cicd_standardization/req_master.md`
- Story master: `data/requirements/REQ-005_production_domain_and_cicd_standardization/STORY-001/story_master.md`
- Final story requirements artifact: `data/requirements/REQ-005_production_domain_and_cicd_standardization/STORY-001/requirements/requirements.md`

## Brief

- Actor: API consumers of the backend (mobile app, web frontend, external
  integrators) and the operations team.
- Capability: reach the backend API at a stable, TLS-secured production
  hostname (`api.cupidus.app`) instead of a raw VPS IP.
- Business value: unblocks REQ-006 and REQ-007, which both assume
  `api.cupidus.app` is live; makes the backend reachable under the owned
  domain with valid HTTPS.
- Key business rules or guardrails: create the DNS record through the
  Cloudflare CLI/API (scripted, repeatable, auditable), not the manual
  dashboard; do not generate or rotate SSH keys unless the existing
  authorized ones are confirmed broken.
- Key edge or failure case: `backend/nginx/default.conf` already has
  `server_name api-cupid.tikup.me` (a different, older domain) — inspect and
  extend/replace this vhost rather than blindly overwriting it; confirm no
  conflicting DNS record already exists on the `cupidus.app` zone before
  creating the new one.
- Existing system entry / discoverability seed: not applicable — this is an
  infrastructure/domain routing change, not a UI-facing story.
- Complexity: standard.
- Why this complexity: requires a new architecture decision (TLS termination
  approach — Cloudflare-proxied edge certificate vs. origin certificate via
  the VPS reverse proxy) not previously in place for this backend; no new UX
  surface.
- Implementation lane seed: devops (this requirement is devops-owned end to
  end; no backend/frontend/mobile code changes are expected).
- Depends on: none.

## Direct Anchors

- Requirement AC / BR anchors: req_master.md Business Scope outcome 1;
  Technical Constraints — DNS/Cloudflare CLI, SSH-key-reuse guardrail.
- Open Question anchors: central-registry "Nginx VPS-target ambiguity"
  (concerns the legacy `api-cupid.tikup.me` vhost, not a blocker — see
  `requirements/requirements.md` Open Question Triage); central-registry
  `api-cupid.tikup.me` VPS target identity (RESOLVED, confirms VPS is a
  legitimate target).
- Related story dependencies: none (independent of STORY-002).

## Scope Seed

### In Scope

- Creating/pointing the `api.cupidus.app` DNS record at the VPS through the
  Cloudflare CLI/API.
- VPS-side routing/TLS change needed for `api.cupidus.app` to reach the
  running backend API (reverse proxy vhost, certificate).

### Out of Scope

- Any change to how the backend gets deployed onto the VPS (that is
  STORY-002).
- REQ-006 (web) and REQ-007 (mobile) consumption of this domain.
- Rotating/generating SSH keys unless confirmed broken.
