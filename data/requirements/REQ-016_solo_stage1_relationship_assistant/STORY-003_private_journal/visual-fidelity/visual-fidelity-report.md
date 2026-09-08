VISUAL_FIDELITY: PASS

# STORY-003 — Private journal, visual fidelity (P3 list, P4 composer)

## P3 — Journal list screen

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

## Verdict — P3

PASS. Every element the spec and the ACs bind is present and correct, and the
three largest visual differences are the design reference being stale against
its own spec, not the implementation drifting from it. The five deltas above are
cosmetic, none affects an acceptance criterion, and each is recorded for the
designer and for P5 rather than silently absorbed.

---

## P4 — Journal composer screen

- Phase: P4 (`coding-plan/phase-P4-journal-composer-screen.md`)
- Implemented: `implemented-s1:diary-compose-empty-ios.png` and
  `implemented-s1:diary-compose-photo-ios.png` (393x852 each)
- Design reference for the composer state: **none exists** — see the detection
  run below.

### Design-source detection was run, not assumed

Step A/B/C of `.claude/skills/mobile-dev/references/visual-fidelity.md` were
executed fresh for this phase rather than inherited from P3:

```
node <design-canvas-tool>/render-design-canvas.js --surface=cupid-ch-ng-1 --list-screens
node <design-canvas-tool>/render-design-canvas.js --surface=cupid-app       --list-screens
node <design-canvas-tool>/render-design-canvas.js --surface=cupid-ch-ng-1 \
  --screen=4-nhat-ky-rieng --platform=ios --out=/tmp/p4-design-probe
```

Findings:

1. `cupid-ch-ng-1` lists 29 screens, one of which is `4-nhat-ky-rieng`.
2. `cupid-app` lists a large inventory containing a dedicated `s1:*` family
   (`s1:mode`, `s1:empty`, `s1:list`, `s1:notebook`, `s1:skills`, `s1:diary`, …).
3. `4-nhat-ky-rieng` rendered at `--platform=ios` (415x900) and the story's
   existing `design-reference-s1:diary-ios.png` are **the same screen**:
   identical Vietnamese content ("Nhật ký", "chỉ mình đọc · 9 dòng"), the same
   three entry cards, the same privacy note, the same gradient pencil FAB. The
   only difference is a 4-tab versus 5-tab bottom bar.

**Correction to the P4 dispatch.** The dispatch stated that `s1:diary` "belongs
to a different, paired-mode app". The render above shows the opposite: `s1:` is
the Stage-1 / solo family inside the shared `cupid-app` canvas, and it resolves
to the same artwork as the solo journal screen in `cupid-ch-ng-1`. `s1:diary` is
the correct screen id for this story, and `story_master.md:9` already locks it
(`Design-Screen: s1:diary`). No screen id was carried over from another story;
this was re-derived from the canvases in this run.

### DESIGN_SOURCE_NOT_DETECTED for the composer state

Neither canvas holds a diary compose/write screen. Both show the compose
affordance only as the FAB on the list screen. This is the outcome phase file
section 6 predicted as normal for a new screen, so it is recorded rather than
worked around, and **no reference frame was fabricated or borrowed**.

With no canvas frame to diff against, the binding source of truth for P4 is
`ux/uiux-spec.md` sections 3, 4 and 6 plus the phase acceptance criteria. The
two frames were compared against those.

### How the frames were produced

Same route as P3, and for the same reason: no navigation reaches
`JournalComposerScreen` yet (the entry point is P5's, and `main_preview.dart`
and the router are both outside this phase's Write Scope). So the screen is
rendered through `RepaintBoundary.toImage` inside its own widget test at the iOS
reference viewport, with the real `buildCupidTheme(platform: CupidPlatform.ios,
brightness: Brightness.dark)` and the real widget tree, wrapped in the app's own
`CupidAppBackground` so the frame carries the real shell background instead of
the framework's default white. Reproduce with:

```
flutter test test/features/journal/journal_composer_screen_test.dart \
  --dart-define=CAPTURE_VISUALS=true
```

Two harness details worth naming, because both silently produce a misleading
frame if missed:

- The attached-photo fixture is warmed through `precacheImage` from
  `tester.runAsync` before the route opens. A `FileImage` first resolved by the
  widget starts its read inside the test's fake-async zone and never completes,
  which captures an empty preview tile that looks like a layout bug.
- Icons are drawn from `CupidIcons` (Material Symbols Rounded, a
  pubspec-declared font). Plain `Icons.*` glyphs rasterize as empty squares in a
  widget test because `MaterialIcons` is not a declared family.

### Frame-by-frame against `ux/uiux-spec.md` sections 3 and 4

`implemented-s1:diary-compose-empty-ios.png`:

- Full-screen route, not a bottom sheet (spec section 3: the body has no length
  bound). Correct.
- `CupidHeader` with a pink back chevron, pink title "Viết nhật ký", and a
  single trailing action "Lưu", rendered muted because the empty composer
  cannot be saved. Matches the spec's save-gating.
- Body opens on the fixed placeholder "Hôm nay có gì bạn muốn giữ lại?" in
  `colorTextMuted`. One preset string, never generated (BR-8).
- Bottom-left "Đính ảnh" with a `+` glyph is the whole toolbar. No share,
  export, copy, send or download affordance anywhere in the frame (AC-6).
- Background is the app's dark purple gradient shell with its star wash,
  consistent with the rest of the app.

`implemented-s1:diary-compose-photo-ios.png`:

- Body text set in the Nunito ramp at `colorText`, wrapping naturally.
- "Lưu" is now the full pink accent — the state carries content, so save is
  live. This is the only difference in the header between the two frames, which
  is exactly what the spec asks the affordance to communicate.
- One 88pt rounded attachment tile above the toolbar, with the detach control
  at its top-right corner.
- Still no share/export row beside the attachment (AC-6).

### Deltas and open items

1. **Detach glyph.** `CupidIcons` carries no `close`, so the detach control uses
   `CupidIcons.remove` (a dash). It is unambiguous with its tooltip and semantic
   label ("Bỏ ảnh này ra"), but a designer may want an `x`. Adding a glyph means
   editing `cupid_icons.dart`, which is outside this phase's Write Scope, so it
   is recorded rather than done.
2. **No canvas frame for the composer.** Recorded above as
   `DESIGN_SOURCE_NOT_DETECTED`. Worth a designer pass before P5 wires the entry
   point, so the composer gets a reference of its own.

## Verdict — P4

PASS. Every element sections 3, 4 and 6 of the UX spec bind for the composer is
present and correct in both frames, the absences the story is about (AC-6, BR-4,
BR-8) hold visually as well as structurally, and the one open glyph question is
a design-system gap recorded for the designer, not an implementation drift. The
missing composer reference is an honest detection outcome, not a waiver: no
frame from another story or another app was used in its place.
