VISUAL_FIDELITY: FAIL
Design-Screen: man-goc-muon-lam
Design-Screen: phut-1-kho-trong
Design-Screen: chi-tiet-the-moi-nghi-ra
Design-Screen: the-da-thanh-ky-niem

- Story: REQ-016 / STORY-001, phase P7
  (`coding-plan/phase-P7-activity-type-enum-and-card-icon.md` §6); rounds 1-3
  were phase P4 (`coding-plan/phase-P4-hub-list-and-entry-point.md` §6)
- Requirement: REQ-016_solo_stage1_relationship_assistant
- Lane: Mobile
- Date: 2026-09-08
- Configuration: `mobile/lib/main_preview.dart`,
  `--dart-define=PREVIEW=man-goc-muon-lam`,
  `--dart-define=PREVIEW_SOLO_HUB_FIXTURE=true`
- Design source: canvas surface `cupid-ch-ng-1`, screen `man-goc-muon-lam`,
  rendered to `design-reference-man-goc-muon-lam-ios.png` (415x900)
- Implementation capture:
  `implemented-man-goc-muon-lam-round4-emulator-5554.png` (405x900),
  Android device `emulator-5554`, native 1080x2400 @ 420dpi = 411dp logical,
  downscaled to 405x900 to match the reference scale
