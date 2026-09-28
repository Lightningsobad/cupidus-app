# Review Slice P3 — Optional capture block on the 23h check-in screen (door + UI + split save)

Outcome: PARTIAL_SLICE_ONLY

- Review type: `scoped-slice` (Slice 3 of 4)
- Story: `STORY-001_checkin_notebook_capture` (REQ-017), Complexity `standard`, Lane `shared` (mobile-only in practice)
- Phase under review: P3 — `coding-plan/phase-P3-checkin-capture-block.md`
- Worktree: `story-REQ-017_checkin_notebook_capture-STORY-001_checkin_notebook_capture`
- BaseHead: `0198e32ddd3f8bad6a4d5274fd7b5ebeae9158b1`
- This slice produces NO story outcome. Story closure is decided by the later `final-synthesis` slice.

## Scope Gate

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

- Slice report path: `data/requirements/REQ-017_checkin_notebook_capture/STORY-001_checkin_notebook_capture/review/slice-p3-capture-ui.md`
- Source/test files in scope (`git diff --stat <BaseHead>`, real paths):
  - `mobile/lib/features/phase_status/presentation/evening_check_in_sheet.dart` (+216/-7)
  - `mobile/lib/features/phase_status/presentation/widgets/checkin_capture_block.dart` (+168/-0, new)
  - `mobile/lib/features/context_notebook/context_notebook_entry_point.dart` (+65/-1)
  - `mobile/lib/features/context_notebook/presentation/widgets/context_inline_add_row.dart` (+9/-3)
  - `mobile/test/features/phase_status/checkin_capture_block_test.dart` (+610/-0, new)
- **Handoff path correction (O-1).** The handoff listed `context_notebook/presentation/evening_check_in_sheet.dart`,
  `context_notebook/presentation/checkin_capture_block.dart` and
  `mobile/test/features/context_notebook/checkin_capture_block_test.dart`. None of those paths exist.
  P3's declared Write Scope (phase §1B:21-24) is `features/phase_status/**`, and the two
  `context_notebook` files above are the Scrum-Master-granted scope extension recorded at phase §7:167-169.
  The five paths above are the set actually reviewed.
- Evidence in scope: `coding-plan/test-results.md` `## P3` (Gates 1-8, lines 368-625),
  `coding-plan/phase-P3-checkin-capture-block.md` §1B/§3/§4/§6/§7,
  `coding-plan/master-plan.md` §3A/§5, `story_master.md` AC-1/2/3/6/7/8/9/12/14/16/17 + BR-4/BR-10/BR-12,
  `ux/uiux-spec.md` Phần A (1-4) and Phần B.
- Touched risk surfaces: RS-2 check-in save flow separation (BR-10); RS-3 per-check-in idempotency (AC-8/BR-12).
- Out of slice (not reviewed): all P1 persistence and P2 content-pack source and their slice reports;
  `notebook_screen.dart`, `checkin_origin_resolver.dart` and the origin-label tests (P4);
  AC-13 (see O-2); story-level launch smoke and the `2-so-tay-nguoi-yeu` fidelity pair.
- Gate 8 / import-boundary is cited as already-verified prior evidence per the handoff and was not re-derived.

## Verdicts

