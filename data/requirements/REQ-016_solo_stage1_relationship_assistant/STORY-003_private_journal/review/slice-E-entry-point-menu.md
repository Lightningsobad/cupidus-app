# STORY-003 Scoped Review — Slice E: Journal entry point and "Tôi" menu row (P5)

- Outcome: `PARTIAL_SLICE_ONLY`
- Date: 2026-09-08
- Reviewer: Iris-QC (slice E of 5, last slice)
- RunId: `RUN-REQ-016_solo_stage1_relationship_assistant-STORY-003-reviewer-sliceE`
- BaseHead: `62f451733d191b666b718b595ead4621676e3e1c`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-003`

This is a scoped slice, not a story verdict. Slices A/B/C/D are closed
(`022ecf4`, `23883d4`, `a5aaa36`, `48896ad`) and were not re-opened. The
story-level verdict belongs to the separate final-synthesis pass.

## 1. Slice scope

Files diffed at `BaseHead` and reviewed (4, paths relative to the worktree):

| File | Change | Status |
| --- | --- | --- |
| `mobile/lib/features/journal/journal_entry_point.dart` | +90, new file | reviewed in full |
| `mobile/lib/features/account/presentation/screens/me_screen.dart` | +70, additive only | reviewed via diff (journal block only) |
| `mobile/test/features/journal/journal_entry_point_test.dart` | new, 9 cases | reviewed (ranged) + re-run |
| `mobile/test/features/account/me_screen_journal_row_test.dart` | new, 3 cases | reviewed (ranged) + re-run |

Two ranged reads outside the file list were needed and taken deliberately:
`journal_screen.dart:120-150` and `journal_list_cubit.dart` refresh mechanism —
both strictly to close **F-C2**, which slice C carried forward to this slice.
No other slice's scope was re-opened.

## 2. Anchors used

- `story_master.md:65` — "Điểm vào: đường vào trực tiếp từ menu chính (nhóm
  KHO). Không phải màn khoá vị trí."
- AC-17 (journal is its own route, not a sub-tab), cited via
  `ux/uiux-spec.md` §8 in the implementation's own doc comments.
- The **settled** P5 contract adjudication in `review/review-report.md`
  §"Adjudicated Item".

## 3. Risk-item verdicts

### R-E1 — Contract surface: no NEW cross-story symbol beyond the settled one. **PASS**

The `openJournalScreen(BuildContext)` question is already adjudicated as
**within contract intent** by the prior compact pass and is cited here as
settled, not re-litigated.

What this slice verified is only that nothing *further* was added.
`journal_entry_point.dart` declares exactly three top-level names and no more:
`JournalComposerSeed` (`:31`), `openJournalComposer` (`:57`), and
`openJournalScreen` (`:80`). A repo-wide search over `mobile/lib` for
`JournalScreen(`, `openJournalScreen`, `openJournalComposer`, and
`JournalComposerSeed` returns exactly one production consumer outside
`features/journal/**`:

```
mobile/lib/features/account/presentation/screens/me_screen.dart:560:
        onTap: () => openJournalScreen(context),
```

No DAO, repository, media store, cubit, or internal widget is re-exported, and
no read-back accessor was added — the one-way property AC-7 depends on holds at
this head. The only `JournalScreen(` construction in production code is
`journal_entry_point.dart:83`, so the "sole external opener" property the phase
spec asserts is factually true, not just documented.

### R-E2 — Discoverability: the row is reachable from the Tôi tab and navigates. **PASS**

`me_screen.dart` gains one additive block, `_PrivateStorageBlock`
(`:527-588`), inserted into the Tôi tab column at `:171-176`, above the
existing `_SettingsCard`. It renders a `caption`-styled heading from
`l10n.me_section_private_storage` and one `_MenuRow` with
`l10n.me_menu_private_journal`, `CupidIcons.lock`, and
`badgeTint: colors.colorMint`.

Strings resolve in both locales — `app_vi.arb:461` "Kho riêng của tôi",
`app_vi.arb:465` "Nhật ký riêng"; `app_en.arb:97-98` "My private storage" /
"Private journal". This matches `story_master.md:65`'s "menu chính (nhóm KHO)":
the entry is a direct menu row in a KHO-labelled group on the main Tôi tab, not
a locked or gated surface.

Navigation is real, not decorative: `onTap: () => openJournalScreen(context)`
(`:560`), which pushes a `MaterialPageRoute<void>` (`journal_entry_point.dart:81-89`).
Independently reproduced — see §4, `me_screen_journal_row_test.dart` case 2
asserts `find.byType(JournalScreen)` after the tap.

The block is written as a list (`rows`) with `showDivider: false` on its single
member, with a doc comment stating STORY-004 appends its rows there. That is
forward-shaped but not speculative code — it is one row today.

### R-E3 (F-C2, carried forward from slice C) — the list's compose CTA is wired, no longer a no-op. **PASS**

Slice C observed at the P3 head that `journal_screen.dart:139` was
`onPressed: () => onCompose?.call()` against a nullable `onCompose` that
nothing supplied — a live no-op. At the current story HEAD that is closed:

- `journal_screen.dart:139` is unchanged (`onCompose?.call()`), and the
  parameter is still nullable with a null default (`:38`, `:51`).
- The gap is closed at the construction site instead.
  `journal_entry_point.dart:83-87` is the **only** production construction of
  `JournalScreen`, and it always passes
  `onCompose: () => openJournalComposer(routeContext)`.

So every production path that can show the list also supplies the callback; the
null default is now reachable only from tests and harnesses. Verified by
execution, not by reading: `journal_entry_point_test.dart:313-323` taps the
list's own CTA and asserts `find.byType(JournalComposerScreen), findsOneWidget`.
That case passes (§4).

Follow-on check, since a wired CTA is only useful if the list reflects the
save: `journal_list_cubit.dart:68-84` subscribes to
`_repository.watchEntries(...)` as a stream, so a new entry propagates without
the entry point needing to await or forward the composer's return value. There
is no stale-list defect behind the `Future<void>` return that discards
`openJournalComposer`'s `String?` id.

## 4. Test evidence

Recorded evidence, `coding-plan/test-results.md` §"Phase P5 – Journal entry
point and 'Tôi' menu row" (`:745-830`):

- `test/features/journal/journal_entry_point_test.dart` — 9 cases, `+9: All tests passed!` (`:776-794`)
- `test/features/account/me_screen_journal_row_test.dart` — 3 cases, `+3: All tests passed!` (`:796-807`)
- regression `test/features/journal test/core/journal` — `+79 ~4: All tests passed!` (`:820-821`)
- regression `test/features/account/presentation/screens/me_screen_test.dart` — `+12: All tests passed!` (`:828-829`)

Re-run in this worktree by the reviewer, both green:

```
flutter test test/features/journal/journal_entry_point_test.dart
00:03 +9: All tests passed!

flutter test test/features/account/me_screen_journal_row_test.dart
00:00 +3: All tests passed!
```

AC-17 has a dedicated assertion rather than only a claim:
`me_screen_journal_row_test.dart:182-200` keeps `MeScreen` on the navigator
stack, asserts `find.byType(TabBar), findsNothing`, and asserts back-navigation
returns to the row — i.e. the journal is an independent route, not a tab switch.

Supporting visual evidence for the menu row exists at
`visual-fidelity/implemented-me-tab-private-journal-row-emulator-5554.png`;
grading it belongs to the visual-fidelity gate, not to this slice.

## 5. Observations (non-blocking, no action required in this slice)

- **O-E1** — `journal_entry_point.dart:83-86` captures the route builder's
  `routeContext` in the `onCompose` closure. It is sound as written (the
  closure can only fire while that route is mounted) and both navigations use
  the same `Navigator`. Noted only because a future refactor that defers the
  callback would need a mounted check.
- **O-E2** — the recorded P5 run notes two non-fatal `warnIfMissed` warnings in
  the pre-existing `me_screen_test.dart` "non-interactive rows" case
  (`test-results.md:832-834`), caused by the new block adding roughly 100px
  above those rows. The suite still passes at `+12`. Flagged for the synthesis
  pass as pre-existing-test drift, not a defect introduced by this slice.

## 6. Slice outcome

`PARTIAL_SLICE_ONLY` — all three named risk items (R-E1 contract surface,
R-E2 discoverability/navigation, R-E3/F-C2 CTA wiring) are **PASS** with
file:line evidence and reproduced test runs. Nothing in this slice's scope is
UNVERIFIED. No fixes were made and no story-level verdict is issued here.
