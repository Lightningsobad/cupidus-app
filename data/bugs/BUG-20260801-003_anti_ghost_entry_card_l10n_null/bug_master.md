# Bug Master: BUG-20260801-003_anti_ghost_entry_card_l10n_null

Status: IN_PROGRESS — assigned to Justin-BugFixer-2
Linked Requirement: REQ-001_cupid_flutter_mobile_app (blocks its Integration
Build & Runtime evidence gate, but does NOT block the readiness gate test
itself — `widget_test.dart` is blocked by `BUG-20260801-002` instead).
Discovered by: Justin-BugFixer, as a masked/out-of-scope finding while
fixing `BUG-20260801-001_app_shell_chat_gate_l10n_null` (item 3 in that
bug's diagnosis.md; this record is the authoritative scope for the fix, do
not re-read that diagnosis.md).

## Scope

- Branch: `codex/REQ-001_cupid_flutter_mobile_app-integration`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-001_cupid_flutter_mobile_app`
- Worktree HEAD at discovery: `3c3e9f0` (after BUG-20260801-001's fix)
- Same branch-topology caveat: `main` does not carry this code. Fix must
  land on the integration branch/worktree above, not `main`.

## Reproduction

```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-001_cupid_flutter_mobile_app/mobile
$HOME/flutter/bin/flutter test
```

## Failure anchor

The identical defect PATTERN as `BUG-20260801-001` (an `AppL10n.of(context)`
null-check crash) but at multiple different production crash sites. Original
finding plus 2 additional crash sites surfaced by Justin-BugFixer-2 while
fixing `BUG-20260801-002` (do not re-read that bug's diagnosis.md; this
record is now the authoritative combined scope):
- `_AntiGhostEntryCardChrome` (`mobile/lib/features/anti_ghosting/.../anti_ghost_entry_card.dart:125`
  — confirm exact relative path when reproducing). Affects
  `mobile/test/features/vibes/vibe_screen_test.dart`.
- `app_shell.dart:203`'s FAB tooltip. Affects
  `mobile/test/features/gallery/gallery_cubit_test.dart`.
- `DreamJarEntryCard`. Affects
  `mobile/test/features/pet/presentation/pet_entry_point_test.dart`.

Note: `gallery_cubit_test.dart` and `pet_entry_point_test.dart` also hit a
GetIt registration gap, already fixed by `BUG-20260801-002` (commit
`d667861`) — that fix is already merged, so these two files should now fail
ONLY with the `AppL10n.of` signature above when this bug is picked up, not
also with a GetIt error. If a GetIt error still reproduces, stop and report
it as a regression rather than folding it into this bug.

`BUG-20260801-001`'s fix pattern (add
`AppL10n.localizationsDelegates`/`AppL10n.supportedLocales` to the affected
test harness's `MaterialApp`/pump helper, matching `mobile/lib/app/cupid_app.dart`'s
real boot composition) likely applies here too, but bug-fixer must verify
via its own query-first reading for each of the three crash sites — do not
assume without confirming the harness in these specific test files lacks
the delegates the same way.

## Constraints for the fix

- Fix must land on `codex/REQ-001_cupid_flutter_mobile_app-integration` in
  the worktree above, not `main`.
- Do not touch `app_shell.dart`/`chat_entry_gate.dart` (already fixed under
  `BUG-20260801-001`) or the GetIt registration items
  (`BUG-20260801-002`, separate bug).
- Do not "fix" the pre-existing, already-triaged, out-of-scope items:
  `pair_gate_cubit_test.dart` constructor mismatch,
  `reminder_copy_guard_test.dart`, ~76 `prefer_initializing_formals` lints.

## Fix Evidence

(bug-fixer fills in `fix-evidence.md`)

## Review

(Reviewer fills in `review/review-report.md`)

BUG_FIX_COMPLETE: NO
