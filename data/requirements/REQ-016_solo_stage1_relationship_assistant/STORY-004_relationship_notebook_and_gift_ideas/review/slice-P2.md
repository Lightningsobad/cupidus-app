# Slice review — P2 (shared invariant gate + context packs)

- Slice id: `P2-invariant-gate-and-context-packs`
- Story: STORY-004_relationship_notebook_and_gift_ideas (REQ-016)
- Reviewer: Iris-QC (scoped-slice mode)
- Date: 2026-09-11
- Diff base: `e5b3741743744241cd8cfb60543cf6d37f0ec946`
- Files in scope (7): `mobile/lib/core/content/invariant_terms.dart`,
  `mobile/lib/features/invite_composer/domain/preset_content_gate.dart`,
  `mobile/lib/features/context_notebook/domain/context_content.dart`,
  `mobile/lib/features/context_notebook/domain/context_content_gate.dart`,
  `mobile/assets/data/req016/ask_questions.v1.json`,
  `mobile/assets/data/req016/skill_seeds.v1.json`,
  `mobile/test/features/context_notebook/context_content_gate_test.dart`
- Evidence read: story-root `test-results.md` § "Phase P2" (L105–194);
  `coding-plan/phase-P2-shared-invariant-gate-and-context-packs.md` §4, §7
- This is a slice-only artifact. It records no story verdict; the final
  synthesis pass owns that.

Outcome: PARTIAL_SLICE_ONLY

## Verdicts

