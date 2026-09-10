# STORY-003 Scoped Review — Slice C: Journal list screen + delete flow (P3)

- Reviewer: Iris-QC-4
- Date: 2026-09-08
- Mode: scoped-slice (Slice C of A–E + synthesis pass F)
- Outcome: `PARTIAL_SLICE_ONLY` — 0 must-fix, 3 observations, 1 inherited risk
- Story: STORY-003 (REQ-016)
- Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-003`
- BaseHead: `62f451733d191b666b718b595ead4621676e3e1c`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-003`

This slice does NOT issue a story-level verdict. It covers only the P3 list
screen, the list cubit, and the two delete flows. Schema/DAO is slice A; media
store, repository and backup exclusion are slice B; composer, entry point and
visual fidelity are slices D–E.

## Files reviewed (diff-scoped)

| File | Δ |
|---|---|
| `mobile/lib/features/journal/presentation/screens/journal_screen.dart` | +440 (new) |
| `mobile/lib/features/journal/presentation/journal_list_cubit.dart` | +115 (new) |
| `mobile/test/features/journal/journal_screen_test.dart` | +467 (new) |
| `mobile/test/features/journal/journal_list_cubit_test.dart` | +224 (new) |

Evidence read: `coding-plan/test-results.md` `## Phase P3` (`:429-543`, ranged);
`story_master.md:49-60` (AC list); `ux/uiux-spec.md:48,55-66` (delete pattern,
queried by line, not full-read); `architecture/solution.md:11-12,136-150,175`
(AC-id mapping, queried). `mobile/lib/l10n/arb/app_vi.arb` and `app_en.arb` were
read only as `git diff <BaseHead>` additions, for the copy this slice's two
screens render.

## AC-id namespace note (not a defect)

`story_master.md` numbers its acceptance criteria 1–5. The source, plan and
tests cite the requirement-level expansion used by
`architecture/solution.md:11-12` (AC-6..AC-14). The mapping used throughout
this report:

| story_master | requirement-level | Subject |
|---|---|---|
| AC-1 | AC-1, BR-4 | Neutral empty state, no streak/goal/count |
| AC-3 | AC-6, AC-7, AC-10 | No share/export/copy affordance |
| AC-4 | AC-11, AC-13 | Single-entry delete, irreversible, no undo |
| AC-5 | AC-12, AC-13 | Delete-all in one operation, no undo |

Two live numbering namespaces is traceability friction for the synthesis pass,
not a code defect. Flagging it so slice F reads the code comments correctly.

## Risk items

| Id | Item | Verdict |
|---|---|---|
| RC-1 | AC-1 — empty state carries no streak/goal/count/progress language | **PASS** |
| RC-2 | AC-4 — single-entry delete is irreversible, no undo/trash, neutral dialog | **PASS** |
| RC-3 | AC-5 — delete-all is one operation, one dialog, no undo/trash | **PASS** |
| RC-4 | AC-3 — no share/export/copy/clipboard affordance anywhere on this screen | **PASS** |
| RC-5 | Test evidence exists and is green for this slice's two files | **PASS** |

### RC-1 — AC-1 empty state, PASS

`journal_screen.dart:152-173` `_JournalEmptyState` renders exactly one `Text`,
`l10n.journal_empty_body`, centred and muted. No illustration, no second CTA, no
counter widget. The copy is `"Chỉ mình bạn đọc được ở đây."` /
`"Only you can read what's here."` (`app_vi.arb` / `app_en.arb`, added at this
BaseHead) — a privacy statement, not an urge to write. There is no "chưa có mục
nào", no day counter, no goal.

Reinforcing absences:

- `journal_list_cubit.dart:32-37` deliberately exposes no count getter on
  `JournalListReady`; the state carries `entries` and `hasMore` only
  (`:23-30`), so no widget can bind to a total.
- `journal_screen.dart:114-125` renders `JournalListLoading` as the empty state
  rather than a spinner, explicitly to avoid the "tiến trình" AC-1 forbids.
  There is no `LinearProgressIndicator`/`CircularProgressIndicator` in the file.
  Because the empty copy asserts privacy rather than emptiness, the first-frame
  flash cannot state anything false to a user who does have entries.
- Row metadata is a plain formatted date (`journal_screen.dart:268-276`, ARB
  `journal_entry_date` = `{date}` with `format: yMMMd`), not a day index.

Enforced by test: `journal_screen_test.dart:260-291` walks every rendered `Text`
at 0 and at 3 entries against `countLike` (`\d+\s*(mục|dòng|ngày|bài|entr(y|ies)|days?|notes?)`)
and `streakLike` (`chuỗi|liên tiếp|mục tiêu|streak|goal|progress|in a row`), plus
both progress-indicator types. This satisfies the phase file's
`STREAK_ABSENCE_TEST_UNRUNNABLE` minimum gate.

