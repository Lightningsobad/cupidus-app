# Visual Fidelity Report: STORY-056 Contract Evidence State Realignment

VISUAL_FIDELITY: PASS
Design-Screen: contract

## What This Report Establishes

STORY-046's `contract` evidence pair compared two **different** app states: its
implemented capture depicted `partnerAlreadySigned` (English fixture clause
text, a `2/20 điều khoản` counter, a "Minh Anh đã ký, đến lượt bạn" signature
line) while its design reference depicted the canvas's unsigned/pre-signature
branch. Its AC3 content-column `MATCH` verdict for `contract` therefore rested
on structural correspondence only.

This report replaces that with a genuine **same-state** comparison: both sides
below are in the unsigned/pre-signature state, and neither carries a signature
line. **It supersedes STORY-046's AC3 content-column verdict for the `contract`
screen**, and it closes the contract evidence-state finding tracked as item 023
(RWB-20260816-023).

STORY-015, STORY-039, STORY-046, and STORY-049 are not reopened. Their own
recorded verdicts and `DONE` status are unchanged; their evidence directories
were read only, never written.

## Evidence Pair

| Side | File | Size | `shasum -a 256` |
|------|------|------|-----------------|
| Design reference | `design-reference-contract-myunsigned-android.png` | 406x900 | `2acd1045727564cf7ff167fd36e13f3a418c65509be7debc35060ba6498514b3` |
| Implementation | `implemented-contract-requesterunsigned-emulator-5560.png` | 405x900 | `7184d365b95ead064205559f25572c5d5ea86cc4c6ef55605120216b2505bb87` |

Conditions match STORY-039's and STORY-049's approved pairs: dark theme, `vi`
locale, Android 412x915dp design frame vs `emulator-5560` at 1080x2400 @420dpi,
`font_scale` 1.0, both sides bounded to 900 px tall.

No signed-state design render was attempted. STORY-049's D-10 finding already
established that the canvas's `mySigned` branch (`Cupid Screens.dc.html:154`)
carries no `hint-placeholder-val` and that two `--click` attempts on the
hold-to-sign control produced output byte-identical to the unclicked baseline.
That experiment was not repeated.

## Why A Fresh Pair, Not A Reuse

AC-1's preferred path is reuse of STORY-049's pair, conditional on confirming
the `contract` screen's source and the design source are both unchanged since
that capture. **The confirmation failed on the implementation side**, so the
reuse path was not taken.

Verified from the control checkout, STORY-049's own story commit `d58da5f` to
`HEAD` (`d369cda`):

- `git diff --stat d58da5f..HEAD -- mobile/lib/features/love_contracts/` →
  **empty**. The screen's own feature tree is untouched.
- `git diff --stat d58da5f..HEAD -- cupid-app-design-system/` → **empty**. The
  design source is untouched.
- `git diff --stat d58da5f..HEAD -- mobile/lib/` → **not empty** (20 files,
  +659/-78). This is the broader check STORY-050 used, and it is the one that
  matters here: it includes `design_system/adaptive/cupid_header.dart` (+51),
  and `love_contract_screen.dart:114` renders through `CupidHeader`.
- `git status --porcelain -- mobile/ cupid-app-design-system/` → **empty**.

Reading that diff suggests the `CupidHeader` change is visually inert for this
screen — both new slots (`trailing`, `titleSemanticLabel`) are null-guarded and
the null branch rebuilds the prior tree exactly, and `contract` passes neither.
But "inert by inspection" is a weaker claim than a render, so a fresh pair was
produced instead and the question does not arise.

### Design side — re-rendered, and it reproduces the stored hash

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=cupid-app-design-system --entry="Cupid App.dc.html" \
  --screen=contract --platform=android --theme=dark --lang=vi \
  --out=<this story's visual-fidelity/> --label=contract-myunsigned
```

→ `DESIGN_CANVAS: OK ... 406x900`, exit 0. The output is **byte-identical** to
STORY-049's and STORY-039's stored reference
(`2acd1045…14b3` on all three). That identity is independent confirmation that
the design source has not moved, obtained by rendering rather than by asserting.

### Implementation side — rebuilt and re-captured

1. `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=contract --dart-define=PREVIEW_CONTRACT_SIGN_STATUS=requesterUnsigned`
   → `✓ Built build/app/outputs/flutter-apk/app-debug.apk`, exit 0.
   Required, because `PREVIEW_CONTRACT_SIGN_STATUS` is a compile-time
   `String.fromEnvironment`. **`main_preview.dart` was not modified** — the
   `requesterUnsigned` fixture STORY-049 added is used as-is.
2. `adb -s emulator-5560 install -r …/app-debug.apk`
3. `adb -s emulator-5560 shell settings put system font_scale 1.0`
4. `am force-stop com.snapsofts.cupid`, then a launcher `am start` of
   `com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
