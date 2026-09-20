# STORY-003 Scoped Review — Slice D: Journal composer screen (P4)

- Outcome: `PARTIAL_SLICE_ONLY`
- Date: 2026-09-08
- Reviewer: Iris-QC (slice D of 5)
- RunId: `RUN-REQ-016_solo_stage1_relationship_assistant-STORY-003-reviewer-sliceD`
- BaseHead: `62f451733d191b666b718b595ead4621676e3e1c`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-003`

This is a scoped slice, not a story verdict. Slices A/B/C are closed and were
not re-opened.

## 1. Slice scope

Files diffed at `BaseHead` and reviewed (6, all paths relative to the worktree):

| File | Lines | Status |
| --- | --- | --- |
| `mobile/lib/features/journal/presentation/journal_composer_cubit.dart` | 299 | reviewed in full |
| `mobile/lib/features/journal/presentation/screens/journal_composer_screen.dart` | 315 | reviewed in full |
| `mobile/test/features/journal/journal_composer_cubit_test.dart` | 305 | reviewed (ranged) |
| `mobile/test/features/journal/journal_composer_screen_test.dart` | 604 | reviewed (ranged) |
| `mobile/lib/l10n/arb/app_en.arb` | 227 | reviewed via diff |
| `mobile/lib/l10n/arb/app_vi.arb` | 1006 | reviewed via diff |

Not opened: everything outside this list, including
`journal_media_store.dart` and `journal_repository.dart` internals (slice B).

## 2. AC anchors used

From `story_master.md:49-60` (the story's own 5-item AC list):

- **AC-2** — an entry written with a photo is kept and shown only in the
  author's own journal.
- **AC-3** — the app offers no share/export function for any entry.

## 3. Risk-item verdicts

### R-D1 — AC-2 persist: the save path writes the entry. **PASS**

`journal_composer_cubit.dart:234-275` is the only write path.
`save()` guards on `state.canSave` (`:236`), then calls
`_repository.saveEntry(...)` with the entry id, body, and attachment source
paths (`:241-247`). The entry id is fixed at construction (`:82-96`), so edit
mode rewrites the same row rather than minting a second one.

Test evidence — `coding-plan/test-results.md:606-611`,
`flutter test --no-pub test/features/journal/journal_composer_cubit_test.dart`
→ `+10: All tests passed!`, run against a real `JournalRepository` on
`NativeDatabase.memory()` and a real `JournalMediaStore` on a temp dir
(`test-results.md:613-617` — no mocks in the persistence path).
Concrete cases: `journal_composer_cubit_test.dart:71-79` (blank save persists
body + `origin: manual`), `:161-180` (edit save keeps the same id, one row).

### R-D2 — AC-2 private: nothing leaves the device on the save path. **PASS**

Neither slice file imports a network, share or clipboard client:

- `journal_composer_cubit.dart:1-9` — `dart:io`, `dart:math`, `flutter_bloc`,
  `image_picker`, and three in-feature files.
- `journal_composer_screen.dart:1-10` — `dart:io`, `design_system`,
  `material`, `flutter_bloc`, and four in-feature/l10n files.

`save()` (`journal_composer_cubit.dart:234-275`) calls exactly two
collaborators: `_repository.saveEntry` and `_mediaStore.resolvePhoto`. There
is no AI call, no upload, and no analytics emission on the path.
The composer is a plain `Cubit`, explicitly not a `HydratedCubit`
(`journal_composer_cubit.dart:17-22`), so no unsaved body is serialized to
disk. Corroborated by the phase's forbidden-import check,
`test-results.md:697-707`.

Residual risk (low, non-blocking) — this property is asserted by review and by
prose in `test-results.md`, not by an executable test. A future import of
`share_plus`/`dio`/`Clipboard` into this feature would not fail any suite. The
AC-3 absence check (R-D3) is test-enforced; this one is not.

### R-D3 — AC-3: no share/export/copy affordance on this screen. **PASS**

The composer's entire control surface is four interactive elements, and none
of them exports:

- back / `maybePop` — `journal_composer_screen.dart:113-117`
- save — `:119-123`
- detach one photo — `:266-277`
- attach photo (opens the OS picker) — `:303-311`

The toolbar holds exactly one action and no hidden or disabled sibling
(`:284-315`). No `Share.share`, `share_plus`, `Clipboard`, deep link, or
`Intent` appears in either file.

Test evidence — `journal_composer_screen_test.dart:415-468`, run in **both**
locales (`:420`): 17 forbidden `IconData` values are asserted absent
(`:432-456`), led by the design system's own `CupidIcons.share`,
`CupidIcons.iosShare`, `CupidIcons.link` — the correct leading assertion,
because the composer draws from `CupidIcons`, so a share glyph would arrive
from there before it arrived from Material. A
`chia sẻ|xuất|sao chép|gửi|in ra|share|export|copy|send|download|back ?up|pdf`
regex is then applied to every readable string in the built tree
(`:458-466`).
Suite result — `test-results.md:636-643`,
`flutter test --no-pub test/features/journal/journal_composer_screen_test.dart
--dart-define=CAPTURE_VISUALS=true` → `+13: All tests passed!`.

Residual risk (low, non-blocking, platform-level) — the body `TextField`
(`journal_composer_screen.dart:183-196`) does not set
`enableInteractiveSelection: false`, so the OS text-selection menu (which on
iOS includes *Share…* and *Copy*) is reachable on the body text. This is a
platform control, not an app affordance, so it does not breach AC-3 as
written ("app **không** cung cấp bất kỳ chức năng chia sẻ/xuất nào"), and
suppressing it would break ordinary text editing. Recorded so the decision is
explicit rather than accidental; no change recommended in this story.

### R-D4 — F-B2 (slice B) call-site confirmation. **PASS — not reachable through the composer's normal edit flow**

The composer is indeed the caller that triggers `saveEntry` on photo
replacement (`journal_composer_cubit.dart:241-247`). It does **not**, however,
leave slice B's orphan behind on the ordinary edit path: it compensates at the
call site.

`_supersededRelativePaths` (`:176`) is loaded from the entry's stored photos
when edit mode reads back (`:191-193`), captured before the write (`:240`),
and every superseded file is resolved and deleted after the write commits
(`:255-260`). The list is then re-seeded from the freshly saved photos
(`:261-263`), so a second edit in the same session is also covered.

User action that would otherwise trigger F-B2 — *user opens a saved entry with
a photo, removes that photo (and optionally adds another), then taps "Lưu"*.
This is directly tested: `journal_composer_cubit_test.dart:182-208` asserts
the previously stored file `storedBefore.existsSync()` is `false` after the
edit save, i.e. the dropped photo is gone from disk, not merely dereferenced.

So F-B2 remains a real defect in the store/repository layer (slice B's
finding, untouched here), but the composer is not a live exploit path for it —
except under R-D5 below, which is the one case where the compensation is
skipped.

### R-D5 — Save is not gated on `isReady` in edit mode. **FAIL (new finding F-D1, medium)**

`JournalComposerState.isReady` exists specifically to mark that an edit-mode
entry has not been read back yet (`journal_composer_cubit.dart:43-44`), and
edit mode starts at `isReady: false` (`:128`). **Nothing consumes it.**
`journal_composer_screen.dart` never references `isReady` in any of its 315
lines, and `save()` guards only on `canSave` (`:236`), which is
`!isSaving && (bodyText.trim().isNotEmpty || photoPaths.isNotEmpty)`
(`:52-53`) — no readiness term.

Reachable sequence:

1. User opens a saved entry for editing — `journal_composer_screen.dart:58-64`
   builds `JournalComposerCubit.editing`, whose factory fires `_loadExisting()`
   **un-awaited** (`journal_composer_cubit.dart:130`).
2. The body field is `autofocus: true` (`journal_composer_screen.dart:187`), so
   the keyboard is already up while the DB readback is in flight.
3. The user types one character before the readback emits. `bodyChanged`
   (`journal_composer_cubit.dart:203`) makes `bodyText` non-empty, so `canSave`
   flips true and the save button enables (`journal_composer_screen.dart:121`).
4. The user taps "Lưu". `save()` runs with `state.photoPaths` still `[]` and
   `_supersededRelativePaths` still `const <String>[]` (`:176`, not yet
   assigned by `:191-193`).

Two consequences:

- **Silent data loss.** `saveEntry` overwrites the entry in place with the
  single typed character; the user's original body is gone with no undo. AC-4
  makes deletion deliberate and confirmed; this loses a kept entry with
  neither.
- **F-B2 orphan, this time real.** The `journal_photos` rows are replaced by
  an empty photo list while the cleanup loop (`:255-260`) iterates the empty
  superseded list, so the entry's photo files stay on disk unreferenced. This
  is exactly the condition slice B described, and R-D4's compensation does not
  fire here.

The race window is short (a local sqlite readback), which is why this is
medium and not high, but the loss is unrecoverable and it lands on the one
data class this story exists to protect.

Test status — **UNVERIFIED / not covered**. Every edit-mode case in
`journal_composer_cubit_test.dart` calls `await settle()` before mutating or
saving (`:101`, `:170`, `:200`), so the pre-ready window is never exercised.

Suggested fix (single expression, for the owning lane to apply, not applied
here) — add the readiness term to the gate at
`journal_composer_cubit.dart:52-53`:

```dart
bool get canSave =>
    isReady && !isSaving && (bodyText.trim().isNotEmpty || photoPaths.isNotEmpty);
