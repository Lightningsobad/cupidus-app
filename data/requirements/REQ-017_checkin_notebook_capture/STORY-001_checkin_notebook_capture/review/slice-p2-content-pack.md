# Review Slice P2 — Check-in capture content pack + context content gate

Outcome: PARTIAL_SLICE_ONLY

- Review type: `scoped-slice` (Slice 2 of 4)
- Story: `STORY-001_checkin_notebook_capture` (REQ-017), Complexity `standard`, Lane `shared` (mobile-only in practice)
- Phase under review: P2 — `coding-plan/phase-P2-checkin-capture-content-pack.md`
- Worktree: `story-REQ-017_checkin_notebook_capture-STORY-001_checkin_notebook_capture`
- BaseHead: `0198e32ddd3f8bad6a4d5274fd7b5ebeae9158b1` → HEAD `5841e02c` (diff re-run fresh at this HEAD; no Slice 1 output reused)
- This slice produces NO story outcome. Story closure is decided by the later `final-synthesis` slice.

## Scope Gate

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

- Slice report path: `data/requirements/REQ-017_checkin_notebook_capture/STORY-001_checkin_notebook_capture/review/slice-p2-content-pack.md`
- Source/test files in scope (diffed against BaseHead, numstat at HEAD `5841e02c`):
  - `mobile/assets/data/req017/checkin_capture.v1.json` (+45/-0, new)
  - `mobile/lib/features/context_notebook/domain/checkin_capture_content.dart` (+148/-0, new)
  - `mobile/lib/features/context_notebook/data/checkin_capture_content_repository.dart` (+23/-0, new)
  - `mobile/lib/features/context_notebook/domain/context_content_gate.dart` (+22/-3)
  - `mobile/pubspec.yaml` (+1/-0)
  - `mobile/test/features/context_notebook/checkin_capture_content_test.dart` (+287/-0, new)
  - `mobile/test/features/context_notebook/checkin_capture_content_repository_test.dart` (+80/-0, new)
  - `mobile/test/features/context_notebook/context_content_gate_test.dart` (+76/-1)
- Evidence in scope: `coding-plan/test-results.md` `## P2` (Gates 1-6 + Visual fidelity), `coding-plan/phase-P2-checkin-capture-content-pack.md` §1B/§3/§4/§6/§7, `coding-plan/master-plan.md` §3A/§5, `story_master.md` AC-3/AC-9/AC-14/AC-15 + BR-1/BR-6, `ux/uiux-spec.md` Phần D (lines 157-167 only)
- Touched risk surfaces: RS-4 content ingestion gate (AC-14/R-15c). Typed/generated contract (pack schema + parser), local asset/offline content load, configuration (`pubspec.yaml` asset dir).
- Critical gates for this slice: parser rejection proof for every malformed shape; gate attribution proof (a violating pack produces a `ContextViolation` carrying the REQ-017 `packageId`); disk scan of the shipped pack; AC-14 wording scan over `lib/**`; analyze delta. All five present and green.
- Out of slice: P1 persistence layer (Slice 1, accepted), all P3 capture UI/cubit wiring, all P4 label rendering, `zodiac_shell_resolver.dart`.

## Verdicts

