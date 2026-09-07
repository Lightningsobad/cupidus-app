VISUAL_FIDELITY: FAIL
Design-Screen: man-goc-muon-lam

- Story: REQ-016 / STORY-001, phase P4 (`coding-plan/phase-P4-hub-list-and-entry-point.md` §6)
- Requirement: REQ-016_solo_stage1_relationship_assistant
- Lane: Mobile
- Date: 2026-09-07
- Configuration: `mobile/lib/main_preview.dart`,
  `--dart-define=PREVIEW=man-goc-muon-lam`,
  `--dart-define=PREVIEW_SOLO_HUB_FIXTURE=true`
- Design source: canvas surface `cupid-ch-ng-1`, screen `man-goc-muon-lam`,
  rendered to `design-reference-man-goc-muon-lam-ios.png` (415x900)
- Implementation capture: `implemented-man-goc-muon-lam-round2.png` (405x900),
  Android device `emulator-5554`, native 1080x2400 @ 420dpi = 411dp logical,
  downscaled to 405x900 to match the reference scale
- Round: 2 (rework after the user's "anchor on design" ruling on D-1/D-2/D-3;
  round 1 capture kept as `implemented-man-goc-muon-lam-emulator-5554.png`)

## 0. Comparison region

The capture goes through `HomeScreen`'s unpaired branch, not through
`ActivityCardHubView` directly, because AC-22's gate is that the unpaired
session reaches the hub through the stage-1 tab bar. So the frame contains
surfaces this phase does not own.

### In region (P4 owns these)

| Element | Owner file |
|---|---|
| Quick-entry strip (3 cells) | `presentation/screens/activity_card_hub_view.dart` |
| Five-pane segmented status filter | `presentation/widgets/activity_status_filter.dart` |
| Card list of the selected pane | `presentation/screens/activity_card_hub_view.dart` |
| Card tile: title, meta line, primary action, "…" overflow, delete | `presentation/widgets/activity_card_tile.dart` |
| Stage-1 4-item tab bar and its 3 placeholder destinations | `features/home/presentation/home_screen.dart` |

### Out of region

| Design element | Owner |
|---|---|
| "HÔM NAY, 19:20" hero card | Not in P4 §3 tasks; no phase claims it yet |
| "+" floating action button | `ux/uiux-spec.md` §1 item 5 → P5 / STORY-002 |
| "Muốn làm" title + subtitle + search icon | STORY-012 |
| "MỚI NGHĨ RA" section headers inside the list | Not in P4 §3 tasks |
| Per-card round icon avatars | Blocked on a domain change (see D-5) |
| Metadata chips (`~70k`, `2 tiếng`) as separate pills | Not in P4 §3 tasks |

## 1. Verdict

FAIL.

The three deltas this rework existed to close are closed. What remains are two
carried-over deltas that were already outside P4's reach, plus one new
in-region glyph deviation and one capture-harness defect. Per
`.agent-contract/design-fidelity-spec.md` any visible discrepancy is FAIL with
the concrete delta noted and there is no per-story prose waiver, so the verdict
stays FAIL even though the design ruling has been implemented.

## 2. Closed by this round

| id | Ruling | What now renders |
|---|---|---|
| D-1 | Anchor on design; PO patched AC-10 | Five panes, `Tất cả · 14` leading and default-selected as a solid pink pill, then `Mới nghĩ ra · 8`, `Đã hẹn ngày · 2`, and the remaining two scrolling off the right edge rather than truncating. Matches the reference row cell for cell. |
| D-2 | Anchor on design; PO patched AC-11 | Every card footer carries exactly one gradient CTA plus one round muted `…` overflow immediately to its right, narrower than the CTA and without `--grad`. Overflow contents are only Chuyển trạng thái / Sửa / Xoá — never a second CTA. |
| D-3 | Anchor on design; PO patched AC-22 | The unpaired branch mounts a 4-item stage-1 bar, `Muốn làm · Ý tưởng · Sổ tay · Nhật ký` in that order, `Muốn làm` first, default, pink, and pointing at this story's list. The other three are placeholder shells. |

