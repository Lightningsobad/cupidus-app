# Slice C Review — Composer Sheet + Entry Surface (P5/P6)

Outcome: PARTIAL_SLICE_ONLY

Slice verdict: DEFERRED_ONLY — 8 of 8 ACs PASS, 0 blocking findings, 5 deferred.
This is a partial verdict over 1 of 3 slices and does not gate the story on its
own; the final-synthesis pass owns the story-level outcome.

Reviewer: Iris-QC
Mode: scoped-slice
Date: 2026-09-10
Story: REQ-016_solo_stage1_relationship_assistant / STORY-002_invite_message_composer
Slice: C of 3 (composer sheet + entry surface, phases P5/P6)
Diff baseline: `git -C <Worktree> diff 711274e3fde25788c91390a44572d53766bba778 HEAD`
Worktree HEAD at review: `b99d3ac9036aee89ade1bdc41b991c7e9f13fec6`

## 1. Slice Boundary

Handoff path correction: the handoff lists `prepare_actions_sheet.dart` under
`features/activity_cards/presentation/screens/`. It does not live there. The
actual path is
`mobile/lib/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart`
— the entry surface is owned by the `invite_composer` feature, and
`activity_card_detail_screen.dart` only imports it. That placement is right:
it keeps the pack-resolution logic with the feature that owns the pack.

In scope, all read at HEAD:

- `mobile/lib/features/invite_composer/presentation/invite_composer_cubit.dart`
- `mobile/lib/features/invite_composer/presentation/widgets/invite_composer_sheet.dart`
- `mobile/lib/features/invite_composer/presentation/widgets/frame_chip_strip.dart`
- `mobile/lib/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart`
- `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart` (+88/-19)
- `mobile/lib/features/activity_cards/presentation/activity_card_detail_cubit.dart` (+13/-0)
- `mobile/lib/features/activity_cards/presentation/widgets/card_detail_overflow_menu.dart`
  (read as a collaborator, not in the declared list — it is where the AC-6
  reply control actually lives; see N-C4)
- `mobile/test/features/invite_composer/invite_composer_cubit_test.dart`
- `mobile/test/features/invite_composer/invite_composer_sheet_test.dart`
- `mobile/test/features/invite_composer/prepare_actions_sheet_test.dart`
- `mobile/test/features/activity_cards/activity_card_detail_cubit_test.dart`
- `mobile/test/features/activity_cards/activity_card_detail_screen_test.dart` (+414/-3)

Slice A files, Slice B files, and F-1/F-2/F-4 were not re-examined. F-3 and F-5
were verified here because they land inside this file set, as the handoff asked.

Tool constraint on this run: the `Grep` tool and `ToolSearch` are both disabled
(`No such tool available: Grep` / `... ToolSearch is disabled for this session`),
and `guard-query-first-bash-read.sh` blocks shell `grep` over source. Every
source claim below therefore rests on a direct or ranged `Read`, or on
`git diff`, never on a keyword search.

## 2. Per-AC Verdicts

