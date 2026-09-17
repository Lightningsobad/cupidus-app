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
| STORY-005_conversation_starters | Alex-Mobile-Dev | DONE (P1-P4), Implementation checkbox checked, commit 5be5a4d — review dispatch BLOCKED, see note below | 5be5a4dfd667925093a33b5c54b115b1d98ace0f |
| STORY-008_date_script_three_parts | Alex-Mobile-Dev-2 | DONE (P1-P4), commit 6818d2a2 — review dispatch BLOCKED, same GENERIC guard as STORY-005 | 6818d2a269b8e7dc78da21ba95b7bdf9f9574707 |
| STORY-009_your_view_portrait | (released) | DONE (P1-P5), commit dc190a49 — review dispatch BLOCKED, same GENERIC guard as STORY-005/008 | dc190a4920609b283509c600d11df8ea1327b030 |
| STORY-010_compatibility_lookup | (released) | DONE (P1-P6, all 6 phases COMPLETE), commit 8ee570cb — review dispatch BLOCKED, same GENERIC guard as STORY-005/008/009/013 | 8ee570cb4b733dbcdd96b12c425916b1dbcd22f5 |
| STORY-012_phase_status_and_widget | Alex-Mobile-Dev-5 (idle, kept alive — not released, see round-23) | Mobile lane exhausted: P1-P5,P7,P8 all DONE/sealed (commit 812f6ed6), P6 run status WAITING_EXTERNAL (see round-25) — AC_CONFLICT_CROSS_REQUIREMENT, PO decision needed, escalated to user (see below) | 812f6ed60d8dfad2fa5658c9c0bf95617fa14fae |
| STORY-013_graceful_exit_and_return | (released) | DONE (P1-P6, all 6 phases COMPLETE), commit 241b936d — review dispatch BLOCKED, same GENERIC guard as STORY-005/008/009 | 241b936dd2e2277732a31fcc103fab05ccc9c950 |

Rounds 11-19 (2026-09-17), via repeated `guard-open-parallel-runs-on-stop.sh
[OPEN_RUNS]`/`STALE_ACTIVE_RUN` cycles: sealed every remaining phase of
STORY-005 (P1-P4, commit `5be5a4d`), STORY-008 (P1-P4, commit `6818d2a2`),
STORY-009 (P1-P5, commit `dc190a49`), and STORY-013 (P1-P6, commit
`241b936d`) via the same 3-part protocol each time (ListAgents idle/running
check; worktree diff matches declared WriteScope exactly; phase file's own
Status field reads DONE/COMPLETE; `master-plan.md` Phases Overview confirms).
STORY-010 reached P5 (commit `e185e6cf`) and STORY-012 reached P5 (commit
`4d60113f`) along the way. Attempted Iris-QC `compact-story-review` dispatch
for STORY-005 (round 13), STORY-008 (round 14), STORY-009 (round 16), and
STORY-013 (round 19, twice) — **all 4 hit the byte-identical
`guard-parallel-spawn.sh [GENERIC]` block**: "story-review blocked; no
completed implementation lane with durable completion marker found for
<REQ>/<STORY>", confirmed via `guard-codes.md` narrow grep to have no
documented code or fix. Classified `GUARD_FEEDBACK_INSUFFICIENT`: do not
re-attempt Iris-QC dispatch for STORY-005/008/009/013 without a guard-code fix
or explicit user go-ahead. Surfaced to the user as an explicit blocker at the
round-19 response boundary (no reply yet). Separately, STORY-012's countdown
line (round 12) was found to also render on already-merged STORY-002's
card-detail screen, invalidating 2 of STORY-002's captured visual-fidelity
PNGs — regen those at STORY-012/integration merge time, not now.

