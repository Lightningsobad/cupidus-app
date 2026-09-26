VISUAL_FIDELITY: PASS
Design-Screen: sb-212-cam-on-chot-viec-ke-tiep

# STORY-007 — "Cảm ơn + chốt việc kế tiếp", visual fidelity (P2 khung khối + P3 phần 1 + P4 phần 2 + P5 phần 3)

- Story: REQ-016 / STORY-007, phases P2, P3, P4 and P5
  (`coding-plan/phase-P2-block-shell-and-entry-point.md` §6,
  `coding-plan/phase-P4-photo-attach.md` §6,
  `coding-plan/phase-P5-next-plan-suggestions.md` §6)
- Requirement: REQ-016_solo_stage1_relationship_assistant
- Lane: Mobile
- Date: 2026-09-24 (P4 re-capture; P2/P5 audit 2026-09-23)

## Screens under audit

| Design screen id | Platform | Design reference | Implemented |
| --- | --- | --- | --- |
| `sb-212-cam-on-chot-viec-ke-tiep` | ios | `design-reference-sb-212-cam-on-chot-viec-ke-tiep-ios.png` (415x900) | `implemented-sb-212-cam-on-chot-viec-ke-tiep-ios.png` (415x900) |

The screen pair above is the audited one. P4 adds a **second state of the same
screen**, `state-khong-anh-sb-212-cam-on-chot-viec-ke-tiep-ios.png` (415x900,
ios): the identical surface on a card with no photo, which is the AC-15/BR-9
shape. It is deliberately not a `design-reference`/`implemented` pair — the
canvas has no empty-photo frame to compare it against — so it is filed as
supporting evidence rather than a second row in the table.

Design source resolution: the project configures four design sources, so the
renderer refuses a default. The surface carrying this story is `cupid-ch-ng-1`
(entry `Cupid Chặng 1.dc.html`, `platforms: ["ios"]`, `screens_from: "frames"`).
The frame list was enumerated with
`node .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=cupid-ch-ng-1 --list-screens`,
and `sb-212-cam-on-chot-viec-ke-tiep` is the only frame in it that renders this
story's surface. The canvas uses slug ids, so the reference was rendered with
`--screen=<slug>` and no `--label`.

`story_master.md` carries no `Design-Screen:` line and is outside this phase's
write scope, so the id is recorded here and Scrum Master must copy it across —
same handling as STORY-006 P2.

## How the implemented capture was produced — and why not on a device

Not a device screenshot. The block only draws on a *Đã đi rồi* card whose
activation row is `armed` from a **strictly earlier calendar day** (AC-1/AC-2),
and it spends that row on its first presentation (AC-3). There is no navigation
path that puts it on screen on demand: it would take seeding a card, marking it
done, then moving the device clock forward a day, and both the seeding surface
and `main_preview.dart` are outside this phase's write scope.

So the real screen was rendered directly, through the repo's established
fallback for an unreachable surface (same pattern as STORY-006 P2 and STORY-003
P3): a `RepaintBoundary.toImage` capture inside this story's own widget test, at
the iOS reference viewport, pumping the real `ActivityCardDetailScreen` — not a
stand-in harness — with the real `buildCupidTheme`, locale `vi`, and the pubspec
font families plus the framework `MaterialIcons-Regular.otf` loaded via
`FontLoader`. It lives in
`mobile/test/features/activity_cards/thank_you/thank_you_block_test.dart`, group
`visual fidelity capture`, skipped unless the dart-define is set, so the
ordinary suite stays hermetic. Reproduce with:

```
FLUTTER_ROOT="$HOME/flutter" flutter test \
  test/features/activity_cards/thank_you/thank_you_block_test.dart \
  --dart-define=CAPTURE_VISUALS=true --plain-name="visual fidelity capture"
```

### Harness artifacts — not product defects

- Captured through `CupidPlatform.material`, not `.ios`. The iOS `CupidHeader`
  puts a `BackdropFilter` over its own title; offscreen that filter has nothing
  behind it to sample and washes the header away. The block under audit is
  platform-neutral and renders identically either way.
- `CupidAppBackground(enableEffectsOverride: false)` wraps the capture, so the
  animated background glow is frozen rather than caught mid-frame.
- No iOS status bar and no home indicator: the design reference includes device
  chrome, a direct widget render does not.
- The thumbnails' files are decoded into the image cache before the widget is
  pumped. `Image.file` reads from disk, and a read started under the test's fake
  clock never finishes, so without the warm-up the row captures as blank squares
  — and waiting on that read afterwards hangs the run rather than failing it.

All three PNGs were opened and inspected. Every glyph rasterises — no tofu — and the
Vietnamese diacritics in `Cảm ơn + chốt việc kế tiếp` and in the card body above
it are all correct.

## Matches the design

- Layered surface at `colorSurfaceAlt` with a hairline `colorLine` border and
  `radiusSmall` corners, indented one `md` from the region edge — the same
  treatment the canvas gives its inner section cards, and the same container
  STORY-006 shipped (`ux/uiux-spec.md` mục 6, `architecture/solution.md` §117
  "mẫu container khối lồng của STORY-006").
