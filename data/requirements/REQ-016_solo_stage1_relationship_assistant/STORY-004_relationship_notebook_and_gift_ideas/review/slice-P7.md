# Scoped Slice Review — Slice P7 (gift screen, quick-entry, push-to-hub)

Outcome: PARTIAL_SLICE_ONLY

- Story: `REQ-016_solo_stage1_relationship_assistant/STORY-004_relationship_notebook_and_gift_ideas`
- Mode: scoped-slice (Tier-3 Scoped Slice + Fresh Final Synthesis)
- Slice: P7 — the LAST implementation slice; a fresh reviewer performs final
  synthesis over slice-P1 … slice-P5-P6 plus this report.
- Reviewed at: worktree HEAD on branch
  `codex/REQ-016_solo_stage1_relationship_assistant-STORY-004_relationship_notebook_and_gift_ideas`
- Diff baseline used: `e5b3741743744241cd8cfb60543cf6d37f0ec946` (DiffBase from
  the handoff, not `BaseHead`)
- REVIEW_SLICE_COMPLETE: YES

This verdict is scoped to this slice only. It is not a story-level gate and
must not be read as one.

## 1. Declared slice scope

Eight files, all present in the diff:

| # | File | Diff |
|---|------|------|
| 1 | `mobile/lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart` | new, 288 lines |
| 2 | `mobile/lib/features/gift_ideas/presentation/cubit/gift_ideas_cubit.dart` | new, 152 lines |
| 3 | `mobile/lib/features/gift_ideas/presentation/widgets/gift_idea_card.dart` | new, 146 lines |
| 4 | `mobile/lib/features/gift_ideas/gift_ideas_entry_point.dart` | new, 29 lines |
| 5 | `mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart` | +42 / -3 |
| 6 | `mobile/lib/l10n/arb/app_vi.arb` | +93 |
| 7 | `mobile/lib/l10n/arb/app_en.arb` | +23 |
| 8 | `mobile/test/features/gift_ideas/gift_ideas_screen_test.dart` | new, 860 lines, 28 cases |

## 2. AC verdict table

AC text is quoted from `../requirements/requirements.md`, which is the
controlling text. Where the handoff's cited AC id and the actual AC text
disagree, the row is filed under the id whose *text* governs the behaviour, and
the drift is recorded in §6.