## 3. In-region deltas

| id | Design shows | Implementation shows | Why |
|---|---|---|---|
| D-4 | No per-card delete affordance | A delete dash on every tile | AC-13 requires the card be removable. Design omits the affordance the AC mandates. Carried over from round 1, unchanged. |
| D-5 | Line 2 of each card starts with an activity-type icon | Line 2 is text only (`chiều · 1.8 km · 70.000đ`) | `ux/uiux-spec.md` §2 asks for the icon, but P2's `ActivityCard.activityType` is a free-text `String?` with no enum, so there is no measurable type→icon map. Closing this needs a domain change outside P4's write scope. Carried over from round 1, unchanged. |
| D-6 | Tab bar glyphs: checklist, lightbulb, open book, lined page with a pencil | `checkCircle`, `autoAwesome` (sparkles), `draw` (pen stroke), `schedule` (clock) | NEW. `ux/uiux-spec.md` §1 only constrains the style (`icon line` + label below), never the glyph, so the four nearest existing tokens were used. `CupidIcons` carries no checklist, lightbulb, book, or edit-note codepoint, and `lib/design_system/icons/cupid_icons.dart` is outside this run's write scope, so the glyphs cannot be matched from here. **Needs a write-scope extension, not a product decision.** |

## 4. Capture-harness defect

| id | Problem | Why it is not a product defect |
|---|---|---|
| D-7 | The capture shows two stacked bottom bars: the new 4-item stage-1 bar, and beneath it the legacy 5-tab app shell bar (Nhà / Trò chuyện / Pet / Ví chung / Tôi). | `lib/main_preview.dart:222` still registers `man-goc-muon-lam` with `wrapInShell: true`, and `:2158` still maps it to `PreviewAppShellTab.home`. Both predate D-3, when the hub genuinely lived inside the shell's "Nhà" tab. The product build has one bar; only the preview harness doubles it. The file is outside this run's write scope. |

D-7 does not invalidate D-1/D-2/D-3 closure — the stage-1 bar itself renders
above the spurious one and is fully legible — but it does mean the frame's
vertical geometry below the card list is not comparable to the reference, so no
spacing claim is made about that band.

## 5. What the capture confirms

Reading `implemented-man-goc-muon-lam-round2.png` top to bottom:

- The unpaired session lands on `Muốn làm`, and `Muốn làm` resolves to the hub —
  AC-22's actual gate, verified through `HomeScreen`, not by rendering the hub
  widget in isolation.
- The shared `--sky` wash now shows through the hub and the stage-1 shell. Both
  Scaffolds dropped their opaque `colorBackground` root fill this round, which
  is what `architecture/solution.md` AD-3 and the STORY-046 backdrop guard
  require.
- The quick-entry strip renders its three cells.
- The five-pane filter renders every label unabbreviated with a plain count,
  never a red badge, and scrolls horizontally instead of shrinking a label.
- Three idea cards, each with a title, a muted meta line, exactly one gradient
  primary action (`Hẹn ngày`), one `…` overflow, and a delete dash.
- No pane is a dead end: the primary action and the two non-destructive
  overflow entries answer with the neutral "Sắp có" message (SC-5), and the
  three placeholder tabs render `<nhãn> — sắp có` per `ux/uiux-spec.md` §6.

## 6. Method notes

- Fixture data, not live runtime: `_PreviewActivityCardRepository` in
  `main_preview.dart` is seeded with the design canvas' own rows and returns
  `{idea: 8, scheduled: 2, done: 3, memory: 1}` so the `Tất cả` count reads 14 —
  the same 14 the design shows. Write methods throw.
- Scale: the capture uses the device's native 411dp logical width, matching the
  design reference's scale. A narrower `--width` was tried and discarded in
  round 1 because it made the hub render oversized.
- Runtime was reachable (`emulator-5554`, Android 16 / API 36), so
  `MOBILE_RUNTIME_UNAVAILABLE` does not apply.
