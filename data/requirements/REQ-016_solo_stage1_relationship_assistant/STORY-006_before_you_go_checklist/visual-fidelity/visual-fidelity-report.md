VISUAL_FIDELITY: PASS
Design-Screen: sb-211-truoc-gio-di

# STORY-006 — "Trước giờ đi" checklist, visual fidelity (P2 block + dismissal)

- Story: REQ-016 / STORY-006, phase P2
  (`coding-plan/phase-P2-detail-screen-block-and-dismissal.md` §6)
- Requirement: REQ-016_solo_stage1_relationship_assistant
- Lane: Mobile
- Date: 2026-09-11

## Screens under audit

| Design screen id | Platform | Design reference | Implemented |
| --- | --- | --- | --- |
| `sb-211-truoc-gio-di` | ios | `design-reference-sb-211-truoc-gio-di-ios.png` (415x900) | `implemented-sb-211-truoc-gio-di-ios.png` (415x900) |
| `sb-211-truoc-gio-di` (closed state) | ios | same reference | `implemented-sb-211-truoc-gio-di-ios-collapsed.png` (415x900) |

Design source resolution: `data/devops/system/design-fidelity-config.json` locks
`design_source` to `cupid-app`; the surface carrying this story is
`cupid-ch-ng-1` (entry `Cupid Chặng 1.dc.html`, `platforms: ["ios"]`,
`screens_from: "frames"`). The frame list was enumerated with
`node .ai-team-bundle/runtime/tools/render-design-canvas.js --list-screens`, and
`sb-211-truoc-gio-di` is the only frame in it that renders this phase's surface.

`story_master.md` carries no `Design-Screen:` line and is outside this phase's
write scope, so the id is recorded here and Scrum Master must copy it across.

## How the implemented captures were produced — and why not on a device

Not by a device screenshot. The block exists only on a `scheduled` card whose
`scheduledOn` equals the device's civil date (AC-1/AC-2), so there is no
navigation path that puts it on screen on demand: reaching it would require
seeding a card dated exactly today and then editing the device clock, and both
the seeding surface and `main_preview.dart` are outside this phase's write
scope.

So the real screen was rendered directly, through the repo's established
fallback for an unreachable surface (same pattern as STORY-003 P3 and
STORY-021): a `RepaintBoundary.toImage` capture inside the story's own widget
test, at the iOS reference viewport, pumping the real
`ActivityCardDetailScreen` — not a stand-in harness — with the real
`buildCupidTheme`, the shipped pack read off disk, and the four pubspec font
families plus the framework `MaterialIcons-Regular.otf` loaded via `FontLoader`.
It lives in `mobile/test/features/before_you_go/before_you_go_block_test.dart`,
group `visual fidelity capture`, skipped unless the dart-define is set, so the
ordinary suite stays hermetic. Reproduce with:

```
FLUTTER_ROOT="$HOME/flutter" flutter test \
  test/features/before_you_go/before_you_go_block_test.dart \
  --dart-define=CAPTURE_VISUALS=true --plain-name="visual fidelity capture"
```

### Harness artifacts — not product defects

- Captured through `CupidPlatform.material`, not `.ios`. The iOS `CupidHeader`
  puts a `BackdropFilter` over its own title; offscreen that filter has nothing
  behind it to sample and washes the header away. Everything under audit here —
  the block itself — is platform-neutral and renders identically either way.
- `CupidAppBackground(enableEffectsOverride: false)` wraps the capture, so the
  animated background glow is frozen rather than caught mid-frame.
- No iOS status bar, no home indicator, no countdown chip row: the design
  reference includes device chrome, a direct widget render does not.
- The open-block capture is bottom-anchored on a 2400px-tall pump, so the block
  and the card CTA above it both sit in frame; the collapsed capture is the
  ordinary 900px frame.

Both PNGs were opened and inspected. All five row glyphs rasterise (no tofu),
Vietnamese diacritics are correct in every label, and the collapsed tick renders
in `colorTextMuted` rather than a mint "done" green.

## Matches the design

