# STORY-015 Reviewer Slice E — P5 Pairing-Required Gate, Entry Point, DI Wiring

Reviewer: Iris-QC (`RUN-REQ-001_cupid_flutter_mobile_app-STORY-015-reviewer-slice-e`)
BaseHead: `0a467d03babf1ed4102c3fab09c61b2dec941a0b`
Note: persisted by Helen-SC on Iris-QC's behalf — Iris-QC's own write of this
file (and its RunState update) was blocked by `guard-parallel-worktree-scope.sh
[OUT_OF_SCOPE]` / an isolation-worktree mismatch (shared worktree concurrent-
sibling-write false positive, same pattern as Slices C and D). Content below is
verbatim from Iris-QC's completed review analysis, transcribed unedited.

Scope: diffed against BaseHead `0a467d03babf1ed4102c3fab09c61b2dec941a0b` with an
explicit pathspec (this story branch was not resynced with the current
integration tip; an unscoped diff was intentionally avoided per handoff
guardrail).

## Files reviewed

- `mobile/lib/features/expenses/data/pairing_state_reader.dart` (new, 21 lines)
- `mobile/lib/features/expenses/presentation/widgets/pairing_required_gate.dart` (new, 62 lines)
- `mobile/lib/features/expenses/expenses_route.dart` (new, 139 lines)
- `mobile/lib/features/home/presentation/home_screen.dart` (additive edit, +308/-5)
- `mobile/lib/core/di/service_locator.dart` (additive edit, +244/-0)
- `mobile/test/features/expenses/expenses_entry_point_test.dart` (new, 193 lines)
- `mobile/test/features/expenses/pairing_gate_test.dart` (new, 193 lines)
- `mobile/test/features/home/home_screen_test.dart` (new, 66 lines)
- `mobile/test/features/home/presentation/timeline_entry_point_test.dart` (154 lines, diff-only-additive vs. this stale BaseHead)

Also read: `story_master.md` (AC4: "Unpaired users cannot access this
feature") and `coding-plan/test-results.md` (`home_screen_ready_signal`
section, confirming the key is present and intact after this story's edit).

## AC4 coverage assessment — PASS

The gate is genuinely wired end-to-end, not dead code:

- `PairingStateReader.isPaired()` (`pairing_state_reader.dart`) resolves
  through the existing `CouplePairingStore` (STORY-012), returning `false` for
  both `unpaired` and `unknown` — it never optimistically grants access when
  the pairing state can't be confirmed.
- `ExpensesEntryPoint` (`expenses_route.dart`) resolves `isPaired()` once per
  mount via `FutureBuilder<bool>`. While loading it shows a spinner; once
  resolved, it renders `PairingRequiredGate` when `!snapshot.data!` and only
  renders `ExpenseHistoryScreen` when paired. It also wraps the repository
  (`_NotPairedWatchingRepository`) so a mid-session `ExpensesNotPairedFailure`
  (e.g. stale cached "paired" state, 404 from backend) flips an already-open
  screen back to the gate — a secondary corroborating signal, not just an
  initial check.
- `home_screen.dart`'s new `_ExpensesEntryCard` (keyed
  `home_expenses_entry_card`) navigates unconditionally to
  `ExpensesEntryPoint` (`MaterialPageRoute<void>(builder: (_) =>
  const ExpensesEntryPoint())`) — it does not duplicate or bypass the gate;
  the gate is resolved by the destination screen itself, which is the correct
  place for it (matches the precedent already set by
  `_TimelineEntryPointGate` for STORY-012).
- `PairingRequiredGate` itself is a dedicated screen (not a generic
  error/empty state) with a primary action into `InviteScreen` — satisfies
  the UX spec's requirement for a distinct pairing-required affordance.

Traced route: `HomeScreen._ExpensesEntryCard.onTap` → `Navigator.push` →
`ExpensesEntryPoint` → `PairingStateReader.isPaired()` → `PairingRequiredGate`
(unpaired) or `ExpenseHistoryScreen` (paired). No bypass path found.