| Id | Claim in scope | Verdict | Evidence |
|----|----------------|---------|----------|
| P3-A1 | Block sits after photos + sentence, before the CTA; separated by a thin divider, not a card; the two STORY-012 chips keep place and meaning (AC-1, AC-7) | PASS | Order asserted geometrically — test:194-202 `capture.dy > journalField.dy` and `save.dy > capture.dy`. Divider: `checkin_capture_block.dart:73` `Divider(height: 1, thickness: 1, color: colors.colorLine)` with no `Card`/`DecoratedBox` wrapper anywhere in the widget; test:205-216 asserts exactly one `Divider` descendant of the block key. Chips: test:229-246 finds both `evening_check_in_journal_chip` / `evening_check_in_private_chip` and asserts each sits above the block. Title uses `type.body` and the optional marker `type.caption`/`colorGhost` (block:82, :88) per UX A.1:43-48 |
| P3-A2 | Every line of wording is a package data item, no hardcoded strings (AC-14) | PASS | All seven lines resolve through `copy.text(<id>)` (block:81, 87, 119, 123, 138, 146, 156); no Dart literal and no `l10n` call in the widget. The test does not invent wording either: `_copy` is parsed from `File(checkinCaptureAssetKey).readAsStringSync()` with `expectedSchemaId` (test:36-43), so test:218-227 compares the rendered text against the shipped `assets/data/req017/checkin_capture.v1.json` |
| P3-A3 | A build with no shipped wording has no block; the display condition is content, not the test seam | PASS | `evening_check_in_sheet.dart:372` `if (widget.capture != null)`. test:248-255 asserts both capture keys `findsNothing` and only the sentence `TextField` remains. This is documented deviation #2 (test-results:553-556) and is the correct call: gating display on `recordCapture` would let a real build with a broken DI registration lose the block silently (STORY-012 §7 lesson) |
| P3-A4 | Nothing is ever selected on the user's behalf, including after typing (AC-3, BR-4) | PASS | `selectedKind` is `NotebookKind?` passed straight through to `ContextInlineSegmented.selectedId` (block:126); the only writer of `_captureKind` is `_selectCaptureKind`, reached only from the user's `onKindSelected` tap (sheet:515-520, block:127-132). test:259-269 asserts `selectedId isNull` and `options hasLength(2)` on open; test:271-285 asserts still `isNull` after entering text |
| P3-A5 | One single-line field; no date, detail, second field, third choice or rating anywhere in the block (AC-3, AC-17) | PASS | `maxLines: 1` at block:99 (vs the multi-line sentence field); exactly two `ContextInlineAddOption`s built (block:116-125); no date/detail/rating widget exists in the file. test:287-304 asserts exactly 2 `TextField`s on the whole screen, `field.maxLines == 1`, and exactly 2 `InkWell` descendants of the block |
| P3-A6 | The capture field always starts empty and never shares a draft with the sentence field (AC-6, BR-3) | PASS | `_captureLine` is a fresh `TextEditingController()` (sheet:180) with no assignment from `_line` or any other source. Full usage census of `_captureLine` — sheet:196, 202-203, 210, 373, 552 — shows it is only listened to, handed to the block, read for the write, and disposed; there is no seeding path to review. test:306-323 types into the journal field and asserts the capture controller text `isEmpty` |
| P3-A7 | Empty or whitespace-only block is completely silent and the screen closes as before (AC-2, AC-17) | PASS | `_writeCapture` returns `nothingAsked` when `capture == null` or the trimmed value is empty (sheet:549-555); `nothingAsked.settled == true` (sheet:74-76) so `_save` reaches `navigator.pop()` (sheet:507-508). No toast/banner/snackbar code path exists for this state. test:327-338 (untouched) and test:340-352 (`'    '`) both assert `writes isEmpty`, `journalCalls == 1`, sheet `findsNothing`. AC-2's "không hỏi lại về buổi hẹn đó" is satisfied by STORY-012's unchanged nudge cadence — see F-3 |
| P3-A8 | Typed with no group chosen: not written, nothing auto-selected, journal still runs exactly once, screen stays, hint appears only after the CTA tap and clears when the line is cleared (AC-16, BR-4, BR-10) | PASS | `_writeCapture` returns `kindMissing` *before* touching the door (sheet:556-559); `_save` still calls `route(...)` unconditionally on the first pass (sheet:494-502) and `kindMissing.settled == false` keeps the screen. The hint renders only under `if (kindMissing)` (block:135-142), and `_captureKindMissing` is reset to false at the top of `_save` (sheet:481), so it cannot appear before a CTA tap. Clearing the line clears it via `_onCaptureLineChanged` (sheet:209-220). test:356-377, test:379-386, test:411-424 |
| P3-A9 | Choosing a group after the hint writes the line immediately, with no second CTA tap | PASS | `_selectCaptureKind` latches `answersOpenQuestion = _captureKindMissing` *before* clearing it, then calls `_resolveCaptureInPlace()` (sheet:515-523). test:388-409 asserts exactly one write carrying the trimmed value `'thích cà phê muối'` (from input `'  thích cà phê muối  '`), `kind == interest`, `originCheckInRef == eveningCheckInOriginRef(_cardId)`, `cardId`, `cardTitle`, `journalCalls == 1`, and the sheet closed |
| P3-A10 | Notebook write failing alone is reported inside the block, keeps the typed line and chosen kind, journal still exactly once; retry re-runs only the notebook half (AC-12, BR-10) | PASS | `_writeCapture` catches everything (sheet:569-571) → `failed`; error line + "Thử lại" render only inside the block (block:143-164); `failed.settled == false` keeps the screen; neither the controller nor `_captureKind` is written on the failure path. `_retryCapture` → `_resolveCaptureInPlace` calls `_writeCapture` only and never `route(...)` (sheet:526-546). test:428-458 asserts error + retry keys present, field text preserved, segmented still `event`; test:460-482 asserts retry → `writes hasLength(1)` with the same `originCheckInRef` and `journalCalls == 1` |
| P3-A11 | Split save: the notebook result never reaches the journal call, and the journal runs exactly once in all four branches (BR-10, KD-1) | PASS | `route(...)` (sheet:496-501) receives only `_line`-derived `trimmed`, `_photos` and `eveningCheckInOriginRef`; the `_CaptureOutcome` value is never passed into it, and the capture text is never handed to the journal (`trimmed` comes from `_line.text`, sheet:477). Journal single-shot is enforced by `_journalHandedOff` (sheet:191, checked :494, set :495 before the await). All four branch tests assert `journalCalls == 1`; test-results:419-422 records the same reasoning |
| P3-A12 | An unreadable card title still writes the line (AC-9) | PASS | `widget.cardTitle` is forwarded unchanged (sheet:567); no fallback text is synthesised at this layer. test:501-514 opens with `cardTitle: null` and asserts the write exists with `cardTitle isNull` and `cardId == _cardId`. Label degradation to "từ một buổi hẹn" is P4's |
| P3-A13 | Two CTA taps in a row produce one entry (AC-8) | PASS (residual) | Guard and its exact limits resolved under F-1 below |
| P3-INV1 | `context_notebook` keeps a single write door; the door widens by exactly one check-in-shaped write and leaks no version-pinning symbols (AC-14, solution §1 KD-1) | PASS (prior evidence) | Seven internal imports collapsed to one entry-point import per file. `recordCheckInCapture` (entry point:159-174) only delegates to `recordFromCheckIn`; no bulk/import/pre-fill/update/delete/read-all added. The `show` list carries `CheckinCaptureCopy`, `CheckinCaptureCopySet`, seven copy-id constants, `ContextInlineAddOption`, `ContextInlineSegmented` — and deliberately **not** `checkinCaptureAssetKey`, `checkinCaptureSchemaId` or the parser, so no host can pin a different package version or hand-build a copy set. Gate 6 `+130 ~4`, exit 0; Gate 8 (test-results:573-625) cited as already-verified, not re-derived |
| P3-INV2 | `ContextInlineAddRow`'s shipped default behaviour is unchanged (STORY-004 non-regression) | PASS | The whole `context_inline_add_row.dart` change is +9/-3: `_InlineSegmented` → public `ContextInlineSegmented`, plus `super.key` and a doc comment. The `_optionId` initialiser at :86-88 was **not** touched, so the "+ tự thêm" row keeps its pre-selected default, and the keys `context-inline-add-segmented` / `context-inline-add-option-<id>` are unchanged — which is why no notebook/skill-screen test needed editing. This is documented deviation #1 (test-results:543-552) and is the lower-risk of the two designs: it removes a branch from a shipped widget's state init instead of adding a host-controlled flag to it |
| P3-INV3 | The check-in screen never reads the card a second time and writes nothing to the card (BR-6) | PASS | `_openFromPayload` gained only the copy load (sheet:746-753); `cardId`/`cardTitle` are the values the sheet already held and are passed straight through (sheet:565-567). No `activity_cards` read or write anywhere in the diff |
| P3-INV4 | An unreadable copy package degrades to "no ask on this screen", never to a check-in failure | PASS | `loadCheckInCaptureCopy()` is wrapped in try/catch → `capture = null` (sheet:746-752), which by P3-A3 removes the block and leaves the photo/sentence path untouched. The door's doc comment states the same contract (entry point:145-148) |
| P3-INV5 | No notebook content can reach a STORY-012 widget or notification from this slice | PASS (structural) | The `_captureLine` census (P3-A6) shows the typed value reaches exactly two places: the block's controller (sheet:373) and the write door (sheet:552). The notification wiring at sheet:712 (`PluginLocalNotificationScheduler`) is untouched by the diff and receives no capture value; `local_notification_scheduler.dart` and `evening_check_in_scheduler.dart` are not in the diff at all; no new widget/notification UI is added. Note this is the AC-13-*adjacent* boundary, not AC-13 itself — see O-2 |
| P3-INV6 | Phase gate evidence is present, green, and honestly scoped | PASS | Gate 1 `+19 ~1`, exit 0 (the one skip is the visual-capture test, run under `--dart-define=CAPTURE_VISUALS=true`). Gate 2 STORY-012 regression `+282 ~7`, exit 0 with `evening_check_in_sheet_test.dart` unmodified — the handoff's "new block pushes the CTA out of the 800x600 frame" risk did not materialise because the STORY-012 suite passes no copy package (test-results:432-435). Gate 3 records the `Size(800, 1600)` surface and why the 412 width is a test-font artifact. Gate 4 analyze `No issues found!`, exit 0, file-scoped because the repo baseline is non-zero. Gate 5 fidelity exit 0 **with a live negative control** — the `/tmp/vf-control/` rename to a non-canvas-id filename made the gate exit 1 (test-results:472-474), and the capture was eyeballed for tofu/opacity/diacritics (:470-471). Gate 7 `test/core/database` `+106`, exit 0. Gate 8 re-runs changed no numbers. `git status --porcelain` clean of other stories' PNGs (:624-625) |
| P3-U1 | UX Phần B:107-109 requires the CTA to show a *visible* processing state ("label mờ đi hoặc spinner nhỏ trong nút") while saving | UNVERIFIED | The disable half is implemented and tested (F-1). The visible half is not asserted anywhere and is not obviously implemented: `FilledButton.styleFrom` (sheet:408-418) sets `foregroundColor` but no `disabledForegroundColor`, and `disabledBackgroundColor: Colors.transparent` leaves the parent `DecoratedBox` gradient at full strength — so the pill's only change while busy is whatever Material's default disabled foreground does to the label, and there is no spinner. Gate 5's capture is the initial state, not the busy state. Low severity (cosmetic affordance, no data risk); recorded rather than judged |
| P3-U2 | UX Phần B:116-120 requires retry to add no second entry when the previous write *partially* succeeded | UNVERIFIED (covered sequentially by P1) | Unprovable at this layer by construction: the retry test replaces the real door with the `recordCapture` seam, and `_Recorder.write` throws *before* appending to `writes` (test:85-88), so "partially succeeded then retried" is never exercised. The real defence is P1's `recordFromCheckIn` select-then-update, which Slice 1 verified PASS for the sequential path (P1-A2). Not a P3 defect; noted so final synthesis does not read test:460 as proof of partial-success idempotency |

