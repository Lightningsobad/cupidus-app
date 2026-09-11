# STORY-004 — Scoped slice review: P5 + P6

Outcome: PARTIAL_SLICE_ONLY

- Review type: scoped-slice (Tier-3 combined slice, phases P5 and P6)
- Reviewer: Iris-QC
- Date: 2026-09-11
- Story: REQ-016 / STORY-004 Kho ngữ cảnh + gợi ý quà
- Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-004_relationship_notebook_and_gift_ideas`
- Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-004_relationship_notebook_and_gift_ideas`
- Diff base: `e5b3741743744241cd8cfb60543cf6d37f0ec946` (merge-base with the
  requirement integration branch), diffed against current HEAD.

This file is authoritative for phases P5 and P6 only. It is not the story gate.

## Scope Gate

Review type: scoped-slice

### Source/Test Files In Scope

P5 (6 declared, all present in the diff):

- `mobile/lib/features/gift_ideas/domain/gift_content.dart` (+247)
- `mobile/lib/features/gift_ideas/domain/gift_content_gate.dart` (+255)
- `mobile/assets/data/req016/gifts.v1.json` (+80)
- `mobile/assets/data/req016/gift_index.v1.json` (+103)
- `mobile/assets/data/req016/gift_taxonomy.v1.json` (+41)
- `mobile/test/features/gift_ideas/gift_content_gate_test.dart` (+632)

P6 (5 declared, all present in the diff):

- `mobile/lib/features/gift_ideas/data/gift_repository.dart` (+94)
- `mobile/lib/features/gift_ideas/domain/gift_selector.dart` (+278)
- `mobile/lib/core/di/service_locator.dart` (+30, shared file)
- `mobile/test/features/gift_ideas/gift_selector_test.dart` (+534)
- `mobile/test/features/gift_ideas/gift_repository_test.dart` (+287)

Write-scope deviations: none. Every changed file in this slice is declared. The
`service_locator.dart` hunk is a single additive block; it contains no edit to
another phase's registrations.

Out of scope, read only as a dependency: `mobile/lib/core/content/invariant_terms.dart`
(P2, lines 1-55, to confirm the `InvariantRule` enum is mirrored 1:1).

### Evidence Files In Scope

- `data/requirements/.../STORY-004.../test-results.md` §"Phase P5" (lines 299-430)
- `data/requirements/.../STORY-004.../coding-plan/test-results.md` §"Phase P6" (lines 99-228)
- `data/requirements/.../STORY-004.../coding-plan/phase-P5-gift-content-packs-and-gate.md`
- `data/requirements/.../STORY-004.../coding-plan/phase-P6-gift-repository-and-deterministic-selector.md`
- `data/requirements/.../STORY-004.../architecture/contract-summary.md` §1, §2, §3, §6
- `data/requirements/.../STORY-004.../requirements/requirements.md` AC-13..AC-21,
  AC-26..AC-28, AC-32..AC-34, BR-11, BR-17

Both evidence files were checked directly rather than assumed: P5's section lives
in the story-root `test-results.md`, P6's in `coding-plan/test-results.md`.

### Query Keys

`validateGiftPacks` · `GiftGateRule` · `requiredGiftBranchIds` · `GiftContextKind`
· `GiftSelector.suggest` · `nextBatch` · `GiftCatalogue` · `GiftRepository`
· `registerLazySingleton<GiftRepository>` · `giai đoạn quen nhau`

### Phase 2 Approval

Approved. 11 files, under the 12-file compact cap; the two phases share one
feature tree and one content family, so splitting them further would have split
`gift_content.dart` from its only consumer.

## Independent verification

Re-run by the reviewer, not copied from the phase evidence:

```
flutter test test/features/gift_ideas/gift_content_gate_test.dart \
             test/features/gift_ideas/gift_selector_test.dart \
             test/features/gift_ideas/gift_repository_test.dart
```

`00:01 +71: All tests passed!`, EXIT=0.

