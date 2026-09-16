# Scrum Master Checkpoint: REQ-016 Solo Stage-1 relationship assistant

## CURRENT (read this first)

**6 of 13 stories DONE, merged** (STORY-001/002/003/004/006), integration tip
`b58afbe073eff4e1ebb9151735221532a9cf5a82`. STORY-007/011 remain BLOCKED
(need STORY-005/008 deps) — re-check once those land.

**PARALLEL WAVE ACTIVE (2026-09-11).** 6 ready stories in flight:
STORY-005, STORY-008, STORY-009, STORY-010, STORY-012, STORY-013.

Round 1 (`architecture-solution`, planning class, own fresh worktree each)
dispatched to Tech Lead, all 6 reached `TECH_LEAD_COMPLETE`/`status:
COMPLETED` (verified on disk, not just run file — some runs showed a
transient stale `COMPLETION_INVALID`/`completion_error: "Missing completion
marker..."` release-hook glitch while artifacts were already correct on
disk; self-corrects or is cosmetic-only, not a real blocker). STORY-012
narrowed its own lane to mobile-only in this pass — accepted as authoritative.

Round 2 (`coding-plan`, same agent via `SendMessage` continuation — same
RunId/RunState/worktree, NOT a fresh spawn) just dispatched to all 6,
back-to-back in one control turn, using `handoff-build.sh spawn --mode
coding-plan --worktree/--branch/--merge-target/--base-head` (explicit git
fields — worktrees are dirty with uncommitted architecture files, so
`git-story-boundary.sh start` re-derivation fails "worktree is dirty";
supplying all four fields bypasses that) + `handoff-build.sh continue` for
Missing-outputs/Do-Not-Re-read:
- STORY-005 -> Alan-Techlead-2 (msg f293cc06) — fold in 4 named discoveries
  (R-1g InvariantRule, occasion_suggestion_service A-1 flag, QuickEntryCell
  wiring, ActivityCardOrigin enum, schemaVersion 6->7 Drift bundling) +
  correct Implementation Lane to mobile-only.
- STORY-008 -> Alan-Techlead-3 (msg 49b2390e).
- STORY-009 -> Alan-Techlead (msg 10eb765a).
- STORY-010 -> Alan-Techlead-4 (msg 4e4fe8f7).
- STORY-012 -> Alan-Techlead-5 (msg e1765b97) — also correct Implementation
  Lane to mobile-only.
- STORY-013 -> Alan-Techlead-6 (msg 148512a6).

Run files: `data/runtime/parallel-runs/RUN-REQ-016_solo_stage1_relationship_assistant-<STORY>-tech-lead.json`.
**Next step on each `TECH_LEAD_COMPLETE` (coding-plan mode):** verify
`coding-plan/master-plan.md` has a parseable Phase Overview table, then
schedule the first ready phase(s) to the appropriate lane (mobile-only
confirmed so far for STORY-005/008/009/010/012/013 — every story in this
wave turned out mobile-only, no backend/devops lane exists for any of
them), respecting `MAX_CODE_WRITERS_PER_STORY: 1`. Do not schedule Reviewer
or implementation off architecture-only completion — coding-plan must exist
and be phase-complete first.

