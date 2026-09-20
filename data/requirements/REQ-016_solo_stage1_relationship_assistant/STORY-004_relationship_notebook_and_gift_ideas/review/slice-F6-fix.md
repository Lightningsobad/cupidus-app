# Slice F6-fix — re-review of the AC-33 dismiss/cycling fix

Reviewer: Iris-QC (scoped-slice)
Story: REQ-016 / STORY-004
Commit under review: `b1feb3d` (worktree HEAD) — the fix, reviewed as a whole,
not as a diff against an earlier commit.
Prior context (not re-litigated): `slice-P7.md`, `slice-P7-patch.md`,
`review-report.md` (Iris-QC-4, `PATCH_REQUIRED` on F6).

## Slice scope

Exactly the question the handoff asks: does `b1feb3d` close F6 (AC-33), and
does it regress AC-18? F1/F2/F3/F4/F5, `_FilterChipRow`, branch chip counts and
effort chip labels are out of scope and were not opened.

Files inspected:

- `mobile/lib/features/gift_ideas/presentation/cubit/gift_ideas_cubit.dart`
  (`GiftIdeasState.withDismissed`, `visibleSuggestions`, `_startingAtRound`,
  `_copyWith`, `GiftIdeasCubit._rank`)
- `mobile/lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart`
  L128-177 (empty-state condition, card list, dismiss-on-lead wiring)
- `mobile/lib/features/gift_ideas/domain/gift_selector.dart` L182-213
  (`nextBatch`, accepted as an already-tested primitive)
- `mobile/test/features/gift_ideas/gift_ideas_screen_test.dart` (the two new
  tests)
- Story AC text: `requirements/requirements.md` L160-162 (AC-18), L236-249
  (AC-33, AC-34)

## Verdicts

| Item | Verdict | Evidence |
| --- | --- | --- |
| AC-33 — no dead-end / no "đã hết ý tưởng" at any N | PASS | `withDismissed` detects exhaustion and clears the dismissed set instead of returning it; `visibleSuggestions` can no longer be empty while `suggestions` is non-empty |
| AC-33 — N = 1 (single-idea pack) | PASS (untested, see F8) | `afterLead.isEmpty ? round.first` re-seats the one idea and clears the set; the reader sees it again rather than an empty screen |
| AC-33 — N > 1, repeated rounds | PASS | round start advances `null → s[1] → s[2] → …` and wraps modulo the list, so cycling continues indefinitely and deterministically ("quay vòng tất định") |
| AC-33 — no progress / percentage / remaining count | PASS | the fix introduces an id (`roundStartGiftId`), no counter; nothing new is rendered |
| AC-18 — narrower branch with genuine matches still renders them | PASS | `visibleSuggestions` falls back to the full ranked list when `remaining` is empty, and the no-match line is now keyed on `state.suggestions.isEmpty` |
| AC-34 — defined-empty branch still reachable | PASS (no regression) | the no-match line still fires exactly when the ranked list is genuinely empty; the card loop reads `visible`, which is empty in that same case |
| `flutter test test/features/gift_ideas` | PASS | `+102 ~1: All tests passed!` — both new tests present in the run |
| `flutter analyze` (3 touched files) | PASS | 3 `prefer_initializing_formals` **infos** only, at `gift_ideas_cubit.dart:182-184`, inside the untouched `GiftIdeasCubit` constructor — pre-existing, 0 errors, 0 warnings |

## F6 — closed

The dead-end is gone, and it is gone at the state layer rather than papered
over at the screen layer:

- `withDismissed` now asks whether this dismissal would leave the ranked list
  with nothing to show. If so it clears `dismissedGiftIds` and moves
  `roundStartGiftId` on to the idea after the one that led the finished round.
- `visibleSuggestions` rotates to that round start via
  `GiftSelector.nextBatch`, which was already implemented and tested but had no
  caller in `lib/` — the fix wires the existing primitive rather than inventing
  a second cursor.
