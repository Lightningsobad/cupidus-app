# Requirement Deployment Log: REQ-001 Cupid Flutter Mobile App

## 1. Metadata

- Requirement ID: REQ-001_cupid_flutter_mobile_app
- Requirement Master: `data/requirements/REQ-001_cupid_flutter_mobile_app/req_master.md`
- System DevOps Memory: `data/devops/system/devops_system_memory.md`
- Requirement Configuration Guide: `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md`
- Last Updated: 2026-08-01

## 2. Environment Status

| Environment | Trigger Rule | Last Attempt | Status | Location / Endpoint | Notes |
|-------------|--------------|--------------|--------|---------------------|-------|
| development-local | automatic after requirement DONE when configured | 2026-08-01 | BLOCKED | n/a | `main` (the branch deployed by `scripts/setup.sh`/`build.sh`/`start-dev.sh`) does not contain the DONE requirement's code — see §3 |
| staging | explicit user instruction only | | NOT_REQUESTED | | out of scope for this handoff |
| production | explicit user instruction only | | NOT_REQUESTED | | out of scope for this handoff |

## 3. Latest Attempt

- Target Environment: development-local
- Trigger: automatic after requirement DONE (REQ-001 marked DONE, all 16 stories DONE and merged into `codex/REQ-001_cupid_flutter_mobile_app-integration`, integration review CLEAN)
- Inputs Used: `data/devops/system/devops_system_memory.md` §3/§3.1/§3.2, `data/devops/system/runtime-command-registry.json`, `req_master.md`, `scrum-master-checkpoint.md`, `deployment/configuration-guide.md`
- Commands / Steps Run (all executed against the current checkout, branch `main`):
  - `bash scripts/setup.sh` — PASS. Postgres/Redis containers up on resolved loopback ports (`127.0.0.1:15432`, `127.0.0.1:16379`), project `cupid-apps`.
  - `bash scripts/build.sh` — PASS. Backend `npm ci` + `nest build` succeeded. Mobile `flutter pub get` + `flutter build apk --debug` succeeded, real APK produced.
  - `bash scripts/start-dev.sh` (bounded run) — backend reached readiness (`GET /api-docs-json` 200 at `http://127.0.0.1:3004`, port auto-resolved). Mobile `flutter test` ran and reported "All tests passed!", but only **76 tests across 17 files** — matching `main`'s actual code state (STORY-001 design_system, STORY-002 api_client, STORY-003 auth only), not the DONE requirement.
- Result: **BLOCKED — deploying `main` would present an incomplete app (3/16 stories) as the finished requirement.**
  - Verified via git: `git merge-base --is-ancestor codex/REQ-001_cupid_flutter_mobile_app-integration main` returns false — the integration branch (all 16 stories, all 5 integration bugfixes, `2efa148` HEAD) has never been merged into `main`.
  - `git diff --stat main codex/REQ-001_cupid_flutter_mobile_app-integration -- mobile` shows 314 files changed, 52,491 insertions on the integration branch not present on `main` — includes STORY-004 (RealtimeCoordinator) through STORY-016 (profile/privacy/notifs) and all 5 `BUG-20260801-00{1..5}` fixes.
  - `req_master.md`/`scrum-master-checkpoint.md` correctly describe the state of `codex/REQ-001_cupid_flutter_mobile_app-integration`; they do not currently reflect that `main` is behind that branch.
  - The backend routes observed during `start-dev.sh` (dream-jar, expenses, admin, data-export, etc.) are not evidence of the mobile merge state — the backend was already contract-frozen (A1) and complete before REQ-001 started, and lives outside REQ-001's mobile-app change surface.
- Fixes Applied: none. Merging `codex/REQ-001_cupid_flutter_mobile_app-integration` into `main` is Scrum Master Git control-plane scope (`AGENTS.md` § Role Map: scrum-master "owns ... integration-branch merges"), not DevOps scope. DevOps did not merge branches or alter `main`.
- Configuration Guide Updated: no — this is a source-branch state issue, not a configuration/setup gap. `configuration-guide.md` content remains accurate for when the merge lands.
- Remaining Blockers / User Actions:
  - **BLOCKER: REQ_001_INTEGRATION_NOT_MERGED_TO_MAIN.** Scrum Master (or whoever owns the Git control-plane merge step) must merge/fast-forward `codex/REQ-001_cupid_flutter_mobile_app-integration` (HEAD `2efa1489ef7b3ec176508801abe10fb071929026`) into `main` before `development-local` deployment can proceed. Once `main` contains that branch's history, re-dispatch DevOps to re-run `scripts/setup.sh` / `scripts/build.sh` / `scripts/start-dev.sh` against the updated `main` and record the real result.
  - Local Postgres/Redis containers from `scripts/setup.sh` were left running (idempotent local infra, matches existing dev-local policy); no other host state was left behind — `start-dev.sh`'s trap already stopped the backend dev process on exit.

## 4. History

| Date | Environment | Trigger | Result | Notes |
|------|-------------|---------|--------|-------|
| 2026-08-01 | development-local | automatic after requirement DONE | BLOCKED | `main` missing merge of `codex/REQ-001_cupid_flutter_mobile_app-integration` (13/16 stories, 5 bugfixes not on `main`); infra/build steps against `main` passed but are not representative of the DONE requirement — see §3 |
