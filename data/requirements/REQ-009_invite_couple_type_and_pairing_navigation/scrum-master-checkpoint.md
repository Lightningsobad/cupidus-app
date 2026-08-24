# Scrum Master Checkpoint — REQ-009_invite_couple_type_and_pairing_navigation

Flow: parallel-requirement (`continue parallel`)
Updated: 2026-08-25

## Active scope

- Requirement: REQ-009_invite_couple_type_and_pairing_navigation
- STORY-001_invite_couple_type_picker: DONE, merged into
  `codex/REQ-009_invite_couple_type_and_pairing_navigation-integration`.
- STORY-002_pairing_choice_navigation_restore: DONE, merged into the same
  integration branch.
- STORY-003_integration_regression_fix: landed on `main` (commit `77d575e`)
  and synced onto the integration branch; post-sync full suite verified
  1386/1386 pass (`integration-review/... ba6c81a` note).
- Requirement Integration Review (Iris-QC, `cbf2ef8`):
  `Outcome: PATCH_REQUIRED`, two blocking findings:
  - **B1** (integration build+runtime smoke against the real `mobile/lib/main.dart`
    entrypoint) — evidence landed at
    `integration-review/integration-build-runtime.md` (commit `fdd9234`, merged
    to `main` at `21c7027`, synced to the integration branch). Build+startup
    readiness PASS, no crash, backend reachable.
    **Self-disclosed partial gap, not yet surfaced to Iris-QC**: the smoke did
    not additionally drive live UI navigation to `InviteScreen` to exercise the
    `AccountRepository` GetIt resolve from a cold real launch — explicitly out
    of scope for that handoff per its own "Scope note". Flag this to Iris-QC
    when re-routing; do not treat it as silently closed.
  - **B2** (cross-screen mobile visual audit) — evidence landed
    2026-08-25: `integration-review/mobile-visual-audit.md`
    (`MOBILE_VISUAL_AUDIT: PASS`) plus 5 supporting screenshots under
    `integration-review/mobile-screenshots/` (`pairingchoice`, `invite`,
    `waiting`, `joincode`, `paired`, captured via `main_preview.dart` +
    runtime deep-link switching on `emulator-5554` by DevOps, analyzed by
    mobile-dev). Landed via ad-hoc main-based detour
    `STORY-INTEGRATION-VERIFY-002` (commit `32d3d22`, inline branch=main, no
    separate merge step) then `sync-integration` merge `8c91087` onto
    `codex/REQ-009_invite_couple_type_and_pairing_navigation-integration`.
    That sync diffed empty against the prior integration HEAD (doc/evidence
    only) — no code changed, so no re-verification of build/runtime is
    required by this sync.
  - Deferred (non-blocking, do not reopen a story lane for these): D1 (stale
    `req_master.md` `## User Stories` table — STORY-001/002 still show
    `Status: PENDING` despite `MERGE_COMPLETE`, STORY-003 missing a row
    entirely; owner: scrum-master, fold in at closure), D2 (evidence-file
    branch placement — self-resolved by landing), D3 (carried-forward
    non-blocking story-level items), D4 (reviewer two-phase
    process/guard contradiction — informational only).

## Next steps (exact, in order)

1. Delegate `Reviewer: integration-review` (Iris-QC) re-check with exact
   target `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/integration-review/review-report.md`.
   Per Iris-QC's own prior report: "the code half of this review needs no
   repeat" — only confirm B1 and B2 evidence now exist and are adequate.
   Explicitly flag the B1 partial-gap note above in the handoff so Iris-QC can
   decide whether it still blocks. Need exactly one passing
   `Outcome: CLEAN` or `Outcome: DEFERRED_ONLY` line before REQ-009 can be
   DONE.
2. Fold D1 into the closure state update: correct `req_master.md`
   `## User Stories` table (STORY-001/002 -> DONE, add STORY-003 row) as part
   of marking REQ-009 DONE, not as a separate story lane.
3. On passing review: `.claude/hooks/git-story-boundary.sh land-integration --req REQ-009_invite_couple_type_and_pairing_navigation`
   to merge the integration branch into `main` and retire the integration
   worktree/branch. Mark REQ-009 DONE in
   `data/requirements/master_requirements_list.md`.
4. Run `.claude/hooks/list-releasable-agents.sh` and `TaskStop` whatever it
   prints once Iris-QC's re-review run goes idle.
5. Emit the mandatory final wave JSON
   `{run_status, requirement_id, pending_count, reason}` —
   `REQUIREMENT_DONE` if step 3 completes this wave, `WAVE_COMPLETE` at the
   next quiescent boundary otherwise.

## Do Not Re-read

- `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-001_invite_couple_type_picker/coding-plan/test-results.md`
  and the STORY-002 equivalent — already established the scoped-`flutter
  analyze` convention; full contents not needed again.
- `mobile/pubspec.yaml`, `mobile/.gitignore`, `mobile/l10n.yaml` — l10n
  generation mechanism already root-caused; not needed again.
- `mobile/test/features/expenses/pairing_gate_test.dart` full diff — captured
  verbatim in `integration-review/mobile-fix-notes.md` and the STORY-003
  `story_master.md`.
- `integration-review/mobile-visual-audit.md` — already read in full and
  independently verified (write-scope clean, `MOBILE_VISUAL_AUDIT: PASS`,
  covers chrome/shell consistency, the couple-type block fit under restored
  navigation, back-affordance coherence, raw-capture regression sweep). Do
  not re-read; cite the verdict directly.
- `integration-review/integration-build-runtime.md` — already read in full;
  cite directly, including its own "Scope note" gap.