## `home_screen.dart` additive-edit check — PASS

Read the full current file. All pre-existing entry points remain present and
functioning, in original order, with their original keys/behavior:
`home_screen_ready_signal` (unchanged text/key), `AntiGhostEntryCard`,
`VibeEntryCard`, `_ReminderEntryCard` (`home_reminder_entry_card`),
`DreamJarEntryCard` (`home_dream_jar_entry_card`), `PetPreviewCard`,
`LoveContractEntryTile`, `_TimelineEntryPointGate`. The new
`_ExpensesEntryCard` (`home_expenses_entry_card`) is appended last, after the
Timeline gate, exactly as its doc comment states.

The 5 deleted lines in the diff are not a feature removal: they are the
original `body: const Center(child: Text(..., key: Key('home_screen_ready_signal')))`
being re-nested inside a new `SafeArea > Padding > SingleChildScrollView >
Column` wrapper (necessary now that multiple entry cards must fit without
overflow) — the same `Center`/`Text`/key trio is preserved verbatim inside the
new wrapper. This matches `test-results.md`'s own confirmation that the key is
"present and intact ... Unaffected by STORY-015," and is corroborated by
three independent tests (`home_screen_test.dart`, `expenses_entry_point_test.dart`,
`timeline_entry_point_test.dart`) all still finding `home_screen_ready_signal`
after the edit.

No other feature's entry point was removed, reordered relative to its
neighbors, or broken.

## `service_locator.dart` additive-edit check — PASS

Full file read. Diff is +244/-0 (zero deletions). The STORY-015 block only
adds new registrations: `ExpenseDao`, `ExpensesRepository`,
`PairingStateReader` (wired to the existing `CouplePairingStore`),
`ExpenseHistoryCubit`, `AddExpenseCubit`. All pre-existing registrations
(pairing, account, gallery, timeline, couple-pairing, dream jar, realtime,
vibes, reminders, anti-ghosting, chat, pet, love-contracts) remain intact and
in their original relative order/content. No removal or reordering found.

## Test coverage assessment

- `pairing_gate_test.dart`: asserts real behavior, not just render smoke —
  `PairingStateReader.isPaired()` true/false/never-optimistic-on-error cases
  against a real `CouplePairingStore` with a faked HTTP transport, plus
  `PairingRequiredGate` widget tests asserting the message/action text and
  that tapping the action actually navigates into `InviteScreen`. PASS.
- `expenses_entry_point_test.dart`: asserts unpaired → `PairingRequiredGate`
  shown / `ExpenseHistoryScreen` absent; paired → the reverse; a mid-session
  `ExpensesNotPairedFailure` flips an already-open screen to the gate; and a
  `HomeScreen` integration test that taps the `home_expenses_entry_card` and
  confirms navigation lands on `ExpensesEntryPoint` (which itself then shows
  the gate under the test's unpaired setup). This exercises the full
  home-screen-to-gate path, not just a unit in isolation. PASS.

Both go beyond widget-render smoke tests and directly assert the
unpaired-blocked / paired-allowed behavior required by AC4.

## `timeline_entry_point_test.dart` — out of scope, noted per handoff instruction

This file's content is entirely about STORY-012's Timeline feature entry
point on `HomeScreen` (`TimelineEntryPointCard`, `_TimelineEntryPointGate`,
`resolvePairingStatus`/`createTimelineCubit` constructor overrides) — nothing
in it references the expenses feature. It appears in the scoped diff only
because this story branch's `BaseHead` predates STORY-012's merge onto the
integration branch (consistent with the handoff's note that the branch was
never resynced and shows unrelated already-merged-story diffs). Not reviewed
as STORY-015 feature logic; no findings raised against it in this slice.

## Findings

None (BLOCKING or NOTE) identified within Slice E's file scope.

Slice-Verdict: CLEAN
