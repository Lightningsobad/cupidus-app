# Review Slice S6 — P6 card detail, lifecycle, delete

Mode: `scoped-slice`
Slice verdict: **FAIL — `PATCH_REQUIRED` on AC-15** (1 blocking finding, 4 deferred;
FLAG-1 verdict issued here, S4-F-4 folded in)
REVIEW_SLICE_COMPLETE: YES

## Scope

Diff baseline `9207f7296a64cd37ca60e432939469ca96860762`, scoped to 6 files.
`git diff --stat` against the baseline: **all six are new files, +2435 / −0**.
No pre-existing file was modified, so there is no regression surface in this slice.

| File | Δ |
|---|---|
| `mobile/lib/features/activity_cards/presentation/activity_card_detail_cubit.dart` | +272 / −0 |
| `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart` | +969 / −0 |
| `mobile/lib/features/activity_cards/presentation/widgets/status_change_picker.dart` | +249 / −0 |
| `mobile/lib/features/activity_cards/presentation/widgets/delete_card_dialog.dart` | +59 / −0 |
| `mobile/test/features/activity_cards/activity_card_detail_screen_test.dart` | +345 / −0 |
| `mobile/test/features/activity_cards/card_lifecycle_ui_test.dart` | +541 / −0 |

AC ids verified directly against `requirements/requirements.md`, not
`story_master.md`. **The scope-gate Query Keys drift is confirmed again, for the
sixth consecutive slice.** The gate lists S6 as "AC-4, AC-5, AC-6, AC-7, AC-15";
the real ids are **AC-12** (schedule date → *Đã hẹn ngày*, L135–137), **AC-14**
(two-way transitions, L144–147), **AC-17/AC-18** (self-marked reply flag / no
behaviour metric, L159–166), **AC-16** (undramatic delete, L153–155). Only
**AC-15** (L149–151) carries the same number in both. `phase-P6-…md` §1B and
`test-results.md` § Phase P6 both use the correct `requirements.md` numbering, so
the drift is confined to the scope gate.

## Verdict Table

