# Visual Fidelity Report: STORY-049 Contract Unsigned-State Render Coverage

VISUAL_FIDELITY: PASS
Design-Screen: contract

## Scope Of This Report

This story closes a **render-coverage gap**, not a defect. RWB-20260816-014
recorded that STORY-039 re-confirmed D-7 and D-8 (the add-clause row) by widget
test and widget-tree structure only, because no preview fixture could paint that
row *in the unsigned state the design's `myUnsigned` branch shows*:
`_contractFixtureFor()` in `mobile/lib/main_preview.dart` exposed only
`partnerAlreadySigned` (never paints the row — ADR-019e hides it from the
`partner` viewer) and `bothSigned` (paints it, but signed). STORY-049 adds the
missing `requesterUnsigned` fixture and files the first rendered
design-vs-implementation comparison of that row.

AC-2 (D-10/D-13) is a documented disposition, not a comparison — see
"AC-2: D-10/D-13 Disposition" below.

## Evidence Pair

| Side | File | Size | Provenance |
|------|------|------|-----------|
| Design reference | `design-reference-contract-myunsigned-android.png` | 406x900 | Reused **byte-for-byte** from STORY-039 (`shasum -a 256` = `2acd1045727564cf7ff167fd36e13f3a418c65509be7debc35060ba6498514b3` on both copies). This is the design canvas's `myUnsigned` branch, the exact branch D-7/D-8 live in. Reuse is now independently confirmed: re-rendering the screen with `render-design-canvas.js` (`--screen=contract --platform=android --theme=dark --lang=vi`) reproduces this exact hash, so the reused file is bit-for-bit what the sanctioned renderer emits today. |
| Implementation | `implemented-contract-requesterunsigned-emulator-5560.png` | 405x900 | Captured 2026-08-18 from `emulator-5560` against the working tree **with this story's `requesterUnsigned` fixture in place**. |
| D-10 probe | `design-reference-contract-mysigned-attempt-android.png` | 406x900 | Output of the `mySigned`-forcing attempt described under AC-2. Byte-identical to the `myUnsigned` reference — that identity *is* the evidence. |

Same conditions as STORY-039's approved pair: dark theme, `vi` locale, Android
412x915dp design frame vs `emulator-5560` at 1080x2400 @420dpi = 411x914dp
logical, `font_scale` 1.0. Both sides are downscaled to 900 px tall, so image
pixels are directly comparable between the files.

The reference carries a device bezel inside its canvas, so its card is narrower
(357 image px) than the capture's (373 image px). Horizontal geometry is
therefore compared as **insets relative to the card**, never as absolute
positions — the same rule STORY-039 established for this screen.

## How The Implementation Capture Was Produced

`capture-mobile-screen.sh` **does** exist, at
`.ai-team-bundle/runtime/tools/capture-mobile-screen.sh`. It is untracked
because that tree is projected by `install.sh` and never committed, so
`git log --all` reports nothing for it — which proves "not version-controlled",
not "absent". It was not used for this capture; the steps below reproduce the
equivalent pipeline directly against the repo's own preview harness, and are the
literal commands that produced the stored PNG:

1. `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=contract --dart-define=PREVIEW_CONTRACT_SIGN_STATUS=requesterUnsigned`
   — **required**, since `PREVIEW_CONTRACT_SIGN_STATUS` is a compile-time
   `String.fromEnvironment`; it cannot be switched by deep link.
