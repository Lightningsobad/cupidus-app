# Diagnosis: BUG-20260825-001 home_screen_design_mismatch

## Pre-Fix Reproduction Gate

Modality: rendered visual comparison (Android emulator capture vs. rendered
design source) — the same modality as the user report.

Result: REPRODUCED

Design source (locked, from `data/devops/system/design-fidelity-config.json`):
- Surface id `cupid-app`, entry `cupid-app-design-system/Cupid App.dc.html`
- Screen id `home`, platform `android`

Commands run:

| Command | Result |
| --- | --- |
| `node .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=cupid-app --screen=home --platform=android --out=data/bugs/BUG-20260825-001_home_screen_design_mismatch/evidence/design` | `DESIGN_CANVAS: OK .../design-reference-home-android.png 406x900` |
| `cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter build apk --debug --target=lib/main_preview.dart --dart-define=PREVIEW=home` | `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` |
| `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-local-debug.apk` | `Success` |
| `.ai-team-bundle/runtime/tools/capture-mobile-screen.sh --out=.../evidence --label=home --device=emulator-5554 --platform=android --route="cupidpreview://screen/home" --settle-ms=4000 --max-edge=900` | `MOBILE_CAPTURE: OK .../implemented-home-emulator-5554.png 405x900` |

Artifacts:
- Design reference:
  `data/bugs/BUG-20260825-001_home_screen_design_mismatch/evidence/design/design-reference-home-android.png`
- Implementation capture:
  `data/bugs/BUG-20260825-001_home_screen_design_mismatch/evidence/implemented-home-emulator-5554.png`

Device note: the emulator display was left at its native `1080x2400 / 420dpi`.
An earlier capture forced `--width=406`, which collapses the logical width to
~155dp and produces a distorted layout that is a capture artefact, not the
defect. That capture was discarded and is not part of the evidence set.

### Observed divergences (enumerated from the two renders)

The user report named no specific element, so the divergences are enumerated
here from the side-by-side renders.

| # | Design source (`home`) | Implementation capture | Kind |
|---|---|---|---|
| M1 | Couple-presence header: two overlapping 42px gradient avatar discs, couple title `Minh & Linh`, couple-type label `Cùng thành phố`, share + bell actions | Absent — screen starts directly with the entry-card list | Missing block |
| M2 | Days counter: `247` under the Dream Gradient with trailing `ngày bên nhau` | Absent | Missing block |
| M3 | Hero caption `Chịu đựng nhau được 247 ngày rồi, giỏi quá 🎀` | Absent | Missing block |
| M4 | Next-milestone pill `Còn 53 ngày nữa tới mốc 300` on `colorSurface` | Absent | Missing block |
| M5 | Pink 180px radial hero glow at top-right inside the screen frame | Not visible (nothing is painted in that region) | Missing decoration |
| M6 | Anti-ghost alert card styled as a warning row (amber icon tile, title `Seen 5 phút rồi đấy`, subtitle, chevron) | Generic entry card titled `Anti-Ghosting`, no alert styling, no subtitle | Styling / content |
| M7 | `Vibe Check` card containing two sub-tiles (`Bạn` / `Mình`) and a `Lịch sử` action | Single generic row `Cảm xúc hằng ngày` / `Lịch sử` | Structure |
| M8 | Bún pet card: sprite, `Lv.3` badge, status line, progress bar | Generic row reading `Không thể tải Bún` (error/degraded state) | Structure + runtime failure |
| M9 | 2-column quick grid (`Synced Alarm`, `Zodiac Red Flag`, and further tiles) | Single-column full-width rows (`Nhắc nhở đồng bộ`, `Hũ Ước Mơ`, `Chi tiêu chung`, `Thư viện ảnh`) | Layout |
| M10 | 5-tab bar `Nhà / Trò chuyện / Pet / Ví chung / Tôi` | Matches — no divergence | OK |

M1–M5 are the block that `REQ-002 / STORY-017_home_dashboard_design_fidelity`
explicitly built and verified (its visual-fidelity report §2 `D3`–`D8`, with a
matching `implemented-home-android-emulator-5560.png` capture). Their total
absence from the current render is the primary regression signal and the first
thing root-cause analysis must explain.