| AC | Verdict | Evidence |
| --- | --- | --- |
| Story AC-1 | PASS | `showInviteComposerSheet` loads the pack and returns early unless `status == ready`, so the sheet cannot open empty (`invite_composer_sheet.dart:62-66`). `MadLibsValues.fromCard(_card)` fills from the card itself (`invite_composer_cubit.dart:177`). End-to-end tap path card → "Chuẩn bị" → "Xuất lời mời" → composer is driven in `activity_card_detail_screen_test.dart` P6 group over a real pack, asserting `('card-1', inviteCategoryId)` reaches the opener. |
| Story AC-4 | PASS | `shareInviteText` is `SharePlus.instance.share(ShareParams(text: text))` and nothing else (`invite_composer_sheet.dart:94-96`). The `ShareInviteText` typedef returns `Future<void>`, so no delivery result can be read back even by a future caller. `invite_composer_cubit_test.dart:455` proves a failed save aborts the share rather than exporting unrecorded. |
| Story AC-6 | PASS | This story adds no reply surface and no inference. The complete detail-screen diff (+88/-19) contains no reply-state change, and the only card write the composer makes is `invited: true`, once, user-initiated, with `replyState: card.replyState` carried forward verbatim (`invite_composer_cubit.dart:302`). The user-tapped binary control is pre-existing and reads exactly "Đánh dấu đã trả lời / chưa trả lời" (`card_detail_overflow_menu.dart:26-31`). |
| Story AC-7 | PASS | There is no post-export reaction of any kind to be dramatic: the sheet's `exported` listener does one thing, `Navigator.of(context).pop(true)` (`invite_composer_sheet.dart:140-144`). No snackbar, no toast, no animation, no second-attempt prompt. The only failure copy is one neutral inline line, "Chưa lưu được lời mời, thử lại nhé.", about the app's own save, not about the recipient (`:223`). |
| AC-1 | PASS | "Xuất lời mời" is a row inside the "Chuẩn bị" sheet that the card's one primary action opens (`prepare_actions_sheet.dart:110-121`), and the sheet binds to the card handed in. `prepare_actions_sheet_test.dart:185` and `:220` pin both the row's presence and that the correct card id plus `inviteCategoryId` reach the composer. |
| AC-3 | PASS | Proven at flow level, not by inspection: `activity_card_detail_screen_test.dart`'s `_RouteRecorder` walks the whole card → sheet → row path and asserts every pushed route `isNot(isA<PageRoute<dynamic>>())`, plus `BottomNavigationBarItem` findsNothing. A second source scan bans `MaterialPageRoute`, `Navigator.push`, `routes:`, `onGenerateRoute`, `PopupMenuItem` in the entry file (`prepare_actions_sheet_test.dart:284`). See D-C2 for what this still does not cover. |
| AC-4 | PASS | The sheet opens with the first frame rendered from card fields; `invite_composer_cubit_test.dart:344` asserts the stored input holds `activity`/`date`/`time`/`place`/`duration` with real card values ("Xem phim Dune", "Rạp CGV Vincom", "tối"). P6 adds the `location` input the AC needs: `card_detail_location_field` writes on blur, and `activity_card_detail_screen_test.dart` proves the card handed to "Chuẩn bị" carries the just-typed place. |
| AC-16 | PASS | OS Share Sheet only. No channel button, no contact entry: the sheet test scans all visible text against `Zalo`, `Messenger`, `SMS`, `Gửi`, `Số điện thoại` and asserts exactly one `CupidPrimaryButton` (`invite_composer_sheet_test.dart:430-449`). A source scan over the three P5 lib files bans `ShareResult`/`ShareResultStatus`, so no delivery status can be derived (`:507`). Slice B independently confirmed the store has no channel column. See D-C3. |

## 3. Round-1 Patch Verification (F-3, F-5)

**F-3 — BUG-20260910-001, `location` dropped on unrelated edits. FIXED,
verified directly.**
`activity_card_detail_cubit.dart:496` now reads
`location: clearLocation ? null : location ?? card.location`, which is
character-for-character the same carry-forward shape as every sibling nullable
column in `_withEdits` (`note` at `:478`, `sourceLink` at `:479`,
`noteKeywords` at `:489`, `linkSavedAt` at `:495`). The new `editLocation`
mutator maps an emptied field to `clearLocation: true` rather than to `''`
(`:206-211` of the diff). All four reachable paths are covered by
`activity_card_detail_cubit_test.dart`: a `_persist` edit of another field, a
`_writeStatus` transition, type-place-then-edit-note, and
clear-place-then-edit-title. The `normalizeLocation` boundary is separately
unit-tested for `''`, whitespace, and `\n\t`.

**F-5 — visual-fidelity re-capture. Code change confirmed present.**
Per the handoff I checked only that the code change is in the diff, not the
PNGs. It is: `ActivityCardDetailScreen` now hoists the repository into `store`,
passes a `prepareActions` seam into `_ActivityCardDetailBody`, and the
`ActivityCardPrimaryAction.prepare` case replaces the entire
`ScaffoldMessenger...showSnackBar("Phần chuẩn bị nằm ở bước sau.")` block with
`await widget.prepareActions(context, cubit.state.card)`. A regression test
asserts the string `'bước sau'` no longer appears anywhere in that file.

One detail worth recording because it is easy to get wrong and was got right:
the CTA hands over `cubit.state.card`, the emitted card, not the constructor's
`card`. That is why a place typed seconds earlier reaches the composer's
`{place}` variable, and it is pinned by its own test.

## 4. Blocking Findings

None.

## 5. Deferred Findings

