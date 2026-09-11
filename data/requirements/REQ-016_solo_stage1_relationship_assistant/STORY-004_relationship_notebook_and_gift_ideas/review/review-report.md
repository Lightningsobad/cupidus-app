# STORY-004 — Story Review Report (final synthesis)

This file replaces the earlier `PARTIAL_SLICE_ONLY` stopgap. It is the single
canonical review gate for
`REQ-016_solo_stage1_relationship_assistant/STORY-004_relationship_notebook_and_gift_ideas`.

- Mode: final-synthesis (Tier-3 Scoped Slice + Fresh Final Synthesis)
- Reviewer: Iris-QC (fresh spawn; not a continuation of any slice session)
- Date: 2026-09-11
- Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-004_relationship_notebook_and_gift_ideas`
- Worktree HEAD at review: `c6189147e4813408c2c98e89b03ecab380afde03`
  (the P7 design-anchor patch commit; the handoff's `BaseHead` is the same sha)
- Story diff baseline for the slice chain: `e5b3741743744241cd8cfb60543cf6d37f0ec946`

## Scope Gate

Review type: final synthesis over seven completed slice reviews.

Slice inputs, all read in full:

| File | Phase | Slice verdict |
|---|---|---|
| `review/slice-P1.md` | P1 persistence | all scoped items PASS |
| `review/slice-P2.md` | P2 invariant gate + context packs | all scoped items PASS |
| `review/slice-P3.md` | P3 ask-on-the-spot surface | all 10 PASS, 1 blocker (since fixed) |
| `review/slice-P4.md` | P4 notebook + skill screens + menu | all PASS |
| `review/slice-P5-P6.md` | P5 gift packs/gate, P6 repo/selector | all PASS, 1 MAJOR traceability item |
| `review/slice-P7.md` | P7 gift screen, quick-entry, push-to-hub | 12/13 PASS, 1 FAIL, 2 gate items |
| `review/slice-P7-patch.md` | P7 design-anchor patch `c618914` | prior FAIL closed, 1 new MAJOR FAIL |

Governing AC text: `requirements/requirements.md`. Every AC id in the table below
was checked against that file directly at this pass (lines 82-264 read in two
ranges). Where a slice filed a row under an id whose text governs something else,
the row here is filed under the correct id and the drift is recorded in D-C.

Source re-opened by this reviewer (not taken from slice prose):
`mobile/lib/features/gift_ideas/presentation/cubit/gift_ideas_cubit.dart` (full),
`mobile/lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart`
(lines 1-60, 110-210),
`mobile/lib/features/gift_ideas/presentation/widgets/gift_idea_card.dart`
(lines 193-247),
`mobile/lib/features/gift_ideas/domain/gift_selector.dart` (lines 178-217),
`mobile/test/features/gift_ideas/gift_ideas_screen_test.dart` (lines 648-777 plus
the full `c618914` test diff), `story_master.md` (lines 1-40).

Query keys: `dismissedGiftIds` · `visibleSuggestions` · `nextBatch` ·
`gift_ideas_no_match` · `_ProvenanceLine` · `Design-Screen`.

## Consolidated AC verdict table

| AC | requirements.md | Subject | Verdict | Owning evidence |
|---|---|---|---|---|
| AC-1 | :82-86 | Câu trả lời ghi thẳng, không toast/nút lưu | PASS | slice-P3 |
| AC-2 | :88-91 | Một câu một lần, không nối đuôi, đúng một thẻ hỏi mỗi route | PASS | slice-P3 (`_routeClaims`), slice-P7 (one ask slot on screen 5) |
| AC-3 | :93-95 | Bỏ qua không chặn, không hỏi lại ngay, không trách móc | PASS | slice-P3 |
| AC-4 | :97-98 | Trường đã trả lời có mặt, sửa được, xoá được | PASS | slice-P1 (lưu trữ), slice-P3 (đọc qua facade), slice-P4 (UI) |
| AC-5 | :100-102 | Không luồng điền-trước/onboarding | PASS | slice-P4 |
| AC-6 | :106-109 | Chỉ sở thích + sự kiện, không trường đánh giá người | PASS | slice-P1 (schema set-equality), slice-P4 (UI) |
| AC-7 | :111-113 | Không xuất/chia sẻ/copy-all/Share Sheet | PASS | slice-P4 |
| AC-8 | :115-118 | Danh sách (có thể rỗng) + "+ tự thêm", trung tính | PASS | slice-P4 |
| AC-9 | :120-122 | Sửa/xoá hiệu lực ngay, không kịch tính hoá | PASS | slice-P1, slice-P4 |
| AC-10 | :126-128 | Câu hỏi kỹ năng cụ thể + mồi chạm-để-chọn, không ô trống | PASS | slice-P2 (gate từ chối pack thiếu chip), slice-P3 (free text opt-in) |
| AC-11 | :130-133 | Bốn kỹ năng mềm bắt buộc, hiện trước khi phải gõ | PASS | slice-P2 (`requiredSkillSeedIds` là luật gate), slice-P3, slice-P4 |
| AC-12 | :135-136 | Không mức độ/sao/điểm/xếp hạng cho kỹ năng | PASS | slice-P1 (cột bị cấm), slice-P4 |
| AC-13 | :138-140 | Hồ sơ kỹ năng rỗng vẫn ra gợi ý handmade dùng được | PASS | slice-P5 (`branchWithoutIdea`), slice-P6 |
| AC-14 cl.1 | :144-146 | Lọc theo **dịp × giai đoạn quen nhau × nội dung sổ tay** | **PARTIAL** | 2/3 trục có thật; trục "giai đoạn quen nhau" không tồn tại dưới `requirements.md`. Xem D-A. |
| AC-14 cl.2 | :144-146 | Mỗi gợi ý riêng-hoá nêu rõ cơ sở người dùng đã tự nhập | PASS | `_ProvenanceLine` phủ cả 3 `GiftContextKind`, render trên cả `_FullBody` và `_CompactBody`; test AC-14 không rỗng-hoá (có guard `expect(personalised, isNotEmpty)` + guard nhánh non-skill). Đã đọc lại nguồn ở pass này. |
| AC-15 | :148-150 | Sổ tay rỗng vẫn cho tập kết quả dùng được | PASS | slice-P5, slice-P7-patch |
| AC-16 | :152-154 | Bộ lọc theo giờ, không VNĐ/khoảng giá/nhãn rẻ-đắt | PASS | slice-P5 gate, slice-P7 rendered-tree scan |
| AC-17 | :156-158 | Bộ lọc "2 tiếng tối nay": mọi kết quả trong ngưỡng | PASS (dè dặt) | slice-P6 (ceiling filter); nhãn bậc là dữ liệu gói, xem D-D |
| AC-18 | :160-162 | Nhánh không-tốn-tiền là bộ lọc riêng, trả về **không rỗng** | **AT RISK** | slice-P6 PASS ở tầng selector, nhưng ở màn hình dismissal mang qua mọi lần re-rank có thể làm nhánh này rỗng. Nằm trong bán kính của F6. |
| AC-19 | :164-166 | Không link mua/tên cửa hàng/mã giảm/affiliate | PASS | slice-P5 gate (9 fixture đỏ), slice-P7 |
| AC-20 | :168-170 | Gợi ý handmade nêu rõ sinh từ kỹ năng nào, công sức **theo giờ** | PASS (dè dặt) | `_basis()` ưu tiên `GiftContextKind.skill` khi `isHandmade`; thẻ compact hiển thị phút, xem D-E |
| AC-21 | :174-176 | Đẩy thành thẻ ở *Mới nghĩ ra*, nguồn sinh "gợi ý quà" | PASS | `addToHub` → `origin.giftSuggestion` (`wireValue == 'gift_suggestion'`), khẳng định trong test; ở lại màn sau khi đẩy |
| AC-22 | :178-180 | Không kho thứ hai, không danh sách "quà đã lưu" | PASS | slice-P7 + slice-P7-patch: `×` không ghi gì, `_CircleAction` là affordance *thêm*, đúng một `ElevatedButton` toàn màn |
| AC-23 | :182-184 | Trường `giá` để trống, luồng quà không bao giờ ghi | PASS | `NewActivityCard` bỏ hẳn `priceVnd`; `priceVnd, isNull` được khẳng định |
| AC-24 | :186-188 | Mọi gợi ý **đang xem** có ít nhất một đường đi tiếp | PASS | Mọi thẻ render đều mang `gift_idea_add_<id>`; `_GuessRow` trả lời bằng snackbar. Trường hợp hết-tập thuộc AC-33, không thuộc AC này. |
| AC-25 | :192-195 | Không lưu/không hiển thị đại lượng hành vi người kia | PASS | slice-P1 (cột bị cấm), slice-P4, slice-P7-patch (`rows` là dòng người đọc tự viết; `dismissedGiftIds` không persist) |
| AC-26 | :197-200 | Nội dung về người kia kết bằng câu để hỏi, đoán ở tầng "user đoán" | PASS (hẹp) | slice-P5 gate; `gift_ideas_guess_row` là lời mời, không phải kết luận |
| AC-27 | :202-204 | Không đóng khung chiến thuật/hứa hẹn phản ứng | PASS (1 khoảng trống test) | Rule `manipulativeTone` có nối dây nhưng không có fixture họ-quà. Xem D-F. |
| AC-28 | :206-209 | Cùng đầu vào ⇒ cùng kết quả, không AI/API runtime | PASS | slice-P6 (thứ tự toàn phần + golden id list + anti-second-store scan); dismissal áp ở tầng view nên `suggest` vẫn thuần |
| AC-29 | :211-213 | Không paywall, streak, huy hiệu, bảng xếp hạng | PASS | slice-P4 |
| AC-30 | :217-218 | Không bao giờ có phản hồi người kia ⇒ mọi AC trên vẫn đạt | PASS | Không bề mặt nào của story nhận đầu vào từ người kia; mọi ngữ cảnh là do người dùng tự nhập |
| AC-31 | :220-226 | Cổng ship: mọi mục qua cổng nhập AC-35 + trạng thái duyệt truy vết theo id bền | PASS (dè dặt) | Mọi gói mang `schema_id` + id bền per-item và được quét from-disk; `editorial_review` chưa được gate ở họ context pack. Xem D-G. |
| AC-32 | :230-234 | Nội dung là gói dữ liệu có lược đồ + id bền, không chuỗi cứng | PASS | slice-P2 (2 gói), slice-P5 (3 gói quà), slice-P7 (`_FilterChipRow` không literal, không ô "tất cả"); patch để nguyên `_FilterChipRow` |
| AC-33 | :236-242 | Hết-tập là trạng thái êm đã định (suy giảm BR-3 **hoặc** quay vòng tất định); không "đã hết ý tưởng", không ngõ cụt, không chỉ báo tiến độ | **FAIL** | Cơ chế quay vòng có thật ở domain (`GiftSelector.nextBatch`) và **không có caller nào trong `lib/`**. Xem F6. |
| AC-34 | :244-249 | Số bậc/số nhánh là thuộc tính dữ liệu; N nhỏ ⇒ rỗng đã định, N lớn ⇒ không đổi hành vi | PASS | slice-P5, slice-P6 (N=1 và N=200), slice-P7-patch (2 mục được bảo vệ giữ nguyên data-driven) |
| AC-35 | :251-257 | Mục vi phạm bị cổng nhập từ chối và làm hỏng bản dựng, kể cả nội dung từ CMS ngoài repo | PASS (mệnh đề CMS hoãn) | slice-P2 (6 rule hiển thị), slice-P5 (13 fixture đỏ). Cổng không có caller runtime. Xem D-B. |
| AC-36 | :259-264 | Câu hỏi vi phạm ranh giới sổ tay bị từ chối ở tầng ĐẦU VÀO | PASS | slice-P2 (`NotebookBoundaryRule` áp cho cả prompt và chip) |

Tally: 33 rows PASS (7 with a named reservation), 1 PARTIAL (AC-14 clause 1),
1 AT RISK inside another finding's blast radius (AC-18), 1 FAIL (AC-33).

## Findings ledger — final status

Slice finding ids collide across files (three different `F1`s). Ids below are
disambiguated by slice.

| Id | Origin | Severity | Final status |
|---|---|---|---|
| P3-F1 | slice-P3 | BLOCKING | **CLOSED.** Import boundary green at HEAD; `gift_ideas_screen.dart:8` now imports only `context_notebook_entry_point.dart`. Confirmed by re-reading the import block at this pass. |
| P7-F1 | slice-P7 | MAJOR | **CLOSED.** AC-14 clause 2 met by `_ProvenanceLine` over all three context kinds, on both card shapes, backed by a non-vacuous test. Re-verified in source at this pass. |
| P7-F2 | slice-P7 | BLOCKING (procedural) | **CLOSED.** User decision recorded (anchor on DESIGN, precedent `b516c48`); Scrum-Master scoping split 5 authorized / 2 protected against AC-32/AC-34/R-15b; `slice-P7-patch.md` independently confirmed the split in shipped code and captures. Not re-litigated. |
| P7-F3 | slice-P7 | MINOR | **CLOSED.** `story_master.md:12-14` now lists all three design screens. Verified directly. |
| P7-F5 | slice-P7 | UNVERIFIED | **CLOSED by Scrum Master.** Runtime startup smoke executed directly (debug APK build, install on `emulator-5554`, `am start -W`, resumed-activity poll, `force-stop`). Accepted as given per handoff; not re-run. |
| **F6** | slice-P7-patch | **MAJOR** | **CONFIRMED — PATCH REQUIRED.** See below. |
| P7-F4 | slice-P7 | MINOR (doc) | **DEFERRED.** See D-H. |
| P7p-F7 | slice-P7-patch | MINOR (evidence) | **DEFERRED.** See D-I. |
| P7p-F8 | slice-P7-patch | MINOR (evidence) | **DEFERRED.** See D-J. |
| P56-F1 | slice-P5-P6 | MAJOR (traceability) | **DEFERRED — requires Product Owner adjudication.** See D-A. |
| P56-F2/F3/F6, P2-F1..F4, P4-F1..F5, P3-F2/F3, P56-F4/F5 | various | MINOR/INFO | **DEFERRED.** Rolled up in D-C..D-G and D-K. |

### F6 — CONFIRMED. AC-33 has no exhaustion behaviour behind the dismiss `×`

I confirmed this independently rather than accepting the slice's characterisation.
Three facts, each read in source at this pass:

1. `gift_ideas_screen.dart:172-175` gives the dismiss `×` to the lead card only,
   and dismissing it promotes the next suggestion into the lead shape. That is,
   by construction, the "gợi ý tiếp theo" mechanic whose premise clause AC-33
   legislates for: *"người dùng liên tục yêu cầu gợi ý tiếp theo cho tới khi
   duyệt hết các mục khớp"* (`requirements.md:236-237`).
2. `gift_ideas_cubit.dart:205` carries `dismissedGiftIds` forward on **every**
   `_rank` pass, and `GiftIdeasState.visibleSuggestions`
   (`gift_ideas_cubit.dart:101-107`) filters them out unconditionally. Nothing
   ever clears the set except disposing the cubit. There is no wrap, no reset on
   exhaustion, and no widening of the result set.
3. `gift_ideas_screen.dart:149-155` renders `l10n.gift_ideas_no_match`
   ("Chưa có ý tưởng nào khớp bộ lọc này.") whenever `visible.isEmpty` — and
   `visible` is the **post-dismissal** list. The screen cannot distinguish "the
   pack genuinely has no match for this filter" (the AC-34 defined-empty state,
   which is legitimate) from "you dismissed them all" (the AC-33 state, which is
   not). In the second case the sentence is factually false.

AC-33 requires one of two behaviours and the screen implements neither:
*"suy giảm sang bộ gợi ý rộng hơn theo BR-3 hoặc quay vòng tất định"*. It also
forbids exactly what is shipped: *"không thông báo 'đã hết ý tưởng', không màn
ngõ cụt"*.

The decisive point against deferring this: **the cycling mechanism already
exists in this story and is already tested — the screen simply does not use it.**
`GiftSelector.nextBatch` (`gift_selector.dart:192-213`) wraps with
`cursor % length`, and its own doc comment names the AC:

```dart
/// Running out is not a state this flow has: the cursor rolls over modulo the
/// list length, so there is no "đã hết ý tưởng" message, no dead-end screen,
/// and no remaining-count to show (AC-33).
```

slice-P5-P6 verified it green (cursor 100 ≡ cursor 4; 20 consecutive full
batches, `gift_selector_test.dart:397-441`). It has **zero callers in
`mobile/lib`**: `GiftIdeasCubit` calls only `_selector.suggest`. So AC-33 passes
at the domain layer and fails at the only layer a user can see.

Test coverage claim verified: the `bỏ qua một gợi ý` group
(`gift_ideas_screen_test.dart:661-713`) has exactly two cases, and the deeper one
dismisses exactly **one** card. No case dismisses more than one. The patch's suite
is green over a real AC gap, as `slice-P7-patch.md` §4 stated.

Adjudication against the two escape hatches the handoff named:

- *Pre-existing and outside the patch's blast radius?* **No.** The dismiss control
  is new in `c618914`. Before it there was no "next suggestion" request mechanic,
  so AC-33's premise clause had no trigger surface in the app. The patch created
  the trigger without the behaviour AC-33 attaches to it, in files the patch owns
  (`gift_ideas_screen.dart`, `gift_ideas_cubit.dart`).
- *AC-33 satisfied some other way?* **No.** Verified in source, above.

Severity, stated fairly: nothing is persisted, and leaving screen (5) rebuilds
the cubit and restores every idea. But AC-33 is explicit that the rule holds
*"với mọi N — 3, 10, hay vài trăm"* and that **no AC of this story may be derived
from the seed pack having 10 items** — which is precisely the "10 taps is a lot"
argument, pre-emptively refused by the AC's own text. The seed pack ships 9-10
ideas, so the false state is roughly nine taps of a control whose entire purpose
is "show me the next one".

Blast radius beyond AC-33: because dismissals survive filter changes, a *single*
dismissal can empty a narrow branch. Dismissing the lead card while the no-cost
branch has one remaining match makes that branch render the false no-match line,
which is in tension with AC-18's non-empty guarantee (`requirements.md:160-162`).
This lowers the N needed from "the whole pack" to "one branch".

### Required patch scope for F6 — and nothing else

Only these files need to change. Do **not** reopen P7-F1, P7-F2, P7-F3 or P7-F5,
and do **not** touch `_FilterChipRow`, `gift_taxonomy.v1.json`, or the two
protected pack-data-driven items.

1. `mobile/lib/features/gift_ideas/presentation/cubit/gift_ideas_cubit.dart`
   — the dismissal set must not be able to empty a non-empty ranked list.
   Either clear `dismissedGiftIds` when the next dismissal would exhaust the
   visible set (deterministic cycling back to the full ranked order), or route
   the visible list through the already-tested `GiftSelector.nextBatch` cursor.
   Prefer the existing mechanism over a new one. Keep dismissals applied at the
   view layer so `GiftSelector.suggest` stays pure (AC-28 — currently correct).
   Consider also not carrying dismissals across a filter change, which is what
   puts AC-18 at risk.
2. `mobile/lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart`
   — the `gift-ideas-no-match` empty state must be reachable **only** from the
   genuine AC-34 case (`state.suggestions.isEmpty`, i.e. the pack really has no
   match for this filter), never from the post-dismissal case.
3. `mobile/test/features/gift_ideas/gift_ideas_screen_test.dart`
   — add the coverage whose absence let this ship: one case that dismisses
   **every** suggestion and asserts the set comes back rather than the no-match
   line appearing, and one case that dismisses then changes a filter chip and
   asserts the branch is not falsely empty.

No l10n change is required: `gift_ideas_no_match` keeps its correct AC-34
meaning. If the fix introduces new copy, both `app_vi.arb` and `app_en.arb` must
stay at parity.

Re-review can be a narrow scoped slice over these three files.

## Deferred items and residual risks

- **D-A (MAJOR, needs Product Owner).** AC-14 clause 1's "giai đoạn quen nhau"
  axis exists in no artifact below `requirements.md` — not in
  `architecture/contract-summary.md`, `coding-plan/master-plan.md`, or
  `ux/uiux-spec.md`, and `GiftContextKind` is a closed `interest`/`event`/`skill`
  set. The axis was descoped **upstream of implementation**; P5 and P6 faithfully
  built the contract they were pointed at, so this is not a developer defect and
  must not be fixed in the F6 patch round. Product Owner must either patch
  AC-14/AC-28 wording to record the descope, or raise a follow-up story. Note the
  BR-16 tension the slice raised: adding the axis later needs a fourth enum value,
  i.e. a Dart edit, which cuts against content-as-data. **This must be resolved
  before requirement integration review**, not silently carried.
- **D-B (residual, requirement-level).** AC-35's final clause — the gate runs even
  for content supplied by an out-of-repo CMS — is not satisfied: neither
  `validateContextPacks` nor `validateGiftPacks` has a caller in `mobile/lib`; both
  run only from `flutter test`. The shipped packs *are* gated from disk at CI time,
  so the exposure is a pack edited without running the suite, not an unvalidated
  production path. The same shape shipped in merged STORY-002, and no CMS exists
  in the repo. Recorded here as a deliberate requirement-level deferral, which is
  what slice-P2 asked final synthesis to decide.
- **D-C (documentation).** AC-id citation drift, now 11 logged instances across
  the phase files, the P6/P7 planning artifacts, and `slice-P7.md`'s own verdict
  table (its "AC-20"/"AC-30"/"AC-31" rows describe AC-20's location line, AC-21's
  origin value, and AC-2's single-ask rule respectively). Code and tests use the
  correct ids throughout. The table in this report is filed against
  `requirements.md` text and supersedes every earlier table. Worth one cleanup
  pass on the phase files so the drift is not re-copied.
- **D-D.** The effort-tier labels ship as "Trong 30 phút / Một tới hai giờ / Trọn
  một buổi"; neither `uiux-spec.md` Phần D's "làm được trong 2 tiếng tối nay" nor
  the canvas's single chip appears. Correct under AC-32/AC-34/R-15b — labels are a
  pack property — so this is a content decision nobody has explicitly taken, not a
  code defect.
- **D-E (O1).** The compact card renders effort in minutes (`240'`) while AC-20
  says "theo giờ". Faithfully pack-derived and the canvas draws minutes too, so it
  is design-anchored on both sides. A pack/format question.