**Round 24** (2026-09-17): 5th consecutive identical `guard-open-parallel-runs-on-stop.sh
[OPEN_RUNS]` Stop block for the STORY-012 run (still `BLOCKED`), despite the
block's own remedy already applied (durable `waiting_reason`/`next_resume_action`,
fully unindexed from `active_runs`/`blocked_runs`). Its own `next:` text said
"dispatch every ready sibling NOW", so re-tested the GENERIC review-gate block
against FRESH state before re-classifying: ruled out the "malformed completion_marker"
theory by confirming both STORY-005 (`completion_marker: "MOBILE_IMPLEMENTATION_COMPLETE: YES"`)
and STORY-008 (`completion_marker: "MOBILE_IMPLEMENTATION_COMPLETE"`, clean string,
`status: COMPLETED`) still hit the byte-identical `guard-parallel-spawn.sh [GENERIC]`
block ("no completed implementation lane with durable completion marker found").
`.claude/hooks/guard-doc.sh GENERIC` confirms `section not found` — no documented
remedy exists for this code. Checked `.parallel-spawn-input.*` temp files for a
diagnostic payload from the live attempt: none was left (only one stale unrelated
file from 2026-07-31, REQ-001/STORY-016). Confirmed: no ready sibling is actually
dispatchable right now (STORY-012 P6 = PO decision pending; STORY-005/008/009/010/013
review = undocumented GENERIC block). Both guards (`OPEN_RUNS` and `GENERIC`)
re-classified `GUARD_FEEDBACK_INSUFFICIENT` on fresh evidence, not stale
assumption. No further blind retries without a guard-code fix or explicit user
decision on the AC4 conflict.

