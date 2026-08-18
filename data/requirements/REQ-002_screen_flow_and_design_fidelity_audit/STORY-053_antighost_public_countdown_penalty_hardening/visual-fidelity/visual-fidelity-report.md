VISUAL_FIDELITY: PASS

# Visual Fidelity Report: STORY-053 Anti-Ghosting Public-Countdown Row

Story: STORY-053_antighost_public_countdown_penalty_hardening
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Rework item: RWB-20260816-018 (design finding D-05, split out of STORY-041)
Lane: mobile
Date: 2026-08-18

## Verdict Scope

`PASS` is scoped to **AC2 and AC3's claims about the new public-countdown row
only** — its position in the penalty card, its leading tile, its title and
subtitle copy in both locales, and its toggle treatment in the enabled
(State A) and disabled (State B) states — plus the AC6 RWB-20260816-019 copy
fold-in, which is visible in the same card.

It is **not** a claim that the whole `antighost` screen is now a pixel copy of
the canvas. The screen's pre-tracked deltas (D-01, D-02, D-03, F-06's
radio-vs-toggle divergence, R-1, R-3) were dispositioned by STORY-041 and are
re-confirmed below as unchanged, not re-litigated. A reviewer should read this
verdict as "the row STORY-053 added matches the design", not "no design delta
remains on this screen".

## Design Source

- Source type: `claude-design`, locked bundle `cupid-app-design-system`
  (`data/devops/system/design-fidelity-config.json`, `locked: true`,
  `ui_surface: true`).
- Canvas entry: `Cupid App.dc.html`, taken from the config's `entry` field.
  Without `--entry` the renderer fails `DESIGN_CANVAS_ENTRY_AMBIGUOUS` (16
  `.dc.html` files in the bundle).
- Screen id: **`antighost`**. Not re-derived: it is the id STORY-041 resolved
  and confirmed by eye for this exact screen one story back in this family.
  Confirmed again here by looking at the render — it is the only screen showing
  the `Ngưỡng "bơ"` threshold control together with the penalty settings card,
  and its penalty card contains precisely the row this story adds. Recorded as
  `Design-Screen: antighost` in `story_master.md` so no later run re-resolves it.
- No design file was modified.

## Evidence Pair

| Role | File | Size |
| --- | --- | --- |
| Design reference | `design-reference-antighost-android.png` | 406x900 |
| Implemented (State A, propose form — row enabled) | `implemented-antighost-emulator-5560.png` | 405x900 |
| Implemented (State B, pending-mine — row disabled) | `implemented-antighost-pending-emulator-5560.png` | 405x900 |

All three are real rendered PNG bytes in this story's own `visual-fidelity/`
directory. STORY-041's artifacts were not reopened, edited, or re-derived.

Capture conditions:

- Device: Android emulator `emulator-5560` (already running; no device was
  created, booted, wiped, or repaired).
- Width: **360dp logical** (`--width=540 --density=240`; 540 / (240/160) = 360).
  Same narrow width STORY-041 used, so the two stories' captures are directly
  comparable. The display override is temporary and reverted by the capture
  script's `EXIT` trap; launch and capture were held in one device lease via
  `capture-mobile-screen.sh --lease-exec`.
- Theme: dark. Locale: `vi`. Design reference rendered at the Android device
  viewport for the same screen id, same theme, same locale.

### Why two implemented captures

The row has two distinct visual treatments and one capture cannot show both:

- `--dart-define=PREVIEW=antighost --dart-define=PREVIEW_ANTIGHOST=state-a`
  -> `AntiGhostNoConfig` -> propose form. Row **enabled and interactive**;
  this is the AC2/AC3/AC4 surface.
- `--dart-define=PREVIEW=antighost --dart-define=PREVIEW_ANTIGHOST=state-b`
  -> `AntiGhostPendingMine`. Row **disabled/read-only**, driven by
  `config.publicCountdown` with `onChanged: null`; this is the AC2 State B
  surface.

Both defines already existed — STORY-041 added them to `main_preview.dart`.
This story added **no new preview plumbing**; its P2 diff only extended the
existing `_previewPendingGhostConfig` fixture with `publicCountdown: true`,
which is what State B renders here.

## AC2 — Row position and structure