## Carry-forward findings from Slice 1

### F-1 — idempotency/concurrency gap in `ContextNotebookRepository.recordFromCheckIn`: RESOLVED AS PARTIAL

**A guard exists, but it is not a de-duplication by check-in id, and it does not close F-1.**

Guard that is present. `onPressed: _busy ? null : _save` (sheet:407). `_save` sets `_busy = true`
inside `setState` at sheet:479-483 — synchronously, and before its first `await` at sheet:485. The same
`_busy` also disables the capture field (block:96), the segmented control (`if (!enabled) return;`,
block:128-130), the retry link (block:152) and the "để sau" button (sheet:434). From the next build
onward, every control on the save path is inert. This satisfies UX Phần B:109 "vô hiệu hoá chạm tiếp
cho tới khi xử lý xong".

What the AC-8 test actually proves. `two taps in a row are one save (AC-8)` (test:485-499) asserts
`writes hasLength(1)` and `journalCalls == 1`. But it calls `await tester.pump()` between the two taps
(test:493) and passes `warnIfMissed: false` on the second (test:494) — the second tap is *expected to
hit nothing*, because the rebuild has already nulled `onPressed`. So the test proves the disable works.
It does not exercise re-entrancy, and no test does.

Guard that is absent. There is no de-duplication by check-in id anywhere in the P3 path, and no
re-entrancy latch on the notebook half. The asymmetry is explicit in the code: the journal half got a
dedicated single-shot latch — `_journalHandedOff` (sheet:191, checked :494, set :495) — added precisely
because KD-1 now lets the screen stay open after a save. `_writeCapture` (sheet:548-573) got no
equivalent: it recomputes `eveningCheckInOriginRef(widget.cardId)` and calls the door unconditionally
every time it is reached. Neither `_save`, `_resolveCaptureInPlace` nor `_writeCapture` contains an
`if (_busy) return;`.

