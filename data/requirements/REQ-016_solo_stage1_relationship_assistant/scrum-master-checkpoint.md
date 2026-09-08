# Scrum Master Checkpoint: REQ-016 Solo Stage-1 relationship assistant

Updated: 2026-09-08 (session 798d014f, continue parallel wave, STORY-001
slice review S5 DONE, S6 next)
Requirement Status: IN_PROGRESS.

**STORY-003 is DONE and merged** (`69b3690` into
`codex/REQ-016_solo_stage1_relationship_assistant-integration`, review
`Outcome: DEFERRED_ONLY`, `story_master.md Status: DONE` committed `d0fca25`
on the integration branch). STORY-001 is the only story still in flight,
mid-way through its 8-pass slice review (S1-S5 DONE, S6-S8 remaining).

All phase-by-phase history through STORY-001 P7 and STORY-003 P5 is DONE,
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

STORY-001 is shared-foundation: it must reach `MERGE_COMPLETE` into
`codex/REQ-016_solo_stage1_relationship_assistant-integration` before
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
   re-run each story's own migration test against the combined schema. Also
   fix two out-of-WriteScope hardcoded schemaVersion literal assertions
   (already fixed on STORY-003's side in `fcc5066`; STORY-001's worktree
   copies already assert `3`, confirmed no fix needed there):
   `mobile/test/core/database/timeline_dao_test.dart:36`,
   `mobile/test/core/database/expense_dao_test.dart:37`.
2. **Constructor signature**: STORY-003's patch2 (`1c32341`, merged in
   `69b3690`) added a SECOND positional constructor parameter to
   `CupidDatabase` — `BackupExclusion? excludeFromBackup`. STORY-001 does
   not know about this. Reconcile STORY-001's own `CupidDatabase`
   constructor edits (if any) against this signature, and check
   `service_locator.dart`'s `CupidDatabase(...)` call site on both sides.

Non-blocking: STORY-001 P5 and STORY-003 P5 both touch
`mobile/lib/l10n/app_vi.arb`/`app_en.arb` for different keys — fine, just
don't collapse their arb edits into one commit at merge.

## STORY-003 (DONE, reference only)

Merged `69b3690`. Full phase/patch/re-review history (6 blocking findings
all closed, `Outcome: DEFERRED_ONLY`, `Iris-QC-3` patch2 re-review committed
`9f4555f`) is fully captured in `STORY-003_private_journal/review/` and
`coding-plan/` artifacts — do not replay it here or re-litigate any item.

## STORY-001 — 8-pass slice review (`story-state:STORY-001` lock, one holder at a time)

Root cause of the slice plan: `Reviewer: full-story-review` first pass
returned `Outcome: BLOCKED` / `REVIEW_SCOPE_TOO_BROAD` (44 files vs. budget
12, `scope-gate.md` + `review-report.md` committed `f3d9bea`). Plan:
S1=P1 store, S2=P2 repo+P7 type, S3=P3 occasion content, S4=P4 hub/entry
(owns FLAG-2), S5=P5 empty-state/capture, S6=P6 detail/lifecycle/delete
(owns FLAG-1 verdict), S7=visual fidelity, S8=`final-synthesis` (fresh
context, reads ONLY `review/slice-1..7-*.md`, overwrites
`review/review-report.md` with the single `Outcome:` line).

BaseHead for every slice dispatch: `9207f7296a64cd37ca60e432939469ca96860762`
(merge-base; pass as explicit 4-field override to `handoff-build.sh spawn`
each time — its auto-derivation would otherwise pick the wrong value).

**AC source of truth is `requirements/requirements.md`, NOT `story_master.md`.**
AC-numbering drift in `scope-gate.md`'s own "Query Keys" section has been
confirmed independently in ALL FIVE slices run so far (S1-S5) — every
remaining slice's reviewer must be told explicitly to verify AC ids against
`requirements.md` directly, never trust scope-gate's listed numbers.