| Item | Source | Verdict | Evidence |
|---|---|---|---|
| AC-15 — a card moved to *Đã hẹn ngày* then rolled back to *Mới nghĩ ra* must not lose the entered date/note silently; app keeps it or asks | `requirements.md` L149–151 | **FAIL — `PATCH_REQUIRED`** | See F-1. The guard works only while the screen stays mounted; on the ordinary schedule-then-return-later path the date was never persisted, so the guard cannot fire and the rollback writes straight through with no question asked. |
| AC-12 — primary action + pick a date → card moves to *Đã hẹn ngày* and lands in that pane | `requirements.md` L135–137 | **PASS as written** | `_pickDate` → `cubit.scheduleDate` → `_edit(scheduledOn:)` + `_writeStatus(scheduled)` (`activity_card_detail_screen.dart:786–801`, `activity_card_detail_cubit.dart:78–81`). The AC's `then` names exactly two outcomes — status transition and correct pane placement — and both are persisted via `updateStatus`. The AC text does not require the date itself to be stored, so the scope gate's FLAG-1 hypothesis survives at AC-12. The date loss lands on AC-15 instead. `card_lifecycle_ui_test.dart:127–138`; CTA opens the picker, `activity_card_detail_screen_test.dart:187–198`. |
| AC-14 — all four statuses reachable in both directions, no locked one-way transition | `requirements.md` L144–147 | **PASS** | `status_change_picker.dart:73–74` iterates `ActivityCardStatus.values` with no filter on `current`; the current status is only tick-marked (`:116–126`), never removed. `changeStatus` writes any target (`activity_card_detail_cubit.dart:86–95`). Test loops all 12 ordered pairs and asserts each writes `updateStatus` (`card_lifecycle_ui_test.dart:142–165`); the widget test asserts all four options are present in the sheet (`:303–308`). |
| AC-16 / R-1c — delete makes the card vanish, undramatic: no reproach, no reason asked, no emotional copy | `requirements.md` L153–155 | **PASS** | `delete_card_dialog.dart:19–59`: one step, title "Xoá thẻ này?", two `ActivityDialogChoiceButton`s drawn identically, neutral `colorSurface` background, only the destructive label carries `colorRed`. No reason field, no second confirmation. Test asserts no `EditableText` in the dialog, equal `fontSize`/`fontWeight` on both buttons, and absence of the pleading strings `chắc` / `tiếc` / `không thể hoàn tác` (`card_lifecycle_ui_test.dart:351–418`). Confirm path reaches `repository.deleteCard` (`activity_card_detail_cubit.dart:174–188`). |
| AC-17 — "đã rủ" allows only *đã trả lời / chưa trả lời*, and the flag moves only on the user's own tap | `requirements.md` L159–161 | **PASS** (persistence gap deferred, see F-2) | `toggleInvited` / `toggleReplyState` are strict two-value toggles (`activity_card_detail_cubit.dart:136–142`); their only callers are the two chips' `onTap` (`activity_card_detail_screen.dart:639, 648`). No timer, no listener, no inference anywhere. The reply chip only renders once `invited` is true (`:641`). Test pumps 6 hours and asserts nothing moved (`card_lifecycle_ui_test.dart:443–468`). |
| AC-18 / R-1b — no "đã xem", no open time, no open count, no reply-frequency, displayed **or stored** | `requirements.md` L163–166 | **PASS** | A search of all four S6 lib files for `seen`, `viewedAt`, `openCount`, `openedAt`, `readReceipt`, `lastOpened` returns **zero hits**. No timestamp is rendered next to either chip; `_edit` deliberately preserves `card.updatedAt` rather than stamping `DateTime.now()` (`activity_card_detail_cubit.dart:264–267`), so not even an implicit activity trace is produced. Copy gate scans every `Text.data` in all four status modes against 15 forbidden phrases (`activity_card_detail_screen_test.dart:201–240`). |
| AC-19 / R-1e — no conclusion or scoring about the other person | `requirements.md` L168–170 | **PASS** | Same copy gate (`điểm`, `xếp hạng`, `tỷ lệ`, `tốc độ trả lời` all asserted absent). The screen renders no derived judgement of any kind; both person-facing chips are verbatim user-set flags. |
| AC-13 / SC-5 — no status is a dead end, including *Đã thành kỷ niệm* | `requirements.md` L139–142 | **PASS** | "Ghi lại" and "xem lại" are two modes of one screen, not two destinations (`activity_card_detail_cubit.dart:30–34`). The status-change row and the delete row are rendered unconditionally for every status (`activity_card_detail_screen.dart:178–197`) — they sit outside the `isReviewing` branch. Asserted for the terminal *Đã thành kỷ niệm* mode at `activity_card_detail_screen_test.dart:143–159`. |
| AC-11 / BR-2 — exactly one primary action matching the status | `requirements.md` L127–133, L203–207 | **PASS with a caveat** (see F-3) | Exactly one `card_detail_primary_action` per status, label sourced from the shared `primaryActionFor` / `activityPrimaryActionLabel` pair rather than re-authored (`activity_card_detail_screen.dart:701–750`); asserted for all four statuses at `activity_card_detail_screen_test.dart:162–185`. The two action rows are plain text at markedly lower visual weight and do not compete for the CTA's position. AC-11's `Given` is scoped to the card *trong danh sách*, so the detail screen is bound by BR-2 rather than by AC-11 literally; BR-2 holds. Caveat: the *Đã hẹn ngày* CTA is inert (F-3). |
| AC-8 — the card supports the full structured field set, all optional except the title | `requirements.md` L106–109, BR-13 L232–234 | **PASS** | Editors exist for 9 of the 10 named fields: title, activity type, scheduled date (picker), price, distance, needs-booking, indoor/outdoor, note, source link (`activity_card_detail_screen.dart:289–322, 423–616, 854–920`). "Ảnh/ký ức" is an empty 4:3 frame with no picker (`:327–353`), which **BR-13 expressly permits** — the model must carry every field "kể cả khi UI của story này chưa dùng hết". The photo gap is therefore not a finding. What BR-13 does **not** cover is an editor that accepts input and discards it — that is F-1's territory, not AC-8's. |
| AC-15 guard mechanics, screen-session scope | `requirements.md` L149–151 | **PASS in isolation** | Within one mounted session the guard is well built: the transition parks and writes nothing until answered (`activity_card_detail_cubit.dart:86–95`), `keep` writes only the status column, `clear` is the sole path that drops the date and only on its own tap (`:101–123`), and dismissal returns `null` → `cancelRegression` leaves the card untouched (`:127–132`, `activity_card_detail_screen.dart:816–827`). Neither dialog branch is an `ElevatedButton`/`FilledButton` and neither is autofocused, so no keyboard or accessibility default can reach the destructive branch (`status_change_picker.dart:145–200`, asserted `card_lifecycle_ui_test.dart:319–329`). This construction is genuinely good; F-1 is that it is unreachable on the path AC-15 actually describes. |
| Write-failure handling reaches the user | robustness | **FAIL (minor)** | See F-4. `state.failed` is set and rolled back correctly by the cubit but is never read by any widget. |
| Test execution | first-hand run in the worktree | **PASS** | `flutter test test/features/activity_cards/activity_card_detail_screen_test.dart` → **6 passed, 1 skipped** (the `CAPTURE_VISUALS` frame, skipped by design). `flutter test test/features/activity_cards/card_lifecycle_ui_test.dart` → **16 passed**. Executed by this review, not read out of `test-results.md`. |
| Test *correctness* (as distinct from test *pass*) | this review | **FAIL — see F-1** | Two tests encode the AC-15 defect as intended behaviour. Green here does not mean covered. |
| Reachability of this screen | S4 / FLAG-2 | **FAIL — owned by S4** | See F-5. Not re-issued as an S6 blocker. |

