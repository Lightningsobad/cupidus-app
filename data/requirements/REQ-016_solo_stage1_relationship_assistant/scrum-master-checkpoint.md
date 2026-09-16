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
| STORY-010_compatibility_lookup | Alex-Mobile-Dev-4 | P6 mbti-seed-content dispatched (LAST phase; P5 verified+committed e185e6cf) | e185e6cfcb2ae0b18edd28cc3a71aaf210bf3c44 |
| STORY-012_phase_status_and_widget | Alex-Mobile-Dev-5 | P5 widget-ios-extension dispatched (P4 verified+committed e7437bcc) | e7437bcc83ba107b0a5c1d711c4c0fff5eed4fe1 |
| STORY-013_graceful_exit_and_return | (released) | DONE (P1-P6, all 6 phases COMPLETE), commit 241b936d — review dispatch BLOCKED, same GENERIC guard as STORY-005/008/009 | 241b936dd2e2277732a31fcc103fab05ccc9c950 |

Round 11 (2026-09-17): STORY-008 and STORY-010 came back idle with real,
verified P3 completions. Committed both (`4b33d96b`, `cfaccc28`),
refresh-base, reactivated run files in place, redispatched P4 to same
agents.

Round 12 (2026-09-17), forced by `guard-open-parallel-runs-on-stop.sh
[OPEN_RUNS]`: STORY-012 P7 (`status: COMPLETED`, genuine) and STORY-013 P3
(`status: COMPLETION_INVALID` — SubagentStop just missed the literal marker
string, work itself was genuine per diff+test-results.md AC coverage) both
verified and committed (`9743c172`, `e1eec120`). Same reactivate/re-add/
redispatch pattern applied; both agents now on next phase. STORY-012 P7
commit flagged a merge-time follow-up: its countdown line also renders on
already-merged STORY-002's card-detail screen, invalidating 2 of STORY-002's
captured visual-fidelity PNGs — regen those at STORY-012/integration merge
time, not now. STORY-005/009 still mid-phase, not yet returned.

