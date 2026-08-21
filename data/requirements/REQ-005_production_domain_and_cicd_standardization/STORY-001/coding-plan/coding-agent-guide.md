# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md` (this story has exactly one: `phase-P1-api-hostname-tls-edge.md`)

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files. UX is WAIVED for
this story — there is no `../ux/` artifact to read.
If the phase names shared interfaces, read those artifacts first.
If the phase names OQ constraints, read the story requirements
`## Open Question Impact` section before working and do not implement blocked
scope.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane. This story is DevOps-only.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane. In particular, the backend build/deploy mechanism
   belongs to STORY-002, not here.
6. Stop and escalate if the assigned work requires an unresolved OQ decision
   that the phase does not already resolve.

## 4. Stop-And-Ask Rules Specific To This Story

These are hard stops, not judgement calls. Each maps to an acceptance criterion.

- Existing SSH access to `root@84.247.140.178` does not work → STOP and report.
  Do not generate or rotate a key without explicit user confirmation (AC4).
- A conflicting `api` record already exists on the `cupidus.app` zone → STOP and
  report the existing record verbatim. Do not overwrite or delete it (AC1).
- A real credential value is needed and not already available → create a named
  placeholder GitHub secret and report the secret name. Never invent, guess, or
  reuse a credential value (AC5).
- The existing `api-cupid.tikup.me` server block cannot be preserved as-is →
  STOP and report the conflict rather than editing it (AC3).
- The origin certificate cannot be installed or `nginx -t` fails → STOP and
  leave the Cloudflare zone SSL mode unchanged. Never leave the zone in
  Full (strict) with an origin that has no valid certificate.

## 5. External State Warning

This phase mutates state that lives outside the repository: a Cloudflare DNS
record and the zone SSL/TLS mode. Reverting the git diff does NOT revert them,
and the wrong rollback order causes an outage. See `master-plan.md` section 6
before backing anything out.

## 6. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Record command output as evidence in `coding-plan/test-results.md`.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.
