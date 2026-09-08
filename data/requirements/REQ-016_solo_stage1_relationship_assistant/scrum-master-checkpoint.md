# Scrum Master Checkpoint: REQ-016 Solo Stage-1 relationship assistant

Updated: 2026-09-08 (session 798d014f, continue parallel wave, post
final-synthesis/tech-lead-F-B3/STORY-001-P6 sync)
Requirement Status: IN_PROGRESS.

All phase-by-phase history through STORY-001 P7 and STORY-003 P4 is DONE,
committed, and superseded by artifacts — do not replay it here. Source of
truth for closed work: each story's `coding-plan/master-plan.md` Phase
Overview table (Status column), `visual-fidelity/visual-fidelity-report.md`,
and `req_master.md` `## Design Ruling Log` (D-1..D-8). Closed bugs:
`BUG-20260907-002` (DONE). Open, non-blocking bugs:
`BUG-20260907-001` (repo-wide `flutter test` pre-existing failures),
`BUG-20260908-001` (repo-wide `flutter analyze` pre-existing chat/dream_jar
warnings) — cite either instead of re-running the repo-wide command.

## Story Graph (from `requirements/requirements.md` -> `## Story Order And Dependencies`)

| Story | Depends On | Story-Class |
|---|---|---|
| STORY-001 | NONE | shared-foundation |
| STORY-002 | STORY-001 | standard |
| STORY-003 | NONE | standard |
| STORY-004 | STORY-001 | standard |
| STORY-005 | STORY-001, STORY-004 | standard |
| STORY-006 | STORY-001 | standard |
| STORY-007 | STORY-001, STORY-002, STORY-003, STORY-005 | standard |
| STORY-008 | STORY-001, STORY-002, STORY-003, STORY-004 | standard |
| STORY-009 | STORY-004 | standard |
| STORY-010 | STORY-004 | standard |
| STORY-011 | STORY-001, STORY-004, STORY-005, STORY-008 | standard |
| STORY-012 | STORY-001 | standard |
| STORY-013 | STORY-001, STORY-004 | standard |

STORY-001 is shared-foundation: it must reach `MERGE_COMPLETE` into
`codex/REQ-016_solo_stage1_relationship_assistant-integration` before
STORY-002/004/006/012 (and transitively 005/007/008/009/010/011/013) become
schedulable. STORY-003 has no dependents and can merge independently. Only
STORY-001 and STORY-003 are currently in flight; all others wait.

## KNOWN MERGE COLLISION (flag before either story merges, not yet hit)

Both STORY-001 P1 and STORY-003 P1 independently bump
`mobile/lib/core/database/cupid_database.dart` `schemaVersion` 2->3 with their
own additive `onUpgrade` branch, in separate worktrees/branches. Whichever
story's branch merges into `codex/REQ-016_solo_stage1_relationship_assistant-integration`
SECOND will conflict on this file. Scrum Master resolves this directly at
merge time (Git-orchestration rule — do not delegate): combine both
`if (from < 3)` migration branches into one, keep schemaVersion at 3, and
re-run each story's own migration test against the combined schema before
completing the merge. Also fix two out-of-WriteScope hardcoded schemaVersion
literal assertions once schemaVersion is 3:
`mobile/test/core/database/timeline_dao_test.dart:36` and
`mobile/test/core/database/expense_dao_test.dart:37` (both currently assert
stale values; no behavior assertions affected).

Non-blocking merge note: STORY-001 P5 and STORY-003 P5 both touch
`mobile/lib/l10n/app_vi.arb`/`app_en.arb` for different keys — fine since
never run concurrently (`MAX_CODE_WRITERS_PER_STORY=1`), just don't collapse
their arb edits into one commit at merge.

## Current Runs (this wave)

