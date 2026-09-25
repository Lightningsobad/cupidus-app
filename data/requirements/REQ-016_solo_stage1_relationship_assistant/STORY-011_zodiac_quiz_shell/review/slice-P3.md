# Slice Review: STORY-011 — P3 Result Surface Screens

Outcome: PARTIAL_SLICE_ONLY

Review type: `scoped-slice` (slice 3 of 4). This verdict scopes ONLY phase P3.
Story closure belongs to the later fresh final-synthesis pass.

- Scope gate: `review/scope-gate.md` (P1 pass; scope fields below extend it for P3)
- Diff baseline for this slice: `git -C <Worktree> diff 27700367 d748df37`
- Blocking findings: 0
- Deferred findings: 2 new, plus an independent verdict on the carried D-P2-2

## Scope of this slice

Source/test files in scope (6): `zodiac_shell/presentation/screens/zodiac_shell_screen.dart`,
`zodiac_shell/presentation/widgets/zodiac_result_surface.dart`,
`l10n/arb/app_vi.arb`, `l10n/arb/app_en.arb`, and the two matching widget test
files under `test/features/zodiac_shell/`.
Evidence in scope: `coding-plan/phase-P3-result-surface-screens.md`,
`coding-plan/test-results.md` §"Phase P3" (lines 199-312),
`coding-plan/master-plan.md` §3A/§5, `visual-fidelity/visual-fidelity-report.md`
§1-§7 and its two implemented PNGs.
Not judged here: P4 entry-point wiring and the §P4 half of the visual-fidelity
report, runtime startup smoke, and every other story-level gate.

## Acceptance Criteria — phase P3 §4

| # | Acceptance criterion | Verdict | Evidence |
|---|----------------------|---------|----------|
| 1 | Every outcome in the seed pack renders exactly 3 cards on one scrollable; no branch renders a result without them | PASS | `ZodiacResultSurface.build` is a single `ListView` whose only card source is `result.suggestions` (`zodiac_result_surface.dart:37-63`) — there is no conditional and no alternate return, so "verdict without cards" is not a branch that exists to be taken. The resolver already fixed the list at three (P2). Tests: `zodiac_result_surface_test.dart:105` loops all 27 shipped outcomes asserting `findsNWidgets(3)`; :125 asserts `find.byType(Scrollable) findsOneWidget` per outcome, which is the assertion that actually forbids a second surface rather than merely not building one; :172 asserts no `ExpansionTile`/`ExpansionPanelList` per outcome. Screen-level: `zodiac_shell_screen_test.dart:341` plays *every* shipped set through to its result and re-asserts the three. |
| 2 | No widget shows `%`, a score, a band, a progress bar, a question count, a streak or a badge | PASS | Nothing in either widget reads a numeric field; `ZodiacShellState` carries none to read (P2). Tests: `zodiac_result_surface_test.dart:185` walks every `Text` of every outcome for `%` and asserts `LinearProgressIndicator`/`CircularProgressIndicator`/`Slider` absent; `zodiac_shell_screen_test.dart:244` scans every picker `Text` for "mở khoá"/"chuỗi" and for the `RegExp(r'\d+\s*/\s*\d+')` shape, and asserts `find.byType(Badge) findsNothing`. The `n/m` regex is the one that would catch a "câu 2/5" readout smuggled in later. |
| 3 | Leaving the result with no card picked: no block, no second ask, no reproachful snackbar | PASS | `_BackToPickerAction` is a plain `backToPicker()` with no interstitial (`zodiac_shell_screen.dart:320-330`). Test `zodiac_shell_screen_test.dart:361` asserts the picker returns, `cards.cards` is empty, and `find.byType(SnackBar) findsNothing` — the last clause is what makes this an AC-10 assertion rather than a navigation assertion. |
| 4 | The "câu để hỏi" block appears if and only if `about_other == true` | PASS | Guarded twice on the same flag plus a null check (`zodiac_result_surface.dart:96, 112`), so an outcome flagged `about_other` with no `ask_line` draws no empty block — and P1's gate makes that combination unshippable anyway. Tests assert *both* halves over the real pack: :214 (all 3 `about_other` outcomes carry the block, the exact `askLine` text and the guess-provenance eyebrow) and :242 (all 24 others carry neither). The negative half is the one that would fail an unconditional block. |
| 5 | `flutter gen-l10n` runs after the `.arb` edits | PASS | `test-results.md:204` records it was run first. Independently corroborated rather than taken on trust: both test files resolve `AppL10n` getters by name (`l10n.zodiac_shell_add_to_my_store_action` at `zodiac_result_surface_test.dart:296`), so the suites could not have compiled had generation not produced them. |