- **D-F.** `manipulativeTone` is the one shared invariant rule with no gift-family
  fixture, and it is the rule AC-27 exists for. Wired, not proven. One fixture in
  the AC-26 group closes it.
- **D-G.** `editorial_review` is parsed but ungated in the context-pack family
  (the preset family has `editorialReviewIncomplete`). AC-31's traceability half
  holds via durable ids; the asymmetry between the two gate families is the
  residual.
- **D-H (P7-F4).** `coding-plan/test-results.md` has no `## Entry Point
  Reachability` heading. Documentation only — the entry point is real,
  independently verified in code by two separate slice reviewers, and covered by
  four widget tests. Non-blocking.
- **D-I (P7p-F7).** `implemented-...-md-full.png` clips before the guess row
  despite `visual-fidelity-report.md:170-176` introducing it specifically to
  evidence that row. Evidence defect, not a product defect: the row's behaviour has
  two widget tests including a geometric below-every-card assertion. The report's
  claim should be corrected or a taller capture taken.
- **D-J (P7p-F8).** `visual-fidelity-report.md:59-64`'s Authority note still states
  an unscoped "spec beats canvas" rule that §P7 lines 220-231 retracts. Needs a
  one-clause phase qualifier so a future reader landing on line 59 does not get the
  reversed rule.
