# Scrum Master Checkpoint — REQ-001 Cupid Flutter Mobile App

Scope: REQ-001_cupid_flutter_mobile_app
Status: DONE. All 16/16 stories DONE and merged into
`codex/REQ-001_cupid_flutter_mobile_app-integration`. Requirement integration
review `Outcome: CLEAN`. All 5 integration bugs
(`BUG-20260801-001`..`BUG-20260801-005`) `DONE`, each with Reviewer
`Outcome: CLEAN` independently confirmed by Scrum Master. Integration Build &
Runtime evidence gate `CLEAN` (recorded in
`integration-review/review-report.md` § Integration Build & Runtime).
Requirement worktree/branch teardown complete via
`.claude/hooks/git-story-boundary.sh cleanup-requirement --req
REQ-001_cupid_flutter_mobile_app` (STORY-012's stale boundary-state flag and
two orphaned STORY-013/STORY-016 worktrees were reconciled directly against
verified git ancestry first). `req_master.md` and
`data/requirements/master_requirements_list.md` both updated to `DONE`.

## Merge to main (2026-08-01, Scrum Master Git control-plane, user-approved)
DevOps's first `development-local` attempt discovered that `main` had never
received the merge of `codex/REQ-001_cupid_flutter_mobile_app-integration`
(no automated tool covers integration->main publish; raw `git merge` of that
ref is guard-blocked as `RAW_STORY_MERGE`). User explicitly approved a
one-off manual merge. Completed via `git read-tree -m --aggressive` +
`write-tree` + `commit-tree` + `git merge --ff-only <raw sha>` (never issued
the blocked porcelain command). Result: `main` HEAD is now
`239b2116b4d4b793e2a635fb79fa3e579448ad81` (parents: prior `main`
`c676b3e287d4da7f5695f21c1f62547161e69609` and integration
`2efa1489ef7b3ec176508801abe10fb071929026`). All 13 conflicts were confined
to `data/` tracking artifacts (zero in `mobile/`/`backend/` source) and
resolved by manual per-file content review, not a blanket side preference;
full resolution rationale is in the merge commit message. Verified: `main`
working tree clean, `git merge-base --is-ancestor
codex/REQ-001_cupid_flutter_mobile_app-integration main` true,
`mobile/lib/core/database/cupid_database.dart` present (ADR-010 canonical,
no stray `app_database.dart`). `req_master.md` § Deployment Status and
`deployment/deployment-log.md` §§ 2-4 updated to record this.

## DevOps redeploy result (2026-08-01, against merged main) — BLOCKED
Frank-Devops re-ran `development-local` against `main` at
`68cc985` (on top of merge commit `239b2116b4d4b793e2a635fb79fa3e579448ad81`).
`setup.sh` PASS, `build.sh` PASS (real 197.7 MB debug APK from the full
merged 16-story source), `start-dev.sh` backend PASS
(`GET /api-docs-json` 200 at `127.0.0.1:3005`). `flutter test` ran the full
suite — **880 passed / 2 failed across 121 test files**, matching the
integration-review evidence exactly (merge gap fully closed and confirmed).
`start-dev.sh` hard-gates on `flutter test`, so it exits non-zero on those 2
failures and the run is `BLOCKED — MOBILE_READINESS_GATE_FAILS_ON_KNOWN_TESTS`.
Both failures verified byte-identical between the integration branch and
`main` (pre-existing, not merge-induced) — the same 2 failures already
accepted as "pre-existing out-of-scope" when REQ-001 was marked DONE:
1. `mobile/test/features/pairing/presentation/pair_gate_cubit_test.dart` —
   compile failure: test constructs `AppShell(createPairGateCubit:,
   createInviteCubit:, createJoincodeCubit:)` but
   `mobile/lib/core/navigation/app_shell.dart:49` no longer declares those
   params (only `partnerStore`, `chatRepository`, `coordinator`,
   `backendUserIdStore`, `consentStore`) — stale test seam vs STORY-016's
   `AppShell`.
2. `mobile/test/features/reminders/reminder_copy_guard_test.dart` — ADR-002
   copy guard bans the literal `"Synced Alarm"` anywhere in `mobile/lib`;
   STORY-016's ARB key `notifs_row_synced_alarm_title` (`app_en.arb:127`,
   `app_vi.arb:565`) reintroduces it into generated l10n
   (`app_l10n_{vi,en}.dart`).
