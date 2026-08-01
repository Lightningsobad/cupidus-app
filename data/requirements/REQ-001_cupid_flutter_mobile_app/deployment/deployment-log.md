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
| development-local | automatic after requirement DONE when configured | 2026-08-01 | DEPLOYED | backend live-verified at `http://127.0.0.1:3005` during the run; no persistent endpoint (dev-local only) | Final redeploy against `main` `6e79d90` (merge + `BUG-20260801-006`/`-007` fixes) passes end-to-end: `setup.sh` PASS, `build.sh` PASS (223.4 MB debug APK), `start-dev.sh` PASS with backend readiness 200 and `flutter test` 890 passed / 0 failed — see §3 |
| staging | explicit user instruction only | | NOT_REQUESTED | | out of scope for this handoff |
| production | explicit user instruction only | | NOT_REQUESTED | | out of scope for this handoff |

## 3. Latest Attempt

- **2026-08-01 (DevOps final redeploy after readiness-gate bugfixes — current
  latest):**
- Target Environment: development-local
- Trigger: re-dispatch after `BUG-20260801-006` and `BUG-20260801-007` closed
  the prior `MOBILE_READINESS_GATE_FAILS_ON_KNOWN_TESTS` blocker
- Source State: branch `main`, clean working tree, HEAD `6e79d90`
  (`BUG-20260801-007` ARB copy fix) on top of `c71875f`
  (`BUG-20260801-006` pair-gate test seam fix), both above merge commit
  `239b2116b4d4b793e2a635fb79fa3e579448ad81`
- Commands / Steps Run:
  - `bash scripts/setup.sh` — **PASS.** Reused running Postgres/Redis for
    project `cupid-apps` on `127.0.0.1:15432` / `127.0.0.1:16379`
    (idempotent rerun confirmed again).
  - `bash scripts/build.sh` — **PASS.** Backend `npm ci` + `nest build`
    produced `backend/dist`. Mobile `flutter pub get` +
    `flutter build apk --debug` produced a real 223.4 MB
    `mobile/build/app/outputs/flutter-apk/app-debug.apk`.
  - `bash scripts/start-dev.sh` (bounded run) — **PASS, end-to-end.**
    - Backend: **PASS.** Default port busy, auto-resolved to 3005; Nest
      booted and readiness `GET http://127.0.0.1:3005/api-docs-json`
      returned 200 (`Backend ready at http://127.0.0.1:3005`).
    - Mobile: **PASS.** `flutter test` reported **890 passed, 0 failed —
      "All tests passed!"**, clearing the hard readiness gate. Script logged
      `Mobile app verified ready (home_screen_ready_signal)` and then
      `Local dev environment is up`, i.e. it reached steady state instead of
      aborting at line 69 as in the previous attempt.
    - The run was then bounded/torn down deliberately; `start-dev.sh` blocks
      on `wait` by design once the environment is up.
- Result: **DEPLOYED.** `development-local` is green end-to-end for the full
  merged 16-story requirement. Test count moved 880 passed / 2 failed ->
  890 passed / 0 failed: the 2 former failures now pass, and the 8 extra
  passing tests are the ones inside `pair_gate_cubit_test.dart` that never
  ran before because that file failed to compile.
- Fixes Applied: none by DevOps this run. The two blocking defects were fixed
  upstream through the bug queue (`BUG-20260801-006` test-only seam
  correction to `PairGateShell`; `BUG-20260801-007` ARB copy corrected to the
  STORY-009 canonical values). The `flutter test` readiness gate in
  `scripts/start-dev.sh` was never relaxed or bypassed at any point.
- Configuration Guide Updated: no — no configuration/setup gap surfaced;
  environment, scripts, ports, and secrets all behaved as documented.
- Remaining Blockers / User Actions: none for development-local.
  - Host state left behind: Postgres/Redis containers remain up (idempotent
    local infra, matches existing dev-local policy). This run's teardown was
    explicitly process-group-wide, so unlike the previous attempt **no
    orphaned backend `node .../backend/dist/main` process leaked** — ports
    3004/3005 verified free and no `cupid-apps/backend` process remains.
  - Carried-forward non-blocking note: `scripts/start-dev.sh`'s trap stops
    the `npm` parent but not the Nest child, so a plain Ctrl+C can still
    orphan the backend. Small cleanup opportunity, not a deployment blocker.
  - Staging and production remain NOT_REQUESTED (direct user instruction
    only); neither was touched.

