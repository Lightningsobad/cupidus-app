# Review Report: STORY-043 Hardening — Shared Expenses Visual Fidelity Evidence

Outcome: DEFERRED_ONLY

Reviewer: Iris-QC
Mode: compact-story-review
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-043_shared_expenses_design_fidelity_hardening
Fixes: STORY-028_shared_expenses_design_fidelity (RWB-20260816-011)
Round: 2
BaseHead: 524bf4524eec80e387d35e6cf0bbfb0d675297b2
Branch: main (Worktree: repository root)

## Scope Gate

- Review type: `compact-story-review`, mobile lane, trivial retro-hardening
  (RED-PATCH) evidence story. Per skill rule 12e3 the reviewer verifies that the
  mobile capture/compare happened and was real by reading the images; the
  reviewer does not re-capture.
- Round 2 is a narrow re-review of round-1 action items 1-4 only.
  Files in scope this round:
  - `visual-fidelity/implemented-expense-ios-emulator-5560.png` (replaced)
  - `visual-fidelity/implemented-expense-ios-cta-emulator-5560.png` (replaced)
  - `visual-fidelity/visual-fidelity-report.md`, amended rows only: Evidence
    provenance note, F6, F7, AC3-iOS, M-1 platform-split note
- Source files in scope (unchanged since round 1, re-confirmed by
  `git diff --stat <BaseHead> -- mobile/`: same 2 files, `141 insertions,
  12 deletions`, byte-identical to round 1):
  - `mobile/lib/features/expenses/presentation/widgets/expense_list_item.dart`
  - `mobile/lib/main_preview.dart` (dev-only preview harness)
- Touched risk surfaces: mobile UI rendering (list-row string formatting),
  mobile navigation/discoverability (assert-unchanged), dev-only preview
  harness/fixture. No persistence, contract, migration, auth, or runtime config
  surface touched.
- Critical gates: static analysis, full test suite, rendered design-fidelity
  comparison (12e2/12e3), entry-point reachability (12e1).
- Query keys: F6, F7, AC3-iOS, M-1, N-1, N-2, provenance, `maxLines`,
  `TextOverflow`.

## Acceptance criteria verdicts

| AC | Verdict | Basis |
|----|---------|-------|
| AC1 | MET | Round 1 |
| AC2 | MET | Round 1 |
| AC3 | **MET (was FAIL)** | Both iOS captures replaced from the post-fix build; iOS platform split re-verified — see below |
| AC4 | MET | Round 1, plus a sharpened M-1 note this round |
| AC5 | MET | Round 1 |
| AC6 | MET | Round 1 (deferred D-b for placement) |
| AC7 | MET | Round 1, verified in source |

## Round-1 blocking findings — both resolved

**B-1 (stale iOS evidence) — RESOLVED.** Both iOS captures were re-taken from
the post-fix build and read directly off the replaced PNGs:

| Capture | Status-bar time | Row dates | Row amounts |
|---|---|---|---|
| `implemented-expense-ios-emulator-5560.png` | 10:05 | `17/08`, `16/08`, `15/08`, `14/08`, `13/08` | `480.000₫`, `96.000₫`, `215.000₫` |
| `implemented-expense-ios-cta-emulator-5560.png` | 10:06 | `07/08`, `06/08`, `02/08`, `28/07`, `15/07`, `01/07` | `185.000₫`, `1.500.000₫`, `1.200.000₫` |

Zero-padded dates and the attached unit are present throughout, so both now
depict the delivered build and agree with the Android trio on every shared
formatting decision. Platform identity re-confirmed independently rather than
from the filename: neither iOS capture contains a FAB anywhere, and the CTA
capture ends with the full-width gradient "Ghi một khoản" button in the content
flow — the AC3 iOS silhouette, not a relabelled Material shot. Against
`design-reference-expense-ios.png` the two rows that previously contradicted the
`VISUAL_FIDELITY: PASS` now match.

**B-2 (F6 cited the wrong image) — RESOLVED, and resolved honestly.** F6 no
longer claims the app ellipsises the long title. It now records the structure
and type as rendered-MATCH on both silhouettes, and downgrades the single-line
clamp to explicitly source-verified only, noting that no fixture title is long
enough to trigger it and that the design reference's own ellipsis comes from a
narrower canvas column and is therefore not evidence about the app either way.
That matches what the images show — "Quà cho Bún (đồ ăn mèo thật)" renders in
full on the new iOS capture. The underlying clamp was verified in source
directly: `expense_list_item.dart:148-149` carries `maxLines: 1` and
`overflow: TextOverflow.ellipsis`. Carried forward as D-f rather than left as a
silent MATCH.

