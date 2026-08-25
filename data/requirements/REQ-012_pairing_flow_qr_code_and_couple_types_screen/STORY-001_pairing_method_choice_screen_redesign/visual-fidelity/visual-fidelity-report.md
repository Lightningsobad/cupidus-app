VISUAL_FIDELITY: PASS

# STORY-001 Visual Fidelity — `pairstart` (pairing-method choice)

- Role: `mobile-dev` (rework for review finding F1/F2)
- Date: 2026-08-26
- Worktree HEAD at capture: `327be663a0cffb277da8e681c45ee334c741791d`
- Design source: `cupid-app-design-system`, entry `Cupid App.dc.html`
  (`data/devops/system/design-fidelity-config.json`, `id: cupid-app`,
  `surface: mobile`, `locked: true`)
- **Design-Screen: `pairstart`**
- Device: `emulator-5554` (`sdk_gphone64_arm64`), Android, already running —
  no device was created, booted, wiped, or repaired.
- Theme / locale compared: **dark + `vi`**, the only combination AC4 names.
  `main_preview.dart` pins both (`locale: const Locale('vi')`, dark
  brightness default) and disables text scaling, so neither is host-dependent.

## Artifacts

| File | Size | Origin |
|---|---|---|
| `design-reference-pairstart-android.png` | 406x900 | `render-design-canvas.js --screen=pairstart --platform=android --theme=dark --lang=vi` |
| `implemented-pairstart-emulator-5554.png` | 405x900, 160352 bytes | `capture-mobile-screen.sh --label=pairstart` over `flutter run -t lib/main_preview.dart --dart-define=PREVIEW=pairstart`, launch and capture inside one `--lease-exec` device-lease window |

The implemented capture is a settled frame, not a splash frame: it is 160 KB
and shows the full three-row screen with Vietnamese copy.

## How `Design-Screen: pairstart` was resolved (review finding F2)

The story reached this lane with `Design-Screen: TBD`. Resolved by the
enumerate → shortlist → confirm procedure, not by guessing:

- **Enumerate.** `render-design-canvas.js --list-screens` reports 37 ids. There
  is **no `pairingchoice` id** in the canvas; the nearest pairing-flow ids are
  `pairstart`, `invite`, `joincode`, `paired`.
- **Shortlist.** `pairstart` sits between `contract` and `invite` in the
  onboarding order and is the only id denoting the pairing entry choice;
  `invite`/`joincode` are this screen's two push destinations, not the screen
  itself. `ux/ux-spec.md:3` independently names the design block `isPairStart`.
- **Confirm by looking.** The rendered `pairstart` frame shows the header
  badge, `Ghép đôi kiểu nào?`, the subtitle, and exactly the three option rows
  with the AC1 copy (`Tôi tạo mã mời` / `Người ấy đã có mã` /
  `Quét QR trên máy họ`) plus the privacy note — i.e. the screen this story
  builds. Confirmed, not assumed.

Consequence for the harness: `main_preview.dart` keyed this screen
`'pairingchoice'`, an id the canvas does not expose, so its captures could
never filename-match a renderable reference (the gate requires one shared
`<screen>` token in both filenames). The key is now `'pairstart'` and its
`seedNote` points at `design-reference-pairstart-android.png`. That is the only
production-tree edit in this rework; it is dev-only preview scaffolding.

## Measurement basis (read this before comparing the two PNGs by eye)

The two images are **not at the same pixel scale**, because the canvas render
draws a device bezel inside its 406x900 frame while the device capture is the
raw screen:

| | image px | logical px (dp/CSS) | scale |
|---|---|---|---|
| design reference, screen area | x 9..397 → 389 wide | 412 | 0.944 |
| implemented capture | x 0..404 → 405 wide | 411.4 | 0.985 |

So the design render shows the same content ~4% smaller. Every comparison below
is therefore stated in **logical px**, converted through those scales, not in
raw image px.

## Per-element comparison

