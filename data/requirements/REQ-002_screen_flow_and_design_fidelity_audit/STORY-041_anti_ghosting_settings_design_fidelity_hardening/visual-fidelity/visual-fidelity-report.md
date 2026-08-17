VISUAL_FIDELITY: PASS

# Visual Fidelity Report: STORY-041 Anti-Ghosting Settings

Story: STORY-041_anti_ghosting_settings_design_fidelity_hardening
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Rework item: RWB-20260816-008 (RED-PATCH for STORY-022)
Lane: mobile
Date: 2026-08-16

## Verdict Scope

`PASS` is scoped to what STORY-022 claimed to fix — layout structure,
spacing, color/token usage, typography, and deviations F-01..F-10 — plus this
story's AC3 narrow-width truncation check (R-2). It is not a claim that the
app screen is now a pixel-for-pixel copy of the canvas: D-01, D-02, D-03 and
D-05 remain deliberately unimplemented and are tracked elsewhere (enumerated
in `## Pre-Tracked Deltas Confirmed Still Open` below). The reviewer can
therefore read this verdict as "STORY-022's fidelity claims are now
visually evidenced", not as "no design delta remains".

## Design Source

- Source type: `claude-design`, locked bundle `cupid-app-design-system`
  (`data/devops/system/design-fidelity-config.json`, `locked: true`,
  `ui_surface: true`).
- Canvas entry: `Cupid App.dc.html`. The bundle carries 16 `.dc.html` files,
  so `render-design-canvas.js` fails with `DESIGN_CANVAS_ENTRY_AMBIGUOUS`
  unless `--entry="Cupid App.dc.html"` is passed — the entry is taken from
  the config above, not guessed.
- Screen id: `antighost`, confirmed present in `--list-screens` output for
  that entry and confirmed by eye against the rendered PNG (threshold
  segmented control + penalty settings card).
- No design file was modified.

## Evidence Pair

| Role | File | Size |
| --- | --- | --- |
| Design reference | `design-reference-antighost-android.png` | 406x900 |
| Implemented (State A, propose form) | `implemented-antighost-emulator-5560.png` | 405x900 |
| Implemented (State B, pending-mine) | `implemented-antighost-pending-emulator-5560.png` | 405x900 |

All three are real rendered PNG bytes in this story's own `visual-fidelity/`
directory. STORY-022's artifacts were not reopened, edited, or re-derived.

Capture conditions:

- Device: Android emulator `emulator-5560`.
- Width: **360dp logical**, obtained with a temporary display-size override
  (`--width=540 --density=240`; 540 / (240/160) = 360dp exactly). This is the
  narrow width AC3 requires so that all four threshold segments are on
  screen simultaneously. The override is temporary and scoped to the capture
  run via the capture script's device lease; no persistent emulator
  configuration was changed.
- Theme: dark. Locale: `vi`.
- Design reference rendered at the Android device viewport for the same
  screen id.

### Why two implemented captures

`AntiGhostCubit.load()` derives its lifecycle from two authenticated
`ghost-config` fetches and maps everything except a 400 to
`AntiGhostLoadFailed`. An unauthenticated preview therefore renders only the
failure state, and **none** of the AC-bearing controls (F-03 threshold
segmented control, F-06 penalty tiles, F-08 pending badge) would ever appear
in a capture. Two authored preview states were added so each AC-bearing
control has a capturable route:

- `state-a` -> `AntiGhostNoConfig` -> propose form: threshold segmented
  control (F-03) + penalty selector (F-06).
- `state-b` -> `AntiGhostPendingMine` -> waiting badge (F-08) and the
  disabled/read-only control treatment (R-3), which State A cannot show.

This mirrors STORY-040's two-capture precedent
(`implemented-chat-*` + `implemented-chat-composer-draft-*`).

## Source Changes

Exactly one source file was modified:

- `mobile/lib/main_preview.dart` — dev-only preview entrypoint. Adds
  `--dart-define=PREVIEW_ANTIGHOST=state-a|state-b`, which unregisters the
  DI-bound `GhostConfigRepository` and registers a fixture in its place, and
  (for `state-b`) seeds `BackendUserIdStore` so `_lifecycleForPending`
  resolves `AntiGhostPendingMine` instead of falling back to
  `AntiGhostPendingUnknownRole`. Omitting the define leaves today's
  live-repository behaviour untouched.

