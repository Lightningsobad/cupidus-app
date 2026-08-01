# Bug Master: BUG-20260801-006_pair_gate_cubit_test_stale_app_shell_seam

Status: DONE — fix by Justin-BugFixer-3, Reviewer Iris-QC `Outcome: CLEAN`
(`review/review-report.md`), independently confirmed by Scrum Master via
direct read: diff scope confirmed test-only (1 file, +68/-5), all 4 gates
(target test 9/9, build, runtime startup, full-suite regression +889/-1)
re-run by Reviewer and matching claimed evidence. Sole remaining suite
failure is the separately queued `BUG-20260801-007`, out of scope here.
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

Recorded in `fix-evidence.md`; root cause in `diagnosis.md`.

Root cause: the pair gate was extracted out of `AppShell` into `PairGateShell`
(`mobile/lib/core/navigation/pair_gate_shell.dart`), which preserves all three
`create*Cubit` seams unchanged. Hypothesis 1 confirmed (test pointed at the
wrong widget); hypothesis 2 ruled out — no production testability gap, and no
production file was modified.

Fix: test-only change to
`mobile/test/features/pairing/presentation/pair_gate_cubit_test.dart` —
`_harness` now builds `PairGateShell`, plus the store/l10n setup the paired
branch's newly-mounted `AppShell` requires. All 9 tests and every original
assertion intact.

Gates: target test PASS (9/9), scoped `flutter analyze` on the changed file
PASS, Build Gate `flutter build apk --debug` PASS (exit 0), Runtime Startup
Gate PASS (registry-defined `home_screen_ready_signal` widget-test readiness,
scoped to `mobile-app`).

Full suite `+889 -1`; the sole remaining failure is the separate queued
`BUG-20260801-007` (`reminder_copy_guard_test.dart`), out of scope here, not a
regression.

Open follow-up for Scrum Master: REQ-001's `development-local` readiness gate
stays red until `BUG-20260801-007` is also fixed, because `start-dev.sh`
hard-gates on the whole `flutter test` run.

## Review

(Reviewer fills in `review/review-report.md`)

BUG_FIX_COMPLETE: YES