- STORY-001: ALL 7 PHASES (P1-P7) DONE per `coding-plan/master-plan.md`
  Phases Overview table. P6 (`phase-P6-card-detail-lifecycle-delete.md`)
  verified against declared WriteScope and committed `884846f`. BaseHead
  refreshed to `884846f4afc0ca2f8d4103f54cce8e2c43b4c129`. P6's own
  `next_step` flagged two open follow-ups, NOT YET TRIAGED:
  (a) the P2 repository contract has no field-write path, so scheduled
  dates and field edits live only in the detail cubit, not persisted via
  the repository; (b) the detail screen still has no route wired since
  `activity_card_hub_view.dart` is outside every phase's write scope so
  far. Decide before the story's final Reviewer gate: acceptable seams to
  note, or a new patch/phase required.
  D-8 is CLOSED (`req_master.md` row updated + committed `9c36bff`,
  decided by `brainstormer` 2026-09-08): the original line numbers
  (125/141/152/160) were wrong; correct source lines are 156/172/183/191.
  Of the 4 flagged words, 2 already map to existing AC-8 fields (trong
  nhà/ngoài trời; ghi chú free-text), 1 (weather) is rejected as it would
  need a runtime API violating R-7/SB-211, and only 1 real signal (coarse
  time-of-day chip) is deferred to a future STORY-012-area requirement
  since REQ-016 has no consumer for it. **No STORY-001 patch phase
  needed** — no field/column/enum change.
  P5 also logged 5 new DESIGN_SPEC_CONFLICT deltas (D-9..D-13) for PO,
  non-blocking. `activity_card_hub_view.dart` still does not mount the P5
  widgets or route to the P6 detail screen (outside every phase's write
  scope so far) — a later integration phase must do that mount (same
  root cause as follow-up (b) above).

  `Reviewer: full-story-review` (`Iris-QC`, RunId
  `RUN-...-STORY-001-reviewer`) DONE: `Outcome: BLOCKED` /
  `REVIEW_SCOPE_TOO_BROAD` (44 source/test/config files + 3 oversized
  artifacts vs. budget of 12/2 — 3.7x over, same structural cause as
  STORY-003's sibling situation: no incremental per-phase review ran across
  P1-P7). `scope-gate.md` + `review-report.md` committed `f3d9bea`.
  Prescribes an **8-pass plan**: S1-S7 `Mode: scoped-slice` + S8
  `Mode: final-synthesis`, one at a time (`story-state:STORY-001` lock):
  - S1 = P1 local card store (9 files, schema/DAO/migration)
  - S2 = P2 domain repository + P7 ActivityType (9 files) — owns FLAG-1 first half
  - S3 = P3 occasion content package (6 files)
  - S4 = P4 hub list/buckets/entry point (9 files) — owns FLAG-2
  - S5 = P5 minute-one empty state + quick capture (5 files)
  - S6 = P6 detail/lifecycle/delete (6 files) — owns FLAG-1 second half + verdict
  - S7 = visual fidelity images + entry-point/runtime evidence (artifacts only)
  - S8 = final-synthesis, reads only slice-1..7 reports

  **Critical carry-forward notes from the scope gate:**
  - AC source of truth is **`requirements/requirements.md`** (AC-10..AC-15),
    NOT `story_master.md` (only has AC-1..AC-7). `master-plan.md` §3A binds
    AC-15 ("mất dữ liệu âm thầm khi lùi trạng thái" / silent data loss on
    status rollback) to exactly P2+P6.
  - **FLAG-1** (repository has no field-write path — the P6 follow-up (a)
    below): S2 establishes the actual contract surface, S6 establishes what
    the detail screen does with it and issues the classification per
    AC-10..AC-15 + master-plan §3A.
  - **FLAG-2** (hub view mounts neither P5 nor P6 — the P6 follow-up (b)
    below, same root cause as the P5 "not yet mounted" note): S4 owns this
    against rule 12e1. Test: if AC-1/AC-2/AC-4/AC-7 can be exercised ONLY via
    direct widget-test mounting and never via the real menu-driven user path,
    that is `PATCH_REQUIRED` (rule 12e1), not an acceptable staged-rollout gap.
  - S7: 4 design references but 9 implemented captures exist (round2/3/4
    retries + one device variant) — must pin the authoritative capture per
    screen before any comparison. Re-assess whether the top-line
    `VISUAL_FIDELITY: FAIL` (held only because D-8 was open) should now read
    PASS given D-8 closed 2026-09-08 with no code change required, or must
    stay FAIL/PARTIAL on an independent ground in the 14 D-14..D-27 deltas.

  **S1 dispatched** (`Iris-QC-2`, RunId `RUN-...-STORY-001-reviewer-s1`,
  BaseHead `9207f7296a64cd37ca60e432939469ca96860762` — the merge-base, same
  diff baseline as the full-story-review pass, NOT the boundary's
  latest-worktree-HEAD value). Output:
  `review/slice-1-p1-local-card-store.md`. IN FLIGHT.