**S1 DONE** (`4b2f758`): `PASS_WITH_FINDINGS`, both gates PASS. 3 findings
for S8: F-1 (MEDIUM, no `ownerKey` param on 3 store methods despite
owner-filtering docs), F-2/F-3 (LOW). G14 (AC-15 store purity) left
UNVERIFIED explicitly.

**S2 DONE** (`e7261e9`): `FINDINGS_RECORDED`, 8 findings, 2 gates FAILED
(`G3-contract-field-set-photos-unreachable`,
`G11-p2-test-evidence-section-missing`). **FLAG-1 result:
`CONTRACT_SURFACE_ESTABLISHED_NO_FIELD_WRITE_PATH`** — repository has
exactly 4 write methods (`createCard` insert-only, `updateStatus`,
`clearScheduledDate`, `deleteCard`); no way to persist title/note/price/
distance/photos/etc after creation. Classification itself deferred to S6
per rule 14.

**S3 DONE** (`bea7108`): `PASS_WITH_FINDINGS`, 5 findings, 0 blocking.
F-2 (content horizon: `occasions.v1.json` covers only through 2027-12-24;
`nearestOccasion` returns `null` forever after — severity later raised by
S5, see below). F-3 (`ContentPackage<T>` shared shape undocumented in
`contract-summary.md` §2 — cross-story gap, owner: tech-lead).

**S4 DONE** (`5565f60`): `FAIL` — recommends `PATCH_REQUIRED`.
**FLAG-2 CONFIRMED** directly in code: `activity_card_hub_view.dart` never
imports/mounts the real P5 widgets or the P6 detail screen; it mounts a
private stub `_QuickEntryStrip` (unlabeled, no `onTap`) and an empty-store
`SizedBox` placeholder, and routes `onPrimaryAction`/`changeStatus`/`edit`
to `_showComingSoon` (only `delete` reaches the repository). Result: AC-1,
AC-2, AC-3, AC-4, AC-6, AC-7, AC-12, AC-14 (+AC-8/15/16/17, detail-screen
ACs) are unreachable via the real menu path — `PATCH_REQUIRED` per rule
12e1, not a staged-rollout gap. Rule 12e1 reachability of the HUB SCREEN
itself still PASSES (reached via `HomeScreen` -> `_SoloHomeGate` ->
`_SoloStageOneShell`); the failure is what the reached screen can do once
there. AC-13 (delete) PASSES narrowly. PASS: AC-10/11/18/20/21/22.
**Second blocker (S4-F-2)**: 3 tests in
`mobile/test/core/navigation/app_shell_test.dart` are red because of THIS
story's own new `HomeScreen` solo branch (needs `ActivityCardRepository` in
GetIt) — verified NOT pre-existing (`home_screen.dart` is +162/-0, whole
branch is new); one-line DI fix, same pattern as S1's round.
Governing ACs per `phase-P4` §1B (correct, unlike scope-gate): AC-10, AC-11,
AC-13, AC-22, AC-21, AC-18/20, BR-2/3/10.
**For S8**: S4-F-4 (invited flag lives only in cubit memory) shares FLAG-1's
root cause — S8 must merge it into S6's FLAG-1 verdict, not count twice.
S4-F-6: preview fixture's `countsByStatus` (14) mismatches its 4 rendered
rows — S7 must treat the `man-goc-muon-lam` capture's "Tất cả · 14" as a
fixture bug, not a design delta.

