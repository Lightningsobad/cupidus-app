# Review Slice P4: Entry Point Wiring — STORY-011 Vỏ hoàng đạo / trắc nghiệm

Outcome: PARTIAL_SLICE_ONLY

Review type: `scoped-slice` · Slice 4 of 4 · Blocking: 0 · Deferred: 3

This is a slice verdict over phase P4 only. It is not a story verdict and cannot
green the DONE gate. Story closure belongs to the later fresh final-synthesis
pass, which consumes `review/slice-P1.md` through `review/slice-P4.md`.

## 1. Scope

- Phase: `coding-plan/phase-P4-entry-point-wiring.md` (entry-point wiring)
- Diff baseline: `git diff d748df37 5c757d68` — 15 files, 1037 insertions,
  90 deletions
- Worktree HEAD at review time is `59aa7f4e` (the P3 review commit, review-only
  and outside the diff range).
- Source/test files in scope:
  - `mobile/lib/features/zodiac_shell/zodiac_shell_entry_point.dart` (new)
  - `mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart`
  - `mobile/test/features/zodiac_shell/zodiac_shell_entry_point_test.dart` (new)
  - `mobile/test/features/activity_cards/quick_entry_strip_test.dart` (new)
  - `mobile/test/features/gift_ideas/gift_ideas_screen_test.dart` (retirements)
  - `mobile/test/features/conversation_starters/conversation_starters_screen_test.dart`
    (retirement)
- Carried from earlier slices, not re-judged here: D-P1-1, D-P1-2, D-P1-3,
  D-P2-1, D-P2-2, D-P3-1, D-P3-2.

## 2. Acceptance Criteria (phase §4)

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | Tapping the third cell from the hub navigates to the story screen, no snackbar | PASS | `_openQuickEntryCell` `activity_card_hub_view.dart:306-324` calls `openZodiacShellScreen(context)`; `zodiac_shell_entry_point_test.dart:276` and `:306` assert `ZodiacShellScreen` on screen and `observer.pushed.last isA<MaterialPageRoute<void>>()` from both hub states |
| 2 | Key `activity_quick_entry_coming_soon` no longer appears for `QuickEntryCell.zodiacShell` | PASS | The snackbar branch is deleted outright, not conditionalised — read at `activity_card_hub_view.dart:306-324`; pinned by a source scan `zodiac_shell_entry_point_test.dart:471` and by `findsNothing` in the entry-point, strip, gift-ideas and conversation-starters suites |
| 3 | The cell shows label "Vỏ hoàng đạo" + filled `auto_awesome` in every account state, no locked variant | PASS | `quick_entry_strip_test.dart:105-131` (no `Icons.lock`, no `Sắp có`, tap yields `[QuickEntryCell.zodiacShell]`); eyeballed in both implemented PNGs — see §5 |
| 4 | The hub does not import `ZodiacShellScreen` or `ZodiacShellCubit` directly | PASS | Only zodiac import in the hub is `import '../../../zodiac_shell/zodiac_shell_entry_point.dart';` (`activity_card_hub_view.dart:16`), matching the sibling pattern at lines 14-15; pinned by `zodiac_shell_entry_point_test.dart:457` with a word-bounded `RegExp(r'\bZodiacShellScreen\b')`, which is the right matcher because a plain `contains` would be satisfied by `openZodiacShellScreen` |

Note on AC 2: its parenthetical allows the placeholder to survive for another
unfinished cell. The implementation goes further and removes the branch for
every cell, which is correct today because all three cells now route. The
consequence for the record is that the strip has no neutral placeholder
affordance left; `kQuickEntryCellCount` is 3 and the `QuickEntryCell` switch is
exhaustive, so adding a fourth cell is a design change that would have to
reintroduce one.

## 3. The six independent verification items

