# Scrum Master Checkpoint: REQ-016 Solo Stage-1 relationship assistant

## Current state (as of Round 38, 2026-09-26)

Ground truth = integration-worktree `story_master.md` copies +
`git-story-boundary.sh status`, not narrative history. DONE stories are
collapsed to one line; full trail lives in each story's own
`story_master.md` / `review/review-report.md`, not here.

| Story | Depends On | Status |
|---|---|---|
| STORY-001 | NONE | DONE, merged |
| STORY-002 | STORY-001 | DONE, merged |
| STORY-003 | NONE | DONE, merged |
| STORY-004 | STORY-001 | DONE, merged |
| STORY-005 | STORY-001, STORY-004 | DONE, merged. Final-synthesis `Outcome: CLEAN`. Open note: `BUG-20260923-002`'s 3 assertions are already green on this story's branch (fixed by P7) — re-verify on integration branch before dispatching a bug-fixer. |
| STORY-006 | STORY-001 | DONE, merged |
| STORY-007 | STORY-001, STORY-002, STORY-003, STORY-005 | DONE, merged (Round 22). Final-synthesis `Outcome: DEFERRED_ONLY`. Open PO question (not yet escalated): see Open user decisions item 4 below. |
| STORY-008 | STORY-001, STORY-002, STORY-003, STORY-004 | DONE, merged (Round 23). Reviewer round-4 `Outcome: DEFERRED_ONLY`. |
| STORY-009 | STORY-004 | DONE, merged |
| STORY-010 | STORY-004 | DONE, merged |
| STORY-011 | STORY-001, STORY-004, STORY-005, STORY-008 | DONE, merged (Round 34), merge `e346e147`. Final-synthesis `Outcome: DEFERRED_ONLY` (10 deferred, 0 blocking). |
| STORY-012 | STORY-001 | DONE, merged (Round 38, merge `e9519243`). Final-synthesis `Outcome: DEFERRED_ONLY`. |
| STORY-013 | STORY-001, STORY-004 | DONE, merged (Round 16); F-I1 rework re-merged into integration Round 40, merge `753d2a86` |

## Open user decisions

1-3. **RESOLVED, applied, not reopened** (STORY-013 evidence-filename fix;
   STORY-005 P5-P7 rework review; STORY-007 P3/P4 Design-Ruling-Log D-10/D-6
   choices — see `req_master.md` `## Design Ruling Log` 2026-09-17/23 rows).

4. **OPEN, not yet escalated to user/PO.** STORY-007 final-synthesis review
   (`review/review-report.md` §4) found `ThankYouBlockCubit.resolve()` consumes
   the one-time unlock at screen-*build* time (`initState`), not when the
   block actually scrolls into view — a long card can burn the unlock before
   the user ever sees it, with no un-consume API. Does not block DONE (AC
   wording gap, not an AC violation). PO question: should AC-3's "consume" mean
   "on screen build" or "on block actually visible"?

5. **OPEN, not yet escalated to user/PO.** `stage1_wipe_registry_parity_test.dart`
   has a pre-existing red assertion touching 3 other stories' status tables
   (confirmed non-blocking for STORY-007, not caused by it). Needs a PO/Tech
   Lead decision; root decision never escalated.

