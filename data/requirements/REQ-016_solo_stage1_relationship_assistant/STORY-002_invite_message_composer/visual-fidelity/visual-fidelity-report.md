VISUAL_FIDELITY: PASS
Design-Screen: 11-xuat-loi-moi-chon-khung
Design-Screen: 11-dien-mad-libs-xem-truoc
Design-Screen: chi-tiet-the-moi-nghi-ra

Sections: §0-§2 cover phase P5 (composer sheet). §3 covers phase P6 (the
"Chuẩn bị" entry sheet and the place field on the card detail screen).

- Story: REQ-016 / STORY-002, phase P5
  (`coding-plan/phase-P5-invite-composer-sheet.md` §6)
- Requirement: REQ-016_solo_stage1_relationship_assistant
- Lane: Mobile
- Date: 2026-09-10
- Configuration: captured inside this story's own widget test,
  `mobile/test/features/invite_composer/invite_composer_sheet_test.dart`
  ("captures the implemented sheet for the visual fidelity gate"), through the
  real `showInviteComposerSheet` entry point over a `RepaintBoundary` wrapping
  the whole app. Material platform override, dark theme, locale `vi`, frame
  415x900 @ dpr 1, app's own bundled fonts loaded via `FontLoader`
  (`Roboto`, `Nunito`, `Roboto Mono`).
- Why not a runtime capture: P5 deliberately registers no route and no entry
  point — that is P6's phase — and `mobile/lib/main_preview.dart` is outside
  P5's write scope, so the sheet is unreachable from a running build at this
  phase. A device *was* reachable (`emulator-5554`); this is the handoff's
  sanctioned widget-test fallback, not a runtime-unavailable block.
- Design source: canvas surface `cupid-ch-ng-1`, screens
  `11-xuat-loi-moi-chon-khung` and `11-dien-mad-libs-xem-truoc`, rendered with
  `render-design-canvas.js --surface=cupid-ch-ng-1 --platform=ios` to
  `design-reference-11-xuat-loi-moi-chon-khung-ios.png` (415x900) and
  `design-reference-11-dien-mad-libs-xem-truoc-ios.png` (415x900)
- Implementation capture:
  `implemented-11-xuat-loi-moi-chon-khung-ios.png` (415x900, sheet at rest) and
  `implemented-11-dien-mad-libs-xem-truoc-ios.png` (415x900, preview switched
  to inline edit)
- Round: 1

## 0. Comparison region

P5 owns one surface: the invite composer sheet reached through
`showInviteComposerSheet`. The phase file names `../ux/uiux-spec.md` §2 and §6
as Source Of Truth, so that is the reference the implementation is measured
against; the two canvas frames are the design-source anchor for the same user
moment and are recorded here because the contract identifies a design reference
by screen id, not by file path.

### In region (P5 owns these)

| Element | Owner file |
|---|---|
| Sheet shell: `--r-sheet` rounded top, ~70% height, drag to expand/dismiss | `presentation/widgets/invite_composer_sheet.dart` |
| Grab handle + title "Soạn lời mời" (card title 22pt/600) | `presentation/widgets/invite_composer_sheet.dart` |
| Horizontal frame chip strip, selected/unselected treatment | `presentation/widgets/frame_chip_strip.dart` |
| Preview block (`--r-card`, body 17pt, multi-line) and its inline-edit state | `presentation/widgets/invite_composer_sheet.dart` |
| Decline-door sentence inside the invite body | content pack (`preset_catalogue`, P2) |
| Full-width `--grad` pill labelled "Chia sẻ" | `design_system/adaptive/cupid_primary_button.dart` |

### Out of region

| Design element | Owner |
|---|---|
| Route/entry point that opens the sheet ("Chuẩn bị" surface) | P6 |
| Card detail screen behind the sheet, and STORY-001's `invited` toggle | STORY-001 |
| Invite wording itself | content pack, not code (R-15a) |