| Item | Verdict | Evidence |
|---|---|---|
| AC-10 (skill question is a concrete question with tap-to-pick seeds, never a blank "your skills are?" box) | PASS | Structural, not editorial: `askQuestionFromJson` rejects an empty `chips` list at parse time — `context_content.dart:115-121` throws `ContentPackageFormatException('question "$id" must offer at least one seed chip')`, covered by `a question with no seed chips is rejected (AC-10)` (`context_content_gate_test.dart:223-234`). The two shipped `target: "skill"` items are concrete questions ("Việc nào bạn làm gọn tay hơn người xung quanh?", "Việc nhỏ nào bạn hay làm mà người khác thấy tiện?") with 4 chips each (`ask_questions.v1.json:68-89`), and `every shipped question offers tap-to-pick seeds (AC-10)` (test:122-126) asserts this over the whole on-disk pack, so a future CV-form question cannot be added silently. |
| AC-11 (seed set must contain the four everyday soft skills, before the user types anything) | PASS | The four required ids are a **gate rule**, not a content convention: `requiredSkillSeedIds` (`context_content.dart:16-21`) is checked by `validateContextPacks` (`context_content_gate.dart:77-89`), emitting `ContextGateRule.missingRequiredSkillSeed`. Red-proof is asserted, not asserted-away: `a seed pack missing one required id is a violation` (test:372-395) also pins the reported `itemId` to exactly `['skill.nho_dai.v1']`, and `an empty seed pack reports all four missing ids` (test:397-407) pins the full list. On disk all four are present with the AC's own wording — `Nhớ dai`, `Biết chỗ ăn ngon`, `Gói quà đẹp`, `Chọn nhạc hợp cảnh` (`skill_seeds.v1.json:8-42`), guarded by `the four required soft skills are on disk (AC-11)` (test:128-132). |
| AC-11 / BR-5 (no CV shape — no tier, level, or proficiency on a skill) | PASS | Enforced by absence in the type, which is stronger than a validation rule: `SkillSeed` (`context_content.dart:89-102`) carries only `id`, `label`, `editorialReview`. There is no group/tier/level field for any consumer to read, so a dimmed "lesser skills" sub-group cannot be rendered even if a CMS emitted such a key — the parser would drop it. Display order is declaration order. |
| AC-32 (packs are schema'd data with a durable per-item id, not strings in widgets) | PASS *for the two packs this slice ships* | Both files carry `schema_id` + per-item durable ids (`ask_questions.v1.json:4,8`; `skill_seeds.v1.json:4,8`), and schema drift is rejected at load — `a pack under another schema id is rejected at load` (test:249-260). Scope note: AC-32 also names the **gift index / effort scale / branch labels**; those packs are not in this slice and must be verified in the P6 slice. |
| AC-35 (a content item breaking an invariant rule is rejected at the gate and turns the build red) | PASS *for the six display rules that live in this layer* | Eight rule tests in `shared invariant rules fire on context packs (AC-35)` (test:263-328) cover flattery, `%`, streak, score/rank (including on a **skill-seed label**, test:313-320), recipient behaviour, manipulative tone, and a violation hidden in a **chip** rather than the prompt (test:306-311). The whole-word guard is asserted in the correct direction too: `terms match whole words, so "địa điểm" is not a score` (test:322-327) proves the gate is not so blunt it blocks legitimate wording. Scope note: AC-35's `R-11` (gift index priced in VNĐ) and `R-1g` (a line about the other person must end in a question) clauses are enforced in other layers — see `test-results.md` L379-392 (`only the gate names a currency token`) and the STORY-002 preset gate — not here. |
| AC-36 / BR-4 (an ask-on-the-spot question probing frequency, behaviour, or human judgement is rejected at the INPUT layer) | PASS | `NotebookBoundaryRule` + `notebookBoundaryTerms` (`invariant_terms.dart:32-40, 89-118`) are applied to prompt **and** chips (`context_content_gate.dart:53-69`). Four tests (test:330-358) cover frequency, behaviour, human judgement, and a judgement probe smuggled into a seed chip; a clean interest question about the same person is asserted to stay empty (test:360-368), so the rule is not a blanket ban on mentioning the other person. Scoping is correct: the boundary rules are applied to questions only, not to skill-seed labels — a skill label describes the *user's own* ability, which R-1f does not restrict. |
| BR-16 (no pack wording inside widget/code or l10n) | PASS | `no pack wording is written into any Dart or l10n file (BR-16)` (test:134-160) walks `lib/**` recursively and substring-scans every `.dart` and `.arb` file for every shipped prompt, chip, and label, with `expect(authored, isNotEmpty)` guarding against a vacuous pass. Notably the dev tightened the *content* rather than the *test* when five chips collided with existing unrelated Dart strings (`test-results.md` L189-194) — the correct direction. Assets are actually shipped: `mobile/pubspec.yaml:101-102` registers `assets/data/req016/` at directory level, so both new files are bundled without a pubspec edit. |
| BR-18 (invariant rules are a runnable input gate, not an editorial convention) | PASS, with a residual risk carried below | The gate reads the shipped packs **from disk**, not from an in-memory fixture: `File(askQuestionsAssetKey).readAsStringSync()` (test:87-96). Red-ness is demonstrated, not assumed — `test-results.md` L155-165 records temporarily rewording `ask.interest.food.v1` to a frequency probe and the resulting failure, quoting the exact violation string `req016.ask_questions/ask.interest.food.v1 [frequency_probe]: question asks past the notebook boundary via "bao lâu một lần"`, then reverting. |
| R-15a (content is data; swapping to an out-of-repo CMS costs no code edit) | PASS | Shape, ids, wording, and the editorial-review trace all live in JSON; Dart holds only the schema id, asset key, the closed `AskTarget` set, and the required-id list. `AskTarget.fromWireValue` returns `null` for an unknown value and the parser raises (`context_content.dart:104-113`), asserted by `an unknown target is a parse error, not a default` (test:210-221) — so a CMS cannot invent a fourth destination for notebook data by silently falling back to a default. `allow_free_text` must be a real boolean; `"yes"` is rejected (test:236-247). |
| R-15c (the invariant rules have exactly one home) | PASS | The move is mechanical and complete: the diff removes `_deniedTerms`, `_percentSymbol`, `_termPatterns`, and `_patternFor` from `preset_content_gate.dart` (-81 lines) and replaces the lexical scan with `invariantHitsIn` + `_presetRuleFor` (+9). `PresetGateRule`, `PresetViolation`, the `validatePresetPack` signature, and both `detail` strings (`text uses the denylisted term "…"`, `text shows a "%" figure`) are byte-identical, so STORY-002's `preset_content_gate_test.dart` stays green **unmodified** — confirmed by the diff, which does not list that test file. Drift is blocked two ways: `only invariant_terms.dart declares denylisted terms` (test:164-194) fails the build if any other `lib/**/*.dart` redeclares a probe term, and `every gate rule name resolves to a shared rule` (test:196-206) fails if a shared rule has no context-gate counterpart. Named run recorded: `flutter test … --plain-name "the invariant rules have exactly one home"` → `+2: All tests passed!`. |

## Test evidence

From story-root `test-results.md` § "Phase P2" (L112-122):

| Command | Result |
|---|---|
| `flutter test test/features/context_notebook test/features/invite_composer test/core/content` | `+181: All tests passed!` |
| `flutter test test/features/context_notebook` | `+45: All tests passed!` |
| `flutter analyze lib test` | 0 error, 213 pre-existing info/warning (exit 1 from pre-existing issues) |
| `flutter analyze --no-fatal-infos --no-fatal-warnings` on the four touched dirs | 13 issues, **0 error / 0 warning**, all `prefer_initializing_formals` in files this phase did not touch |

The regression requirement in the phase's §6 (`test/features/invite_composer/` stays green after the rule layer is extracted) is met by the 181-test combined run, which includes the invite_composer suite.

## Findings

1. **LOW — the duplicate-denylist scan probes 7 of ~40 terms, `lib/` only.**
   `only invariant_terms.dart declares denylisted terms` (test:164-194) checks
   the probe list `thả thính, điểm số, xếp hạng, chuỗi ngày, hoạt động lần cuối,
   tần suất, xứng đáng`. A *partial* second denylist built only from untested
   terms (`phần trăm`, `score`, `rank`, `cư xử`, …) would pass, and a copy under
   `test/` or in an asset is out of the scan's reach entirely. The rule the
   phase actually wants — "exactly one declaration site" — would be better
   expressed by iterating `invariantDeniedTerms.values` and
   `notebookBoundaryTerms.values` instead of a hand-copied probe list, which
   would also make the probe list self-maintaining as terms are added. Not a
   blocker: the realistic failure mode (someone copies the whole map next to a
   new package family) is caught today.

2. **LOW — map disjointness is a comment, not an assertion.**
   `invariant_terms.dart:86-88` states `notebookBoundaryTerms` is "Disjoint from
   `invariantDeniedTerms` by construction". I verified the two maps are in fact
   disjoint today. But in a phase whose whole thesis is "invariant rules are a
   runnable gate, not an editorial convention", this one invariant is enforced
   editorially. A duplicated term would produce two violations for one string
   and make one list relaxable without turning the other red. A three-line
   set-intersection test would close it.

3. **INFO — `_requireContentBool` is a local copy of the shared parser helper
   layer.** `context_content.dart:143-156` reimplements a `requireContent*`
   helper because `core/content/content_package.dart` sits outside this phase's
   Write Scope. The dev disclosed this deliberately (`test-results.md` L183-185).
   Correct call under the scope constraint; fold it into `content_package.dart`
   when a phase owns that file, so the parser helper layer does not fork the way
   the denylist just did.

4. **INFO — `editorial_review` is parsed but ungated in this pack family.**
   Also disclosed (`test-results.md` L186-188). `preset_content_gate.dart` has
   `PresetGateRule.editorialReviewIncomplete`; the context gate has no
   equivalent, so a context pack shipped with a missing or half-filled
   `editorial_review` is not rejected. The phase file's §3 and §4 name exactly
   two pack-specific rules and neither is editorial, so this matches the plan —
   flagging it only because the asymmetry between the two gate families is
   invisible from either file alone, and SB-123's two-layer moderation trace is
   a story-level concern the final synthesis should confirm lands somewhere.

## Residual risks (not slice blockers)

- **No runtime caller.** `validateContextPacks` is referenced nowhere in
  `mobile/lib` outside its own definition — the gate runs only from
  `flutter test`. This means (a) BR-18's "breaks the build" is really "breaks
  the test suite / CI", and (b) AC-35's final sentence — *"the gate runs even
  for content supplied by an out-of-repo CMS, i.e. content that never passed
  this repo's review"* — is not yet satisfied, because CMS-supplied content
  would never be on disk at test time. This is **not a regression introduced by
  P2**: `validatePresetPack` has exactly the same shape and shipped that way in
  the merged STORY-002. Final synthesis should confirm whether P3/P5 wire the
  gate into the load path, or record the CMS clause as a known
  requirement-level deferral.
- **Required-seed ordering is not gated.** AC-11 says the four soft skills show
  *before* the user has to type anything. The gate proves they are present; that
  they render first, and ahead of any free-text affordance, is a UI property
  belonging to the P3/P5 slices.

## Scope note for the final synthesis pass

Verified only the 7 files and the AC/invariant ids listed above. AC-32's gift
index, effort scale, and branch labels (P6), the currency gate (P4), R-1g's
closing-question rule (STORY-002), and all rendering behaviour are untouched by
this review.