- STORY-003: ALL PHASES P1-P5 DONE, committed (P5 = commit `c72a2ed`,
  BaseHead `c72a2edae6560e5068a4b3d6f1f4fb9249731d6a`). First review
  attempt (`Mode: compact-story-review`, run
  `RUN-...-STORY-003-reviewer`) returned `Outcome: BLOCKED` /
  `REVIEW_SCOPE_TOO_BROAD` (this story has never had an incremental
  per-phase review — the diff at the branch-point BaseHead is 50 files,
  9802/-542, ~4x the compact budget) — its `review/review-report.md` +
  `scope-gate.md` are committed as `3af11b1`. That report independently
  adjudicated the P5 `openJournalScreen` contract question as **WITHIN
  CONTRACT INTENT, settled, do not reopen**, and prescribed a 5-slice
  re-review (same BaseHead `62f451733d191b666b718b595ead4621676e3e1c`):
  A=P1 schema/migration, B=P2 media-store+backup (carry forward
  `OS_BACKUP_EXCLUSION_UNVERIFIED` iOS-half as an already-tracked
  residual, do not re-litigate), C=P3 list+delete, D=P4 composer,
  E=P5 entry-point+menu (contract question already settled) — each
  `Mode: scoped-slice` returning `PARTIAL_SLICE_ONLY`, then F=
  `Mode: final-synthesis` reading only the 5 slice reports +
  `visual-fidelity/visual-fidelity-report.md` for the one story-level
  verdict. All 5 slice runs are registered
  (`RUN-...-STORY-003-reviewer-sliceA` through `sliceE`). Slices B-E are
  NOT concurrent: `guard-parallel-spawn.sh` enforces one lock holder for
  `story-state:STORY-003` at a time (all 5 slices share the one STORY-003
  worktree), so each must be dispatched only after the prior slice's run
  file goes `COMPLETED`.

  Slice A (schema/migration, `Iris-QC-2`) is DONE:
  `PARTIAL_SLICE_ONLY`, 6/9 PASS, one must-fix (RA-7: two out-of-scope
  test files still asserted stale `schemaVersion == 2`), one known merge
  item (RA-8, matches the KNOWN MERGE COLLISION section above), one
  deferred low-severity item (RA-9, missing indexes). RA-7 already FIXED
  by Scrum Master directly (`fcc5066`, verified
  `flutter test test/core/database/{timeline,expense}_dao_test.dart` ->
  15/15 pass) — checked STORY-001's worktree copies of both files too,
  they already assert `3`, no fix needed there. Slice A report committed
  `022ecf4`.

  Slice B (media-store+backup, `Iris-QC-3`) is DONE: `PARTIAL_SLICE_ONLY`,
  3 must-fix, report committed `23883d4`. iOS media backup exclusion
  confirmed RESOLVED (closes the previously tracked
  `OS_BACKUP_EXCLUSION_UNVERIFIED` media gap — do not re-open). Real,
  unfixed implementation findings for final-synthesis/PO-Techlead to
  route (Scrum Master does NOT patch these — they are inside the mobile-dev
  P2 lane, not out-of-scope literals like RA-7 was):
  - **F-B1** (most severe): journal media root is flat/device-wide, not
    owner-scoped; switching accounts and opening the journal deletes the
    other account's photo files while their DB rows survive pointing at
    empty files. No multi-owner test exists. Direct AC-2 privacy
    violation.
  - **F-B2**: editing an entry's photos leaves old files orphaned
    (`saveEntry` replaces the `journal_photos` rows but not the files;
    `sweepOrphans` only scans at folder granularity). Trigger path is via
    P4's composer — sizing/severity to be finished once slice D lands.
  - **F-B3**: iOS `cupid.sqlite` (journal text/content) is NOT
    backup-excluded, only the iOS media root is — new coverage asymmetry,
    needs a Tech Lead decision (tag file vs. move DB to Application
    Support + migration).
  Slice C (P3 list+delete, `Iris-QC-4`) is DONE: `PARTIAL_SLICE_ONLY`, 0
  must-fix, all 4 gates PASS with test enforcement, report committed
  `a5aaa36`. 3 carry-forward notes: F-C1 (low, `onSelected` discards menu
  value — safe today, single-row menus), F-C2 (slice E must confirm P5
  actually wired the compose CTA, which is a no-op stub at P3 head),
  F-B1-reaches-AC-5 (confirms `deleteAll` also delegates into slice B's
  not-owner-scoped media path — same F-B1 fix, no new fix needed). Also
  noted: `story_master.md` numbers AC-1..AC-5 while code/plan cite the
  requirement-level AC-6..AC-14 expansion — traceability friction for
  final-synthesis, not a defect.
  Slice D (P4 composer, `Iris-QC-5`) is DONE: `PARTIAL_SLICE_ONLY`, 5 PASS
  (incl. R-D4 confirming F-B2's normal edit path is self-compensated),
  1 medium FAIL (new), report committed `48896ad`.
  - **F-D1** (medium, new): `journal_composer_cubit.dart` `canSave`
    (:52-53) omits an `isReady` guard, and the screen never reads
    `isReady` either. Edit-mode's `_loadExisting()` (:130) is fired
    un-awaited; if the user types before it resolves, Save becomes
    enabled and overwrites the entry with the just-typed text plus an
    empty photo list — losing the original body irrecoverably and
    orphaning its photos (this IS a live F-B2 trigger path, unlike the
    normal edit path R-D4 confirmed is safe). No test covers this
    window. Suggested one-line fix (not applied — mobile-dev lane owns
    it): add `isReady &&` to `canSave`.
  - F-D2 (trivial): source comments cite AC-6/AC-13, not in
    `story_master.md`'s 5-item AC list; traceability only.
  Slice E (P5 entry-point+menu, `Iris-QC-6`) is DONE: `PARTIAL_SLICE_ONLY`,
  3 PASS (R-E1 contract surface, R-E2 discoverability/navigation, R-E3
  confirms F-C2 CLOSED — the list's compose CTA is wired at the
  construction site in `journal_entry_point.dart`), 0 must-fix, report
  committed `61dc70c`. All 5 slices (A-E) are now closed.

  `Reviewer: final-synthesis` (`Iris-QC-7`) DONE: `Outcome: PATCH_REQUIRED`,
  report committed `d88a298` (`review/review-report.md`, overwrote the old
  BLOCKED record; a stray tool-call XML artifact leaked into the file by
  the reviewer was cleaned up by Scrum Master directly before commit — a
  write-corruption fix, not a content/judgment change). Outcome summary: 6
  blocking / 8 deferred / 1 dismissed / 2 closed / 1 merge-owned (RA-8, see
  KNOWN MERGE COLLISION above). AC-1/AC-3 PASS; AC-2/AC-4/AC-5 correct at
  row layer but fail at file/save layer via F-B1/F-D1. Story stays
  `IN_PROGRESS`.

  6 blocking findings (all routed, patch dispatched — see below):
  F-B1 (journal media root not owner-scoped — direct AC-2 privacy
  violation), F-D1 (`canSave` missing `isReady` guard — save-before-ready
  race), F-B3 (iOS DB text half not backup-excluded — needed a Tech Lead
  decision before patching, see below), F-VF1 (P3 visual-fidelity gap:
  missing `CupidAppBackground` wrapper + 4 uncited deltas vs. design
  reference — the 3 already-cited `DESIGN_SPEC_CONFLICT` items are NOT
  part of this finding and must not be touched), F-G1 (missing runtime
  startup smoke evidence in `test-results.md`), F-G2 (missing entry-point
  reachability evidence in `test-results.md`, path already proven by
  slice E: `me_screen.dart:560` -> `openJournalScreen` -> `MaterialPageRoute`).
  Deferred/dismissed/closed items (F-B2/R-D4 reconciled safe, RA-9, D-B1,
  F-C1, F-D2+F-C3, R-D2 residual, O-E2, contract-summary §2 doc-drift,
  R-D3 residual, RA-8 merge-owned, RA-7 closed `fcc5066`, F-C2 closed):
  left untouched, do not re-litigate — full detail in the committed report.

  `Tech Lead` (`Alan-Techlead`, `Mode: compact-story-plan`,
  RunId `RUN-...-STORY-003-techlead-patch1`) DONE: F-B3 decision recorded
  in `architecture/solution.md` §7, plus an `openJournalScreen`
  doc-drift fix in `contract-summary.md` §2 (was already deferred/noted,
  fixed opportunistically in the same write scope). Verified diff matches
  declared 2-file WriteScope exactly, committed `6a08474`. Decision:
  confirmed the review's minimal-fix direction (reuse existing
  `com.snapsofts.cupid/backup_exclusion` iOS channel/method, no
  `AppDelegate.swift` change) but corrected the sidecar file list — DB
  runs in rollback-journal mode (no `setup:` passed to drift
  `NativeDatabase`, so WAL is never enabled), so the real sidecar is
  `cupid.sqlite-journal`, not `-wal`/`-shm`; tag all four names
  best-effort (skip missing files). BaseHead refreshed to
  `6a08474465adfddab64d0fd8aea0852c0c3ce9fc`.

  `Mobile Developer` comprehensive patch round (`Alex-Mobile-Dev-2`,
  `Mode: mobile-implementation`, RunId
  `RUN-...-STORY-003-mobile-dev-patch2`) DONE: all 6 findings addressed
  (F-B1 owner-scoped media root via new `ownerUserId`/`ownerSegment` on
  `JournalMediaStore`; F-D1 `canSave` now gates on `isReady`; F-B3
  `CupidDatabase` tags `cupid.sqlite`+sidecars via injected
  `BackupExclusion` typedef per `architecture/solution.md` §7.4; F-G1/F-G2
  evidence added to `test-results.md`; F-VF1 re-capture + report update).
  Scrum Master spot-checked `cupid_database.dart`, `journal_media_store.dart`,
  `journal_composer_cubit.dart`, `service_locator.dart` diffs directly
  before trusting the completion marker — all four match their assigned
  finding correctly. Verified 20 files/+718/-61 diff, committed `1c32341`.
  BaseHead refreshed to `1c32341d9995c11d9706f20778e78182c844def7`.
  Mobile-dev flagged that the dispatch's declared WriteScope had wrong
  paths (`features/journal/...` vs actual `core/journal/...`) and omitted
  `journal_screen.dart`/both ARB files/`test/core/journal/` — a
  Scrum-Master handoff-authoring error, not scope creep; noted in the
  commit message.

  Narrow `Reviewer: scoped-slice` re-review (`Iris-QC-3`, RunId
  `RUN-...-STORY-003-reviewer-patch2`, BaseHead `6a08474...` = the pre-patch2
  commit) IS NOW IN FLIGHT, scoped to exactly the 20 patched files, judging
  each of F-B1/F-D1/F-B3/F-G1/F-G2/F-VF1 CLOSED/STILL_OPEN/NEW_ISSUE against
  its original repro in `review/review-report.md`. Slices A/C/E excluded per
  final-synthesis's own recommendation. Output: overwrites
  `review/review-report.md` with the new canonical `Outcome:` line.

  Also reconciled: `Alex-Mobile-Dev-2`'s (prior instance number, now
  reused) STORY-001 P5 idle notification (reporting `MOBILE_COMPLETE`)
  arrived after this session had already independently verified and
  committed that same P5 work as `2f956d7` — no new action was needed,
  purely a late-arriving duplicate. A duplicate `Iris-QC-6` slice-E
  notification was likewise a no-op late arrival, already superseded by
  the final-synthesis dispatch. All idle finished teammates
  (`Alan-Techlead`, `Alex-Mobile-Dev-2/3/4`, `Iris-QC` through `Iris-QC-7`)
  were released via `TaskStop` after their work was committed/verified.