| Id | Claim in scope | Verdict | Evidence |
|----|----------------|---------|----------|
| P2-A1 | No wording this story authors lives in ARB/l10n or a Dart constant (AC-14, BR-5) | PASS | `checkin_capture_content_test.dart:66-91` walks every `.dart`/`.arb` under `lib/` recursively and asserts zero `source.contains(copy.text)` hits, plus `expect(authored, isNotEmpty)` so the scan cannot pass vacuously. Only ids live in Dart (`checkin_capture_content.dart:16-40`); every string lives in the asset. Scan scoping reviewed under F-4 |
| P2-A2 | Grading/scoring wording in the pack turns the gate red, attributed to the REQ-017 pack (BR-1, R-1f) | PASS | `context_content_gate.dart:78-93` runs `_invariantViolations` + `notebookBoundaryHitsIn` over every `CheckinCaptureCopy.text`; `context_content_gate_test.dart` group `the check-in capture pack is gated too (REQ-017 AC-14)` proves `'Điểm số hôm nay của người ấy?'` yields a violation with `packageId == 'req017.capture.fixture'`, `rule == scoreOrRatio`, `itemId == checkin.capture.question.v1` — this is the exact `§6 Required assertion evidence` the phase demanded, including the pack attribution. `'Người ấy nhắn bao lâu một lần?'` → `frequencyProbe`, so the notebook boundary is guarded on capture copy, not only on ask questions. test-results Gate 3 `+31`, exit 0 |
| P2-A3 | Only the named-card origin item declares `{card}`; the fallback item is parameterless and resolves correctly | PASS | Asset: `notebook.origin.with_card.v1` carries `"params": ["card"]`, the other eight declare none; `checkinCaptureItemParams` (`checkin_capture_content.dart:44-47`) whitelists the parameter for that one id only, so "absent from this map" means "takes none". Tests `only the named-card origin label declares a parameter` (asserts `isEmpty` for all others), `a readable card title resolves {card}` (`isNot(contains('{'))`), `the degraded line carries no placeholder` |
| P2-A4 | A malformed pack fails loudly instead of being silently skipped | PASS | Eight rejection paths proven in `checkin_capture_content_test.dart:138-285`, each asserting on the exception *message* not just the type: duplicate item id, missing `id`, missing `text`, parameter an item does not support, parameter nothing supports, placeholder used but undeclared, parameter declared but never used, and wrong `schema_id`. The parser enforces both directions of the declared/used relation (`checkin_capture_content.dart:82-110`), which is stricter than the phase asked for. `CheckinCaptureCopySet.text()` throws on an unknown id rather than returning `''` (test `an unknown copy id is an error, not an empty string`) |
| P2-A5 | No export/share capability added to the pack or the repository (AC-15) | PASS | `CheckinCaptureContentRepository` exposes only `load()`; `CheckinCaptureCopySet` exposes only `text(id)` and `originLabel(cardTitle:)`. No serialize/share/export member in either new file, and the asset holds no export copy item |
| P2-INV1 | The pack is well-formed and version/schema-gated as the domain layer expects | PASS | Asset carries `id`/`version`/`schema_id`/`locale`/`items`; the repository passes `expectedSchemaId: checkinCaptureSchemaId` (`req017.checkin_capture.v1`) so a pack authored under another schema id is rejected at load, proven by test `a pack under another schema id`. The `.v1` suffix appears in the schema id, the asset filename and the item ids, so a v2 family can ship beside this one without collision |
| P2-INV2 | Every copy item UX Phần D names exists as a durable id | PASS | `uiux-spec.md:159-163` names the question, "Tuỳ chọn", the kind-required hint line, both origin label forms, and the error/retry lines. All seven are present in `requiredCheckinCaptureCopyIds`, which additionally carries the two kind labels — a superset of Phần D, not a subset. Enforced by test `exists and carries every copy id UX Part D names`, which loops the constant list against the pack read from disk |
| P2-INV3 | Tests assert against parsed content, not copy-pasted literal copy | PASS | `checkin_capture_content_test.dart` and `checkin_capture_content_repository_test.dart` both read the real asset (`File(checkinCaptureAssetKey).readAsStringSync()`) and compare through `copy.text(id)` / `itemById(id)`; the AC-9 degrade assertions compare `originLabel()` against `copy.text(notebookOriginFallbackId)` rather than against a retyped Vietnamese string. The one literal — the question wording as the default of `_capturePack(...)` in the gate test — is a deliberate clean-copy control fixture, and it is not the thing that guards the shipped wording: `the packs on disk report no violation` does that from disk |
| P2-INV4 | The gate scans `assets/data/req017/` from disk alongside the two REQ-016 packs, with no cross-pack leakage | PASS | `validateContextPacks` now takes a required `checkinCapture:` package; `context_content_gate_test.dart` parses all three from disk, asserts all three exist and are non-empty, and asserts the combined violation list is empty. Test `clean capture copy leaves the other two packs clean` closes the leakage direction. Gate doc comment updated to name both asset dirs, so the contract text matches the behavior |
| P2-INV5 | The asset directory is wired into `flutter.assets` (closes Slice 1 finding N-1) | PASS | `pubspec.yaml` `+ - assets/data/req017/` under `flutter.assets`; the JSON sits directly in that directory, so the directory-form declaration covers it. `master-plan.md` §1 already attributed this line to P2, and the repository test loads the key through a real `CachingAssetBundle` subclass, so the bundle key and the declared path are the same string |
| P2-INV6 | The content path is asset-only, cached, and fails loudly | PASS | `CheckinCaptureContentRepository` holds an injected `ContentPackageLoader` and no HTTP client or model call. `_cached ??=` gives one parse per instance, proven by `expect(await repository.load(), same(await repository.load()))`. A malformed asset throws `ContentPackageFormatException` and a missing asset throws rather than degrading to an empty pack (R-15a) |
| P2-INV7 | The required-param signature change broke no `validateContextPacks` call site | UNVERIFIED | test-results Gate 3 reports 0 `lib/` call sites and 5 test call sites updated, and the diff confirms all 5 in-file updates. The suites that actually compiled are green (`test/features/context_notebook` `+130 ~4`; `test/core/database` `+106`; four files across `compatibility_lookup`/`activity_cards`/`your_view_portrait` `+74`). A caller in a test directory none of those runs compiled would not have surfaced. See F-6 for the exact missing evidence key; residual risk is low |
| P2-INV8 | Static analysis clean on P2's files | PASS | test-results Gate 4/Gate 6: `flutter analyze --no-pub` over the three `lib/` and three `test/` files → `No issues found!`, exit 0. File-scoped deliberately, because the repo-wide analyze baseline is non-zero by design (222 warnings, 0 errors), so a repo-wide exit code proves nothing here. One self-inflicted `unnecessary_import` was fixed and re-run |

