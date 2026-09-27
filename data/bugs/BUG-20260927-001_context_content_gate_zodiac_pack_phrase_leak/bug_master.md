# Bug Master: BUG-20260927-001 `context_content_gate_test.dart` BR-16 Zodiac Pack-Phrase Leak

Status: DONE
Severity: BLOCKING to REQ-017_checkin_notebook_capture/STORY-001_checkin_notebook_capture
Phase P1 completion (P1's own required `context_notebook` regression scope
includes this suite); still non-blocking to REQ-016 requirement-level delivery
(pre-existing, confirmed byte-identical at that surfacing run's own BaseHead,
out of that run's write scope); blocking to the
`mobile/test/features/context_notebook/context_content_gate_test.dart`
combined-suite gate whenever a session executes it
Source: Alex-Mobile-Dev (mobile-dev), REQ-016 requirement-level `Mode:
mobile-implementation` run (RunId
`RUN-REQ-016_solo_stage1_relationship_assistant-NONE-mobile-dev-fm1wiring`),
reported as `BLOCKER: PREEXISTING_TEST_FAILURE`
Created: 2026-09-27
Linked Requirement: REQ-016_solo_stage1_relationship_assistant
Linked Story: surfaced by the F-M1 requirement-level tab-wiring run (`Story:
NONE`); root cause is `mobile/lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart`,
last touched by STORY-011 P2 (commit `27700367`) — not this run's write scope

## Report

Observed behavior:
`flutter test test/features/context_notebook/context_content_gate_test.dart --no-pub --reporter compact`
fails its BR-16 case at line 159: `Expected: empty; Actual:
['lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart contains
"Ca phe sang"']`. The gate scans shipped source for banned literal pack
phrases; a doc comment in `zodiac_shell_resolver.dart` (line 157 at the
surfacing BaseHead) contains one.

Expected behavior:
The gate should pass, or the doc comment should not contain a banned pack
phrase literal (fix is either a wording change in the STORY-011-owned file,
or a gate-scope adjustment to exclude doc comments — bug-fixer to decide
after diagnosis).

Reproduction steps or command:
```
cd mobile && flutter test test/features/context_notebook/context_content_gate_test.dart --no-pub --reporter compact
```

Proof this is pre-existing, not introduced by the surfacing run:
- Reporting run's worktree HEAD == its own declared BaseHead
  (`9aadd52f536c96d2d5258f841873f3a7469ff72e`, the REQ-016 integration branch
  after the Tech Lead's F-M1 architecture-decision commit).
- `git diff --quiet 9aadd52f -- mobile/lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart`
  and the same for `context_content_gate_test.dart` both exit 0 — both files
  are byte-identical to BaseHead; the reporting run's own diff touched only
  `home_screen.dart` and `activity_card_hub_view_test.dart`.
- The banned phrase is present at `zodiac_shell_resolver.dart:157` already at
  BaseHead, in a doc comment. `git log` attributes the file's last change to
  commit `27700367` (STORY-011 P2), well before this BaseHead.

Why not fixed inline by the reporting agent:
`zodiac_shell_resolver.dart` and `context_content_gate_test.dart` are outside
the F-M1 wiring run's declared WriteScope
(`mobile/lib/features/home/presentation/home_screen.dart`,
`mobile/test/features/activity_cards/`), and the root cause belongs to
STORY-011, not to this requirement-level fix.

## Artifacts

- [x] Diagnosis (Bug Fixer)
- [x] Fix Evidence (Bug Fixer)
- [x] Review (Reviewer)

## Routing Notes

- Current owner: scrum-master — bug closed; sequencing Deferred Finding D-1
  (propagate the `main` fix commit into the REQ-017/STORY-001 worktree) before
  continuing Alex-Mobile-Dev's P1 re-run
- Next role: none for this bug; downstream is REQ-017/STORY-001 Phase P1
  resume (Alex-Mobile-Dev), not bug-queue work
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md` (complete — root cause confirmed: display-form
  pack literal `"Cà phê sáng"` in a doc comment, BR-16 gate itself is correct
  and unchanged)
- Fix Evidence: `fix-evidence.md` (complete — doc-comment-only patch on
  `main`, all four gates PASS: Pre-Fix Reproduction, Original Failure
  Recheck, Build, Runtime Startup)
- Review Report: `review/review-report.md` (complete — `Outcome:
  DEFERRED_ONLY`, 0 blocking findings, 1 deferred finding D-1: fix must be
  propagated from `main` into the REQ-017/STORY-001 worktree/branch before
  its P1 re-run, since both currently share the pre-fix blob for
  `zodiac_shell_resolver.dart`)
- Checkpoint: tracked in
  `data/requirements/REQ-016_solo_stage1_relationship_assistant/scrum-master-checkpoint.md`
  and `data/bugs/BUG-20260927-001_context_content_gate_zodiac_pack_phrase_leak/scrum-master-checkpoint.md`
- Origin: REQ-016 requirement-level F-M1 tab-wiring run
  (`data/runtime/parallel-runs/RUN-REQ-016_solo_stage1_relationship_assistant-NONE-mobile-dev-fm1wiring.json`)

## Second Occurrence — 2026-09-28, REQ-017_checkin_notebook_capture/STORY-001_checkin_notebook_capture P1

Reported by: Alex-Mobile-Dev (mobile-dev), RunId
`RUN-REQ-017_checkin_notebook_capture-STORY-001_checkin_notebook_capture-mobile-dev`,
`Mode: mobile-implementation`, returned `BLOCKER: MOBILE_TEST_BLOCKED`.

Same failing suite/case (`context_content_gate_test.dart:159`, BR-16), same
file (`mobile/lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart`),
matched phrase reported as `"Cà phê sáng"` (same phrase, this run's own
report did not re-quote the ASCII-normalized form). Confirmed pre-existing at
this run's own BaseHead `0198e32ddd3f8bad6a4d5274fd7b5ebeae9158b1` (`git
diff --quiet` against both `zodiac_shell_resolver.dart` and
`context_content_gate_test.dart` exit 0 — both untouched by P1's diff, which
touched only the P1 `Write Scope` files). Unlike the first occurrence, this
run's own required `## 6. Test Scope` regression coverage (phase file
`coding-plan/phase-P1-notebook-origin-persistence.md`) explicitly includes
the `test/features/context_notebook/` suite, so this bug now BLOCKS this
phase's own completion — it cannot be cited as out-of-scope and deferred the
way the F-M1 run did.

## Resolution

- First occurrence (F-M1, REQ-016): still not required to unblock REQ-016
  delivery or its `DONE` gate (already merged/DONE); that citation stands.
- Second occurrence (P1, REQ-017/STORY-001): `bug-fixer` dispatch is now
  REQUIRED — this is the blocking path for
  `REQ-017_checkin_notebook_capture/STORY-001_checkin_notebook_capture` Phase
  P1 to reach `MOBILE_COMPLETE: YES`. Queue immediately via `fix bugs`.
- Root-cause file (`zodiac_shell_resolver.dart`) belongs to REQ-016/STORY-011,
  not REQ-017; the fix branch/worktree should be a bug-fixer-owned worktree
  targeting `main` (or the currently active integration line for that file),
  not the REQ-017 story worktree/branch, since the P1 story `WriteScope` does
  not include this file.
- Bugfix review (`Iris-QC`, 2026-09-28): `Outcome: DEFERRED_ONLY`, 0 blocking
  findings, 1 deferred finding (D-1). Bug status set to `DONE` per the
  review's State Recommendation. D-1 is Scrum-Master-owned sequencing, not
  bug-fixer rework: the fix committed on `main` must be propagated into the
  REQ-017/STORY-001 worktree/branch
  (`codex/REQ-017_checkin_notebook_capture-STORY-001_checkin_notebook_capture`)
  before Alex-Mobile-Dev's P1 re-run, since both currently hold the identical
  pre-fix blob for `zodiac_shell_resolver.dart`.

## Blockers

- N/A (resolved; D-1 propagation tracked at
  `data/requirements/REQ-017_checkin_notebook_capture/STORY-001_checkin_notebook_capture/scrum-master-checkpoint.md`)
