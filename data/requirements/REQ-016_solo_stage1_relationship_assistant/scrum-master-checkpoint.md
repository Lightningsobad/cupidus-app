# Scrum Master Checkpoint: REQ-016 Solo Stage-1 relationship assistant

Updated: 2026-09-08 (session 798d014f, continue parallel wave, STORY-001
review DONE/`PATCH_REQUIRED`, Tech Lead patch-plan dispatched)
Requirement Status: IN_PROGRESS.

**STORY-003 is DONE and merged** (`69b3690` into
`codex/REQ-016_solo_stage1_relationship_assistant-integration`, review
`Outcome: DEFERRED_ONLY`, `story_master.md Status: DONE` committed `d0fca25`
on the integration branch). STORY-001 is the only story still in flight.

All phase-by-phase history through STORY-001 P7 and STORY-003 P5 is DONE,
committed, and superseded by artifacts — do not replay it here. Closed bugs:
`BUG-20260907-002` (DONE). Open, non-blocking bugs:
`BUG-20260907-001` (repo-wide `flutter test` pre-existing failures),
`BUG-20260908-001` (repo-wide `flutter analyze` pre-existing chat/dream_jar
warnings) — cite either instead of re-running the repo-wide command.

## Story Graph (from `requirements/requirements.md` -> `## Story Order And Dependencies`)

| Story | Depends On | Story-Class |
|---|---|---|
| STORY-001 | NONE | shared-foundation |
| STORY-002 | STORY-001 | standard |
| STORY-003 | NONE | standard (DONE, merged) |
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

STORY-001 is shared-foundation: must reach `MERGE_COMPLETE` before
STORY-002/004/006/012 (and transitively 005/007/008/009/010/011/013) become
schedulable. Only STORY-001 is currently in flight; all others wait on it.

## KNOWN MERGE COLLISION (hits when STORY-001 merges — STORY-003 already merged clean first)

Two things to reconcile at STORY-001's merge into
`codex/REQ-016_solo_stage1_relationship_assistant-integration`, both in
`mobile/lib/core/database/cupid_database.dart`. Scrum Master resolves both
directly at merge time (Git-orchestration rule — do not delegate):

1. **Migration branch**: STORY-001 P1 and STORY-003 P1 each independently
   bump `schemaVersion` 2->3 with their own additive `onUpgrade` branch.
   Combine both `if (from < 3)` branches into one, keep schemaVersion at 3,
   re-run each story's own migration test against the combined schema.
   (STORY-003's hardcoded-literal fix already in `fcc5066`; STORY-001's
   worktree copies already assert `3`, confirmed no fix needed there.)
2. **Constructor signature**: STORY-003's patch2 (`1c32341`, merged in
   `69b3690`) added a SECOND positional constructor parameter to
   `CupidDatabase` — `BackupExclusion? excludeFromBackup`. STORY-001 does
   not know about this. Reconcile STORY-001's own `CupidDatabase`
   constructor edits (if any) against this signature, and check
   `service_locator.dart`'s call site on both sides.

Non-blocking: STORY-001 P5 and STORY-003 P5 both touch
`mobile/lib/l10n/app_vi.arb`/`app_en.arb` for different keys — fine, just
don't collapse their arb edits into one commit at merge.

## STORY-003 (DONE, reference only)

Merged `69b3690`. Full history in `STORY-003_private_journal/review/` and
`coding-plan/` artifacts — do not replay it here or re-litigate any item.

## STORY-001 — review DONE, now in patch round

The 8-pass slice review (S1-S8, `story-state:STORY-001` lock) is fully
complete and committed. **Do not re-read `review/slice-1..7-*.md` or
re-litigate any slice finding** — the canonical, complete, cross-checked
synthesis is `review/review-report.md` (committed `e3a504f`,
`Outcome: PATCH_REQUIRED`). That file is the single source of truth for
all findings, owners, and the patch/re-review plan. Read it directly for
any finding detail; do not reconstruct from this checkpoint.

**Summary for routing purposes only** (full detail in `review-report.md`):
6 blocking findings — B-1 (mobile-dev: hub mounts neither P5 nor P6,
FLAG-2, confirmed independently by 4 slices), B-2 (mobile-dev + tech-lead:
no post-creation field-write path, FLAG-1, AC-15 violated), B-3 (sequencing
constraint: B-1+B-2 must land together), B-4 (mobile-dev: 3 red tests this
story caused, misfiled as pre-existing), B-5 (mobile-dev: visual-fidelity
FAIL stands, quick-entry strip renders empty boxes — same root as B-1),
B-6 (product-owner + mobile-dev: occasion content expires 2027-12-24,
dead invitation affordance after — cheapest closure is a PO durable
refresh-owner record, OR mobile-dev adds a conditional render in the
patch). Two rulings needed: R-1 (product-owner: is the inert *Đã hẹn ngày*
CTA acceptable under AC-11 — does NOT block current patch sizing, only
adds scope if PO later requires more) and R-2 (scrum-master + tech-lead:
is rule 12g real-DI startup smoke required or `NOT_APPLICABLE`).