No FAIL in this slice. One UNVERIFIED (P2-INV7, low risk, evidence key named in F-6). No blocking finding.

## Findings

### F-4 — DEFERRED (cross-slice, the P3 slice must close it)
The AC-14 wording scan deliberately excludes four ids —
`_genericAppVocabularyIds` in `checkin_capture_content_test.dart:17-28`:
`optional_label`, `kind.interest`, `kind.event`, `retry`. The exclusion is
correct and it is measured, not guessed: test-results Gate 4 records a
throwaway diagnostic run over all nine items reporting 21 collisions, every one
of them on those four items, already present in `lib/l10n/arb/app_vi.arb`,
`lib/l10n/generated/` and ten unrelated screens. Scanning them would assert a
collision REQ-017 never caused, which is a false assertion rather than a
stricter gate.

The consequence is what matters downstream: for exactly those four items there
is now NO gate that can detect the capture UI rendering l10n or a hardcoded
literal instead of the pack. The two kind labels are the sharpest case — a chip
widget hardcoding "Sở thích"/"Sự kiện" would look correct, satisfy AC-3's
"user picks the kind" behavior, and still defeat AC-14's intent, with every
test in this slice still green. The P3 slice must confirm the capture block
resolves all four through `CheckinCaptureCopySet.text(...)`. Not raised against
P2: P2 shipped the items correctly and cannot control who reads them.

### F-5 — DEFERRED (observation, gate asymmetry)
Required-id presence for the capture pack is enforced only in test code (test
`exists and carries every copy id UX Part D names`), while the sibling rule for
skill seeds is enforced inside production code — `context_content_gate.dart`
still carries its `for (final String requiredId in requiredSkillSeedIds)` loop
and no equivalent loop was added for `requiredCheckinCaptureCopyIds`. Protection
is equivalent today, because the pack ships in-repo and the test reads it from
disk, so a missing id cannot reach a device without turning the suite red; a
missing id would otherwise surface only when `CheckinCaptureCopySet.text()`
throws on the screen that needs it. The asymmetry becomes real only if a pack
source ever stops being a repo asset. Not a patch item for this story.