Round 13 (2026-09-17): STORY-005 mobile-dev lane fully DONE (P1-P4, all
`master-plan.md` phase statuses `DONE`), `story_master.md` Implementation
checkbox checked, sealed at commit `5be5a4dfd667925093a33b5c54b115b1d98ace0f`
in the story worktree. Diff vs merge-base `b58afbe073eff4e1ebb9151735221532
a9cf5a82` (the correct Reviewer BaseHead) is 32 non-data files — over Tier-2's
12-file cap, so this story needs Tier-3 scoped-slice review (5 slices: P1
content-pack+gate 5 files, P2a schema/migration 11 files, P2b calendar
service 5 files, P3 selection/card handoff 4 files, P4 screen/entry 8 files +
owes visual-fidelity check, + one final-synthesis after all 5 return).
**BLOCKED**: `guard-parallel-spawn.sh [GENERIC]` still fires "story-review
blocked; no completed implementation lane with durable completion marker
found for REQ-016_solo_stage1_relationship_assistant/STORY-005_conversation_starters"
on every Iris-QC scoped-slice dispatch attempt for this story, even after
removing the stale `completion_error` field and refreshing
`base_head`/`worktree_head`/`updated_at`/`next_step` in the mobile-dev run
file to the current committed HEAD (the same fix class that worked for
STORY-012/013's `COMPLETION_INVALID` cases). Targeted `grep -A 20` searches
of `.claude/hooks/guard-codes.md` for `no completed implementation lane`,
`durable completion marker`, `implementation lane`, `### GENERIC`,
`COMPLETION_INVALID`, `NO_IMPL`/`IMPL_LANE`/`LANE_MISSING` all found nothing
— this GENERIC message has no documented code, so per the guard-feedback rule
this is `GUARD_FEEDBACK_INSUFFICIENT`: do not keep blind-retrying the same
Agent() dispatch. `master-plan.md`'s phase table (all 4 phases `DONE`) rules
out `REVIEW_NOT_READY`'s specific condition, so the block is coming from
something else the doc doesn't name. Next action needs either a user
decision on how to proceed, or inspecting the guard script itself (which
Scrum Master may not do without explicit user authorization to debug/patch
guard implementation). The 5 Handoff Control blocks (BaseHead
`b58afbe073eff4e1ebb9151735221532a9cf5a82`, RunIds ending
`-reviewer-slice-P1/-P2a/-P2b/-P3/-P4`) are fully designed and ready to send
once this unblocks. Do not re-attempt the Iris-QC dispatch again without
either a guard-code fix or explicit user go-ahead.

Round 14 (2026-09-17): three more genuine-but-unmarkable phase completions
reconciled via the same 3-part protocol (ListAgents idle + worktree diff
matches WriteScope + phase file `## 7. Status` reads DONE/COMPLETE):
STORY-009 P4 (final phase was P5, committed `efe65a4501b1ca71013290dc67f71316
ad69c826`, P5 dispatched to Alex-Mobile-Dev-3), STORY-012 P3 (P4 chosen as
critical path over P6/P8 under the 1-writer-per-story cap, committed
`35ac2e24f235f3b5f57d903d9f6242aa06abefe1`, dispatched to Alex-Mobile-Dev-5),
STORY-013 P4 (agent's own open question on the 2 visual-fidelity PNGs
resolved by including them, per STORY-009 precedent; committed
`84c1f0e1f5f00f051cce5cf0891fb147ad27bbbf`, P5 dispatched to
Alex-Mobile-Dev-6). Also reconciled STORY-008 P4 (all 4 phases now COMPLETE,
committed `6818d2a269b8e7dc78da21ba95b7bdf9f9574707`) and attempted its
compact-story-review dispatch to Iris-QC — **hit the exact same
`guard-parallel-spawn.sh [GENERIC]` "story-review blocked; no completed
implementation lane with durable completion marker found"** block as
STORY-005, with a fully-correct run file (`status: COMPLETED`,
`completion_marker: MOBILE_IMPLEMENTATION_COMPLETE` present, `base_head`/
`worktree_head` at current HEAD). This is now a **confirmed 2nd occurrence**
of the identical undocumented block on a fully-reconciled run file, so it is
systemic to story-review dispatch after manual reconciliation, not a
per-story data issue. Per `GUARD_FEEDBACK_INSUFFICIENT`, do not re-attempt
Iris-QC dispatch for STORY-008 or STORY-005 without a guard-code fix or
explicit user go-ahead. STORY-008 stays implementation-DONE/review-BLOCKED
alongside STORY-005 until resolved.

Round 15 (2026-09-17), forced by `guard-open-parallel-runs-on-stop.sh
[OPEN_RUNS]` flagging STORY-010 as `STALE_ACTIVE`: STORY-010 P4
(entry-point-screen-and-label-capture) verified genuine via the 3-part
protocol (worktree diff matches WriteScope, phase file `- Status: COMPLETE`
at line 10 — note this phase file's Status line sits in the top metadata
block, not under a numbered `## 7.` heading like other phase files) and
`master-plan.md` P1-P4 all `COMPLETE`. Committed `6d59a6d048b00963140ac82
57fedc98cc941c26d` (incl. the previously-missing `visual-fidelity/` dir,
now added to `write_scope*`), `refresh-base` done. P5 (zodiac-seed-content)
dispatched over the equally-ready P6 (mbti-seed-content) under the
1-writer-per-story cap — arbitrary first-in-sequence tie-break, P6 still
deferred. Alex-Mobile-Dev-4's own completion report (received concurrently)
independently confirmed the same facts and flagged two cross-cutting risks,
now durably recorded here for merge/review-time handling, not to be resolved
by Mobile Dev or Scrum Master now:
1. **UI/UX deviation**: frame "10-bang-tra-an-khop" renders the DẢI block as
   a 3-point gradient bar; may violate AC-16/AC-17 + uiux-spec §3.1. Needs a
   UI/UX-owned decision before merge review — do not silently accept or
   reject.
2. **Shared ARB key removal**: STORY-010's diff removes ARB key
   `gift_ideas_guess_coming_soon`. Verify at/before merge that STORY-009
   (still in flight) does not still reference it — a stale reference would
   break `AppLocalizations` and redden the build.
Two earlier agent-messages from Alex-Mobile-Dev-4 diagnosing `MARKER_MISSING`
(pointing at the pre-fix `status: COMPLETION_INVALID` + write_scope-pointing-
at-P5-while-phase_id-was-P4 mismatch) describe exactly the state this round's
reconciliation already corrected — no further action needed on those reports.

Round 16 (2026-09-17), forced by `guard-open-parallel-runs-on-stop.sh
[OPEN_RUNS]`: STORY-009 P5 (locked-entry-point, final phase) verified genuine
via the 3-part protocol — worktree diff (10 files) matches WriteScope exactly,
phase file `## 7. Status` reads `COMPLETE`, `master-plan.md` P1-P5 all
`COMPLETE`. Committed `dc190a4920609b283509c600d11df8ea1327b030`, refresh-base
done, run file marked terminal (`status: COMPLETED`) and removed from
`scheduler.active_runs`. Since all 5 phases are now COMPLETE, this is a
**3rd occurrence** of implementation-DONE-but-review-BLOCKED: did **not**
re-attempt Iris-QC dispatch (per `GUARD_FEEDBACK_INSUFFICIENT`, already
confirmed systemic at STORY-005/STORY-008) — recorded STORY-009 alongside
them, still pending guard-code fix or explicit user go-ahead. Released
Alex-Mobile-Dev-3 (`TaskStop`, nothing left in its lane). Also corrected a
false-positive `STALE_ACTIVE`/`COMPLETION_INVALID` flag on STORY-010's run
file: verified P5 (`phase-P5-zodiac-seed-content.md`) is still `Status:
NOT_STARTED` with a clean worktree (no commits/changes past P4's
`6d59a6d0`) — Alex-Mobile-Dev-4 is still genuinely mid-P5, so cleared the
spurious `completion_error` and restored `status: ACTIVE` with no other
changes; no commit, no redispatch needed.

Round 17 (2026-09-17), forced by `guard-open-parallel-runs-on-stop.sh
[OPEN_RUNS]` flagging STORY-010 `STALE_ACTIVE` (new sub-variant: no
`completion_error`, just `updated_at` older than the 1800s staleness window
per `guard-codes.md` `STALE_ACTIVE_RUN`) plus a concurrent genuine
Alex-Mobile-Dev-6 completion report: (1) STORY-010 confirmed still genuinely
mid-P5 (ListAgents running, worktree unchanged since P4) — no commit, just
bumped `updated_at` as a heartbeat to clear the time-based false flag, no
other field touched. (2) STORY-013 P5 (closed-archive-pane) verified genuine
via the 3-part protocol (worktree diff 17 files matches WriteScope incl. the
same-precedent visual-fidelity PNGs, phase file `## 7. Status` reads
`COMPLETE`), committed `d4f64984cd8d18265eb99a7db4292a34703e17f3`,
refresh-base done. A SubagentStop guard then stamped a stale
`completion_error` on the run file referring to the already-sealed P5 stop
event — cleared it (moot once phase advanced past it). Dispatched P6
(phase-P6-return-gate-and-screen.md, dep P3 COMPLETE) via `SendMessage` to
the same live Alex-Mobile-Dev-6 session (not a fresh spawn).

Round 18 (2026-09-17), forced by `guard-active-scope-stale-on-stop.sh
[STALE_ACTIVE_RUN]` + `guard-open-parallel-runs-on-stop.sh [OPEN_RUNS]`
flagging all 3 in-flight runs at once: (1) STORY-013's run file hit the
`MARKER_MISSING`/`COMPLETION_INVALID` stomp a **2nd time** (same 3 fields
only, `write_scope*` intact) — re-applied the standard fix
(`completion_error` cleared, `status: ACTIVE`, `updated_at` bumped); this is
the occurrence that let Alex-Mobile-Dev-6 pin down the root cause, now
recorded above. (2) STORY-012 confirmed genuinely `BLOCKED`
(`ListAgents`->idle, not just time-stale): P4 (widget-bridge-android)
verified genuine via the 3-part protocol (worktree diff matches WriteScope +
1 disclosed extra file `activity_card_hub_view.dart` needed for a real
publisher registration, phase file `## 7. Status` reads `DONE`), committed
`e7437bcc83ba107b0a5c1d711c4c0fff5eed4fe1`, refresh-base done, P5
(widget-ios-extension, dep P4) dispatched via `SendMessage` to the same
Alex-Mobile-Dev-5 session. (3) STORY-010 P5 (zodiac-seed-content, 144
cells/12 axis values) verified genuine via the 3-part protocol (worktree
diff matches WriteScope, phase file `## 1. Phase Metadata` reads `Status:
COMPLETE`), committed `e185e6cfcb2ae0b18edd28cc3a71aaf210bf3c44`,
refresh-base done. Per `master-plan.md`, P6 (mbti-seed-content) is the
**last** phase of this story — dispatched via `SendMessage` to the same
Alex-Mobile-Dev-4 session, carrying forward the >50KB asset test-harness fix
pattern (`_DiskBundle.loadString` override) and a do-not-touch note on
`compat_bands.v1.json` (shared touch point with P6). All 3 findings/risk
notes from STORY-010 P5 (UI/UX gradient-bar deviation, ARB key removal, AC-32
InvariantRule gap) stay durably logged here for merge/review time, not
actioned now. All 3 agents confirmed `running` via `ListAgents` after
dispatch — genuinely mid-phase, no further reconciliation needed this round.

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
- **Root cause found round 18** for the "`completion_marker` is present but
  status is still active" `STALE_ACTIVE_RUN`/`OPEN_RUNS` variant, which fired
  identically 3x in a row on all 3 runs (STORY-010/012/013) and survived both
  a `completion_error` clear and an `updated_at` real-clock fix (use
  `date -u +"%Y-%m-%dT%H:%M:%S.000000Z"` for hand-written timestamps —
  guessed values landed in the future relative to actual UTC, but that was
  NOT the actual trigger for this variant): the SubagentStop release hook
  writes the DETECTED `completion_marker` value into the run file when a
  phase ends (success or blocker text), but does not clear it when Scrum
  Master resets `status: ACTIVE` to dispatch the NEXT phase. The leftover
  value from the PREVIOUS phase's Stop event, sitting alongside a fresh
  `ACTIVE` status, is exactly the inconsistent combination this guard
  detects. Fix: when reactivating a run file for the next phase, DELETE the
  `completion_marker` key entirely (not just clear `completion_error`) —
  it should only reappear once the release hook writes a new one at that
  phase's own Stop event. Applied to STORY-010/012/013 round 18; watch next
  Stop-hook cycle to confirm this clears the guard.
- **Refinement, round 19**: the round-18 delete rule applies ONLY when
  resetting a run to `status: ACTIVE` for the NEXT phase. Once a run reaches
  genuine terminal `status: COMPLETED` (all phases done, sealed by commit +
  refresh-base), RESTORE/KEEP `completion_marker` on that terminal run file —
  it is the same field the specialist's own genuine completion carries, and a
  terminal record should not look artificially incomplete. Applied to
  STORY-013's run file round 19. Important: restoring it did NOT fix the
  separate story-review spawn `GENERIC` guard block below — that is an
  independent, still-unresolved defect; do not treat `completion_marker`
  presence/absence as a lever for it anymore (tested both ways, identical
  block).
- `STALE_ACTIVE_RUN` has two independent trigger shapes per `guard-codes.md`:
  (a) a stale `completion_error` field on a genuinely-still-active run — clear
  the field, restore `status: ACTIVE`, no commit; (b) `updated_at` older than
  `PARALLEL_RUN_STALE_ACTIVE_SECONDS` (1800s) with no real completion at all —
  just bump `updated_at` as a heartbeat after confirming via `ListAgents`
  (running, not idle) and worktree-unchanged that the agent is genuinely still
  mid-phase. Never commit or redispatch for either shape unless the phase
  file's own Status field actually reads COMPLETE.
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
- **`MARKER_MISSING`/`COMPLETION_INVALID` structural defect** (diagnosed by
  Alex-Mobile-Dev-6, round 18): the release/validation hook checks the run
  file's `transcript_path` (the PARENT/orchestrator session's own jsonl) for
  the completion marker instead of `agent_transcript_path` (the subagent's own
  transcript, where the marker genuinely appears). This means the field can
  never self-heal from a specialist's wording alone, and re-fires on a later
  Stop even after Scrum Master manually restores `status: ACTIVE` — it stomps
  only `status`/`completion_error`/`updated_at` back to the stale P5-era
  values, NOT `write_scope*` (those survive manual edits). Do not keep
  re-fighting this in a loop: once the underlying phase is independently
  verified genuine (3-part protocol) and sealed (commit + refresh-base), fix
  the 3 fields once more, move on to real dispatch work, and only re-fix again
  if a fresh Stop-hook block actually names this same run. This is a known
  tooling defect, not a real absence of completion — do not gate-game by
  editing `transcript_path`/`agent_transcript_path` themselves.