**D-C1 — the composer writes a full snapshot built from a card captured at
construction time.**
`InviteComposerCubit` stores `_card` at construction and `share()` writes
`_invitedEdit(_card)` — every column, from that snapshot. If anything mutated
the card between sheet open and the share tap, those edits would be silently
rolled back. Today nothing can: the composer is a modal sheet over the detail
screen, and the card it receives is the freshly emitted `cubit.state.card`. So
there is no defect against any AC now. It is the same full-snapshot hazard class
as F-3, one layer up, and this is the shared-foundation entry STORY-007/008
reuse — worth a re-check the first time a non-modal or long-lived composer
appears.

**D-C2 — `_invitedEdit` is a second hand-maintained copy of the column list.**
`invite_composer_cubit.dart:285-303` spells out all 17 fields, and `_withEdits`
spells them out again. Adding a column to `ActivityCard` now requires editing
both, plus the `_withLocation` test helper. The doc comment explains why
`ActivityCardEdit` cannot be copied instead (no `copyWith`, writes are
full-snapshot), which is correct. Mitigated in practice:
`invite_composer_cubit_test.dart:400-427` compares every single field against
`ActivityCardEdit.from(card)`, so a forgotten column fails a test rather than
corrupting a row. Noting the duplication, not asking for a change.

**D-C3 — AC-16's "không tích hợp API nhắn tin" is verified at source-scan and
visible-text level, never at the dependency level.**
The scans cover the four new lib files and the rendered sheet. Nothing asserts
that the app's dependency manifest carries no messaging SDK, and nothing bans a
`sms:`/`tel:`/`whatsapp:` URL scheme reaching a launcher from elsewhere. That is
out of this slice's file list and arguably out of the story's, but AC-16 is
phrased about the app, not about these files. Recommend the final-synthesis pass
decide whether a manifest-level assertion belongs to this story or to a
requirement-level gate.

**D-C4 — AC-3's route ban is proven for this flow, not for the app shell.**
The `_RouteRecorder` test is genuinely strong for the card → sheet → composer
path, and it is the right level to test at. But AC-3's subject is the main menu
and tab bar, which this story does not touch and this slice cannot see. A future
story could add an "Xuất lời mời" destination without failing anything here.
No action now; recorded so the AC is not read as globally enforced.

**D-C5 — three surfaces now carry their own file-local bilingual helper.**
`_composerText`, `_prepareText`, and the pre-existing `activityHubText` are the
same function three times, because `mobile/lib/l10n/` sits outside this story's
write scope. Each one documents that reason honestly. This is scope-correct and
the right call under the constraint; it is also three places to update when the
l10n consolidation finally happens.

## 6. Notes On The Slice

**N-C1 — the empty-state discipline is applied twice, at both levels.**
`_resolveActions` resolves the pack *before* the "Chuẩn bị" sheet is shown, so a
category whose pack is missing or empty produces no row rather than a row that
opens an error; `InviteComposerCubit.load` applies the same rule one level down.
Both a zero-preset pack and a completely absent asset are tested, and the
missing-asset test additionally scans visible text for "lỗi"/"Lỗi" to prove no
error surface leaked. This is the behaviour AC-27 asks for, implemented as a
policy rather than as a special case.

**N-C2 — the pack is loaded twice per entry, and that is free.**
The entry surface loads the pack to decide whether the row exists, then
`showInviteComposerSheet` loads it again through the cubit. Slice A established
that `PresetCatalogue` memoises the parse `Future` per category, so the second
call is a cache hit. Correct today; the memoisation is now load-bearing for
entry-surface responsiveness, which it was not before P6.

**N-C3 — the "no count" rule is enforced by scan at three levels.**
Chip strip (no count, no position, no terminator, by construction), sheet (regex
`\d+\s*(/|của|trên)\s*\d+` over all visible text, with the invite body itself
deliberately excluded and the exclusion justified in a comment), and cubit
(source scan banning `totalFrames`, `presetCount`, `remaining`). The body
exclusion is the interesting one: a `d/M` date inside pack content reads like an
"n/m" counter, and the test draws the line at chrome-versus-content rather than
weakening the regex.

**N-C4 — one collaborator outside the declared file list was read.**
`card_detail_overflow_menu.dart`, because story AC-6's binary reply control
lives there and no file in the declared list could evidence it. It is
STORY-001-owned, unchanged by this story's diff, and no finding is filed
against it.

**N-C5 — doc drift in the F-3 test group, harmless.**
The group comment in `activity_card_detail_cubit_test.dart:71-74` says "These
three cases are the paths that reach `_withEdits`" and is followed by four
tests. The fourth (clear-then-edit) is a real additional path, so the tests are
right and the sentence is stale. Cosmetic.

REVIEW_SLICE_COMPLETE: YES