- The screen's no-match condition moved from `visible.isEmpty` to
  `state.suggestions.isEmpty`, so the AC-34 sentence can no longer be reached
  by dismissals. That is a genuine second line of defence, not a substitute for
  the state fix.

Traced by hand over `[A,B,C]`: leads run A → B → C, the third dismissal wraps,
and the full set returns led by B. That matches the widget test's assertion on
`ranked[1]`, and it matches AC-33's "quay vòng tất định" branch.

## Independent verification output

```
$ flutter test test/features/gift_ideas
00:03 +102 ~1: All tests passed!
```

The `~1` skip is the pre-existing `captures 5-goi-y-qua-thang-cong-suc` visual
capture case, unchanged by this commit. Both new tests appear in the run:
`waving every idea away wraps the round, it does not empty it` and
`dismissals carried into a narrower branch cannot empty it (AC-18)`.

```
$ flutter analyze lib/.../gift_ideas_cubit.dart lib/.../gift_ideas_screen.dart test/.../gift_ideas_screen_test.dart
3 issues found. (ran in 5.6s)
   info • prefer_initializing_formals • gift_ideas_cubit.dart:182:9
   info • prefer_initializing_formals • gift_ideas_cubit.dart:183:9
   info • prefer_initializing_formals • gift_ideas_cubit.dart:184:9
```

All three sit in the constructor at L178-185, which `b1feb3d` does not touch.
Pre-existing and out of scope, as the handoff states.

## New findings

### F7 (MINOR) — the rotation collapses on the first dismissal of every round after the first

`_startingAtRound` resolves `roundStartGiftId` against the list it is handed,
and `visibleSuggestions` hands it `remaining` (ranked minus dismissed). The
round's lead **is** the idea `roundStartGiftId` names, and it is the first thing
the reader dismisses in the new round — so the lookup immediately returns `-1`
and the list falls back to unrotated ranked order.

Worked example, `suggestions = [A,B,C]`, immediately after the first wrap
(`roundStartGiftId = B`):

- visible `[B,C,A]`, lead B — correct
- dismiss B → `remaining = [A,C]`, `indexWhere(id == B)` is `-1` → visible
  `[A,C]`, **lead A**
- expected under the getter's own documented model ("the ranked order rotated
  to `roundStartGiftId`, minus the ideas waved away") → `[C,A]`, lead C

So one tap into round two the reader is handed A, an idea they waved away in
round one, instead of C. The behaviour stays deterministic and never empties,
so AC-33's literal clauses (no exhaustion message, no dead-end screen, no
progress indicator, holds at every N) are all still met — this is a quality
defect inside a satisfied AC, not an AC failure.

Why the tests do not catch it: the widget test runs exactly one round, and
round one starts with `roundStartGiftId == null`, where no rotation is applied
and ranked order is trivially correct. It asserts the post-wrap lead and then
stops, one tap short of the divergence.

Fix direction, if the lane picks it up: rotate `suggestions` first and filter
the dismissed ideas out of the rotated list, rather than rotating the already
filtered `remaining`. `rotate([A,B,C], B) = [B,C,A]`, minus `{B}` → `[C,A]`,
lead C. One reordering of the two operations in `visibleSuggestions`.

### F8 (NIT) — no state-level test for a single-idea pack

AC-33 is explicit that the rule holds for `N ≥ 1`, and `withDismissed`'s
`afterLead.isEmpty ? round.first` branch exists exactly for `N == 1`. Nothing
exercises it: `gift_selector.dart` covers a pack of one at the `nextBatch`
level, but the wrap-and-clear path in `GiftIdeasState` does not. The branch is
correct by reading; it is simply unguarded against future edits, and would need
a fake single-idea catalogue to cover.

## Not re-opened

F1 (AC-14 provenance), F2 (design authority), F3 (`story_master.md`), F4
(missing heading, deferred), F5 (runtime smoke) — closed or deferred upstream,
outside this slice. Branch chip counts, effort chip labels and `_FilterChipRow`
were not inspected (R-15b protected).

REVIEW_SLICE_COMPLETE: YES
