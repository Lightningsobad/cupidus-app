# Bugfix Review Report: BUG-20260927-001 BR-16 Zodiac Pack-Phrase Leak

Outcome: DEFERRED_ONLY

Bug: BUG-20260927-001_context_content_gate_zodiac_pack_phrase_leak
Review Type: bugfix-review (minimal depth)
Reviewer: Iris-QC
Date: 2026-09-28
Scope Gate: `data/bugs/BUG-20260927-001_context_content_gate_zodiac_pack_phrase_leak/review/scope-gate.md` (`SCOPE_GATE_COMPLETE: YES`)
Blocking findings: 0
Deferred findings: 1

## Reviewed Inputs

| Input | Access |
| --- | --- |
| `bug_master.md` | full read (126 lines, 6.4 KB) |
| `diagnosis.md` | full read (154 lines, 7.8 KB) |
| `fix-evidence.md` | full read (177 lines, 9.5 KB) |
| `scrum-master-checkpoint.md` | full read (82 lines, 3.9 KB) |
| `mobile/lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart` | ranged read, lines 140-189 only |
| Control-checkout Git state | `git rev-parse`, `git diff`, `git diff --name-only`, `git worktree list` (read-only) |

No implementation file was full-read; the BR-16 gate test was verified by diff
inventory only, never opened. No test, build, or startup command was re-run —
recorded evidence was sufficient (SKILL rule 18).

## Verified Change Scope

Exactly one source file changed, unstaged in the control checkout on `main`
(HEAD `908d22d8`):

- `mobile/lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart`, `+7 -4`,
  entirely inside the `///` block on `zodiacNotebookTagsIn` (lines 155-164).

`git diff --name-only` lists no other source or test path. The signature
`Set<String> zodiacNotebookTagsIn(String text)` and the whole function body
(lines 165-177) are untouched, so shipped Dart behavior is unchanged.

## Reviewer Focus Items (from `fix-evidence.md`)

| # | Item | Verdict | Evidence |
| --- | --- | --- | --- |
| 1 | Doc comment still describes `zodiacNotebookTagsIn` accurately | PASS | Comment states the notebook holds free Vietnamese with diacritics while packs address ASCII slugs, and that the two meet after diacritic folding and emitting contiguous runs of up to `_maxTagWords` words. That matches the body exactly: `_foldedSegmentsIn(text)` then nested spans capped at `_maxTagWords` joined with `_` (lines 167-175). The retained slug example `di_bo` is a real output of that pipeline, and the `[_maxTagWords]` / `[ZodiacShellResolver.resolve]` doc links still resolve. |
| 2 | BR-16 gate not weakened; gate test unmodified | PASS | `mobile/test/features/context_notebook/context_content_gate_test.dart` is absent from `git diff --name-only`, and the bug fixer created no commit, so the gate file is byte-identical to `908d22d8`. No allowlist, exclusion, or scan-surface narrowing was added. The fix is on the authored side, which preserves the control REQ-016/STORY-011 owns. |
| 3 | Patch landed on `main`, not a REQ-017 branch | PASS | Control checkout is on `main` at `908d22d8` and holds the only modification. `git worktree list` shows the REQ-017 integration worktree at `908d22d8` and the STORY-001 worktree at `0198e32d`; `git status --porcelain` in the STORY-001 worktree reports no local change to the file. This matches the checkpoint's Fix Branch Guidance. |

## Mandatory Bugfix Gates

| Gate | Required | Result | Source of truth |
| --- | --- | --- | --- |
| Pre-Fix Reproduction Gate | YES | PASS — `Result: REPRODUCED`, same modality, exit 1, `+27 -1`, offender list naming the file | `diagnosis.md` → `## Pre-Fix Reproduction Gate` |
| Original Failure Recheck Gate | YES | PASS — `Same modality as original: YES`; same suite/reporter, `+28: All tests passed!`, exit 0, and the BR-16 case is named in the run output so it executed rather than being skipped | `fix-evidence.md` → `## Original Failure Recheck Gate` |
| Build Gate | YES | PASS — registry `runtimes.mobile-app.buildCommand`, exit 0, three split-ABI debug APKs built. The two added flags narrow/parameterize the registry command; no substitute build system | `fix-evidence.md` → `## Build Gate` |
| Runtime Startup Gate | YES | PASS — registry `runtimes.mobile-app.readiness` satisfied on first poll, resumed activity and live pid confirmed, error logcat empty after a pre-launch clear, clean force-stop shutdown verified | `fix-evidence.md` → `## Runtime Startup Gate` |
| Same-modality recheck for the reported failure | YES | PASS — the report's modality was a `flutter test` suite run, and the recheck is the identical command, so no UI/browser modality gap applies (SKILL rule 16) | as above |