`mobile/lib/features/anti_ghosting/presentation/screens/anti_ghost_screen.dart`
was **not modified**. That is the correct outcome for a fidelity-hardening
story: the R-2 check found no truncation defect (see AC3 below), and no other
new real deviation was found, so there was nothing to fix in the production
screen. Adding the capture route was the work.

No backend, persistence, l10n, or entry-point file was touched.

## AC2 — F-01..F-10 Re-Verification Against the Render

Each item below was checked against the actual rendered pixels, not against
widget-test assertions.

| Id | STORY-022 deviation | Fix under test | Verdict in render |
| --- | --- | --- | --- |
| F-01 | Screen padding did not match the design section box | shared `_screenPadding` | CONFIRMED — card edges align to the same gutter as the canvas section box on both sides |
| F-02 | Intro hero card missing entirely | `_IntroHeroCard` | CONFIRMED — hero card present at top with matching surface + title treatment |
| F-03 | Threshold picker was a Material `ChoiceChip` row, not a segmented control | `_TimeoutSegmentedControl` / `_TimeoutSegment` | CONFIRMED — single pill track (`colorSurfaceAlt`, radius 999) with inset segments; selected segment carries the hot gradient pill. See AC3 close-up. |
| F-04 | Cards had no surface treatment | `_SettingsCard` | CONFIRMED — both settings cards render the design's elevated surface fill and radius |
| F-05 | Radius derived from the spacing scale instead of platform tokens | `platform.radiusCard` / `radiusSmall` / 999 | CONFIRMED — card corners, 40x40 icon tiles, and the segmented track each read as three distinct radii matching the canvas |
| F-06 | Penalty rows had no design chrome | `_PenaltyIconTile` + dividers + trailing control affinity | CONFIRMED — see close-up below |
| F-07 | Typography roles misapplied | `_sectionHeadingStyle` / `type.caption` | CONFIRMED — section heading, row label, and segment caption render at three distinct weights/sizes matching the canvas hierarchy |
| F-08 | Pending badge stretched full width | `Align(centerStart)` | CONFIRMED in the **State B** capture — badge hugs its content at the start edge, does not span the card |
| F-09 | Inconsistent inter-card gaps | uniform `CupidSpacing.md` | CONFIRMED — hero -> threshold card -> penalty card gaps are visually equal |
| F-10 | Ink surface regression | `Material(type: MaterialType.transparency)` | CONFIRMED (indirect) — rows render cleanly inside the card fill with no opaque ink rectangle or debug paint error; a regression here is visible as a mismatched row background, and none is present |

### F-06 close-up (named AC2 emphasis target)

Cropped and upscaled from both PNGs. The app's penalty card renders, per row:
a 40x40 rounded icon tile at `platform.radiusSmall`, the row label in the
design's label style, a hairline divider between rows, and the selection
control at the trailing edge. The `Emoji Storm` row's tile carries the
accented peach tint (`isAccented = enabled && penalty == Penalty.emojiStorm`)
against `colorSurfaceAlt` for the others — matching the canvas, where the
same row is the only tinted tile. Tile geometry, glyph size, divider
placement, and trailing-control alignment all match.

Two known, already-accepted divergences are visible in this crop and are
**not** new findings:

- The app uses a **radio group**; the design draws **toggles**. STORY-022
  documented this as a deliberate divergence because `ux/uiux-spec.md` §2.3
  requires single-select radio-group semantics (the penalties are mutually
  exclusive), which a set of independent toggles cannot express.
- The design's rows carry **descriptive subtitles**; the app's do not. That
  is D-03, deferred and l10n-blocked.

### F-03 close-up (named AC2 emphasis target)

Covered under AC3 below, since the same crop answers both.

## AC3 (R-2) — Narrow-Width Segment-Label Truncation

Result: **no truncation. R-2 resolves as no-defect; no code fix required.**

`_TimeoutSegment` renders its label with `maxLines: 1` and
`overflow: TextOverflow.ellipsis`, so a too-narrow segment would show a
visible `…`. The screen packs four segments — three presets
(`_timeoutPresets = [5, 10, 15]`) plus the app-only `Tuỳ chỉnh` — as
`Expanded` children with `CupidSpacing.sm` gaps inside a track padded by
`CupidSpacing.xs`, which is the tightest per-segment budget the layout can
produce.

At 360dp the threshold row was cropped and upscaled 3x. All four labels —
`5 phút`, `10 phút`, `15 phút`, `Tuỳ chỉnh` — render **complete, with no
ellipsis and no clipped glyph**, including the diacritics on `phút` and
`Tuỳ chỉnh`. `5 phút` is the selected segment and renders inside the hot
gradient pill without its label being pushed or clipped by the pill inset.

