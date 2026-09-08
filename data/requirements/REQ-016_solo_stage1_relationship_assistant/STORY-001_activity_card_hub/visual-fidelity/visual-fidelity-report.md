VISUAL_FIDELITY: FAIL
Design-Screen: man-goc-muon-lam

- Story: REQ-016 / STORY-001, phase P4 (`coding-plan/phase-P4-hub-list-and-entry-point.md` §6)
- Requirement: REQ-016_solo_stage1_relationship_assistant
- Lane: Mobile
- Date: 2026-09-08
- Configuration: `mobile/lib/main_preview.dart`,
  `--dart-define=PREVIEW=man-goc-muon-lam`,
  `--dart-define=PREVIEW_SOLO_HUB_FIXTURE=true`
- Design source: canvas surface `cupid-ch-ng-1`, screen `man-goc-muon-lam`,
  rendered to `design-reference-man-goc-muon-lam-ios.png` (415x900)
- Implementation capture: `implemented-man-goc-muon-lam-round3.png` (405x900),
  Android device `emulator-5554`, native 1080x2400 @ 420dpi = 411dp logical,
  downscaled to 405x900 to match the reference scale
- Round: 3 (narrow write-scope extension to close D-6 and D-7; round 2 capture
  kept as `implemented-man-goc-muon-lam-round2.png`, round 1 as
  `implemented-man-goc-muon-lam-emulator-5554.png`)

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

Both deltas this round existed to close — D-6 and D-7 — are closed and verified
in the round-3 capture. What remains is exactly D-4 and D-5, the two deltas
carried unchanged since round 1, both of which need a decision or a domain
change outside P4's reach. Per `.agent-contract/design-fidelity-spec.md` the
token is only ever `PASS` or `FAIL`, PASS requires no visible deviation, and
there is no per-story prose waiver — so with D-4 and D-5 still visible the
verdict stays FAIL. Rounds cannot clear it from inside this story's scope;
routing D-4/D-5 is a Scrum Master decision.

## 2. Closed by round 2

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

D-4 and D-5 are the only remaining deltas and are unchanged by round 3 — it did
not touch the tile or the domain. Both are why the token is still FAIL, and
neither is closable from inside P4's scope: D-4 is a design-vs-AC-13 conflict
that needs a product ruling, D-5 needs an `activityType` enum.

## 3b. Closed by round 3

| id | Fix | What the round-3 capture shows |
|---|---|---|
| D-6 | 4 new `CupidIcons` tokens — `checklist` 0xe6b1, `lightbulb` 0xe0f0, `menuBook` 0xea19, `editNote` 0xe745 — read from the bundled `MaterialSymbolsRounded-Variable.ttf` cmap with `fontTools`, then wired into `_SoloStageOneShellState._icons`. | The bar draws a checklist, a lightbulb, an open book, and a lined page with a pencil, in that order. The glyph names are not a judgment call: the design source names them verbatim (`Cupid Chặng 1 Screens.dc.html` lines 91/92/94/95 → `checklist`, `lightbulb`, `menu_book`, `edit_note`), and all four resolve in the bundled font. Matches the reference glyph for glyph. |
| D-7 | `man-goc-muon-lam` dropped `wrapInShell: true` and its stale `PreviewAppShellTab.home` arm in `lib/main_preview.dart`. | Exactly one bottom bar. The legacy 5-tab shell bar (Nhà / Trò chuyện / Pet / Ví chung / Tôi) is gone, so the frame's vertical geometry below the card list is now comparable to the reference. The reclaimed band also reveals the 4th card ("Suất chiếu 19:20 — CGV Vincom") that round 2 clipped. |

Only this one preview entry was changed; every other `wrapInShell` registration
in the file is untouched, so no other screen's capture geometry moves.

## 5. What the capture confirms

Reading `implemented-man-goc-muon-lam-round3.png` top to bottom:

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
  primary action (`Hẹn ngày`), one `…` overflow, and a delete dash, plus a
  fourth card now visible in the band the removed second bar freed.
- One bottom bar, carrying the four design-named glyphs above the four labels.
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
- Glyph codepoints were resolved by reading the bundled font's cmap with
  `fontTools` (`TTFont.getBestCmap()`), never recalled from a different icon
  font's PUA range, per the rule at the top of `cupid_icons.dart`. `lightbulb`
  aliases 0xe0f0/0xe90f to one glyph; `menu_book` 0xea19 is distinct from
  `book` 0xe865 and `auto_stories` 0xe666, and the design names `menu_book`.
