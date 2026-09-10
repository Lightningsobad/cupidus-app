VISUAL_FIDELITY: PASS
Design-Screen: 11-xuat-loi-moi-chon-khung
Design-Screen: 11-dien-mad-libs-xem-truoc

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
design-source defects. (a) and (b) are genuine layout choices where the spec
and the canvas disagree and PO owns the call; if PO rules for the canvas, the
work is a re-layout of `frame_chip_strip.dart` and
`invite_composer_sheet.dart`, not a change to the Cubit, the payload contract,
or the content pack.
