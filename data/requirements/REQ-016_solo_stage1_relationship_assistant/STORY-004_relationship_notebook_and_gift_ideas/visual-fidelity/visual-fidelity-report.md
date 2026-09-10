VISUAL_FIDELITY: PASS

# STORY-004 — Notebook and skill profile, visual fidelity (P4)

Phase: P4 (`coding-plan/phase-P4-notebook-and-skill-screens-and-menu-entry.md`)

## Screens under audit

| Design-Screen | Design reference | Implemented |
| --- | --- | --- |
| `2-so-tay-nguoi-yeu` | `design-reference-2-so-tay-nguoi-yeu-ios.png` (415x900) | `implemented-2-so-tay-nguoi-yeu-ios.png`, `implemented-2-so-tay-nguoi-yeu-ios-empty.png`, `implemented-2-so-tay-nguoi-yeu-md.png` (415x900 each) |
| `3-ho-so-ky-nang-phien-ban-toi` | `design-reference-3-ho-so-ky-nang-phien-ban-toi-ios.png` (415x900) | `implemented-3-ho-so-ky-nang-phien-ban-toi-ios.png`, `implemented-3-ho-so-ky-nang-phien-ban-toi-ios-empty.png`, `implemented-3-ho-so-ky-nang-phien-ban-toi-md.png` (415x900 each) |

Surface `cupid-ch-ng-1`, platform `ios` (the only platform the canvas publishes
for these two frames). Both implemented captures are rendered at the same
415x900 frame the reference was rendered at, so the pair compares without
rescaling either image.

## How the implemented captures were produced — and why not on a device

Not by a device screenshot. Both screens are pushed from the Me tab and hold
only locally written rows, so reaching a non-empty state on a device means
driving several taps through a screen whose entry point this very phase adds.
The repo's existing pattern for this case was used instead
(`mobile/test/features/reminders/visual_capture_support.dart`, STORY-021): a
`RepaintBoundary.toImage` render inside this story's own widget test, at the
iOS reference viewport, with the real `buildCupidTheme`, the real
`CupidAppBackground` shell and the real widget tree.

Harness: `mobile/test/features/context_notebook/visual_capture_test.dart`,
skipped unless `--dart-define=CAPTURE_VISUALS=true`, so the ordinary scoped
suite stays hermetic. Reproduce with:

```
flutter test test/features/context_notebook/visual_capture_test.dart \
  --dart-define=CAPTURE_VISUALS=true
```

The harness loads the four pubspec-declared families (Nunito, Roboto, Roboto
Mono, Material Symbols Rounded) off disk, plus the framework's
`MaterialIcons-Regular.otf` from `$FLUTTER_ROOT`, because a widget test ships
no asset bundle. Every capture was opened and read: all Vietnamese diacritics
render correctly and no glyph rasterises as a notdef box.

### Harness artifacts — not product defects

- **The iOS header title is washed out in every `-ios` capture.**
  `CupidHeader`'s iOS band is a `BackdropFilter`, and an offscreen
  `RenderRepaintBoundary.toImage()` has no backdrop layer to sample, so the
  title blurs to nothing. The same screens re-rendered with the opaque Material
  band (`implemented-*-md.png`) show `Sổ tay người yêu` and `Những gì bạn giỏi`
  in place. `notebook_screen_test.dart` and `skill_profile_screen_test.dart`
  also assert the titles by text.
- **No iOS status bar or home indicator.** The design reference includes device
  chrome; a direct widget render does not.

## Authority note

Where the design reference and `ux/uiux-spec.md` disagree, the spec wins — it is
the story's binding UX artifact and the canvas frame predates it. Everything
under `DESIGN_SPEC_CONFLICT` below is that case: these are **not**
implementation gaps and must not be "fixed" toward the canvas.

## DESIGN_SPEC_CONFLICT — design reference contradicts binding requirements

### `2-so-tay-nguoi-yeu`

1. **Count subtitle under the title.** The reference renders
   `34 dòng · dày lên từ những câu hỏi lẻ`. AC-25 forbids a count or a
   "hoàn thiện hồ sơ" progress read on this screen. Implemented screen has no
   subtitle at all; `notebook_screen_test.dart` asserts the absence.