**Round 25** (2026-09-17): Found the actual fix in
`.agent-contract/parallel-execution-policy.md` lines 259-263 (Runtime State
section) — `BLOCKED` and `ESCALATED` run statuses are explicitly documented as
"not capacity-consuming... but Stop/status flows must report them until Scrum
Master routes rework, escalates them to a durable backlog artifact, or
intentionally parks them as `PAUSED` or `WAITING_EXTERNAL`". Lines 230-235 and
245-252 confirm only `PAUSED`/`WAITING_EXTERNAL` (with `waiting_reason` +
`checkpoint_path` + `next_resume_action`, exactly what round-23 already added)
are the sanctioned park states the Stop hook can honor for a durable external
reason such as human input — `BLOCKED` was never going to satisfy `OPEN_RUNS`
no matter what metadata it carried. Fixed: changed the STORY-012 mobile-dev
run file's `status` from `BLOCKED` to `WAITING_EXTERNAL` (same durable
`waiting_reason`/`next_resume_action`/`checkpoint_path` fields kept), and
re-added the run id to `parallel-scheduler.json.paused_runs` (removed from
`active_runs`/`blocked_runs`, matching "PAUSED and WAITING_EXTERNAL do not
consume capacity" but "must remain visible in the scheduler"). If this
resolves `OPEN_RUNS`, apply the same status correction to any future
externally-blocked run instead of leaving it as bare `BLOCKED`. The GENERIC
review-gate block for STORY-005/008/009/010/013 is unrelated and still
unresolved (guard-doc.sh GENERIC: section not found; re-verified live twice
this session with clean completion markers).

**Round 26** (2026-09-17): The `OPEN_RUNS` block text changed after round-25's
status fix — it now names the run `WAITING_EXTERNAL` explicitly and adds a new
reason: "completion_marker present but run status is still parked". This is
new, useful signal (the guard IS reading the corrected status; the remaining
conflict is the stale `completion_marker: MOBILE_IMPLEMENTATION_COMPLETE`
field left over from sealing P8, contradicting a run that is honestly still
parked because P6 is not done). Applied the "Recurring patterns" rule already
documented below literally: deleted the `completion_marker` key entirely from
the run file (it should only reappear once a Stop event completes ALL
remaining phases, which P6 has not). Left `status: WAITING_EXTERNAL` and all
waiting_reason/next_resume_action/checkpoint_path fields untouched.

**Recurring patterns to apply again without re-deriving:**
- Reuse the SAME RunId/RunState file for every phase of a story — never
  invent a new RunId for a `SendMessage` continuation.
- After sealing a completed phase (commit + `refresh-base`), edit that run
  file: clear `completed_at`/`completion_error`/`phase_completed`/
  `next_step*`, set `status: ACTIVE`, bump `updated_at`
  (`date -u +"%Y-%m-%dT%H:%M:%S.000000Z"`), update `base_head`/`worktree_head`,
  set `phase_in_progress`, update `write_scope*` to the new phase file, and
  DELETE the `completion_marker` key entirely (it should only reappear once
  the release hook writes a new one at that phase's own Stop event). Manually
  re-add the run id to `parallel-scheduler.json.active_runs` (auto-prune only
  removes on `COMPLETED`, never re-adds).
- When a run reaches genuine terminal `status: COMPLETED` (all phases
  sealed), RESTORE/KEEP `completion_marker` instead of deleting it — a
  terminal record should not look artificially incomplete. This does NOT fix
  the GENERIC guard block above; tested both ways, identical block.
- A run file showing `status: COMPLETED`/`COMPLETION_INVALID` +
  `completion_error: "Missing completion marker..."` can still be genuine:
  verify via (1) `ListAgents` idle, (2) worktree diff matches declared Write
  Scope exactly, (3) phase file's own Status field reads COMPLETE. If all 3
  hold, treat as real and seal it.
- `STALE_ACTIVE_RUN` has two independent trigger shapes: (a) a stale
  `completion_error` on a genuinely-still-active run — clear it, restore
  `status: ACTIVE`, no commit; (b) `updated_at` older than 1800s with no real
  completion — just bump `updated_at` as a heartbeat after confirming via
  `ListAgents` + worktree-unchanged. Never commit/redispatch for either shape
  unless the phase file's own Status field actually reads COMPLETE.
- **`MARKER_MISSING`/`COMPLETION_INVALID` root cause** (diagnosed round 18):
  the release/validation hook checks the run file's `transcript_path` (the
  PARENT/orchestrator jsonl) for the completion marker instead of
  `agent_transcript_path` (the subagent's own transcript, where the marker
  genuinely appears). No specialist wording can self-heal this; it can also
  re-stomp `status`/`completion_error`/`updated_at` back to stale values on a
  later Stop event even after a manual fix (confirmed again round 21 on
  STORY-010 — two sequential `Edit` calls were silently overwritten; a single
  full-file `Write` after a fresh `Read` persisted correctly). Once the
  underlying phase is independently verified genuine and sealed, fix the
  fields once, move on, and only re-fix if a fresh Stop-hook block actually
  names that run again. Never edit `transcript_path`/`agent_transcript_path`
  themselves to game this.
- Schema-version collision, 4-way, unchanged: STORY-005/009/010/013 all
  independently bump Drift `schemaVersion` from divergent bases. Resolve at
  merge time via serialized `sync-target`/`merge` + sequential renumbering
  (7->8->9->10, order TBD by merge-readiness).
- Cross-story items still owed, not yet actioned: System Architecture Memory
  ADRs for STORY-012 (local notification + OS widget, plus the P5 disclosure
  that `IPHONEOS_DEPLOYMENT_TARGET` was raised 13.0->14.0 on all 9 Xcode
  configs, forced by `home_widget`/WidgetKit, dropping iOS-13 support — no
  REQ-016 AC governs minimum iOS version, flagged for review/merge attention)
  and STORY-013 (schemaVersion 7 + chapter-closure-as-sole-closed-state +
  wipe-registry convention); `pubspec.yaml` package-dependencies lock if a
  7th story later touches it.
- STORY-010 cross-cutting risks carried to merge/review time: UI/UX
  gradient-bar deviation on screen (10) vs AC-16/AC-17; ARB key
  `gift_ideas_guess_coming_soon` removed (cross-check STORY-009); missing
  InvariantRule for AC-32 prophetic-language gap; tier-2 content moderation
  (AC-35/D-15) still ungranted for both 144 zodiac and 256 MBTI cells;
  pre-existing unrelated red tests in `test/design_system` and 3 in
  `test/features/love_contracts` (proven pre-existing by a stash experiment).

Round 20 (2026-09-16/17): STORY-012's run file showed a real,
evidence-complete P5 completion (MARKER_MISSING tooling defect, not a real
absence). Verified via the 3-part protocol (10-file diff matches WriteScope
incl. new `mobile/ios/CupidPhaseWidget/` extension). Sealed: committed
`4d60113f58b70824c6072f8bfd7f80ac9157a06e`, `refresh-base` done. Reactivated
the run file (`phase_in_progress: P6`, `phases_remaining: [P8]`), continued
the SAME live teammate `Alex-Mobile-Dev-5` via `SendMessage` to start P6.
STORY-010 confirmed still genuinely mid-P6, no action needed that round.

Round 21 (2026-09-16/17): STORY-010 P6 (mbti-seed-content, last phase)
reported genuinely COMPLETE by Alex-Mobile-Dev-4 (256 MBTI cells, 16 axis
values, new `compat_mbti_seed_test.dart`, `compat_bands.v1.json` untouched).
Verified via the 3-part protocol; `master-plan.md` P1-P6 all COMPLETE.
Sealed: committed `8ee570cb4b733dbcdd96b12c425916b1dbcd22f5` (5 files,
+3098/-2), ran `refresh-base`. Hit the MARKER_MISSING stomp firsthand while
terminalizing the run file (see recurring-patterns bullet above); fixed by a
single full-file `Write` after a fresh `Read`. Removed the run id from
`parallel-scheduler.json.active_runs`, released `Alex-Mobile-Dev-4` via
`list-releasable-agents.sh` -> `TaskStop`. Did **not** attempt Iris-QC
dispatch — STORY-010 is recorded as a likely **5th cohort member** of the
GENERIC guard block (not attempted, not confirmed) alongside
STORY-005/008/009/013. STORY-012 (P6 in progress, P8 still queued) is the
only genuinely active run left in this wave.

Round 22 (2026-09-17): Alex-Mobile-Dev-5 reported STORY-012 P6 (evening
check-in) code+tests complete and green but **BLOCKED** by a genuine
cross-requirement AC conflict: REQ-002/STORY-021's AC4 compliance-guard test
(`mobile/test/features/reminders/reminder_copy_guard_test.dart`) bans
`flutter_local_notifications` (and every functional alternative
`alarm`/`awesome_notifications`) from `pubspec.yaml`, while REQ-016/STORY-012
`phase-P6-evening-check-in.md` §3 requires adding exactly that package for the
23h local reminder — no technical workaround exists (both named alternatives
are on the same ban list). Verified via the full 3-part protocol: worktree
diff (18 files) matches the agent's own delivered list plus one legitimate
2-line disclosed wiring touch to `activity_card_hub_view.dart` (adds the
`eveningCheckIn` scheduler param, same pattern as prior phases' hub-view
registration touches); `phase-P6-evening-check-in.md` §7 reads `Status:
BLOCKED` with a matching §8 blocker section citing the same failing test and
3 PO-decision options; `master-plan.md` line 62 also reads `BLOCKED`; the run
file's `blockers[]` array independently records the identical
`AC_CONFLICT_CROSS_REQUIREMENT` code/detail/options. Sealed the verified,
tested-green (but externally blocked) P6 work via `git-story-boundary.sh
commit` at `62dd329787800ff08e11ff1c1c94d75598fb17bf` (18 files, +2048/-42) —
committing to the story branch only, NOT merging into integration, since the
conflicting dependency must not ship until Product Owner decides. Refreshed
the run file (`base_head`/`worktree_head` -> `62dd3297`, `status: ACTIVE`,
`phase_in_progress: P8`, `phases_remaining: []`) and dispatched P8 (last
phase; deps P3, P7 both DONE, independent of P6) to the SAME live teammate via
`SendMessage`. **Scrum Master cannot spawn `product-owner` directly** (only
`brainstormer` may, per role-map.md) — this AC4 conflict is surfaced to the
human user as a required business decision (3 options in
`phase-P6-evening-check-in.md` §8: narrow AC4's scope to import-boundary only;
keep AC4 and move the 23h reminder to server push; or accept a permanently
red gate). Do not re-attempt to resolve this blocker without a user/PO
decision, and do not delete or weaken `reminder_copy_guard_test.dart`.

Round 23 (2026-09-17): Alex-Mobile-Dev-5 reported STORY-012 P8 (counter and
quiet surfaces, last mobile phase) genuinely DONE. Verified via the full
3-part protocol: worktree diff matches the declared P8 Write Scope exactly
(`wealth_counter_line.dart`, `gift_progress_block.dart`,
`activity_card_hub_view.dart` modify-only, 3 new test files);
`phase-P8-counter-and-quiet-surfaces.md` §7 reads `Status: DONE`;
`master-plan.md` P8 row reads `DONE` (P6 row correctly still `BLOCKED`). The
run file had independently surfaced a `RELEASE_MARKER_UNSATISFIABLE` blocker
(same structural MARKER_MISSING defect class — `transcript_path` points at
the parent/orchestrator jsonl, not the subagent's own transcript — confirmed
a third time, this time diagnosed by the worker itself after trying 3+ marker
wordings) requesting manual scheduler-slot release. Sealed P8 via
`git-story-boundary.sh commit` at `812f6ed60d8dfad2fa5658c9c0bf95617fa14fae`
(11 files, +1391/-17) and ran `refresh-base` (`BaseHead` now `812f6ed6`).
STORY-012's mobile lane is now fully exhausted: P1-P5, P7, P8 all DONE/sealed;
only P6 remains, still `BLOCKED` on the round-22 `AC_CONFLICT_CROSS_REQUIREMENT`
pending the same PO/user decision. Reconciled the run file to terminal
`status: BLOCKED` (single full-file `Write` after a fresh `Read`, since a
prior sequential `Edit` hit the same concurrent-modification race documented
in the recurring-patterns list) with only the `AC_CONFLICT_CROSS_REQUIREMENT`
blocker remaining, `release_note` documenting the manual release rationale,
and `worktree_head`/`base_head` at `812f6ed6`, plus `waiting_reason` and
`next_resume_action` fields for durable OPEN_RUNS-guard parking. Pruned the
run id from `parallel-scheduler.json` entirely (`active_runs` and
`blocked_runs` both empty for it) per the "terminal run -> prune from all
lists" rule — the run file itself (`status: BLOCKED` +
`checkpoint_path`/`waiting_reason`/`next_resume_action`) is now the sole
durable record; re-check `phase-P6-evening-check-in.md` §8 for the PO
decision before re-registering this run. Ran `list-releasable-agents.sh` —
it did **not** print
`Alex-Mobile-Dev-5` (its run is indexed in `blocked_runs`, not unindexed), so
per the release-agent rule it was **not** `TaskStop`'d; it remains idle and
addressable via `SendMessage` for when P6 can resume. The other 4 previously
stale handles (`Alex-Mobile-Dev-3/4/6`, bare `Alex-Mobile-Dev`) were still
printed by the hook and re-attempted via `TaskStop`; all returned "No task
found" (already gone, confirmed harmless, no further action). No other
parallel run is active in this wave — STORY-005/008/009/010/013 remain
sealed/DONE but review-gate-blocked by the round-19 `GENERIC` guard cohort
(unresolved, no new information this round), and STORY-012 is now blocked on
the same AC4 PO decision as P6. No runnable next step exists in this
requirement without external input (PO/user decision on AC4, or a guard-code
fix for the GENERIC review-gate block).

