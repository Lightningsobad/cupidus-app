# Scrum Master Checkpoint: REQ-016 Solo Stage-1 relationship assistant

## CURRENT (read this first)

**6 of 13 stories DONE, merged** (STORY-001/002/003/004/006), integration tip
`b58afbe073eff4e1ebb9151735221532a9cf5a82`. STORY-007/011 remain BLOCKED
(need STORY-005/008 deps) — re-check once those land.

**PARALLEL WAVE ACTIVE — round 31 dispatches in flight** (2026-09-17). Round
30 fully reconciled via the 3-part protocol: STORY-009 mobile-dev patch
(F-1/F-2/F-3) committed `d860557e`, refresh-base'd. STORY-010 mobile-dev patch
(F-1..F-5) committed `aaa2021a`, refresh-base'd — flagged the STORY-009/010
Drift schemaVersion 6->7 collision (2 stories, different new tables; reconcile
at integration merge, do not block story review on it). STORY-012 scoped-slice
reviews S1-S6a all PASSed (S6a ran `flutter test`, +33 passed), committed as
one batch `4833be73` (BaseHead deliberately left unchanged — Reviewer BaseHead
is never refresh-based). Released 8 finished teammates via
`list-releasable-agents.sh` + `TaskStop`.

Round 31 dispatched: fresh `compact-story-review` re-checks for STORY-009
(`Iris-QC`, RunId `...-STORY-009_your_view_portrait-reviewer-patch1`) and
STORY-010 (`Iris-QC-2`, RunId `...-STORY-010_compatibility_lookup-reviewer-patch1`),
both with `BaseHead` unchanged at the original merge-base
`b58afbe073eff4e1ebb9151735221532a9cf5a82` and handoff bodies narrowing scope
to only the findings the patch commits were meant to close (prior
review-report.md is the standing baseline, not to be re-litigated in full).
**STORY-012 S6b dispatch was attempted and BLOCKED by
`guard-parallel-spawn.sh` (`GENERIC`): "story-review blocked; implementation
writer run(s) still open: ...STORY-012...mobile-dev-gaps"** — Alex-Mobile-Dev-3
(G-1/G-2/G-3 gap-closer) is still genuinely `ACTIVE` on the same story, so a
reviewer cannot start concurrently. **Do not retry S6b until the gap-closer
run returns**; re-dispatch it (Target reviewer, Mode scoped-slice, same
fields as before) the moment that run is reconciled.

| Story | Agent | State | BaseHead |
|---|---|---|---|
| STORY-005_conversation_starters | (released) | `Outcome: DEFERRED_ONLY`, merged into integration (`2b5d841f`), commit `8bb1c2e2`. Held `Status: TODO` — `guard-story-done-evidence.sh` blocks DONE on missing `design-reference-*.png` (`VISUAL_RUNTIME_MISSING`). Devops confirmed (STORY-008 worktree) the render tool itself works, but the fix is per-worktree/gitignored and does NOT propagate here — STORY-005's own merged/integration worktree still needs its own render pass. Owner/path TBD (devops or mobile-dev) — decide next round. | n/a (merged) |
| STORY-008_date_script_three_parts | (released) | Devops confirmed `VISUAL_RUNTIME_MISSING` not reproducible in this worktree (pre-existing working Playwright install); committed `58ff2e56`. **Next**: dispatch mobile-dev to render `design-reference-*.png` for `s1:datescript` + write `visual-fidelity-report.md`, then re-dispatch Reviewer. | 58ff2e562df35d713393df9c197899c9ed0ffddb |
| STORY-009_your_view_portrait | Iris-QC (running, patch re-review) | Mobile-dev patch sealed `d860557e`. Awaiting `REVIEW_COMPLETE` from the patch re-review. | d860557ee220f2e606ad0d1d2c9129bd8d10a00e |
| STORY-010_compatibility_lookup | Iris-QC-2 (running, patch re-review) | Mobile-dev patch sealed `aaa2021a`. Awaiting `REVIEW_COMPLETE` from the patch re-review. | aaa2021abf79b7e4d63bb1e649ea01c66530c55b |
| STORY-012_phase_status_and_widget | Alex-Mobile-Dev-3 (G-1/G-2/G-3, running) | S1-S6a PASSed, committed `4833be73` (BaseHead unchanged, reviewer semantics). **S6b BLOCKED on open mobile-dev-gaps run — do not retry until that returns.** After S6b + gap-closer both land: dispatch `final-synthesis` (fresh reviewer, pass all 7 slice report paths: S2's `beforeYouGo` caller gap, S4's iOS `CFBundleURLTypes`/`configurationDisplayName` gaps routed to mobile lane, S5's `phase_status_cubit.dart` call-site O-1, S6a's BR-15 hard-coded-string N-1 carried into S6b). **Do not mark DONE.** | b58afbe073eff4e1ebb9151735221532a9cf5a82 (reviewer slices unchanged) |
| STORY-013_graceful_exit_and_return | (released) | F1 fixed (`req016.last_opened_at` added to `Stage1WipeRegistry`), committed `e80eb387`. F2/F3 (AC-13/AC-31/AC-32) DEFERRED per mobile-dev's own note. **Next**: re-dispatch Reviewer. | e80eb3874718eaa4fcd578b8da1fc746b2cbf786 |