## Findings

### F-1 — FLAG-1 VERDICT: `PATCH_REQUIRED` on AC-15 — the scheduled date is never persisted, so the no-silent-loss guard cannot fire on the path AC-15 describes

**This is the FLAG-1 classification S6 was assigned to issue.** It is a real
AC-15 violation with user-facing data loss, not an acceptable seam.

**Ground truth from S2, cited not re-derived:** `ActivityCardRepository` exposes
exactly four write methods — `createCard` (insert-only), `updateStatus`,
`clearScheduledDate`, `deleteCard` — and no way to persist any field after
creation.

**What this screen does with that gap.** Every field editor on the detail screen
routes to `ActivityCardDetailCubit._edit` (`activity_card_detail_cubit.dart:215–271`),
which only `emit`s a new in-memory `ActivityCard`. It issues **zero** repository
calls. That covers all eleven editable values: title, note, source link, price,
distance, activity type, needs-booking, indoor/outdoor, invited, reply state,
**and the AC-12 scheduled date**. The cubit states the boundary itself at
`:56–66`, and the phase record repeats it (`test-results.md:881–891`,
`phase-P6-…md:130–132`). So the behaviour is deliberate and documented — the
question this slice must answer is whether it is *permissible*, and it is not.

**The decisive trace.** `scheduleDate` (`activity_card_detail_cubit.dart:78–81`)
sets the picked date in memory and then calls `_writeStatus(scheduled)`, which
persists **only** the status column. The store therefore ends in a state the
design never contemplated: `status = 'scheduled'` with `scheduled_on = NULL`.

Now run AC-15's exact `Given` — *"một thẻ đã chuyển sang Đã hẹn ngày rồi bị lùi
về Mới nghĩ ra"* — through the real app rather than through the cubit:

- **Run A, both actions in one uninterrupted screen session.**
  `_needsScheduledDateQuestion` (`:194–197`) reads `state.card.scheduledOn` from
  memory, finds it non-null, and parks the transition. The dialog appears and the
  user is asked. **AC-15 satisfied.** This is the only run the tests exercise.
- **Run B, the user leaves the screen and comes back — a date set today and
  rolled back next week, i.e. the ordinary case.** The screen disposes and the
  date is gone, with no message. On re-entry the card is handed in from the store
  with `scheduledOn == null` and `status == scheduled`. The rollback now finds
  `scheduledOn == null`, `_needsScheduledDateQuestion` returns **false**, no
  dialog is shown, and `updateStatus(idea)` is written straight through.

Run B is precisely AC-15's `Given` and `When`. Its `then` fails on **both**
limbs: the app did not keep the data, and it did not ask before dropping it. That
the loss physically occurred at dispose rather than at the rollback tap does not
rescue it — **AC-15 forbids an outcome, not a mechanism**, and the story's
`## Business Outcome` ("không ý tưởng nào rơi rụng") points the same way. AC-15
also names *ghi chú* alongside *ngày hẹn*, and the note is lost identically, so
two of the AC's three named data items are affected. ("Ảnh" has no write path in
this story at all, so there is nothing there to lose.)

**Two tests certify the defect as correct behaviour.** This is why a green run is
not evidence here:

- `card_lifecycle_ui_test.dart:266–278`, *"a regression with no saved date asks
  nothing"*, asserts that a *Đã hẹn ngày* card with `scheduledOn == null` rolls
  back silently. That is right only if such a card never had a date. Because
  `scheduleDate` cannot persist one, **that state is the normal state of every
  card the user scheduled**. The test guarding the AC-15 boundary green-lights
  exactly the case where AC-15 breaks.
