# Scrum Master Checkpoint — REQ-009_invite_couple_type_and_pairing_navigation

Flow: parallel-requirement (`continue parallel`)
Updated: 2026-08-24

## Active scope

- Requirement: REQ-009_invite_couple_type_and_pairing_navigation
- STORY-001_invite_couple_type_picker: DONE, merged into
  `codex/REQ-009_invite_couple_type_and_pairing_navigation-integration`
  (`MERGE_COMPLETE: true`).
- STORY-002_pairing_choice_navigation_restore: DONE, merged into the same
  integration branch (`MERGE_COMPLETE: true`).
- STORY-003_integration_regression_fix: ad-hoc `Story-Class: standard`,
  `Depends-On: NONE` regression fix (not new product scope). Root cause:
  STORY-001 added a GetIt-resolved `AccountRepository` dependency at
  `InviteScreen._defaultInviteCubit`; the pre-existing unrelated
  `mobile/test/features/expenses/pairing_gate_test.dart` navigates into
  `InviteScreen` and never registered that dependency in its own GetIt
  fixture. Found by the mandatory full `flutter test --no-pub` integration
  verification run (1385 tests, 1384 passed, this 1 genuine regression).
  Fixed (test-only, no production change) by Alex-Mobile-Dev-3 in the
  integration worktree, independently re-verified by Scrum Master.

## STORY-003 Git-boundary detour (read before touching STORY-003 further)

Two guards forced a detour from "commit directly on the integration branch":

- `guard-orphan-commit.sh [EPHEMERAL_BRANCH_COMMIT]` blocks raw
  `git add`/`git commit` on any `codex/*` branch, including the integration
  branch, even for Scrum-Master orchestration commits.
- `git-story-boundary.sh start` for a brand-new story id with no explicit
  clean target defaults to a fresh worktree/branch off `main`; it cannot
  reuse the integration worktree in place while uncommitted changes sit
  there, and once a boundary is recorded for a story id it cannot be
  redirected to a different branch (`BOUNDARY_STATE_MISMATCH`) or cleaned up
  before `MERGE_COMPLETE` (`cleanup` refuses).

Resolution taken: the identical, already-verified fix diff was re-applied
onto a dedicated `main`-based story worktree/branch
(`codex/REQ-009_invite_couple_type_and_pairing_navigation-STORY-003_integration_regression_fix`,
worktree `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-009_invite_couple_type_and_pairing_navigation-STORY-003_integration_regression_fix`),
independently re-verified there (`flutter test --no-pub test/features/expenses`
59/59, `flutter analyze --no-pub test/features/expenses/pairing_gate_test.dart`
clean), and committed via `git-story-boundary.sh commit`
(commit `77d575e`). `MergeTarget: main` (the boundary's default — not the
integration branch).

Full diagnosis/evidence:
`data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/integration-review/mobile-fix-notes.md`
(committed on the STORY-003 branch, not yet on main or the integration
branch).

## Next steps (exact, in order)

1. `.claude/hooks/git-story-boundary.sh merge --req REQ-009_invite_couple_type_and_pairing_navigation --story STORY-003_integration_regression_fix`
   to merge the STORY-003 branch into `main`. (First attempt blocked on a
   dirty control checkout from this checkpoint edit itself — resolved by
   this commit.)
2. `.claude/hooks/git-story-boundary.sh complete --req REQ-009_invite_couple_type_and_pairing_navigation --story STORY-003_integration_regression_fix`
3. `.claude/hooks/git-story-boundary.sh sync-integration --req REQ-009_invite_couple_type_and_pairing_navigation`
   to carry the STORY-003 fix (now on `main`) onto
   `codex/REQ-009_invite_couple_type_and_pairing_navigation-integration`.
4. Re-run the full `flutter test --no-pub` suite in the integration worktree
   once more after sync-integration to confirm 1385/1385 pass (the original
   failure closed, no new regression from the sync merge).
5. Discard the now-redundant duplicate uncommitted changes still sitting in
   the integration worktree
   (`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-009_invite_couple_type_and_pairing_navigation`:
   modified `mobile/test/features/expenses/pairing_gate_test.dart`, untracked
   `data/requirements/.../STORY-003_integration_regression_fix/`,
   `data/requirements/.../integration-review/`) — they will have arrived via
   the sync-integration merge instead. Verify with `git status --porcelain`
   before discarding that the content matches what the merge brought in.
6. Delegate `Reviewer: integration-review` (Iris-QC) with exact target
   `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/integration-review/review-report.md`,
   scoped to STORY-001 + STORY-002 + STORY-003 on the integration branch.
   Need exactly one passing `Outcome: CLEAN` or `Outcome: DEFERRED_ONLY` line
   before REQ-009 can be DONE.
7. On passing review: `.claude/hooks/git-story-boundary.sh land-integration --req REQ-009_invite_couple_type_and_pairing_navigation`
   to merge the integration branch into `main` and retire the integration
   worktree/branch. Mark REQ-009 DONE in
   `data/requirements/master_requirements_list.md`.
8. Run `.claude/hooks/list-releasable-agents.sh` and `TaskStop` whatever it
   prints (expect `Alex-Mobile-Dev-3` once its run is fully reconciled).
9. Emit the mandatory final wave JSON
   `{run_status, requirement_id, pending_count, reason}` —
   `REQUIREMENT_DONE` if step 7 completes, `WAVE_COMPLETE` at the next
   quiescent boundary otherwise.

## Do Not Re-read

- `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-001_invite_couple_type_picker/coding-plan/test-results.md`
  and the STORY-002 equivalent — already established the scoped-`flutter
  analyze` convention; full contents not needed again.
- `mobile/pubspec.yaml`, `mobile/.gitignore`, `mobile/l10n.yaml` — l10n
  generation mechanism already root-caused (physical `app_l10n.dart` is only
  materialized by the `flutter assemble` pipeline via `flutter test`/`build`/
  `run`, never `pub get` or standalone `flutter gen-l10n`; scoped analyze and
  `flutter test` do not require the physical file).
- `mobile/test/features/expenses/pairing_gate_test.dart` full diff — captured
  verbatim in `integration-review/mobile-fix-notes.md` and the STORY-003
  `story_master.md`.
