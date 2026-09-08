# Scrum Master Checkpoint: REQ-016 Solo Stage-1 relationship assistant

Updated: 2026-09-08T00:00Z (continue parallel wave, current session)
Requirement Status: IN_PROGRESS.
- STORY-001 (shared-foundation): P4 round 2 committed `98e865d`. User ruling
  (2026-09-08) on D-6/D-7: option (a) "extend write scope, re-run gate" —
  extended write scope to `mobile/lib/design_system/icons/cupid_icons.dart` +
  `mobile/lib/main_preview.dart` (D-7 preview-harness double-bar fix bundled
  in since round 3 would otherwise predictably re-FAIL on it) +
  `features/home/presentation/home_screen.dart`. `Alex-Mobile-Dev-2` P4 round 3
  dispatched, IN FLIGHT (RunId
  RUN-REQ-016_solo_stage1_relationship_assistant-STORY-001-mobile-dev,
  BaseHead `98e865d777c03e9f3bf8d93178d35a0bb45973e6`). Do NOT dispatch P5/P6 or
  Reviewer until this round returns; if round 3 still FAILs on a genuinely new
  D-id, stop and report again rather than re-litigating D-1/2/3/6/7.
- STORY-003 (standard, no dependents): `BUG-20260907-002` DONE, branch rebased.
  P3 (journal list + delete) COMPLETE, visual-fidelity PASS — committed
  `1f4a815` + phase-status sync `03fd937`, BaseHead refreshed to `03fd937`.
  `Alex-Mobile-Dev` P4 (composer screen) dispatched, IN FLIGHT (same RunId,
  fresh phase).
Scheduler: `data/runtime/parallel-scheduler.json` supervisor.requirement_id = REQ-016_solo_stage1_relationship_assistant

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

Ready now (no unmet deps): STORY-001, STORY-003. Both have full architecture +
coding-plan bundles committed on their story branches. Both are single mobile
lane, sequential phases (`MAX_CODE_WRITERS_PER_STORY=1` per story; never run
two phases of the SAME story concurrently, but the two stories run concurrently
fine — 2 separate code-writer slots).

All other stories blocked on STORY-001 and/or STORY-004.

## RESOLVED — STORY-001 Design/AC Conflict (was "BLOCKED", closed 2026-09-07T16:10Z)

User ruling: anchor on design for all three clusters (D-1 filter panes, D-2
hero CTA, D-3 tab bar) — see `req_master.md` `## Design Ruling Log`
(D-1/D-2/D-3, source: `visual-fidelity-report.md` screen `man-goc-muon-lam`).
`Andy-PO` `Mode: ac-patch` (dispatched directly by Scrum Master per explicit
user override of the normal brainstormer-only PO/UX routing) patched
`requirements/requirements.md` AC-10/AC-11/AC-22 and `ux/uiux-spec.md` §1/§3
to match the design canvas. Landed:
- `main` commit `b516c48` (4 files: requirements.md, uiux-spec.md,
  req_master.md, this checkpoint).
- Pulled onto the STORY-001 story branch via `git checkout b516c48 -- <3
  paths>` + `git-story-boundary.sh commit` → commit
  `54173ad5954afe015843e68d08fdd7ed079281cc`; BaseHead refreshed to same sha.

P4 rework (5th "Tất cả" filter pane, hero CTA + overflow "…", new 4-item tab
bar) re-dispatched — see "Active Runs" below. No story review gate until
that rework lands and its visual-fidelity gate passes.

## KNOWN MERGE COLLISION (flag before either story merges)

Both STORY-001 P1 and STORY-003 P1 independently bump
`mobile/lib/core/database/cupid_database.dart` `schemaVersion` 2->3 with their
own additive `onUpgrade` branch, in separate worktrees/branches. Whichever
story's branch merges into `codex/REQ-016_solo_stage1_relationship_assistant-integration`
SECOND will conflict on this file. Scrum Master resolves this directly at
merge time (per Git-orchestration rules — do not delegate): combine both
`if (from < 3)` migration branches into one, keep schemaVersion at 3 (not 4,
since both stories target the same v3), and re-run each story's own migration
test against the combined schema before completing the merge.