| AC | Subject (from requirements.md) | Verdict | Evidence |
|----|-------------------------------|---------|----------|
| AC-13 | Ô "Gợi ý quà" trên hub mở màn (5); hai ô còn lại giữ hành vi cũ | PASS | `activity_card_hub_view.dart:_openQuickEntryCell` routes `QuickEntryCell.giftIdeas` → `openGiftIdeasScreen(context)`, all other cells → `Key('activity_quick_entry_coming_soon')` snackbar. Wired into BOTH hub states (`QuickEntryStrip.onCellSelected` and `MinuteOneEmptyState.onQuickEntryCellSelected`). Asserted in both states, `gift_ideas_screen_test.dart:725-831`. `quick_entry_strip.dart` is unchanged by this story — strip shape/labels untouched, as the phase file requires. |
| AC-14 (clause 1) | Bộ gợi ý lọc theo dịp × giai đoạn × nội dung sổ tay | PASS | `gift_ideas_cubit.dart` re-runs the P6 selector on every filter/context change; ranking itself was verified in slice P5-P6 and is not re-litigated here. |
| AC-14 (clause 2) | "mỗi gợi ý riêng-hoá **nêu rõ nó dựa trên điều người dùng đã tự nhập**" | **FAIL** | `gift_idea_card.dart:72` gates the provenance line on `idea.isHandmade && skillLabel != null`; `_skillLabel()` (`gift_idea_card.dart:101-108`) only inspects `GiftContextKind.skill`. A suggestion personalised by a notebook interest or event renders no statement of its basis. See finding F1. |
| AC-16 / AC-19 | Không ký hiệu tiền tệ, khoảng giá, nhãn rẻ/đắt, liên kết mua (the real no-price/no-commerce ACs; the phase file cites these as "AC-14/AC-15/AC-26") | PASS | `gift_idea_card.dart` renders title, description, branch label, effort label, one `CupidPrimaryButton` — no price/shop/buy affordance. Rendered-tree scan over `_renderedText(tester)` for `₫ / vnđ / vnd / đồng / $ / giá / rẻ / đắt / khuyến mãi / giảm giá / mã giảm / cửa hàng / shop / mua  / http` at `gift_ideas_screen_test.dart:635-663`. ARB files carry no currency token. |
| AC-20 | Dòng khoá vị trí là liên kết văn bản nhỏ ở cuối màn, không phải banner | PASS | `gift_ideas_screen.dart:259-288` `_LocationLockLine` — two `Text` captions in `type.caption`/`colorTextMuted`, last child of the `ListView` (`gift_ideas_screen.dart:158`), no `GestureDetector`, no `DecoratedBox`, nothing tappable. |
| AC-21 | Đẩy về hub qua `createCard`, ở lại màn sau khi đẩy | PASS | `gift_ideas_cubit.dart:addToHub` is the single write; emits `state.withAdded(...)` and performs no navigation. Test asserts the created card and that the route is still screen (5), `gift_ideas_screen_test.dart:590-602`. |
| AC-22 | Không kho thứ hai / không danh sách đã lưu riêng | PASS | Second-action absence scan + icon absence + exactly one `ElevatedButton` per card, `gift_ideas_screen_test.dart:665-714`. `gift_ideas_entry_point.dart:15-16` exports only `GiftIdeasScreen, giftIdeasEntryPointId` — no headless "top gift" helper that could seed a second surface. |
| AC-23 | Thẻ tạo ra có trường giá rỗng | PASS | `gift_ideas_cubit.dart:addToHub` constructs `NewActivityCard(title:, origin:, durationMinutes:)` and deliberately omits `priceVnd`; asserted `priceVnd, isNull` at `gift_ideas_screen_test.dart:590-602`. `activity_card.dart:240-276` confirms `priceVnd` stays an optional field this flow never sets. |
| AC-24 | Không ngõ cụt — mọi thẻ có đường ra | PASS | Every `GiftIdeaCard` receives a non-null `onAddToHub` (`gift_ideas_screen.dart:152-156`); the empty state renders `Key('gift-ideas-no-match')` plus the still-present filters, so the screen is never a terminal blank. |
| AC-30 | `origin = gift_suggestion` trên thẻ tạo ra | PASS | `activity_card.dart` adds `giftSuggestion('gift_suggestion')` to `ActivityCardOrigin`; asserted `origin.wireValue == 'gift_suggestion'` at `gift_ideas_screen_test.dart:590-602`. |
| AC-31 | Đúng một thẻ hỏi tại chỗ, và nó có thể vắng mặt hoàn toàn | PASS | Exactly one ask slot in the layout, `gift_ideas_screen.dart:136-140`, between the two chip rows and the list. Identity (`entryPointId: 'gift_ideas'`, needed field ids, `onContextChanged`) asserted at `gift_ideas_screen_test.dart:532-539`. The slot returning nothing is a normal state, documented `gift_ideas_screen.dart:132-135`. |
| AC-32 / AC-34 | Số chip = số mục trong `gift_taxonomy`; đổi gói đổi số chip không sửa Dart | PASS | `_FilterChipRow` (`gift_ideas_screen.dart:172-202`) emits one chip per `GiftTaxonomyItem`, no leading "tất cả" cell, no integer literal. R-15b honoured — the UI layer assumes no pack size. |
| AC-17 | Bộ lọc mức công sức, incl. "2 tiếng tối nay" quick chip per `ux/uiux-spec.md` Phần D item 1 | PASS (with reservation) | Ceiling-filter behaviour tested at `gift_ideas_screen_test.dart:343`. No chip is literally labelled "làm được trong 2 tiếng tối nay"; the pack ships "Trong 30 phút / Một tới hai giờ / Trọn một buổi". Under SKILL rule 14 the governing AC text is AC-32/AC-34, which make tier labels and counts a property of the data pack, not of Dart — so a label deviation is a pack-content question, not a code defect. Flagged for the synthesis reviewer as a spec-vs-pack reservation, not a slice failure. |
| R-15b (OQ) | Không giả định kích cỡ gói ở tầng UI | PASS | No integer literal and no currency token under `lib/features/gift_ideas/`; enforced by the P5 gate tests, re-confirmed by reading all four new source files in this slice. |