Consequence. P3 does **not** close Slice 1's F-1. Because `_busy` only takes effect at the next build,
two pointer events delivered inside the same frame both enter `_save` and both reach the door with the
same `originCheckInRef`, where P1's untransacted select-then-branch is the only remaining defence — both
selects can find nothing and both insert. The same sub-frame window exists on `_selectCaptureKind`
(guarded only by the build-time `enabled` check) and on `_retryCapture`.

Which AC-8 sub-clause. `story_master.md:77-78` contains two:

- (ii) "thao tác lưu lặp lại hay chạm hai lần không tạo mục trùng" — **met** for the user-reachable
  case. Two human taps are ≥100ms apart, i.e. ≥6 frames at 60Hz, so the CTA is already disabled;
  proven by test:485. Repeated-save-after-`kindMissing` is also safe (`_journalHandedOff` blocks a
  second journal entry, and `kind` is still null so no write happens).
- (i) "lần check-in đó tạo **tối đa một** mục sổ tay" — **still resting entirely on P1**. For any
  concurrent or sub-frame entry into `_writeCapture`, nothing in this slice bounds the check-in to one
  entry.

Verdict. The handoff's automatic-`PATCH_REQUIRED` trigger — "if there is no such guard anywhere in the
call path" — is **not** met: the submit control *is* disabled while a save is in flight, and the
ordinary double-tap is both guarded and tested. F-1 is therefore carried to the final synthesis as
residual risk R-1 against AC-8 sub-clause (i), not raised to a blocking P3 defect. The decision on
P1's missing transaction belongs to the final synthesis, which owns the story verdict.