## Contract invariants this slice owns (§3A risk surfaces)

| Risk surface | Verdict | Evidence |
|--------------|---------|----------|
| Bề mặt kết quả một-lượt-cuộn (P3) | PASS | AC 1 above. The strongest evidence is structural rather than test-shaped: the blocks are siblings in one `ListView` with nothing collapsible or tappable between them, so there is no code path that could hide a card behind a second interaction. The `_BackToPickerAction` sits outside the scrollable as a fixed footer (`zodiac_shell_screen.dart:286-301`), which does not split the verdict from its cards — the AC-5/BR-2 unit is the surface itself and it stays whole. |
| Giọng R-1e/R-1g ở đầu ra (P1, P3) | PASS | R-1e: no ranking or score surface exists to render, and AC 2's scans prove none was drawn. R-1g: the ask block is the closing block of any paragraph about the other person (`zodiac_result_surface.dart:112-115`), and the block-order test proves it by geometry (`insight.dy < ask.dy < subheading.dy < firstCard.dy`, `zodiac_result_surface_test.dart:152`) rather than by mere presence. The sentence content itself is pack data already gated at P1 — P3 adds no sentence about the other person of its own. |

## Test evidence (test-results.md §P3, lines 199-312)

| Gate | Verdict | Note |
|------|---------|------|
| Targeted widget: result surface | PASS | `zodiac_result_surface_test.dart` 10/10. Reads the shipped `zodiac_outcomes.v1.json` off disk through `ContentPackageLoader`, so the assertions are about the pack an author shipped, not fixture copy. The 4000px-tall viewport is deliberate and correct: in a phone-height frame a `ListView` absence assertion can pass by never having built the widget it looks for. |
| Targeted widget: screen (three stages) | PASS | `zodiac_shell_screen_test.dart` 12/12, +2 capture tests skipped without the flag. The guess-label test (:275) asserts the label against the *subject of the question actually on screen* while walking the round, rather than assuming the rotation's order — the only shape of that assertion that stays true as the cursor advances. |
| Targeted suite `test/features/zodiac_shell/` | PASS | `+134 ~2`, 0 failures, `--concurrency=1`. Consistent with my own P2-slice rerun of `+142 ~4` at the later story HEAD: P4 added tests after this commit. |
| Regression `test/features/activity_cards/` | PASS | `+345 ~5`, 0 failures, 5 pre-existing skips. Required by §6 because this phase creates cards through the shared repository. |
| Scoped `flutter analyze` over the write scope | PASS | `No issues found!` (3 items). Scoping explained and legitimate: the repo baseline is 222 warnings / 0 errors, so a whole-tree run carries no pass/fail signal. Delta 0. One `unnecessary_import` was raised and fixed before the recorded result. |
| Capture run | PASS | `--dart-define=CAPTURE_VISUALS=true` → 14/14, 2 PNGs written. Both PNGs exist on disk at the sizes claimed. |
| Per-story visual fidelity | PASS | Section below. Gate re-run independently. |
| Runtime startup smoke | NOT_APPLICABLE (this slice) | Phase §1B/§6 record `Startup Smoke: NOT_APPLICABLE` / `Runtime startup smoke: NO`. The story-level mobile smoke gate remains open and is the synthesis pass's to enforce. |
| Entry point reachability | NOT_APPLICABLE (this slice) | Owned by P4. |

### Visual fidelity — verified, not accepted

I re-ran the gate myself rather than reading the recorded verdict:

- `python3 .claude/hooks/lib/visual_fidelity.py --dir <story dir> --stage review --stack mobile` → silent, exit 0.
- Negative control on an empty story directory → exit 1 with the "does not
  record `VISUAL_FIDELITY: PASS`" message. So the pass above is a real
  evaluation and not a gate that returns 0 on everything.

I opened both implemented PNGs and compared the result frame against
`design-reference-7-vo-hoang-dao-3-viec-ios.png` block by block, at the same
415x900 frame.

- Vietnamese diacritics land everywhere in both images, with no tofu box:
  "Cung & trắc nghiệm", "DỰA TRÊN PHỎNG ĐOÁN CỦA BẠN", "CÂU ĐỂ HỎI",
  "3 ĐIỀU LÀM ĐƯỢC TỪ ĐÂY", "Tối rảnh gần nhất, bạn ấy muốn ở yên hay ra
  ngoài?", "Chọn lát khác", and on the picker "Lát khoảng lặng", "Cách bạn thả
  lỏng", "Bạn đoán, rồi đi hỏi". The hooks, grave, tilde and dot-below marks are
  all rendered rather than dropped.
- Icons draw glyphs, not notdef boxes: `auto_awesome` and `chevron_right` on
  every picker card, `help` in the ask block, `local_activity` on each
  suggestion card, `add` inside each round outline.
- The result frame shows what the ACs demand: exactly three suggestion cards,
  the ask block between the insight and the subheading, the positioning note,
  and no percentage, band, progress bar or counter anywhere in the frame.
- The seven documented deviations in the report all match what I see, including
  the two most load-bearing ones: the canvas's zodiac-pair chip
  ("Sư Tử × Cự Giải") is genuinely unfillable from a quiz-answer outcome, and
  the per-card icons are genuinely uniform because `ZodiacSuggestion` has no
  icon field to vary. Both are content-model consequences, not canvas neglect.
- The `-md` suffix and the Material capture platform are correctly justified:
  `CupidHeader`'s iOS band is a `BackdropFilter`, which has nothing to sample in
  an offscreen `RepaintBoundary.toImage()`, so an iOS capture would wash the
  title out and prove less, not more.

## Independent verdict on D-P2-2 (carried from the P2 slice)

**CONFIRMED, with two refinements — and it moves owner.** The P2 slice asked
what `ZodiacShellStage.loading` renders when it never resolves. The answer is
`zodiac_shell_screen.dart:59-60`:

```dart
case ZodiacShellStage.loading:
  return const SizedBox.shrink();
```

An empty body under the header. There is no timeout, no retry affordance and no
error copy, so on a load failure the reader sees a blank screen indefinitely.
That much confirms the finding. Two things refine it:

1. **It is not P3's to fix, and P3 could not have fixed it.**
   `ZodiacShellStage` has four members — loading, picker, asking, result — and
   no error member. There is no state the screen could have matched on to draw a
   retry, so the gap is in P2's state machine, not in this phase's rendering of
   it. Reassigning the owner from "Mobile Developer, if P3 review finds no
   timeout" to the cubit itself is the actionable part of this verdict.
   Separately, `SizedBox.shrink()` is the *right* widget for the success path
   and is not itself the defect: the wait is a synchronous-feeling asset read,
   and staging it as a spinner is exactly the "đang tính" theatre R-7 forbids.
2. **"No way out" is refuted; "no explanation" stands.** The header renders a
   back control whenever `Navigator.of(context).canPop()` is true
   (`zodiac_shell_screen.dart:46-50`). On the real flow the screen is pushed, so
   the reader can leave a blank screen — they are not trapped in the app. It is
   absent only in the capture, where the screen is the harness `home`.

I also closed the one production trigger the disk-reading tests do **not**
cover, because it would have changed this from deferred to blocking:
`mobile/pubspec.yaml:101-102` declares `assets/data/req016/` as a directory
asset, and both `zodiac_quiz.v1.json` and `zodiac_outcomes.v1.json` sit directly
in it — so "the pack parses off disk in a test but is missing from the built
bundle" cannot happen. With that path closed and P1's gate making a malformed
shipped pack a build-time impossibility, the finding stays **deferred**: real,
but with no currently reachable trigger.