- **D-K (carried, low).** Notebook rows written inside the same second are ordered
  arbitrarily-but-stably (`DateTime` at one-second granularity, UUID tie-break),
  contradicting the facade's own "Newest first"/"Oldest first" doc comments. No AC
  imposes ordering. P1-owned follow-up. Also: `AskOnTheSpotSlot.entryPointId` is
  contract-required but never read; `eventOn` is written and rendered by nothing;
  repo-wide `flutter analyze lib test` still exits 1 on a pre-existing ~217-issue
  info baseline that predates this story.

## Conclusion

Across three phases and 36 acceptance criteria this story is in good shape: the
persistence layer's forbidden columns are enforced by executable set-equality, the
content packs are genuine data with durable ids behind a build-breaking entry gate
with red-proven fixtures, the selector is deterministic by construction, no second
store or price field exists anywhere, and the two design-vs-pack items the user's
design-anchor decision did **not** authorize were correctly left alone. Three of
the four blocking or major items carried into this synthesis are genuinely closed,
verified in source rather than accepted from a report.

One acceptance criterion fails at the user-visible layer. AC-33's exhaustion
behaviour is absent behind the dismiss control the P7 patch introduced, the screen
shows a factually false no-match message for the rest of the session once the
reader has waved ideas away, and the deterministic-cycling mechanism this story
already built and tested has no caller. The fix is small, bounded to three files,
and can reuse code that already exists — which is a further argument for fixing it
now rather than carrying it.

Outcome: PATCH_REQUIRED