ADDITIONAL small fix bundled into the same merge reconciliation (flagged by
STORY-003's P1 run, applies identically regardless of merge order): once
schemaVersion is 3, two out-of-WriteScope pre-existing tests assert the old
literal and must be updated to `3`:
`mobile/test/core/database/timeline_dao_test.dart:36` and
`mobile/test/core/database/expense_dao_test.dart:37`. No behavior assertions
are affected.

## Active Runs (this wave)

- STORY-001 tech-lead: COMPLETED (both architecture-solution + coding-plan
  bundle in one run, forced by validate-techlead-handoff.sh). Committed
  a2aaf1cd20c5735adc78d38bb70287eeb8374c63. Agent released (`TaskStop`).
  Plan: 6 phases, single Mobile lane, sequential P1->P2->P4->P5/P6 (P3 flexible
  between P2 and P4).

- RUN-REQ-016_solo_stage1_relationship_assistant-STORY-001-mobile-dev
  - P1: COMPLETED by Alex-Mobile-Dev. Committed 98ff776601680afacb8b4b841835e850337b6534.
  - P2 (card domain repository): COMPLETED (session recovered — prior run
    RUN...STORY-001-mobile-dev was left ACTIVE by a dead session f8b579b2 with
    no runtime agent reachable; verified P2 output already existed uncommitted
    in the worktree from that prior run, so this session committed it directly
    rather than re-running the phase). Committed 01d020d337aa50a96d84d13c1f2f2020e48799a3
    (impl) + fd371b25a790da479497b29f82eebee237ab963a (master-plan status).
    BaseHead refreshed to fd371b25a790da479497b29f82eebee237ab963a.
  - P3 (occasion content package): COMPLETED by Alex-Mobile-Dev (session
    b8a1eda8; SubagentStop transcript was missing the bare completion marker
    but test-results.md/master-plan.md carried full genuine evidence —
    46/46 targeted tests pass, 0 out-of-scope changes, static analysis clean).
    Committed 1d88f98227bac13a95f1180ff3cf76c6f228e3c4. BaseHead refreshed to
    same sha.
  - P4 (hub list + entry point): COMPLETE. Real completion signal received
    12:39:52Z from Alex-Mobile-Dev-3 (result-bearing idle_notification,
    `idleReason: available`, `MOBILE_COMPLETE: YES`) — verified against the
    worktree before trusting it: `git status --porcelain` matched every
    declared write-scope file, the two out-of-scope home test fixtures, and
    `main_preview.dart`; `phase-P4-hub-list-and-entry-point.md` §7 Status =
    COMPLETE; `flutter analyze` 0 errors (16 issues, 5 pre-existing
    warnings); `flutter test test/features/activity_cards/ test/features/home/`
    101 passed / 1 skipped. Per-story visual-fidelity gate ran for real
    (emulator-5554 reachable) and returned FAIL — see "BLOCKED" section above
    for the full product/design conflict, not a rework item. Committed
    `c5267b6`; BaseHead refreshed to `c5267b60f420ce04bd6f58e974759a8c0df94245`.
    Out-of-WriteScope changes declared and verified: `mobile/lib/main_preview.dart`
    (new preview entry point required by the mandatory §6 visual-fidelity
    gate), `mobile/test/features/home/presentation/home_header_notifications_test.dart`
    and `.../timeline_entry_point_test.dart` (fixture updates — AC-22's
    unpaired branch now requires `ActivityCardRepository`).

    CONCURRENCY INCIDENT (root cause, resolved earlier this wave): a P3
    Occasion.name amendment (committed `c1ae334` before this P4 completion)
    was NOT produced by Alex-Mobile-Dev-3. The original P3 worker, `Alex-Mobile-Dev`
    (not -2/-3), sent an `idle_notification` at 11:42:59Z tagged `interrupted`,
    which Scrum Master read as P3 being finished, and committed P3 + dispatched
    P4 to a fresh instance (`Alex-Mobile-Dev-3`) in the SAME worktree at
    11:53Z. But `Alex-Mobile-Dev` had not actually stopped: it resumed on its
    own and kept working past the interruption (rendering the P4/P5 design
    reference, finding the `Occasion.name` gap, fixing it), reporting back only
    at 12:02:26Z — by which point it had been writing to
    `occasion_suggestion_service.dart` and `test-results.md` in the same
    worktree at the same time as `Alex-Mobile-Dev-3`. This is a
    `MAX_CODE_WRITERS_PER_STORY=1` violation Scrum Master did not intend and
    did not detect until `Alex-Mobile-Dev`'s own report flagged the RunState
    field it expected (its P3 completion fields) had been overwritten by the
    P4 dispatch. No data was lost or corrupted — `Alex-Mobile-Dev`'s fix
    exactly matches what Scrum Master had already independently verified and
    committed in `c1ae334` — but this was luck, not design. Confirmed via
    `ListAgents` that `Alex-Mobile-Dev` is now `idle` (not running) and
    `Alex-Mobile-Dev-3` is the only live writer on this worktree going forward.
    LESSON for this wave: an `idle_notification` with `idleReason: interrupted`
    is NOT a completion signal and must not be treated as one — only a
    `result`-bearing idle notification (or the SubagentStop/mailbox
    notification with a real completion marker) means the agent is actually
    done. Do not dispatch the next phase into the same worktree until that.
  - Worktree: /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-001
  - Branch: codex/REQ-016_solo_stage1_relationship_assistant-STORY-001, BaseHead c5267b60f420ce04bd6f58e974759a8c0df94245
  - Output: coding-plan/test-results.md
  - Status: BLOCKED — P4 complete and committed, but see "BLOCKED — Product/Design
    Decision Needed" section above. Do NOT dispatch P5 or P6 until that decision
    is made; do not spawn Reviewer for a story review gate until the decision
    lands, since the review would need to know which of D-1/D-2/D-3 to check
    against.
  - Next after decision: P5 (needs P3+P4), P6 (needs P4).
  - P4 REWORK ROUND 2: COMPLETE and committed. `Alex-Mobile-Dev-2`
    (`Session-Recovery: YES`, same RunId/RunState/Worktree) rebuilt the
    5-pane filter, card footer CTA+overflow, and 4-item stage-1 tab bar.
    `flutter analyze lib test` 195 issues/0 errors; combined phase tests
    +194 ~1 -2 (only pre-existing out-of-scope reds); diff footprint =
    exactly the 6 declared write-scope files. Committed via
    `git-story-boundary.sh commit` -> `98e865d777c03e9f3bf8d93178d35a0bb45973e6`
    on `codex/REQ-016_solo_stage1_relationship_assistant-STORY-001`.
    Run record `RUN-...-STORY-001-mobile-dev.json` already shows
    `status: COMPLETED` (marker matched cleanly, no manual reconciliation
    needed this time). BaseHead NOT YET refreshed past `98e865d` — do that
    before the next phase dispatch.
  - Visual-fidelity round 2 verdict: `FAIL` (per
    `.agent-contract/design-fidelity-spec.md`, any visible discrepancy
    fails, no per-story prose waiver) but D-1/D-2/D-3 (the three deltas
    this rework existed to close) are CLOSED and confirmed cell-for-cell
    against the design canvas. Carried over unchanged from round 1: D-4
    (no per-card delete affordance in design vs. AC-13 mandating one),
    D-5 (line-2 type icon blocked by `ActivityCard.activityType` being an
    un-enumerated `String?`, a P2/domain change out of this run's scope).
    TWO NEW findings this round, both scope-boundary issues, not
    re-litigations of D-1/2/3:
    - D-6: stage-1 tab bar glyphs (checklist/lightbulb/book/edit-note in
      the design) were substituted with the 4 nearest existing
      `CupidIcons` tokens (`checkCircle`/`autoAwesome`/`draw`/`schedule`)
      because the shared icon file
      `mobile/lib/design_system/icons/cupid_icons.dart` has no matching
      codepoints and is outside this run's write scope. Worker frames
      this as needing a write-scope extension, not a product decision.
    - D-7: the capture shows two stacked bottom bars (new stage-1 bar +
      legacy 5-tab shell bar) because `mobile/lib/main_preview.dart:222`
      (`wrapInShell: true`) and `:2158` (tab mapping) are stale, predating
      the D-3 shell replacement. Explicitly a preview-harness defect, not
      a product defect (the real app renders one bar); file outside write
      scope.
    STOPPED HERE per the pre-authorized decision rule ("if FAIL with
    genuinely new D-ids: stop and report, do not re-litigate D-1/D-2/D-3")
    — reported to user, awaiting disposition on D-6/D-7 before P5/P6.

- STORY-003 tech-lead (Alan-Techlead-2): COMPLETED both passes.
  - Pass 1 (architecture-solution): mobile-only lane, no backend; 3 ADR-affecting
    discoveries re: ADR-007 disposable-cache assumption and ADR-010/schema-v3
    destructive-migration policy (flagged for a later `foundation`-mode Tech
    Lead pass to amend `system_architecture_memory.md`, non-blocking here);
    one-directional `openJournalComposer(context, seed:)` contract for
    STORY-007/008; 7 risk-surface gates; non-blocking `RESEARCH_TOOLS_UNAVAILABLE`
    note gating `OS_BACKUP_EXCLUSION_UNVERIFIED` (carried into P2 as a mandatory
    lookup task, not a blocker). Committed cbef1b4b73e35c6ae38712139b495606152b2e86.
  - Pass 2 (coding-plan, via SendMessage continuation): 5 phases, all Mobile
    lane. P1 (schema) -> P2 (media store + repository) -> P3 (list screen) ‖ P4
    (composer screen) -> P5 (entry point + menu row, includes `openJournalComposer`
    export - no separate contract phase). Critical path P1->P2->P4->P5.
    Committed 6023ad3b73b46687c80e4d17b4525cbec5da393c. Agent still idle/addressable
    (not yet released — may be reused for STORY-003 P2 continuation later).
  - MERGE NOTE (non-blocking, flag at merge time): P5 only ADDS a menu row to
    the "Tôi" tab's "Kho riêng của tôi" card block; STORY-004 adds 2 more rows
    to the same block — resolve by keeping both stories' rows, order not
    contractually fixed. P3 and P4 both touch `app_vi.arb`/`app_en.arb` for
    different l10n keys — fine since never run concurrently under
    MAX_CODE_WRITERS_PER_STORY=1, but sequence their arb edits carefully if a
    future wave ever parallelizes P3/P4 within this story.

- RUN-REQ-016_solo_stage1_relationship_assistant-STORY-003-mobile-dev
  - P1 (journal persistence schema): COMPLETED by Alex-Mobile-Dev-2.
    Committed 4551d4d5bbd7ac3a3a2cc31c62cfe44edf797e41. BaseHead refreshed to
    same sha. 21/21 phase tests pass; `flutter analyze lib/core/database
    test/core/database` clean; broader `flutter analyze lib test` shows 188
    pre-existing issues (0 in core/database, 0 introduced by this phase) —
    matches known BUG-20260907-001 repo-wide baseline, not a phase defect.
    Two deliberate beyond-spec hardening decisions: `beforeOpen: PRAGMA
    foreign_keys = ON` (SQLite ignores FK per-connection without it, so
    `ON DELETE CASCADE` on journal_photos would be inert without this) and
    `upsertEntry` uses `insertOrIgnore` for foreign ids (blocks cross-account
    overwrite, not just read, of another user's entry).
  - FLAGGED (non-blocking, resolve at merge — same fix regardless of which
    story lands first since both target schemaVersion 3): two OUT-OF-WriteScope
    hardcoded schemaVersion literal assertions break once schemaVersion is 3:
    `mobile/test/core/database/timeline_dao_test.dart:36` (`expect(...,1)` ->
    `3`) and `mobile/test/core/database/expense_dao_test.dart:37`
    (`expect(...,2)` -> `3`). No behavior assertions broken. Scrum Master to
    fix these two literals directly during the schemaVersion merge
    reconciliation (see KNOWN MERGE COLLISION section) — not a specialist task.
  - P2 (media store + repository: `JournalMediaStore`/`JournalRepository`/
    `JournalEntry`): code/DI complete and green (28/28 phase tests, 36/36
    regression, analyze clean of errors/warnings) but the phase's mandatory OS
    backup-exclusion lookup sub-task is BLOCKED. Alex-Mobile-Dev-2 (session
    b8a1eda8) retried `WebSearch`/`WebFetch` twice (fresh attempt + a
    Scrum-Master-directed retry) and both are confirmed disabled at the
    SESSION level (not per-agent, not transient — Tech Lead hit the identical
    restriction earlier). No native backup-exclusion config was written under
    `mobile/android/app/src/main` or `mobile/ios/Runner`; DI provisionally
    wires `getApplicationSupportDirectory` pending the lookup (commented as
    provisional, not the verified answer). Committed
    b081f408509c48d5fbc023ab1c4a3e36568b081a (partial — see test-results.md
    Phase P2 for full evidence + verbatim tool errors). BaseHead refreshed to
    same sha.
  - `OS_BACKUP_EXCLUSION_UNVERIFIED` HOLD is RESOLVED: `Alex-Mobile-Dev`
    (session ff6b64a5, `Session-Recovery: YES`) completed P2 against live
    vendor docs — Android `backup_rules.xml`/`data_extraction_rules.xml`
    wired in `AndroidManifest`, iOS `URLResourceValues.isExcludedFromBackup`
    via a method channel in `AppDelegate.swift`. Committed
    `2a357a2ea19375db6aa8732914e1a5e8bb94bf75`; BaseHead refreshed to same
    sha. `DEV_DESIGN_RENDER` also RESOLVED in the same run
    (`design-reference-s1:diary-ios.png` rendered, `Design-Screen: s1:diary`
    recorded in `story_master.md`).
  - NEW BLOCKER surfaced by the same run: `PREEXISTING_TEST_FAILURE` —
    `flutter build ios --debug --no-codesign` fails repo-wide (no per-flavor
    Xcode build configurations). Routed per
    `blockers-and-escalation.md`: created
    `BUG-20260907-002_ios_missing_per_flavor_xcode_build_configurations`.
    Distinct root-cause family from `BUG-20260907-001` (flutter test
    failures) — do not merge the rows.
  - `BUG-20260907-002` FIX LANDED on `main` (control checkout, no story
    worktree touched), commit `62f4517`: 18 new XCBuildConfiguration
    objects (Debug/Release/Profile x local/prod) + `local`/`prod` schemes +
    a regression guard test. `Iris-QC` `Mode: bugfix-review` returned
    `Outcome: DEFERRED_ONLY` (0 blocking, 4 deferred documentation/
    robustness notes, none affecting correctness). `bug_master.md` and
    `master_bugs_list.md` both set to `Status: DONE`. IMPORTANT still
    OPEN: STORY-003's worktree BaseHead (`2a357a2ea19375db6aa8732914e1a5e8bb94bf75`)
    predates this fix — refresh/rebase STORY-003 onto `main` past `62f4517`
    before dispatching P3, or its iOS build verification will hit the same
    pre-existing failure.
  - Worktree: /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-003
  - Branch: codex/REQ-016_solo_stage1_relationship_assistant-STORY-003, BaseHead 2a357a2ea19375db6aa8732914e1a5e8bb94bf75
  - Output: coding-plan/test-results.md
  - Status: `BUG-20260907-002` now `DONE`. Committed the previously
    uncommitted `test-results.md` DEV_DESIGN_RENDER note
    (`168232486bce65d3c7648aaf1420786327dcba3e`), rebased the story branch
    onto `main` (bugfix `62f4517` now an ancestor of HEAD
    `0e36d03e959489be8f98d6173410ecbee1c2d328`, clean rebase, no conflicts),
    and ran `git-story-boundary.sh refresh-base` — BaseHead is now
    `0e36d03e959489be8f98d6173410ecbee1c2d328`. READY: dispatch STORY-003 P3
    (expanded WriteScope for `journal_list_cubit.dart`, `journal_screen.dart`,
    `app_vi.arb`, `app_en.arb`, `journal_list_cubit_test.dart`,
    `journal_screen_test.dart` — design render for P3 is already done, only
    the screen implementation + `implemented-*.png` + verdict remain). No
    remaining blocker on this story.
  - RUN RECORD RECONCILED (guard-codes.md `STALE_ACTIVE_RUN`): the P2 run's
    final transcript message reported its blocker in prose without a bare
    `BLOCKER: <reason>` marker line, so automated release couldn't match it
    against `completion_markers: [MOBILE_COMPLETE]` and kept re-flagging
    `COMPLETION_INVALID`. Helen-SC directly inspected the worker output
    (phase_status.P2=COMPLETE, 30/30 tests, 0 analyze errors,
    `coding-plan/test-results.md` present in the worktree) and manually set
    `RUN-...-STORY-003-mobile-dev.json` `status: COMPLETED` with a
    `release_note` recording this reconciliation. This closes only the P2
    run record as a unit; the STORY-003-level wait on `BUG-20260907-002`
    above is unaffected and remains the operative next step.
  - RESIDUAL (non-blocking, resolve at P1 rework or merge time): the iOS half
    of the DB-file backup exclusion was never done. Android's rules already
    cover `cupid.sqlite` via the `root:app_flutter` exclusion, but on iOS the
    DB path is owned by `mobile/lib/core/database/cupid_database.dart` (a P1
    file, outside P2's write scope). `architecture/solution.md` §4 requires
    AC-9 to cover "media root and DB file" on both platforms; the P2 phase's
    own AC text names only the media root. This is a scope conflict between
    two artifacts, not a missed P2 task — Scrum Master must settle which
    artifact governs before the iOS DB exclusion is assigned to a run.

## Next Step On Resume

Both stories have exactly one run in flight; do not double-dispatch either.

1. STORY-001: P4 rework round 2 landed, committed `98e865d`. BLOCKED ON A
   USER DECISION for D-6/D-7 disposition (see "Active Runs" above) before
   refreshing BaseHead and dispatching P5/P6. Options put to the user:
   (a) extend STORY-001's write scope to add 4 glyphs to the shared
   `mobile/lib/design_system/icons/cupid_icons.dart` and re-run the P4
   gate a 3rd time; (b) accept the substituted icons + harness artifact as
   carried-forward limitations (same treatment as D-4/D-5) and proceed to
   P5/P6 now, letting the story Reviewer gate render the final
   CLEAN/DEFERRED_ONLY/PATCH_REQUIRED call; (c) something else the user
   specifies. Do NOT dispatch P5/P6 or Reviewer until this is resolved.
2. STORY-003: `BUG-20260907-002` is `DONE` (`Iris-QC` `DEFERRED_ONLY`).
   Branch rebased onto `main` past `62f4517`, BaseHead refreshed to
   `0e36d03e959489be8f98d6173410ecbee1c2d328`. `Alex-Mobile-Dev` dispatched
   for P3 (journal list screen + delete flows,
   `RUN-REQ-016_solo_stage1_relationship_assistant-STORY-003-mobile-dev`,
   same RunId, fresh phase) — IN FLIGHT. On return: verify write-scope diff,
   commit via `git-story-boundary.sh commit`, refresh BaseHead, check the
   Per-story visual-fidelity verdict (REQUIRED gate, design ref
   `s1:diary` already resolved). If clean, proceed to P4 (composer,
   parallelizable with P3 per the phase file, but MAX_CODE_WRITERS_PER_STORY=1
   means dispatch sequentially unless a second wave is opened) then P5, then
   the story review gate (Reviewer required — standard).
3. STORY-001 is shared-foundation: it must reach `MERGE_COMPLETE` into
   `codex/REQ-016_solo_stage1_relationship_assistant-integration` before
   STORY-002/004/006/012 (and transitively 005/007/008/009/010/011/013) become
   schedulable. STORY-003 has no dependents and can merge independently.
6. Before merging EITHER story, re-read the KNOWN MERGE COLLISION section
   above and resolve `cupid_database.dart` schemaVersion conflict directly
   (Scrum Master Git orchestration, not a specialist handoff) when the second
   story's merge hits it.
7. After each story's final phase passes and a story review gate (Reviewer
   required for both — standard/complex) records CLEAN/DEFERRED_ONLY, run
   `git-story-boundary.sh merge` into the integration branch.
8. Deferred/non-blocking: after STORY-003 merges, consider a `foundation`-mode
   Tech Lead pass to amend `system_architecture_memory.md` for the ADR-007/
   ADR-010 discoveries. Not required to finish STORY-003 itself.

## Do Not Re-read

- req_master.md, requirements/requirements.md (already loaded in full this session; reuse facts above).
- STORY-001 and STORY-003 story_master.md (already loaded/edited in full this session).
- STORY-001 coding-plan/master-plan.md, phase-P1-local-card-store.md (already loaded in full this session).
- STORY-003 coding-plan/phase-P1-journal-persistence-schema.md (already loaded in full this session).
- .claude/skills/scrum-master/references/handoffs/tech-lead.md and mobile-dev.md (already loaded in full this session).

## Notes

- Pre-flight `preflight_check.py` ACTION_NEEDED item was resolved this session: committed `data/bugs/master_bugs_list.md` + `BUG-20260907-001...` (commit 0fbb83c).
- Integration worktree/branch for REQ-016 confirmed via `ensure-integration` + `sync-integration` (in sync at BaseHead 0fbb83c3e0faa9632701b2b69df7b4ce4712e379 at that time; both stories have since advanced past that on their own branches, integration branch itself untouched until first merge).
- rtk's `find`/`grep` wrapper produced garbled/fabricated output when listing/searching `data/runtime/parallel-runs` and `data/requirements/**`. Prefer ranged `Read` over shell grep/find for these paths; do not rely on `rtk proxy` for source/config/workflow files — the query-first guard blocks it there regardless of path.
- `git-story-boundary.sh commit --req <REQ_DIR> --story <STORY> --message "..."` is the correct way to commit story-worktree-owned planning/implementation artifacts; Scrum Master owns this commit, not the specialist.
- `.claude/hooks/list-releasable-agents.sh` + `TaskStop` on its exact printed handles is the correct release mechanism; ran once this wave (released `Alan-Techlead@session-f8b579b2`).
- To pull a control-checkout commit's file content into a story worktree without tripping `guard-orphan-commit.sh` `EPHEMERAL_BRANCH_COMMIT`: `git checkout <sha> -- <exact paths>` (content-only, stages no commit) then `git-story-boundary.sh commit`. Used to land `main` commit `b516c48` (PO ac-patch) onto STORY-001 as `54173ad5`.
- BUG-20260907-002 (iOS per-flavor Xcode build configs) is distinct from BUG-20260907-001 (flutter test failures) — separate root-cause families, do not merge rows.