### RC-2 — AC-4 single-entry delete, PASS

Flow: `_JournalEntryMenu` (`journal_screen.dart:348-375`) → `_confirmDeleteEntry`
(`:68-79`) → `_showConfirmDialog` (`:410-440`) → `JournalListCubit.deleteEntry`
(`journal_list_cubit.dart:95-97`) → repository.

Irreversibility, verified in-slice:

- The cubit copies nothing into an undo buffer; `deleteEntry` is a one-line
  delegation to the repository (`journal_list_cubit.dart:97`).
- No `SnackBar`, `SnackBarAction`, trash list, archive flag or restore path
  exists anywhere in the 440-line screen file or the 115-line cubit.
- `journal_screen.dart:409` records the intent explicitly, and
  `journal_screen_test.dart:414-415` asserts `find.byType(SnackBar)` is
  `findsNothing` after a delete.

Dialog neutrality (`ux/uiux-spec.md:57-58` requires "hộp thoại xác nhận trung
tính ('Xoá mục này?' / Huỷ / Xoá màu `--red`) — không hỏi lý do"):

- Title `journal_delete_entry_title` = `"Xoá mục này?"` / `"Delete this entry?"`;
  no body; actions `"Huỷ"` and `"Xoá"` with `colors.colorRed`
  (`journal_screen.dart:426-435`). No reason prompt, no shame or guilt framing,
  no "bạn có chắc không muốn giữ lại kỷ niệm này" style copy. Matches the spec
  string literally.
- Dismissing the barrier returns `null`, coerced to `false`
  (`journal_screen.dart:439`), so an accidental tap-outside cannot delete.

Tested: `journal_screen_test.dart:356-394` (confirm path removes the row and the
repository no longer resolves it; cancel path keeps it) and
`journal_list_cubit_test.dart:153-167` against a real drift database.

### RC-3 — AC-5 delete-all, PASS

Flow: `_JournalHeaderMenu` (`journal_screen.dart:379-406`) → `_confirmDeleteAll`
(`:81-93`) → same neutral dialog → `JournalListCubit.deleteAll`
(`journal_list_cubit.dart:101-108`).

- One dialog, one confirm. No second step and no retype-to-confirm, exactly as
  `ux/uiux-spec.md:59-63` requires ("không hai bước, không gõ lại chữ 'XOÁ'").
- Copy: title `"Xoá toàn bộ nhật ký?"`, body `"Toàn bộ mục và ảnh sẽ bị xoá khỏi
  máy này."`, confirm `"Xoá toàn bộ"`, cancel `"Huỷ"`. The body states the scope
  of the deletion; it carries no guilt framing and no "bạn sẽ mất..." loss copy.
- `deleteAll` also resets `_limit` to one page (`journal_list_cubit.dart:106`),
  so the screen returns to the first-open state rather than a scrolled-open one
  — matching `ux/uiux-spec.md:63-64`.
- No hidden trash: `ux/uiux-spec.md:65-66` forbids it, and nothing in this slice
  creates one.

Tested: `journal_screen_test.dart:397-417` (list empties, empty state returns,
no `SnackBar`) and `journal_list_cubit_test.dart:169-191` (real DB; repository
empty and window reset verified by re-seeding).

### RC-4 — AC-3 no share/export, PASS

Read both source files end to end. Neither contains `Share`, `Share.share`,
`share_plus`, `SharePlus`, `Clipboard`, `Clipboard.setData`, `launchUrl`, a
deep-link or scheme construction, a file-export/save-as call, or any network
client. The only two outbound calls the screen makes are
`mediaStore.resolvePhoto` (`journal_screen.dart:322`) and the two cubit delete
methods.

Structural containment, which is the part worth keeping:

- `enum _JournalMenuAction { deleteEntry, deleteAll }`
  (`journal_screen.dart:25`) is a closed set, so an added menu action is a
  visible source change rather than an inline literal.
- Tapping a row expands text in place (`journal_screen.dart:235-258`) instead of
  pushing a reader route, so there is no second surface that could grow its own
  share affordance (`:236-239`).
- Both menus hold exactly one row (`:363-372`, `:394-402`).

Enforced by two tests: `journal_screen_test.dart:293-353` asserts no share-like
`Icon` (10 glyphs incl. `Icons.share`, `ios_share`, `content_copy`, `download`,
`send`, `link`) and no label matching
`chia sẻ|xuất|sao chép|gửi|share|export|copy|send|download|back ?up`, in the
list and inside both opened menus, and asserts `PopupMenuEntry` count == 1 for
each — which is what makes "no hidden export row beside delete" checkable rather
than assumed. `journal_list_cubit_test.dart:193-223` is the import-level gate:
neither file may import `share_plus`, `dio`, `cupid_api`,
`RealtimeCoordinator`, `Clipboard`, `hydrated_bloc` or `cached_network_image`.
This satisfies the phase file's `PRIVACY_EGRESS_GATE_UNRUNNABLE` minimum gate.

### RC-5 — test evidence, PASS

`coding-plan/test-results.md:429-472`, Phase P3, Status **COMPLETE**:

- `flutter test test/features/journal/journal_list_cubit_test.dart test/features/journal/journal_screen_test.dart`
  → `+19 ~2: All tests passed!` (10 cubit + 9 widget; the 2 skips are the
  `CAPTURE_VISUALS` capture tests). `test-results.md:462-464`.
- `flutter analyze lib/features/journal lib/l10n test/features/journal`
  → 3 `info` issues, all pre-existing in the P2 file
  `journal_repository.dart:25-27`; zero in either file this slice owns.
  `test-results.md:456-461`.
- `flutter gen-l10n` OK, `l10n-untranslated.json` = `{}`, so the two ARB files
  stayed key-identical. `test-results.md:453-455`.

The counts in the evidence match the files: `journal_list_cubit_test.dart` has
10 `test(...)` cases (including the 2 parameterised egress-gate cases) and
`journal_screen_test.dart` has 9 non-capture `testWidgets` plus the 2 skipped
capture tests. Evidence and code agree.

## Observations (non-blocking)

**F-C1 — both popup menus ignore the selected value.**
`journal_screen.dart:362` (`onSelected: (_) => onDelete()`) and `:393`
(`onSelected: (_) => onDeleteAll()`) discard the `_JournalMenuAction` they
receive. Correct today because each menu builds exactly one row, and
`journal_screen_test.dart:338,351` pins that row count. But the enum has two
values and the handler pattern-matches neither: if a future row is ever added to
either menu, selecting it silently fires delete. Cheap hardening is a `switch`
on the value. Not a must-fix — the row-count assertions fail first if a row
appears — but the failure mode is destructive rather than inert, which is why it
is recorded.

**F-C2 — the compose CTA is a no-op in P3.**
`journal_screen.dart:139` calls `onCompose?.call()`, and `onCompose` defaults to
null (`:48-51`). The button is enabled and tappable in that state, so at the P3
commit a tap does nothing visible. `test-results.md:824` indicates P5 wires the
real callback through the entry point. This is a phase-ordering artefact, not a
shipped defect; slice E should confirm the wiring is actually present at the
story head rather than only planned.

**F-C3 — AC-id namespace divergence.** See the mapping table above. Worth one
line in the synthesis pass so a reader of `journal_screen.dart:29-32` does not
look for AC-6 in `story_master.md` and conclude the citation is wrong.

## Inherited risk (slice B scope, cited not re-verified)

**F-B1 (media store not owner-scoped)** reaches this slice's delete flow.
`JournalListCubit.deleteAll` (`journal_list_cubit.dart:101`) delegates to
`repository.deleteAll()`, which is the path slice B found operating on a media
root that is not per-user. If that finding stands, "xoá toàn bộ nhật ký" on a
shared device may delete or retain the wrong account's photo files — an AC-5
correctness consequence even though the defect itself is in P2 code. The list
screen and cubit add no owner filter of their own and cannot: they never see an
owner id. Resolution belongs to slice B's fix, not here; recording the reach so
the synthesis pass does not scope the fix to the repository alone.

**F-B2 (orphan file on entry edit)** does not reach this slice. The compensating
sweep this slice owns — `JournalListCubit._start` calling
`repository.sweepOrphans()` exactly once on feature open
(`journal_list_cubit.dart:59-66`, asserted by
`journal_list_cubit_test.dart:102-111`) — is present and correct as the AC-13
compensating half.

## Not covered by this slice

Composer screen and composer cubit (D), entry point / `me` tab row (E), visual
fidelity artefacts and `VISUAL_FIDELITY: PASS` (E), schema/DAO/migration (A),
media store / repository / backup exclusion (B). `test-results.md:538-543`
records the visual-fidelity result for P3; this slice did not verify it.

## Outcome

`PARTIAL_SLICE_ONLY`. All four named critical gates PASS with test enforcement,
not just source inspection. Nothing in this slice blocks the story. Carry F-C1,
F-C2 and F-C3 into the synthesis pass, and carry F-B1's reach into AC-5 into
slice B's fix scope.