**Do not trust a RunState `status` field without checking the actual
worktree diff first** for any code-writer completion. Wait for the real
teammate mailbox/SubagentStop notification, then verify `git status`/`git
diff` matches the declared WriteScope before committing or trusting a
completion marker.

## Next Step On Resume

1. Wait for `Iris-QC-3` (STORY-003 patch2 narrow re-review, RunId
   `RUN-...-STORY-003-reviewer-patch2`, in flight) to finish. If outcome is
   `CLEAN`/`DEFERRED_ONLY`: verify/commit `review/review-report.md`, mark
   STORY-003 `DONE`, run `git-story-boundary.sh complete`, then
   `git-story-boundary.sh merge` into the integration branch (no
   dependents). If it finds new must-fix items, route them narrowly the
   same way (do not re-open the full report).
2. STORY-001: wait for `Iris-QC-2` (S1, `RUN-...-STORY-001-reviewer-s1`, in
   flight) to finish; verify/commit `review/slice-1-p1-local-card-store.md`
   inside the STORY-001 worktree, then dispatch S2 (`RUN-...-reviewer-s2`,
   same BaseHead `9207f7296a64cd37ca60e432939469ca96860762`, per
   `scope-gate.md` § Prescribed Slice Plan — owns FLAG-1 first half), then
   S3, S4 (owns FLAG-2), S5, S6 (owns FLAG-1 verdict), S7 (visual fidelity,
   image-disambiguation required), strictly sequentially — one lock holder
   at a time for `story-state:STORY-001`. After S7, dispatch S8
   `final-synthesis` (fresh context, reads only `review/slice-1..7-*.md`,
   overwrites `review/review-report.md` with the single `Outcome:` line).
   If final-synthesis returns `CLEAN`/`DEFERRED_ONLY` -> mark STORY-001
   `DONE`, run `git-story-boundary.sh complete`, then
   `git-story-boundary.sh merge` into the integration branch
   (STORY-002/004/006/012 unblock once this merges); `PATCH_REQUIRED` ->
   route named findings to the owner it specifies, patch, narrow re-review,
   then DONE/merge. Apply the KNOWN MERGE COLLISION fix above on whichever
   story merges SECOND (STORY-003 will likely merge first — apply the fix
   on STORY-001's merge).
3. Deferred/non-blocking: after STORY-003 merges, consider a `foundation`-mode
   Tech Lead pass to amend `system_architecture_memory.md` for the ADR-007/
   ADR-010 discoveries. The `contract-summary.md` §2 `openJournalScreen`
   doc-drift item is ALREADY FIXED (see F-B3 tech-lead entry above) — do
   not redo it.

## Do Not Re-read

- req_master.md, requirements/requirements.md (already loaded in full this
  session; reuse facts above).
- STORY-001 and STORY-003 story_master.md (already loaded/edited in full
  this session).
- Full phase-by-phase P1-P4/P7 history for either story — it is DONE,
  committed, and captured by the artifact pointers above, not restated here.