| # | Item | Verdict | How it was checked |
|---|------|---------|--------------------|
| 1 | The entry point exposes exactly one symbol, no leaked internal types | PASS | Read the whole 32-line file: one top-level `Future<void> openZodiacShellScreen(BuildContext context)`, a `library;` directive, one import (the screen), no `export`, no `class`. The test at `:442` regex-extracts top-level declarations and asserts `declared == <String>['openZodiacShellScreen']` — anchored at `^`, so the indented `MaterialPageRoute<void>(` inside the body cannot satisfy it |
| 2 | Hub slot-2 navigation has zero gating conditionals | PASS | Read `_openQuickEntryCell` directly: a bare exhaustive three-arm switch, then `if (cubit.isClosed) return;` and `await cubit.load();` — the only conditional is a disposal guard after the await, not a gate. The scan at `:399` strips `//` lines (load-bearing: the file's own doc comment names R-13/R-14/onboarding) then requires 14 gate tokens absent **and** `code.contains('if (')` false. `quick_entry_strip_test.dart:161` runs the same class of scan over the strip |
| 3 | Navigation proven hub-originated, both hub states | PASS | `_RecordingObserver extends NavigatorObserver` records `didPush`. Populated hub at `:276`; Minute-1 empty store at `:306`, which first asserts `find.byType(MinuteOneEmptyState) findsOneWidget` so the state is proven before the tap; back-to-hub at `:332`. The slot index is read as `QuickEntryCell.values.indexOf(QuickEntryCell.zodiacShell)` rather than hardcoded, so the test follows a reorder instead of silently testing the wrong cell |
| 4 | Legitimacy of the three stale-test retirements | PASS | See §4 — the cited precedent exists and is honoured in code, not only in a comment |
| 5 | P4's half of the shared visual-fidelity report | PASS, with two deferred items | See §5 — gate re-run with a negative control, both P4 PNGs and all three design references opened |
| 6 | `flutter analyze lib test` delta 0 against a non-zero baseline | PASS | See §6 — verified by a targeted re-run, not by accepting the count |

## 4. The three stale-test retirements

The phase removed three pre-existing cases that pinned the `activity_quick_entry_coming_soon`
placeholder the phase is contracted to delete. The claim under review is that
the codebase already carried the precedent at `gift_ideas_screen_test.dart:1163`.

- **The precedent exists.** The pre-change text at that location, visible in the
  diff, reads `Slot 1 ("mồi chuyện") left this list when STORY-005 shipped
  screen (6); its own navigation regression lives in
  test/features/conversation_starters/conversation_starters_screen_test.dart`.
  P4 extended that same comment in place rather than inventing a new practice.
- **The precedent is honoured in code, not only in prose.** I read the file it
  points at: `conversation_starters_screen_test.dart:947-998` holds slot 1's
  navigation regression for both the populated hub and the Minute-1 hub. So the
  STORY-005 pattern — retire the placeholder assertion, move the regression into
  the owning feature's suite — was actually carried out, which is what makes it
  a precedent rather than a convenient reading.
- **Coverage is migrated one-for-one, not dropped.** The two retired gift-ideas
  cases were a populated-hub case and a Minute-1 case; both map onto
  `zodiac_shell_entry_point_test.dart:276` and `:306`, and the Minute-1 one keeps
  its `MinuteOneEmptyState` assertion. The retired conversation-starters case
  maps onto the same pair.
- **Nothing else in the two files was disturbed.** Both suites keep their own
  slot-0 / slot-1 navigation cases, including their Minute-1 variants
  (`gift_ideas_screen_test.dart:1112` and `:1139`,
  `conversation_starters_screen_test.dart:956` and `:984`), and all four still
  assert `activity_quick_entry_coming_soon` findsNothing. The invariant is now
  pinned from four suites instead of being asserted in reverse from two.

Verdict: the retirements are legitimate. They delete assertions that were true
only while STORY-011 was unshipped, and they leave the behaviour better covered
than before.

## 5. Visual fidelity — verified, not accepted

The `VISUAL_FIDELITY: PASS` token is shared with P3 (carried finding D-P3-2), so
one PASS cannot be read as proof that either surface was audited alone. I judged
only the P4 rows and screens.

- **Gate re-run independently.** `python3 .claude/hooks/lib/visual_fidelity.py
  --dir <story dir> --stage review --stack mobile` → exit 0.
- **Negative control.** The same invocation against an empty
  `/tmp/iris-p4-vf-control/EMPTY-STORY` → exit 1 with `visual-fidelity/visual-fidelity-report.md
  does not record 'VISUAL_FIDELITY: PASS'`. The exit 0 above is therefore a real
  evaluation, not a no-op.
- **A pixel probe was attempted and refused.** A read-only PIL scanline probe of
  the two PNGs was blocked: `QUERY-FIRST BASH READ GUARD BLOCKED [GENERIC]:
  query-first agent attempted to read or patch source/test/config/workflow
  artifact files through an inline shell script`. The §5 observations below are
  therefore eyeball evidence, which is what the gate asks for, and are recorded
  as such rather than as measurements.
- **Both implemented PNGs opened and read.** In
  `implemented-man-goc-muon-lam-md-quick-entry.png` and
  `implemented-phut-1-kho-trong-md-quick-entry.png` the three cells appear in the
  fixed order with "Gợi ý quà" / "Mồi chuyện" / "Vỏ hoàng đạo", the `redeem`,
  `mood` and filled `auto_awesome` glyphs all draw as glyphs rather than notdef
  boxes, every diacritic renders (including "Vỏ hoàng đạo", "Bắt đầu từ một điều
  nhỏ nhé.", "Đi ăn quán Huế mới mở"), and the third cell carries no lock, no
  "Sắp có" badge and no dimming — it has the same fill, size and text weight as
  the other two. AC 3 is satisfied on the image, not only in the widget tree.
- **All three design references opened.** See D-P4-1: two of them do not draw
  this surface at all.

## 6. Analyzer delta

The phase records `flutter analyze lib test` → 271 issues, 0 errors, "delta 0",
where delta 0 is defined file-scoped ("no issue line names a file this phase
created or edited") rather than as a count difference. The handoff asked me to
check this against a 222-warning/0-error baseline rather than accept a clean run.

- A whole-tree `flutter analyze lib test` in the story worktree reproduced a
  large issue list, but the transport truncated the middle of the output, so a
  count read off that run would not be evidence. I did not filter it — filtering
  build/test output is refused by the query-first guard, and correctly so.
- Instead I ran the falsifiable form directly: `flutter analyze` over the seven
  files P4 created, edited or scans (including `quick_entry_strip.dart`) →
  **`No issues found!`**. The file-scoped delta-0 claim is verified at source.
- `flutter analyze test` alone → **21 issues, 0 errors**, and not one of the 21
  names a file this phase touched. They are pre-existing `unused_import` /
  `unnecessary_import` / `prefer_initializing_formals` lines in unrelated
  suites.
- `flutter analyze lib/features/zodiac_shell` → **`No issues found!`** for the
  story's entire lib footprint, so none of the whole-tree count is attributable
  to STORY-011 at all.
- The count arithmetic does not reconcile with 222: 271 − 21 leaves ~250 for
  `lib`, so 222 is not a `lib`-only figure for this branch head. The most
  plausible reading is that 222 is an older snapshot of a tree that has since
  grown; I could not confirm it, because doing so would require analyzing a
  checkout at the baseline commit and a reviewer may not move Git state. This
  does not weaken the verdict — the three targeted runs above establish that P4
  contributes zero analyzer issues, which is the claim the gate exists to check
  — but it does mean the number "222" in the handoff should not be reused as a
  live baseline. Recorded as D-P4-3.

## 7. Risk surfaces

| Surface | Verdict | Note |
|---------|---------|------|
| Navigation / entry point reachability | PASS | Proven from both hub states through the production widget tree with a real observer, not by pushing the route directly |
| Module boundary (AC-20: no headless "cung của bạn hôm nay" helper) | PASS | The entry point carries no `export`, unlike its `gift_ideas` / `conversation_starters` siblings, so the cubit, resolver, rotation store and packs stay unreachable from outside the module |
| Gating rules R-13 (location) / R-14 (paid tier) / onboarding | PASS | Absent by source scan over both the entry point and the strip, and absent by behaviour: the from-hub navigation tests would fail if any gate intervened |
| Shared strip contract owned by STORY-001 | PASS | Cell order, `kQuickEntryCellCount`, and the `activity_quick_entry_slot_*` / `activity_quick_entry_strip` keys are unchanged, and `quick_entry_strip_test.dart` now pins that shape independently of the hub |
| Build gate | PASS (recorded) | `flutter build apk --debug` succeeded and was run bare, with no pipe or redirect, so its full output is on the record. Not re-run here: re-running a build is not what a reviewer adds, and the phase's unfiltered run is the stronger evidence |
| Runtime startup smoke | OUT OF SLICE | Story-level; belongs to the final synthesis |

One note on the strip source scan at `quick_entry_strip_test.dart:161`: unlike
the entry-point scan it does not strip comment lines, so a future doc comment in
`quick_entry_strip.dart` mentioning e.g. "premium" would fail it. That is
stricter than intended rather than a coverage hole, so it is a note and not a
finding.

## 8. Findings

### D-P4-1 — Two of P4's three design anchors do not draw this surface (deferred)

The report adds three `Design-Screen:` lines for P4. I opened all three.
`design-reference-man-goc-muon-lam-ios.png` and
`design-reference-phut-1-kho-trong-ios.png` contain **no quick-entry strip at
all** — the first is the Muốn làm hub with its filter chips, "HÔM NAY" hero card
and card list; the second is the Minute-1 screen with two large cards and its
footer copy. They are evidence of *which hub states the cell must work from*,
which is a real and useful thing to have captured, but they cannot anchor a
fidelity comparison for a surface they do not contain.

The only canvas frame that draws the three entry points is
`tab-y-tuong-hub-cua-vao`, and against it the shipped surface differs by
decision in three ways, two of which the report already discloses:

- shape: a vertical list of full-width rows inside the Ý tưởng tab, versus a
  horizontal three-cell strip on the Muốn làm hub (disclosed; STORY-001 owns the
  strip and P4 may not change it);
- label: "Cung & trắc nghiệm" versus the shipped "Vỏ hoàng đạo" (disclosed; the
  label is AC-28-governed, and the canvas string is the *screen* title, which
  screen (7) already renders — consistent with the standing decision that the
  canvas outranks `uiux-spec.md` only where no AC governs the item);
- **not disclosed:** each canvas row also carries a subtitle — for this row,
  "Vui thôi — nhưng cuối cùng vẫn ra 3 điều làm thật" — and a trailing chevron.
  The shipped cell is label plus glyph only. The report's shape note mentions
  chevrons in passing but never names the lost subtitle, which is the row's only
  piece of copy expressing the "vui thôi nhưng ra 3 điều làm thật" promise.

Deferred, not blocking: every individual deviation is either owned by another
story or justified by an AC. What needs correcting is what the report lets a
later audit conclude — "three design screens, PASS" reads as three clean
comparisons, when it is one anchor that the surface is knowingly deviant against
plus two screenshots of surrounding context. Same class as D-P3-1.

### D-P4-2 — Third cell is flush to the frame edge in the populated-hub capture (deferred)

In `implemented-man-goc-muon-lam-md-quick-entry.png` the "Vỏ hoàng đạo" cell
runs into the right edge of the 415-wide frame with no inset and no visible
rounded right corner, while the card list below it keeps a normal right margin.
In `implemented-phut-1-kho-trong-md-quick-entry.png`, at the same width, the
same cell is inset like the other two and its rounded corner is visible. So the
two captures of the same strip disagree, and the one that clips is the one that
clips the cell P4 has just filled.

This is eyeball evidence only (the pixel probe was refused, §5). The strip's
layout belongs to STORY-001 and P4 is forbidden from changing it, so this is not
a P4 defect; the clip most likely comes from the populated hub's header region
giving the strip a different available width than the Minute-1 surface does.
It is recorded because the report's eyeball notes assert what is *absent* from
slot 2 ("No lock, no 'Sắp có' badge, no dimming ... in either image") without
noting what is cut, and because a strip of exactly three fixed cells that clips
the last one signals "scroll for more" where there is no more. For the synthesis
or for the STORY-001 owner, not for P4.

### D-P4-3 — Two write-scope/baseline claims are unverifiable from the record (deferred)

Both are disclosure problems, not misconduct; the phase raised both itself.

- The phase justifies editing `gift_ideas_screen_test.dart` and
  `conversation_starters_screen_test.dart` — two files the handoff's eight-path
  prose list does not name — by citing entries 5 and 6 of a ten-entry
  `write_scope` in
  `data/runtime/parallel-runs/RUN-...-STORY-011_zodiac_quiz_shell-mobile-dev.json`.
  That file is not present in `data/runtime/parallel-runs/` now (only the
  reviewer p2/p3/p4 slice runs are), and `data/runtime/` is gitignored
  (`.gitignore:12`), so it has no history and its prior contents cannot be
  reconstructed. The p1 reviewer slice run is likewise gone, which suggests
  completed run files are cleaned up, so absence now is weak evidence about
  what the grant said then. I therefore cannot confirm or refute the citation.
  On the merits the two edits are defensible independently of the grant — they
  are the three retirements judged legitimate in §4, and Scrum Master was told
  before the edit — so this is deferred for the record rather than raised as a
  scope breach.
- The "222 warnings / 0 errors" baseline could not be reproduced (§6). It should
  not be carried forward as a live number without being re-measured.

## 9. Traceability

- Phase file: `coding-plan/phase-P4-entry-point-wiring.md` §1B, §3, §4, §6, §7
- Test evidence: `coding-plan/test-results.md` §"Phase P4 — Entry Point Wiring
  (Mobile)" (lines 314-471)
- Visual fidelity: `visual-fidelity/visual-fidelity-report.md` §P4 (shared token,
  D-P3-2)
- `coding-plan/master-plan.md` line 57: P4 status flipped `NOT_STARTED` → `DONE`;
  no other row touched in this commit
- Independent runs performed for this slice: targeted `flutter analyze` over the
  seven P4-adjacent files; `flutter analyze test`; `flutter analyze
  lib/features/zodiac_shell`; `visual_fidelity.py` gate plus negative control

## 10. Recommendation

Phase P4 is sound on the four criteria it owns and on the six items sent for
independent verification. Nothing here blocks the story. The final synthesis
should pick up D-P4-1, D-P4-2 and D-P4-3 alongside the carried items, and should
note that the story-level gates P1 deferred — runtime startup smoke and a
story-level visual verdict — are still open and were not settled by this slice.

REVIEW_SLICE_COMPLETE: YES