2. **Count-bearing group headers.** The reference renders `SỞ THÍCH · 21` and
   `SỰ KIỆN · 13`. Same AC-25 rule. Implemented headers are the group name and
   nothing else (`Sở thích`, `Sự kiện`).
3. **`Về Cún` / `Về mình` segmented switcher.** The reference puts a two-way
   switcher between the notebook and the skill screen inside one frame. The
   phase contract makes these two separate screens, each pushed from its own
   `Kho riêng của tôi` row. Implemented screens carry no switcher.
4. **Interests rendered as chips.** The reference renders interests as
   read-only chips with no per-item affordance. `uiux-spec.md` Phần B and AC-9
   require every written line to be editable and deletable through a `...`
   menu, which a chip has nowhere to carry. Implemented interests are rows with
   the `...` menu.
5. **One shared `Tự ghi thêm một dòng` row.** The reference has a single add
   row for the whole screen. The phase contract requires `+ tự thêm` per group,
   opening an inline add row with a 2-way segmented control in that same row.
   Implemented screen has one per group.
6. **Bottom 4-tab bar.** The reference frames the screen inside a
   `Muốn làm / Ý tưởng / Sổ tay / Nhật ký` tab bar. This screen is a pushed
   route off the Me tab, not a tab; STORY-003 AC-17 fixes that placement.
   `me_screen_context_rows_test.dart` asserts no `TabBar` is present after the
   push.
7. **Explainer card at the bottom.** The reference closes with a
   `Chỉ ghi sở thích và sự kiện…` paragraph card. AC-8 requires the empty and
   populated states to stay neutral, with no inviting or instructional copy.
   Implemented screen has none.

### `3-ho-so-ky-nang-phien-ban-toi`

8. **Count subtitle.** The reference renders
   `11 thứ bạn làm được — đủ để nghĩ ra quà tự tay`. AC-25, as above.
9. **`LÀM ĐƯỢC BẰNG TAY` / `THỨ KHÔNG AI GỌI LÀ KỸ NĂNG` sub-groups.** The
   reference splits the list in two and ranks the user's own answers. AC-12
   requires a flat name-only list. `skill_profile_screen_test.dart` asserts no
   sub-group heading appears once the list has entries.
10. **Per-skill effort annotations and leading tier glyphs.** The reference
    renders `~2 giờ một lần làm` / `~40 phút` under each skill, behind a
    bar-chart and a wand icon. AC-12 forbids a score, a level bar and a tier
    badge. The implemented row renders exactly one `Text` — the name — which
    that test asserts by walking the row's descendants.
11. **`TỪ ĐÂY LÀM ĐƯỢC` count/CTA card linking to Gợi ý quà.** The reference
    closes with `6 món quà tự tay và 3 buổi đi chơi…` plus a
    `Xem trong Gợi ý quà` button. It is both a count (AC-25) and a cross-link
    into `gift_ideas`, which is outside this phase. Implemented screen has
    neither.
12. **Bottom 4-tab bar.** Same as item 6.

## Matched against the reference

- Dark sky wash canvas, card surface fill, card radius and row rhythm.
- Muted small-caps group header treatment above each group.
- Accent-purple text-button treatment for the add affordance.
- Value on the first line with the user's own note in muted caption underneath.
- Vietnamese typography, including diacritics, at every weight used.

## Forbidden surfaces — verified absent in the captures and in the tree

No share, export or copy-all icon or action anywhere on either screen,
including inside the `...` menus; no Share Sheet; no streak, badge,
leaderboard or paywall widget; no skill level, score or tier badge; no progress
indicator. Asserted by `expectNoBannedSurfaces()` in both screen tests and
confirmed by reading every capture.

## Observation for the reviewer — not a P4 defect

In `implemented-2-so-tay-nguoi-yeu-ios.png` the three interests read
newest-first, while `implemented-2-so-tay-nguoi-yeu-md.png` — the same
repository, re-rendered moments later — reads oldest-first. All five rows are
written inside the same millisecond by the capture harness, so
`ContextNotebookRepository.entries()` appears to have no stable tie-break when
`createdAt` ties. That ordering lives in the P1 repository, outside this
phase's Write Scope, so it is recorded here rather than changed.
