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
- Implementation capture:
  `implemented-man-goc-muon-lam-emulator-5554.png` (405x900, 84865 bytes),
  Android emulator `emulator-5554`, native 1080x2400 @ 420dpi = 411dp logical
- Round: 1 (one in-region fix applied, then recaptured — see §2)

## 0. Comparison region

The capture goes through `HomeScreen`'s unpaired branch, not through
`ActivityCardHubView` directly, because AC-22's gate is that the existing
"Nhà" tab reaches the hub. So the frame contains surfaces this phase does not
own.

### In region (P4 owns these)

| Element | Owner file |
|---|---|
| Quick-entry strip (3 cells) | `presentation/screens/activity_card_hub_view.dart` |
| Four-pane segmented status filter | `presentation/widgets/activity_status_filter.dart` |
| Card list of the selected pane | `presentation/screens/activity_card_hub_view.dart` |
| Card tile: title, meta line, primary action, delete | `presentation/widgets/activity_card_tile.dart` |
| Entry point: unpaired session renders the hub in "Nhà" | `features/home/presentation/home_screen.dart` |

### Out of region

| Design element | Owner |
|---|---|
| "HÔM NAY, 19:20" hero card | Not in P4 §3 tasks; no phase claims it yet |
| "+" floating action button | `ux/uiux-spec.md` §1 item 5 → P5 / STORY-002 |
| "Muốn làm" title + subtitle + search icon | STORY-012 |
| "MỚI NGHĨ RA" section headers inside the list | Not in P4 §3 tasks |
| Per-card round icon avatars | Blocked on a domain change (see §2, delta D-5) |
| Metadata chips (`~70k`, `2 tiếng`) as separate pills | Not in P4 §3 tasks |
| 5-tab AppShell bar (Nhà / Trò chuyện / Pet / Ví chung / Tôi) | Pre-existing app shell |

## 1. Verdict

FAIL.

`.agent-contract/design-fidelity-spec.md` ("Design source detection and
locking") is explicit: PASS means the render matches the design reference with
no visible deviation, any visible discrepancy is FAIL with the concrete delta
noted, and there is no per-story prose waiver. Three in-region deltas remain,
and they are not implementation defects — they are places where the design
canvas and the authoritative artifacts disagree. Recording them as FAIL is the
only way the contract lets that conflict reach a decision-maker.

## 2. In-region deltas

| id | Design shows | Implementation shows | Why |
|---|---|---|---|
| D-1 | Five filter panes, first is "Tất cả · 14" | Exactly four panes, first is "Mới nghĩ ra · 8" | `ux/uiux-spec.md` §3 and AC-10 both mandate exactly four fixed cells. A fifth "Tất cả" pane would violate the AC the phase is gated on. **Needs a product decision.** |
| D-2 | Hero card carries a "Trước giờ đi" CTA **and** an overflow "…" | One primary action per card, no overflow | SC-4 / AC-11: exactly one primary action per status. A second affordance on the same card is the thing SC-4 forbids. **Needs a product decision.** |
| D-3 | A 4-item Chặng-1 tab bar (Muốn làm / Ý tưởng / Sổ tay / Nhật ký) replaces the app shell bar | Existing 5-tab app shell bar, hub rendered inside "Nhà" | AC-22 and `ux/uiux-spec.md` §1 forbid a new tab or route for the hub. **Needs a product decision.** |
| D-4 | No per-card delete affordance | A delete dash on every tile | AC-13 requires the card be removable. Design omits the affordance the AC mandates. |
| D-5 | Line 2 of each card starts with an activity-type icon | Line 2 is text only (`chiều · 1.8 km · 70.000đ`) | `ux/uiux-spec.md` §2 asks for the icon, but P2's `ActivityCard.activityType` is a free-text `String?` with no enum, so there is no measurable type→icon map. Closing this needs a domain change outside P4's write scope. |

### Fixed in this round

| id | Delta | Fix |
|---|---|---|
| F-1 | Pane count rendered as bare `8`; design renders `Mới nghĩ ra · 8` | `activity_status_filter.dart`: count `Text` changed from `'$count'` to `'· $count'`. Recaptured; suites re-run green afterwards. |

## 3. What the capture confirms

Reading `implemented-man-goc-muon-lam-emulator-5554.png` top to bottom:

- The "Nhà" tab of the running app resolves to the hub for an unpaired
  session — AC-22's actual gate, verified through `HomeScreen`, not by
  rendering the hub widget in isolation.
- The quick-entry strip renders its three cells.
- The segmented filter renders the four labels unabbreviated with plain counts:
  "Mới nghĩ ra · 8" selected (solid pink), "Đã hẹn ngày · 2" and "Đã đi rồi · 3"
  outlined, and the fourth cell scrolling off the right edge rather than
  truncating (`ux/uiux-spec.md` §3).
- Three idea cards, each with a title, a muted meta line, exactly one gradient
  primary action ("Hẹn ngày"), and a delete dash — SC-4 satisfied visually, not
  only in the widget test.
- No pane is a dead end: the primary action answers with the neutral "Sắp có"
  message (SC-5).

## 4. Method notes

- Fixture data, not live runtime: `_PreviewActivityCardRepository` in
  `main_preview.dart` is seeded with the design canvas' own rows and returns
  `{idea: 8, scheduled: 2, done: 3, memory: 1}` so the header count reads 14 —
  the same 14 the design shows. Write methods throw. This follows the spec's
  rule that preview state is fixed with fake data, never by driving live
  runtime.
- Scale: the first capture used `--width=540`, which on a 420dpi device gives a
  ~205dp logical viewport and made the hub render oversized with wrapped
  titles. That capture was discarded. The kept capture uses the device's native
  411dp logical width, matching the design reference's scale.
- Runtime was reachable (`emulator-5554`, Android 16 / API 36), so
  `MOBILE_RUNTIME_UNAVAILABLE` does not apply.
