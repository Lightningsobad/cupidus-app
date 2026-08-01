# Bug Master: BUG-20260801-007_reminder_copy_guard_synced_alarm_violation

Status: PENDING
Linked Requirement: REQ-001_cupid_flutter_mobile_app (blocks the
`development-local` deployment readiness gate; `start-dev.sh` hard-gates on
`flutter test` and this test fails its assertion)
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
$HOME/flutter/bin/flutter test test/features/reminders/reminder_copy_guard_test.dart
```

## Failure anchor

Per Frank-Devops-2's report: ADR-002's copy guard test bans the literal
string `"Synced Alarm"` from appearing anywhere under `mobile/lib`.
STORY-016 added ARB key `notifs_row_synced_alarm_title` with English value
`"Synced Alarm"` (`mobile/lib/l10n/app_en.arb:127`) and a Vietnamese
counterpart (`mobile/lib/l10n/app_vi.arb:565`); Flutter's l10n codegen then
reintroduces the literal `"Synced Alarm"` string into the generated
`app_l10n_en.dart` (and the guard scans generated output too), tripping the
ADR-002 ban.

## Working hypothesis (NOT a diagnosis — context only)

Two plausible directions, unverified — bug-fixer must confirm via its own
query-first reading before choosing:
1. Read ADR-002 to understand exactly why `"Synced Alarm"` is banned (likely
   a copy-consistency rule, e.g. the product's approved term is something
   else, such as "Shared Reminder" or "Synced Reminder"). If so, rename the
   ARB key's English/Vietnamese display value to the ADR-002-approved term
   in both `app_en.arb` and `app_vi.arb`, and confirm no other STORY-016
   surface (UI copy, other ARB keys, docs) still references the banned
   phrase.
2. If STORY-016's product/UX intent genuinely requires the literal "Synced
   Alarm" term and ADR-002 is stale/superseded by that decision, that is a
   copy-guard policy question, not a code fix — flag it back rather than
   silently loosening the guard's banned-phrase list.
Confirm which by reading ADR-002's actual rationale/approved terminology and
the guard test's implementation before deciding.

## Constraints for the fix

- Fix must land on `main` in the control checkout above.
- Prefer the smallest fix: correcting the ARB copy to the ADR-002-approved
  term, not loosening or removing the copy-guard test itself, unless
  investigation shows ADR-002 is the thing that needs updating (in which
  case treat that as a blocker back to Scrum Master, not a unilateral guard
  change).
- Do not "fix" the sibling out-of-scope item in the same discovery:
  `pair_gate_cubit_test.dart` (`BUG-20260801-006`, separate bug).
- This bug blocks the REQ-001 `development-local` readiness gate. Full
  detail on the redeploy that discovered it is in
  `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/deployment-log.md`
  § Latest Attempt (2026-08-01, "DevOps redeploy against merged main").

## Fix Evidence

(bug-fixer fills in `fix-evidence.md`)

## Review

(Reviewer fills in `review/review-report.md`)

BUG_FIX_COMPLETE: NO