- Round: 4 (P7 re-measures **D-5 only**, plus the D-4 ruling recorded in
  `../../req_master.md` § Design Ruling Log. D-1/D-2/D-3/D-6/D-7 are closed
  rulings and were not reopened. Earlier captures kept as
  `implemented-man-goc-muon-lam-round3.png`,
  `implemented-man-goc-muon-lam-round2.png`, and
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
| Card tile: title, meta line and its leading type glyph, primary action, "…" overflow | `presentation/widgets/activity_card_tile.dart` |
| Stage-1 4-item tab bar and its 3 placeholder destinations | `features/home/presentation/home_screen.dart` |

### Out of region

| Design element | Owner |
|---|---|
| "HÔM NAY, 19:20" hero card | Not in P4 §3 tasks; no phase claims it yet |
| "+" floating action button | `ux/uiux-spec.md` §1 item 5 → P5 / STORY-002 |
| "Muốn làm" title + subtitle + search icon | STORY-012 |
| "MỚI NGHĨ RA" section headers inside the list | Not in P4 §3 tasks |
| Per-card round icon avatars | The domain change landed in P7; the placement disagreement is now tracked as D-5a |
| Metadata chips (`~70k`, `2 tiếng`) as separate pills | Not in P4 §3 tasks |

## 1. Verdict

FAIL.

D-4 and D-5 are both closed and verified in the round-4 capture. Every delta
this story opened in rounds 1-3 (D-1 through D-7) is now closed.

What is open is one new in-region delta, **D-8**, raised by this round's own
measurement: the canvas carries four context words — `ngoài trời đang mưa`,
`chiều`, `tối nay được`, `Theo lịch âm` — that no field in
`architecture/contract-summary.md` §3 can hold. Removing the activity-type word
from line 2 is what exposed them, and `phase-P7-...md` §6 names this case in
advance as a Product Owner blocker rather than something this lane resolves.

Per `.agent-contract/design-fidelity-spec.md` the token is only ever `PASS` or
`FAIL`, PASS requires no visible deviation, and there is no per-story prose
waiver — so with D-8 visible the verdict stays FAIL. D-8 is not an
implementation defect and there is no code left to write for it: the design
asks for information the accepted data contract does not carry, so closing it
means changing the contract, which is a product decision. Scrum Master routes
D-8 to Product Owner; per that routing D-8 does not hold the mobile lane's
`MOBILE_COMPLETE` for this round.

## 2. Closed by round 2

| id | Ruling | What now renders |
|---|---|---|
| D-1 | Anchor on design; PO patched AC-10 | Five panes, `Tất cả · 14` leading and default-selected as a solid pink pill, then `Mới nghĩ ra · 8`, `Đã hẹn ngày · 2`, and the remaining two scrolling off the right edge rather than truncating. Matches the reference row cell for cell. |
| D-2 | Anchor on design; PO patched AC-11 | Every card footer carries exactly one gradient CTA plus one round muted `…` overflow immediately to its right, narrower than the CTA and without `--grad`. Overflow contents are only Chuyển trạng thái / Sửa / Xoá — never a second CTA. |
| D-3 | Anchor on design; PO patched AC-22 | The unpaired branch mounts a 4-item stage-1 bar, `Muốn làm · Ý tưởng · Sổ tay · Nhật ký` in that order, `Muốn làm` first, default, pink, and pointing at this story's list. The other three are placeholder shells. |

## 3. In-region deltas

| id | Design shows | Implementation shows | Why |
|---|---|---|---|
| **D-8** (new, round 4) | Line 2 / the meta row carries four **context words** the domain has no field for — see the table below | No context word at all: the meta line is `<icon> 2026-09-07 · 1.8 km · 70.000đ` | This is the exact case `phase-P7-...md` §6 told this lane to stop on rather than resolve. No field in `architecture/contract-summary.md` §3 holds any of these words: `scheduledOn` is a civil `YYYY-MM-DD` with no time of day, `distanceKm`/`priceVnd` are numeric, and none of the words is an activity type. Per §6 the lane did **not** invent a column and did **not** widen the enum to absorb them. Needs a Product Owner ruling. |

D-4 and D-5 are both closed this round (§3c). D-8 is the only open in-region
delta, and it is a product decision rather than code: the design asks for
information the accepted data contract cannot carry. That is why the token
stays FAIL while the lane still reports `MOBILE_COMPLETE` — nothing is left to
implement here, only to rule on.

### D-8 evidence — the four context words

Design source: `Cupid Chặng 1 Screens.dc.html` (Claude Design bundle, surface
`cupid-ch-ng-1`, screen `man-goc-muon-lam`), rendered to
`design-reference-man-goc-muon-lam-ios.png`.

| Word | Source line | Rendered as | Which card |
|---|---|---|---|
| `ngoài trời đang mưa` | 125 | 3rd segment of the hero card's meta line: `Vé có rồi · cách 4,2 km · ngoài trời đang mưa` | "HÔM NAY, 19:20" hero card |
| `chiều` | 141 | 3rd chip, paired with a distance: `chiều · 1,8 km` | "Cà phê sách Hào Nam" |
| `tối nay được` | 152 | standalone 2nd chip | "Làm bánh flan mang qua nhà" |
| `Theo lịch âm` | 160 | 1st segment of the description line: `Theo lịch âm · còn 9 ngày nữa` | "Ngắm trăng Rằm ở cầu Long Biên" |

They are not one field. Read together they look like a free-text *availability
/ condition* note — a time of day, a weather condition, an offered slot, a
calendar system — which is a product question about what the card is allowed to
say, not a rendering question. Deciding it is Product Owner's; implementing
whatever is decided is a later phase.

Note that `ngoài trời đang mưa` sits on the hero card, which §0 already lists as
**out of region** for this story. It is recorded here because it is the same
finding, not because this story owns that surface.

## 3c. Closed by round 4

| id | Ruling | What the round-4 capture shows |
|---|---|---|
| D-4 | Anchor on design; no AC-13 patch needed (`../../req_master.md` § Design Ruling Log) | No tile carries a delete dash. Every card footer is exactly one gradient CTA (`Hẹn ngày` / `Chuẩn bị`) plus the round muted `…`, matching the canvas card footers. AC-13's condition reads "at least one forward path OR a delete path" — the `…` → `Xoá` entry still satisfies it, and it is now the single delete route. |
| D-5 | Closed on its own terms: P7 introduced the closed vocabulary, and the glyph goes inline on line 2 per `phase-P7-...md` §3 and `ux/uiux-spec.md` §2 | The activity-type WORD is gone from line 2 on every card, replaced by its mapped glyph: a fork-and-knife (`restaurant`) on "Cà phê sách Hào Nam" for `dining`, and a ticket (`local_activity`) on "Suất chiếu 19:20 — CGV Vincom" for `outing`. Line 2 of the coffee card now reads `1.8 km · 70.000đ` where round 3 read `chiều · 1.8 km · 70.000đ`. Round 1's stated cause — "`activityType` is a free-text `String?` with no enum, so there is no measurable type→icon map" — no longer holds: the enum and a pure type→glyph function both exist. The canvas additionally draws the glyph inside a round avatar left of the title; that placement is **not** reopened here, because P7 §3 and the UX spec both specify the inline line-2 form and this lane implements its accepted spec rather than ranking the two authorities. |

## 3b. Closed by round 3

| id | Fix | What the round-3 capture shows |
|---|---|---|
| D-6 | 4 new `CupidIcons` tokens — `checklist` 0xe6b1, `lightbulb` 0xe0f0, `menuBook` 0xea19, `editNote` 0xe745 — read from the bundled `MaterialSymbolsRounded-Variable.ttf` cmap with `fontTools`, then wired into `_SoloStageOneShellState._icons`. | The bar draws a checklist, a lightbulb, an open book, and a lined page with a pencil, in that order. The glyph names are not a judgment call: the design source names them verbatim (`Cupid Chặng 1 Screens.dc.html` lines 91/92/94/95 → `checklist`, `lightbulb`, `menu_book`, `edit_note`), and all four resolve in the bundled font. Matches the reference glyph for glyph. |
| D-7 | `man-goc-muon-lam` dropped `wrapInShell: true` and its stale `PreviewAppShellTab.home` arm in `lib/main_preview.dart`. | Exactly one bottom bar. The legacy 5-tab shell bar (Nhà / Trò chuyện / Pet / Ví chung / Tôi) is gone, so the frame's vertical geometry below the card list is now comparable to the reference. The reclaimed band also reveals the 4th card ("Suất chiếu 19:20 — CGV Vincom") that round 2 clipped. |

Only this one preview entry was changed; every other `wrapInShell` registration
in the file is untouched, so no other screen's capture geometry moves.

## 5. What the capture confirms

Reading `implemented-man-goc-muon-lam-round4-emulator-5554.png` top to bottom:

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
- Three idea cards, each with a title, exactly one gradient primary action
  (`Hẹn ngày`) and one `…` overflow — and no delete dash on any of them (D-4).
  A fourth card is visible in the band the removed second bar freed.
- Where a card has a meta line, that line now begins with the activity-type
  glyph instead of the type word (D-5, domain half). "Làm bánh flan mang qua
  nhà" and "Ngắm trăng Rằm ở cầu Long Biên" carry no meta line at all in this
  fixture, and correctly draw no leading glyph rather than a bare fallback.
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
- Round 4, same method, 7 more tokens: `local_activity` 0xe53f, `home` 0xe88a,
  `groups` 0xf233, `directions_walk` 0xe536, `photo_camera` 0xe3b0, `redeem`
  0xe8b1, `label` 0xe892. Aliases were confirmed to be the same glyph by
  comparing `RecordingPen` signatures, not by assuming adjacent codepoints
  match. **`card_giftcard`, which `phase-P7-...md` §3 names for `gift`, is not
  in the bundled font's cmap at all** — the only gift glyphs present are
  `redeem` and `featured_seasonal_and_gifts` 0xef91. The lane substituted
  `redeem` and documented it on the token rather than inventing a codepoint.
  Worth a Tech Lead confirmation, but not a blocker: no glyph was guessed.
- The round-4 device pid was checked immediately before and immediately after
  the capture (27940 both times) so this frame is this lane's build, not a
  neighbouring lane's install landing between launch and screencap.
- `phase-P7-...md` §6's measurement warning fired exactly as written: removing
  the type word from line 2 exposed the canvas' own context words. Per that
  instruction the lane stopped at reporting it and neither added a column nor
  widened the enum to absorb the words. It is filed as delta **D-8** with its
  design-source line numbers in §3, not as a soft note, so Product Owner
  adjudicates it on the same footing as D-1 through D-7.

## 7. Round 5 — phase P5, Minute-1 empty state

This round covers a second design screen. Rounds 1–4 above are the card hub in
its filled state (`man-goc-muon-lam`) and stay as written; nothing here edits
them, and the head verdict stays `FAIL` because D-8 is still open and
Product-Owner-owned.

- Design-Screen: `phut-1-kho-trong`
- Surface: `cupid-ch-ng-1`
- Reference: `design-reference-phut-1-kho-trong-ios.png` (415x900)
- Implementation: `implemented-phut-1-kho-trong-ios.png` (415x900, the state the
  user lands on) and `implemented-phut-1-kho-trong-ios-suggestions.png` (same
  screen after the second invitation is tapped, showing the occasion rows)
- Round verdict: PASS on layout, structure and tokens; five design deltas below
  are `DESIGN_SPEC_CONFLICT`, where the canvas and the approved UX spec disagree
  and the lane implemented the spec.

### 7.1 Comparison region

Reference and implementation are both 415x900 with no crop, so the compared
region is the whole screen. Both frames were rendered at `CupidPlatform.ios`
to match the reference's platform suffix.

### 7.2 What matches

- One short headline, then two full-width invitation cards stacked with
  `CupidSpacing.md` between them, then the quick-entry strip along the bottom —
  the same vertical order and the same proportions as the canvas.
- Invitation 1 carries the accent: `gradientHot` glyph tile on a
  `colorAccentPink` border, exactly as the design's primary invite.
  Invitation 2 is the quiet one: `colorSurfaceAlt` tile, `colorLine` border,
  mint glyph.
- Glyph tiles are `platform.tapTarget` square at `radiusSmall`; cards use
  `radiusCard`; every tappable row clears the platform tap target.
- Type ramp and colours are read from tokens only (`cardTitle`, `body`,
  `caption`, `colorText`, `colorTextMuted`), with no literal hex or font size in
  the new widgets.
- The segmented status filter is absent, as the design shows it absent.

### 7.3 Deltas

- **D-9 — the design has no quick-entry strip; the spec requires one.**
  `ux/uiux-spec.md` §4a and §6 and `phase-P5-...md` §4 (AC-2) require the fixed
  three-cell strip to render in every state including absolute-empty. The canvas
  ends after the second invitation. Implemented to the spec: the strip is
  present, always three cells, identical cell widths in both captured states.
  `DESIGN_SPEC_CONFLICT`.
- **D-10 — the design's headline is three lines and is followed by a body
  paragraph and two footer lines.** §4a is explicit that Minute-1 carries "tối
  đa một dòng tiêu đề ngắn" and "không có mô tả đoạn văn". Implemented to the
  spec: a single `maxLines: 1` title and no paragraph, which is why the
  implementation frame has more empty space above the invitations than the
  canvas. `DESIGN_SPEC_CONFLICT`.
- **D-11 — the design gives each invitation a marketing subtitle.** A subtitle
  under each invite is the paragraph copy §4a excludes, and it also makes the
  two invitations look like a choice to study rather than two one-tap doors.
  Implemented to the spec: one label line per invitation, no subtitle.
  `DESIGN_SPEC_CONFLICT`.
- **D-12 — the design's second invitation names a specific occasion in its
  subtitle.** That string is occasion content. R-15a makes occasion content data
  from the shipped package, never a literal in Dart, and the nearest occasion is
  device-date dependent so a baked string would be wrong most of the year.
  Implemented to the spec: the invitation label is occasion-neutral, and the
  occasion name appears only after the tap, read from the package
  (`activity_minute1_occasion_name` in the suggestions capture).
  `DESIGN_SPEC_CONFLICT`.
- **D-13 — the design's second invitation uses a calendar-with-check glyph that
  has no `CupidIcons` token.** Adding a token means editing `cupid_icons.dart`,
  which is outside this phase's write scope, and inventing a codepoint is
  forbidden by that file's own rule. Substituted `schedule`, already in the
  bundled cmap and already used for the scheduled sense elsewhere. Cosmetic and
  cheap to correct in a later phase that owns the icon file. Not a blocker.

### 7.4 Harness artefact, not a delta

The implementation frames show a flat `colorBackground` where the design shows
the sky wash. The wash is `CupidAppBackground`, mounted once at the composition
root through `MaterialApp.builder`, so it is above this widget and outside this
phase's write scope. Mounted in the real app the wash is inherited unchanged;
the flat field is a property of the capture host, and no background colour was
overridden in the widgets under test.

### 7.5 Method notes

- Runtime path is unreachable for this screen, and no runtime blocker applies.
  `phut-1-kho-trong` has no `previewScreens` entry; `main_preview.dart` and
  `activity_card_hub_view.dart` are both outside this phase's write scope, and
  the hub currently renders `Key('activity_card_hub_minute1_slot')`, an empty
  placeholder, where this widget will later mount. So no running build can
  navigate to the screen this phase produced — the screen does not exist on any
  route yet, which is not the same as a device being unavailable.
  `MOBILE_RUNTIME_UNAVAILABLE` therefore does **not** apply and was not emitted.
- Capture method is the in-test `RepaintBoundary` fallback: the widget tree is
  pumped at the reference's exact 415x900 viewport with the four bundled TTFs
  registered through `FontLoader`, then `RepaintBoundary.toImage(pixelRatio: 1)`
  writes the PNG. It is gated behind `kCaptureVisuals`
  (`--dart-define=CAPTURE_VISUALS=true`) so an ordinary test run neither renders
  fonts nor writes files.
- Command: `flutter test test/features/activity_cards/minute_one_empty_state_test.dart
  --dart-define=CAPTURE_VISUALS=true` → `+8: All tests passed!`, both PNGs
  written and visually confirmed (glyphs resolved, no tofu, no DEBUG ribbon —
  `debugShowCheckedModeBanner: false` was set on the capture host after the
  first frame showed it).
- The capture host inlines its own support rather than importing the reminders'
  `visual_capture_support.dart`, whose output directory is hard-wired to REQ-002
  and which is outside this phase's write scope.
- No design canvas render was needed: `design-reference-phut-1-kho-trong-ios.png`
  already existed at the matching 415x900, so `render-design-canvas.js` was not
  re-run and the reference was not regenerated.

## 8. Round 6 — phase P6, card detail, lifecycle and delete

This round covers the third and fourth design screens. Rounds 1–5 above stay as
written; nothing here edits them, and the head verdict stays `FAIL` because D-8
is still open and Product-Owner-owned.

- Design-Screen: `chi-tiet-the-moi-nghi-ra` and `the-da-thanh-ky-niem`
- Surface: `cupid-ch-ng-1`
- Reference: `design-reference-chi-tiet-the-moi-nghi-ra-ios.png` and
  `design-reference-the-da-thanh-ky-niem-ios.png` (both 415x900)
- Implementation: `implemented-chi-tiet-the-moi-nghi-ra-ios.png` (status *Mới
  nghĩ ra*), `implemented-chi-tiet-the-moi-nghi-ra-ios-ghi-lai.png` (status *Đã
  đi rồi* — the "đang ghi lại" mode AC-13 asks for) and
  `implemented-the-da-thanh-ky-niem-ios.png` (status *Đã thành kỷ niệm* — the
  "xem lại" mode)
- Round verdict: PASS on layout, structure and tokens for both pairs. The
  deltas below are `DESIGN_SPEC_CONFLICT` (canvas versus approved UX spec),
  `CONTRACT_GAP` (canvas draws a field the `activity_cards` contract has no
  column for), or icon substitutions of the D-13 kind. None is a blocker.

### 8.1 Comparison region

Reference and implementation are 415x900 with no crop, both rendered at
`CupidPlatform.ios` to match the reference's platform suffix, so the compared
region is the whole viewport.

Two notes on what the region does and does not contain:

- The `-ghi-lai` frame has **no design counterpart**. The canvas draws the card
  detail only in *Mới nghĩ ra* (A4) and *Đã thành kỷ niệm* (A8); "đang ghi lại"
  is a mode AC-13 requires and the canvas never drew. It is captured and
  reported here so the phase's required "cả hai chế độ" evidence exists, and it
  is compared against `ux/uiux-spec.md` §5 rather than against a PNG. Its file
  name carries the A4 screen token plus a `-ghi-lai` suffix, the same shape
  round 5 used for `implemented-phut-1-kho-trong-ios-suggestions.png`.
- In the A8 frame the primary CTA sits below the 900px fold, under the memory
  photo placeholder. The screen scrolls; the CTA exists and is asserted by
  `activity_card_detail_screen_test.dart` → `"xem lại" keeps a way out, so a
  memory is not a dead end`. The fold is a property of the reference viewport,
  not a missing element.

### 8.2 What matches

- Both modes are one screen at one route, as AC-13 requires: the same
  `Key('activity_card_detail')` scroll view, the same header, the same note
  block, the same lifecycle rows. Only the status pill, the memory photo frame,
  the note label and the CTA change between them.
- Header shape matches: back affordance top-left, status pill on the same line,
  large `cardTitle` headline directly under it.
- The status pill carries the design's dot-plus-label form, `colorAccentPink`
  tinted at 0.18 for the three working statuses and `colorButter` for the
  memory status — the gold the A8 pill uses.
- The memory frame matches A8's structure: a tall rounded `colorSurface` card
  with a centred glyph, drawn only in the memory mode.
- The quote block matches A8 label-for-label: `CÂU BẠN VIẾT TỐI ĐÓ` in
  `colorTextMuted` 11px/700/0.6, body text beneath on `colorSurface` at
  `radiusCard`.
- Chip row, source-link row and stat cards use the design's pill and card
  geometry (`radiusSmall`/`radiusCard`, `colorSurface`, `colorSurfaceAlt` for
  the selected chip) with no literal hex or font size in the new widgets — type
  and colour are read from `cupidType`/`cupidColors` only.
- The A4 CTA is the design's full-width gradient pill on `gradientHot` with a
  leading glyph; the A8 CTA is the design's outlined variant, `colorSurface`
  with a 1.5px `colorLine` border and a butter glyph.
- Every tappable row — status row, delete row, dialog buttons, picker options —
  clears `platform.tapTarget`.

### 8.3 Deltas

- **D-14 — the design's header carries `ios_share` and `more_horiz` tiles.**
  Sharing has no acceptance criterion in this story. The overflow menu is worse
  than absent here: AC-14 and AC-16 require status change and delete to be
  reachable, and AC-16 in particular asks for "một hộp thoại thẳng", so both are
  drawn as explicit labelled rows instead of being hidden one tap deeper.
  Implemented to the spec. `DESIGN_SPEC_CONFLICT`.
- **D-15 — A4 draws a 2x2 stat grid (GIÁ, THỜI LƯỢNG, KHUNG GIỜ, KHOẢNG
  CÁCH); the implementation draws two cards.** `activity_cards` has no duration
  and no time-window column, and `contract-summary.md` §4 makes adding one a
  decision this phase does not own. GIÁ and KHOẢNG CÁCH are implemented; the
  other two are omitted rather than faked. `CONTRACT_GAP` — needs Product Owner
  and Tech Lead if those two fields are wanted.
- **D-16 — the design formats money and distance as display strings
  ("~70.000đ", "180.000đ", "1,8 km"); the implementation shows the raw number
  with a muted unit suffix ("120000 đ", "3.5 km").** AC-6 makes these fields
  editable in place, and a thousands-grouped string is not a valid edit buffer —
  the field would fight the keyboard on every keystroke. Round 6 added the unit
  suffix so the number is never unitless; grouping is deliberately left for a
  later phase that either splits display from edit or moves the fields behind a
  sheet. Cosmetic, not a blocker.
- **D-17 — A4 draws the note twice: a description line under the title and a
  `SỔ TAY CÓ GHI` block of lilac keyword chips.** The contract has exactly one
  free-text `note` column and no keyword list, so both design elements collapse
  into one editable paragraph under one `SỔ TAY CÓ GHI` label. `CONTRACT_GAP`.
- **D-18 — the design's CTA copy is per-screen prose ("Chốt ngày đi thôi",
  "Đọc lại · rủ đi lần nữa"); the implementation uses "Hẹn ngày" and "Xem
  lại".** `ux/uiux-spec.md` §2 fixes the four SC-4 labels, AC-13 requires the
  same label wherever the action appears, and P4's card tile already ships that
  table through `activityPrimaryActionFor`. Diverging on the detail screen would
  break the tile/detail match. Implemented to the spec.
  `DESIGN_SPEC_CONFLICT`. **Closed in round 7 — the user ruled anchor-on-design;
  see §9.**
