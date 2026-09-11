VISUAL_FIDELITY: PASS

# STORY-004 — Notebook, skill profile and gift ideas, visual fidelity (P4, P7)

Phases: P4 (`coding-plan/phase-P4-notebook-and-skill-screens-and-menu-entry.md`)
and P7 (gift ideas screen (5) and the hub quick-entry cell).

## Screens under audit

| Design-Screen | Phase | Design reference | Implemented |
| --- | --- | --- | --- |
| `2-so-tay-nguoi-yeu` | P4 | `design-reference-2-so-tay-nguoi-yeu-ios.png` (415x900) | `implemented-2-so-tay-nguoi-yeu-ios.png`, `implemented-2-so-tay-nguoi-yeu-ios-empty.png`, `implemented-2-so-tay-nguoi-yeu-md.png` (415x900 each) |
| `3-ho-so-ky-nang-phien-ban-toi` | P4 | `design-reference-3-ho-so-ky-nang-phien-ban-toi-ios.png` (415x900) | `implemented-3-ho-so-ky-nang-phien-ban-toi-ios.png`, `implemented-3-ho-so-ky-nang-phien-ban-toi-ios-empty.png`, `implemented-3-ho-so-ky-nang-phien-ban-toi-md.png` (415x900 each) |
| `5-goi-y-qua-thang-cong-suc` | P7 | `design-reference-5-goi-y-qua-thang-cong-suc-ios.png` (415x900) | `implemented-5-goi-y-qua-thang-cong-suc-ios.png`, `implemented-5-goi-y-qua-thang-cong-suc-md.png` (415x900 each) |

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

---

# P7 — `5-goi-y-qua-thang-cong-suc`

VISUAL_FIDELITY: PASS

## How the capture was produced

Same harness pattern as P4 and for the same reason: no device or simulator
runtime is reachable from this lane, and screen (5) is pushed from the hub's
quick-entry strip over a store that this phase itself fills. The capture is a
`RepaintBoundary.toImage()` render inside this story's own widget test at the
415x900 iOS reference viewport with `devicePixelRatio: 1`, the real
`buildCupidTheme`, the real `CupidAppBackground` shell and the real widget tree,
reading the real shipped packs off disk.

```
flutter test test/features/gift_ideas/gift_ideas_screen_test.dart \
  --dart-define=CAPTURE_VISUALS=true --name='captures'
```

The same four bundled families plus `$FLUTTER_ROOT`'s `MaterialIcons-Regular.otf`
are loaded.

**Third capture added in the design-anchor rework round.** The implemented
screen is taller than 900px, so the reworked components that sit below the fold
— the compact card variant and the bottom guess row — are invisible in a
415x900 frame and a reader could not check them. `-md-full.png` is the same
screen re-rendered at 415x1600 with nothing clipped. The two 415x900 captures
are kept unchanged in purpose: they are the frames that compare 1:1 against
`design-reference-5-goi-y-qua-thang-cong-suc-ios.png` without rescaling.

| file | viewport | what it evidences |
| --- | --- | --- |
| `implemented-5-goi-y-qua-thang-cong-suc-ios.png` | 415x900 | iOS platform render, 1:1 against the canvas |
| `implemented-5-goi-y-qua-thang-cong-suc-md.png` | 415x900 | same frame with the opaque Material header band |
| `implemented-5-goi-y-qua-thang-cong-suc-md-full.png` | 415x1600 | whole page, including everything below the fold |

All three captures were opened and read. Every Vietnamese string renders with
full diacritics, and every glyph draws as a glyph rather than a notdef box —
including the three added this round, whose codepoints were read out of the
bundled `MaterialSymbolsRounded-Variable.ttf` cmap rather than guessed:
`close`/0xe5cd on the dismiss control, `help`/0xe887 on the guess row disc, and
`handyman`/0xf10b on the provenance band.

The same two harness artifacts as P4 apply: the iOS title band is blank because
`CupidHeader`'s iOS band is a `BackdropFilter` with no backdrop to sample
offscreen — both `-md` captures show `Gợi ý quà` in place, and the screen test
asserts the title by text — and there is no device chrome.

## Matched against the reference

- Dark sky wash canvas, card surface fill, card radius and row rhythm.
- Effort pill with a leading timer glyph at the card's top-left, branch label
  muted at the top-right, title, then description.
- A provenance line in muted caption under the description, naming the basis
  the reader themselves typed.
- Full-width gradient primary pill with a leading `+` glyph.
- Pill-shaped filter chips in a wrapping row directly under the header.
- Vietnamese typography, including diacritics, at every weight used.

Matched by the design-anchor rework round (previously listed below as
conflicts 1, 2, 3, 6 and 7):

- **Primary action label** now reads `+ Thêm vào Muốn làm`, as the canvas draws
  it.
- **Per-card dismiss `×`** as a circular control beside the primary pill.
- **Compact second card shape**: minutes badge, title, provenance line,
  circular add control, no description and no second gradient pill.
- **Provenance explainer band** under the filter rows, with the canvas's
  crossed-tools glyph and its notebook-row-count phrasing.