M6–M9 overlap `STORY-017` deferral `F6` ("design's vibe / pet / quick-grid /
timeline cards ... each lives in its own feature widget file outside this
story's WriteScope"), so they are candidate out-of-scope delivery rather than
regressions, and must be classified before any patch.

### Capture-harness correction (applied before root-cause analysis)

The first capture in the table above was built **without**
`--dart-define=PREVIEW_HOME_FIXTURE=true`. Without that define,
`main_preview.dart:834` hands `HomeScreen` the live `AccountRepository`, which
has no authenticated session on this emulator, so `_CoupleHeroHeader`'s
`FutureBuilder` never receives a profile and returns `SizedBox.shrink()`
(`home_screen.dart:255-257`). That produced a render with M1–M5 entirely
missing, which is a **harness artefact, not the defect**.

`STORY-017`'s own visual-fidelity report §1 (lines 68-79) establishes the
correct harness: the fixture define is mandatory for this screen because the
design's `home` state (paired couple, `SAME_CITY`, day 247) cannot be reached
without it. The screen was rebuilt with the define and recaptured; the corrected
capture is the one stored at
`evidence/implemented-home-emulator-5554.png` and is the basis of the
classification below. M1–M5 are **withdrawn**: with the correct harness the
presence row, days counter, caption, milestone pill and hero glow all render.

Additional confirmation that Home cannot be captured any other way:
`evidence/implemented-real-entrypoint-emulator-5554.png` shows the real
`lib/main.dart` entrypoint landing on the pairing-choice screen
(`Ghép đôi để mở khoá Cupid`) on an unauthenticated device — Home is behind
auth + pairing.

## Root Cause

**This is not a regression. It is the accumulated set of Home-dashboard
surfaces that an approved review gate explicitly ruled out of scope and
deferred, and that no story has delivered since.**

### Governing decision

`REQ-002 / STORY-017_home_dashboard_design_fidelity` is the only story that has
ever audited this screen against the design source. Its review report records
`Outcome: DEFERRED_ONLY` (round 3, Reviewer `Iris-QC`), and its finding `B5` was
`CLOSED by scrum-master` by fixing a **comparison region**: AC1's "no visible
deviation" is evaluated only against `R1`–`R7`, with the feature cards, the
"Seen" banner, the header actions, the tab *set*, the `--sky` backdrop and the
FAB explicitly declared out of region because each is owned by a different
file/story and changing them would violate `STORY-017`'s AC5.

### Classification of every divergence still visible

In-region (`R1`–`R7`) — all still match, no regression found:

| Region | Design | Corrected capture | Verdict |
|---|---|---|---|
| R1 presence row | two overlapping 42px gradient discs, `Cùng thành phố` | present, identical | MATCH |
| R2 days counter | `247` under the Dream Gradient + `ngày bên nhau` | present | MATCH |
| R3 milestone pill | `Còn 53 ngày nữa tới mốc 300` on `colorSurface` | present | MATCH |
| R4 hero caption | `Chịu đựng nhau được 247 ngày rồi, giỏi quá 🎀` | present | MATCH |
| R5 card rhythm | 16px column inset, uniform gaps | present | MATCH |
| R6 tab-bar styling | Material pink pill behind active icon | present | MATCH |
| R7 hero glow | 180px pink radial, top-right | present | MATCH |

The three in-region residual deltas are exactly `STORY-017` §1.2's `Δ1`
(counter size — governed by AC3 over the prototype), `Δ2` (`Minh`, not
`Minh & Linh` — deferral `F4`, blocked on a partner-profile API) and `Δ3`
(no `bedtime` glyph on the pill — deferral `F2`). None is new.

Out-of-region — the divergences that make the screen read as "completely
wrong", each already a recorded deferral and none of them a regression:

| # | Divergence | Recorded as | Owning file (never redesigned) |
|---|---|---|---|
| M6 | Anti-ghost alert card (`Seen 5 phút rồi đấy`) rendered as a plain `Anti-Ghosting` entry row | `F3` | `mobile/lib/features/anti_ghosting/presentation/widgets/anti_ghost_entry_card.dart` |
| M7 | `Vibe Check` two-tile card rendered as a single `Cảm xúc hằng ngày` row | `F6` | `mobile/lib/features/vibes/presentation/widgets/vibe_entry_card.dart` |
| M8 | Bún pet card (sprite, `Lv.3`, progress bar) rendered as a plain row | `F6` | `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart` |
| M9 | 2-column quick grid (`Synced Alarm`, `Zodiac Red Flag`, …) rendered as single-column full-width rows | `F6` | multiple feature widget files; `STORY-023 Zodiac Red Flag` is `DEFERRED` in `req_master.md:825` |
| — | Header share / notification actions absent | `F3` | routes do not exist |
| — | `--sky` three-radial screen backdrop | `F10` | `mobile/lib/design_system/theme/cupid_theme.dart` |

Git history confirms the "never delivered" claim rather than "delivered then
lost": `git log` on the three card widgets returns only `e52fb2b`
(`STORY-011/P8: pet entry point on HomeScreen`), `3466fd6` (`STORY-008`) and
`34bb6aa` (`STORY-011` merge) — all `REQ-001` feature-entry-point commits. They
were authored as generic navigation rows and were never given the dashboard
card designs. `home_screen.dart` itself was last touched by `93165e4`
(`STORY-017`) and `3d74a75` (`STORY-061`, dream-jar row only), so nothing
removed the hero block.

`M10` (5-tab bar) is a MATCH: `STORY-017`'s deferral `F7` (3 tabs vs 5) and
`F11` (stray person FAB) were both closed since, by
`REQ-003_app_shell_five_tab_navigation_and_fab_consolidation`.

### Why no patch was applied

Closing M6–M9 means building four dashboard cards (anti-ghost alert banner,
vibe two-tile card, pet card with sprite/level/progress, 2-column quick grid),
plus header actions whose routes do not exist, plus a global theme backdrop.
That is new product scope spread across `anti_ghosting/`, `vibes/`, `pet/`,
the alarm/zodiac features and `cupid_theme.dart` — far past this bug's 12-file
budget, and directly contrary to an approved review gate that declared each of
those surfaces out of scope. Patching them here would silently overturn a
Scrum-Master-ruled scope decision.

Same disposition and same precedent as
`BUG-20260824-001_pairing_code_screen_missing_design`.

Outcome: `ESCALATE_TO_BACKLOG`.

### Secondary observation (not the reported defect)

The corrected capture shows `Không thể tải Bún` where the design shows the pet
card. That is the preview harness having no authenticated backend for
`PetPreviewCard`, not a Home-screen defect — the real entrypoint never reaches
Home unauthenticated. It is called out only so a follow-up story does not
mistake it for a rendering bug.