71 = 37 (gate) + 24 (selector) + 10 (repository), which reconciles exactly with
the counts P5 and P6 each claim in their own evidence sections. This matters more
than the totals: the P5-owned `no Dart file in the gift flow hardcodes a count`
scan and the P6-owned anti-second-store scan both walk the whole
`lib/features/gift_ideas/` tree, so they now also cover P7's presentation files,
and they are green at HEAD with those files present.

## Per-AC / BR verdict

### Phase P5

| Id | Verdict | Evidence |
|---|---|---|
| AC-13 (empty skill profile still yields handmade ideas) | PASS | `gift_taxonomy.v1.json:18-21` ships `handmade`; `gifts.v1.json` gives it 4 ideas (`gift.thu_tay_ke_ky_uc.v1`, `gift.bua_com_nau_tai_nha.v1`, `gift.album_anh_tu_dan.v1`, `gift.do_thu_cong_theo_nghe_tay.v1`), and `gift_content_gate.dart:129-139` makes a branch with no idea a `branchWithoutIdea` violation, so the empty-screen state cannot ship. Behavioural proof is in P6. |
| AC-14 (suggestions filtered by occasion × stage × notebook, each says what it derives from) | PARTIAL — see F1 | The occasion and notebook axes exist as `gift_index.v1.json` rows keyed `event`/`interest` (`gift_content.dart:47-64`), and `every index row resolves to a shipped idea (R-15a)` asserts all three `GiftContextKind` values are used. The relationship-stage axis has no representation in the schema. |
| AC-15 (empty notebook still non-empty) | PASS | The idea pack is independent of the index: `gifts.v1.json` ships 9 ideas, no index row is required for one to exist. Behavioural proof at `gift_selector_test.dart:264-283`. (The evidence file's justification for this row is wrong — F3.) |
| AC-20 (handmade suggestion names the skill it came from) | PASS | `gift_index.v1.json:69-101` keys four rows by the durable seed ids from contract-summary §2, each pointing at handmade ideas that carry an `effort_tier_id`; `GiftIndexRow.value` doc at `gift_content.dart:117-119` fixes seed id, not wording, as the key. |
| AC-26 (content about the other person ends in a question, no inference) | PASS | `gift_content_gate.dart:215-221` runs P2's `invariantHitsIn` over every display string — idea title, idea description, taxonomy label, index row value. Proven to fire on gift packs for `flattery`, `percentDisplay`, `scoreOrRatio`, `recipientBehaviour` at `gift_content_gate_test.dart:520-550`. See F4 for the one shared rule with no gift-family fixture. |
| AC-33 / BR-17 (N is data, no count constant) | PASS | `gift_content_gate_test.dart:297-311` fails on any bare integer literal anywhere under `lib/features/gift_ideas/`, after stripping string literals then line comments (`:160-168`); the anti-vacuous case at `:286-295` proves the scan can tell `final int ideaCount = 9;` from `const String p = 'a9'; // 9`, and `expect(files, isNotEmpty)` proves the file set is non-empty. Verified green at HEAD. |
| AC-34 (branches and tiers are data, unknown ids rejected) | PASS | `gift_content_gate.dart:73-97` raises `unknownTaxonomyId` for both `branch_id` and `effort_tier_id`; `GiftTaxonomyKind` (`gift_content.dart:26-42`) names only the two *kinds* of item, never their values, so no `switch` over a hardcoded branch list exists. Red-proven at `gift_content_gate_test.dart:552-580`. |
| BR-11 (all three branches present, each with an idea) | PASS | `gift_content_gate.dart:118-140` raises `missingRequiredBranch` and `branchWithoutIdea`; both red-proven at `gift_content_gate_test.dart:597-630`, plus the from-disk assertion at `:214-226`. |
| R-15a (stable ids) | PASS | Every item id in all three packs is a dotted durable id; `danglingGiftId` (`gift_content_gate.dart:100-116`) makes an index row pointing at an unshipped id a build failure, red-proven at `gift_content_gate_test.dart:582-594`. |
| R-15b (N is a data attribute) | PASS | Same as AC-33; `ContentPackage.length` is asserted to equal `items.length` at `gift_content_gate_test.dart:313-325`. |
| Phase gate: from-disk scan | PASS | `gift_content_gate_test.dart:179-212` opens the three real asset files through `File(...)` and asserts `validateGiftPacks(...)` is empty — same build-breaking mechanism as P2, extended to the gift family. |
| Phase gate: price leak | PASS | Nine red-proven commerce fixtures at `gift_content_gate_test.dart:446-508` (currency symbol, `200k` shorthand, cheap label, store name, store URL, unit-dropped grouped figure, taxonomy label, index row value). Two negative cases at `:510-517` stop the rule over-reaching: hour labels stay clean, and the `no_cost` branch may still say "tiền". |

AC-16, AC-19 and AC-27 are not cited by P5 but are enforced by its gate; they are
adjudicated under P6 below, which does cite them.

### Phase P6

| Id | Verdict | Evidence |
|---|---|---|
| AC-16 (effort filter is hours, no price anywhere) | PASS at this layer | `GiftTaxonomyItem.maxMinutes` (`gift_content.dart:140-146`) is a minutes bound, the only scale in the model; there is deliberately no price/currency/vendor field on `GiftIdea` (`gift_content.dart:66-97`). The gate keeps money out of every string. The on-screen half is P7's. |
| AC-17 (2-hour filter: every result inside the bound) | PASS | `gift_selector.dart:254-275` reads the ceiling off the taxonomy item and keeps ideas whose own tier bound is `<=` it — a ceiling, not an equality, so `30 phút` survives a `1-2 giờ` filter. Asserted at `gift_selector_test.dart:338-355` and re-asserted at both N=1 and N=200 (`:499-510`). |
| AC-18 (no-cost branch is its own filter, non-empty) | PASS | `gift_selector.dart:259-262`; `gift_selector_test.dart:357-369` asserts non-empty and branch-pure, `:371-382` asserts branch and ceiling compose. |
| AC-19 (no purchase link, store name, or discount path) | PASS | Enforced upstream by the P5 gate's `_webAddress` and store-name terms (`gift_content_gate.dart:149-197`), red-proven at `gift_content_gate_test.dart:471-487`. The P6 layer adds no field that could carry one. |
| AC-21 (chosen suggestion becomes a card in the shared hub) | NOT IN THIS SLICE | The selector deliberately has no write path; the push-to-hub action is P7. `GiftContextSnapshot` is documented as a snapshot, not a live handle (`gift_selector.dart:56-72`), which is what keeps a second write path from growing here. |
| AC-27 (not framed as tactics, no promise about the other person's reaction) | PASS with a gap — see F4 | The `manipulativeTone` rule is applied to every gift string through `invariantHitsIn`; `GiftGateRule.manipulativeTone` mirrors it (`gift_content_gate.dart:14`). No gift-family fixture proves it fires. |
| AC-28 (deterministic, no model call, no external content API) | PASS | Total order at `gift_selector.dart:173-177` (score desc, then durable id asc) means no two entries compare equal, so Dart's unstable `List.sort` has nothing to reorder; matches are gathered by walking the index pack in author order (`:224-234`), not by iterating a hash map. Proven three ways: a golden literal id list (`gift_selector_test.dart:149-156, 219-234`), input-order reversal (`:246-261`), and a real-database second read (`gift_repository_test.dart:168-202`). The anti-second-store scan additionally fails on `Random`, `DateTime.now`, `Stopwatch`, `dart:io`, `package:dio`, `package:http`, `HttpClient`, `cupid_api` (`gift_repository_test.dart:232-270`), with a companion case proving the scan reaches the two new files (`:272-285`). |
| AC-33 (rotation, never "out of ideas", no progress indicator) | PASS | `nextBatch` wraps with `cursor % length` (`gift_selector.dart:192-213`) and takes `min(size, length)` so a batch never repeats. Cursor 100 ≡ cursor 4 and 20 consecutive full batches at `gift_selector_test.dart:397-441`; `score` is documented as ranking weight that is never rendered (`gift_selector.dart:118-125`). |
| R-15b (pack size is data) | PASS | The parameterised group at `gift_selector_test.dart:443-533` runs five cases at N=1 and N=200. The N=1 handmade case is honestly conditional (`:486-497`): at N=1 the generated pack holds one `by_occasion` idea, so an empty handmade branch is the *defined* quiet state, and what is asserted is that nothing errors. That is the right assertion, not a weakened one. |
| contract-summary §6 (no second store, no persisted cursor) | PASS | `GiftRepository` (`gift_repository.dart:13-94`) holds one memoised `Future<GiftCatalogue>` over bundled assets and a `ContextNotebookReader`; no table, no DAO, no saved-gift list, no cursor field. The cursor is a `nextBatch` parameter owned by the caller. |
| DI wiring (carried note 1) | PASS | `service_locator.dart` registers `GiftRepository` via `contextNotebookReader()` — the P3 facade, not a new store — and `GiftSelector` as `const GiftSelector()`, a pure value. Both are `registerLazySingleton`, neither is a `SessionScopedStore`, which is correct for client-owned data that must survive sign-out. No second store is created. |

## Findings

**F1 — MAJOR (carry to final synthesis; not a P5/P6 implementation defect).**
AC-14 requires gift suggestions to be filtered by *dịp Việt × giai đoạn quen nhau
× nội dung sổ tay*. The relationship-stage axis exists nowhere in this slice:
`GiftContextKind` (`gift_content.dart:47-64`) is a closed set of
`interest`/`event`/`skill`, `gift_index.v1.json` has no stage-keyed row, and
`GiftSelector.suggest` takes no stage input. The phrase "giai đoạn quen nhau"
appears in `requirements/requirements.md` at lines 52, 145 and 206 and in no
other story artifact — not `architecture/contract-summary.md`, not
`coding-plan/master-plan.md`, not `ux/uiux-spec.md`, and not the requirement
master. So the axis was dropped upstream of implementation, and both phases
faithfully built the contract they were pointed at (contract-summary §2, which
their phase files name as Source Of Truth).

Two consequences worth stating plainly. First, AC-14 and AC-28 both enumerate
inputs that include stage, so neither is fully traceable today. Second, adding
the axis later is not a data-only change: it needs a fourth `GiftContextKind`
enum value, i.e. a Dart edit, which is in tension with BR-16's acceptance test
("swap the content source to an out-of-repo CMS without changing one line of
code"). Better to decide now than after a CMS export exists.

Recommended handling: Product Owner adjudicates at final synthesis — either
confirm the descope and patch AC-14/AC-28 wording, or raise it as a follow-up
story. Do not reopen P5 or P6 for it.

**F2 — MINOR (adjudicates carried note 2: cosmetic, no coverage gap).**
`gift_repository_test.dart:230` labels the anti-second-store group
`(AC-17, AC-18, AC-28)`. AC-17 is the two-hour filter and AC-18 is the no-cost
branch; neither has anything to do with a second store. The correct ids are
AC-28 (determinism, which the group does cover) and AC-22 (no "saved gift"
list, which the `savedGift`/`saved_gift` tokens at `:259-261` genuinely cover).
`coding-plan/test-results.md:176` cites the same group as `(AC-28, AC-32)`,
which is a different wrong pair — AC-32 is content-as-data-with-durable-ids.

This is label drift, not missing coverage: AC-17 and AC-18 are properly covered
by the group `bộ lọc nhánh và mức công sức (AC-17, AC-18)` at
`gift_selector_test.dart:337-395`, verified green. Both mislabels are inherited
from `phase-P6-...md` §4, whose own bullets are shifted the same way — it cites
`(AC-16, AC-21)` for "empty context still non-empty" (that is AC-15), `(AC-19,
AC-27)` for "empty skill profile still non-empty" (that is AC-13), and
`(AC-17, AC-18)` for the anti-second-store grep. Notably the developer's own
in-code labels are *more* accurate than the plan's: `gift_selector_test.dart:285`
and `gift_repository_test.dart:204` both correctly say AC-13. Fix the plan and
the two labels together, or the same wrong pairs will be re-copied by whoever
writes the story-level AC coverage table.

**F3 — MINOR (inaccurate evidence claim).** `test-results.md:406` justifies AC-15
with "`gift.phieu_doi_thoi_gian.v1` cố ý không nằm trong chỉ mục nào để chứng
minh tập nền không rỗng". That is false: the id is listed in
`gift_index.v1.json:60-67` under `gift_index.event.thi_cu_ap_luc.v1`. The
underlying AC-15 verdict is unaffected — the real proof is
`gift_selector_test.dart:264-283`, which asserts an empty snapshot returns every
idea — but the stated reason should be corrected rather than carried into the
story-level coverage table.

**F4 — MINOR (test gap, one shared rule).** Of the six `InvariantRule` values,
five have a gift-family fixture proving they fire on gift content
(`gift_content_gate_test.dart:520-550` covers four; `priceOrCommerce` is covered
separately). `manipulativeTone` has none, and it is precisely the rule AC-27
exists for. The rule *is* wired — `_displayViolations` applies all of
`invariantHitsIn` — so this is unproven rather than unenforced, and P2 covers the
rule in its own tests. Add one fixture in the AC-26 group (a "tặng cái này thì
chắc chắn đổ"-shaped string) to close it.

**F5 — LOW (latent coupling, fails safe).** `_giftRuleFor`
(`gift_content_gate.dart:254-255`) resolves a shared rule's wire value with
`firstWhere` and no `orElse`. I confirmed `InvariantRule`
(`invariant_terms.dart:16-27`) has exactly the six values `GiftGateRule` mirrors,
so it is correct today. A seventh shared rule would make this throw `StateError`
mid-validation. It fails loudly inside the build gate rather than passing
content silently, so this is a robustness note, not a defect. An `orElse` that
raises a named "unmapped shared rule" error would say what went wrong.

**F6 — INFO (stale artifact field).** `phase-P6-...md:127` still reads
`Status: IMPLEMENTED_PENDING_COMMIT`; the work is committed and present at HEAD.
P5's own status line is already `COMPLETE`.

## Residual risks

1. **F1 is the only one that can change the story's shape.** Everything else in
   this slice is either a label or a test fixture. If Product Owner decides the
   stage axis is in scope, it lands in the index schema and in `GiftContextKind`,
   i.e. back through P5, and it will ripple into P7's filter chips.
2. **The two count/store scans now police files two phases own.** They walk all
   of `lib/features/gift_ideas/`, so any future presentation work that adds a
   bare integer literal — an `EdgeInsets.all(16)`, a `maxLines: 2` — turns a
   P5-owned test red. P6's own evidence records this happening once already
   (`coding-plan/test-results.md:223-227`). It is working as designed and it is
   strict; whoever owns P7 rework should know the gate is there before being
   surprised by it.
3. **The commerce term list is deliberately broad.** `giá` is a whole-word term,
   so ordinary Vietnamese phrasing such as "giá trị" would be rejected by the
   gate. The failure direction is safe (build red, author rewords), but a CMS
   editor hitting it will need the term list to be discoverable.
4. **Determinism is proven, cross-process determinism is proven by proxy.** The
   golden literal id list is the right mechanism and it does hold a fresh process
   to a fixed expectation. My own re-run was a single process; P6's evidence
   records two separate `flutter test` invocations agreeing.

## Slice conclusion

P5 and P6 are implemented to their phase plans and to `contract-summary.md`
§1/§2/§3/§6, with all 71 scoped tests independently verified green at HEAD. The
content packs are real data with durable ids, the entry gate is a genuine
build-breaking scan with 13 red-proven fixtures and two anti-over-reach negative
cases, the selector is deterministic by construction rather than by convention,
and no second store or persisted cursor exists. No blocking finding.

One MAJOR traceability item (F1) is raised for adjudication at final synthesis
and is explicitly not a defect in either phase's implementation.

REVIEW_SLICE_COMPLETE: YES