**Action items 2 and 4 — done.** F7 and the AC3-iOS row are re-stated against
the round-2 captures and both are accurate. The Evidence table now carries a
provenance note that names the round-1 defect plainly, requires any future
re-capture to replace the whole `implemented-*` set from one build, and gives a
reader a concrete cross-check (Android trio and iOS pair must agree on shared
rows' date and currency formatting).

**Unasked-for improvement, verified and worth keeping.** The new M-1 note uses
the round-2 iOS capture to isolate the overlap: the same row
("Nồi chiên không đầu") at the same scroll extent renders its full `1.200.000₫`
on iOS, where the Material capture clips it to `1.200`. Confirmed in both
images. M-1 is Material-only, not a shared layout fault — that materially
sharpens the D-1 routing.

## Gates

No Dart file changed this round, so round-1's independently re-run gates still
hold and were not re-run (skill rule 18):

| Gate | Command | Independently reproduced in round 1 |
|------|---------|--------------------------------------|
| Analyze | `flutter analyze lib test` | 80 issues, all `info`, 0 error / 0 warning; none in `expense*` or `main_preview.dart` |
| Test | `flutter test` | `All tests passed!` `+1270 ~2`, exit 0 |

Entry point (12e1) verified in source in round 1: `home_screen.dart:200` mounts
`_ExpensesEntryCard`, whose `onTap` at `:204` pushes `const ExpensesEntryPoint()`
(`expenses_route.dart:28`) onto the root navigator — a discoverable card on
Home, not URL-only. No route, shell, or tab wiring in the diff.

## Deferred findings

- **D-a — N-1/N-2 landed without a regression lock.** No test asserts the
  `dd/MM` date format or the attached-unit amount string; `_dateLabel` has no
  coverage, which is why the full suite passed unchanged across both formats.
  STORY-042's precedent locked its render-discovered fix with a widget test.
- **D-b — M-3 correction authored, not placed.** The inaccurate "as in the mock"
  justification still exists at STORY-028's
  `visual-fidelity/visual-fidelity-report.md` line 109. The implementer
  correctly declined to edit a closed story's approved artifact and recorded the
  replacement wording. Scrum Master owns placement.
- **D-c — sharpened D-1/D-2/M-1 descriptions must reach the split-out
  design-system rework item.** D-1 gains a shape delta STORY-028 never recorded
  (`radiusButton` resolves to a circle on a square FAB, not the design's 20px
  rounded square); D-2's STORY-028 description is stale and overstates the gap
  (the shipped iOS CTA already draws `gradientHot`, `glowShadow`, pill radius
  and a `w800` label); M-1 is now observed and Material-only. If these do not
  travel, the design-system story will be scoped against an obsolete baseline.
- **D-d — residuals 1-9** (chip tap-target height 48 vs 33, chart
  normalization, weekday labels, caption/delta/attribution copy, item-count
  caption, absent "Xem tất cả" footer, per-category glyph artwork). All are
  pre-existing decisions upheld by STORY-028's approved review or inherent
  mock-versus-live data differences, now quantified against a render for the
  first time. Not made worse by this story.
- **D-e — design-reference below-fold limitation.** `render-design-canvas.js`
  exposes no scroll flag, so the design side of the iOS CTA and the "Xem tất cả"
  footer was verified against markup rather than pixels. Honestly disclosed,
  same limitation STORY-042 recorded, already its own tooling rework item.
- **D-f — single-line ellipsis clamp is render-unverified.** Present in source
  but never exercised, because no fixture title overflows. If a future capture
  wants it proven, one long title in the preview fixture would do it.

## Conclusion

All seven acceptance criteria are met. RWB-20260816-011 is closed on its own
terms: STORY-028's 32 enumerated items are now confirmed against a real
dual-platform render instead of source-to-source, D-1/D-2/M-1 keep their
shared-component deferral with sharper and in two cases corrected descriptions,
M-2/M-3/M-4 each carry an explicit disposition, and the two deviations only a
render could surface (N-1 date padding, N-2 amount unit) were fixed in app code
rather than re-documented.

The round-1 defect was the evidence set itself, and the round-2 fix addresses
the class rather than the instance — the provenance note makes a pre-/post-fix
capture mix detectable by any future reader instead of relying on someone
noticing the status-bar clock again. Six deferred items carry forward; none
blocks closure.

## State recommendation

- Keep `Implementation (Development)` checked; check `Review (Reviewer)`.
- Story status: `DONE`.
- Route D-b (M-3 placement) and D-c (sharpened D-1/D-2/M-1 descriptions to the
  design-system rework item) before REQ-002 integration review.
