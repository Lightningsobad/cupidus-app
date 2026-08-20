# Story Brief: STORY-002 Standardize VPS backend deploys onto GitHub Actions CI/CD

## Identity

- Parent requirement: `data/requirements/REQ-005_production_domain_and_cicd_standardization/req_master.md`
- Story master: `data/requirements/REQ-005_production_domain_and_cicd_standardization/STORY-002/story_master.md`
- Final story requirements artifact: `data/requirements/REQ-005_production_domain_and_cicd_standardization/STORY-002/requirements/requirements.md`

## Brief

- Actor: engineering/operations team maintaining and deploying the backend.
- Capability: a push/merge to the production branch triggers an automated
  build + deploy to the VPS through GitHub Actions, replacing whatever
  undocumented mechanism (systemd unit, PM2, docker compose, manual script,
  cron, etc.) currently deploys the backend there.
- Business value: removes tribal-knowledge deploy risk with a single,
  repeatable, auditable deploy path; establishes the CI/CD pattern REQ-006
  and REQ-007 assume exists.
- Key business rules or guardrails: read-only investigation of the current
  mechanism first, before designing the replacement; do not leave two
  competing deploy paths live once the Actions pipeline is cut over; any
  credential the pipeline needs must be a placeholder GitHub Actions secret
  (`gh secret set <NAME> --body <placeholder>`), never sourced/guessed from
  the VPS — report the exact required secret name list back to the user; do
  not generate or rotate SSH keys unless the existing authorized ones are
  confirmed broken; whether to mint a dedicated least-privilege deploy key vs.
  reuse the existing authorized key is a DevOps judgment call to record with
  rationale.
- Key edge or failure case: the current mechanism may be stateful (e.g. a
  docker compose setup with volumes/persistent data) — the cutover must not
  cause data loss or extended downtime; a failed Actions build/deploy must
  not leave the VPS in a broken/partially-deployed state.
- Existing system entry / discoverability seed: not applicable — this is a
  CI/CD infrastructure story, not a UI-facing story.
- Complexity: complex.
- Why this complexity: security-sensitive (SSH deploy credentials, secrets
  management) and it replaces the live production deploy path for the
  backend — needs extended validation focus per complexity-routing.md.
- Implementation lane seed: devops (this requirement is devops-owned end to
  end; no backend/frontend/mobile code changes are expected).
- Depends on: none.

## Direct Anchors

- Requirement AC / BR anchors: req_master.md Business Scope outcome 2;
  Technical Constraints — CI/CD standardization, secrets placeholder rule,
  SSH-key-reuse guardrail.
- Open Question anchors: req_master.md "exact current deploy mechanism
  unknown" (resolved via this story's read-only investigation phase, not a
  creation blocker); req_master.md "dedicated deploy SSH key vs. reuse"
  (DevOps judgment call, record during implementation); central-registry
  "Nginx VPS-target ambiguity" (the legacy `api-cupid.tikup.me` vhost/compose
  config must be inventoried as part of the current-mechanism investigation).
- Related story dependencies: none (independent of STORY-001).

## Scope Seed

### In Scope

- Read-only investigation of the current VPS deploy mechanism.
- A GitHub Actions workflow that builds and deploys the backend to the VPS on
  push/merge to the production branch.
- Decommissioning the prior deploy mechanism once the Actions pipeline is
  live and verified.
- Placeholder GitHub Actions secrets for anything the pipeline needs, with
  the exact required secret name list reported back to the user.

### Out of Scope

- Pointing `api.cupidus.app` at the VPS (that is STORY-001).
- Any application/business-logic change to the backend itself.
- Sourcing, guessing, or reusing any real credential value discovered on the
  VPS without explicit user confirmation.