The recheck gate is also the regression test: BR-16 fails pre-fix and passes
post-fix, so no new test was warranted.

## Touched Risk Surfaces

| Surface | Touched | Critical gate | Status |
| --- | --- | --- | --- |
| Typed/generated contract | NO | n/a — signature and body unchanged in the diff | not required |
| Persistence/schema/migration | NO | n/a | not required |
| Runtime/configuration | NO | n/a | not required |
| External integration | NO | n/a | not required |
| Async job/workflow | NO | n/a | not required |
| Mobile interaction / navigation / lifecycle | NO | documentation-only; startup gate passed anyway | not required, passed |
| Security/auth | NO | n/a | not required |
| Data migration/backfill | NO | n/a | not required |
| Operational command | NO | n/a | not required |
| Test-control integrity (BR-16 not weakened) | YES | gate file unmodified | PASS (focus item 2) |

Setup/configuration impact: none, so no `configuration-guide.md` verification was
in scope. Design fidelity and entry-point reachability do not apply — this is a
bugfix on a doc comment with no user-facing surface.

## Cluster Boundary

`diagnosis.md` closes the "shipped pack wording duplicated into `lib/**`" family
with exactly one member at this HEAD, and the passing BR-16 run independently
confirms it: BR-16 scans every `.dart`/`.arb` file under `lib/` against every
shipped prompt, chip, and skill label, so its empty offender list is stronger
proof of a closed cluster than a manual sweep would be. No sibling call site
needed patching because no call site changed.

## Traceability

- Reported observed-vs-expected (`bug_master.md` → Report): BR-16 offender list
  non-empty vs empty. The recheck exercises exactly that assertion at the same
  line and it is now empty.
- Diagnosis root cause (display-form pack literal authored into a doc comment,
  gate itself correct) matches what the diff removes.
- Patch decision (reword the comment, keep the ASCII slug form, name BR-16 at the
  violating site) matches the implemented hunk line for line.
- Blocking path in `bug_master.md` → Second Occurrence / Resolution
  (REQ-017/STORY-001 Phase P1 needs `test/features/context_notebook` +
  `test/features/zodiac_shell` green) is addressed by the adjacent-suite run
  `+240 ~8`, 0 failures — subject to the deferred finding below.
- No unapproved product scope was added: no executable code, no new public API,
  no new dependency, no test relaxation.

## Deferred Findings

### D-1 — The fix is not yet visible to the blocked REQ-017 STORY-001 worktree (owner: scrum-master)

Not a defect in the patch, and not rework for Bug Fixer. Recorded because the
checkpoint's Next Step depends on it.

The fix exists only as an unstaged edit in the control checkout. The file's blob
is identical on both committed heads:

- `908d22d8:mobile/lib/.../zodiac_shell_resolver.dart` → `f15d6ea58d1dd012d2e9b7473c9318720c2634db`
- `0198e32d:mobile/lib/.../zodiac_shell_resolver.dart` → `f15d6ea58d1dd012d2e9b7473c9318720c2634db`

and the STORY-001 worktree has no local modification to it. So the STORY-001
worktree (branch `codex/REQ-017_checkin_notebook_capture-STORY-001_checkin_notebook_capture`,
head `0198e32d`) still carries the pre-fix comment. The checkpoint's Next Step
commits on `main` and then continues Alex-Mobile-Dev to re-run the two suites; if
that re-run happens inside the STORY-001 worktree, BR-16 will still fail there at
the same line until the `main` commit reaches that story branch (or the re-run is
performed where the fix is present). Leaving the patch uncommitted was correct
per repository convention, so this is purely a propagation/routing step for Scrum
Master to sequence before the P1 re-run.

## Residual Risk (no action required for this bug)

BR-16 is recurrence-prone by construction: any future pack chip can retroactively
collide with an existing `lib/**` literal, including one inside a comment. The
added in-file note mitigates this for this file only. Already raised in
`diagnosis.md` → Risk Notes; carried forward here for Scrum Master's judgement,
not as a finding against this patch.

Pre-existing and explicitly out of scope: `mobile/test/design_system/` is red at
this baseline for unrelated reasons and was correctly not run.

## State Recommendation

- Keep `Diagnosis` and `Fix Evidence` checked in `bug_master.md` → Artifacts.
- Check `Review (Reviewer)` in `bug_master.md` → Artifacts.
- Recommended bug status: `DONE`.
- Before the P1 re-run, sequence D-1: commit on `main`, then make the commit
  available to the STORY-001 branch/worktree, then continue Alex-Mobile-Dev.

Scrum Master owns all state updates and the commit; this review made no edit
outside this `review/` directory.