## 3. Independent verification performed

Not a re-read of the implementer's evidence — these were run/opened by the
reviewer at current HEAD:

- `flutter test test/features/gift_ideas/gift_ideas_screen_test.dart`
  → `00:01 +21 ~1: All tests passed!`
  (the `~1` is the `skip: !kCaptureVisuals` capture case, `gift_ideas_screen_test.dart:859`)
- `flutter test test/features/context_notebook/ask_on_the_spot_slot_test.dart`
  → `00:05 +12: All tests passed!`, including
  `+11: biên giới import của feature no file outside features/context_notebook imports an internal`
- Three PNGs opened and eyeballed at 415x900 (see §5).
- All four new `lib/` files and `activity_card_hub_view.dart` read in full;
  `quick_entry_strip.dart` read in full to confirm it is untouched.
- `gift_ideas_screen_test.dart` read in four ranges (90-259, 461-560, 560-720,
  715-860) — a full read is blocked by the heavy-read guard at 31059 bytes.

### Entry point reachability (SKILL 12e1) — verified in code by the reviewer

Screen (5) is reachable in the running app from both hub states through exactly
one router, `_openQuickEntryCell` in `activity_card_hub_view.dart`:

- populated hub → `QuickEntryStrip(onCellSelected: ...)`
- Minute-1 empty hub → `MinuteOneEmptyState(onQuickEntryCellSelected: ...)`

`openGiftIdeasScreen` (`gift_ideas_entry_point.dart:23-29`) pushes a full-screen
`MaterialPageRoute`, so the hub gains no sixth pane (AC-22). On return the
router awaits and calls `cubit.load()`, so a pushed card is visible immediately.
Four widget tests cover the routing in both states. The section heading itself
is missing from the phase evidence file — see finding F4; the *substance* is
verified here and is not in doubt.

## 4. Out-of-declared-scope files in the diff — adjudication

All four are adjudicated NECESSARY and CONSISTENT. None is scope creep.

| File | Diff | Adjudication |
|------|------|--------------|
| `mobile/lib/features/activity_cards/domain/activity_card.dart` | +10 / -1 | Adds `giftSuggestion('gift_suggestion')` to `ActivityCardOrigin` and `final int? durationMinutes;` to `NewActivityCard`. AC-30 cannot be satisfied without the enum value, and the P7 phase file names the STORY-001 `createCard` contract as its Source Of Truth. `priceVnd` untouched. ACCEPT. |
| `mobile/lib/features/activity_cards/data/activity_card_repository_impl.dart` | +1 | `durationMinutes: Value(draft.durationMinutes),` at line 49 — threads the field the enum change added. `priceVnd: Value(draft.priceVnd)` at line 43 still passes null. Minimal. ACCEPT. |
| `mobile/lib/features/activity_cards/presentation/widgets/minute_one_empty_state.dart` | +9 / -1 | Adds the `onQuickEntryCellSelected` callback so the Minute-1 state routes like the populated state. This is the already-re-verified Gap-1 fix; per the handoff it is not re-opened here. Confirmed only that it is coherent with `_openQuickEntryCell`. ACCEPT. |
| `mobile/test/features/activity_cards/activity_type_test.dart` | +9 / -4 | Test-only update following the Drift `schemaVersion` bump introduced by the context-notebook tables in an earlier slice. No product change. ACCEPT. |

## 5. Visual fidelity — reviewer opened and compared the images

Three PNGs at 415x900, opened and eyeballed against `../ux/uiux-spec.md` Phần D:

- `visual-fidelity/design-reference-5-goi-y-qua-thang-cong-suc-ios.png`
- `visual-fidelity/implemented-5-goi-y-qua-thang-cong-suc-ios.png`
- `visual-fidelity/implemented-5-goi-y-qua-thang-cong-suc-md.png`

Confirmed by eye, not by trusting the report:

- Vietnamese diacritics render correctly; no tofu glyphs.
- `+` and timer glyphs render (MaterialIcons loaded).
- No currency symbol, no `×` dismiss control, no second action anywhere.
- The iOS capture's title band is blank — the documented `BackdropFilter`
  artifact of the capture harness, not a product defect; the `-md` capture shows
  "Gợi ý quà" in the same position. Accepted as a harness limitation.