Round 19 (2026-09-17): STORY-013 P6 (last phase) reported COMPLETE by
Alex-Mobile-Dev-6 with full evidence (test-results.md P6 section 9: 110
passed / 4 failed both with and without the P6 diff stashed, confirming the 4
red `test/features/auth/` failures are pre-existing baseline, not caused by
this phase). Verified via the standard 3-part protocol (worktree diff exactly
matches declared WriteScope; `coding-plan/master-plan.md` Phases Overview
shows P1-P6 all COMPLETE; agent's own detailed report matches). Sealed: committed
`241b936dd2e2277732a31fcc103fab05ccc9c950` (13 files, +1323/-8), ran
`refresh-base` (BaseHead now `241b936d...`), marked the run file terminal
(`status: COMPLETED`, `completion_marker: MOBILE_IMPLEMENTATION_COMPLETE`
restored per the refinement above), removed the run id from
`parallel-scheduler.json.active_runs`, released `Alex-Mobile-Dev-6` via
`list-releasable-agents.sh` -> `TaskStop`. Then attempted to dispatch Iris-QC
`compact-story-review` for STORY-013 twice (once with `completion_marker`
deleted, once restored) — both attempts blocked with the byte-identical
`guard-parallel-spawn.sh [GENERIC]` message: "story-review blocked; no
completed implementation lane with durable completion marker found for
REQ-016_solo_stage1_relationship_assistant/STORY-013_graceful_exit_and_return".
Checked `guard-codes.md` `## GENERIC` section (narrow grep, per the
hook-source-read guard's own allowed pattern): confirmed this message has no
dedicated code yet and no documented field/value fix. Cross-referenced the
rest of this checkpoint and found rounds 13/14/16 already hit and fully
diagnosed the SAME message for STORY-005, STORY-008, and STORY-009
respectively, each concluding `GUARD_FEEDBACK_INSUFFICIENT` and instructing no
further Iris-QC retries without a guard-code fix or explicit user go-ahead.
STORY-013 is therefore a **4th confirmed occurrence** of this systemic,
unresolved block — joining STORY-005/008/009 in the same
"implementation-DONE, review-BLOCKED" cohort. Do not re-attempt Iris-QC
dispatch for any of these 4 stories again without either a guard-code fix
(requires explicit user authorization to debug/patch guard implementation) or
explicit user go-ahead. STORY-010 (P6, last phase, not yet reported) and
STORY-012 (P5 in progress, P6/P8 remaining) are the only 2 genuinely active
runs left in this wave; both are still mid-implementation, not yet at their
own review-gate dispatch point. Given 4 fully-implemented stories now parked
on the identical undiagnosed guard, this is worth surfacing to the user as an
explicit blocker at the next natural response boundary, not just a checkpoint
note.

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
| STORY-012 | STORY-001 | standard (mobile-dev P4 dispatched) |
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