## 1. Verdict

PASS against the Source Of Truth (`ux/uiux-spec.md` §2/§6). Every §2 item is
present, in order, once: grab handle + title; horizontally scrolling frame
chips with the selected chip on a pale `--pink` fill at body 17pt/600 and the
unselected chips on a thin `colorLine` border at `colorTextMuted`; a
`--r-card` preview block carrying the rendered invite including the
decline-door sentence; and exactly one full-width `--grad` pill labelled
"Chia sẻ". §2.6 holds: there is no second send control, no contact/phone
field, and no per-channel icon. §6 holds: no category picker appears.
AC-26/AC-27 hold: the captured frame shows no count, no "n/m" position, no
progress bar, and no "hết khung" terminator.

Eyeballed, not just exit-code-checked. Both captures were opened and read.
Vietnamese diacritics render correctly throughout with the bundled text fonts
— "Soạn lời mời", "Rủ nhẹ nhàng", "Kiểu nghiêm túc", "Kiểu lầy lội" (the third
chip is clipped at the frame edge, which is the horizontal strip scrolling as
designed), "Rảnh không, mình đi xem phim Dune nhé? Hẹn Thứ Bảy 15/8 tối ở rạp
CGV Vincom Đồng Khởi, chắc khoảng 2 tiếng. Bận thì cứ nói mình biết nha, không
sao đâu.", "Chia sẻ" — with no tofu boxes and no dropped tone marks. All five
mad-libs variables resolved: no literal `{...}` placeholder survives anywhere in
the body. The second capture differs from the
first exactly as intended: the same sheet, same chips, same CTA, with the
preview block now carrying a text caret, confirming §2.3's "sửa tại chỗ"
rather than a pushed editor screen.

## 2. Design-source conflicts — PO ruling required

The two canvas frames describe a materially different interaction model from
the one §2/§6 and the AC specify. The implementation follows the spec, per the
phase file's Source Of Truth line, and these are raised as ruling proposals
rather than silently absorbed. Numbering continues the requirement's Design
Ruling Log in `../../req_master.md`; final numbers are Scrum Master's/PO's to
assign.

| # | Canvas shows | Spec/AC requires | Implemented as |
|---|---|---|---|
| a | `11-xuat-loi-moi-chon-khung`: a vertical list of frame *cards*, each with a preview snippet, selected card marked by a pink border and a check glyph; sheet titled "Hôm nay rủ kiểu gì đây?" | §2.1 title "Soạn lời mời"; §2.2 a horizontally scrolling *chip* row, selected chip on a pale `--pink` fill | Spec (chip strip, "Soạn lời mời") |
| b | `11-dien-mad-libs-xem-truoc`: a separate full screen (back arrow, "Đổi khung" pill), with a per-field mad-libs editor section and shuffle controls | §2.3 the preview block itself becomes the editor, in place, "không mở màn soạn thảo riêng"; §1 the whole flow is one sheet | Spec (inline edit inside the sheet) |
| c | Same frame: a CTA labelled "Gửi qua Zalo" plus a download icon button | AC-16 / §2.6: "không có icon Zalo/Messenger riêng", one "Chia sẻ" CTA through the OS Share Sheet only | Spec (single "Chia sẻ" pill). **This canvas element is an AC violation in the design itself**, not a fidelity gap in the implementation |
| d | Same frame: a "CÒN HAI CHỖ TRỐNG" banner over the editor | AC-26/AC-27/R-15b forbid any count or progress indicator | Spec (no count surface anywhere) |

Conflict (c) and (d) cannot be resolved in favour of the canvas without
changing an accepted acceptance criterion, so they are reported as
design-source defects. (a) and (b) are choices where the spec and the canvas
disagree and PO owns the call. Their remediation cost is **not** the same, and
an earlier revision of this paragraph understated (b) — corrected here after
review finding F-4 of round 1:

- **(a) is a re-layout.** Ruling for the canvas means rebuilding
  `frame_chip_strip.dart` as a vertical card list with per-frame preview
  snippets and changing the sheet title. The Cubit's selection state, the
  payload contract, and `presets.invite.v1.json` all stay as they are.
- **(b) is a content-pack schema change plus a renderer change, not a
  re-layout.** `design-reference-11-dien-mad-libs-xem-truoc-ios.png` is a
  rendered document parody: a letterhead caption, a document title, labelled
  fields ("Kính gửi:", "Tôi tên:", "Lý do:"), highlighted fill-in slots, a
  checkbox approval row, and a place/date footer. The shipped schema stores a
  preset as a flat `clauses` list of prose sentences with
  `requires`/`targets`/`role` and has no construct for a title, a letterhead, a
  field label, a checkbox, or a footer. Ruling for the canvas therefore means
  extending `schema_id: req016.presets.v1` and writing a structured renderer
  beside `invite_renderer.dart` — and this is a `shared-foundation` story whose
  schema is the stated precedent for every later preset story (AC-25, R-15a,
  `story_master.md ## Open Question Impact`), with STORY-007 due to add a second
  category onto the same renderer. PO should rule on (b) with that cost in
  view, not with a layout cost.

## 3. Phase P6 — "Chuẩn bị" entry sheet and the place field

VISUAL_FIDELITY: PASS

- Story: REQ-016 / STORY-002, phase P6
  (`coding-plan/phase-P6-prepare-entry-surface-and-location-field.md`)
- Lane: Mobile
- Date: 2026-09-10
- Round: 1
- Configuration: captured inside this story's own widget tests over a
  `RepaintBoundary` wrapping the whole app. All three frames come from
  `mobile/test/features/activity_cards/activity_card_detail_screen_test.dart`
  ("captures the place field for the visual fidelity gate" and "captures the
  \"Chuẩn bị\" sheet over the card it opened from"). Frame 415x900 @ dpr 1,
  dark theme, locale `vi`, iOS platform override, bundled fonts loaded via
  `FontLoader` (`Roboto`, `Nunito`, `Roboto Mono`, `Material Symbols Rounded`).
  The sheet frame is taken by driving the real path — mount the card detail,
  tap its one CTA, let the real `showPrepareActionsSheet` resolve its rows from
  a real content pack — so the capture contains the card, the scrim, and the
  sheet in one image (round-2 change, review finding F-5).
- Why not a runtime capture: the entry surface is a modal sheet behind a card
  detail screen that is reached by tapping a specific card in the hub;
  `mobile/lib/main_preview.dart` is outside P6's write scope, so no fixed-frame
  runtime route to it exists. This is the sanctioned widget-test fallback.

### 3.1 Surfaces and their design source

| Surface | Capture | Design source |
|---|---|---|
| "Chuẩn bị" action chooser sheet | `implemented-11-chuan-bi-chon-hanh-dong-ios.png` | **None.** `--list-screens` on surface `cupid-ch-ng-1` returns 29 frames and none of them is this chooser; Source Of Truth is `../ux/uiux-spec.md` §1/§4, as the phase file states |
| Card detail, place field filled, `mới nghĩ ra` | `implemented-chi-tiet-the-moi-nghi-ra-ios-cho-hen.png` | `design-reference-chi-tiet-the-moi-nghi-ra-ios.png` (415x900), rendered here with `render-design-canvas.js --surface=cupid-ch-ng-1 --platform=ios --screen=chi-tiet-the-moi-nghi-ra` |
| Card detail, place field filled, `đã hẹn ngày` | `implemented-chi-tiet-the-da-hen-ngay-ios-cho-hen.png` | Same screen, the state whose one CTA P6 rewires; no separate reference frame exists for it |

### 3.2 Comparison region