- `card_lifecycle_ui_test.dart:127–138` is named *"picking a date **saves it**
  and moves the card to Đã hẹn ngày"* and asserts
  `repository.calls == ['updateStatus:card-1:scheduled']` — i.e. asserts the date
  is **not** saved — under the comment *"One write, not 'save the date' then 'now
  change the status'."* The test name and its assertion say opposite things.

**Why this is not an acceptable seam.** Both available escapes fail:

- *"The repository has no field writer and repository files were outside P6's
  write scope."* True (`phase-P6-…md:19–25`) but not exculpatory. The repository
  ships **inside STORY-001** — P2 built it on this same branch, inside this same
  diff baseline. This is a phase write-scope boundary internal to one story, not
  a cross-story dependency. `master-plan.md` §3A binds AC-15 to **P2 + P6
  jointly**, and `phase-P6-…md:39–41` lists *"AC-15 mất dữ liệu âm thầm khi lùi
  trạng thái"* as an owned risk surface. A gap falling between the two phases that
  jointly own the AC is still the story's gap. Both halves shipped.
- *"BR-13 lets this story's UI leave model fields unused."* True, and it is why
  the photo placeholder passes. It does not cover a UI that **offers** an editor,
  accepts the user's typing, and drops it. BR-13 permits an unused field; it does
  not permit a field that pretends to be used.

The phase record self-classifies this as *"việc phải làm tiếp, không phải
blocker"* (`test-results.md:888–891`). A phase does not grade its own declared
risk surface, and this review does not adopt that classification.

**Patch scope is narrow**, which further weakens any "too large for this story"
argument: `clearScheduledDate` already exists, so the column and the DAO write
path are both in place in one direction. The minimum fix is the set direction —
a `setScheduledDate(id, isoDate)` writer, or folding the date into
`updateStatus` — plus repairing the two tests above so they assert persistence
rather than its absence. Owner: whichever phase carries
`activity_card_repository.dart` / `activity_card_repository_impl.dart` in write
scope, together with this cubit.

### F-2 — S4-F-4 folded in: "đã rủ" and reply state are memory-only too — same root cause, **deferred**, no AC violated

Per the handoff this is merged into the F-1 classification rather than reported
as an independent finding: `toggleInvited` and `toggleReplyState`
(`activity_card_detail_cubit.dart:136–142`) go through the same `_edit` helper
and are lost on dispose for the same reason — no repository field writer.
`card_lifecycle_ui_test.dart:511` asserts `repository.calls, isEmpty` for the
whole field-edit group, making the non-persistence explicit.

**But the severity is different from F-1, and S8 should keep the split.** The ACs
governing these two flags are constraint-shaped, not persistence-shaped:

- **AC-17** (L159–161) requires only that the app *offers just the two values*
  and that *the flag changes only on the user's own tap*. Both limbs hold
  exactly.
- **AC-18** (L163–166) forbids displaying or storing behaviour metrics. This
  holds, and if anything holds harder — nothing is stored at all.
- No AC in `requirements.md` requires `invited` or `replyState` to survive a
  restart. `## Scope / In Scope` item 8 mentions the marking, but that is scope
  prose, not an acceptance criterion, and rule 14 binds this review to the AC
  text.

So: a genuine defect with genuine user-facing loss, but **no AC it violates** →
**deferred with a named owner**, not blocking. The same repository patch that
closes F-1 closes this; it should be scoped to cover both in one pass.

### F-3 — the *Đã hẹn ngày* primary action is inert, and the code justifies it against a scope line `requirements.md` draws elsewhere (medium)

`_runPrimaryAction`'s `prepare` branch (`activity_card_detail_screen.dart:760–773`)
shows a neutral SnackBar, *"Phần chuẩn bị nằm ở bước sau."*, under the comment
*"STORY-002 owns preparation."* `requirements.md` `## Out of Scope` L55–56 draws
the boundary in a different place:

> Xuất lời mời / bottom sheet mad-libs — STORY-002. **Ở story này hành động chính
> của *Đã hẹn ngày* là "chuẩn bị"**, chưa phải "xuất lời mời".