## Deferred findings

**D-P3-1 — the deviation list in the visual-fidelity report is not complete.**
Comparing the two frames myself surfaced two copy deltas the report's seven
numbered deviations do not mention. The canvas ask-block heading is
"CÂU ĐỂ HỎI CÚN" — personalised with the partner's name — against the shipped
chrome string "CÂU ĐỂ HỎI"; and the canvas positioning note names the partner
("App không kết luận Cún là người thế nào") against the shipped generic line.
Both have the same legitimate cause as documented deviation 1: screen (7) has no
partner-name binding in this story, so there is no value to interpolate. No
correctness consequence and no AC is touched — AC-15 requires a question, not a
named question. Recording it because the deviation list is the artifact a later
requirement-level audit trusts instead of re-opening the PNGs, and a list that
silently omits deltas is the shape that lets a real regression pass as
"already documented". Owner: Mobile Developer — add the two rows.

**D-P3-2 — one visual-fidelity report and one verdict token span both P3 and
P4.** `visual-fidelity/visual-fidelity-report.md` carries four `Design-Screen:`
lines and a `§P4` section under a single `VISUAL_FIDELITY: PASS` header, so the
P3 surface (screen 7) and the P4 surface (the hub quick-entry strip) cannot be
judged, or failed, independently. That is a structural consequence of one story
owning two audited surfaces, not a defect in either phase's work, and the file
is explicit about which section owns which surface. Flagging it for the final
synthesis so it does not conclude that a single `PASS` token was an audit of
only one screen. No owner action required at slice level.

## Traceability

- Requirements: AC-2/AC-3/AC-4/AC-5/AC-6/AC-7/AC-10/AC-12/AC-13/AC-14/AC-15/
  AC-17/AC-18/AC-19/AC-20, BR-2/BR-12, SC-2, R-1e/R-1g/R-7, cited at the
  assertion sites above.
- OQ discipline: no unresolved OQ touches this slice. R-15b holds at the
  presentation layer structurally — the "3" in "3 điều làm được từ đây" is BR-2's
  fixed layout contract, not the content package's N, and the `.arb` entry says
  so in its own description rather than leaving a future editor to guess.
- BR-12 (content is data, not code): the 11 new `.arb` keys are chrome only —
  screen title, guess label, provenance eyebrow, ask-block heading, subheading,
  the add action, snackbar plus undo, two neutral exits, and the positioning
  note. No prompt, option label, insight, ask line, suggestion title or note was
  copied out of the P1 packs, and P1's own source-scan gate runs green against
  both new source files, so this is enforced rather than asserted.
- Architecture: `solution.md` §3 UI Delivery Anchor honoured — three stages of
  one route rather than three routes, which is what makes AC-3's clean abandon a
  single state reset and makes AC-5's "result never arrives without its cards"
  structurally true instead of a rule a second route would have to remember.
- UX: `uiux-spec.md` §5's "reuse STORY-004/005's suggestion-card treatment,
  define no third card variant" is honoured — the `(+)` is the STORY-010
  treatment with a 44x44 hit area and a `Semantics` label, verified counted once
  per card at `zodiac_result_surface_test.dart:288`.
- Configuration guide: phase §1B records `Update Required: NO`; this slice adds
  no env var, credential, service, or manual setup step. Confirmed.
- A P1 gate false positive is recorded honestly at `test-results.md:273-282`: an
  `AC-10`/`R-10` citation in a doc comment matched the R-15b item-count scan
  because a hyphen is not `\w`. The phase reworded its comments instead of
  loosening the P1 rule that sits outside its write scope. That is the correct
  call and worth noting as a precedent, not a finding.

## Recommendation

No P3 finding blocks the story. Carry D-P3-1 and D-P3-2 into the final
synthesis, and carry D-P2-2 forward in its refined form — the fix, if the team
ever wants one, belongs to `ZodiacShellCubit`'s stage enum, not to these
screens. The story's outcome still depends on slice P4 and on the story-level
mobile gates (runtime startup smoke, entry point reachability), which this slice
does not judge.