**Scrum-Master routing decision (role-boundary constraint)**: Product
Owner and UI/UX Designer are backlog-shaping roles this session may not
spawn directly (`role-map.md` — only `brainstormer` spawns them). R-1 is
therefore left OPEN/deferred (does not block B-1..B-5's patch — see
above); B-6 is being closed via mobile-dev's offered code alternative
(conditional render) instead of the PO durable-record path, to stay
within role boundaries. R-2 is routed to Tech Lead (a normal delivery
role) together with B-2's contract-design amendment, per `review-report.md`
routing instructions.

**Tech Lead dispatched** (`Alan-Techlead@session-798d014f`, RunId
`RUN-REQ-016_solo_stage1_relationship_assistant-STORY-001-techlead-patch1`,
`Mode: coding-plan`, output `coding-plan/master-plan.md`, BaseHead
`e3a504fe4ebfa9a60ee62964001d462c714956fa` = current worktree HEAD after
S8's commit) — IN FLIGHT. Job: (1) rule on R-2, noting B-1's patch touches
exactly the wiring 12g would exercise so satisfying it in the same round
is likely cheapest if REQUIRED; (2) design the minimal `ActivityCardRepository`
contract addition for B-2 (a `setScheduledDate` method, or fold into
`updateStatus`) and amend the coding-plan phase table accordingly.
Completion marker: `CODING_PLAN_UPDATED`.

**Do not trust a RunState `status` field without checking the actual
worktree diff first** for any code-writer completion. Wait for the real
teammate mailbox/SubagentStop notification, then verify `git status`/`git
diff` matches the declared WriteScope before committing or trusting a
completion marker.

## Next Step On Resume

1. STORY-003: DONE, merged. No further action.
2. STORY-001: wait for Tech Lead's `CODING_PLAN_UPDATED` completion.
   Verify `git status --porcelain` in the story worktree matches
   `coding-plan/master-plan.md` only, commit via `git-story-boundary.sh
   commit`, fold the R-2 ruling + contract design into this checkpoint.
3. Then dispatch **mobile-dev** (`Alex-Mobile-Dev`) for the actual patch
   round covering B-1, B-2 (together, per B-3), B-4, B-5's code half, and
   B-6's conditional-render alternative, plus the bundled deferred items
   named in each B-item in `review-report.md` (S2-F2-1 photos, S2-F2-3
   ownership-mismatch, S4-F-4/S6-F-2 invited/replyState, S6-F-6 title
   desync, S4-F-3 frame flash, S5-F-4 strip scroll — see report for the
   full bundle list). New BaseHead = worktree HEAD after Tech Lead's
   commit (re-derive at dispatch time, do not reuse `e3a504f`). Same
   `story-state:STORY-001` lock.
4. After mobile-dev's patch, dispatch a **scoped-slice** re-review (NOT a
   full 8-pass re-run — `review-report.md`'s own recommendation: the patch
   only touches `activity_card_hub_view.dart`, the repository contract
   pair, the P6 cubit, `app_shell_test.dart`'s DI helper, and two
   lifecycle tests; S1, S3, and P7-half-of-S2 need no re-review).
5. If that re-review returns `CLEAN`/`DEFERRED_ONLY` -> mark STORY-001
   `DONE` **inside the integration worktree**
   (`.ai-team-worktrees/cupid-apps/integration-REQ-016_solo_stage1_relationship_assistant`,
   not the control checkout — evidence guard needs the merged
   visual-fidelity report, which only exists there), run
   `git-story-boundary.sh complete`, then `git-story-boundary.sh merge`
   into the integration branch, resolving the KNOWN MERGE COLLISION above
   directly and re-running both stories' migration tests against the
   combined result.
6. Deferred/non-blocking: after STORY-001 merges, consider a
   `foundation`-mode Tech Lead pass to amend `system_architecture_memory.md`
   for ADR-007/ADR-010 discoveries, and to document `ContentPackage<T>`
   in `contract-summary.md` §2 (S3-F-3, bundled as tech-lead-owned deferred
   item in `review-report.md`).

## Do Not Re-read

- req_master.md, requirements/requirements.md (already loaded in full this
  session; reuse facts above).
- STORY-001 and STORY-003 story_master.md (already loaded/edited in full
  this session).
- `review/slice-1..7-*.md` — fully superseded by `review-report.md`, do not
  re-read any of them.
- Full phase-by-phase P1-P4/P7 history for either story, and STORY-003's
  full patch/re-review history — DONE, committed, captured by artifact
  pointers above, not restated here.