- Block title at `body` semibold on `colorText`, left-aligned, with the dismiss
  affordance right-aligned on the same row.
- Dark palette, type scale and spacing rhythm read as the same surface family as
  the reference.
- Two-tier action hierarchy holds: the card's single primary action
  (`Ghi lại buổi đó đi`, gradient pill) sits above the block and the block adds
  no card-level CTA of its own — AC-6 and AC-7, visible directly in the capture.

## Phần 3 (P5) — matches the design

The capture is pinned to 2026-09-21 and resolves the shipped occasion pack
(`assets/data/req016/calendar_events.v1.json`), so the three chips it shows are
the wording and the dates the app actually ships.

- Section header `HẸN NHAU LẦN TỚI · KHÔNG BẮT BUỘC` in muted caption caps with
  the canvas's letter-spacing, sitting below the block title with no divider.
- Each suggestion is one full-width row of identical height and identical
  decoration: leading activity icon, title at `body` semibold, a date readout
  beneath it, and a `+` affordance at the trailing edge in `colorAccentPink`.
  No row is emphasised over its peers (`ux/uiux-spec.md` mục 3).
- The rows stay at the secondary-action tier: `Ghi lại buổi đó đi` above the
  block keeps the only gradient fill on the screen (AC-6, BR-1).
- Vietnamese diacritics render fully across all three titles and the countdown
  line (`Tết Trung Thu`, `Ngày Nhà giáo Việt Nam`, `còn 60 ngày`) — checked
  glyph by glyph against the capture, no tofu boxes, and the three leading
  glyphs are the real `walk`/`handmade`/`visit` icons rather than fallback
  squares.

### Deltas inside phần 3 — accepted, with the binding source

- **Three rows vs the canvas's two.** AC-35 fixes "2-3" as a layout parameter,
  not a content claim: the section renders what the pack has, capped at
  `maxNextPlanSuggestions`. On the captured day the pack has three upcoming
  occasions, so three render. A pack with one renders one, with no placeholder
  filling the third slot, and an empty pack leaves the whole section out of the
  tree (`next_plan_test.dart`).
- **Plain `+` glyph vs the canvas's ringed `⊕`.** `CupidIcons.add` is the
  design system's own token for this affordance and is what every other
  "thêm vào kho" surface in the app already draws; a second, ringed variant
  would be a new icon rather than a reused one.
- **Every row carries a date line.** The canvas leaves its second row without
  one. Every suggestion here is an occasion, and AC-21 requires the occasion's
  date to travel with the card, so the date is never absent for a chip that
  exists.

## Phần 2 (P4) — matches the design

All three slots are now filled. P4 (2026-09-24) shipped Section 2, so the
implemented PNG was re-captured with the photo row present and the block no
longer has an empty slot.

The capture is driven through the section's loader seam with three photo files
on disk, because the merged source (`ActivityCardPhotos` + the journal's
`originRef` projection) has no seeding surface inside this phase's write scope.
The thumbnails are flat colour squares rather than photographs on purpose: what
the capture is evidence *of* is the row's geometry and chrome, and a real
photograph would only add noise the canvas cannot be compared against.

- One horizontally scrolling row of square thumbnails at the secondary-action
  tier, indented with the rest of the block, `radiusSmall` corners
  (`ux/uiux-spec.md` mục 3, phase P4 §3).
- Each thumbnail is **the photo and nothing else** — no caption, no date, no
  entry label, no overlay of any kind. Asserted in the tree as well as in the
  capture: `photo_attach_test.dart` fails if any `Text` appears inside
  `photo_attach_row` (AC-17, BR-8).
- Nothing is pre-selected: no accent border, no tick on any thumbnail in the
  capture, which is AC-16 read straight off the render.
- No "thêm ảnh mới" affordance in the row — the section opens neither camera nor
  gallery (`ux/uiux-spec.md` mục 3 dòng 62-63).
- Section header `KÈM ẢNH · KHÔNG BẮT BUỘC` uses the identical muted caption-caps
  treatment and letter-spacing as phần 3's `HẸN NHAU LẦN TỚI · KHÔNG BẮT BUỘC`
  directly beneath it, so the two optional sections read as peers.
- Vietnamese diacritics in the header (`KÈM ẢNH`, `KHÔNG BẮT BUỘC`) rasterise
  fully — inspected glyph by glyph, no tofu.

### Empty state — the second capture

`state-khong-anh-sb-212-cam-on-chot-viec-ke-tiep-ios.png` is the same screen
with the loader returning nothing. Section 2 is **absent entirely**: no header,
no grey row, no empty frame, no "thêm ảnh đi" CTA — phần 1 sits directly above
phần 3's header with the block's normal rhythm and no gap where the row was.
That is AC-15/BR-9 verified by render rather than by assertion alone.

### Deltas inside phần 2 — accepted, with the binding source

