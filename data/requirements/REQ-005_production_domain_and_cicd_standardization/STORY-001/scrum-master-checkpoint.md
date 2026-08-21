# Scrum Master Checkpoint: REQ-005 / STORY-001

Flow: parallel-story (continue parallel wave)
Story: STORY-001 Point api.cupidus.app at the production backend API
Status: BLOCKED — real user decision required

## State As Of This Checkpoint

- Worktree: `.../story-REQ-005_production_domain_and_cicd_standardization-STORY-001`
- Branch: `codex/REQ-005_production_domain_and_cicd_standardization-STORY-001`
- Requirements DONE, UX WAIVED, Architecture DONE.
- Implementation run `Frank-Devops-3`
  (`RUN-REQ-005_production_domain_and_cicd_standardization-STORY-001-devops`,
  agent_id `Frank-Devops-3@session-4df004a7`) returned
  `DEVOPS_COMPLETE: NO` with two typed blockers, recorded in
  `coding-plan/test-results.md`:

  1. **SECRET_REQUIRED** — no git remote is configured on this checkout at
     all (`git remote -v` empty, `gh repo view`/`gh secret list` both report
     "no git remotes found"), so there is no non-guessed target repo to
     receive a `CLOUDFLARE_API_TOKEN` placeholder GitHub Actions secret per
     AC5's fallback. Best-guess candidate seen in `gh auth status`'s account
     repo list: `hoak57uet/cupid-backend` — **unconfirmed, needs a user
     decision**: which GitHub repository's Actions secrets should hold the
     Cloudflare credential for this story (and, by extension, STORY-002's
     CI/CD pipeline)?
  2. **ORIGIN_CERT_PROVISION_FAILED** — `WebSearch`/`WebFetch`/`ToolSearch`
     were not available in the Frank-Devops-3 runtime, so the Cloudflare
     Origin CA issuance endpoint, required credential type (scoped API
     token vs. Origin CA Key), and certificate validity period could not be
     verified against live sources as the phase required. No issuance was
     attempted; nothing was guessed.

- Repo-side prep IS complete and safe (already in the STORY-001 worktree,
  uncommitted): `.gitignore` rule for `backend/certs/`, additive
  `api.cupidus.app` nginx server block (legacy `api-cupid.tikup.me` block
  byte-for-byte unchanged, confirmed via diff), Compose `443:443` publish +
  cert mount (profile-gated to `vps`, local dev unaffected), and an untested
  but `bash -n`-clean `scripts/cloudflare/create-api-dns-record.sh`. SSH
  access to the VPS is confirmed working (no key rotation). No cert/key
  material exists anywhere in the tree. Nothing was touched on the live VPS
  beyond a read-only SSH check.
- `Frank-Devops-3` remains a live teammate (not printed by
  `list-releasable-agents.sh` — its run status is `BLOCKED`, not a
  release-eligible terminal state) but is not doing further work pending the
  decision above; do not re-dispatch it for the same phase without new
  answers.

## Next Step (blocked on user)

Ask the user directly (not inferable from repo state):
1. Which GitHub repository should own this project's Actions secrets
   (`CLOUDFLARE_API_TOKEN`, and STORY-002's deploy-pipeline secrets)? This
   checkout has zero git remotes configured.
2. Once known: wire that remote, then continue `Frank-Devops-3` (same
   RunId) via SendMessage with the exact answer, so it can create the
   placeholder secret and attempt Origin CA cert issuance research/live
   provisioning per AC5.

Do not retry Frank-Devops-3 without a real remote/repo answer — retrying
without new information will reproduce the same SECRET_REQUIRED blocker.

## Do Not Re-read

- `coding-plan/master-plan.md`, `coding-agent-guide.md`,
  `phase-P1-api-hostname-tls-edge.md` (already summarized in the REQ-005
  checkpoint)
- `architecture/solution.md` (already summarized in the REQ-005 checkpoint)