Round 10 recovery (2026-09-17): all 6 in-flight dispatches hit a genuine
weekly account-limit exhaustion (not a guard block); resumed via
Session-Recovery `SendMessage` (same RunId/Worktree/Branch/BaseHead) once
the limit reset. Fully superseded by rounds 11-12 above.

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
| STORY-005 | STORY-001, STORY-004 | standard (implementation DONE, review BLOCKED — see round-13 note) |
| STORY-006 | STORY-001 | standard (DONE, merged) |
| STORY-007 | STORY-001, STORY-002, STORY-003, STORY-005 | standard (BLOCKED) |
| STORY-008 | STORY-001, STORY-002, STORY-003, STORY-004 | standard (implementation DONE, review BLOCKED — same GENERIC guard as STORY-005, see round-14 note) |
| STORY-009 | STORY-004 | standard (implementation DONE, review BLOCKED — same GENERIC guard as STORY-005/008, see round-16 note) |
| STORY-010 | STORY-004 | standard (mobile-dev P5 dispatched, P4 sealed 6d59a6d0, see round-15 note) |
| STORY-011 | STORY-001, STORY-004, STORY-005, STORY-008 | standard (BLOCKED) |
| STORY-012 | STORY-001 | standard (P6 sealed BLOCKED on AC_CONFLICT_CROSS_REQUIREMENT, PO decision needed — see round-22 note; P8 last phase dispatched) |
| STORY-013 | STORY-001, STORY-004 | standard (mobile-dev P6 dispatched, P5 sealed d4f64984, see round-17 note) |

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
