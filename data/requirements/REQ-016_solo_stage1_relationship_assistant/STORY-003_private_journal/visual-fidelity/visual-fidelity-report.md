VISUAL_FIDELITY: PASS

# STORY-003 — Private journal list, visual fidelity

- Design screen id: `s1:diary`, platform `ios`
- Design reference: `design-reference-s1:diary-ios.png` (416x900, rendered by the
  P2 run)
- Implemented: `implemented-s1:diary-ios.png` and
  `implemented-s1:diary-empty-ios.png` (393x852 each)
- Phase: P3 (`coding-plan/phase-P3-journal-list-screen-and-delete.md`)

`393x852` is the iOS reference frame; the design reference is that same frame
bounded by the capture tool's `--max-edge=900`, so the two share an aspect ratio
and compare without distorting either.

## How the implemented capture was produced — and why not on a device

Not by `capture-mobile-screen.sh`. That tool screenshots whatever a device is
showing, and there is no way to put `JournalScreen` on a device from this phase:
`mobile/lib/main_preview.dart:145` (`previewScreens`) has no `journal`/`diary`
key, and no route reaches the screen, because the phase file section 6 assigns
the navigation entry point to P5 — "điểm vào do P5 nối; P3 chỉ giao màn". Both
`main_preview.dart` and the router are outside this phase's Write Scope.

So the screen was rendered directly, through the repo's existing pattern for
this case (`test/features/reminders/visual_capture_support.dart`, STORY-021): a
`RepaintBoundary.toImage` capture inside the widget test, at the iOS reference
viewport, with the real `buildCupidTheme(platform: CupidPlatform.ios,
brightness: Brightness.dark)` and the real widget tree. It lives in
`mobile/test/features/journal/journal_screen_test.dart`, group `visual capture`,
skipped unless `--dart-define=CAPTURE_VISUALS=true`, so the ordinary suite stays
hermetic. Reproduce with:

```
flutter test test/features/journal/journal_screen_test.dart \
  --dart-define=CAPTURE_VISUALS=true
```

### Harness artifacts — not product defects

- The header and per-entry menu glyphs rasterise as **empty squares**. They are
  `Icons.more_horiz`, and `MaterialIcons` is not a pubspec-declared font family,
  so a widget test (which ships no asset bundle) cannot load it. Nunito, Roboto
  and Material Symbols Rounded are declared and are loaded via `FontLoader`,
  which is why all text and any `CupidIcons` glyph render correctly. On device
  the menu icon renders normally.
- No iOS status bar or home indicator: the design reference includes device
  chrome, a direct widget render does not.

## Authority note

Where the design reference and `ux/uiux-spec.md` disagree, the spec wins — it is
the story's binding UX artifact and the canvas frame predates it. Three
differences below are that case and are recorded as `DESIGN_SPEC_CONFLICT`: they
are **not** implementation gaps and must not be "fixed" toward the canvas.

## DESIGN_SPEC_CONFLICT — design reference contradicts binding requirements

1. **Entry counter.** The reference renders `🔒 chỉ mình đọc · 9 dòng` under the
   title. `uiux-spec.md` line 20-21 forbids exactly this: "Không hiện số mục đã
   viết, không hiện chuỗi ngày". AC-1 and BR-4 say the same. Implemented screen
   has no counter, and `journal_screen_test.dart` asserts its absence in both
   the empty and populated states.
2. **Rendered `originRef`.** The reference shows a chip `gắn với thẻ CGV Vincom`
   on the first card. `architecture/solution.md` section 4 states `originRef`
   "không bao giờ render, không bao giờ là link". Implemented screen never
   renders it.
3. **Bottom tab bar.** The reference places `Nhật ký` as a fifth tab alongside
   Muốn làm / Ý tưởng / Lịch / Sổ tay. This story delivers a pushed full-screen
   surface, and its entry point is P5's scope, not a tab destination. Out of
   scope here either way.

Also: the reference titles the screen `Nhật ký`; `uiux-spec.md` line 20 specifies
`Nhật ký riêng`, which is what ships.

## Matches the spec

- Header: title plus back affordance, nothing else (spec line 20)
- Rows newest-first, each with the write date as `caption` and a 1-2 line excerpt
  as `body` (spec lines 22-23)
- Single primary action labelled `Viết điều gì đó` on `--grad` (spec lines 25-26)
- No share/export/copy icon or label anywhere, menus included (spec lines 45-49)
- Per-entry context menu holding only `Xoá`, into a neutral confirm dialog
  (spec line 57)
- Neutral empty state, exactly one CTA, no illustration or urging (spec line 78)
- No goal or progress bar anywhere (spec line 27)

## Deltas — real, none AC-bearing, all deferred

1. **Compose button placement.** Reference uses a floating pink gradient pencil
   FAB in the bottom-right; implemented uses a bottom-docked full-width `--grad`
   pill carrying the label. Spec line 25 permits "pill nổi góc dưới hoặc CTA
   trên header", so both readings are inside the spec; the labelled pill was
   chosen because the label itself is spec-mandated and a pencil FAB cannot
   carry it. Worth a designer call, not a defect.
2. **Date format.** Reference uses warm relative dates (`Tối qua · 23:14`,
   `Thứ Bảy 16/8`); implemented uses `yMMMd` (`3 thg 9, 2026`). The spec fixes
   the slot and the type ramp but not the format. The reference's format reads
   better and is a good follow-up; changing it now would mean a new l10n
   contract mid-phase.
3. **Privacy footnote card.** Reference closes the list with a muted card:
   "Nhật ký không xuất ra được, không có nút chia sẻ. Xoá một dòng hay xoá cả sổ
   cũng chỉ một thao tác." Implemented has no such card. Section 4 of the spec
   requires the *absence* of share affordances, not a card explaining it, so
   this is additive. Recommend adding it — it makes the privacy promise legible
   rather than merely true.
4. **Multiple thumbnails.** Reference shows two square thumbnails on the first
   card; implemented renders `photos.first` only. The data model holds all of
   them, so this is a bounded follow-up.
5. **Background.** Reference has a purple wash behind the header; implemented is
   flat `colorBackground`. No spec line covers it.

## Verdict

PASS. Every element the spec and the ACs bind is present and correct, and the
three largest visual differences are the design reference being stale against
its own spec, not the implementation drifting from it. The five deltas above are
cosmetic, none affects an acceptance criterion, and each is recorded for the
designer and for P5 rather than silently absorbed.