- Layered surface at `colorSurfaceAlt` with a hairline `colorLine` border and
  `radiusSmall` (16) corners, indented one `md` from the region edge
- Title row: `gradientHot` rounded icon tile carrying the `checklist` glyph,
  then `Trước giờ đi` at `body` semibold
- One row per hint: leading muted icon, label at `body` on `colorText`, minimum
  40pt row height
- Trailing inline action on the share row only, at `caption` on `colorAccentPink`
- A pill-radius (`radiusButton`, 999) block action at the foot
- Closed state: a single muted line with a neutral tick and a `Mở lại` action,
  leaving no frame behind (AC-14)

## Authority note

Where the canvas and the story's binding artifacts disagree, the ACs in
`requirements/requirements.md` and the phase plan win — they are what this story
is gated on, and the canvas frame predates them. The differences below are that
case and are recorded as `DESIGN_SPEC_CONFLICT`: they are **not** implementation
gaps and must not be "fixed" toward the canvas without a user ruling.

## DESIGN_SPEC_CONFLICT — design reference contradicts binding requirements

1. **Full-screen destination vs nested block.** The canvas renders a standalone
   screen with its own back chrome (`← Hôm nay · 19:20`) and its own title
   (`Suất chiếu 19:20 / CGV Vincom Bà Triệu`). AC-6: "không xuất hiện như một
   destination riêng; nó không phải màn hình thứ 12." AC-5 puts the block "ở mức
   thị giác thấp hơn rõ rệt so với hành động chính cấp thẻ." Implemented as a
   sub-block inside `ActivityCardDetailScreen`, with no route added.
2. **Per-row checkboxes, mint done-tick and strikethrough.** The canvas gives
   every row a checkbox and shows `Kiểm lại vé một lần nữa` ticked in mint with
   the label struck through. AC-27: "không có streak, chuỗi ngày, huy hiệu, hay
   đếm số lần hoàn thành checklist." Phase §3: "Không checkbox, không trạng thái
   đã-làm." Implemented rows carry no checkbox and no per-row state.
3. **Full-width gradient CTA at the block foot.** The canvas ends with a
   `gradientHot` full-width button `Xong hết rồi, đi gặp Cún thôi`, visually
   identical to a card-level primary action. AC-4: "hành động chính **cấp thẻ**
   vẫn là **đúng một**"; AC-5 requires the block's action to sit visibly below
   it. Implemented as an outline pill labelled `Xong hết rồi, đi thôi` — which
   is also the label the requirements specify, against the canvas wording.
4. **Hardcoded row labels and row count.** The canvas ships four specific labels
   (`Kiểm lại vé một lần nữa`, `Mang đủ tiền mặt (~250k)`, `Mang áo mưa, nhớ sẵn
   chỗ trú nếu mưa`, `Đổ xăng trước khi đi đón`, `Chia sẻ vị trí cho một người
   nhà`). AC-29/BR-15 make every label a property of the shipped content pack,
   and a test asserts no shipped label appears as a literal in any Dart file
   under `lib/features/before_you_go/**`. AC-30 makes the row count a function
   of which conditions hold for that card, so it is not a design constant.
5. **Row-count subtitle.** The canvas renders `4 việc nhỏ, lấy từ chính những gì
   bạn đã ghi` under the title. The count varies per card by AC-30, and AC-27
   rules out surfacing checklist tallies. No subtitle ships.
6. **Countdown chip.** The canvas leads with `CÒN 2 TIẾNG 15 NỮA LÀ GẶP`.
   AC-10 resolves the phase by civil date only, and the phase model carries no
   time-of-day, so the chip has no data behind it in this story.

## Out of scope here — not conflicts, not defects

- **Per-row sub-captions** (`trả tại chỗ, còn bắp với nước nữa`, `tháng 9 · miền
  Bắc · đang mùa mưa`, `4,2 km, đường Bà Triệu giờ tan làm`). The v1 pack schema
  has no sub-caption field; adding one is a content-package + resolver change in
  P1, not a P2 widget change.
- **The `Đọc lại phần "trước" một lượt` navigation row.** That row links the
  private journal and belongs to STORY-008.
