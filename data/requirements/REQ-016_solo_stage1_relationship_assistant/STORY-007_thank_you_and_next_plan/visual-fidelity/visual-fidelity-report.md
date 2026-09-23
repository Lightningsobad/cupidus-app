VISUAL_FIDELITY: PASS
Design-Screen: sb-212-cam-on-chot-viec-ke-tiep

# STORY-007 — "Cảm ơn + chốt việc kế tiếp", visual fidelity (P2 khung khối + điểm gắn)

- Story: REQ-016 / STORY-007, phase P2
  (`coding-plan/phase-P2-block-shell-and-entry-point.md` §6)
- Requirement: REQ-016_solo_stage1_relationship_assistant
- Lane: Mobile
- Date: 2026-09-23

## Screens under audit

| Design screen id | Platform | Design reference | Implemented |
| --- | --- | --- | --- |
| `sb-212-cam-on-chot-viec-ke-tiep` | ios | `design-reference-sb-212-cam-on-chot-viec-ke-tiep-ios.png` (415x900) | `implemented-sb-212-cam-on-chot-viec-ke-tiep-ios.png` (415x900) |

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

Both PNGs were opened and inspected. Every glyph rasterises — no tofu — and the
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

## P2 scope note — the three slots are empty on purpose

P2 ships the frame and its slot contract only. The canvas draws the block with
its sections filled; those sections are P3 (`soạn lời cảm ơn`), P4 (`đính ảnh`)
and P5 (`chốt việc kế tiếp`), each explicitly out of this phase's write scope.
An unfilled slot renders nothing at all — no placeholder row — which is also the
shape AC-15/BR-9 need for "card with no photo". The canvas has no equivalent
empty-frame state to compare against, so the following are recorded as
**not-yet-built, not deltas**:

- Section 1: the thank-you draft card, its `Chép để gửi Zalo` gradient CTA and
  the shuffle button (P3, blocked on `CONTENT_GATE_CATEGORY_COUPLING`).
- Section 2: the `Kèm một ảnh tối qua` row with thumbnail, sub-caption and
  chevron (P4, blocked on `JOURNAL_SOURCE_CONTRACT_CLOSED`).
- Section 3: the `HẸN NHAU LẦN TỚI · KHÔNG BẮT BUỘC` header and its two
  suggestion rows with `+` affordances (P5).

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

## Out of scope here — not conflicts, not defects

- The monospace receipt block inside section 1 is STORY-002's renderer output
  (AC-8); its framing is P3's call, not P2's.
- The `+` affordances on the section-3 rows write activity cards through
  STORY-001's creation path (AC-19..AC-24) and belong to P5.
