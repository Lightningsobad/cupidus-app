# Slice Review: STORY-011 — P1 Content Pack And Gate

Outcome: PARTIAL_SLICE_ONLY

Review type: `scoped-slice` (slice 1 of 4). This verdict scopes ONLY phase P1.
Story closure belongs to the later fresh final-synthesis pass.

- Scope gate: `review/scope-gate.md`
- Diff baseline: `git -C <Worktree> diff f91e9c15 731084ab`
- Blocking findings: 0
- Deferred findings: 3

## Acceptance Criteria — phase P1 §4

| # | Acceptance criterion | Verdict | Evidence |
|---|----------------------|---------|----------|
| 1 | Both packages parse under the right `expectedSchemaId`; a wrong one throws `ContentPackageFormatException` | PASS | Assets carry `"schema_id": "req016.zodiac_quiz.v1"` / `"req016.zodiac_outcomes.v1"` (line 4 of each), matching `zodiacQuizSchemaId` / `zodiacOutcomesSchemaId` in `zodiac_shell_content.dart:12,15`. `content_package.dart:81-85` compares and throws. Tests `zodiac_shell_content_test.dart:140,145`. |
| 2 | Gate throws on: `%`, `about_other` with an ask line that does not close as a question, fewer than 3 suggestions, a question measuring the other person, `mapping` pointing at a missing `outcome_id` | PASS | `validateZodiacPacks` covers all five: `%` via `invariantHitsIn` on `insight`/`ask_line`/`suggestions[].title`/`.note` (gate:183-257); AC-15 pair via `starterStructureHitsIn` (gate:198-225, structural `?`/`？` check at `invariant_terms.dart:209-217`); pool floor at gate:227-235; input probes via `notebookBoundaryHitsIn` on `questions[].prompt` (gate:128-136); cross-reference on both `mapping[].outcome_id` and `fallback_outcome_id` (gate:139-158). One control test per rule: gate test lines 265, 279, 299, 311, 325, 365, 384, 507, 603, 610, 617. `assertZodiacPacksClean` raises (gate:274-285, test:651). |
| 3 | No item-count constant in code; every count reads `ContentPackage.length` | PASS | Repo-side grep over `lib/features/zodiac_shell/` finds no seed-count literal; the only `3` is `minimumSuggestionsPerOutcome` (gate:79), documented and verified as the BR-2 *layout* contract, not N. Parser tests prove N=1 and N=7 both read through `length` (content test:196,200,210,226); source scan test at gate test:698. |
| 4 | No `http`/`dio`/API client import under `features/zodiac_shell` | PASS | Grep for `package:http`, `package:dio`, `dart:io`, `HttpClient`, `ApiClient` over `lib/features/zodiac_shell/` returns nothing. In-repo source scan test at gate test:675, with a negative control at :686 proving the scan can fail. |

## Contract invariants this slice owns (§3A risk surfaces)

| Risk surface | Verdict | Evidence |
|--------------|---------|----------|
| Cổng nhập nội dung | PASS | Gate runs over the REAL bundled assets, both directly and through `ContentPackageLoader` (gate test:207,217), plus a violating fixture per rule. |
| N là thuộc tính dữ liệu (R-15b/AC-31) | PASS | `ZodiacQuizSet.questions` / `ContentPackage.length` only; N=1 and N=7 fixtures both parse. `questions_per_round` is range-checked against `questions.length`, not a constant (gate:105-114). |
| Giọng R-1e/R-1g ở đầu ra | PASS | Lexical layer fully delegated to `core/content/invariant_terms.dart`; `ZodiacGateRule` mirrors all three source enums by wire value, with a no-`orElse` `firstWhere` so a missing member is a loud `StateError` rather than a silent miss (gate:301-314). |
| Ngoại tuyến / không AI (AC-22/AC-23) | PASS | Static asset bundle only; no transport import, no network call, no runtime AI surface. Confirmed by grep and by the in-test source scan. |

## Test evidence (test-results.md §P1, lines 33-107)

