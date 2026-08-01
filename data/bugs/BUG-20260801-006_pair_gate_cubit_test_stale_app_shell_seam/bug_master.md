# Bug Master: BUG-20260801-006_pair_gate_cubit_test_stale_app_shell_seam

Status: PENDING
Linked Requirement: REQ-001_cupid_flutter_mobile_app (blocks the
`development-local` deployment readiness gate; `start-dev.sh` hard-gates on
`flutter test` and this test fails to compile)
Discovered by: Frank-Devops-2, during a `development-local` redeploy of
REQ-001 against `main` after the integration branch was merged
(merge commit `239b2116b4d4b793e2a635fb79fa3e579448ad81`). Verified
pre-existing: byte-identical failure on both the (now-torn-down) integration
branch and `main`; already triaged as out-of-scope when REQ-001 was marked
DONE, but it blocks the automated dev-local readiness gate so the user chose
to fix it rather than re-scope the gate.

## Scope

- Branch: `main`
- Worktree: control checkout at
  `/Users/alantravala/workspace/snapsofts/cupid-apps` (no dedicated worktree;
  REQ-001's story/integration worktrees are already torn down and this is a
  standalone bug scope, not story work)
- Worktree HEAD at discovery: `68cc985` (commit that recorded the merge into
  main); current HEAD `71698a0`

## Reproduction

```
cd /Users/alantravala/workspace/snapsofts/cupid-apps/mobile
$HOME/flutter/bin/flutter test test/features/pairing/presentation/pair_gate_cubit_test.dart
```

## Failure anchor

Per Frank-Devops-2's report: the test constructs
`AppShell(createPairGateCubit: ..., createInviteCubit: ...,
createJoincodeCubit: ...)`, but `mobile/lib/core/navigation/app_shell.dart:49`
no longer declares those constructor parameters — its current constructor
only accepts `partnerStore`, `chatRepository`, `coordinator`,
`backendUserIdStore`, and `consentStore`. This is a compile failure (stale
test seam), not a runtime assertion failure. STORY-016 (or a related later
story) changed `AppShell`'s constructor shape without updating this test.

## Working hypothesis (NOT a diagnosis — context only)

Two plausible directions, unverified — bug-fixer must confirm via its own
query-first reading before choosing:
1. The test should be rewritten to construct `AppShell` with its current
   constructor shape (`partnerStore`/`chatRepository`/`coordinator`/
   `backendUserIdStore`/`consentStore`) and drive pair-gate/invite/joincode
   behavior however the current `AppShell` composition actually exposes it
   (e.g. via `coordinator` or an injected store), not via removed
   constructor callbacks.
2. If `AppShell` genuinely lost necessary test seams for pair-gate/invite/
   joincode behavior when its constructor was simplified, that may indicate
   a real production testability gap — confirm whether that behavior is
   still exercised anywhere else before concluding the test is simply
   obsolete.
Confirm which by reading the current `app_shell.dart` constructor and
composition root, and how pairing/invite/joincode flows are actually wired
today, before deciding.

## Constraints for the fix

- Fix must land on `main` in the control checkout above.
- Do not touch unrelated `AppShell` production wiring already verified
  correct by the 5 prior REQ-001 bugs (`BUG-20260801-001`..`-005`) unless
  this bug's own investigation finds a genuine, separately confirmed gap.
- Do not "fix" the sibling out-of-scope item in the same discovery:
  `reminder_copy_guard_test.dart` (`BUG-20260801-007`, separate bug).
- This bug blocks the REQ-001 `development-local` readiness gate. Full
  detail on the redeploy that discovered it is in
  `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/deployment-log.md`
  § Latest Attempt (2026-08-01, "DevOps redeploy against merged main").

## Fix Evidence

(bug-fixer fills in `fix-evidence.md`)

## Review

(Reviewer fills in `review/review-report.md`)

BUG_FIX_COMPLETE: NO