2. `adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk`
3. `adb -s emulator-5560 shell settings put system font_scale 1.0`
4. `adb -s emulator-5560 shell am force-stop com.snapsofts.cupid`, then
   `am start -a android.intent.action.MAIN -c android.intent.category.LAUNCHER -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
5. `adb -s emulator-5560 shell 'sleep 12; screencap -p ...'`
6. Downscaled 1080x2400 -> 405x900 (exactly 0.375) with `sips`, matching
   STORY-039's stored dimensions.

Note for the next capture on this harness: STORY-048's cold-start deep-link trap
does **not** apply here. Because the screen id is baked in at build time via
`--dart-define=PREVIEW=contract`, a cold launcher start lands on the contract
screen directly and no deep link is needed. This capture is from the first
attempt.

## Measured Comparison (image px)

Probed programmatically with a stdlib `zlib`/`struct` PNG reader (accent-pink
band detection for the add-clause label, luminance-step detection for the card
edges, full-width period detection for the dashed hairlines). Not eyeballed.

| Measurement | Design `myUnsigned` | Implementation `requesterUnsigned` | Delta |
|---|---|---|---|
| Card left/right at the add-clause band | 25..381 (357 wide) | 16..388 (373 wide) | framing only, see above |
| Add-clause `+` glyph left inset from card left | 19 | 20 | **1** |
| Add-clause label band height | 12 | 13 | **1** |
| Add-clause label bottom -> dashed rule below | 22 | 22 | **0** |
| Clause row pitch | 47 | 48 | **1** |

### D-7 — one `+` glyph, pink, w600 — PASS

The rendered add-clause row is `+ Thêm điều khoản riêng`: a single leading plus
followed by the label, in accent pink at semibold weight, left-aligned. The
design's `myUnsigned` branch paints the same single-plus construction
(`+ Thêm điều khoản của riêng tụi mình`). The duplicated-glyph defect STORY-015
fixed is **absent in the render**, which is the confirmation D-7 previously
lacked — until this story it was asserted only by the widget test `Exactly one
plus on the add-clause affordance (D-7)` in
`mobile/test/features/love_contracts/presentation/screens/love_contract_screen_fidelity_test.dart`.

### D-8 — add-clause row is the last child of the clause list block — PASS

Both sides place the add-clause row inside the card, immediately below the last
clause row, above the dashed hairline that opens the sign section. The
block-membership measurement is exact: the gap from the label's bottom to that
dashed rule is **22 px on both sides**, and the left inset matches within 1 px.
The design's `padding:8px 8px 4px` clause block and the implementation's
`fromLTRB(sm, sm, sm, xs)` therefore produce the same rendered relationship.
STORY-039's structure-only re-confirmation is now superseded by this render.

## Newly Visible, Outside D-7/D-8 Scope

Adding render coverage necessarily makes other differences visible for the first
time. Neither is a D-7/D-8 result; both are recorded here for Scrum Master and
Reviewer rather than silently dropped.

- **Add-clause label copy.** Design: `Thêm điều khoản của riêng tụi mình`.
  Implementation: `Thêm điều khoản riêng`. This is the shipped `vi` ARB string,
  quoted verbatim in STORY-015's own D-7 write-up and accepted there — D-7's
  defect was the duplicated glyph, not the wording. This is a copy/localization
  difference, not a layout or token deviation, and no D-item covers it.
- **Clause counter row.** The implementation renders `2/20 điều khoản` between
  the header rule and the first clause row; the design has no counter. Already
  dispositioned as A-1 in STORY-015 ("shipped REQ-001 affordance ... removing it
  would be a functional change") and present in STORY-039's approved capture.
  Unchanged here.

Fixture-state differences that are not fidelity: the design reference selects 3
of 4 preset clauses and this fixture selects 2, and the preview harness supplies
no `myDisplayName`, so the subtitle falls back to its neutral form. Both were
equally true of STORY-039's approved pair.

## AC-2: D-10/D-13 Disposition — Document And Close

D-10 (signed card) and D-13 (sign-action error banner) are closed by
disposition. For D-10 that disposition is now backed by the sanctioned
renderer's own recorded output, not by an assertion.

### Correction to the earlier claim

A previous revision of this report, and of `story_master.md`'s AC-2 text, stated
that `capture-mobile-screen.sh` and `render-design-canvas.js` "do not exist in
this repository's working tree or Git history". **That was wrong.** Both exist
right now:

- `.ai-team-bundle/runtime/tools/render-design-canvas.js` (20011 bytes)
- `.ai-team-bundle/runtime/tools/capture-mobile-screen.sh` (23087 bytes)

They are untracked because `.ai-team-bundle/runtime/` is projected by
`install.sh` and never committed, so `git log --all -- "*<name>"` returns empty
for both. An empty `git log` proves a path is **not version-controlled**; it
never proves the path is absent from disk. The claim originated in STORY-048 and
was repeated here without a filesystem check. `data/devops/system/design-fidelity-config.json`
names `render-design-canvas.js` as the sanctioned renderer for this repository.

### D-10 — the `mySigned` branch was actually attempted

`Design-Screen: contract`, resolved from the tool itself:

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=cupid-app-design-system --entry="Cupid App.dc.html" --list-screens
```

returned 38 screen ids, of which `contract` is this screen.