Cheapest UI-layer close, if final synthesis wants one: give the notebook half the same latch the
journal half already has — a `String? _captureWrittenForRef` set before the await, or a leading
`if (_busy) return;` in `_save`. Either is a 2-line change inside P3's existing Write Scope.

### F-3 — `question_id` left null on check-in-sourced rows: RESOLVED AS UNRELATED

**No. Nothing in this slice keys off `question_id`, and a null `question_id` on these rows cannot cause
an incorrect re-ask.**

Nothing in the slice reads it. A search of all five slice files for
`question_id|questionId|askedQuestion|recordAnsweredQuestion|reAsk|re_ask` hits only
`context_notebook_entry_point.dart:107-136` — the pre-existing STORY-009 `recordAnsweredQuestion` door,
unchanged by this diff (the entry-point diff touches only the `library` doc line, two imports, the two
new exports and the two new functions). `lib/features/phase_status/` contains no reference to
`questionId` or `recordAnsweredQuestion` at all.

Both "don't re-ask" cadences key off something else:

1. **The 23h check-in ask** — this slice's own surface — is reachable only from the 23h nudge, whose
   no-repeat rule is STORY-012 AC-17 and lives in `phase_status/domain/evening_check_in_scheduler.dart`.
   That file is not in this diff, and `story_master.md` Out of Scope:49 forbids changing it.
   Non-regression evidence: Gate 2 `+282 ~7`, exit 0 with `evening_check_in_sheet_test.dart`
   unmodified. This cadence never consults `notebook_entries`, so it cannot observe `question_id`.
2. **The answered-question re-ask cadence** is `your_view_portrait`:
   `your_view_portrait_cubit.dart` decides from `PortraitAnswerRepository` and its
   `Map<String, PortraitAnswer> _answers`, keyed by `question.id` with `PortraitAnswerState`
   (`:77`, `:175`, `:187`, `:201-203`) — i.e. from the `portrait_answers` table, which is a different
   table from `notebook_entries`. The only callers of `recordAnsweredQuestion` are that cubit and the
   `portrait_answers` table/generated code.

So `notebook_entries.question_id` is not an input to any re-ask decision on any surface. Slice 1's F-3
is unrelated to the cadence path and carries no AC impact for P3. It remains only the data-shape note
Slice 1 recorded (`addEntry` could already produce an `ask_on_the_spot` row without a `question_id`).

## Observations

### O-1 — Handoff file paths were wrong (corrected, no impact)
Three of the five paths the handoff named do not exist; P3's real write scope is
`features/phase_status/**` per phase §1B:21-24, plus the two `context_notebook` files granted at
phase §7:167-169. The Scope Gate above records the set actually diffed and reviewed.

### O-2 — Handoff attributed AC-13 to this slice; it belongs to P4
`master-plan.md` §3A:32 maps AC-13 to RS-6, whose required dependencies are **P1, P4** — not P3.
`ux/uiux-spec.md` places AC-13 in Phần C:150-152 (the notebook screen / widget / notification surface),
and phase P3 §4:93-104 does not claim it. The AC-13 verdict therefore belongs to the P4 slice. The
in-scope negative evidence for the adjacent boundary is recorded as P3-INV5.