P6 owns exactly two things on these frames: the chooser sheet, and the place
row between the chip row and the link-provenance row. Everything else in the
card frames is STORY-001's surface, already reviewed and merged with
`Outcome: DEFERRED_ONLY` scoped to `visual-fidelity/`; its known deviations
from `chi-tiet-the-moi-nghi-ra` (block order, meta-cell order, note block
placement, header pill) are **out of region here** and are not re-litigated by
this phase.

### 3.3 Verdict

PASS, eyeballed rather than exit-code-checked — every PNG below was opened and
read.

Chooser sheet, against `ux/uiux-spec.md` §1/§4: a bottom sheet with the
`radiusSheet` rounded top, a grab handle, the title "Chuẩn bị", and a **list**
carrying its single currently-resolvable row "Xuất lời mời" with a leading
`edit_note` glyph in `colorAccentPink` and a trailing chevron. The list shape is
present from day one, so STORY-006/008 append rows rather than reshape the
sheet. No count, no "n/m" position, no "đã gửi" marker, no second CTA.

§4 ("dismissing the sheet lands back on the card") is now shown by the image
rather than asserted over it. The re-captured frame holds the whole card detail
above the sheet — header pill *ĐÃ HẸN NGÀY*, title "Cà phê sách Hào Nam", the
four meta cells, the note block, the chip row, the place row, the link block,
and the "Chuẩn bị cho tươm tất" CTA — with the sheet occupying only the bottom
~135 px. The card is what the sheet is drawn over, so dismissing it can only
land there. The nav path agrees: `_PrepareActionRow.onTap` calls
`Navigator.of(context).pop(action)` and `showPrepareActionsSheet` runs
`chosen.run(context)` afterwards against the card detail's own context, so the
sheet is gone before the composer opens and no page route is ever pushed —
pinned by "closes itself before the composer opens (UX §4)" and "the whole path
pushes no page route (AC-3)".

Round-1 note: the previous capture of this surface was taken over an empty
scaffold and showed flat grey behind the scrim, so it did not support the claim
made from it. That capture was replaced, not re-argued.

Card frames: the place row renders as a `colorSurface` box carrying
"rạp CGV Vincom Đồng Khởi" in body type, sized and cornered like the existing
optional-field rows, sitting between the chip strip and the link-provenance
block. It matches the phase file's "cùng dạng với các trường tuỳ chọn đang
có". Both frames still show exactly one primary CTA ("Chốt ngày đi thôi" /
"Chuẩn bị cho tươm tất") and exactly one inert secondary line, so the added row
did not grow a second primary action (AC-2), and the whole screen still fits
the 415x900 frame with the row added.

Typography: Vietnamese diacritics are correct everywhere in all three PNGs —
"Chuẩn bị", "Xuất lời mời", "rạp CGV Vincom Đồng Khởi", "Chuẩn bị cho tươm
tất", "Chốt ngày đi thôi", "Thứ Năm 1/10", "chưa hẹn ngày", "SỔ TAY CÓ GHI",
"không uống được cà phê đậm" — with no tofu boxes and no dropped tone marks.
The first sheet capture of this phase *did* rasterize both row icons as tofu
because its harness loaded only the three text fonts; every harness that writes
a capture now loads `MaterialSymbolsRounded-Variable.ttf` as well.

### 3.4 Design-source gaps — no PO ruling requested

| # | Gap | Why it is not a fidelity defect |
|---|---|---|
| e | No canvas frame exists for the "Chuẩn bị" chooser | The surface is introduced by this requirement's own architecture decision (single entry surface, AC-1/AC-3); `ux/uiux-spec.md` §1/§4 is the phase file's declared Source Of Truth and the implementation matches it |
| f | `chi-tiet-the-moi-nghi-ra` draws no place row | The `location` column is the Tech Lead's accepted additive schema-v5 decision (R-1e) taken to satisfy AC-4; the design predates it. The row follows the existing optional-field treatment rather than inventing one |

Neither gap changes an accepted acceptance criterion, so unlike §2 (c)/(d)
these are recorded for traceability only and need no ruling to merge.
