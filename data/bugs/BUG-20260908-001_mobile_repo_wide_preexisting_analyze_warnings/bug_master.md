# Bug Master: BUG-20260908-001 Mobile Repo-Wide Pre-Existing `flutter analyze` Warnings (chat + dream_jar)

Status: PENDING
Severity: non-blocking to REQ-016 stories (pre-existing, confirmed identical at
the surfacing story's own BaseHead, out of the surfacing story's write scope);
blocking to the repo-wide `flutter analyze lib test` build-evidence gate
whenever a mobile-dev run's session executes it
Source: Alex-Mobile-Dev (mobile-dev), REQ-016/STORY-003 `Mode:
mobile-implementation` run (Phase P4), reported as `BLOCKER:
PREEXISTING_TEST_FAILURE` against the analyze command (no red test — warning-
level `flutter analyze` exit 1)
Created: 2026-09-08
Linked Requirement: N/A (pre-existing defects unrelated to REQ-016; first
surfaced during REQ-016_solo_stage1_relationship_assistant delivery)
Linked Story: surfaced by REQ-016/STORY-003_private_journal (Phase P4); may
also surface independently on REQ-016/STORY-001_activity_card_hub or any other
branch that runs the repo-wide `flutter analyze lib test`

## Report

Observed behavior:
`flutter analyze lib test` exits 1 on warning-level issues (no failing test).
Failures reproduce identically on a detached checkout of BaseHead
`03fd93743b969a4e370ad15e48458f39a503382e`, after `flutter pub get` and
`flutter gen-l10n`, so none is caused by the surfacing story:
- `flutter analyze --no-pub lib/features/chat` -> exit 1, 18 issues
- `flutter analyze --no-pub lib/features/dream_jar` -> exit 1, 21 issues

Failure anchors:
1. `unused_import '../widgets/partner_presence_chip.dart'` —
   `mobile/lib/features/chat/presentation/screens/chat_screen.dart:24:8`
2. `unused_local_variable 'titleSemanticLabel'` —
   `mobile/lib/features/chat/presentation/screens/chat_screen.dart:157:18`
3. `override_on_non_overriding_member` —
   `mobile/lib/features/chat/presentation/widgets/partner_presence_chip.dart:85:8`
4. `unused_import '../widgets/create_dream_jar_sheet.dart'` —
   `mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart:13:8`
5. ~17 `deprecated_member_use` (`withOpacity`, `activeColor`) across
   `mobile/lib/features/dream_jar/presentation/screens/*`

Expected behavior:
`flutter analyze lib test` exits 0. Each domain above needs its own
root-cause fix (remove dead imports/locals in `chat`, drop the stray
`override` annotation, replace deprecated Flutter color/checkbox APIs in
`dream_jar`) — tracked as one intake row until triaged/split by a bug-fixer.

Reproduction steps or command:
```
export PATH="${FLUTTER_SDK_PATH:-$HOME/flutter}/bin:$PATH"
cd mobile && flutter analyze lib test
```
or the two bounded per-directory commands above.

Proof this is pre-existing, not introduced by the surfacing story:
- Detached worktree at REQ-016/STORY-003 BaseHead
  `03fd93743b969a4e370ad15e48458f39a503382e`; both `chat` and `dream_jar`
  analyze runs reproduce the same warnings at identical files/line numbers.
- Touched paths are `mobile/lib/features/chat/**` and
  `mobile/lib/features/dream_jar/**`, both outside the reporting story's
  declared WriteScope (`mobile/lib/features/journal/**`, l10n ARBs, journal
  test files, and STORY-003 artifact paths).

Why not fixed inline by the reporting agent:
Each warning family needs a different fix (dead-code removal, stray override
annotation, deprecated-API migration) and none of the touched files are in
the surfacing story's declared write scope; folding unrelated fixes into a
story branch would blow story scope.

## Artifacts

- [ ] Diagnosis (Bug Fixer)
- [ ] Fix Evidence (Bug Fixer)
- [ ] Review (Reviewer)

## Routing Notes

- Current owner: scrum-master
- Next role: bug-fixer, when queued via `fix bugs` (not required to unblock
  REQ-016 story delivery — see Resolution below)
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md` (not created; needs bug-fixer triage)
- Fix Evidence: `fix-evidence.md` (not created)
- Review Report: `review/review-report.md` (not created)
- Checkpoint: tracked in
  `data/requirements/REQ-016_solo_stage1_relationship_assistant/scrum-master-checkpoint.md`
- Origin: REQ-016/STORY-003_private_journal mobile-dev run
  (`data/runtime/parallel-runs/RUN-REQ-016_solo_stage1_relationship_assistant-STORY-003-mobile-dev.json`)
- Related: `BUG-20260907-001_mobile_repo_wide_preexisting_test_failures` (same
  pre-existing/out-of-scope disposition pattern, different failure mechanism —
  full-suite `flutter test` failures vs. `flutter analyze` warnings; kept as a
  separate row per root-cause-family, not merged)

## Resolution (not yet started — non-blocking to REQ-016 delivery)

- REQ-016 story branches (STORY-001, STORY-003, and any sibling that runs the
  repo-wide `flutter analyze lib test`) may cite this bug id as the tracked,
  pre-existing, out-of-scope justification for a non-zero repo-wide analyze
  exit, and should verify their own scope via a bounded per-feature-directory
  `flutter analyze --no-pub <touched dirs>` instead of the repo-wide command
  when citing this bug in evidence.
- No `bug-fixer` dispatch is required to unblock REQ-016 delivery. Queue this
  bug through `fix bugs` when repo-wide static-analysis health work is
  prioritized.

## Blockers

- N/A
