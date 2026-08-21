# Story Requirements: STORY-002 Standardize VPS backend deploys onto GitHub Actions CI/CD

## Identity
- Parent requirement: `data/requirements/REQ-005_production_domain_and_cicd_standardization/req_master.md`
- Story master: `data/requirements/REQ-005_production_domain_and_cicd_standardization/STORY-002/story_master.md`

## Actor & Capability
- Actor: engineering/operations team maintaining and deploying the backend.
- Capability: a push/merge to the production branch triggers an automated
  build + deploy of the backend to VPS `root@84.247.140.178` through GitHub
  Actions, replacing whatever undocumented mechanism (systemd unit, PM2,
  docker compose, manual script, cron, etc.) currently deploys it there.

## Business Value
Removes tribal-knowledge deploy risk with a single, repeatable, auditable
deploy path, and establishes the GitHub Actions CI/CD pattern that REQ-006
(web frontend deploy) and REQ-007 (mobile app pointed at
`api.cupidus.app` in production builds) assume already exists.

## Acceptance Criteria

- AC1: The current VPS deploy mechanism is investigated read-only (SSH
  inspection only, no changes) and documented before any replacement is
  designed, including an inventory of the legacy `api-cupid.tikup.me`
  vhost/compose config found on the VPS as part of that investigation.
- AC2: A GitHub Actions workflow exists in the repository such that a
  push/merge to the production branch triggers an automated build and
  deploy of the backend to VPS `root@84.247.140.178`.
- AC3: Once the Actions pipeline is live and its deploy is verified working,
  the prior undocumented deploy mechanism is decommissioned so that no two
  competing deploy paths remain live simultaneously.
- AC4: Every credential the pipeline needs (VPS deploy key material if a
  dedicated deploy key is created, Cloudflare API token, registry
  credentials, etc.) is created only as a placeholder GitHub Actions secret
  via `gh secret set <NAME> --body <placeholder>` — never sourced or guessed
  from a real value discovered on the VPS — and the exact list of required
  secret names is reported back to the user so they can populate/rotate the
  real values themselves.
- AC5: No SSH key is generated or rotated unless the existing
  already-authorized keys are confirmed broken. The choice of minting a
  dedicated least-privilege deploy key for GitHub Actions vs. reusing the
  existing authorized key is a recorded DevOps judgment call with rationale.
- AC6: If the current mechanism is stateful (e.g. a docker compose setup
  with volumes/persistent data), the cutover to the Actions pipeline causes
  no data loss and no extended downtime.
- AC7: A failed Actions build or deploy does not leave the VPS in a broken
  or partially-deployed state — the previous working deployment remains
  serving traffic until a deploy fully succeeds.

## Business Rules / Guardrails

- Investigation of the current deploy mechanism must be read-only and must
  happen before the replacement pipeline is designed.
- Do not leave two competing deploy paths live once the Actions pipeline is
  cut over.
- Any credential the pipeline needs must be a placeholder GitHub Actions
  secret, never sourced or guessed from a value found on the VPS.
- Do not generate or rotate SSH keys unless the existing authorized ones are
  confirmed broken.
- Dedicated least-privilege deploy key vs. reuse of the existing authorized
  key is a DevOps judgment call; the decision and rationale must be
  recorded when made.

## Edge Cases / Failure Modes

- The current mechanism may be stateful (e.g. docker compose with
  volumes/persistent data) — cutover must not cause data loss or extended
  downtime.
- A failed Actions build/deploy must not leave the VPS in a
  broken/partially-deployed state.

## Scope

### In Scope
- Read-only investigation of the current VPS deploy mechanism, including
  inventory of the legacy `api-cupid.tikup.me` vhost/compose config.
- A GitHub Actions workflow that builds and deploys the backend to the VPS
  on push/merge to the production branch.
- Decommissioning the prior deploy mechanism once the Actions pipeline is
  live and verified.
- Placeholder GitHub Actions secrets for anything the pipeline needs, with
  the exact required secret name list reported back to the user.

### Out of Scope
- Pointing `api.cupidus.app` at the VPS (that is STORY-001).
- Any application/business-logic change to the backend itself.
- Sourcing, guessing, or reusing any real credential value discovered on the
  VPS without explicit user confirmation.

## Open Question Impact

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All scope items above (AC1-AC7). Rationale, per the requirement-level
  Open Question Triage:
  - "Exact current deploy mechanism unknown" is not a creation blocker — it
    is AC1, the first implementation phase of this story (read-only
    investigation), not a precondition for defining the story.
  - "Dedicated deploy SSH key vs. reuse" is a DevOps security judgment call
    to be made and recorded during implementation (AC5); it does not block
    story definition or scope.
  - "Nginx VPS-target ambiguity" (central registry) concerns the legacy
    `api-cupid.tikup.me` domain, a different domain than this requirement's
    `api.cupidus.app`. It is not a blocker to this story; the read-only
    investigation phase (AC1) must inventory that legacy vhost/compose
    config as part of documenting the current deploy mechanism.

## Dependencies
- None. Independently deliverable regardless of STORY-001's completion
  status, since the backend already runs on the VPS via the existing
  (undocumented) mechanism.
