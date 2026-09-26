# Review Slice S5 — P5 minute-one empty state + quick capture

Mode: `scoped-slice`
Slice verdict: **PASS** (3 minor findings + 1 severity escalation carried to S8;
the blocking defect in this territory is S4's FLAG-2, not re-issued here)
REVIEW_SLICE_COMPLETE: YES

## Scope

Diff baseline `9207f7296a64cd37ca60e432939469ca96860762`, scoped to 5 files.
`git diff --numstat` against the baseline: **all five are new files, +1409 / −0**.
No pre-existing file was modified in this slice, so there is no regression
surface here.

| File | Δ |
|---|---|
| `mobile/lib/features/activity_cards/presentation/widgets/minute_one_empty_state.dart` | +355 / −0 |
| `mobile/lib/features/activity_cards/presentation/widgets/quick_capture_sheet.dart` | +208 / −0 |
| `mobile/lib/features/activity_cards/presentation/widgets/quick_entry_strip.dart` | +159 / −0 |
| `mobile/test/features/activity_cards/minute_one_empty_state_test.dart` | +437 / −0 |
| `mobile/test/features/activity_cards/quick_capture_sheet_test.dart` | +250 / −0 |

AC ids verified directly against `requirements/requirements.md`, not
`story_master.md`.

## Verdict Table

| Item | Source | Verdict | Evidence |
|---|---|---|---|
| AC-1 — empty state, **exactly two** one-tap invitations, no onboarding form/wizard/profile fill (SC-3) | `requirements.md` L72–76 | **PASS** | Exactly two `_InviteCard`s: `activity_minute1_invite_link` and `activity_minute1_invite_occasion` (`minute_one_empty_state.dart:103–129`); labels match AC-1's two named invitations. Test asserts `findsNWidgets(2)` by key prefix + `Form`/`TextFormField`/`EditableText` all `findsNothing` + title `maxLines == 1` + no "+" action (`minute_one_empty_state_test.dart:205–230`). Run green first-hand. |
| AC-1 — third-CTA check (the 3-cell strip) | `uiux-spec.md` §4a L131–132 | **PASS, not a violation** | The `QuickEntryStrip` is also mounted in the empty state (`minute_one_empty_state.dart:139`), but §4a authorizes it explicitly: *"Dải lối-vào-nhanh 3 ô (mục 6) **vẫn hiện** ở trạng thái này — nó không phải form và không cạnh tranh với 2 lời mời."* Its cells are navigation to STORY-004/005/011 surfaces, not card-creating invitations. The widget's own doc-comment claim to that effect was checked against the spec and is accurate. |
| AC-2 — paste link → ≥1 card in *Mới nghĩ ra*, no extra field before the card exists | `requirements.md` L78–80 | **PASS** | `_captureLink` → `QuickCaptureSheet(mode: link)` → one autofocus `TextField` → `onSubmitted` → `createCard(…origin: pastedLink…)` → `pop(card)`; no confirm button (`quick_capture_sheet.dart:90–145`, asserted by `ButtonStyleButton` `findsNothing`). The *Mới nghĩ ra* clause is not set by S5 code — verified at the contract instead: `activity_card_repository_impl.dart:40` writes `status: Value(ActivityCardStatus.idea.wireValue)` unconditionally, so the clause holds through the real repository and not only the test fake. |
| AC-3 — 1–2 deterministic suggestions from the shipped package, one tap creates a card | `requirements.md` L82–85 | **PASS in isolation** (see F-2 escalation) | `_SuggestionList` renders `prompt.occasion.name` + one tap-row per suggestion → `OccasionSuggestionService.acceptSuggestion` (`minute_one_empty_state.dart:130–134, 172–180, 281–355`). Test asserts exactly 2 rows, `origin == occasionSuggestion`, title taken verbatim from the package, and no `EditableText` between tap and card. |
| AC-6 — manual "+" creates a card from title alone, saved immediately | `requirements.md` L97–99 | **PASS** | `QuickCaptureMode.title` path; `QuickCaptureAddAction` hidden while `storeCount == 0`, shown otherwise (`quick_capture_sheet.dart:152–190`), matching `uiux-spec.md` §1 item 5 (*"luôn hiện, trừ lúc màn ở trạng thái rỗng Phút-1"*). Both branches tested. |
| AC-7 — pasted link kept, card created even with no derivable title/image | `requirements.md` L101–104 | **PASS** | Link mode sends `title: ''` deliberately so the save never blocks on a field the user did not give; `_resolveTitle` in the repository derives it. Test asserts `draft.title` is empty and `sourceLink` preserved. |
| J1 — 5-second capture incl. paste-link path | `requirements.md` Traceability L292 | **PASS by structure** | Paste-link path is 2 interactions end to end (tap invite, submit field), `autofocus: true` raises the keyboard on open, no confirm step and no intermediate screen. Occasion path is 2 taps with zero fields. |
| AC-4 — 1–2 cards **within 60 seconds** of tapping an invitation | `requirements.md` L87–89 | **UNVERIFIED (low risk)** | No timing measurement exists in the P5 evidence and none is obtainable from a widget test. The structural path above is well inside the budget, but the numeric clause itself is unmeasured. |
| R-7 / BR-8 — no runtime AI, no external content API | `requirements.md` L92–93, L220–222 | **PASS** | No network or model call on any path in the three lib files. Occasion content arrives via `loadOccasionPackage()` (shipped asset) behind the injectable `OccasionPromptLoader` typedef; occasion name and suggestion titles are rendered verbatim from the package (`minute_one_empty_state.dart:306, 339`), never authored in Dart (R-15a). |
| SC-1' / AC-21 — no second store | `requirements.md` L178–180 | **PASS** | All three files write solely through `ActivityCardRepository.createCard`; no parallel list or local collection is introduced. |
| `uiux-spec.md` §6 — 3 equal cells, no count badge, no "new" dot, `filled` icon variant | `uiux-spec.md` L153–172 | **PASS** | Fixed 3-cell `Row`, equal widths asserted across both states, `Badge` `findsNothing`, exactly 3 `Text` descendants. `CupidIcon` defaults to `CupidIconVariant.filled` (`cupid_icon.dart:41`), so the omitted `variant:` at the cell call sites still satisfies §6; the two invitation icons correctly pass `variant: line` per §4a. |
| SC-5 / AC-13 — an unfilled quick-entry cell is not a dead end | `requirements.md` L139–142 | **PASS** | Each unfilled cell answers with the neutral "Sắp có" SnackBar prescribed by §6 L170–172 rather than doing nothing. |
| Test execution | first-hand run in the worktree | **PASS** | `flutter test test/features/activity_cards/minute_one_empty_state_test.dart` → **7 passed, 1 skipped** (the `CAPTURE_VISUALS` frame, skipped by design). `flutter test test/features/activity_cards/quick_capture_sheet_test.dart` → **6 passed**. Executed by this review, not read out of `test-results.md`. |
| Reachability of these widgets | S4 / FLAG-2 | **FAIL — owned by S4** | See F-1. Not re-issued as an S5 blocker. |

## Findings

### F-1 — The three widgets are correct but unmounted (confirms S4's FLAG-2; owner: S4)

Confirmed independently in code, not inherited: a search of `mobile/lib` for
`MinuteOneEmptyState`, `QuickCaptureSheet`, `QuickCaptureAddAction`, and
`QuickEntryStrip` returns **no call site outside these files themselves**. The
only cross-file reference is `minute_one_empty_state.dart:139` mounting
`QuickEntryStrip`. `activity_card_hub_view.dart:63` mounts a **private**
`_QuickEntryStrip` declared at `:156–157` inside that same file — a different
class from the public `QuickEntryStrip` reviewed here. `MinuteOneEmptyState`,
`QuickCaptureSheet`, and `QuickCaptureAddAction` have zero call sites in `lib`.

The implementer recorded the same gap: `phase-P5-…md` §7 (*"ba widget đã xong và
đã kiểm thử nhưng chưa gắn vào `activity_card_hub_view.dart`"*) and
`test-results.md:782–791` (*"Khoảng hở còn lại"*), which also notes `_EmptyPane`
still returns `SizedBox(key: Key('activity_card_hub_minute1_slot'))`.

Consequence for this slice: **AC-1, AC-2, AC-3, AC-6 and AC-7 are exercisable
only by widget tests that mount these widgets directly; no user arriving from the
main menu can reach any of them.** By the scope gate's own FLAG-2 test that is
`PATCH_REQUIRED`, not an acceptable staged-rollout gap. Per the S5 handoff this
is S4's recorded finding and is **not** double-counted as an S5 blocker — S5
reviewed these files on their own terms and finds the implementations correct;
they are simply orphaned. S8 should attribute the blocker once, to S4.

### F-2 — ESCALATION of S3's F-2: the second invitation becomes permanently dead on 2027-12-25 (severity MEDIUM → HIGH)

Direct answer to the question S3 posed. The degradation **is graceful in the
narrow sense**: `_revealSuggestions` (`minute_one_empty_state.dart:156–170`)
tests `_prompt == null` and shows a neutral "Sắp có" SnackBar keyed
`activity_minute1_occasion_coming_soon`; the suggestion list is gated behind
`_showSuggestions && prompt != null` (`:130`). Nothing crashes, nothing renders
half-built, and no occasion is invented in Dart (R-15a respected, and the code
comment says so explicitly).

But the invitation card itself is rendered **unconditionally** (`:117–129`).
So from 2027-12-25 — the day after `occasions.v1.json`'s last covered date per
S3 — the Minute-1 screen still shows AC-1's second invitation, and that
invitation can never produce a card again. Two consequences:

- **AC-3 becomes permanently unsatisfiable.** *"chọn một gợi ý tạo ngay một thẻ"*
  has no reachable path once `nearestOccasion` returns `null` forever.
- **AC-1's "đúng hai lời mời một chạm" degrades to one working invitation plus
  one dead affordance.** AC-4 survives, because the paste-link path still
  delivers a card, but it does so through one invitation instead of two.

Two aggravating details:

- The copy shown is `Sắp có` — the identical string
  `quick_entry_strip.dart:129` uses for genuinely **unbuilt** cells. A user who
  hits a shipped-but-data-exhausted feature is told it was never built.
- **This branch has no test.** Every occasion test supplies a non-null
  `_prompt`; the one test that leaves `prompt` null
  (`minute_one_empty_state_test.dart:205`) never taps the occasion invite. The
  single branch the app enters permanently after 2027-12-24 is the only branch
  in this file with zero coverage.

Recommendation for S8: keep this **deferred** only if a content-refresh owner and
a refresh date before 2027-12-25 are recorded somewhere durable. Absent that, it
is `PATCH_REQUIRED` against AC-1/AC-3 with a known expiry date, not a
content-freshness nit.

### F-3 — AC mis-mapping in the P5 evidence record and two test names (minor; traceability)

`test-results.md:761–764` maps *"AC-1"* to *"một trường, không form"* and
*"AC-2"* to *"dải 3 ô luôn hiện"*. Against `requirements.md`, AC-1 is the
two-invitation empty state (a different assertion) and AC-2 is the paste-link →
card clause; the 3-cell strip carries **no AC id at all** — it exists only in
`uiux-spec.md` §6. The same mis-citation appears in
`quick_capture_sheet_test.dart:86` (*"asks for exactly one field and no form
(AC-1)"* — that assertion is AC-6 / BR-4).

Coverage is **not** actually missing: `minute_one_empty_state_test.dart:205`
covers real AC-1 and `:232` covers real AC-2. This is a labeling defect that
would corrupt S8's coverage roll-up if the evidence table is taken at face value.

Worth recording as a contrast with S1–S4: the **code** comments in these three
lib files cite AC ids **correctly** against `requirements.md`
(`quick_capture_sheet.dart:18` AC-7 = pasted link, `:22` AC-6 = manual "+", both
exact; `phase-P5-…md` §4 likewise). The AC drift in this slice is confined to two
test names and one evidence table.

### F-4 — Quick-entry strip does not scroll on narrow screens (minor; UX spec deviation)

`uiux-spec.md` §6 L167–168 requires the 3-cell strip to scroll horizontally when
the screen is too narrow (*"cuộn ngang nếu màn quá hẹp"*).
`quick_entry_strip.dart:40–53` is a fixed `Row` of three `Expanded` cells whose
labels are `maxLines: 1, overflow: ellipsis` — on a narrow device the labels
truncate instead of the strip scrolling. The §6 properties the tests do assert
(3 equal cells, shape invariant to data, no badge) all hold. Low impact,
deferrable.

### F-5 — Unhandled write failure wedges the capture sheet (minor; robustness)

`quick_capture_sheet.dart:118–145`: `_submit` sets `_saving = true`, awaits
`repository.createCard`, and has no error path. If the Drift write throws, the
sheet stays mounted with a disabled field, no message, and no retry other than
dismissing — the typed text is lost. The existing test covers the empty-submit
case only. Local-DB writes rarely fail, so this is deferrable, but it is the only
unhandled failure mode on the J1 capture path.

## Notes For S8

- Blocking item in this territory (**F-1**) belongs to **S4**; do not count it twice.
- **F-2** changes the severity of S3's F-2 and needs a product decision (refresh
  owner + date), not a code fix in these files.
- **F-3**, **F-4**, **F-5** are deferrable; none blocks on its own.
- Nothing in this slice is `UNVERIFIED` except AC-4's 60-second numeric clause,
  which has no measurable evidence and no low-cost way to obtain one.
