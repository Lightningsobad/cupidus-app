# Scoped Slice Review — P7 design-anchor patch (`c618914`)

- Story: `REQ-016_solo_stage1_relationship_assistant/STORY-004_relationship_notebook_and_gift_ideas`
- Mode: scoped-slice (fresh, narrow re-review of one already-committed patch)
- Patch reviewed: `c618914` against parent `cc6ef4e` — the exact HEAD that
  `review/slice-P7.md` reviewed
- Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-004_relationship_notebook_and_gift_ideas`
- Governing prior document: `review/slice-P7.md`
  (`PARTIAL_SLICE_ONLY`, F1 MAJOR / F2 procedural blocker / F3 F4 minor / F5 unverified)
- REVIEW_SLICE_COMPLETE: YES

This report is scoped to the patch. It is not a story-level gate and must not be
read as one. AC rows `review/slice-P7.md` already marked PASS are not
re-litigated except where this patch touched their surface.

## 0. AC id note

AC text below is quoted from `../requirements/requirements.md`, which governs.
Several ids in `review/slice-P7.md`'s verdict table do not match that file's
text — its "AC-20" row describes the location-lock line (the real AC-20 is the
handmade skill-provenance rule at `requirements.md:168-170`), its "AC-30" row
describes `origin = gift_suggestion` (the real AC-30 is `requirements.md:217`),
and its "AC-31" row describes the single ask card (the real AC-31 is
`requirements.md:220-226`, the content-moderation ship gate). This is the
9th–11th instance of the AC-id drift that slice already logged in its §6, now
present in the review artifact itself rather than only in the planning files.
Rows below are filed under the id whose **text** governs.

## 1. Patch scope

Code, exactly the seven declared files, no scope creep:

| File | Diff |
|------|------|
| `mobile/lib/features/gift_ideas/presentation/widgets/gift_idea_card.dart` | +335 / -~100 (rewritten into `_FullBody` / `_CompactBody` / `_ProvenanceLine` / `_MetaRow` / `_EffortBadge` / `_CircleAction`) |
| `mobile/lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart` | +168 / -25 |
| `mobile/lib/features/gift_ideas/presentation/cubit/gift_ideas_cubit.dart` | +67 / -2 |
| `mobile/lib/design_system/icons/cupid_icons.dart` | +18 / -0 (three additive `IconData` constants) |
| `mobile/lib/l10n/arb/app_vi.arb` | +71 / -9 |
| `mobile/lib/l10n/arb/app_en.arb` | +12 / -4 |
| `mobile/test/features/gift_ideas/gift_ideas_screen_test.dart` | +271 / -19 |

Non-code also touched: `coding-plan/phase-P7-*.md`, `coding-plan/test-results.md`,
`review/review-report.md`, `review/slice-P4.md`, `review/slice-P5-P6.md`,
`review/slice-P7.md`, `story_master.md`, `ux/uiux-spec.md`, `visual-fidelity/*`.

`cupid_icons.dart` sits outside `features/gift_ideas/` but was named in the
handoff's own file list and is additive only (three new constants, no existing
constant changed), so no other feature's icon rendering can shift. ACCEPT.

## 2. AC verdict table — re-verified and newly touched rows

| AC | Subject (governing text) | Verdict | Evidence |
|----|--------------------------|---------|----------|
| AC-14 clause 2 (`requirements.md:144-146`) | "mỗi gợi ý riêng-hoá nêu rõ nó dựa trên điều **người dùng đã tự nhập**" | **PASS — F1 closed** | `gift_idea_card.dart:199-241` `_ProvenanceLine` switches on `basis.kind` over all three of `GiftContextKind.skill / .interest / .event`; `_basis()` (`:232-240`) falls through to `matches.first` for any non-handmade kind and returns null only when `matches` is empty. Rendered on BOTH shapes — `_FullBody:102` and `_CompactBody:167`. Read in the current widget source, not taken from the phase file. |
| AC-15 (`:148-150`) | Sổ tay trống vẫn cho tập kết quả dùng được | PASS | `_ProvenanceLine` renders `SizedBox.shrink()` on empty matches rather than inventing a basis; `_BasisBand` renders nothing for a reader who wrote nothing (`gift_ideas_screen.dart:295-300`). Test "a reader who has written nothing gets no band at all" also asserts the card list is still populated. |
| AC-20 (`:168-170`) | Gợi ý handmade nêu rõ nó sinh từ **kỹ năng nào**, kèm ước lượng công sức theo giờ | PASS (with a minor reservation) | `_basis()` explicitly prefers a `GiftContextKind.skill` match when `idea.isHandmade`, so the pre-patch handmade wording is preserved verbatim while the general case is added around it. Effort is present on both shapes. Reservation: the compact shape renders effort in **minutes** (`{minutes}'`, e.g. `240'` in the capture) rather than in hours — see Observation O1. |
| AC-16 / AC-19 (`:152-154`, `:164-166`) | Không tiền tệ / khoảng giá / nhãn rẻ-đắt / thương mại | PASS | Absence group re-run green; the P5 content gate over every file under `lib/features/gift_ideas/` re-run green (37 cases). No currency token in either ARB diff. |
| AC-21 / AC-22 / AC-23 (`:174-184`) | Một hành động chính, đúng một kho, trường giá để trống | PASS | The compact shape's `_CircleAction` is a new *add* affordance, not a new *keeping* affordance: test "the compact add control pushes to the hub like the pill" asserts it lands one `ActivityCard` with `origin.giftSuggestion` and `priceVnd == null` through the same `cubit.addToHub`. The absence test was correctly tightened from `findsNWidgets(cardCount)` to one `gift_idea_add_<id>` key per card plus exactly one `ElevatedButton` screen-wide. The relabel to `Thêm vào Muốn làm` names the *existing* stage-1 hub tab, not a second collection. |
| AC-24 (`:186-188`) | Mọi gợi ý đang xem có ít nhất một đường đi tiếp | PASS | Every rendered card carries a live `gift_idea_add_<id>`; the new `_GuessRow` answers with a snackbar instead of being a tap that does nothing (`gift_ideas_screen.dart:_GuessRow`, test "tapping the guess row answers instead of doing nothing"). Literally satisfied: the criterion is scoped to a suggestion being viewed. The exhaustion case is filed under AC-33 (F6), which is where its text actually lands. |
| AC-25 (`:192-195`) | Không lưu và không hiển thị đại lượng **hành vi của người kia** | PASS | The one new quantity on the screen is `gift_ideas_basis_notebook` = "sổ tay ({rows} dòng)", counting rows **the reader wrote themselves** (`gift_ideas_cubit.dart:210-213` derives it from `snapshot.values`, the user's own notebook entries). It is not a "đã xem", an open time, a frequency or a judgement about the partner. `dismissedGiftIds` is session-only and never persisted (`gift_ideas_cubit.dart:174-182`), so no taste profile is stored either. |
| AC-26 (`:197-200`) | Nội dung nói về người kia kết bằng câu để hỏi người thật, phần đoán ở tầng "user đoán" | PASS (narrow) | New copy `gift_ideas_guess_row` = "Bí quá thì thử đoán xem người ấy thích kiểu quà nào" states no conclusion about the partner and sits squarely in the criterion's own "tầng user đoán" allowance. It is an invitation, not a claim. Worth the synthesis reviewer's eye only because it is the first line on this screen that mentions the partner at all. |
| AC-32 / AC-34 / R-15b (`:230-234`, `:244-249`) | Số bậc thang công sức và số nhánh là **thuộc tính dữ liệu**; đổi gói không sửa Dart | **PASS — protected items honoured** | `_FilterChipRow` is byte-identical: the patch's last source hunk starts *after* `class _FilterChip`, and the row still emits one chip per `GiftTaxonomyItem` with no integer literal and no "tất cả" cell. Captures show 3 branch chips + 3 effort chips carrying the pack's own labels ("Theo dịp / Không tốn tiền / Tự tay làm", "Trong 30 phút / Một tới hai giờ / Trọn một buổi"), **not** the canvas's 2 chips and not its "Làm được trong 2 tiếng tối nay". `gift_taxonomy.v1.json` untouched by this commit. The new `_EffortBadge` reads `effortTier.maxMinutes` off the pack (test: "a tier maps to the minutes the pack declares, not to a Dart factor"; "a suggestion whose tier the taxonomy does not declare maps to null"). Neither protected item was moved toward a fixed canvas value. |
| AC-33 (`:236-242`) | Hành vi hết-tập là trạng thái êm đã định — suy giảm theo BR-3 hoặc quay vòng tất định; **không** "đã hết ý tưởng", **không** màn ngõ cụt | **FAIL (new)** | The dismiss `×` introduced by this patch *is* a "next suggestion" mechanic, and there is no exhaustion behaviour behind it. See finding F6. |
| AC-28 (`:206-209`) | Cùng đầu vào ⇒ cùng kết quả, tất định | PASS | Dismissals are applied in `GiftIdeasState.visibleSuggestions` (`gift_ideas_cubit.dart:96-103`), i.e. at the view layer, so `_selector.suggest` stays a pure function of catalogue + snapshot + filter. The patch was deliberate about this and the comment says so. |

## 3. Independent verification performed

Run and opened by this reviewer at `c618914`, not read off the phase file:

- `flutter test test/features/gift_ideas/gift_ideas_screen_test.dart`
  → `00:02 +29 ~1: All tests passed!`
  (28 → 29 cases plus the `skip: !kCaptureVisuals` capture case; the seven new
  cases all named in §4 below ran green)
- `flutter test test/features/gift_ideas/gift_content_gate_test.dart`
  → `00:00 +37: All tests passed!` — the AC-33/BR-17 integer scan and the
  currency scan over `lib/features/gift_ideas/` both still hold after the patch
  added `_CircleAction`, `_GlyphDisc` and `_BasisBand`
- `flutter analyze lib/features/gift_ideas lib/design_system/icons/cupid_icons.dart test/features/gift_ideas`
  → `5 issues found.`, all `info • prefer_initializing_formals`, all on
  constructor lines that predate this patch
  (`gift_repository.dart:17-18`, `gift_ideas_cubit.dart:120-122`). No new lint,
  no warning, no error.
- All three P7 PNGs opened and eyeballed against
  `design-reference-5-goi-y-qua-thang-cong-suc-ios.png` and
  `../ux/uiux-spec.md` Phần D — see §5.
- `gift_idea_card.dart` (378 lines) read in full; `gift_ideas_screen.dart`
  read across the changed ranges; `gift_ideas_cubit.dart` read across the
  changed ranges; both ARB diffs read in full; the test diff read in full.
- `requirements.md` read directly at the AC-13…AC-35 range to check every id
  cited above.

Flutter SDK used: `PATH="/Users/alantravala/flutter/bin:$PATH"` (the phase file's
`$HOME/flutter/bin` resolves to the same install).

## 4. New test coverage — assessed, not assumed

Seven new cases, and they are non-vacuous:

- "every personalised suggestion states its basis, not only handmade (AC-14)"
  seeds one notebook row per non-skill index kind, then **asserts a
  non-handmade, non-skill personalised suggestion actually exists** before
  looping the provenance-key assertion. Without that guard the loop could pass
  over an empty set; with it, the test genuinely covers the F1 case.
- "the × sits beside the primary pill, on the lead card only" — asserts the key
  on `ranked.first` and its absence on every later suggestion.
- "tapping it drops the card and promotes the next one" — asserts the promoted
  card's `compact == false`, that it gains the dismiss key, and that
  `cardsByStatus` is still empty (nothing written down).
- "the lead card is full, every following card is compact" — guards on
  `ranked.length > 1` with a reason, then asserts the badge text equals
  `"${second.effortTier!.maxMinutes}'"`, i.e. the pack's own number.
- "the compact add control pushes to the hub like the pill" — full
  origin/price assertion, not just a tap.
- Two `_BasisBand` cases, including the empty-reader case.
- Two `_GuessRow` cases, including a geometric assertion that the row sits below
  the last card.

Gap: **no case dismisses every suggestion.** That is exactly the state F6 is
about, and it is why the patch's own suite is green over a real AC gap.

## 5. Visual fidelity — reviewer opened and compared the images

Opened: `design-reference-5-goi-y-qua-thang-cong-suc-ios.png` (415x900),
`implemented-5-goi-y-qua-thang-cong-suc-ios.png` (415x900),
`implemented-5-goi-y-qua-thang-cong-suc-md-full.png` (415x1600). The `-md`
415x900 capture is the same frame as the iOS one with the opaque Material band.

Confirmed by eye against the canvas:

| Authorized item | Canvas | Implemented | Verdict |
|---|---|---|---|
| 1. Primary-action label | `+ Thêm vào Muốn làm` | `+ Thêm vào Muốn làm` on the lead card's gradient pill | matched |
| 2. Per-card dismiss `×` | circular `×` right of the pill | circular `×` right of the pill, lead card only | matched |
| 3. Compact second-card variant | minutes badge · title · provenance · circular `⊕` | same, and no description and no second gradient pill | matched |
| 6. Provenance explainer band | crossed-tools glyph, "Dựa trên việc bạn làm được (…) × sổ tay về Cún (34 dòng)." | crossed-tools glyph, "Dựa trên việc bạn làm được (Gói quà đẹp) × sổ tay (1 dòng)." | matched (values are the fixture's, not pinned) |
| 7. Bottom row | `?` disc · "Bí quá thì thử đoán xem Cún thích kiểu quà nào" · `›` | `?` disc · "Bí quá thì thử đoán xem người ấy thích kiểu quà nào" · `›` | matched (generic partner reference, correct — no partner name exists in solo stage 1) |

| Protected item | Canvas | Implemented | Verdict |
|---|---|---|---|
| 4. Branch chips | 2 chips, one row | 3 chips from the pack, wrapping | correctly left data-driven |
| 5. Effort chip labels | one chip "Làm được trong 2 tiếng tối nay" | 3 pack labels "Trong 30 phút / Một tới hai giờ / Trọn một buổi" | correctly left data-driven |

Glyphs: `close`, `help` and `handyman` all rasterise as real glyphs, not notdef
boxes, in the captures. Vietnamese diacritics render correctly at every weight,
including in the new strings. No currency symbol anywhere. The iOS title band is
still blank — the documented `BackdropFilter` harness artifact, unchanged.

Two problems with the evidence itself, not with the product: see F7 and F8.

## 6. Findings

### F1 — CLOSED

Resolved as described in the AC-14 row above, and resolved at the right layer:
the general case was added by generalising the render, not by re-ranking, so the
selector is untouched and AC-28 determinism is preserved. `ux/uiux-spec.md`
Phần D item 3 — the clause that restricted the line to handmade and thereby
contradicted Phần E, which slice-P7 §7 named — was amended in the same commit to
match the implemented behaviour. The spec self-contradiction F1 rested on is
gone.

### F2 — CLOSED

`visual-fidelity/visual-fidelity-report.md` §P7 lines 220-231 now state plainly
that the first pass's self-adjudication "was wrong to make here" and that the
decision was taken outside the report, on the STORY-001 precedent (`b516c48`,
D-1/D-2/D-3). It then splits the seven items into two groups on exactly the
right axis: a spec-vs-canvas decision does not license overriding an AC. Items
1, 2, 3, 6, 7 reworked toward the canvas (lines 232-261); items 4 and 5 left
pack-driven with AC-32/AC-34/R-15b cited as the reason (lines 263-282). That is
the Scrum-Master scoping determination applied exactly, and I verified the split
against the shipped code and the captures rather than against the report's own
claim.

The stop-rule check the implementer ran before the relabel (item 1) is sound and
I re-checked its premise: `Muốn làm` is the existing stage-1 hub tab, so the new
label names the store `addToHub` already writes to. No second collection exists.

### F3 — CLOSED

`story_master.md:12-14` now reads
`Design-Screen: 2-so-tay-nguoi-yeu, 3-ho-so-ky-nang-phien-ban-toi, 5-goi-y-qua-thang-cong-suc`.

### F4 — OPEN, documentation only, residual

`coding-plan/test-results.md` gained 99 lines for this round and still has no
`## Entry Point Reachability` heading. The entry point itself remains real,
independently verified in `review/slice-P7.md` §3 and covered by four widget
tests that re-ran green here. Per the handoff this is not treated as blocking
this slice; it is handed to final synthesis as a `DEFERRED_ONLY`-eligible
residual.

### F5 — CLOSED by Scrum Master

Runtime startup smoke was run directly by Scrum Master (debug APK build, install
on `emulator-5554`, `am start -W`, resumed-activity poll, `force-stop` cleanup).
Taken as given per the handoff; not re-run.

### F6 — MAJOR (NEW): AC-33 exhaustion has no defined behaviour behind the new dismiss control

The dismiss `×` is only on the lead card, and dismissing it promotes the next
suggestion into that shape (`gift_ideas_screen.dart:172-175`). That makes it, by
construction, the "next suggestion please" mechanic AC-33 legislates for — and
AC-33's premise clause is precisely "người dùng liên tục yêu cầu gợi ý tiếp theo
cho tới khi duyệt hết các mục khớp" (`requirements.md:236-242`).

What actually happens at the end of that sequence:

- `gift_ideas_screen.dart:149-155` — when `visible.isEmpty`, the screen renders
  `l10n.gift_ideas_no_match` = "Chưa có ý tưởng nào khớp bộ lọc này."
- `gift_ideas_cubit.dart:205` — `_rank` carries `dismissedGiftIds` forward on
  **every** re-rank, so changing a branch chip or an effort chip does not bring
  a dismissed idea back.

So after the reader dismisses each suggestion in turn, the screen shows
"no idea matches these filters" for *every* filter combination for the rest of
the session, and the statement is false: ideas do match the filter, the reader
dismissed them. AC-33 requires the opposite of all three properties observed
here — it requires degradation to a broader set per BR-3 or deterministic
cycling, it forbids an out-of-ideas read, and it forbids a dead-end screen.

Severity, honestly stated: reaching it takes one deliberate dismiss per shipped
idea in a single session, and leaving screen (5) and returning rebuilds the
cubit and restores everything, so nothing is lost permanently. But AC-33 is
explicit that it holds "với mọi N — 3, 10, hay vài trăm", and the smaller the
pack the cheaper the path. The patch's own suite cannot catch it because no case
dismisses more than one card.

This finding is *caused by* authorized item 2, but it is not the item itself:
the dismiss control was correctly added per the user's design-anchor decision.
What is missing is the exhaustion behaviour AC-33 attaches to it. Under this
slice's stop rule this is not a stop condition (F1 is resolved and neither
protected item was touched), so it is passed to final synthesis with the
severity marked rather than adjudicated here.

### F7 — MINOR (NEW): `-md-full.png` does not evidence what the report says it evidences

`visual-fidelity-report.md:170-176` introduces the third capture specifically
because "the reworked components that sit below the fold — the compact card
variant and **the bottom guess row** — are invisible in a 415x900 frame and a
reader could not check them", and the table at line 182 describes it as "whole
page, including everything below the fold".

I opened it. At 415x1600 the page is still clipped: it ends part-way through a
compact card, several cards above the guess row. The compact variant is
evidenced; the guess row is not, in any of the three captures. The guess row's
*behaviour* is independently covered by two widget tests including a geometric
below-every-card assertion, so this is an evidence defect, not a product defect
— but the report currently asserts visual evidence that does not exist. Fold in:
the "Screens under audit" table at line 14 still lists only two implemented PNGs
for screen 5.

### F8 — MINOR (NEW): the report's Authority note now contradicts its own §P7

`visual-fidelity-report.md:59-64` still reads, with no phase qualifier, "Where
the design reference and `ux/uiux-spec.md` disagree, the spec wins … these are
**not** implementation gaps and must not be 'fixed' toward the canvas." Read at
document level that is the exact position §P7 lines 220-231 retracts. It sits
above the P4 conflict list and before the `---` P7 divider, so it is *probably*
scoped to P4 — but nothing in the text says so, and a future reader landing on
line 59 gets the reversed rule. Wants a one-clause scope qualifier.

## 7. Observations (not findings)

**O1 — the compact shape states effort in minutes, not hours.** AC-20 asks for
"ước lượng công sức theo giờ" and the whole R-11 framing is an hours scale.
`_EffortBadge` renders the pack's `max_minutes` verbatim, so the capture shows
`240'` for a four-hour idea beside `30'` for a half-hour one. It is faithfully
pack-derived — which is why this is not an AC-32/AC-34 problem — and the canvas
itself draws `20'`, so it is design-anchored too. It simply reads oddly at the
top of the range. A pack-level or format-level question, not a code defect.

**O2 — carried Gap 3 is unchanged and now more visible.** The full-page capture
makes plain how much vertical space the six-option `AskOnTheSpotSlot` takes
above the first suggestion. Still the P4 component's property, still outside
this phase's write scope, still correctly recorded rather than changed.

**O3 — ARB parity is complete.** Every one of the nine new keys exists in both
`app_vi.arb` and `app_en.arb`, and both removed `gift_ideas_location_lock_*`
keys are gone from both files. No orphan and no untranslated placeholder.

## 8. Slice conclusion

The patch does what the recorded user decisions asked of it. F1 is genuinely
closed at the widget layer and backed by a non-vacuous test. F2 is closed
procedurally and correctly scoped: the five authorized items are reworked to the
canvas and visible in the captures, and the two protected pack-data-driven items
were left alone with the right criteria cited. F3 is closed. F4 is unchanged and
documentation-only. No scope creep, no new lint, no regression in the 37-case
content gate.

One new MAJOR AC gap emerged from the patch's own new control: F6, AC-33
exhaustion behind the dismiss `×`. Two new minor evidence defects (F7, F8) sit in
`visual-fidelity-report.md`. All three, plus residual F4, are handed to the
final-synthesis reviewer, which owns the story verdict.

REVIEW_SLICE_COMPLETE: YES
