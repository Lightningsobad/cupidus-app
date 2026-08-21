# Scope Gate — REQ-005 Requirement Integration Review (full, both stories)

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Review type: `requirement-integration-review` (full requirement, STORY-001 + STORY-002)
Review report path:
`data/requirements/REQ-005_production_domain_and_cicd_standardization/integration-review/review-report.md`
Branch: `codex/REQ-005_production_domain_and_cicd_standardization-integration`
BaseHead: `8ae3d376065781bd20ee20078f88afb86406dcba`

## Diff shape (measured, not assumed)

`git diff --stat 8ae3d37..HEAD` = 16 files, +2409 / -7. Every path is
STORY-001 or requirement-level. STORY-002's implementation landed **before**
BaseHead (merge `bf6427b`, then `8ae3d37`), so it is NOT in this diff and is
reviewed here as already-merged state plus its own prior integration review.

## Source/config files in scope

- `deployment/caddy/api.cupidus.app.caddy`
- `backend/docker-compose.prod.yml` (port contract only)
- `.github/workflows/scripts/vps-deploy.sh` (BACKEND_PORT contract only)
- `.github/workflows/deploy-backend.yml` (trigger/branch contract only)
- `scripts/cloudflare/*.sh` (3 scripts, credential-hygiene scan only)

## Evidence/governing files in scope

- `req_master.md` (Business Scope, Deployment/Configuration status, story table)
- `deployment/configuration-guide.md` (FULL read — explicitly required by the
  handoff to confirm both story sections survived the merge)
- `STORY-001/story_master.md`, `STORY-001/review/review-report.md`
- `STORY-002/story_master.md`
- prior `integration-review/review-report.md` (STORY-002-only, superseded)
- `STORY-001/coding-plan/test-results.md` — RANGED only (26 KB), around
  `## Story Runtime Startup Smoke`

## Touched risk surfaces

runtime/configuration; external integration (Cloudflare, GHCR); operational
command (`vps-deploy.sh`); security/auth (secrets, SSH, TLS);
shared local/host infrastructure (multi-tenant VPS). No UI surface — rules
12e1/12e2/12g1/12g2 not applicable (both stories record `UX-Spec: WAIVED`).

## Critical gates to verify

1. Cross-story port contract: Caddy `reverse_proxy 127.0.0.1:3010` ==
   compose `127.0.0.1:3010:3000` == `vps-deploy.sh` health-gate port.
2. `configuration-guide.md` well-formed, both sections present, no
   duplication/truncation (rule 12a).
3. Business Scope outcome (a): `api.cupidus.app` serves backend over HTTPS.
4. Business Scope outcome (b): VPS backend deploys on GitHub Actions CI/CD.
5. Rule 12g3: `## Integration Build & Runtime` with `- Build: PASS — …` and
   `- Runtime/Smoke: PASS — …` present in `integration-review/`, or
   `Integration-Verify: WAIVED — …` in `req_master.md`.
6. Requirement-level state coherence across `req_master.md` and both
   `story_master.md` files.
7. No secret material in the requirement diff.

## Query keys for Phase 2

`3010`, `reverse_proxy`, `BACKEND_PORT`, `127.0.0.1:3010:3000`,
`Story Runtime Startup Smoke`, `Integration Build & Runtime`,
`Integration-Verify`, `Stories-Merged`, `Status:`, `api.cupidus.app`.

## Decision

Phase 2 may proceed. Scope is inside the requirement-integration budget.
