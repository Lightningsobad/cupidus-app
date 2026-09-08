VISUAL_FIDELITY: FAIL
Design-Screen: man-goc-muon-lam
Design-Screen: phut-1-kho-trong

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