- **A row of thumbnails vs the canvas's single list row.** The canvas draws one
  full-width row: one thumbnail, the title `Kèm một ảnh tối qua`, a sub-caption
  and a trailing chevron. `ux/uiux-spec.md` mục 3 dòng 53-54 fixes the shape as
  "một hàng thumbnail ảnh dạng lưới ngang cuộn được", and phase P4 §3 repeats it
  ("hàng thumbnail cuộn ngang, chỉ ảnh"). The canvas shape also presumes exactly
  one photo, while AC-14 merges two stores that can each hold several.
- **Selection in place vs a chevron into somewhere else.** The chevron implies a
  second destination; AC-16 and phase P4 §3 specify tap-to-select/deselect on the
  thumbnail itself with a tick top-right, and the block is explicitly a read-only
  window rather than a door into the journal.
- **A section header where the canvas has a row title.** `uiux-spec.md` does not
  name a header for phần 2, and the canvas's own equivalent text
  (`Kèm một ảnh tối qua`) cannot ship — see the conflict below. A caption-caps
  header matching phần 3 keeps the section named without putting any journal
  content on screen.

## Authority note

Where the canvas and the story's binding artifacts disagree, the ACs in
`requirements/requirements.md` and the phase plan win — they are what this story
is gated on, and the canvas frame predates them. The differences below are that
case and are recorded as `DESIGN_SPEC_CONFLICT`: they are **not** implementation
gaps and must not be "fixed" toward the canvas without a user ruling.

## DESIGN_SPEC_CONFLICT — design reference contradicts binding requirements

1. **Full-screen destination vs nested block.** The canvas renders a standalone
   screen with device chrome, a back chevron, a `ĐÃ ĐI RỒI · TỐI QUA` status
   chip and its own H1. AC-7: "khối nằm **bên trong luồng 'ghi lại'** của thẻ
   đó ... Người dùng không phải rời luồng 'ghi lại' để dùng khối."
   `architecture/solution.md` §3 (UI Delivery Anchor) and `ux/uiux-spec.md`
   mục 6 both fix the delivery shape as STORY-006's nested container inside
   `ActivityCardDetailScreen`. Implemented as a sub-block, with no route added.
   This is the identical conflict STORY-006 P2 recorded against `sb-211`.
2. **Full-width dismiss button vs header close icon.** The canvas ends with a
   full-width `Thôi, để hôm khác` button, visually indistinguishable from a
   card-level primary action. AC-6 keeps *Đã đi rồi* at **đúng một** card-level
   primary action, and phase P2 §3 specifies a `close` icon in the block header
   at ≥44pt with no confirm dialog. Implemented as `thank_you_close`, a
   `platform.tapTarget` square carrying `CupidIcons.close` in `colorTextMuted`
   with semantic label `Đóng`.
3. **Screen-level H1 and subtitle.** The canvas leads with
   `Sáng nay có hai việc nhỏ xíu.` over `Chỉ hiện một lần thôi. Bỏ qua thì app
   cũng thôi.` Both are screen chrome that a nested block has no room for, and
   the H1 hardcodes a section count ("hai việc") while the spec's block frames
   three sections (P3/P4/P5), so the count is not a design constant. The block
   carries the name `ux/uiux-spec.md` mục 1 gives it,
   `Cảm ơn + chốt việc kế tiếp`.
4. **`ĐÃ ĐI RỒI · TỐI QUA` chip.** The canvas surfaces when the outing happened.
   The detail screen already carries its own `ĐÃ ĐI RỒI` status chip (STORY-001),
   and the `· TỐI QUA` half is a recency readout the block has no data for: the
   ledger stores `armed_on` as a civil date and nothing about time of day
   (BR-3, and the P1 column allowlist). No chip ships from this story.
5. **Section 2's row text `Kèm một ảnh tối qua` / `lấy từ tối qua bạn lưu lúc
   23h`.** This is the sharpest one. The sub-caption is a journal entry's save
   timestamp rendered on a screen the photo can be shared from, and AC-17/BR-8
   allow **only photo file references** to leave the journal — "chữ và siêu dữ
   liệu không bao giờ rời thiết bị qua đường này" (`ux/uiux-spec.md` mục 3).
   Phase P4 §3 enforces it at the type level: the projection carries a file path
   and nothing else, so there is no timestamp in the widget's reach to draw even
   if a designer asked for it. The row title is the same problem one step softer
   — `tối qua` is a recency readout derived from entry metadata. Neither ships.
   The section is named by a caption-caps header carrying no journal content.
6. **Section 2's trailing chevron.** A chevron reads as "there is more of this
   somewhere". There is not: the journal is a one-way surface (AC-7) and this
   section is the single read-only window onto it. AC-16 puts the whole
   interaction on the thumbnail itself. No chevron ships.

## Out of scope here — not conflicts, not defects

- The monospace receipt block inside section 1 is STORY-002's renderer output
  (AC-8); its framing is P3's call, not P2's.
- The `+` affordances on the section-3 rows write activity cards through
  STORY-001's creation path (AC-19..AC-24). Shipped by P5: the tap calls
  `ActivityCardRepository.createCard` and nothing else writes a card.