5. `capture-mobile-screen.sh --device=emulator-5560 --label=contract-requesterunsigned --mode=implemented --platform=android --max-edge=900`
   → `MOBILE_CAPTURE: OK … 405x900`, exit 0. Steps 2-5 ran inside a single
   `--lease-exec` device lease so no concurrent worker could disturb the device
   mid-capture.

Note for the next capture on this harness: a 12000 ms settle is **not enough**
for this debug build. The first attempt captured the Flutter splash screen and
was discarded; a 45 s settle before the screenshot produced the real screen.
Confirm the capture's content before trusting it — the splash capture exited 0
and carried a plausible `405x900`, so exit status alone does not distinguish
the two.

The implementation PNG's hash differs from STORY-049's stored capture. This is
**expected and is not evidence of a render change**: the status-bar clock is
baked into every screenshot, and this capture also took a different downscale
path (`capture-mobile-screen.sh` rather than STORY-049's manual `sips` step).
Byte equality was never available here and is not claimed.

## Same-State Confirmation

The implementation capture shows no `đã ký` signature line, both sign-state
affordances are pre-signature, and the hold-to-sign control is unpressed. The
design reference shows the same. The mismatched-state condition DEF-2 recorded
is not present in this pair.

## Measurement Method

Probed programmatically with a stdlib `zlib`/`struct` PNG reader: accent-pink
band detection for checkboxes, the add-clause row and the CTA; luminance-step
detection for card and pill edges; full-width alternation detection for the
dashed hairlines; row-local background deviation for text bands. Not eyeballed.
All positions are image px in each file's own 900 px-tall frame.

**Vertical scale is 1:1 between the two files**, established by three
independent invariants rather than assumed:

| Invariant | Design | Implementation | Δ |
|---|---|---|---|
| Clause row pitch | 47 | 47 | **0** |
| CTA pill height (at card centre − 120 px) | 62 | 62 | **0** |
| Add-clause label bottom → dashed rule below | 19.5 | 19.5 | **0** |

Horizontal geometry is **not** 1:1: the design canvas carries a device bezel, so
its card is 356 px wide (x 25..381) against the capture's 372 px (x 16..388).
Horizontal is therefore compared as insets and centring relative to the card,
never as absolute position — the rule STORY-039 established for this screen.

## Per-Element Verdict

| # | Element | Verdict | Basis |
|---|---------|---------|-------|
| 1 | Header band | **MATCH** | Eyebrow / display title / subtitle present in that order on both, inside the gradient wash with rounded top corners. Measured bands — eyebrow: design y142..152, impl y144..153; title: design y163..189, impl y170..194; subtitle: design y203..216, impl y212..224. |
| 2 | Clause rows | **MATCH** | Four rows both sides; round check control at the leading edge, label, `§n` marker trailing. Pitch 47 px on both. Clause 1 top → add-clause top: design 193, impl 192 (Δ1). |
| 3 | Divider | **MATCH** | Two dashed hairlines on both, bounding the clause block. Rule A: design y234..235, impl y242..244. Rule B: design y482..483, impl y509..512. Add-clause bottom → rule B is 19.5 px on both (Δ0). |
| 4 | CTA / hold-to-sign affordance | **MATCH** | Sign caption then full-width rounded pill with the pink→purple gradient, circular light badge and `Giữ để ký` label, on both. Pill height 62 px on both (Δ0). Pill bottom → card bottom: design 22, impl 24 (Δ2). |
| 5 | Encryption footer | **MATCH** | Lock glyph plus `Bản hợp đồng lưu ở Level 2 — mã hoá đầu-cuối`, outside and below the card on both, and exactly centred on both: design content x78..329, centre 203 against canvas centre 203; impl x55..350, centre 202 against canvas centre 202. |

**New deviations found: NONE.** Every measured difference resolves into one of
the three already-recorded categories below.

### Differences that are already dispositioned

- **Clause-counter row `2/20 điều khoản`** — present in the implementation,
  absent from the design source. Dispositioned as A-1 by STORY-015 (shipped
  REQ-001 affordance backed by a server-enforced 20-clause cap) and re-confirmed
  as CC-1 by STORY-050, both keep-and-exclude. It fully accounts for the one
  structural span that differs: the distance between the two dashed rules is
  248 px on the design side and 267.5 px on the implementation side, and the
  counter row occupies that ~19.5 px.
- **Add-clause label copy** — design `Thêm điều khoản của riêng tụi mình`
  against the implementation's `Thêm điều khoản riêng`. The shipped `vi` ARB
  string, accepted under STORY-015's D-7 (whose defect was the duplicated glyph,
  not the wording) and recorded again by STORY-049.

