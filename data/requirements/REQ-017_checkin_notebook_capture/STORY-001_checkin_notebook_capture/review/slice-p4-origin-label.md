# Review Slice P4 — Origin label on the notebook screen, its degrade, and its non-leak boundary

Outcome: PARTIAL_SLICE_ONLY

- Review type: `scoped-slice` (Slice 4 of 4)
- Story: `STORY-001_checkin_notebook_capture` (REQ-017), Complexity `standard`, Lane `shared` (mobile-only in practice)
- Phase under review: P4 — `coding-plan/phase-P4-notebook-origin-label.md`
- Worktree: `story-REQ-017_checkin_notebook_capture-STORY-001_checkin_notebook_capture`
- BaseHead: `0198e32ddd3f8bad6a4d5274fd7b5ebeae9158b1`
- This slice produces NO story outcome. Story closure is decided by the later `final-synthesis` slice.

## Scope Gate

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

- Slice report path: `data/requirements/REQ-017_checkin_notebook_capture/STORY-001_checkin_notebook_capture/review/slice-p4-origin-label.md`
- P4's implementation commit, derived first rather than assumed: `8ac87d88`
  (`git -C <Worktree> log --format='%h|%s' <BaseHead>..HEAD` then `git show --numstat 8ac87d88`).
- Source/test files in scope (real paths, from `git show --numstat 8ac87d88`):
  - `mobile/lib/features/context_notebook/domain/checkin_origin_resolver.dart` (+56/-0, new)
  - `mobile/lib/features/context_notebook/presentation/screens/notebook_screen.dart` (+111/-12)
  - `mobile/test/features/context_notebook/checkin_origin_resolver_test.dart` (+298/-0, new)
  - `mobile/test/features/context_notebook/notebook_screen_test.dart` (+269/-0)
  - `mobile/test/features/context_notebook/origin_label_visual_capture_test.dart` (+207/-0, new)
  - `mobile/test/features/gift_ideas/gift_repository_test.dart` (+57/-0)
- **Handoff path correction (O-1): NONE REQUIRED.** All six paths the handoff offered as a best guess
  exist and are exactly the six source/test files in `8ac87d88`. Unlike Slice 3's handoff (which had
  3 of 5 paths wrong, recorded as that slice's O-1), this handoff's guessed set is the real set. It
  was still derived from the diff before use, not taken on trust.
- Artifact/evidence files also carried by `8ac87d88` (in scope as evidence, not as reviewed code):
  `coding-plan/master-plan.md` (+1/-1), `coding-plan/phase-P4-notebook-origin-label.md` (+7/-1),
  `coding-plan/test-results.md` (+161/-0), `scrum-master-checkpoint.md` (+8/-5),
  `visual-fidelity/visual-fidelity-report.md` (+112/-2), and three PNGs
  (`design-reference-2-so-tay-nguoi-yeu-ios.png`,
  `implemented-2-so-tay-nguoi-yeu-origin-ios.png`, `implemented-2-so-tay-nguoi-yeu-origin-md.png`).
- All six source/test paths fall inside P4's declared Write Scope (phase §1B:19-23). No scope
  extension was needed or taken; phase §7:142-144 records why `context_notebook_entry_point.dart`
  did not have to be touched, and the diff confirms it was not.
- Evidence in scope: `coding-plan/test-results.md` `## P4` (Gates 1-6, lines 627-787),
  `coding-plan/phase-P4-notebook-origin-label.md` §1B/§3/§4/§6/§7,
  `coding-plan/master-plan.md` §3A/§5, `story_master.md` AC-4/5/9/10/11/13/15 +
  BR-6/BR-7/BR-11 + `## Open Question Impact`, `ux/uiux-spec.md` Phần C and Phần E,
  `visual-fidelity/visual-fidelity-report.md` Phần II.
- Touched risk surfaces: RS-5 Origin label degrade (AC-9/BR-6); RS-6 Notebook consumer
  non-regression (BR-11, AC-10/AC-13). `master-plan.md` §3A:31-32 maps both to **P1, P4** — which is
  why the AC-13 verdict is owed here and was correctly declined by Slice 3 (its O-2).