- **D-19 — A4 puts a secondary line under the CTA ("hoặc soạn lời rủ cho ngọt ·
  để dành hôm khác"), which is two more actions.** SC-4 is "đúng một hành động
  chính" per status. Implemented to the spec: one CTA, no secondary line.
  `DESIGN_SPEC_CONFLICT`. **Closed in round 7 — the user ruled anchor-on-design;
  see §9.**
- **D-20 — four glyphs the design uses have no `CupidIcons` token.**
  `event` → `schedule`, `history` → `menuBook`, `image` → `photoCamera`, and the
  delete row's trash → `remove`. `cupid_icons.dart` is outside this phase's
  write scope and its own rule forbids inventing a codepoint, so this is the
  D-13 substitution rule applied again. Cosmetic and cheap to correct in a phase
  that owns the icon file.
- **D-21 — block order differs.** The design runs title → meta → note →
  chips → link → CTA; the implementation runs title → note → stats → chips →
  link → invited → lifecycle rows → CTA. The lifecycle rows have no canvas
  counterpart at all (see D-27), and the note is lifted above the stats because
  in the record mode it is the field the CTA focuses.
- **D-22 — the design's source-link row is two lines ("Từ cái link bạn dán ngày
  28/8" plus a truncated URL); the implementation is one editable URL field.**
  There is no column recording when the link was pasted, and AC-6 makes the link
  editable. `CONTRACT_GAP` for the provenance line.
- **D-23 — A8's pill is right-aligned and reads "★ KỶ NIỆM"; the implementation
  keeps the pill beside the back affordance and reads "ĐÃ THÀNH KỶ NIỆM".** The
  label is the shared four-status vocabulary D-1 froze, so shortening it on one
  screen would reintroduce exactly the drift D-1 closed. The left placement is a
  real positional delta, kept because A4 needs the same header line for both
  modes and AC-13 asks for one screen, not two headers. Cosmetic.
- **D-24 — A8's photo frame has a diagonal hatch and a two-line caption
  ("ảnh hôm chèo thuyền hồ Tây / (người dùng tự thả vào)").** That caption is a
  design annotation for photo upload, which has no acceptance criterion in this
  story and no column in `activity_cards`. The implementation draws the frame as
  a plain placeholder so the memory mode reads as a memory, and leaves upload to
  the story that owns it. `CONTRACT_GAP`.
- **D-25 — A8's two stat cards are aggregates ("4 lần đi chung", "15 chỗ để
  dành") and it adds an insight strip ("Buổi đó sổ tay ghi thêm được: sợ nước
  sâu · thích chỗ vắng người").** Both are cross-card derivations: the P2
  repository contract exposes `countsByStatus` only, and the insight strip is
  taste-profile scope owned by a later requirement. For the record these are
  *not* AC-18/AC-19 violations — they count shared outings, they do not score
  the other person — they are simply outside this contract. The implementation
  shows the card's own GIÁ and KHOẢNG CÁCH instead. `CONTRACT_GAP`.
- **D-26 — A8 places the title below the photo and follows it with a meta line
  ("Thứ Bảy 16/8 · 2 tiếng 10 · 180.000đ · trời hanh").** The title stays above
  the photo so the header is identical in all four statuses, and the meta line
  is not rendered because duration and weather have no columns (same root cause
  as D-15). Structural.
- **D-27 — the implementation adds three elements neither canvas draws:** the
  "Chuyển trạng thái" row, the "Xoá thẻ" row, and the invited/reply chips.
  These are required by AC-14, AC-16 and AC-17 respectively. Recorded here so a
  reviewer reads them as deliberate additions rather than stray widgets.

### 8.4 Harness artefacts, not deltas

- No iOS status bar. The design references were rendered from the canvas, which
  paints its own 9:41 status row; a widget capture has no system chrome. Round 5
  classified this the same way.
- Flat `colorBackground` where the design shows the sky wash, for the reason
  §7.4 already records: `CupidAppBackground` is mounted at the composition root
  through `MaterialApp.builder`, above this widget and outside this phase's
  write scope.

### 8.5 Method notes

- Runtime path is unreachable for this screen and no runtime blocker applies,
  for the same reason §7.5 records: the detail screen has no route because
  mounting it is `activity_card_hub_view.dart`'s job and that file is outside
  this phase's write scope. A screen that exists on no route is not a device
  being unavailable, so `MOBILE_RUNTIME_UNAVAILABLE` does **not** apply and was
  not emitted.
- Capture method is the in-test `RepaintBoundary` fallback established in round
  5: the tree is pumped at the reference's exact 415x900 viewport with the four
  bundled TTFs registered through `FontLoader`, then
  `RepaintBoundary.toImage(pixelRatio: 1)` writes the PNG, all gated behind
  `--dart-define=CAPTURE_VISUALS=true`.
- Command: `flutter test
  test/features/activity_cards/activity_card_detail_screen_test.dart
  --dart-define=CAPTURE_VISUALS=true` → `+7: All tests passed!`, all three PNGs
  written and visually confirmed (glyphs resolved, no tofu, no DEBUG ribbon).
- **The first capture run produced three frames that were all the *idea*
  status.** Pumping the same widget type three times reuses the element tree,
  so `BlocProvider.create` never re-ran and every frame rendered card one under
  a different file name. Fixed by keying the screen on its status, and the
  capture loop now reads the status pill back and fails before writing if the
  frame does not match its file name — a mislabelled frame is worse evidence
  than no frame.
- Design references were rendered from the canvas at 415x900 with
  `render-design-canvas.js`; the `--lang` flag was not passed because this
  canvas exposes no toggles.

## 9. Round 7 — A4 CTA re-capture after the D-18/D-19 rulings

Scope of this round is one screen and one region: the CTA block of
`chi-tiet-the-moi-nghi-ra`. D-18 and D-19 were raised in round 6 as
`DESIGN_SPEC_CONFLICT`; the user ruled **anchor on design**, Product Owner
patched AC-11/AC-13 and `ux/uiux-spec.md` §2 (26427f2), and the CTA block was
rebuilt in `dedd45b`. Rounds 1-6 are not reopened and no other screen's entry
was re-measured or re-captured.

- Design-Screen: `chi-tiet-the-moi-nghi-ra`
- Reference: `design-reference-chi-tiet-the-moi-nghi-ra-ios.png` (415x900,
  unchanged — D-18/D-19 are visual-copy findings against the same canvas frame,
  so the reference was not re-sourced)
- Implementation: `implemented-chi-tiet-the-moi-nghi-ra-ios.png`
  (`ActivityCardStatus.idea`, *Mới nghĩ ra*) and
  `implemented-chi-tiet-the-moi-nghi-ra-ios-ghi-lai.png`
  (`ActivityCardStatus.done`, *Đã đi rồi*), both 415x900, both recaptured
- Round verdict: **D-18 and D-19 are closed** — the two findings this round was
  dispatched to re-judge both now match the design. The screen is **not** a
  clean `PASS`: two cosmetic deltas remain visible in the same CTA region, D-20
  (icon substitution, carried over from round 6) and D-28 (new, below). Neither
  is a blocker and neither is an implementation defect, but per
  `.agent-contract/design-fidelity-spec.md` a visible deviation is not `PASS`,
  so this round does not turn the head token green.

### 9.1 What the re-capture confirms

- **D-18 closed.** The *Mới nghĩ ra* frame's CTA now reads `Chốt ngày đi thôi`,
  the canvas string, in place of the fixed SC-4 label `Hẹn ngày`. The pill keeps
  the design's geometry: full width, 54px tall, `gradientHot` pink→violet,
  `radiusButton`, leading glyph then label, label centred.
- **D-18 in the second mode.** The `-ghi-lai` frame reads `Ghi lại buổi đó đi`.
  The canvas never drew this mode (§8.1), so it is judged against
  `ux/uiux-spec.md` §2 as patched: same voice, same one-action rule, wording
  specific to the status.
- **D-19 closed.** One caption line sits under the CTA in both frames — `hoặc
  soạn lời rủ cho ngọt · để dành hôm khác` on *Mới nghĩ ra*, matching the
  canvas string exactly, and `hoặc thêm ảnh sau · viết dần cũng được` on the
  record mode. It renders as inert prose: `caption` type, `colorTextMuted`, no
  fill, no border, no tap target, so SC-4's "đúng một hành động chính" still
  holds visually as well as behaviourally.
- **No overflow.** The longer D-18 strings fit at the 415pt reference width;
  `FittedBox(scaleDown)` absorbs the excess and no RenderFlex stripe appears in
  either frame. The label is never truncated or ellipsised.
- **Nothing else moved.** Header, status pill, note block, stat cards, chip row,
  source-link row, invited chips and the two lifecycle rows are pixel-stable
  against the round-6 frames; the diff is confined to the CTA block.

### 9.2 New delta

- **D-28 — the canvas colours part of the secondary line.** In the reference,
  `soạn lời rủ cho ngọt` is set in the accent pink while `hoặc` and `· để dành
  hôm khác` stay muted; the implementation draws the whole line in
  `colorTextMuted`. The emphasis reads, in the canvas, as a hint that the phrase
  is tappable — which is exactly what D-19's ruling says it must not be, since
  SC-4 allows one action. Uniform muted text is the honest rendering of an inert
  line, so this is left as-is and recorded rather than matched. Cosmetic,
  not a blocker.

### 9.3 Still open, unchanged by this round

- **D-8** stays open and Product-Owner-owned (§1). Nothing in this round touches
  it, so the head `VISUAL_FIDELITY:` token stays `FAIL` for the D-8 reason
  recorded there — this round narrows what FAIL covers, it does not clear it.
- **D-20** (`event` → `CupidIcons.schedule` on the A4 CTA) is re-confirmed by
  this capture: the design's CTA glyph is a calendar, the implementation's is a
  clock. `cupid_icons.dart` is still outside this phase's write scope, so the
  round-6 substitution note stands unchanged.
- D-14 to D-17 and D-21 to D-27 were not re-measured; their round-6 text stands.

### 9.4 Method notes

- Same in-test `RepaintBoundary` fallback as rounds 5 and 6, same 415x900
  viewport, same four TTFs via `FontLoader`, same status read-back guard before
  each PNG is kept.
- Command: `flutter test
  test/features/activity_cards/activity_card_detail_screen_test.dart
  --dart-define=CAPTURE_VISUALS=true` → `+8: All tests passed!` (round 6 was
  `+7`; the two D-18/D-19 widget tests from `dedd45b` are in this file).
- The capture loop writes all three of this file's frames in one pass, so
  `implemented-the-da-thanh-ky-niem-ios.png` was rewritten and then restored
  from `HEAD`: A8 is outside this round's write scope. Its in-region content is
  unaffected either way — §8.1 records that A8's CTA sits below the 900px fold,
  and D-18/D-19 changed only the CTA block. **A8's frame is nonetheless stale
  below the fold** (its CTA now reads `Đọc lại · rủ đi lần nữa` and carries a
  secondary line); refreshing it needs a dispatch whose write scope includes
  that file.