```

and add a cubit test that calls `bodyChanged` + `save()` before `settle()` and
asserts the stored entry is unchanged.

### R-D6 — Locale key parity for the composer's new strings. **PASS**

The composer resolves 7 l10n keys: `journal_composer_title`,
`journal_composer_edit_title`, `journal_composer_save`,
`journal_composer_placeholder`, `journal_composer_attach`,
`journal_composer_photo_label`, `journal_composer_remove_photo`
(`journal_composer_screen.dart:110-111, 122, 193, 256, 271, 308`).

All 7 are present in both `mobile/lib/l10n/arb/app_vi.arb` (template, each with
an `@`-description) and `mobile/lib/l10n/arb/app_en.arb`. No key is defined in
one locale only. `test-results.md:602` records the same count ("7 keys each").

## 4. Minor / non-blocking observations

- **F-D2 (documentation, trivial).** Source comments in both slice files cite
  AC ids that do not exist in this story's 5-item AC list — `AC-6` for the
  no-share invariant (`journal_composer_screen.dart:23, 285`) and `AC-13` for
  the no-draft/no-hidden-copy invariant (`:24, 115`;
  `journal_composer_cubit.dart:21, 233`). The invariants themselves are
  correct and map to `story_master.md` AC-3 and AC-2/AC-4 respectively; only
  the reference numbers are off, likely carried over from REQ-level or an
  earlier AC numbering. Traceability nit, no behaviour impact.
- **Static analysis** for this phase — `test-results.md:676-689`, `flutter
  analyze --no-pub lib/features/journal lib/core/journal test/features/journal`
  → 9 issues, all `info`, 0 warnings, 0 errors. The 5 in
  `journal_composer_cubit.dart` are `prefer_initializing_formals`, which is
  not expressible for private named fields; the justification given is
  correct.

## 5. Slice outcome

`PARTIAL_SLICE_ONLY`.

- PASS: R-D1, R-D2, R-D3, R-D4, R-D6
- FAIL: R-D5 (**F-D1** — `isReady` never gates save; edit-mode save-before-
  readback silently overwrites a saved entry and orphans its photo files)
- UNVERIFIED: no test covers the R-D5 window
- Carried forward unchanged: **F-B2** stays open as slice B's finding; slice D
  confirms the composer compensates for it on the normal edit path and is a
  live path to it only via F-D1.

No story-level verdict is issued from this slice.