- Out of slice (not reviewed): all P1/P2/P3 source and their sealed slice reports; the check-in
  sheet, the capture block and the content-pack ingestion gate; `recordFromCheckIn`'s transactional
  behaviour (P1); story-level launch smoke; the `23h-vua-ve-j8` fidelity pair (Phần I, P3's).

## Verdicts

| Id | Claim in scope | Verdict | Evidence |
|----|----------------|---------|----------|
| P4-A1 | A check-in row lands in the existing "Sở thích"/"Sự kiện" group with the label "từ buổi hẹn \<tên thẻ\>"; no third group is created (AC-4) | PASS | Grouping is untouched by P4 — `groupNotebookEntries` still keys on `entry.kind` and the screen still iterates `notebookGroupOrder`, so an `event` check-in row reuses the shipped group. `notebook_screen_test.dart`:560-596 asserts the row is a descendant of `notebook-group-event` **and** counts group `Column`s with a `notebook-group-` key prefix, asserting exactly 2. The label text is compared against `_shippedCopy.originLabel(cardTitle: 'Đi cà phê tối')` (test:572 region and :645-655), not a hand-typed string |
| P4-A2 | An unreadable card degrades the label to "từ một buổi hẹn"; the row still renders in full and stays editable/deletable (AC-9, BR-6) | PASS | `CheckinOriginResolver.labelsFor` (`checkin_origin_resolver.dart`:43-54) computes `stillThere = cardId != null && readable.contains(cardId)` and passes `cardTitle: null` otherwise, so the fallback is the only path. Four branches are unit-covered: card readable (:49-74), title snapshot `null` (:76-93), card id not readable (:95-114), probe throws (:116-134), plus check-in row with no card id at all (:205-216). Widget level: `notebook_screen_test.dart` asserts the fallback string for the unreadable-card case and adds `expect(find.textContaining('Đi cà phê tối'), findsNothing)` — the stale title does not survive the degrade |
| P4-A3 | A probe failure never reaches the screen (KD-2) | PASS | `try/catch (_) { readable = const <String>{} }` at `checkin_origin_resolver.dart`:36-41, and the production probe swallows per-card read errors at `notebook_screen.dart`:346-350. Widget test asserts `tester.takeException()` is `null` after a throwing probe and that the fallback still rendered |
| P4-A4 | Editing the text takes effect immediately and the label wording is unchanged; deleting removes the row through the existing flow with no extra dialog (AC-5, partial — see F-7) | PASS (partial) | Edit: test:624-656 drives menu → "Sửa" → `enterText` → save, then asserts `repository.entries().single.value == 'Cà phê không đường'` **and** that the origin `Text` still reads `_shippedCopy.originLabel(cardTitle: 'Đi cà phê tối')`. Delete: test:658-680 asserts `find.byType(AlertDialog) findsNothing`, the origin key gone, and `entries()` empty. The "đổi loại" half of AC-5 is **not** implementable on this surface — see F-7 |
| P4-A5 | A row the user added themselves has no label line at all (BR-11) | PASS | `labelsFor` `continue`s on `entry.originCheckInRef == null` (`checkin_origin_resolver.dart`:45-47) so manual ids are absent from the map; `_NotebookRow` renders the line only `if (label != null)` (`notebook_screen.dart`:422-428). Unit: resolver returns `isEmpty` for a manual-only list (:136-147). Visual: "Đi bộ ven hồ" and "Sinh nhật" carry no origin line in both captures |
| P4-A6 | The gift surface shows the entry text but never the origin label or card title (AC-10) | PASS | `gift_repository_test.dart`:289-315 writes via `recordFromCheckIn(cardId: 'card-1', cardTitle: 'Đi cà phê tối')`, then asserts `context().values.single.key == label == 'cà phê muối'` and that the concatenation of both fields contains neither `'Đi cà phê tối'` nor `'checkin-2026-09-27'`. This also proves the positive half of AC-10 — a check-in row **is** consumed like any other (`values hasLength(1)`). Backed by a source scan over `_giftSourceFiles()` for eight origin tokens (:316-341) |
| **P4-A7** | **STORY-012's widget and notification can never show an entry value or the origin label (AC-13, BR-7)** | **PASS** | Three independent legs, all verified directly rather than from the checkpoint note. (1) Static scan, `checkin_origin_resolver_test.dart`:228-265: reads `home_widget_bridge.dart` and `local_notification_scheduler.dart` off disk and fails on any of ten tokens (`NotebookEntry`, `ContextNotebookReader`, `context_notebook`, the three `origin*` columns, `originLabel`, `CheckinOriginResolver`, and both wording ids). It is guarded against silent vacuity by `expect(file.existsSync(), isTrue)` with a stated reason. (2) Wording containment, same file :267-296: walks all of `lib/` recursively, skips `lib/features/context_notebook/`, and fails on either origin wording id anywhere else. (3) **Type closure, derived by this review, not asserted by the tests:** the widget payload cannot carry free text from any caller — `pushWidgetPayload(PhaseResolution)` (`home_widget_bridge.dart`:177) is invoked from exactly one place, `phase_status_cubit.dart`:171, with a typed `PhaseResolution`; the public `writeHomeWidgetPayload(Map<String,String>)` (:213) has exactly one production caller, the default `_writer` at :169. No call site exists through which notebook data could be injected. Leg 3 is what closes the gap a token scan alone would leave |
| P4-A8 | No export/share affordance and no "xem buổi hẹn gốc"; the "..." menu still holds exactly Sửa/Xoá (AC-15, BR-9) | PASS | The `"..."` menu is untouched by the diff. test:598-622 asserts `findsNWidgets(2)` `PopupMenuItem` plus both labels, with `expectNoBannedSurfaces()`. The label subtree is asserted to contain no `InkWell`, and `find.textContaining('checkin-2026-09-27')` is `findsNothing` — the check-in reference itself never reaches the screen. Reinforced at the type level: `ReadableCardProbe = Future<Set<String>> Function(Set<String>)` returns ids, never cards, so no surface can obtain a card object to render from |
| P4-A9 | The label is content, never a hardcoded string, and `<tên thẻ>` is a content parameter rather than a UI-layer concatenation (AC-14, UX Phần D) | PASS | The only construction site is `CheckinCaptureCopySet.originLabel` (`checkin_capture_content.dart`:140-147), which does `text(notebookOriginWithCardId).replaceAll('{card}', title)` and falls back to `text(notebookOriginFallbackId)` on a null/blank title. The resolver calls it; the row widget receives a finished `String?` and cannot reach a card title. All three test files parse the shipped `assets/data/req017/checkin_capture.v1.json` through `ContentPackage.parse(..., expectedSchemaId:)` rather than restating the wording |
| P4-A10 | The probe runs once per screen load, not once per row (phase §3) | PASS | `_load()` resolves entries and labels together (`notebook_screen.dart`:101-104) and `_originLabels` short-circuits to `{}` when no row has an origin (:108-114). `labelsFor` builds one distinct `Set<String>` of card ids and awaits `probe` at most once (:28-41). test:149-185 counts calls (`expect(calls, 1)`) and asserts the set is exactly `{'card-1','card-2'}` from four rows sharing two cards; test:187-203 asserts zero calls when no row came from a check-in. The production probe still issues one `cardById` per **distinct card**, which is per-card and not per-row as the plan requires; the code comment at :338-341 declares this and names the missing batch read as the reason |
| P4-A11 | Deleting a notebook entry does not touch the journal or photos, and vice versa (AC-11) | PASS (vacuous precondition — see O-5) | `_delete` calls only `repository.deleteEntry(id)` → `ContextNotebookDao`; nothing in the P4 diff reaches journal or photo storage. The converse half of AC-11 has no reachable trigger: `grep -rn -e deleteJournal -e clearJournal -e deleteJournalEntry lib test` returns **no matches**, so no journal-deletion capability ships today and nothing can break the notebook row |
| P4-INV1 | The card store is read-only from this path (BR-6) | PASS | `_probeReadableCards` (`notebook_screen.dart`:343-355) calls only `ActivityCardRepository.cardById` and writes nothing; the typedef's doc comment states the set shape is deliberate so a probe result can never be rendered as a card. No `activity_cards` write appears anywhere in the diff |
| P4-INV2 | An unreadable content package degrades safely rather than failing the screen | PASS | `_originLabels` wraps `_originContent.load()` in `try/catch` and returns `{}` (`notebook_screen.dart`:116-123), so every row simply loses its label. This is the correct call and not an AC-9 miss: AC-9's degrade is *card* unreadability, and with no authored wording loaded there is no legal string to show — hardcoding one would break AC-14. Same shape as P3-INV4, which Slice 3 passed |
| P4-INV3 | Existing notebook behaviour is not regressed (BR-11, RS-6) | PASS | The `_NotebookRow` change is purely additive (one `if (label != null)` `Text`); `_add`, `_update`, `_delete` and the group header are unchanged. Gate 5 runs both in-scope suites green: `test/features/context_notebook` `+148 ~5` exit 0 and `test/features/gift_ideas` `+103 ~1` exit 0. The `~` skips are the `skip: !kCaptureVisuals` capture tests. The `context_notebook` import-boundary guard ran inside that pass and stayed green; the two new imports (`core/di/service_locator.dart`, `activity_cards/domain/activity_card_repository.dart`) point outward from the feature, the direction the guard does not police |
| P4-INV4 | Visual fidelity for `2-so-tay-nguoi-yeu` passes, and the gate was actually live | PASS | Re-run by this review: `python3 .claude/hooks/lib/visual_fidelity.py --dir <story dir> --stage review --stack mobile` → exit 0. **Independent negative control by this review** (not a re-read of the developer's): the same two PNGs plus the report were copied to a temp dir with the implemented file renamed `implemented-origin-label-wrong-name.png` → exit 1, `no screen has BOTH renders ... running-app renders exist for ['origin'] and design renders for ['2']`. The gate pairs on the first token after the prefix and is genuinely inspecting. Both PNGs were opened and looked at, not merely exit-code-checked — see Observations |

## Resolution of carried-forward findings

### F-4 (kind-selector chip labels) — CLOSED, not a defect

The two chip labels are package reads, as Slice 2 and Slice 3 implied. Exact source, now named:
`mobile/lib/features/phase_status/presentation/widgets/checkin_capture_block.dart`:119
`label: copy.text(checkinCaptureInterestKindId)` and :123 `label: copy.text(checkinCaptureEventKindId)`.
A repository-wide search for both constants returns only the declarations
(`checkin_capture_content.dart`:19-20, and :33-34 in the required-id list), the entry-point `show`
list (`context_notebook_entry_point.dart`:40-41), and those two call sites. No `l10n` call and no
Dart literal supplies either chip. P3's review is not re-derived beyond this citation.

### F-6 (`validateContextPacks` gained a required `checkinCapture` param) — CLOSED, not blocking

`grep -rn "validateContextPacks" mobile/lib mobile/test` returns exactly **eight** lines: the
declaration at `mobile/lib/features/context_notebook/domain/context_content_gate.dart`:50 and seven
references inside a single file, `mobile/test/features/context_notebook/context_content_gate_test.dart`
(:99, :106, :144, :352, :416, :438 — :106 is a helper used by the others).

- There is **no production call site at all**; the function is a build-time invariant runner invoked
  only from its test.
- The one file that calls it lives in `test/features/context_notebook`, which is exactly the suite
  Gate 5 ran green (`+148 ~5`, exit 0). A missing named argument is a compile error in Dart, so a
  green run of that directory is proof every call site supplies `checkinCapture:`.
- **No uncovered call site exists**, so the blocking-if-true condition does not hold. F-6 needs no
  follow-up from final synthesis.

### R-1 (AC-8 "tối đa một mục" residual from Slice 3) — untouched by P4, carries forward unchanged

P4 adds **no write path**. The diff's only repository calls are `entries()` (read) and the unchanged
pre-existing `addEntry`/`updateEntry`/`deleteEntry` on the notebook screen; `recordFromCheckIn` is
not called, referenced, or altered by any P4 file. R-1 therefore reaches final synthesis exactly as
Slice 3 stated it, neither widened nor narrowed by this slice.

## Findings

| Id | Severity | Finding |
|----|----------|---------|
| F-7 | MEDIUM (for final synthesis to classify) | **AC-5's "đổi loại" clause is not implementable on the shipped notebook surface, and nothing in P4 declares the gap.** `story_master.md`:68-70 states "Given người dùng sửa nội dung **hoặc đổi loại** của một mục từ check-in, when lưu sửa, then thay đổi có hiệu lực ngay"; `ux/uiux-spec.md` Phần C:140-141 repeats it; phase P4 §4:86 lists it as an acceptance item. But the capability does not exist end to end: `_update` (`notebook_screen.dart`:145-151) passes only `id`, `value`, `detail`, `eventOn`; `ContextNotebookRepository.updateEntry` (`context_notebook_repository.dart`:158-163) has no `kind` parameter; and the edit-mode `ContextInlineAddRow` (`notebook_screen.dart`:283-292) is constructed **without** `options`/`selectedOptionId`, which only the add-mode row at :301-316 supplies. This is inherited REQ-016 STORY-004 behaviour, not a P4 regression, and P4 could not have added it without violating UX Phần C:137-139 ("y hệt mọi mục khác... không thêm lựa chọn thứ ba"). P4 §3's task list correctly omits it; P4 §4 nonetheless claims it; `test-results.md` `## P4` records no deviation. So the phase file is internally inconsistent and the acceptance claim is unbacked. Two clean resolutions, both outside this slice: treat "đổi loại" as referring to the add-time choice (AC-3) and patch AC-5's wording, or classify the story as incomplete against AC-5. **This slice does not choose.** |

## Observations

- **O-1 (scope gate).** No handoff path correction was required; recorded above for symmetry with
  Slice 3's O-1.
- **O-2.** `ux/uiux-spec.md` Phần C's heading (:122) lists "AC-4, AC-5, AC-9, AC-10, AC-11, AC-15,
  BR-6, BR-11" but its body at :150-152 also governs AC-13/BR-7. The heading's AC list is
  incomplete, which is plausibly what made AC-13's ownership ambiguous enough for it to be deferred
  out of Slice 3. Cosmetic artifact nit; the body is unambiguous.
- **O-3.** `story_master.md`:3 still reads `Status: TODO` and `## Artifacts` still has Implementation
  and Review unchecked. Scrum Master state, not a P4 defect — flagged so final synthesis does not
  inherit it silently.
- **O-4.** `visual-fidelity-report.md`'s Verdict table (rows 2 and 3, :197-198) labels AC-5 as
  "ảnh chụp tên thẻ". AC-5's actual text is the edit/delete behaviour; "nhãn xuất xứ từ buổi hẹn
  \<tên thẻ\>" is AC-4's. The screenshots do evidence AC-4 and AC-9 as claimed, so this is an
  evidence-prose mis-citation only, with no effect on the fidelity verdict.
- **O-5.** AC-11's first half ("xoá một mục nhật ký hoặc xoá toàn bộ nhật ký") has no reachable
  trigger in the shipped app — there is no journal-deletion API anywhere in `mobile/lib`. The AC is
  satisfied vacuously today. Worth recording so a future journal-delete feature knows it inherits an
  untested cross-feature promise.
- **O-6 (visual inspection, done by eye, not by exit code).** Both PNGs opened. No tofu boxes;
  Vietnamese diacritics complete on every string ("Sổ tay người yêu", "Sở thích", "Sự kiện", "Phim
  kinh dị Hàn", "Kỷ niệm quen nhau", "+ tự thêm"). Both label branches appear on one screen as the
  report claims: "từ buổi hẹn Đi cà phê tối" under "Cà phê muối", "từ một buổi hẹn" under "Phim kinh
  dị Hàn" — with the stale title "Xem phim khuya" nowhere on the screen. "Đi bộ ven hồ" and "Sinh
  nhật" carry no origin line. The label renders as a muted caption with no chip, pill, border, fill,
  icon or arrow. The `...` glyph renders as three dots, not an empty box. Background is opaque. The
  `-ios` capture's header title is washed out exactly as the report declares (`BackdropFilter` with
  no backdrop offscreen); the `-md` capture shows the full title, so the header band is evidenced.
- **O-7.** The origin caption is visually identical to the metadata line ("15/05" on "Sinh nhật") in
  size, colour and position. That is spec-conformant rather than a collision: UX Phần C:128 requires
  the label take "cùng vai trò với timestamp/metadata theo bảng type-scale".
- **O-8.** `DESIGN_SPEC_CONFLICT` in Phần II (:147-166) is declared, not hidden, and its precedence
  call is correct: canvas `2-so-tay-nguoi-yeu` depicts REQ-016's original conception (group counts,
  chips, "Về Cún / Về mình" tabs), while the shipped screen is REQ-016 STORY-004's reviewed result;
  those deltas are merged decisions P4 may not touch, and the new label — absent from the canvas —
  is scored against UX Phần D and AC-4/AC-5/AC-9. Same precedence Slice 3 accepted for Phần I.
- **O-9.** `origin_label_visual_capture_test.dart` is deliberately a separate file from
  `visual_capture_test.dart` because the latter writes into REQ-016 STORY-004's evidence directory
  (file doc :22-25, test-results :777-779). `git status --porcelain` in the worktree is clean after
  this review's gate runs, so no other story's PNGs were dirtied.

## Traceability

- **Requirements:** `story_master.md` AC-4 (P4-A1), AC-5 (P4-A4 + F-7), AC-9 (P4-A2, P4-A3),
  AC-10 (P4-A6), AC-11 (P4-A11, O-5), **AC-13 (P4-A7 — the verdict this slice was assigned)**,
  AC-14 (P4-A9), AC-15 (P4-A8), BR-6 (P4-A2, P4-INV1), BR-7 (P4-A7), BR-11 (P4-A5, P4-INV3).
  BR-6 and BR-7 resolved against their real definitions at `requirements/requirements.md`:136 and
  :139 respectively (both are REQ-017 renumberings of REQ-016 STORY-012 BR-12 and BR-11 — two
  distinct "BR-11"s are in play across the two requirements, and the citations were checked rather
  than assumed). Phase §4's eight acceptance items map onto P4-A1/A2/A4/A5/A6/A7/A11 with exactly
  one unbacked: the "đổi loại" clause, F-7.
- **Architecture:** phase §1B `Source Of Truth` cites `architecture/solution.md` §1 KD-2 and §4.
  KD-2 (degrade is the only path; a read error never reaches the UI) verified at P4-A2/P4-A3, and
  structurally enforced by putting the resolver in `domain/` so no widget holds a card title —
  `_NotebookRow` receives a finished `String?`.
- **UX:** `ux/uiux-spec.md` Phần C:124-155 (P4-A1, P4-A2, P4-A4, P4-A5, P4-A6, P4-A7, P4-A8, O-7)
  and Phần E:170-177 (no new entry point, no "đã lưu" badge — the diff adds neither).
- **OQ discipline:** `story_master.md` `## Open Question Impact` records no blocked scope; OQ-1,
  OQ-2 and A-5 all RESOLVED 2026-09-27. This slice implements no blocked scope and omits no
  unblocked scope.
- **Configuration guide:** phase §1B `Update Required: NO`; the story's single config line (the
  asset dir) belongs to P2. No configuration-guide verification owed here.