| Claim | Design reference | Implemented (State A) | Verdict |
| --- | --- | --- | --- |
| The row is the **first** child of the penalty settings card | first row of the card, above both penalty rows | first row of the card, above the `Hình phạt` heading and all three penalty rows | MATCH |
| Leading 40x40 rounded tile, amber-tinted, distinct from the peach Emoji Storm tile | amber/gold tile, stopwatch glyph | amber tile at `colorAmber` 0.2 alpha, stopwatch glyph; Emoji Storm's tile stays peach beside it | MATCH |
| Trailing pill toggle, on by default | hot-gradient pill, white knob at the trailing edge | hot-gradient pill, white knob at the trailing edge | MATCH |
| Hairline divider separates the row from what follows | divider under the row | divider under the row | MATCH |
| Row height/vertical rhythm consistent with the penalty rows | — | row reads at the same height and gutter as the Emoji Storm row below it | MATCH |

State B (`implemented-antighost-pending-emulator-5560.png`): the row renders
with the same geometry, the toggle still reflecting the persisted `true`, the
leading tile falling back to `colorSurfaceAlt` (no amber accent), and the whole
card dimmed as read-only. That de-accenting is deliberate and mirrors the
existing `_PenaltyIconTile` rule (`isAccented = enabled && ...`) rather than
introducing a new disabled convention.

## AC3 — Copy, both locales

| Locale | Title | Subtitle | Evidence |
| --- | --- | --- | --- |
| `vi` | `Đếm ngược công khai` | `Hiện trên dashboard cả hai` | visible in both implemented PNGs; **byte-identical to the design canvas**, which renders the same two strings |
| `en` | `Public countdown` | `Shown on both dashboards` | not capturable in the same dark+vi frame; asserted by widget test `AC3 (en): the public-countdown row uses the en strings` |

The `vi` strings were checked against the render rather than only against the
ARB file, which is the point of this pass: the canvas and the app agree on the
exact wording, so the row is not merely present but reads as designed.

## AC6 — RWB-20260816-019 copy fold-in, confirmed against the design

The design canvas labels the sound penalty **`Phát âm thanh`**. Before this
story the app read `Gây ồn`. The implemented capture now reads `Phát âm thanh`
in the same card, in the same position, in the same type role as the canvas.
This is the visual confirmation that the fold-in matched the design source and
was not a free-hand copy change.

## Deltas found in the new row

None. There is no layout, spacing, sizing, colour, typography, or state
difference between the design's public-countdown row and the implemented one at
360dp dark/`vi`, in either the enabled or the disabled state.

## Pre-Tracked Deltas Confirmed Still Open (not this story's scope)

Re-confirmed present/absent in this render, all inherited and dispositioned by
STORY-041:

| Id | Delta | Status in this render |
| --- | --- | --- |
| F-06 | Penalty rows are a radio group in the app, independent toggles in the design | Still divergent. Mandated by `ux/uiux-spec.md` §2.3; unchanged by this story. |
| D-03 | Per-row penalty subtitles absent in the app | Still absent (l10n-blocked). Note: the **new** row does carry its subtitle, because this story shipped the l10n key for it. |
| `Hình phạt` heading | The app prints a section heading the design's card lacks | Still present. Required as the radio group's accessible name; dispositioned as not-fixable by STORY-041. The new row sits **above** this heading, so it is not captured by the group label — matching the design, where the countdown row is likewise not a penalty option. |
| D-01 / D-02 | Storm emoji-set card, handshake consent callout | Still absent (l10n-blocked). |
| R-3 | Disabled state does not dim gradients | Still applies, and the new switch follows it: State B keeps the pill's full gradient. Consistent with the accepted convention, not a new deviation. |
| R-1 | Light-theme contrast risk | Not exercised; this capture is dark-theme. |

## Verification Evidence

Run in this session from `mobile/` (`export PATH="$HOME/flutter/bin:$PATH"`):

```
flutter test test/features/anti_ghosting/
-> 00:01 +69: All tests passed!   (69 tests)

flutter analyze lib test
-> 80 issues found.   all severity `info`, 0 error, 0 warning,
   none in this story's write scope
```

Capture tool output:

```
DESIGN_CANVAS: OK  design-reference-antighost-android.png            406x900
MOBILE_CAPTURE: OK implemented-antighost-emulator-5560.png          405x900 169760
MOBILE_CAPTURE: OK implemented-antighost-pending-emulator-5560.png  405x900 145820
```

## Golden test (step 4) — not added

No `matchesGoldenFile` baseline was added. The phase file's §6 test scope names
targeted widget tests plus `flutter analyze` and nothing else, and the row's
visual contract is already pinned by assertions on the real decoration
(`_publicCountdownSwitchDecoration`: gradient when on, `colorLine` when off,
`colorAmber` 0.2 tile) rather than by prose. Adding a golden here would widen
this story's scope and commit new binaries; flagged for Scrum Master rather
than done unilaterally.

Result: **PASS**

No mobile e2e, emulator lifecycle work beyond the temporary display-size
override for the capture, signing, or store operation was performed.