| Gate | Verdict | Note |
|------|---------|------|
| Targeted unit `flutter test test/features/zodiac_shell/` 67/67 PASS | PASS | Test-name inventory read directly; the claimed coverage matches the actual `test(...)` bodies rule by rule. |
| Regression `flutter test test/core/content/` 15/15 PASS | PASS | `content_package.dart` was reused verbatim — the P1 diff touches no file under `lib/core/content/`. |
| Scoped `flutter analyze lib/features/zodiac_shell test/features/zodiac_shell` — `No issues found!` | PASS | Scoping to the write scope is legitimate here: the repo-wide baseline is non-zero (0 errors), so only the delta is meaningful. Delta = 0. |
| Per-story visual fidelity | NOT_APPLICABLE (this slice) | P1 ships data + domain only and renders no widget. The design reference `design-reference-7-vo-hoang-dao-3-viec-ios.png` was resolved and committed in this range (design side only); the implemented capture and `VISUAL_FIDELITY:` verdict belong to P3 and to the story-level synthesis. Writing no verdict token here is correct, not an omission. |
| Runtime startup smoke | NOT_APPLICABLE (this slice) | Phase §1B/§6 record `Startup Smoke: NOT_APPLICABLE` / `Runtime startup smoke: NO`; the story-level mobile smoke gate is the synthesis pass's to enforce. |
| Entry point reachability | NOT_APPLICABLE (this slice) | Owned by P4; do not read this slice as evidence for it. |

## Deferred findings

**D-P1-1 — `contract-summary.md` §1/§2 still sketches the envelope key as
`"schemaId"`, and its named consumer is an out-of-repo CMS.** The deviation
recorded in `test-results.md` is correct and I confirm the reasoning: the same
§1 mandates reusing `content_package.dart` verbatim, and `ContentPackage.parse`
reads `schema_id` (`content_package.dart:81`), so the sketch's camelCase cannot
be the wire form; the §2 schema-id *values* are matched exactly. The
implementation is right and the architecture doc is what is stale. This is
deferred rather than blocking because it changes no shipped byte — but it is
not cosmetic: a CMS exporter written against §1 would emit `schemaId` and throw
at load. Owner: Tech Lead — correct §1/§2 to `schema_id`. Out of this phase's
write scope, so it could not be fixed here.

**D-P1-2 — the time-gating key scan covers item keys only; envelope root keys
are invisible to it.** `collectJsonKeys` is called on the ITEM map in both
parsers (`zodiac_shell_content.dart:290,320`), and `ContentPackage` keeps only
`id`/`version`/`schemaId`/`items` (`content_package.dart:41-44`) — no raw
envelope is retained. So a root-level `"daily": true` alongside `"items"` would
be ignored by the parser and never reach `_timeGatingViolations`. Not
hypothetical: the shipped quiz package already carries a root key nothing reads
(`"locale": "vi"`, line 5), which shows the envelope does accept unknown root
keys. Phase §3 scopes the rule to "bất kỳ mục nào" (any ITEM), so the code
matches its task and both shipped packages are clean (0 hits for all five
keys) — but the dartdoc on `zodiacTimeGatingKeys`
(`zodiac_shell_content.dart:22-23`) claims rejection "anywhere in either
package, at any depth", which overstates what runs. Owner: Mobile Developer —
either narrow that comment or extend the scan to the envelope. Prefer extending
it, since the CMS is out of repo.

**D-P1-3 — phase §3's input-layer task text ("dùng danh sách từ khoá riêng của
gate này") contradicts R-15c and is the stale side.** The gate instead delegates
to `notebookBoundaryHitsIn`, and gate test:732 actively asserts the feature
declares no second denylist. The §4 acceptance criterion only requires the
behaviour, which is met (frequency / behaviour / judgement probes all rejected,
tests :603/:610/:617), and a per-feature keyword copy would be the regression
R-15c/D-15 exists to prevent. Recording so the final synthesis does not read the
phase text as an unmet task. Owner: Tech Lead — align the phase §3 wording.

## Traceability

- Requirements: AC-29..AC-34, BR-12/BR-13/BR-14 via phase §1B Primary Inputs;
  AC-4/AC-12/AC-13/AC-14/AC-15/AC-18/AC-19/AC-20/AC-22/AC-23 cited at the
  assertion sites listed above.
- OQ discipline: OQ-3 closed 2026-09-06 by D-15 → R-15a/b/c are binding
  constraints, not open questions. All three are implemented as runtime-checked
  rules, not prose. No unresolved OQ touches this slice.
- Architecture: `contract-summary.md` §1-§6 — honoured, with D-P1-1 the one
  doc-side divergence.
- Configuration guide: phase §1B records `Update Required: NO`; this slice adds
  no env var, credential, service, or manual setup step. Confirmed — the change
  is an asset bundle plus pure Dart domain code.

## Recommendation

No P1 finding blocks the story. Carry the three deferred items into the
story-level final synthesis; none of them, alone or together, is grounds to
return P1 to the mobile lane. The story's own outcome still depends on slices
P2-P4 and on the story-level mobile gates (runtime startup smoke, entry point
reachability, implemented visual fidelity), which this slice deliberately does
not judge.
