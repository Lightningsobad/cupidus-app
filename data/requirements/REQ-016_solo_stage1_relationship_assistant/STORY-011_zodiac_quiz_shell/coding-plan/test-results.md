## Story Runtime Startup Smoke

- Runtime Id: backend-api
- Registry: data/devops/system/runtime-command-registry.json
- Reason: `guard-parallel-spawn.sh` refused to spawn Alex-Mobile-Dev for this
  story's Phase P1 with "no declared service runtime is running" even though
  Phase P1 itself declares `Runtime startup smoke: NO`. This section satisfies
  that blanket repo-level spawn-guard precondition; it is not a Phase P1 test
  result.
- Command: `npm run start:dev` in `backend/`, `PORT` sourced from
  `DEVSTACK_PORT_API` in `.env.devstack` (shared devstack tenant `cupid_apps`,
  reserved port 21020 per `sharedInfra.reservedPorts.api`)
- Ready Check: `GET http://127.0.0.1:21020/api-docs-json` expecting HTTP 200
- Result: PASS (HTTP 200, valid OpenAPI JSON body returned; process listening
  on `*:21020`, backend `[NestApplication] Nest application successfully
  started` logged)
- Shutdown: PASS (SIGTERM to the nest dev process; process exited within 2s;
  port 21020 confirmed free afterward)

Notes:
- Worktree-local setup performed to make this runnable: `backend/node_modules`
  installed via `npm ci` (worktrees do not share installed dependencies), and
  two pre-existing local secrets/generated files copied from the control
  checkout into this worktree since git worktrees do not carry untracked
  files: `backend/service-account.json` (pre-supplied Firebase Admin
  credential, not generated) and `.env.devstack` (devstack-generated env
  contract for the same shared `cupid-apps` tenant; `devstack use --check`
  confirms this worktree resolves to the same adopted tenant as the control
  checkout, and `devstack port check` showed no conflicts before starting).
- This smoke does not leave backend-api running; per the handoff, only proof
  it can start and answer ready was required.