Verified a second time, independently, in the State B capture (where the
control is disabled and the selection sits on `10 phút` instead) — also no
truncation.

360dp is at or below the narrow end of the supported Android range, so
segments that fit here fit on wider devices; no additional width was
captured.

## AC4 — D-05 Not Touched

D-05 is the missing "Đếm ngược công khai" (public countdown) penalty row.
It is visible in the design reference crop as the **first** row of the
penalty card, and it is confirmed **still absent** from the app render. This
is intentional and correct for this story: D-05 needs a new persisted
setting, a backend field, and new l10n keys, and is tracked separately as
`RWB-20260816-018`.

No file related to D-05 was modified. `data/retro-audit/rework-backlog.md`
was not edited by this story (Scrum Master owns it).

## AC5 — New Deviations Found

No new fixable deviation was found. One new observation is recorded for the
reviewer's judgment:

**O-1 — app adds a "Hình phạt" section heading that the design's penalty
card lacks.** Assessed as **not a fixable deviation**, for the same reason
F-06's radio-vs-toggle divergence was accepted: `ux/uiux-spec.md` §2.3
mandates radio-group semantics, and an accessible radio group requires a
group label. Removing the heading would strip the group's accessible name.
The design's card can omit a heading because its rows are independent
toggles that each carry their own descriptive subtitle (D-03) — and those
subtitles are deferred, so the heading is currently the only thing naming
the group. Flagged explicitly so the reviewer can check this judgment rather
than have it buried.

## AC7 — Entry Point Unchanged

Confirmed by source, not inference.
`mobile/lib/features/anti_ghosting/presentation/widgets/anti_ghost_entry_card.dart`
lines 140-142 still push `AntiGhostScreen` via a full-screen
`MaterialPageRoute` from the existing entry card. No new route, tab, or
navigation affordance was added. The dev-only `PREVIEW_ANTIGHOST` define
lives in `main_preview.dart` and is not reachable from the shipped app.

## Chrome Notes (expected, not deviations)

- **No bottom tab bar in the app capture.** Correct: the entry card pushes
  `AntiGhostScreen` as a full-screen route *above* the shell, so the real
  runtime shows no tab bar here either. Same class as the existing
  `ghostset` preview-registry note.
- **App-only propose CTA "Đề xuất cho đối phương".** Required by UX spec
  §2.3 State A's propose/approve handshake, which the design canvas does not
  model at all.
- **Hero title wraps to 2 lines at 360dp** (1 line at 412dp). A function of
  the deliberately narrow AC3 capture width, not a fidelity defect.
- **Selected segment is `5 phút` in the app vs `10 phút` in the design.**
  State A defaults to `_timeoutPresets.first`; the canvas simply draws a
  sample selection. Not a deviation.

## Pre-Tracked Deltas Confirmed Still Open

Confirmed absent in the render, all pre-existing and out of scope here:

| Id | Delta | Status |
| --- | --- | --- |
| D-01 | Storm emoji-set card | deferred (l10n-blocked) |
| D-02 | Handshake consent callout | deferred (l10n-blocked) |
| D-03 | Per-row penalty subtitles | deferred (l10n-blocked) |
| D-05 | Public-countdown penalty row | split out as RWB-20260816-018 |
| R-1 | Light-theme contrast risk | note only, OQ5-blocked; this capture is dark-theme so R-1 is not exercised |
| R-3 | Disabled-state visual choice | CONFIRMED in State B — the disabled control does not dim the selected segment's gradient. Note only, no action, as dispositioned. |

## Verification Evidence

Targeted mobile checks only, run in this session
(`export PATH="$HOME/flutter/bin:$PATH"`; binary at
`/Users/alantravala/flutter/bin/flutter`):

```
flutter test test/features/anti_ghosting
-> All tests passed!  (63 tests)

flutter analyze lib/main_preview.dart
-> No issues found!
```

Result: **PASS**

Note on scoping: whole-package `flutter analyze` exits 1, but every `error`
is inside `build/ios/SourcePackages/checkouts/flutterfire/packages/cloud_firestore/…`
— vendored third-party sources under generated build output, unrelated to
this change and pre-existing. `flutter analyze lib test` reports 80 issues,
all `info` level and all pre-existing patterns in files this story never
touched. Analyzing the single modified file reports zero issues, which is
the conclusive signal that this change adds no analyzer debt.

No mobile e2e, emulator lifecycle work beyond the temporary display-size
override for the capture, signing, or store operation was performed.
