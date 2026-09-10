# Bug Master: BUG-20260908-001 Mobile Repo-Wide Pre-Existing `flutter analyze` Warnings (widened: full 191-issue baseline, ~15 directories)

Status: PENDING
Severity: non-blocking to REQ-016 stories (pre-existing, confirmed identical at
each surfacing story's own BaseHead, out of the surfacing story's write scope);
blocking to the repo-wide `flutter analyze lib test` build-evidence gate
(`verify-implementation-build-runtime-gate.sh`, code `BUILD_FAILED_BUT_COMPLETE`)
whenever a mobile-dev run's session cites the bare command and then reports a
completion marker
Source: Alex-Mobile-Dev (mobile-dev). Originally opened from REQ-016/STORY-003
`Mode: mobile-implementation` run (Phase P4), 39 issues in `chat`+`dream_jar`.
Widened 2026-09-10 from REQ-016/STORY-001 `Mode: mobile-implementation` run
(Phase P14): full `flutter analyze lib test` measures 191 issues, 0 errors,
across ~15 directories — the original 39 are a confirmed subset, not the
whole set. Both reports were `BLOCKER: PREEXISTING_TEST_FAILURE` (no red test
— info/warning-level `flutter analyze` exit 1).
Created: 2026-09-08. Widened: 2026-09-10.
Linked Requirement: N/A (pre-existing defects unrelated to REQ-016; first
surfaced during REQ-016_solo_stage1_relationship_assistant delivery)
Linked Story: surfaced by REQ-016/STORY-003_private_journal (Phase P4);
confirmed to also surface on REQ-016/STORY-001_activity_card_hub (Phase P14,
BaseHead `59d856478a7ee01cb644a7136099b29c9edbaed9`, delta 0 new issues from
P14's own diff — 1 pre-existing line shifted `:75:9`->`:76:9` in a file P14
touched, same rule/message, not a P14-introduced issue); will surface on any
branch that runs the repo-wide `flutter analyze lib test`

## Report

Observed behavior (original, chat+dream_jar subset):
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

Observed behavior (widened, full baseline, reported by Alex-Mobile-Dev from
REQ-016/STORY-001 Phase P14, BaseHead `59d856478a7ee01cb644a7136099b29c9edbaed9`,
measured on a detached checkout after `pub get`+`gen-l10n`, and re-measured
identically post-P14 with a 0-issue delta):
- `flutter analyze lib test` -> exit 1, **191 issues, 0 errors** (all
  info/warning severity), spread across ~15 directories: `core/auth`,
  `core/navigation`, `core/realtime`, `core/content`, `features/auth`,
  `features/chat`, `features/dream_jar`, `features/reminders`,
  `features/emojis`, `features/gallery`, `features/home`, and more.
- Dominant rule families (approximate, not yet triaged per-file): 92
  `prefer_initializing_formals`, 27 `deprecated_member_use`, 9
  `use_null_aware_elements`, 9 `unnecessary_underscores`, plus the original
  chat/dream_jar anchors below.
- The original 39-issue chat+dream_jar set is a confirmed subset of these 191
  (same command, same severity profile, same pre-existing/out-of-scope
  disposition) — not a separate root-cause family, so this stays one bug row,
  widened rather than split.