### Fixture-state differences, not fidelity

- **Subtitle** — design `Giữa Minh & Linh · có hiệu lực đến khi cả hai cùng
  huỷ` against the implementation's `Có hiệu lực đến khi cả hai cùng huỷ`. The
  preview harness supplies no `myDisplayName`, so the subtitle falls back to its
  neutral form. Recorded by STORY-049 for the same reason.
- **Clause selection** — the design selects 3 of 4 preset clauses, the fixture
  selects 2. Equally true of STORY-039's and STORY-049's approved pairs.
- **Clause label language** — the implementation renders the preview fixture's
  English strings (`Always tell the truth`, …) where the design renders its
  Vietnamese preset copy. This is preview fixture **data**, not shipped copy and
  not a layout or token property. It is the same fixture text visible in
  STORY-046's capture and named in DEF-2's own description.

### Rendered-gap tolerance, not a deviation

Three gaps run a few px larger in the implementation: the header band's
eyebrow→title gap (design 11, impl 17), its title→subtitle gap (design 14, impl
18), and the card-bottom→footer gap (design 14, impl 20). These are text
line-box and leading differences between a static HTML prototype and Flutter's
text layout, not spacing-token divergence:

- The header's spacing tokens were already reconciled to the design source by
  STORY-015's D-6 (`margin-top:8px` under the sequence label and `margin-top:7px`
  under the title, both implemented as `CupidSpacing.sm`), and STORY-015's D-5
  set the title's `height: 1.1`, which adds leading above and below the glyph
  band without moving the box.
- Every measurement that is independent of a text line box matches exactly —
  clause pitch 47/47, CTA pill height 62/62, add-clause→rule 19.5/19.5.

Glyph band heights are correspondingly 1-2 px *smaller* in the implementation
(title 27 vs 25, subtitle 14 vs 13), which is the same rasterization effect seen
from the other side and is inconsistent with an actual spacing regression.

## AC-3: Scope Boundary Held

No `mobile/lib/**` file was modified, including `mobile/lib/main_preview.dart`.
`git status --porcelain -- mobile/ cupid-app-design-system/` was empty before
the work and the only paths this story writes are its own
`visual-fidelity/` directory and its own `story_master.md`. The design source
was rendered read-only, with `--out` pointing at this story's own evidence
directory. STORY-015's, STORY-039's, STORY-046's and STORY-049's evidence
directories were read but not written.

## Verification State

Run in this session from `/Users/alantravala/workspace/snapsofts/cupid-apps/mobile`
against the working tree at `HEAD` `d369cda`:

- `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=contract --dart-define=PREVIEW_CONTRACT_SIGN_STATUS=requesterUnsigned`
  → `✓ Built build/app/outputs/flutter-apk/app-debug.apk`, exit 0.
- `flutter analyze --no-pub lib test` → `80 issues found`, all `info`, zero
  errors, zero warnings. Identical to the baseline STORY-049 and STORY-050 both
  recorded. Exit code 1 is `flutter analyze`'s normal result whenever any issue
  exists including `info`-level ones, and is not a failure signal here.
- `flutter test --no-pub` (full suite) → `+1314 ~2: All other tests passed!`,
  exit 0. 1314 passed, 2 skipped, 0 failures. The count is above STORY-050's
  1285 because other stories have since added tests; this story adds none.
- Flutter 3.44.1 stable / Dart 3.12.1.

This story changes no source, so the verification is evidence that it introduced
no regression, not a new build result.

VISUAL_FIDELITY: PASS