- **Runtime startup smoke:** phase §1B `Startup Smoke: NOT_APPLICABLE`. Story-level mobile launch
  smoke is a story obligation owned by final synthesis, not a P4 slice obligation.
- **Static analysis:** Gate 4 scored as a delta over the six changed files
  (`flutter analyze --no-pub <6 paths>` → `No issues found!`, exit 0). Correct method — a bare
  `flutter analyze` can never exit 0 in this repo, so it is not usable as gate evidence.
- **Visual fidelity:** in scope for this phase and PASS — P4-INV4, including this review's own
  negative control proving the gate was live.

## State recommendation

None from this slice. `Outcome: PARTIAL_SLICE_ONLY`. Carry forward to final synthesis:

1. **F-7 (new, MEDIUM)** — AC-5's "đổi loại" clause has no implementation and no declared deviation.
   Needs an explicit call: patch the AC wording, or record the story incomplete against AC-5. It
   cannot be fixed inside P4's Write Scope without contradicting UX Phần C:137-139.
2. **R-1 (from Slice 3)** — unchanged; P4 adds no write path and does not touch `recordFromCheckIn`.
3. **F-4 and F-6 — CLOSED here.** Neither needs final-synthesis attention. F-6 in particular is not
   the blocker it was flagged as: `validateContextPacks` has no production call site.
4. **AC-13 — settled PASS (P4-A7).** No longer owed by any slice.
5. **O-3** — `story_master.md` is still `Status: TODO` with Implementation/Review unchecked.
6. **O-5** — AC-11's journal-deletion half is satisfied vacuously; no journal-delete API ships.
7. **O-4** — one AC mis-citation in the fidelity report's prose, no verdict impact.

REVIEW_SLICE_COMPLETE: YES