| Element | Design (logical) | Implemented (logical) | Verdict |
|---|---|---|---|
| Screen padding | 20 left/right (`ux-spec.md:90`) | card left edge at 19 image px / 0.985 = 19.7 | MATCH |
| Option-row card width | 372 (412 − 2×20); measured 351 image px / 0.944 = 372.0 | measured 366 image px / 0.985 = 371.6 | MATCH |
| Text-column offset inside row (border 1.5 + pad 18 + tile 50 + gap 14 = 83.5) | measured 82 image px / 0.944 = 86.9 | measured 82 image px / 0.985 = 83.2 | MATCH — the implementation is the closer of the two to the spec'd 83.5 |
| Row-3 title cap-height (`Quét QR trên máy họ`, 16px/w800) | 15 image px | 15 image px | MATCH |
| Row-3 title run width | 145 image px → 153.6 | 150 image px → 152.3 | MATCH (0.8%) |
| Hero badge | 92 box, radius 34, `join_left` 42, 140° pink→purple gradient | same, measured equal width to the reference | MATCH |
| Title / subtitle | `Ghép đôi kiểu nào?` 25px w900; subtitle 13px, max-width 290, wraps after `nhập` | identical copy, identical wrap point | MATCH |
| Row 1 treatment | pink 1.5px border + glow, `grad-hot` tile, white `qr_code_2`, **pink** chevron | identical | MATCH |
| Row 2 treatment | neutral border, purple-tint tile, `dialpad`, neutral chevron | identical | MATCH |
| Row 3 treatment | neutral border, mint-tint tile, `qr_code_scanner`, neutral chevron | identical | MATCH |
| Row order | create → enter code → scan QR | identical | MATCH |
| Privacy note | 13/15 padding, r16, 5% surface, mint `lock` soft 17px, 11.5px copy | identical | MATCH |
| Spacing rhythm | 18 badge→title, 8 →subtitle, 26 →row1, 12 between rows, 22 →note | identical constants, `pairing_choice_screen.dart:17-56` | MATCH |
| **"Để sau, xem trước app đã" escape link** | present, 13px w700, centered, 16 below the note | **absent** | DELTA D-1 (not a defect — see below) |
| Canvas chrome header (back arrow + `Ghép đôi`) | present | absent | DELTA D-2 (not a defect — see below) |
| Row-3 supporting copy | wraps to 2 lines | 1 line | DELTA D-3 (not a defect — see below) |

## Deltas

### D-1 — the "later, look around first" escape link (not a defect)

The design source places a centered `Để sau, xem trước app đã` link 16px below
the privacy note. The rendered reference shows it; the implementation renders
nothing below the privacy note. **That difference is now expected**, because the
element is an approved, explicit scope exclusion:

- `story_master.md` "## Scope Decisions" D-1 records the Product Owner
  **decision: DROP** — the escape link is removed from this story's design
  scope. AC1-AC4 do not reference it and none of the three in-scope option rows
  depend on it.
- `ux/ux-spec.md` §6 is correspondingly marked **OUT OF SCOPE, do not
  implement**; its measurements remain in the spec as reference only, not as a
  preserve-exactly element.
- The reasoning behind the exclusion is unchanged from what this report and
  `review/review-report.md` D1 already established: the link's `goHome` target
  has no reachable destination for an unpaired user
  (`pair_gate_shell.dart:144` renders `AppShell` only for `PairGatePaired()`),
  the link never existed at `BaseHead` so nothing regressed, and wiring it would
  require a pair-gate-bypass capability outside REQ-012. No follow-up story was
  opened.

So the design reference showing the link while the build omits it is a scoped,
adjudicated deviation — the same posture as D-2 and D-3 — and it does not hold
the fidelity token below `PASS`. The locked design canvas is not edited, and no
mobile rework was implied or performed.

### D-2 — canvas chrome header (not a defect)

The canvas frame paints a back arrow and a `Ghép đôi` title bar above the
screen. `ux/ux-spec.md` §2 begins the screen structure at the header badge and
defines no app bar, and the story's `NO_CHROME`/`NO_TABS` contract is pinned by
`chain_chrome_guard_test.dart` (`pairingChoice renders no header and no tab
bar`, PASS) and by the screen suite's own `carries no header or tab chrome
(AC4 NO_CHROME/NO_TABS)` case. The chrome is prototype navigation, like the
canvas' screen-index FAB that `hide_selectors` already strips. Its absence is
the specified behaviour.

All content therefore sits ~80 image px higher in the implemented capture than
in the reference. That vertical offset is entirely a consequence of D-2; the
inter-element spacing rhythm itself matches (table above).

### D-3 — row-3 supporting copy wraps differently (not a defect)

`Nhanh nhất khi hai người ngồi cạnh nhau` breaks after `cạnh` in the reference
and fits on one line in the build. Measured: the string occupies 232 logical px
against ~249 logical px of available text column (372 card − 3 border − 36
padding − 50 tile − 14 gap − 20 chevron), so one line is the correct result for
the spec'd geometry. Font size and text-column origin match (table above); the
canvas' own flex row reserves more trailing space and breaks earlier. No token,
size, or spacing value differs. The privacy note differs the same way and for
the same reason.

## Golden test

Not added. `visual-fidelity.md` step 4 pins a comparison **after** it passes.
D-1 is now resolved — an approved scope exclusion, no longer an open design
question — so nothing unsettled remains to freeze into a baseline. Pinning the
golden itself was not performed in this documentation-only update; no new render
or capture was taken.

## Blockers

None of the typed `MOBILE_VISUAL_AUDIT_*` codes applies: the device was
available, the screen was reachable from the preview entrypoint with authored
state, the canvas holds the screen, and both images were produced and read.