### O-3 — The new test file imports two `context_notebook` internals directly (accepted by design)
`checkin_capture_block_test.dart:7` imports `domain/checkin_capture_content.dart` and `:9` imports
`presentation/widgets/context_inline_add_row.dart`, bypassing the entry-point door. This is the
intended consequence of the AC-14 decision, not a violation: the test needs `checkinCaptureAssetKey`,
`checkinCaptureSchemaId` and `checkinCaptureCopyFromJson` to read the shipped asset off disk and prove
the rendered wording is not a literal (test:36-43), and those three symbols are deliberately withheld
from the door's `show` list (Gate 8, test-results:586-589). The shipped import-boundary guard is green
at HEAD with this file present (Gate 6 `+130 ~4`, exit 0), so its scan does not treat test files as
hosts. Worth one line in the door's doc comment so a future reviewer does not read it as drift.

## Traceability

- Requirements: `story_master.md` AC-1/AC-7 (P3-A1), AC-14 (P3-A2, P3-INV1), AC-3/AC-17 (P3-A4, P3-A5), AC-6 (P3-A6), AC-2 (P3-A7), AC-16 (P3-A8, P3-A9), AC-12 (P3-A10), AC-9 (P3-A12), AC-8 (P3-A13, F-1), BR-4 (P3-A4, P3-A8), BR-10 (P3-A8, P3-A10, P3-A11), BR-12 (F-1, P3-U2). Phase §4's seven acceptance items map onto P3-A1/A7/A8/A9/A10/A13/A5 with no item unaddressed.
- Architecture: phase §1B `Source Of Truth` cites `architecture/solution.md` §1 KD-1/KD-4 and §4. KD-1 (notebook write first, journal always, pop conditional) verified at sheet:475-510; the single-write-door rule verified at P3-INV1. The §1B consumer contract said `phase_status` calls `ContextNotebookRepository` directly, which the shipped import-boundary guard forbids — a design-artifact gap, resolved by widening the entry-point door rather than by editing the guard test (test-results:514-539, Gate 8). That resolution is the architecturally correct one and follows the STORY-009 `recordAnsweredQuestion` precedent.
- UX: `ux/uiux-spec.md` Phần A.1 (P3-A1), A.2 (P3-A4, P3-A5), A.3 (P3-A6, P3-A7), A.4 (P3-A8, P3-A9), Phần B (P3-A10, F-1, P3-U1, P3-U2). `visual-fidelity/visual-fidelity-report.md` records `VISUAL_FIDELITY: PASS` plus an explicit `DESIGN_SPEC_CONFLICT`: canvas `23h-vua-ve-j8` depicts the REQ-016 end state and has no capture block, so pre-existing elements were scored against the canvas and the new block against UX A.2. That is the correct precedence and is declared rather than hidden.
- OQ discipline: `story_master.md` `## Open Question Impact` records no blocked scope; OQ-1, OQ-2, A-5 all RESOLVED 2026-09-27. Nothing in this slice implements blocked scope or omits unblocked scope.
- Deliberate deviations from the phase file: both are declared (test-results:541-556) and both verified above — no `allowNoSelection` flag (P3-INV2), and `capture == null` as the hide condition (P3-A3). Neither weakens an AC.
- Configuration guide: phase §1B `Update Required: NO`; `master-plan.md` §1 records the only config line (the asset dir) as P2's. No configuration-guide verification owed by this slice.
- Runtime startup smoke: phase §1B `Startup Smoke: NOT_APPLICABLE`. Story-level mobile launch smoke is a story obligation owned by final synthesis, not a P3 slice obligation.
- Visual fidelity: in scope for this phase and PASS — see P3-INV6, including the negative control that proves the gate was live.

## State recommendation

None from this slice. `Outcome: PARTIAL_SLICE_ONLY` — P3 contributes **no blocking finding**. Carry
forward to final synthesis: residual risk R-1 (F-1 not closed; AC-8 sub-clause (i) rests on P1's
untransacted `recordFromCheckIn`, with a 2-line UI-layer fix available inside P3's Write Scope),
P3-U1 (unasserted CTA processing affordance, cosmetic), P3-U2 (partial-success retry idempotency
unprovable at the seam layer, covered sequentially by P1-A2), and O-2 (AC-13 verdict is owed by the
P4 slice, not this one).

REVIEW_SLICE_COMPLETE: YES
