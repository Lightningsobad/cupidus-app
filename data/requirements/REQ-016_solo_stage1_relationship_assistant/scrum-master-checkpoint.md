# Scrum Master Checkpoint: REQ-016 Solo Stage-1 relationship assistant

## CURRENT (read this first)

**6 of 13 stories DONE, merged** (STORY-001/002/003/004/006), integration tip
`b58afbe073eff4e1ebb9151735221532a9cf5a82`. STORY-007/011 remain BLOCKED
(need STORY-005/008 deps) — re-check once those land.

**PARALLEL WAVE ACTIVE.** 6 stories in flight, all coding-plans DONE and
committed, each single mobile-dev lane (`MAX_CODE_WRITERS_PER_STORY: 1`).
Current per-story phase state as of round 10 (2026-09-17, post
weekly-limit-reset recovery):

| Story | Agent | Phase in progress | BaseHead |
|---|---|---|---|
| STORY-005_conversation_starters | Alex-Mobile-Dev | P4 screen-and-entry-point | 96b7f827 |
| STORY-008_date_script_three_parts | Alex-Mobile-Dev-2 | P3 entry-point-and-script-screen | 9574213d |
| STORY-009_your_view_portrait | Alex-Mobile-Dev-3 | P4 portrait-screen | c61256c2 |
| STORY-010_compatibility_lookup | Alex-Mobile-Dev-4 | P3 result-blocks-and-card-push (self-reported COMPLETE pre-interruption, unverified — needs agent re-confirmation before commit) | a9078bba |
| STORY-012_phase_status_and_widget | Alex-Mobile-Dev-5 | P7 phase-line-and-countdown | 55836165 |
| STORY-013_graceful_exit_and_return | Alex-Mobile-Dev-6 | P3 stage1-wipe-and-purge | 5b08a16a |

**Recurring patterns to apply again without re-deriving:**
- Reuse the SAME RunId/RunState file for every phase of a story — never
  invent a new RunId for a `SendMessage` continuation.
- After sealing a completed phase's commit + `refresh-base`, edit that run
  file: clear `completed_at`/`completion_error`/`phase_completed`/
  `next_step*`, set `status: ACTIVE`, bump `updated_at`, update
  `base_head`/`worktree_head`, set `phase_in_progress: "P<n>"`, update
  `write_scope*` to the new phase file. Then manually re-add the run id to
  `parallel-scheduler.json.active_runs` (auto-prune only removes on
  `COMPLETED`, never re-adds).
- A run file showing `status: COMPLETED` + `completion_error: "Missing
  completion marker..."` can still be genuine: verify via (1) `ListAgents`
  idle, (2) worktree diff matches declared Write Scope exactly, (3) phase
  file's own Status field reads COMPLETE. If all 3 hold, treat as real,
  commit it, and remind the agent next dispatch to emit the literal marker.
- Schema-version collision, 4-way, unchanged: STORY-005/009/010/013 all
  independently bump Drift `schemaVersion` from divergent bases. Not a
  spawn-time blocker — resolve at merge time via serialized `sync-target`/
  `merge` + sequential renumbering (7->8->9->10, order TBD by
  merge-readiness). Do not pre-emptively message any Mobile Dev about it.
- Cross-story items still owed, not yet actioned: System Architecture Memory
  ADRs for STORY-012 (local notification + OS widget) and STORY-013
  (schemaVersion 7 + chapter-closure-as-sole-closed-state + wipe-registry
  convention); `pubspec.yaml` package-dependencies lock if a 7th story later
  touches it (STORY-012 already added `home_widget`/
  `flutter_local_notifications`/`timezone`).

**Round 10 recovery (2026-09-17, this note):** all 6 in-flight dispatches
(STORY-005 P4, STORY-008 P3, STORY-009 P4, STORY-010 P3, STORY-012 P7,
STORY-013 P3) simultaneously failed with `idleReason: failed`,
`failureReason: "weekly limit · resets 3am (Asia/Saigon)"` — genuine
Anthropic account exhaustion, not a guard block. Waited for reset (date
advanced to 2026-09-17, system confirmed reset). Verified via `ListAgents`
all 6 agents back `idle`; verified per-worktree `git status --porcelain`:
STORY-005/008/010/012 dirty with real uncommitted progress, STORY-009/013
clean (only exploratory reads before the failure hit). Sent
Session-Recovery `SendMessage` to all 6 (same RunId/Worktree/Branch/
BaseHead, no new RunIds), each told to inspect own existing diff first
(dirty) or start fresh (clean), finish the declared phase, update
test-results.md, and emit the literal `MOBILE_IMPLEMENTATION_COMPLETE: YES`
marker in final text. STORY-010's resume also asks the agent to re-verify
its own Completion Criteria itself, since its phase file's pre-interruption
`Status: COMPLETE` was never backed by a genuine completion report. None of
these 6 committed yet by Scrum Master — awaiting genuine verified
completions before next commit/dispatch round.

Full round 1-9 wave narrative (Tech Lead architecture/coding-plan dispatch,
per-phase completions, STALE_WAIT guard fix discovery, the round-7 session
recovery, and the schema-collision escalation from 2-way to 4-way) is
superseded by the CURRENT table above and the artifacts on disk
(`coding-plan/master-plan.md`, `coding-plan/test-results.md`, per-phase
files) — do not re-read that history; the recurring-patterns list above
already captures every reusable lesson from it.

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