6. **RESOLVED by user 2026-09-26 (Round 42): wire the 3 tabs to their
   already-shipped screens** (not deferred; D-3 stands as originally written).
   Implementation now in flight — see Round 42 cursor below. Was: F-I2 action item 6
   (`integration-review/mobile-visual-audit.md`, Round 41, committed `c1c538ea`)
   found **F-M1**: in solo/unpaired mode — REQ-016's own premise — 3 of the 4
   solo stage-1 tabs (`Sổ tay`, `Nhật ký`, and the Me-hub path to `Hồ sơ kỹ
   năng`) are dead ends. `home_screen.dart:281,323-332,364-370` renders
   `'<label> — sắp có'` for them. The screens themselves
   (`JournalScreen`/`NotebookScreen`/`SkillProfileScreen`) are fully built and
   verified working (audit seam C), but their only production entry point is
   `MeScreen` (`me_screen.dart:560/568/577`), and `MeScreen` mounts only via
   `AppShell` (`app_shell.dart:182`), which is constructed only on
   `PairGateShell`'s **paired** branch (`pair_gate_shell.dart`) — never reached
   in solo/unpaired mode. This contradicts decision D-3 (`req_master.md:155`,
   2026-09-07), which resolved the STORY-001 canvas-vs-AC conflict in favor of
   the canvas and patched AC-22 + UX §1 to require the four-tab bar **and its
   routes** for solo stage-1. The tab bar shipped; 3 of its 4 routes did not.
   No single story's own gate could catch this — STORY-001, STORY-003, and
   STORY-004 are each internally correct and each pass their own tests; the
   gap exists only in composition, which is exactly what this requirement-level
   audit is for. **User/PO decision needed between:** (a) wire the three solo
   tabs to the already-shipped screens (implementation rework, scope/story
   TBD), or (b) record an explicit PO deferral that supersedes D-3's "and its
   routes" clause for stage 1 (i.e., ship the tabs as placeholders for now).
   Scrum Master is not making this call unilaterally — it is a product-scope
   decision that reverses a previously-explicit, previously-escalated decision
   (D-3), not an implementation detail. Not routed to Reviewer for a verdict
   first: the choice of AC-22 compliance scope must be settled before a fresh
   integration review can even know what to check.
   **Correction (Tech Lead, Round 42):** no tab is named/mapped to `Hồ sơ kỹ
   năng` — the 4 D-3-locked labels are `Muốn làm · Ý tưởng · Sổ tay · Nhật
   ký`, and the real fix uses 2 tabs, not 3. See Current cursor below for the
   full corrected decision.

## Still-open non-blocking items

- STORY-008: retry `runtime_smoke` now that host disk has 28Gi free; re-review
  F-3 in `STORY-008/review/review-report.md` before sealing.