- **2026-08-01 (DevOps redeploy against merged `main` — superseded by the
  final redeploy above):**
- Target Environment: development-local
- Trigger: re-dispatch after the integration->main merge closed the prior
  `REQ_001_INTEGRATION_NOT_MERGED_TO_MAIN` blocker
- Source State: branch `main`, clean working tree, HEAD
  `68cc985` (chore commit on top of merge commit
  `239b2116b4d4b793e2a635fb79fa3e579448ad81`)
- Commands / Steps Run:
  - `bash scripts/setup.sh` — **PASS.** Reused running Postgres/Redis for
    project `cupid-apps` on `127.0.0.1:15432` / `127.0.0.1:16379`
    (idempotent rerun confirmed again).
  - `bash scripts/build.sh` — **PASS.** Backend `npm ci` + `nest build`
    succeeded (`backend/dist` produced). Mobile `flutter pub get` +
    `flutter build apk --debug` succeeded, real 197.7 MB
    `mobile/build/app/outputs/flutter-apk/app-debug.apk` produced from the
    full merged 16-story source.
  - `bash scripts/start-dev.sh` (bounded run) — **PARTIAL.**
    - Backend: **PASS.** Default port 3004 busy, auto-resolved to 3005;
      Nest booted all modules (chat/alarms gateways, full route table) and
      readiness `GET http://127.0.0.1:3005/api-docs-json` returned 200.
    - Mobile: **FAIL.** `flutter test` ran the full suite — **880 passed,
      2 failed, across 121 test files** — exactly matching the requirement
      integration-review evidence (and no longer the prior partial 76/17).
      Because `start-dev.sh` treats `flutter test` as a hard readiness gate,
      it aborted at line 69 (`ERROR: command ""${FLUTTER}" test" failed`)
      and ran its trap to stop the backend.
- Result: **BLOCKED — MOBILE_READINESS_GATE_FAILS_ON_KNOWN_TESTS.** The merge
  gap is fully closed and `main` now builds and runs the complete requirement.
  The only thing preventing a clean `DEPLOYED` status is that the two test
  failures already accepted as "pre-existing out-of-scope" at the integration
  review are a hard gate in `scripts/start-dev.sh`.
- Failing tests (both verified byte-identical between
  `codex/REQ-001_cupid_flutter_mobile_app-integration` and `main` via
  `git diff --stat` — i.e. **pre-existing on the integration branch, not
  introduced by the merge**):
  1. `mobile/test/features/pairing/presentation/pair_gate_cubit_test.dart` —
     **compile failure**, so the whole file fails to load:
     `No named parameter with the name 'createPairGateCubit'`. The test
     harness constructs `AppShell(createPairGateCubit:, createInviteCubit:,
     createJoincodeCubit:)`, but `mobile/lib/core/navigation/app_shell.dart:49`
     declares only `partnerStore`, `chatRepository`, `coordinator`,
     `backendUserIdStore`, `consentStore`. The pairing story's test seams are
     absent from the STORY-016 version of `AppShell` that is on the branch.
  2. `mobile/test/features/reminders/reminder_copy_guard_test.dart` —
     ADR-002 copy guard (AC2/AC3) asserts no `mobile/lib` string literal
     contains `"Synced Alarm"`. It finds two:
     `lib/l10n/generated/app_l10n_vi.dart:429` and
     `lib/l10n/generated/app_l10n_en.dart:431`, both generated from the ARB
     key `notifs_row_synced_alarm_title` whose value is literally
     `"Synced Alarm"` in `mobile/lib/l10n/arb/app_en.arb:127` and
     `mobile/lib/l10n/arb/app_vi.arb:565`. This is a cross-story copy-policy
     conflict: STORY-016's notification-row label violates the reminders
     story's ADR-002 naming ban.
- Fixes Applied: none. Both failures are mobile source/copy defects
  (`mobile-dev` / `bug-fixer` scope), not deployment or configuration gaps.
  DevOps deliberately did **not** relax or bypass the `flutter test` gate in
  `scripts/start-dev.sh`, since that would mask a real failing readiness
  signal rather than fix it.
