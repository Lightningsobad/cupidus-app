# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files. UX is WAIVED for
this story; no `../ux/` artifact exists.
If the phase names shared interfaces, read those artifacts first —
`../architecture/contract-summary.md` is the authoritative contract for secret
names, VPS runtime layout, health gate, and rollout order.
If the phase names OQ constraints, read `../requirements/requirements.md`
`## Open Question Impact` before working; nothing is BLOCKED in this story.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`. P2 must not
   start before P1 is `DONE`.
2. Execute only phases owned by your lane. Both phases are DevOps.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into `backend/src/` or
   `backend/nginx/default.conf` — STORY-001 owns the nginx vhost, and touching it
   here conflicts on the integration branch.
6. Stop and escalate if the work requires an unresolved decision the phase does
   not already resolve.

## 4. Open Implementation Decisions

OID-1 (SSH key reuse vs. dedicated), OID-2 (SSH mechanism), and OID-3 (GHCR
package visibility) are deliberately open. They are DevOps judgment calls to be
made **and recorded with rationale** during P2 implementation, in
`STORY-002/devops/cutover-evidence.md` and in
`../../deployment/configuration-guide.md`. Their criteria are in
`../architecture/solution.md` `### Open Implementation Decisions`. Do not treat
them as planning gaps.

## 5. Non-Negotiable Guardrails

- No real credential value is ever read, echoed, copied, or committed. Secrets
  are placeholders via `gh secret set <NAME> --body <placeholder>`, and the exact
  required secret name list must be reported back to the user (AC4).
- No SSH key is generated or rotated unless an existing authorized key has been
  demonstrated broken (AC5).
- The legacy deploy path is disabled only after a green Actions deploy is
  verified serving traffic (AC3).
- No `docker system prune`, `docker compose down -v`, or volume removal on the
  VPS, ever (AC6).
- No `StrictHostKeyChecking=no`; the host key is pinned from
  `VPS_SSH_KNOWN_HOSTS`.

## 6. Plan Update Rule

- Update phase status, owned notes, and test evidence in place; record evidence
  in `coding-plan/test-results.md`.
- Do not redesign the plan during implementation.
- Escalate if the plan is materially wrong — in particular if the P1 inspection
  disproves assumption A-1 (Docker Compose on the VPS), which changes the deploy
  contract's shape and needs an architecture revision.