- **Bottom row** as a tappable card-like row: `?` disc, "Bí quá thì thử đoán
  xem …", `›` chevron.

## Adjudication of the seven P7 spec-vs-canvas divergences

The first pass recorded all seven as `DESIGN_SPEC_CONFLICT` and self-adjudicated
them in favour of `ux/uiux-spec.md`. That self-adjudication was wrong to make
here. The decision was taken outside this report, on the STORY-001 precedent
(commit b516c48, decisions D-1/D-2/D-3): **for this screen the design reference
canvas anchors over `uiux-spec.md` wording.**

That decision answers a *spec-vs-canvas* question. It does not license
overriding an acceptance criterion, which is why the seven items split into two
groups and not one.

### Items 1, 2, 3, 6, 7 — canvas wins, reworked, now matched

The divergence was only against spec prose, so the canvas anchors and
`uiux-spec.md` Phần D was amended to match (items 2b, 3, 3b, 4, 4b and the
rewritten "Liên kết khoá vị trí" paragraph).

1. **Primary action label** → `+ Thêm vào Muốn làm`. Checked against the stop
   rule before changing anything: `Muốn làm` is the name of the *existing*
   stage-1 hub tab (`home_screen.dart:309`, `activity_card_hub_view.dart`,
   `req_master.md` D-3), so the label names the one shared hub the action
   already writes to. It is a relabel; `addToHub` still calls STORY-001's
   `createCard` and no second collection exists (AC-21, AC-22, BR-7, SC-1').
2. **Per-card dismiss `×`** → added, on the lead card where the canvas draws it.
   It is not a competing *primary* action: it removes a suggestion from the
   list and writes nothing, so "exactly one primary action" still holds.
   Deliberately session-only — a persisted rejection set would be both a second
   store (AC-22) and a taste profile nobody asked to keep.
3. **Compact second card shape** → added. The lead card keeps the full shape;
   dismissing it promotes the next suggestion into that shape, so no suggestion
   is permanently stuck in the compact role.
4. **Provenance explainer band** → added under the filter rows. The earlier note
   about its row count stands and is now load-bearing: AC-25 bans quantities of
   the *other person's behaviour*, AC-33 bans progress/exhaustion indicators,
   and a count of rows the reader typed themselves is neither.
5. **Bottom row** → the canvas's tappable card-like row. AC-20 was re-read
   directly before making this change: it governs the handmade skill provenance
   line, **not** the location-lock link, so no AC constrains this row's shape.
   Tapping it answers with a short "coming in a later step" message naming both
   R-13 surfaces, the same pattern the hub's quick-entry strip uses, so the row
   is never a tap that does nothing (AC-24/SC-5).

### Items 4 and 5 — intentional divergence, pack-driven, unchanged

These are **not** spec-vs-canvas questions, so the design-anchor decision does
not reach them. Both are governed by AC-32, AC-34 and R-15b, which make the
number of branches and the effort-tier labels a property of the shipped content
pack that no code and no AC may pin. Matching the canvas here would mean
hardcoding a count or a label list in the UI layer — the exact thing those
criteria forbid, and the thing `gift_content_gate_test.dart` fails the build
over.

4. **Two branch chips on the canvas vs. three shipped.** `gift_taxonomy.v1.json`
   declares three branches (adding "Tự tay làm"). The row renders one chip per
   pack branch and will render four if an author ships a fourth. Unchanged.
5. **Effort chip labels.** The canvas shows one chip, "Làm được trong 2 tiếng
   tối nay"; the pack's own labels are "Trong 30 phút / Một tới hai giờ / Trọn
   một buổi". The labels come from the pack. Phần D item 2's
   "≤1 giờ / ≤2 giờ / cả ngày+" is likewise an example, not a string list.
   Unchanged.

`gift_taxonomy.v1.json` was not touched in this round.

## Delta that is neither a match nor a conflict

**The ask card is much taller than the reference's.** The reference draws the
open question as a compact wrap of small chips (`xe máy` / `xe bus` / `đi bộ` /
`không biết`). The shipped `AskOnTheSpotSlot` — P4's component, reused here
because the handoff requires exactly one of them and forbids a second ask
surface — renders full-width stacked option buttons, so with six options it
fills most of the first screenful and pushes the first suggestion card below the
fold.

This is a property of the P4 component, outside this phase's Write Scope, and
changing it would change screen (2)'s and screen (3)'s appearance too. Recorded
for the reviewer rather than changed. If it is judged a defect, it belongs to
the ask-card component, not to screen (5).

## Forbidden surfaces — verified absent in the captures and in the tree

No currency symbol, price figure, price range control, cheap/expensive label,
shop name, discount code or outbound link anywhere on the screen; no save,
favourite, bookmark, share or "xem sau" affordance beside the one primary
action; no progress, percentage, remaining-count or "hết ý tưởng" indicator.
Asserted by the absence groups in `gift_ideas_screen_test.dart`, by the P5
currency/integer content gate over every file under `lib/features/gift_ideas/`,
and confirmed by reading both captures.
