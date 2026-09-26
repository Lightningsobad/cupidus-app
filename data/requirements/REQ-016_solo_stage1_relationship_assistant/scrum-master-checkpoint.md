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

6. **OPEN, BLOCKING — escalated to user this round (Round 41), REQ-016 cannot
   be marked DONE until resolved.** F-I2 action item 6
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

## Current cursor (Round 41, `continue parallel`, 2026-09-26 — F-I2/F-I3 devops dispatched, mobile-visual-audit blocked on lock, patch1 run closed out)

- Resolved OPEN_RUNS Stop-hook guard re-trigger on
  `RUN-...-STORY-013_graceful_exit_and_return-mobile-dev-patch1`: per
  `.agent-contract/parallel-execution-policy.md` ("BLOCKED... must be
  reported until Scrum Master routes rework... or intentionally parks
  them"), adding only `waiting_reason`/`next_resume_action` while leaving
  `status: BLOCKED` was NOT sufficient to stop the guard re-flagging it.
  Rework was already routed and landed (patch2, `MOBILE_COMPLETE: YES`,
  merged `753d2a86`), so the run file's own `status` field now reads
  `COMPLETED` with `resolution: SUPERSEDED_BY_REWORK` and
  `resolved_by_run_id` pointing at patch2 — matching the precedent set by
  the terminal `...-NONE-reviewer` run file, where `status: COMPLETED` is
  independent of business outcome (there: `review_outcome: PATCH_REQUIRED`;
  here: superseded-without-completing). `waiting_reason`/`next_resume_action`
  text kept as-is for audit trail.
- Dispatched `Frank-Devops` (`Flow: parallel-requirement`, `Story: NONE`,
  `Mode: devops-implementation`, RunId
  `RUN-REQ-016_solo_stage1_relationship_assistant-NONE-devops-fi2fi3`,
  `ConcurrencyClass: code-writer` — `integration-review` class is
  reviewer-only per `BAD_CONCURRENCY_CLASS`, `LockScope:
  requirement-state:REQ-016_solo_stage1_relationship_assistant`, worktree =
  the existing integration worktree, `BaseHead: 753d2a86...`) for F-I2
  action item 5 (`integration-review/build-runtime-evidence.md`: real build +
  real app-launch smoke, `## Integration Build & Runtime`, plus a
  confirm/deny on whether `BUG-20260923-001`'s 11 `test/core/database/` reds
  are version-lag only) and F-I3 action item 7
  (`deployment/configuration-guide.md`: add local-notification section, fix
  the stale POST_NOTIFICATIONS single-consumer claim). **In flight — awaiting
  SubagentStop/mailbox notification, not polling.**
- Attempted to dispatch `Alex-Mobile-Dev` (same requirement-level pattern,
  `Mode: requirement-mobile-visual-audit`, RunId
  `...-NONE-mobile-dev-visualaudit`) for F-I2 action item 6
  (`integration-review/mobile-visual-audit.md`) in the SAME batch. **Blocked
  by `guard-parallel-spawn.sh` [GENERIC]: `requirement-state:
  REQ-016_solo_stage1_relationship_assistant` lock already held** by the
  just-spawned Frank-Devops run. Expected/correct serialization (no
  finer-grained lock class exists for requirement-level integration-review
  artifacts) — NOT a bug, not retried with a workaround lock. No orphaned run
  file was created for this blocked attempt (confirmed via scheduler dump).
- Frank-Devops returned `DEVOPS_COMPLETE: YES` (its own SubagentStop
  transcript marker was missing — known failure mode — but the run file
  itself carries the marker and full evidence directly). 3-part verification
  passed: `list-releasable-agents.sh` showed it idle; worktree diff matched
  WriteScope exactly (`build-runtime-evidence.md` new,
  `configuration-guide.md` modified, nothing else); evidence content checked
  by eye — real `flutter build apk --debug --split-per-abi` PASS (85.2s, 3
  ABI split APKs), real `emulator-5554` app-launch smoke PASS (WARM launch,
  `ResumedActivity` confirmed, clean `am force-stop`), D-I2 confirmed CLOSED
  (`flutter test test/core/database/` now 104/104 passing —
  `BUG-20260923-001`'s 11 tracked reds do not reproduce at this HEAD,
  schemaVersion caught up by sibling merges), and `configuration-guide.md`
  gained the requested Local Notifications section (init ~65-67, iOS
  permission ~95-124, `tz.UTC` scheduling ~139-165,
  `inexactAllowWhileIdle` rationale) plus the POST_NOTIFICATIONS
  second-consumer correction. Committed in the integration worktree as
  `0a8f4214`. `Frank-Devops` released via `TaskStop`.
- Re-dispatched `Alex-Mobile-Dev` (FRESH spawn — prior patch1 instance
  released) for F-I2 action item 6
  (`integration-review/mobile-visual-audit.md`), RunId
  `...-NONE-mobile-dev-visualaudit`, rebuilt with explicit
  `--worktree/--branch/--merge-target/--base-head` (full-length sha
  `0a8f421410e964ffec81033a7213adff35281858` — the integration worktree HEAD
  after the devops commit; `handoff-build.sh`'s default `--req/--story`
  derivation fails for `Story: NONE` requirement-level handoffs with
  `BOUNDARY_WORKTREE_MISSING`, and a truncated short-sha `BaseHead` trips
  `STALE_BASEHEAD` — always pass the full 40-char sha for these). **In
  flight — awaiting SubagentStop/mailbox notification, not polling.**
- `Alex-Mobile-Dev` returned genuine `MOBILE_COMPLETE: YES` (after one
  mid-task `idle_notification interrupted` recovered via `SendMessage
  Session-Recovery: YES` restating the full original parallel-handoff fields —
  worktree confirmed clean of edits before resuming, so no fresh spawn was
  needed; run file self-corrected from a transient `COMPLETION_INVALID` to
  `status: COMPLETED` by the time it was re-read, no manual release-hook
  workaround needed). 3-part verification passed: agent releasable; worktree
  `git status --porcelain` showed exactly the one declared `WriteScope` file;
  full file content read and eyeballed — real seam-by-seam evidence (device
  cold-launch capture + 3 RepaintBoundary widget-test seams, 3 green
  capture-suite runs, two apparent anomalies investigated and correctly
  dismissed as harness artifacts). Committed in the integration worktree as
  `c1c538ea`. Accepted markdown-only evidence for this cross-story audit type
  (screenshots/scratch test suites intentionally left in
  `/tmp/req016-visual-audit/`, outside WriteScope; ephemeral cleanup is fine)
  — distinct from the per-story visual-fidelity gate's committed-PNG
  requirement. `Alex-Mobile-Dev` released via `TaskStop`.
- Audit raised **F-M1** (solo stage-1 tabs unreachable in solo mode,
  contradicting decision D-3) plus NOTE-1 (blank `Bảng tra ăn khớp` body
  during pack load, by AC-28 design, worth a PO glance) and NOTE-2 (a user who
  denies the FCM-init `POST_NOTIFICATIONS` prompt silently gets no REQ-016
  evening check-in). F-M1 escalated as **Open user decisions item 6** above —
  BLOCKING, not routed to Reviewer first, since it is a product-scope reversal
  of an already-explicit prior decision (D-3), not an implementation detail.
- **Next resume action (STOPPED pending user decision):** F-I2 and F-I3 are
  both now fully closed out. The ONLY remaining gate before a fresh `Iris-QC`
  requirement-integration-review is Open user decisions item 6 (F-M1) — the
  answer changes what that review checks: (a) wire-the-tabs needs new
  implementation work before AC-22 can even be reviewed; (b) explicit deferral
  needs the deferral recorded (Design Ruling Log / `req_master.md`) BEFORE the
  review runs, so the reviewer checks the updated AC-22 scope, not stale D-3
  wording. Once decided: (i) apply it (implementation dispatch, or a recorded
  deferral — Scrum Master cannot spawn Product Owner directly per role-map,
  only `brainstormer` does, so a wording-only AC patch may need that path, or
  a direct Scrum-Master-owned `req_master.md`/Design Ruling Log status entry
  if it's an annotation, not an AC rewrite); (ii) dispatch a FRESH `Iris-QC`
  requirement-integration-review (new RunId — prior one terminal
  `PATCH_REQUIRED`) scoped to `stage1_wipe_registry.dart`, the parity test
  result, the configuration guide section, both new integration-review
  evidence files, and the F-M1/AC-22 disposition (9 previously-PASS
  cross-story contracts do not need re-verification); (iii) on `Outcome:
  CLEAN`/`DEFERRED_ONLY`: re-sync `main` if moved, `cleanup-requirement`,
  `land-integration`, flip `req_master.md` + `master_requirements_list.md` to
  `DONE`.

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