- Open, non-blocking bugs (cite, do not re-run repo-wide/broad commands):
  `BUG-20260907-001` (repo-wide `flutter test` pre-existing failures),
  `BUG-20260908-001` (repo-wide `flutter analyze` pre-existing chat/dream_jar
  warnings), `BUG-20260923-001` (Drift `schemaVersion` migration test lag —
  11 reds in `test/core/database/`), `BUG-20260923-002`
  (`test/features/conversation_starters` 3 pre-existing enum/rule-list-length
  reds, root cause STORY-005 P6/P7 rework — but see STORY-005 row above, may
  already be resolved on integration branch), `BUG-20260924-001` (3
  pre-existing `test/design_system/` reds, confirmed pre-existing at STORY-007
  P3's own BaseHead). Closed: `BUG-20260907-002`, `BUG-20260910-001`.
- Integration branch re-verification owed: re-run integration build/runtime
  verification and record under
  `REQ-016_solo_stage1_relationship_assistant/integration-review/` BEFORE any
  future `land-integration` for this requirement — prior evidence is stale.
- STORY-013: `coding-plan/master-plan.md`, all 6 phase files, and
  `test-results.md` use literal `Status: COMPLETE`, not the gate-recognized
  `DONE|SKIPPED|DEFERRED|WAIVED|N/A` (per Alan-Techlead-3 verification,
  2026-09-26; story itself is `MERGE_COMPLETE: true`/`MERGED`, review
  `Outcome: DEFERRED_ONLY`). Not yet known to block anything post-merge; if any
  future gate scans STORY-013's own phase/plan files and rejects `COMPLETE`,
  this is the cause — fix is Scrum-Master-owned artifact wording, not rework.
- **OQ-1 (Round 42, non-blocking, for PO):** solo stage-1 tab `Ý tưởng` maps to
  no shipped screen. Its "sinh ý tưởng" content (Gợi ý quà/Mồi chuyện/trắc
  nghiệm) already ships and is reachable via `Muốn làm`'s quick-entry rail
  (audit seam B PASS); no story owns `Ý tưởng`'s own content. Per UX §1
  lines 17-18/§6, keeping it a `sắp có` placeholder is correct spec, not an
  F-M1 defect — full reasoning in
  `architecture/fm1-solo-tabs-solution.md` §6. PO decides only whether to
  assign it new content later or record an explicit deferral; out of scope
  for this requirement's `DONE` gate.

## 3-part verification protocol (use before sealing any specialist's reported-complete work)

(1) `ListAgents`/`list-releasable-agents.sh` shows the agent idle/gone; (2)
worktree `git diff`/`git status` matches the declared WriteScope; (3) the
specialist's own output file / `story_master.md` Status field reads
DONE/COMPLETE. After sealing: commit (Scrum Master only), then
`git-story-boundary.sh refresh-base` before the next spawn handoff.

## Do Not Re-read

- `req_master.md` body text, `requirements/requirements.md`, all DONE stories'
  `requirements.md`/`uiux-spec.md`/`architecture/*`/`coding-plan/master-plan.md`
  for STORY-001/002/003/004/006/009/010/013 — superseded by this checkpoint.
- `test-results.md` files (can be 80KB+) — use `git diff`/`Read
  offset/limit`, never a full Read.
- Round 1-35 narrative in git history of this file — superseded by the table
  and "Current cursor" sections above.

## Current cursor (Round 42 continued, `continue parallel`, 2026-09-26 — Tech Lead F-M1 decision sealed, mobile-dev dispatch next)

- Tech Lead (`Alan-Techlead`) returned `TECH_LEAD_COMPLETE: YES`. 3-part
  verification passed: agent releasable; worktree `git status --porcelain`
  showed exactly the declared WriteScope (`architecture/` dir, one new file);
  full file content read and eyeballed — matches the specialist's own report
  exactly. Committed in the integration worktree as `9aadd52f`. `Alan-Techlead`
  released via `TaskStop`.
- **Corrects the Round 42/Open-user-decisions-item-6 premise**: no tab maps to
  `Hồ sơ kỹ năng`. The 4 D-3-locked labels are `Muốn làm · Ý tưởng · Sổ tay ·
  Nhật ký`. Fix uses **2 tabs**: `Sổ tay` → `openNotebookScreen` +
  `openSkillProfileScreen` (req_master.md:131 groups these as one seed);
  `Nhật ký` → `openJournalScreen`. `Ý tưởng` unaffected, correctly stays a
  placeholder (see new OQ-1 in Still-open non-blocking items above).
- Decision (full text in `architecture/fm1-solo-tabs-solution.md`, do not
  re-derive): tab body → destination-list block (style of shipped
  `_PrivateStorageBlock`, `me_screen.dart:539-579`); row tap pushes via the
  existing 3 entry points. Mounting the screens as tab bodies is forbidden
  (`journal_entry_point.dart:96-98`, `context_notebook_entry_point.dart:59-61`,
  AC-17) plus 3 technical reasons (own Scaffold+back would pop
  `PairGateShell`; `getIt`-in-`build` breaks the un-DI'd test host;
  `IndexedStack` would eagerly open private screens on app entry). No
  state/DI changes beyond 3 optional test seam-opener callbacks on
  `_SoloStageOneShell` (same pattern as shipped
  `resolvePairingStatus`/`createTimelineCubit`). Classification: `standard`,
  direct on this integration worktree/branch (2 files, no story worktree).
  `next_mode_recommendation: mobile-implementation-direct` — test scope fully
  specified in the doc's §5.2, no coding-plan phase needed.
- Two hard constraints for the mobile-dev dispatch (carry forward verbatim):
  (1) `activity_card_hub_view_test.dart:852-907` will correctly go red and
  must be rewritten, keeping the exact AC-21/SC-1' assertion
  (`find.text('Đi biển')` → `findsNothing`) for all three tabs; (2) exactly 2
  new imports allowed in `home_screen.dart` (the two entry-point files only),
  per journal P5 §4's import boundary AC.
- **Next resume action:** dispatch `Alex-Mobile-Dev` (fresh spawn — prior
  visual-audit instance already released), `Mode: mobile-implementation`,
  `Flow: parallel-requirement`, `Story: NONE`, `ConcurrencyClass:
  code-writer`, worktree = the integration worktree, `BaseHead` = integration
  HEAD after `9aadd52f` (resolve full sha at dispatch time),
  `WriteScope`/`OutputPath` = `mobile/lib/features/home/presentation/home_screen.dart`
  + `mobile/test/features/activity_cards/activity_card_hub_view_test.dart` +
  optionally one new test file per §5.2. Handoff body must carry §5.1-§5.4 of
  `architecture/fm1-solo-tabs-solution.md` verbatim (code changes, required
  tests, gate-run constraints, screenshot note) — do not re-summarize from
  memory. After `MOBILE_COMPLETE: YES` + 3-part verify + seal + commit:
  dispatch a FRESH `Iris-QC` requirement-integration-review (new RunId — prior
  terminal one is `PATCH_REQUIRED`) scoped to the F-M1 fix plus the
  Round-41-closed F-I2/F-I3 evidence (`stage1_wipe_registry.dart`, parity
  test, configuration guide, `build-runtime-evidence.md`,
  `mobile-visual-audit.md`) — the 9 previously-PASS cross-story contracts do
  not need re-verification. On `Outcome: CLEAN`/`DEFERRED_ONLY`: re-sync
  `main` if moved, `cleanup-requirement`, `land-integration`, flip
  `req_master.md` + `master_requirements_list.md` to `DONE`.

## Superseded history (Rounds 37-41, collapsed — all 13 stories DONE/merged, F-I1 rework landed, F-I2/F-I3 devops evidence closed, requirement-level mobile-visual-audit closed)

Round 41: `Frank-Devops` closed F-I2 action item 5
(`integration-review/build-runtime-evidence.md`: real build + app-launch
smoke; `BUG-20260923-001`'s 11 `test/core/database/` reds confirmed
version-lag-only, now 104/104 passing) and F-I3 action item 7
(`deployment/configuration-guide.md`: added Local Notifications section, fixed
stale POST_NOTIFICATIONS claim); committed `0a8f4214`. `Alex-Mobile-Dev`
closed F-I2 action item 6 (`integration-review/mobile-visual-audit.md`,
seam-by-seam PASS except F-M1, plus non-blocking NOTE-1/NOTE-2); committed
`c1c538ea`. F-M1 (solo stage-1 tabs unreachable in solo mode, contradicting
D-3) escalated to the user as Open user decisions item 6 — resolved 2026-09-26
(wire the tabs; see Current cursor above for the corrected 2-tab decision).
Full narrative, exact commands, and root-cause detail for these rounds live in
this file's own prior git history if ever needed — not reproduced here per
checkpoint budget.

## Superseded history (Rounds 37-40, collapsed — all 13 stories DONE/merged, F-I1 rework landed)

All 13 REQ-016 stories DONE/merged by Round 38 (integration HEAD `e9519243`).
Round 39 `Iris-QC` integration review → `Outcome: PATCH_REQUIRED` (F-I1/F-I2/
F-I3; 9 cross-story contracts PASS; report committed `55ade421`). Round 40
resolved F-I1: Tech Lead decided `calendar_event_state_decision: REGISTER`
(`STORY-013/architecture/solution.md` §7 Addendum); mobile-dev patch1 BLOCKED
on stale BaseHead + phase-status wording (both Scrum-Master-fixed directly:
`sync-target`, `Status: COMPLETE`->`DONE` relabel `b08bd4be`); patch2
`MOBILE_COMPLETE: YES`, committed `91542e4b`, merged into integration
`753d2a86`. Full narrative, exact commands, and root-cause detail for these
rounds live in this file's own prior git history if ever needed — not
reproduced here per checkpoint budget.