- Configuration Guide Updated: no — no configuration/setup gap surfaced; the
  environment, scripts, ports, and secrets all behaved as documented.
- Remaining Blockers / User Actions:
  - **BLOCKER: MOBILE_READINESS_GATE_FAILS_ON_KNOWN_TESTS.** Scrum Master
    decision required, since these two failures were knowingly accepted as
    "pre-existing out-of-scope" when the requirement was marked DONE, yet
    they hard-block `development-local`. Either (a) queue them as bugs and
    fix the two defects above, or (b) explicitly re-scope the dev-local
    mobile readiness signal. DevOps recommends (a): failure 1 is a stale
    test seam and failure 2 is a two-line ARB copy change, both small and
    both currently hiding a real cross-story inconsistency.
  - Host state left behind: Postgres/Redis containers remain up (idempotent
    local infra, matches existing dev-local policy). Two orphaned backend
    `node .../backend/dist/main` processes leaked from this session's bounded
    `start-dev.sh` runs (the script's trap stops the `npm` parent but not the
    Nest child) and were stopped by DevOps; ports 3004/3005 are free again.
    Worth noting as a small `scripts/start-dev.sh` cleanup gap.

- **2026-08-01 (Scrum Master Git control-plane merge, superseded by the
  redeploy above):** `codex/REQ-001_cupid_flutter_mobile_app-integration`
  (HEAD `2efa1489ef7b3ec176508801abe10fb071929026`) merged into `main` at
  merge commit `239b2116b4d4b793e2a635fb79fa3e579448ad81` (first parent prior
  `main` HEAD `c676b3e287d4da7f5695f21c1f62547161e69609`). Performed via
  `git read-tree -m --aggressive` + `git write-tree` + `git commit-tree` +
  `git merge --ff-only <raw sha>` (raw `git merge <ref>` of this branch is
  guard-blocked as `RAW_STORY_MERGE`, and no automated helper covers an
  integration->main publish step). All 13 conflicts were confined to `data/`
  tracking artifacts; zero conflicts in `mobile/`/`backend/` source. `main`
  working tree is clean; `git merge-base --is-ancestor
  codex/REQ-001_cupid_flutter_mobile_app-integration main` returns true;
  `mobile/lib/core/database/` spot-check confirms the ADR-010 canonical
  `cupid_database.dart` (no stray `app_database.dart`). Next: re-dispatch
  DevOps to re-run `scripts/setup.sh`/`build.sh`/`start-dev.sh` against this
  `main` and record the real (expected full ~880-test/121-file) result.

- **2026-08-01 (first DevOps attempt against unmerged `main` — superseded,
  retained for history):**
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
| 2026-08-01 | development-local | Scrum Master Git control-plane merge (user-approved one-off) | MERGED_TO_MAIN | integration branch merged into `main` at `239b2116b4d4b793e2a635fb79fa3e579448ad81`; DevOps redeploy against updated `main` not yet run — see §3 |
| 2026-08-01 | development-local | DevOps redeploy against merged `main` | BLOCKED | Merge gap closed and confirmed: full requirement now builds and tests on `main` (880 passed / 2 failed across 121 test files, matching integration-review evidence, vs the prior partial 76/17). `setup.sh` PASS, `build.sh` PASS (real 197.7 MB debug APK), `start-dev.sh` backend PASS (`/api-docs-json` 200 at `127.0.0.1:3005`). Blocked only by the mobile `flutter test` readiness gate failing on the 2 already-accepted out-of-scope failures (`pair_gate_cubit_test.dart` compile error vs `AppShell`; `reminder_copy_guard_test.dart` ADR-002 "Synced Alarm" token). Both verified pre-existing on the integration branch, not merge-induced — see §3 |
| 2026-08-01 | development-local | DevOps final redeploy after `BUG-20260801-006`/`-007` fixes | DEPLOYED | Green end-to-end against `main` `6e79d90`. `setup.sh` PASS, `build.sh` PASS (223.4 MB debug APK + `backend/dist`), `start-dev.sh` PASS: backend readiness `GET /api-docs-json` 200 at `127.0.0.1:3005` and mobile `flutter test` **890 passed / 0 failed**, so the readiness gate cleared and the script reached `Local dev environment is up`. Gate was fixed upstream via the bug queue, never relaxed. No blockers remain; teardown left no orphaned backend process — see §3 |