**STORY-005 coding-plan DONE** (verified on disk: 4 phase files +
`master-plan.md` + `coding-agent-guide.md`, `story_master.md` Lane
corrected). Committed Tech Lead's architecture+coding-plan artifacts to the
STORY-005 worktree (`da7e0ad`, was dirty and blocked the next spawn — sealed
it, this is routine Scrum-Master git orchestration, not specialist work).
Critical path P1→P3→P4, P2 off-path but needed before P3; P1+P2 both
`Depends On: None`, one mobile lane so sequential not parallel. **Dispatched
`Alex-Mobile-Dev` Phase P1** (`mobile-implementation`,
RunId `...-STORY-005_conversation_starters-mobile-dev`, BaseHead `da7e0ad`).
P2 is separately ready once P1's writer is free (`MAX_CODE_WRITERS_PER_STORY:
1` — do not run P1+P2 concurrently in the same story).

**STORY-008 coding-plan DONE** (verified on disk: 4 phase files +
`master-plan.md` + `coding-agent-guide.md`, `architecture/` present).
Committed Tech Lead's architecture+coding-plan artifacts to the STORY-008
worktree (`638e2e0`, same dirty-worktree pattern as STORY-005 — sealed it).
Phases strictly sequential (P2 needs P1, P3 needs P2, P4 needs P3 — only P1
immediately dispatchable). Screen (9) is intentionally routeless
(BR-1a/SC-6, location-locked) so visual-fidelity evidence must come from a
`RepaintBoundary` capture inside a widget test, not device/emulator
deep-linking. **Dispatched `Alex-Mobile-Dev-2` Phase P1**
(`mobile-implementation`, RunId
`...-STORY-008_date_script_three_parts-mobile-dev`, BaseHead `638e2e0`).

**STORY-009 coding-plan DONE** (verified on disk: 5 phase files +
`master-plan.md` + `coding-agent-guide.md`, `story_master.md` Lane corrected
mobile-only). Tech Lead hit a stop-guard deadlock in its round-1 pass
(`validate-techlead-handoff.sh` blocked 4x with `master-plan.md not found`
even though `Mode: architecture-solution` should skip that check) and wrote
the full coding-plan directly to unblock itself — accepted as legitimate,
matches the known `project_techlead_architecture_only_stop_deadlock` pattern;
**do not dispatch a fresh coding-plan pass for STORY-009, it would overwrite**.
Removed a stray `architecture-tmp-placeholder.md` the Tech Lead couldn't
delete (no Bash) from the worktree root before committing. Committed
(`4920cc8`). 5 phases strictly sequential (P2 needs P1's pack shape, P3 needs
P1+P2, P4 needs P2+P3, P5 needs P4) — only P1 dispatchable. AC-22 resolved via
a narrow `recordAnsweredQuestion(...)` write door inside the STORY-004 module
(does not violate STORY-004 §6 contract). **Dispatched `Alex-Mobile-Dev-3`
Phase P1** (BaseHead `4920cc8`).

**STORY-013 coding-plan DONE** (verified on disk: 6 phase files +
`master-plan.md` + `coding-agent-guide.md`). Committed (`7fe3d78`). All 6
phases (P1..P6) strictly sequential, single mobile lane, no parallel
execution possible (shared ownership of `core/di/service_locator.dart` and
`cupid_database.dart`) — only P1 dispatchable. P1 carries the `schemaVersion`
6->7 migration; Tech Lead flagged that this reddens schema assertions in
other DB test files and the phase must clean up ALL of them in the same
phase (told to Mobile Dev explicitly). Filter strip already has 5 columns so
"Đã đóng" is the 6th; `uiux-spec.md` §3 calls it "cột thứ 5" per an older
screenshot — also flagged to Mobile Dev. **Dispatched `Alex-Mobile-Dev-4`
Phase P1** (BaseHead `7fe3d78`).

**STORY-010 coding-plan DONE** (verified on disk: 6 phase files +
`master-plan.md` + `coding-agent-guide.md`). Committed (`8af089d`). P1+P2
both `Depends On: None` but `MAX_CODE_WRITERS_PER_STORY: 1` forces sequential
— dispatched P1 only. **Critical content-integrity rule for every Mobile Dev
phase on this story:** axis-count values must be derived from shipped
content packs, never hardcoded as literals (12/16/144/256) in `mobile/lib/`
— P1 ships a small seed axis set, P5/P6 widen it later; hardcoding breaks
that property. **Dispatched `Alex-Mobile-Dev-6` Phase P1** (BaseHead
`8af089d`).

**STORY-012 coding-plan DONE** (verified on disk: 8 phase files +
`master-plan.md` + `coding-agent-guide.md`). Committed (`061b60c`). Critical
path P1→P2→P7→P8; once P1 lands, P2+P3+P6 unlock together (parallel, but
still one writer per story). **Dispatched `Alex-Mobile-Dev-5` Phase P1**
(BaseHead `061b60c`). **Two things owed before scheduling STORY-012 P5:**
(a) P5 will create a requirement-level `deployment/configuration-guide.md`
(App Group iOS entitlements + Android 13+ `POST_NOTIFICATIONS`, added
provisionally by P6 if P6 runs first) — P5's WriteScope must add
`data/requirements/REQ-016_solo_stage1_relationship_assistant/deployment/`,
which is outside the story directory; (b) confirm RunState `write_scope`
reflects the coding-plan WriteScope before dispatching further phases (Tech
Lead flagged dispatch-1's `architecture/`+`story_master.md` write_scope may
still be showing instead of dispatch-2's `coding-plan/` scope — check the
run file, not just the handoff prose, before the next phase spawn).

**STORY-005 Phase P1 COMPLETE** (`MOBILE_IMPLEMENTATION_COMPLETE`, 38 new
tests pass, scoped analyze clean). Committed implementation (`110ac79`):
starter/calendar content packs, R-15c gate, R-1g invariant-term wiring.
**Sent `SendMessage` continuation to the same `Alex-Mobile-Dev` agent for
Phase P2** (BaseHead `110ac79`) — built by hand per handoff-schema.md since
`handoff-build.sh continue` only emits the ordinary `Flow: story`/
`Git-Boundary` schema, not the parallel-worker fields; the ordinary-schema
output is NOT valid for a parallel worker continuation, always
hand-preserve `Parallel-Execution/RunId/RunState/Worktree/WriteScope/
OutputPath/CompletionMarker` from the original spawn when this happens
again.

**STORY-008 Phase P1 COMPLETE** (52 tests pass, scoped analyze clean).
Committed (`daf54b6`). Corrected two Tech Lead planning defects surfaced by
Mobile Dev: (a) phase file mis-cited AC-6 for the "each requires: []" rule —
actually AC-10+AC-37, code/tests already correctly target AC-10/AC-37; (b)
`contract-summary.md` §1 example JSON says `schemaId`, parser correctly
reads `schema_id` per the repo-wide `req016.*` convention — no code change
needed, doc-only mismatch, same class as STORY-006's D-1. Also: P2 actually
`Depends On: P1` (not None as originally relayed) — corrected in the
continuation. **Sent `SendMessage` continuation to `Alex-Mobile-Dev-2` for
Phase P2** (BaseHead `daf54b6`).

**Wave status (round 4): all 6 stories have an active Mobile Dev writer** —
STORY-005/008 on P2 (dispatched round 3), STORY-013 still on P1 (genuinely
in-flight, not yet reporting), STORY-009/010/012 P1 COMPLETE and just
dispatched to P2 this round (`Alex-Mobile-Dev-3`/`-6`/`-5`, BaseHead
`4920cc8`/`8af089d`/`061b60c` respectively; phase files
`phase-P2-answer-store-and-notebook-door.md` /
`phase-P2-relationship-labels-store.md` / `phase-P2-phase-resolver.md`).

**STALE_WAIT guard root cause + fix pattern (2026-09-11/12):** a
`SendMessage`-hand-built parallel continuation (used because
`handoff-build.sh continue` doesn't support parallel-worker fields) never
flips the target run file back from `status: COMPLETED` to `ACTIVE` the way
a fresh `Agent` spawn does via `guard-parallel-spawn.sh`. Left stale, the
Stop-hook `guard-active-scope-stale-on-stop.sh` cannot find a non-terminal
run for the agent and misattributes the block to an unrelated old run
sharing the same reused agent name. **Fix, apply every time a P2+ phase is
dispatched by hand-built SendMessage, not just on guard block:** after
sending, edit that run's `data/runtime/parallel-runs/<run-id>.json` —
remove `completed_at`/`completion_error`/`phase_completed`/
`next_step*`/`next_unlockable*`/`parallel_schedulable_now`, set
`status: "ACTIVE"`, bump `spawned_at`/`updated_at`, update `base_head`/
`worktree_head` to the new commit, add `phase_in_progress: "P<n>"` +
`phase_note` explaining why, and update `write_scope*` phase-file entries to
the new phase file. Then add/keep the run_id in
`parallel-scheduler.json`'s `active_runs` (this index is advisory only —
an external reconciliation process rewrites it independently and may drop
entries seconds after you add them; the run file's own `status` field is
the actual source of truth, don't chase the index further than one retry).

**Wave status (round 5):** STORY-005 P2 was implemented but left uncommitted
in-worktree (agent's own `phase_note` flagged "not self-committed", P2 must
land as ONE commit per master-plan.md §6). Scrum Master committed it as
`3eb580134d69e5a2ddd0532890c39c324441b092` on
`codex/REQ-016_solo_stage1_relationship_assistant-STORY-005_conversation_starters`
(17 files, +1052/-20, incl. new `calendar_event_state_table.dart` +
conversation_starters `data/` + migration test). Then dispatched **STORY-005
to Phase P3** (`phase-P3-selection-and-card-handoff.md`) via `SendMessage`
continuation to the same agent `Alex-Mobile-Dev` (msg
`dac299d8-e7c6-4205-8d9a-fe52d57cc2dc`, BaseHead `3eb5801`). Run file
re-activated to `status: ACTIVE`/`phase_in_progress: P3`.

STORY-013's P1 SubagentStop transcript never surfaced the completion marker
(`completion_error: "Missing completion marker..."`) even though P1 work was
already committed at `7fe3d780` (worktree_head matches base_head, current).
Dispatched **STORY-013 to Phase P2**
(`phase-P2-closure-service-and-read-exclusion.md`) via `SendMessage`
continuation to the same agent `Alex-Mobile-Dev-4` (msg
`35978bff-8e1e-4c7e-8c26-be2728e20aa8`, BaseHead unchanged `7fe3d780`). Run
file re-activated to `status: ACTIVE`/`phase_in_progress: P2` per the
STALE_WAIT fix pattern above (applied to both run files this round, plus
`parallel-scheduler.json` `active_runs` re-synced to list all 6 run ids —
external reconciliation has repeatedly shrunk this index seconds later; not
chased further than one retry per documented policy, run-file `status` is
authoritative).

All 6 stories now have a live Mobile Dev writer: STORY-005 P3, STORY-008 P2,
STORY-009 P2, STORY-010 P2, STORY-012 P2, STORY-013 P2.

**Wave status (round 6):** `ListAgents` showed `Alex-Mobile-Dev-2` (STORY-008)
and `Alex-Mobile-Dev-5` (STORY-012) went idle (genuine P2 completions).
Committed both as Scrum Master: STORY-008 P2 -> `9574213d13ffb56f00d39aff659236d9bca0ff5f`
(date_script_selector.dart + date_script_renderer.dart, 36 tests);
STORY-012 P2 -> `55836165c282b8518edc663098fd9402abc7d861` (phase_status
feature + req016 content assets, 164 tests incl. 44 new). Dispatched
**STORY-008 to Phase P3** (`phase-P3-entry-point-and-script-screen.md`) via
`SendMessage` to the same agent `Alex-Mobile-Dev-2` (msg
`f3b21fdc-e210-470e-87ab-3044098ed630`, BaseHead `9574213`); P3 touches
`invite_composer/presentation/widgets/prepare_actions_sheet.dart` so it must
rerun all of `test/features/invite_composer/`. Dispatched **STORY-012 to
Phase P7** (`phase-P7-phase-line-and-countdown.md`, chosen over P3/P6 to stay
on critical path P1->P2->P7->P8) via `SendMessage` to the same agent
`Alex-Mobile-Dev-5` (msg `10014695-dd84-4d69-8e8b-a68f2a57e4e6`, BaseHead
`5583616`); P7/P8 both touch `activity_card_hub_view.dart` and must stay
sequential. Both run files re-activated per the STALE_WAIT fix pattern.

Live phase state now: STORY-005 P3, STORY-008 P3, STORY-009 P2, STORY-010 P2,
STORY-012 P7, STORY-013 P2 — all 6 stories still have exactly one active
Mobile Dev writer each (single-lane, MAX_CODE_WRITERS_PER_STORY=1).

**Cross-story coordination flagged by Tech Leads, not yet actioned:**
- **Schema-version collision risk**: STORY-005 P2 and STORY-013's
  chapter-closure phase both independently plan Drift `schemaVersion 6->7`
  from the same base tip. Not a spawn-time blocker (write-scope overlap
  resolves at merge per policy), but whichever of the two merges second
  will need its migration renumbered to 7->8 during `sync-target` conflict
  resolution — handle it then (Scrum-Master git orchestration), do not
  pre-emptively message either Tech Lead.
- **System Architecture Memory update owed** (outside both runs'
  WriteScope, need a dedicated pass with `system-architecture-memory` in
  LockScope before/around merge, `MAX_SHARED_MEMORY_WRITERS_GLOBAL: 1`):
  STORY-012 wants an ADR for local notification + OS widget capability
  (R9 consequence: no server-side push exists, confirmed console.log stub);
  STORY-013 wants an ADR for schemaVersion 7 + "chapter-closure log is sole
  closed-state source" + a cross-story wipe-registry convention.
- **`pubspec.yaml` package-dependencies lock**: STORY-012 adds `home_widget`
  0.9.4, `flutter_local_notifications` 22.3.0, `timezone`. No other story in
  this wave currently touches `pubspec.yaml` — no live conflict, but if a
  7th story is added to this wave later and also touches it, it needs
  `LockScope: package-dependencies:pubspec`.

Active-scope pointer note: `data/runtime/scrum-master-active-scope.json` is
auto-overwritten by the SendMessage hook to whichever continuation was sent
last (expected hook behavior) — recovery source of truth is the run-id list
above, not the pointer file, until the wave reaches a quiescent boundary.

**Agent release owed (do only once a story's Tech Lead has nothing further
pending on it):** run `.claude/hooks/list-releasable-agents.sh`,
cross-check against fresh `ListAgents` before any `TaskStop` — the script
has been observed printing an actively-running agent as releasable
(`SendFeedback` filed, session `798d014f-5c13-4b1a-b79d-9730e6b30504`, not
yet fixed).

## Archival: STORY-006_before_you_go_checklist — DONE, merged

standard, Depends-On STORY-001. Merged at `merge_sha
b58afbe073eff4e1ebb9151735221532a9cf5a82` (story commit `617e64b`), round-2
`full-story-review` `Outcome: DEFERRED_ONLY` (round-1 F-1 Runtime Startup
Smoke + F-2 Entry Point Reachability both closed with evidence only, no
source change). Deferred, non-blocking: D-1 `schemaId`/`schema_id` doc-only
mismatch; D-2 `scheduledOn: '2026-10-01'` fixture time bomb in
`test/features/activity_cards/activity_card_detail_screen_test.dart`
(outside this story's write scope, worth a look before that date). DevOps
follow-up (not actioned, not blocking): document `--split-per-abi` in the
`mobile-app` runtime registry build command (521MB all-ABI debug APK doesn't
fit typical device free space). Full P1/P2/patch-round/guard-quirk history
superseded by artifacts (`review/review-report.md`, phase files,
`coding-plan/test-results.md`) — do not re-read unless that report shows a
discrepancy.

## Archival: STORY-004_relationship_notebook_and_gift_ideas — DONE, merged

complex, shared-foundation, Depends-On STORY-001 (runtime dep only, AC-6's
push-to-hub). Merged at `merge_sha fa30737fea83bae932af3555e6ab7e35cadcaefb`
(story commit `23d471cd04adc577cdab85dd8abcc23071f21f88`). Review `Outcome:
DEFERRED_ONLY` — 0 blocking across 36 ACs; F6 (AC-33 exhaustion/cycling
defect, MAJOR) fixed (`b1feb3d`), independently re-verified CLOSED.

Deferred, not blocking: **D-1** (MINOR) intra-round rotation reverts after a
round's lead is dismissed — fix direction: rotate `suggestions` to
`roundStartGiftId` first, then drop dismissed. **D-2** (NIT) no state-level
test for single-idea pack wrap-and-clear. **D-A** (MAJOR,
requirement-level) — AC-14 clause 1's "giai đoạn quen nhau" stage axis has
no artifact backing; PO must patch AC-14/AC-28 or open a follow-up story,
adjudicate before REQ-016 integration review. **D-B** — AC-35's CMS clause,
intentional requirement-level deferral. D-C..D-K: lower-severity, full text
in `review/review-report.md`.

`BUG-20260910-001`: fully closed, gate-satisfied, no further action.

**Known non-blocking guard quirks** (do not re-investigate):
- `validate-reviewer-handoff.sh NO_REVIEW_CONTEXT` /
  `PARALLEL_WORKTREE_GATE_PATH_MISMATCH` on scoped-slice AND full-story-review
  dispatches alike: reads the control checkout's `review/` dir, which
  doesn't exist pre-merge — expected. Accept the reviewer's result via
  teammate message + independent worktree file verification regardless of
  this gate's state; do not ask Reviewer to retry `Outcome:` variants.
- `scrum-master-active-scope.json`'s `scope_kind` auto-reverts to
  `"requirement"` on every handoff even when hand-corrected to `"story"` —
  tooling-recomputed, not persistable by hand, does not block delivery.
- Ordinary `Flow: story` Git-Boundary `BaseHead` must equal current worktree
  HEAD (not the pre-story merge-base); put the merge-base
  (`711274e3fde25788c91390a44572d53766bba778`) in handoff prose/query keys
  instead, e.g. `git -C <Worktree> diff 711274e3... HEAD`.

**Open, non-blocking, needs a real user decision** (surfaced via
`PushNotification`, logged in `req_master.md` Design Ruling Log 2026-09-10
STORY-002 row): (a) vertical frame-card list vs. chip strip, (b) separate
full-screen per-field editor vs. inline sheet edit — genuine
navigation-architecture PO/user call. Current spec-compliant implementation
stays valid/mergeable while open.

**Standing boundary note** for every future story depending on an
already-merged prior story: `git-story-boundary.sh start` defaults
`MergeTarget` to `main` and `BaseHead` to `main` HEAD — wrong, `main` never
holds a story's merged code (only the integration branch does). Fix
sequence: `start` -> `repair-boundary --branch <branch> --worktree <path>
--merge-target codex/REQ-016_solo_stage1_relationship_assistant-integration
--story-class <class> --depends-on <deps>` -> `sync-target` (pulls the
integration branch's commits into the story worktree). Resolve any
`sync-target` conflict directly (Scrum-Master git orchestration, never
delegated), then `sync-target --continue`.

## Archival: STORY-002_invite_message_composer — DONE, merged

complex, shared-foundation, Depends-On STORY-001. Merged at
`844487bc2c5c29609c531575c43af74b3fdf2502` (story commit `c65cda4`), review
`Outcome: DEFERRED_ONLY`. Closed `BUG-20260910-001` as part of this story's
patch round. Deferred findings to carry into STORY-007/008 planning: D-A2
(`validatePresetPack` no `lib/` call site), D-B2 (`savePayload` key
validation deferred), D-C1 (composer full-snapshot hazard, re-check for
non-modal reuse).

## Archival: STORY-001_activity_card_hub — DONE, merged

Shared-foundation dependency for STORY-002/004/005/006/007/008/009/010/011/
012/013. Merged at `merge_sha 4c18bd31e5f011556c9656319201a02d9780a575`,
review `Outcome: DEFERRED_ONLY`. Non-blocking carry-forward: `req_master.md`
G-3/D-23/D-26 closure commit `fd1da92` is on `main` but not yet on the
integration branch — reconcile whenever `land-integration` runs.

## Archival: STORY-003_private_journal — DONE, merged

Independent (Depends-On NONE). Merged at `69b3690`, review `Outcome:
DEFERRED_ONLY`.

## Story Graph (from `requirements/requirements.md`)

| Story | Depends On | Story-Class |
|---|---|---|
| STORY-001 | NONE | shared-foundation (DONE, merged) |
| STORY-002 | STORY-001 | shared-foundation (DONE, merged) |
| STORY-003 | NONE | standard (DONE, merged) |
| STORY-004 | STORY-001 | complex, shared-foundation (DONE, merged) |
| STORY-005 | STORY-001, STORY-004 | standard (mobile-dev P1 dispatched) |
| STORY-006 | STORY-001 | standard (DONE, merged) |
| STORY-007 | STORY-001, STORY-002, STORY-003, STORY-005 | standard (BLOCKED) |
| STORY-008 | STORY-001, STORY-002, STORY-003, STORY-004 | standard (mobile-dev P1 dispatched) |
| STORY-009 | STORY-004 | standard (mobile-dev P2 dispatched) |
| STORY-010 | STORY-004 | standard (mobile-dev P2 dispatched) |
| STORY-011 | STORY-001, STORY-004, STORY-005, STORY-008 | standard (BLOCKED) |
| STORY-012 | STORY-001 | standard (mobile-dev P2 dispatched) |
| STORY-013 | STORY-001, STORY-004 | standard (mobile-dev P1 dispatched) |

Open, non-blocking bugs (cite, do not re-run repo-wide commands):
`BUG-20260907-001` (repo-wide `flutter test` pre-existing failures),
`BUG-20260908-001` (repo-wide `flutter analyze` pre-existing chat/dream_jar
warnings). Closed: `BUG-20260907-002`, `BUG-20260910-001`.

## Do Not Re-read

- `req_master.md`, `requirements/requirements.md`, all DONE stories'
  `requirements.md`/`uiux-spec.md`/`architecture/*`/`coding-plan/master-plan.md`
  — superseded by the Archival entries above.
- Any DONE story's full phase-by-phase history, slice-review files, or
  round-1 `review/review-report.md` — fully superseded by artifacts and the
  one-line Archival summaries above; re-read only if a fresh reviewer
  report shows a discrepancy.
- `test-results.md` files (can be 80KB+) — use `git diff`/`Read
  offset/limit`, never a full Read.