**S5 DONE** (`3462c2c`): `PASS` — all 5 files new (+1409/-0). AC-1 PASS
(exactly 2 `_InviteCard`s); the "3rd CTA" (`QuickEntryStrip` visible in
empty state) is explicitly allowed by `uiux-spec.md` §4a, NOT a violation.
AC-2 PASS (verified at repository contract, real write not just test fake).
J1 PASS structurally; AC-4 (60s claim) UNVERIFIED, no timing measurement.
**F-1** (independently confirmed, not double-counted): `MinuteOneEmptyState`/
`QuickCaptureSheet`/`QuickCaptureAddAction` have 0 call sites anywhere —
correctly built but orphaned (this is S4/FLAG-2's blocker, not new).
**F-2 severity raised MEDIUM->HIGH** (was S3's finding): null-occasion
degrades gracefully (no crash, SnackBar shown) BUT the invitation card still
renders unconditionally, so from 2027-12-25 onward AC-3 becomes permanently
impossible and AC-1 degrades to one live + one dead invitation; this branch
has zero test coverage. Minor: wrong AC mapping in
`test-results.md:761-764`, strip doesn't scroll on narrow screens, no error
branch in `_submit` (failed write leaves sheet stuck).

**S6 next**: P6 detail/lifecycle/delete (6 files) — owns FLAG-1 verdict
(use S2's `CONTRACT_SURFACE_ESTABLISHED_NO_FIELD_WRITE_PATH` finding) +
AC-15 P6 half, and must fold S4-F-4 into its FLAG-1 classification per S4's
note above. Output `review/slice-6-p6-card-detail-lifecycle-delete.md`.
Not yet dispatched.

**Do not trust a RunState `status` field without checking the actual
worktree diff first** for any code-writer completion. Wait for the real
teammate mailbox/SubagentStop notification, then verify `git status`/`git
diff` matches the declared WriteScope before committing or trusting a
completion marker.

## Next Step On Resume

1. STORY-003: DONE, merged. No further action.
2. STORY-001: dispatch **S6** (P6 detail/lifecycle/delete, 6 files,
   `Mode: scoped-slice`, output
   `review/slice-6-p6-card-detail-lifecycle-delete.md`, same BaseHead
   `9207f7296a64cd37ca60e432939469ca96860762` explicit 4-field override,
   distinct `--run-id` suffix `-s6`). S6 owns the FLAG-1 verdict using S2's
   contract-surface finding, AC-15 P6 half, and must fold S4-F-4 into that
   verdict (not a separate finding). Then S7 (visual fidelity — 9
   implemented captures vs. 4 design references, pin the authoritative
   capture per screen before comparing; also treat S4-F-6's fixture-count
   mismatch as a fixture bug not a design delta; re-assess whether
   `VISUAL_FIDELITY: FAIL` should now read PASS given D-8 closed), strictly
   sequentially — one lock holder at a time for `story-state:STORY-001`.
   Tell each reviewer to verify AC labels against `requirements.md`
   directly (drift confirmed in all 5 slices so far). After S7, dispatch S8
   `final-synthesis` (fresh context, reads only `review/slice-1..7-*.md`,
   overwrites `review/review-report.md` with the single `Outcome:` line).
   If final-synthesis returns `CLEAN`/`DEFERRED_ONLY` -> mark STORY-001
   `DONE` **inside the integration worktree**
   (`.ai-team-worktrees/cupid-apps/integration-REQ-016_solo_stage1_relationship_assistant`,
   not the control checkout — evidence guard needs the merged
   visual-fidelity report, which only exists there), run
   `git-story-boundary.sh complete`, then `git-story-boundary.sh merge`
   into the integration branch, resolving the KNOWN MERGE COLLISION above
   (migration branch AND `CupidDatabase` constructor parameter) directly
   and re-running both stories' migration tests against the combined
   result. Given S4/S5 already found real `PATCH_REQUIRED`-grade defects
   (FLAG-2 unreachable ACs), the more likely outcome is
   final-synthesis returns `PATCH_REQUIRED` -> route each named finding to
   its owner (mobile-dev for the mount/wiring gaps), patch, narrow
   re-review, then DONE/merge.
3. Deferred/non-blocking: after STORY-001 merges, consider a
   `foundation`-mode Tech Lead pass to amend `system_architecture_memory.md`
   for ADR-007/ADR-010 discoveries, and to document `ContentPackage<T>`
   in `contract-summary.md` §2 (S3-F-3).

## Do Not Re-read

- req_master.md, requirements/requirements.md (already loaded in full this
  session; reuse facts above).
- STORY-001 and STORY-003 story_master.md (already loaded/edited in full
  this session).
- Full phase-by-phase P1-P4/P7 history for either story, and STORY-003's
  full patch/re-review history — DONE, committed, captured by artifact
  pointers above, not restated here.