DevOps applied no fix (mobile source/copy defects, not deployment scope) and
did not relax the `flutter test` gate. Full detail in
`deployment/deployment-log.md` § Latest Attempt (2026-08-01, "DevOps
redeploy against merged main"). Both `req_master.md` § Deployment Status and
`deployment-log.md` are already updated by Frank-Devops with this result —
do not re-verify.
Host state: Postgres/Redis idempotent-left-up (existing policy); two
orphaned backend `node .../backend/dist/main` processes from the bounded
runs were stopped by DevOps, ports 3004/3005 free again.

## User decision (2026-08-01): queue as bugs and fix
User selected "Queue as bugs and fix" over re-scoping the gate or stopping.
Two bugs registered in `data/bugs/master_bugs_list.md` (both `PENDING`, both
`Linked Requirement: REQ-001_cupid_flutter_mobile_app`), each with full
reproduction/failure-anchor/constraints in its `bug_master.md`:
- `BUG-20260801-006_pair_gate_cubit_test_stale_app_shell_seam`
- `BUG-20260801-007_reminder_copy_guard_synced_alarm_violation`
Both must be fixed on `main` directly (no dedicated worktree — REQ-001's
story/integration worktrees are already torn down and this is standalone bug
scope, not story work). Recorded via commit `71698a0` (blocker) and the bug
artifacts above (not yet committed as of this checkpoint edit — commit next).

Both bugs completed: `BUG-20260801-006` DONE (commit `c71875f`, Reviewer
Iris-QC `Outcome: CLEAN`), `BUG-20260801-007` DONE (commit `6e79d90`,
Reviewer Iris-QC-3 `Outcome: CLEAN`), both independently confirmed by Scrum
Master.

## Final DevOps redeploy (2026-08-01) — DEPLOYED
Frank-Devops-3 re-ran `development-local` against `main` HEAD `6e79d90`:
`setup.sh` PASS, `build.sh` PASS (223.4 MB debug APK), `start-dev.sh` PASS
end-to-end — backend readiness 200 at `127.0.0.1:3005`, mobile
`flutter test` **890 passed / 0 failed**, script reached `Local dev
environment is up`. `MOBILE_READINESS_GATE_FAILS_ON_KNOWN_TESTS` is
resolved (fixed upstream via the bug queue, gate never relaxed). No
orphaned processes left; Postgres/Redis remain up per existing idempotent
dev-local policy. `req_master.md` § Deployment Status and
`deployment-log.md` §§ 2-4 already updated by Frank-Devops-3 — do not
re-verify.

## Post-DONE operational tooling addition (2026-08-01): scripts/run-mobile.sh
User reported a real gap after DEPLOYED: no script existed to launch the app
on an Android emulator or iOS Simulator (`runtime-command-registry.json`'s
`mobile-app.notes` had documented this as an accepted, by-design limitation).
User explicitly chose "add a small devops script now" over opening a new
requirement or deferring. Routed directly to DevOps (`Frank-Devops-4`),
scoped to REQ-001, no story worktree (operational tooling on `main`
directly, `Flow: deploy`).
Delivered: `scripts/run-mobile.sh <android|ios> [--avd|--udid] [-- <flutter
run args>]` — boots an AVD (`emulator -avd`) or Simulator (`xcrun simctl
boot`) if none is online, polls (bounded, 180s) until `flutter devices`
reports it, then hands off to a foreground `flutter run -d <device>`
session; new `android_sdk_root()`/`android_tool()` helpers added to
`scripts/lib/common.sh` (PATH, then `$ANDROID_HOME`/`$ANDROID_SDK_ROOT`,
then per-OS default install dirs, mirroring the existing `flutter_bin()`
convention); `runtime-command-registry.json`'s `mobile-app` runtime gained a
`launch` block (subcommands, options, typed blockers, verification method)
and its `notes` field now points at the new script instead of describing
the gap; `deployment/configuration-guide.md` gained a "Launching The App On
An Emulator / Simulator" section and its QA/backend-URL command examples now
use `scripts/run-mobile.sh android -- --dart-define=...` instead of bare
`flutter run`, plus a documented AVD-disk-sizing caveat DevOps hit during
verification (`java.io.IOException: Requested internal only, but not enough
space` — an AVD `/data` sizing issue, not a script defect).
Independently verified by Scrum Master (not just DevOps's report):
`bash -n scripts/run-mobile.sh` and `scripts/lib/common.sh` both pass,
executable bit set (755), `git diff` scope confirmed as exactly these 4
files with no unrelated changes. Committed as `1226fbf` (control-plane
commit directly on `main`, no story boundary applicable — see AGENTS.md Git
Boundary rule: this is operational tooling, not story delivery). This is
deliberately NOT wired into `scripts/start-dev.sh`'s headless readiness gate
(`flutter run` is inherently interactive); the readiness gate contract is
unchanged.

## Next valid step
REQ-001 is fully closed: 16/16 stories DONE, integration review CLEAN, all 7
linked bugs (`BUG-20260801-001`..`007`) DONE with Reviewer `Outcome: CLEAN`,
`development-local` DEPLOYED, and the post-deploy emulator/simulator launch
tooling gap is now closed via `scripts/run-mobile.sh` (commit `1226fbf`). No
further action needed on this requirement. Staging/production remain
NOT_REQUESTED (direct-instruction-only; do not deploy there without an
explicit user request).

## Do Not Re-read
- Do not re-read `integration-review/review-report.md` in full — its content
  (requirement integration review CLEAN + Integration Build & Runtime CLEAN)
  is already summarized above and in `req_master.md`.
- Do not re-run or re-verify any of the 7 bug fixes/reviews; all `DONE`,
  `Outcome: CLEAN`, independently confirmed. See `data/bugs/master_bugs_list.md`.
- Do not re-run `git-story-boundary.sh cleanup-requirement` for REQ-001;
  teardown already confirmed clean (`git worktree list` shows only the
  control checkout and unrelated worktrees remain).
- Do not re-litigate the integration->main merge or the two final
  redeploy attempts; all complete and verified as described above.
- Do not re-verify `scripts/run-mobile.sh`/`common.sh`/registry/config-guide
  changes again; already independently confirmed and committed as `1226fbf`.