- Implemented shows **3 branch chips + 3 effort chips in two rows**; the design
  reference shows a single row. Data-driven per AC-34, so the count is a pack
  property — but the two-row shape is a real visual delta.
- The ask card at 6 stacked full-width options pushes the first gift card below
  the fold (carried Gap 3, see §6).

`visual-fidelity/visual-fidelity-report.md` records `VISUAL_FIDELITY: PASS`
(lines 1 and 150) **while listing 7 P7 `DESIGN_SPEC_CONFLICT` items** (lines
189-232): primary-action label, per-card dismiss `×`, compact second card
variant, 2-vs-3 branch chips, effort chip labels, provenance explainer band,
bottom row content. Item 6 self-admits its own AC-25 citation "does not hold".
The report resolves all seven itself under an "Authority note" (lines 59-64)
declaring `ux/uiux-spec.md` the winner over the design canvas. That
self-adjudication is the substance of finding F2.

## 6. Carried items from earlier slices — status

| Item | Status |
|------|--------|
| Gap 2 = slice-P3 F1 import-boundary regression | **RESOLVED, confirmed green at HEAD.** Fixed at commit `5e984bc`, sealed at `cc6ef4e`. The boundary case passes (`+11` of the 12-case run above). The gate is non-vacuous — slice P3 caught a real violation with it. Not re-raised. |
| Gap 3 = `AskOnTheSpotSlot` full-width stacked options push content below the fold at 6 options | **Still accurately documented**, VF report §P7 "Delta that is neither a match nor a conflict". My own read of the implemented capture confirms it and shows it is NOT materially worse at P7. No new action. |
| AC-id citation drift (8 self-corrections already logged) | **One NEW instance, in the handoff itself.** The P7 phase file's `Primary Inputs Summary` (`coding-plan/phase-P7-*.md:50-51`) and the dispatch cite `AC-6 (SC-2), AC-13, AC-14, AC-15, AC-20, AC-22, AC-23, AC-24, AC-26, AC-30, AC-31`. Against `requirements.md`: AC-6 is the notebook-fields AC (push-to-hub is AC-21); AC-14/AC-15 are selector-level, not the no-price ACs (those are AC-16/AC-19); AC-26 likewise. The **implementation and tests use the corrected ids throughout** — the drift is in the planning artifact only. Logged, not blocking; the synthesis reviewer should decide whether the phase file gets patched. |

## 7. Findings

### F1 — MAJOR (NEW): AC-14 second clause unmet at the P7 display layer

`gift_idea_card.dart:72`

```dart
if (idea.isHandmade && skillLabel != null) ...<Widget>[
  const SizedBox(height: CupidSpacing.xs),
  Text(
    l10n.gift_ideas_from_skill(skillLabel),
    key: Key('gift_idea_from_skill_${idea.id}'),
```

and `gift_idea_card.dart:101-108`

```dart
String? _skillLabel() {
  for (final GiftContextMatch match in suggestion.matches) {
    if (match.context.kind == GiftContextKind.skill) return match.context.label;
  }
  return null;
}
```

AC-14 (`requirements.md:144-146`) requires that **mỗi** personalised suggestion
state the user-entered basis it rests on. As implemented, only the handmade
branch with a matching skill context does. A suggestion ranked up by a notebook
interest or a notebook event — both first-class ask targets, declared at
`gift_ideas_screen.dart:21-27` — renders no provenance at all.

Compounding: VF report `DESIGN_SPEC_CONFLICT` item 6 deliberately dropped the
design's provenance explainer band, which is the one surface that would have
covered the general case.