**Next step when round-31 runs return**: verify each via the 3-part protocol
below. For STORY-009/STORY-010 reviewer runs: commit review-report.md/
scope-gate.md, do NOT refresh-base (Reviewer BaseHead stays an ancestor of
HEAD). For the STORY-012 gap-closer (mobile-dev, code-writer role): commit,
DO refresh-base, then immediately retry the S6b reviewer dispatch that was
blocked this round. When S1-S6b all land, dispatch `Reviewer: final-synthesis`
for STORY-012 with all 7 slice report paths. Also still owed: re-dispatch
Reviewer for STORY-008 (after its mobile-dev render) and STORY-013 (post
F1-only rework); decide/execute STORY-005's independent render-evidence path.
Do not re-litigate the GENERIC guard fix, the P6 AC4 decision, or STORY-012's
scope-gate re-plan — all closed.

**3-part verification protocol** (use before sealing any specialist's
reported-complete work): (1) `ListAgents` shows the agent idle; (2) worktree
`git diff` matches the declared WriteScope exactly; (3) the specialist's own
output file / phase file Status field reads DONE/COMPLETE. After sealing:
commit (Scrum Master only, specialists don't self-commit), then
`git-story-boundary.sh refresh-base --req <REQ_DIR> --story <STORY>` before
building the next spawn handoff — a stale `BaseHead` from skipping this step
was hit and fixed in round 29.

## Cross-story carry-forward (not yet actioned, review/merge-time)

- Schema-version collision, 4-way: STORY-005/009/010/013 all independently
  bump Drift `schemaVersion` from divergent bases. Resolve at merge time via
  serialized `sync-target`/`merge` + sequential renumbering.
- System Architecture Memory ADRs owed: STORY-012 (local notification + OS
  widget; P5 raised `IPHONEOS_DEPLOYMENT_TARGET` 13.0->14.0 on all 9 Xcode
  configs for `home_widget`/WidgetKit, dropping iOS-13 — no REQ-016 AC governs
  min iOS version, flag at merge) and STORY-013 (schemaVersion 7 +
  chapter-closure-as-sole-closed-state + wipe-registry convention).
- STORY-012's countdown line (round 12) also renders on already-merged
  STORY-002's card-detail screen, invalidating 2 of STORY-002's captured
  visual-fidelity PNGs — regen at STORY-012/integration merge time.
- STORY-010 cross-cutting (beyond its own F-1..F-5 rework): UI/UX
  gradient-bar deviation vs AC-16/AC-17; ARB key `gift_ideas_guess_coming_soon`
  removed (cross-check STORY-009); missing InvariantRule for AC-32
  prophetic-language gap; tier-2 content moderation (AC-35/D-15) ungranted
  for both 144 zodiac and 256 MBTI cells; pre-existing unrelated red tests in
  `test/design_system` and 3 in `test/features/love_contracts` (proven
  pre-existing by a stash experiment) — Scrum-Master/user-owned F-6/D-1/D-2.
- STORY-013: the 4 red tests in `test/features/auth/` are pre-existing
  baseline failures (110 passed/4 failed identically with the diff stashed).
- STORY-005's run file has stale `base_head`/`review_base_head` fields
  (reviewer's own non-blocking note) — low priority, fix opportunistically.
- STORY-010's `reviewer_gate_note`: `validate-reviewer-two-phase.sh`
  incorrectly demands `review/scope-gate.md` for `compact-story-review` mode
  — tooling inconsistency, not yet fixed.

## Known non-blocking guard quirks (do not re-investigate)

- `validate-reviewer-handoff.sh NO_REVIEW_CONTEXT` /
  `PARALLEL_WORKTREE_GATE_PATH_MISMATCH` on scoped-slice AND full-story-review
  dispatches: reads the control checkout's `review/` dir, which doesn't exist
  pre-merge — expected. Accept the reviewer's result via worktree file
  verification regardless.
- `scrum-master-active-scope.json`'s `scope_kind` auto-reverts to
  `"requirement"` on every handoff — tooling-recomputed, does not block
  delivery.
- `MARKER_MISSING`/`COMPLETION_INVALID`: the release hook can check the
  parent/orchestrator transcript instead of the subagent's own transcript.
  Once a phase is independently verified genuine via the 3-part protocol,
  fix the run file's status fields once (single full-file `Write` after a
  fresh `Read` — sequential `Edit`s can be silently overwritten) and move on.
- For ordinary `Flow: story` Git-Boundary: `BaseHead` must equal current
  worktree HEAD, not the pre-story merge-base.
- `git-story-boundary.sh start` for a story depending on an already-merged
  prior story defaults `MergeTarget`/`BaseHead` to `main` — wrong, `main`
  never holds merged story code (only the integration branch does). Fix:
  `start` -> `repair-boundary --branch <branch> --worktree <path>
  --merge-target codex/REQ-016_solo_stage1_relationship_assistant-integration
  --story-class <class> --depends-on <deps>` -> `sync-target`.

## Open, needs a real user decision (non-blocking, current impl stays valid)

- STORY-002 navigation architecture: (a) vertical frame-card list vs. chip
  strip, (b) separate full-screen per-field editor vs. inline sheet edit.
  Logged in `req_master.md` Design Ruling Log 2026-09-10.
- STORY-004 D-A (MAJOR, requirement-level): AC-14 clause 1's "giai đoạn quen
  nhau" stage axis has no artifact backing; PO must patch AC-14/AC-28 or open
  a follow-up story before REQ-016 integration review.

## Story Graph (from `requirements/requirements.md`)

| Story | Depends On | Story-Class |
|---|---|---|
| STORY-001 | NONE | shared-foundation (DONE, merged) |
| STORY-002 | STORY-001 | shared-foundation (DONE, merged) |
| STORY-003 | NONE | standard (DONE, merged) |
| STORY-004 | STORY-001 | complex, shared-foundation (DONE, merged) |
| STORY-005 | STORY-001, STORY-004 | standard (reviewed DEFERRED_ONLY, merged, held TODO on VISUAL_RUNTIME_MISSING) |
| STORY-006 | STORY-001 | standard (DONE, merged) |
| STORY-007 | STORY-001, STORY-002, STORY-003, STORY-005 | standard (BLOCKED, needs STORY-005/008) |
| STORY-008 | STORY-001, STORY-002, STORY-003, STORY-004 | standard (reviewed BLOCKED on VISUAL_RUNTIME_MISSING, devops fix in flight) |
| STORY-009 | STORY-004 | standard (reviewed PATCH_REQUIRED, rework in flight) |
| STORY-010 | STORY-004 | standard (reviewed PATCH_REQUIRED, rework in flight) |
| STORY-011 | STORY-001, STORY-004, STORY-005, STORY-008 | standard (BLOCKED, needs STORY-005/008) |
| STORY-012 | STORY-001 | standard (impl DONE all P1-P8, first review in flight) |
| STORY-013 | STORY-001, STORY-004 | standard (reviewed PATCH_REQUIRED, rework in flight) |

Open, non-blocking bugs (cite, do not re-run repo-wide commands):
`BUG-20260907-001` (repo-wide `flutter test` pre-existing failures),
`BUG-20260908-001` (repo-wide `flutter analyze` pre-existing chat/dream_jar
warnings). Closed: `BUG-20260907-002`, `BUG-20260910-001`.

## Archival: DONE, merged stories (one-liners; full history superseded by artifacts)

- **STORY-001_activity_card_hub** — shared-foundation dep for
  002/004/005/006/007/008/009/010/011/012/013. `merge_sha
  4c18bd31e5f011556c9656319201a02d9780a575`, `Outcome: DEFERRED_ONLY`.
  Non-blocking: `req_master.md` G-3/D-23/D-26 closure (`fd1da92`) is on
  `main` but not yet on the integration branch — reconcile at
  `land-integration`.
- **STORY-002_invite_message_composer** — complex, shared-foundation. Merged
  `844487bc2c5c29609c531575c43af74b3fdf2502` (`c65cda4`), `Outcome:
  DEFERRED_ONLY`. Closed `BUG-20260910-001`. Deferred: D-A2
  (`validatePresetPack` no `lib/` call site), D-B2 (`savePayload` key
  validation deferred), D-C1 (composer full-snapshot hazard, re-check for
  non-modal reuse).
- **STORY-003_private_journal** — independent. Merged `69b3690`, `Outcome:
  DEFERRED_ONLY`.
- **STORY-004_relationship_notebook_and_gift_ideas** — complex,
  shared-foundation. Merged `fa30737fea83bae932af3555e6ab7e35cadcaefb`
  (`23d471cd`), `Outcome: DEFERRED_ONLY`, 0 blocking across 36 ACs; F6 (AC-33
  exhaustion/cycling, MAJOR) fixed `b1feb3d`, re-verified CLOSED. Deferred:
  D-1 (MINOR) intra-round rotation revert order; D-2 (NIT) no state-level
  test for single-idea pack wrap; D-A (MAJOR, see decision list above); D-B
  AC-35 CMS clause (intentional requirement-level deferral); D-C..D-K lower
  severity, full text in `review/review-report.md`.
- **STORY-006_before_you_go_checklist** — standard. Merged
  `b58afbe073eff4e1ebb9151735221532a9cf5a82` (`617e64b`), `Outcome:
  DEFERRED_ONLY`. Deferred: D-1 `schemaId`/`schema_id` doc-only mismatch;
  D-2 `scheduledOn: '2026-10-01'` fixture time bomb in
  `activity_card_detail_screen_test.dart` (outside write scope). DevOps
  follow-up (not blocking): document `--split-per-abi` in the `mobile-app`
  runtime registry build command.

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
- Round 1-28 narrative history — fully superseded by the CURRENT table and
  carry-forward notes above; do not re-derive already-closed blockers
  (GENERIC guard fix, STORY-012 P6 AC4 decision).