"Chuẩn bị" is **this** story's primary action; only "xuất lời mời" is STORY-002's.
AC-11's CTA label table is still satisfied (the button does read "chuẩn bị") and
AC-13 still passes because the status-change and delete rows remain, so this is
not a dead end. But one of the four SC-4 primary actions currently does nothing,
and the in-code justification cites a boundary the requirement does not draw
there. S8 should rule on whether AC-11 tolerates a correctly-labelled inert CTA,
or whether "chuẩn bị" needs a real destination in this story.

### F-4 — write failures are invisible to the user (minor; robustness)

The cubit handles failure carefully: `updateStatus`, `clearScheduledDate` and
`deleteCard` each catch, set `failed: true`, and leave the card unchanged
(`activity_card_detail_cubit.dart:174–188, 199–213`), asserted at
`card_lifecycle_ui_test.dart:516–539`. **Nothing renders it.** `_content` never
reads `state.failed`, and the `MultiBlocListener`
(`activity_card_detail_screen.dart:108–132`) listens only for `pendingRegression`
and `deleted`. `git grep '\.failed' -- mobile/lib` returns only the two cubit
declarations plus unrelated gallery code — no reader anywhere.

User-visible result: a failed status change or a failed delete produces no
message, no retry, and no change on screen — the row silently keeps its old
label, indistinguishable from a tap that did not register. The state machine is
right; only the presentation is missing. Local-DB writes rarely fail, so this is
deferrable, but it is the only unhandled failure surface on the lifecycle path
and it mirrors S5's F-5 on the capture path — S8 may want to treat the pair as
one item.

### F-5 — the detail screen has no route (confirms S4's FLAG-2; owner: S4)

Confirmed independently in code, not inherited: `git grep -n
"ActivityCardDetailScreen" -- mobile/lib` returns **only its own declaration** at
`activity_card_detail_screen.dart:28–29`. `ActivityCardDetailCubit`,
`showStatusChangePicker`, `showScheduledDateChoiceDialog` and
`showDeleteCardDialog` likewise have no call site outside these four files. The
implementer recorded the same gap (`test-results.md:913–915`).

Consequence for this slice: **AC-12, AC-13, AC-14, AC-16, AC-17 and AC-18 are
exercisable only by widget tests that mount this screen directly**; no user
arriving from the main menu can reach it. Per the S6 handoff this is S4's
recorded finding and is **not** double-counted here — S6 reviewed these files on
their own terms. S8 should attribute the blocker once, to S4.

Note the interaction with F-1, which S8 should not miss: F-5 currently masks F-1
in manual testing. While the screen is unreachable, nobody can observe the date
loss. **Wiring the route without also fixing F-1 turns a latent defect into a
live one** — the two must be sequenced together, not shipped one at a time.

### F-6 — trivial: the title field can desynchronise from the cubit

`_titleField`'s `onChanged` (`activity_card_detail_screen.dart:300–305`) swallows
empty input so the title can never be blanked — correct against AC-8's "tất cả
tuỳ chọn trừ tiêu đề". But the `TextEditingController` keeps the emptied text on
screen, so the visible field and the cubit's card disagree until the user types
again. Cosmetic while nothing persists; worth folding into the F-1 patch, since
it becomes a real save-the-wrong-thing hazard once a field writer exists.

## Notes For S8

- **F-1 is this slice's blocking finding and the FLAG-1 verdict: `PATCH_REQUIRED`
  against AC-15.** It is not an acceptable seam. Do not accept the phase record's
  own "không phải blocker" self-classification.
- **F-2 is the S4-F-4 fold-in, already merged into F-1's root cause.** Same
  repository gap, but **deferred**, because no AC requires those two flags to
  persist. Do not promote it to a second blocker and do not count it as a second
  independent finding.
- **F-5 belongs to S4** — attribute the reachability blocker once. Record the
  sequencing constraint: fixing F-5 alone makes F-1 user-visible.
- **F-3** needs a product ruling on AC-11 (inert but correctly-labelled CTA), not
  a code judgement.
- **F-4** and **F-6** are deferrable; F-4 pairs with S5's F-5.
- Nothing in this slice is `UNVERIFIED`. Every AC above was traced to code and to
  a first-hand test run in the worktree.
- One observation for S7, from an S6 file, not an S6 finding: the visual-evidence
  capture loop (`activity_card_detail_screen_test.dart:279–304`) writes frames for
  *Mới nghĩ ra*, *Đã đi rồi* and *Đã thành kỷ niệm* only. **There is no captured
  frame for *Đã hẹn ngày*** — the one status whose behaviour F-1 finds defective.