### F-6 — UNVERIFIED (low risk, evidence key for final synthesis)
`validateContextPacks` gained a REQUIRED named parameter, so every caller had to
change in the same commit. The claim that no caller exists outside the updated
test file is plausible and unchallenged — the symbol is a
`features/context_notebook/domain` export introduced with its own suite in
REQ-016 — but the runs on record compiled only `test/features/context_notebook`,
`test/core/database` and four named files elsewhere. Exact missing evidence key:
a compile or `flutter analyze` pass covering `test/` outside
`test/features/context_notebook`. Deliberately not re-run here: the repo's
analyze baseline never exits 0, so an exit code from that command would not be
readable as a verdict, and a broad test run is the story-level build evidence
the final synthesis already owns. Close it there, or accept the residual.

## Traceability

- Requirements: `story_master.md` AC-14 (P2-A1, P2-A2, P2-INV2, P2-INV4 — the pack passes through the STORY-004 AC-36 intake gate), AC-3 content half (the two kind labels + `kind_required_hint` exist as data items; the "app does not guess the kind" behavior is P3), AC-9/BR-6 content half (`originLabel` degrade, P2-A3 — the rendering half is P4), AC-15 (P2-A5), BR-1/R-1f (P2-A2). The phase file's §1B citations `AC-3/AC-14/AC-15/BR-1/BR-5` index the requirement-level `../requirements/requirements.md`; the ids verified above are the story-level `story_master.md` ones plus `uiux-spec.md` Phần D, which names BR-5 as the content-as-data rule.
- Phase §4 acceptance list maps 1:1 onto P2-A1..P2-A5; all five PASS.
- Architecture: `architecture/solution.md` §1 KD-3 and §4 as cited by the phase — `validateContextPacks` remains the single intake gate, rules live only in Dart and wording only in the asset. Verified: the new gate branch adds no rule to the asset, and `checkin_capture.v1.json` carries no rule/validation field.
- UX: `uiux-spec.md` Phần D (lines 157-167) — both bullets satisfied: every named item is a durable id (P2-INV2), and `<tên thẻ>` is a content parameter resolved in `CheckinCaptureCopySet.originLabel`, never hand-concatenated at the UI layer (P2-A3). The Phần D requirement that grading/scoring content breaks the build is P2-A2.
- OQ discipline: `story_master.md` `## Open Question Impact` records no blocked scope (OQ-1, OQ-2, A-5 all RESOLVED 2026-09-27). Nothing in this slice implements blocked scope or omits unblocked scope.
- Configuration guide: phase §1B `Update Required: NO`; `master-plan.md` §1 records the asset-dir line as the story's only configuration change and explicitly `NOT_APPLICABLE` for a guide update (no env var, no secret, no third-party). Nothing owed.
- Runtime startup smoke: phase §1B `Startup Smoke: NOT_APPLICABLE` — P2 is data, parser and repository. The story-level mobile launch smoke (rule 12g) belongs to the final synthesis.
- Visual fidelity: phase §6 and test-results record `NOT_APPLICABLE` for P2 — it renders no screen. Story-level `visual-fidelity/` evidence for `23h-vua-ve-j8` (P3) and `2-so-tay-nguoi-yeu` (P4) is out of this slice.
- Evidence hygiene: test-results Gate 5 records `git status --porcelain` identical byte-for-byte before and after the suite run, which is the check that `visual_capture_test.dart` in this suite did not rewrite another story's visual-fidelity PNGs.

## State recommendation

None from this slice. `Outcome: PARTIAL_SLICE_ONLY` — P2 contributes no blocking
finding. Carry F-4 into the P3 slice as a required check, F-6 into the final
synthesis as the one open evidence key, and F-5 as a deferred note.

REVIEW_SLICE_COMPLETE: YES