Spec tension worth naming for the synthesis reviewer: `ux/uiux-spec.md` Phần D
item 3 restricts the line to handmade ("chỉ ở nhánh handmade"), while Phần E
presupposes a general one ("dòng riêng-hoá 'vì [Tên] thích...' trong thẻ gợi
ý"). The UX spec contradicts itself; AC-14 does not.

Not impossible to fix: `suggestion.matches` is already on the card, so this is
an incomplete render, not missing data.

### F2 — BLOCKING at story level (procedural): `VISUAL_FIDELITY: PASS` recorded over 7 open `DESIGN_SPEC_CONFLICT` items

`visual-fidelity/visual-fidelity-report.md:1`, `:59-64`, `:150`, `:189-232`.

Reviewer SKILL 12e2/12e3 require that a design-vs-implementation conflict be
raised as `BLOCKED: DESIGN_SPEC_CONFLICT` so Scrum Master can ask the user which
side anchors. The implementer instead typed all seven conflicts and then
resolved them itself via an "Authority note" asserting `ux/uiux-spec.md` beats
the design canvas.

That precedent runs the other way in this very requirement: commit `b516c48`
— `chore(REQ-016): PO ac-patch STORY-001 AC-10/AC-11/AC-22 + uiux-spec (anchor
on design, D-1/D-2/D-3)` — records the user anchoring on **DESIGN** for
STORY-001. The authority question is therefore live, not settled, and is the
user's to answer.

This is a story-level gate item, raised here because P7 is where the conflicts
live. Under the slice contract it does not by itself set this slice's verdict.

### F3 — MINOR: `story_master.md` `Design-Screen:` omits screen 5

`story_master.md:12-14` lists only `2-so-tay-nguoi-yeu` and
`3-ho-so-ky-nang-phien-ban-toi`. The phase file
(`coding-plan/phase-P7-*.md:172`) and the VF report both record
`Design-Screen: 5-goi-y-qua-thang-cong-suc`. Reviewer may not edit
`story_master.md` (SKILL rule 7) — Scrum Master must patch.

### F4 — MINOR (story-level, documentation only): no `## Entry Point Reachability` heading

SKILL 12e1 makes the section non-waivable. Searched `coding-plan/test-results.md`
across lines 40-465 (the P6 and P7 regions and the material above them); no such
heading exists. The entry point itself is real, discoverable and covered by four
widget tests — verified independently in §3 above. This is a missing heading in
the evidence file, not a missing behaviour.

### F5 — UNVERIFIED (story-level): mobile runtime startup smoke

SKILL 12g makes runtime startup smoke mandatory for a non-trivial mobile-lane
story unless `story_master.md` carries `Runtime-Smoke: WAIVED — <reason>`. The
P7 phase file records `Startup Smoke: NOT_APPLICABLE`
(`coding-plan/phase-P7-*.md:32`), no `## Story Runtime Startup Smoke` section
exists in `coding-plan/test-results.md`, and `story_master.md` carries no
`Runtime-Smoke:` line at all. Either the waiver line is added with a reason, or
the smoke is run. Cannot be closed from within this slice.

## 8. Residual risks

1. **Provenance coverage (F1)** is the one user-visible AC gap this slice found.
   Until it is closed, the "why am I seeing this" promise of AC-14 holds only
   for handmade-plus-skill suggestions.
2. **Design authority for REQ-016 is unresolved (F2).** Seven P7 deltas were
   self-adjudicated one way while a merged STORY-001 commit records the user
   choosing the other way. If the user anchors on design again, several P7
   surfaces change shape (chip rows, card variant, primary-action label,
   provenance band) — which would also close F1 as a side effect.
3. **Effort-tier labels (AC-17 reservation)** live in the pack, so the "2 tiếng
   tối nay" quick chip is a content decision nobody has explicitly taken. Low
   risk, but it will read as a spec miss to whoever compares Phần D to the app.
4. **Capture-harness blind spot on the iOS title band.** The blur artifact means
   the iOS captures can never evidence the header; the `-md` capture is the only
   proof the title renders. Acceptable, but it is a permanent gap in the iOS
   evidence line for this story.
5. **`~1` skipped case.** The visual capture case only runs under
   `--dart-define=CAPTURE_VISUALS=true`, so the ordinary suite result never
   exercises it. Intended, but it means "21 passed" is not "22 verified".

## 9. Slice conclusion

Within the declared 8-file P7 scope, the implementation is coherent, well
tested, faithful to the content-as-data invariants, and free of price/commerce
leakage. Twelve of thirteen AC rows pass. One AC row fails (F1). Two story-level
gate items (F2, F5) and two documentation defects (F3, F4) are handed to the
final-synthesis reviewer, which owns the story verdict.

REVIEW_SLICE_COMPLETE: YES