Expected behavior:
`flutter analyze lib test` exits 0. **Fixing only chat+dream_jar (the
original 39) will not achieve this** — 152 further issues remain across ~13
other directories. Each domain needs its own root-cause fix (remove dead
imports/locals in `chat`, drop the stray `override` annotation, replace
deprecated Flutter color/checkbox APIs in `dream_jar`, add initializing
formals / null-aware elements / drop stray underscores elsewhere) — tracked
as one intake row until triaged/split by a bug-fixer. Until this is fully
cleaned up, the repo-wide `flutter analyze lib test` build-evidence gate will
non-zero-exit for every mobile-dev session that cites the bare command
alongside a completion marker (guard `BUILD_FAILED_BUT_COMPLETE`); Scrum
Master's practical workaround per session is to have the specialist verify
scope with a bounded per-directory `flutter analyze --no-pub <touched dirs>`
and report `BLOCKER: PREEXISTING_TEST_FAILURE` citing this bug id instead of
a bare completion marker over the repo-wide command.

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
- Widened proof: detached worktree at REQ-016/STORY-001 BaseHead
  `59d856478a7ee01cb644a7136099b29c9edbaed9` (post `pub get`+`gen-l10n`) ->
  191 issues, 0 errors. Post-P14 in the live story worktree -> 191 issues, 0
  errors. Sorted diff of the two runs is exactly one line, same
  file/rule/message (only the reported column shifted `:75:9`->`:76:9` in a
  file P14's diff touches) — P14 adds 0 new analyze issues. 190 of the 191
  issues are outside Alex-Mobile-Dev's declared STORY-001 P14 WriteScope
  (§13.7, 7 files); the 1 remaining (`prefer_initializing_formals`,
  `activity_card_detail_cubit.dart:76:9`) is pre-existing in a file the
  WriteScope touches but is not part of the P14 diff itself.

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
  (`data/runtime/parallel-runs/RUN-REQ-016_solo_stage1_relationship_assistant-STORY-003-mobile-dev.json`).
  Widened by REQ-016/STORY-001 Phase P14 mobile-dev run
  (`Alex-Mobile-Dev`, `SendMessage` msg `5370e892`, 2026-09-10).
- Related: `BUG-20260907-001_mobile_repo_wide_preexisting_test_failures` (same
  pre-existing/out-of-scope disposition pattern, different failure mechanism —
  full-suite `flutter test` failures vs. `flutter analyze` warnings; kept as a
  separate row per root-cause-family, not merged)
- Related guard: `.claude/hooks/verify-implementation-build-runtime-gate.sh`,
  code `BUILD_FAILED_BUT_COMPLETE` — fires whenever a mobile-dev session cites
  the bare `flutter analyze lib test` command and then reports a completion
  marker, since the command's real exit code is non-zero regardless of
  severity. The gate's own fix text is: if the command already failed at
  BaseHead outside WriteScope, the specialist stops with `BLOCKER:
  PREEXISTING_TEST_FAILURE` (command, failing assertion, BaseHead proof,
  out-of-scope path) instead of a completion marker, and Scrum Master opens
  or widens a bug and re-dispatches — this is that step for STORY-001 P14.

## Resolution (not yet started — non-blocking to REQ-016 delivery)

- REQ-016 story branches (STORY-001, STORY-003, and any sibling that runs the
  repo-wide `flutter analyze lib test`) may cite this bug id as the tracked,
  pre-existing, out-of-scope justification for a non-zero repo-wide analyze
  exit, and should verify their own scope via a bounded per-feature-directory
  `flutter analyze --no-pub <touched dirs>` instead of the repo-wide command
  when citing this bug in evidence, and should report a `BLOCKER:
  PREEXISTING_TEST_FAILURE` citing this bug id rather than a bare completion
  marker over the repo-wide command, to avoid tripping
  `BUILD_FAILED_BUT_COMPLETE`.
- No `bug-fixer` dispatch is required to unblock REQ-016 delivery. Queue this
  bug through `fix bugs` when repo-wide static-analysis health work is
  prioritized — full cleanup now spans ~15 directories (191 issues), not just
  chat+dream_jar (39); a bug-fixer will likely want to split this into
  per-directory sub-fixes rather than one patch.
- Analyze-command standardization (e.g. `--no-fatal-infos --no-fatal-warnings`
  with a zero-error grep as the real gate condition) is a devops/build-gate
  policy change, not a bugfix — out of scope for this bug row and out of
  scope for Scrum Master to decide unilaterally mid-story. Not actioned here.

## Blockers

- N/A