The contract screen's sign section is a two-way `sc-if` in
`cupid-app-design-system/project/Cupid Screens.dc.html`:

- line 154: `<sc-if value="{{ mySigned }}">` — **no** `hint-placeholder-val`
- line 160: `<sc-if value="{{ myUnsigned }}" hint-placeholder-val="{{ true }}">`

Only a branch carrying `hint-placeholder-val="{{ true }}"` is painted by the
static prototype, so `mySigned` is structurally unpainted. The `myUnsigned`
branch's only interactive affordance is the hold-to-sign control at line 161,
bound to `onMouseDown="{{ startHold }}" onMouseUp="{{ endHold }}"` — design-time
placeholder bindings with no runtime behaviour behind them.

Two forcing attempts were run through the renderer's `--click` flag, at two
different depths, to rule out a mis-targeted selector:

| # | `--click` selector | Tool output | Exit | Output SHA-256 |
|---|---|---|---|---|
| 0 | *(none — baseline)* | `DESIGN_CANVAS: OK ... 406x900` | 0 | `2acd1045…14b3` |
| 1 | `span[data-vi]:text-is("Giữ để ký")` | `matched 2 element(s)`, `DESIGN_CANVAS: OK ... 406x900` | 0 | `2acd1045…14b3` |
| 2 | `div:has(> div > span[data-vi]:text-is("Giữ để ký"))` (the handler div itself) | `matched 2 element(s)`, `DESIGN_CANVAS: OK ... 406x900` | 0 | `2acd1045…14b3` |

A third attempt with a deliberately wrong selector (`div[style*="Giữ"]`) returned
`DESIGN_CANVAS_CLICK_TARGET_MISSING` and exit 1 with no PNG written, confirming
the tool does report a failed click rather than silently ignoring it — so the
exit-0 results above really did click a resolved element.

**All three successful renders are byte-identical to the unclicked baseline and
to the stored `myUnsigned` reference** (`2acd1045727564cf7ff167fd36e13f3a418c65509be7debc35060ba6498514b3`).
Clicking the sign control changes not one pixel. The stored probe output is
`design-reference-contract-mysigned-attempt-android.png`, produced by attempt 2
written directly into this directory.

**D-10 conclusion:** the `mySigned` branch is unreachable from the design source
as shipped — not merely un-rendered for want of a tool. There is no signed-state
reference image obtainable, therefore no rendered comparison is possible. This
is an evidence-based closure grounded in the renderer's own output.

### D-13 — unchanged, independent grounds

D-13 has no design-side counterpart in any branch: STORY-015 recorded the
sign-action error banner under A-3 as an app-only element the design source does
not model. Its closure never depended on tool availability and is unaffected by
the correction above.

**Closure:** STORY-039's existing widget-test / widget-tree structure-level
verification stands as sufficient for D-10 and D-13. This story's DONE gate must
not require a rendered comparison for these two items. Building new
design-canvas tooling remains out of scope under AC-3 — and is moot, since the
sanctioned renderer already exists and was exercised.

## AC-3: Scope Boundary Held

No design-side render tool was built or reconstructed. The `mySigned` probe
under AC-2 invoked the **already-installed** `render-design-canvas.js`
read-only, with `--out` pointing at this story's own evidence directory; no
design source, token, or tool file was written. No shipped app code was
touched: the only source change is the additive `requesterUnsigned` case in
`mobile/lib/main_preview.dart`, a preview-only harness.
`love_contract_screen.dart`, `love_contract_repository.dart`,
`clause_toggle_row.dart`, and `hold_to_sign_button.dart` are unmodified.
STORY-015's and STORY-039's `visual-fidelity/` directories were read but not
written.

## Verification State At Capture Time

- `flutter test --no-pub` (full suite): 1285 passed, 2 skipped, 0 failures.
- `flutter analyze --no-pub lib test`: 80 issues, all `info`, all pre-existing;
  zero errors, zero warnings.
- `flutter build apk --debug -t lib/main_preview.dart` with both dart-defines:
  succeeded.
- Flutter 3.44.1 stable / Dart 3.12.1.

Re-verified after the 2026-08-18 B-1/B-2 rework (which changed one doc comment
and this report; no fixture, capture, or measurement changed): `flutter analyze
--no-pub lib test` → 80 issues, all `info`; `flutter test --no-pub` → `+1285 ~2:
All other tests passed!`, exit 0. Identical to the pre-rework run.
