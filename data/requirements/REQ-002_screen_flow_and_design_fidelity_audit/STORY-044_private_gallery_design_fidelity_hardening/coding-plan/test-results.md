# Test Results — STORY-044 Phase P0 (`--click` pre-shutter interaction flag)

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-044_private_gallery_design_fidelity_hardening
- Phase: P0 — `render-design-canvas.js` `--click` flag
- Lane: devops
- Date: 2026-08-17
- Tool: `.ai-team-bundle/runtime/tools/render-design-canvas.js`, invoked from
  `/Users/alantravala/workspace/snapsofts/cupid-apps`

## 1. Durability boundary (task 1, resolves KD4)

```
git check-ignore -v .ai-team-bundle/runtime/tools/render-design-canvas.js
```

Result: `.gitignore:5:.ai-team-bundle/	.ai-team-bundle/runtime/tools/render-design-canvas.js`

Ignored, as expected. Per solution.md section 3 (`P0 durability boundary`):
the working change is applied in place (uncommitted, not durable on its own);
the durable, reviewable deliverable is
`coding-plan/render-design-canvas-click.patch` plus
`coding-plan/tool-contract-click-flag.md`, both tracked under this story's own
directory. `.gitignore` was not edited and the tool file was not force-added.

## 2. Playwright provisioning

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js --location=cupid-app-design-system --entry="Cupid App.dc.html" --list-screens
```

- Exit code: **0** — full screen/toggle/platform inventory printed, including
  `gallery`. No `VISUAL_RUNTIME_MISSING`. Playwright is provisioned; the Stop
  Rule condition for a missing runtime does not apply.

## 3. `parseArgs` repeatability (task 2)

**Repeatability preserved for `--click`.** Two `--click` flags were passed,
first a deliberately non-matching selector, second the verified selector from
section 5 below:

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=cupid-app-design-system --entry="Cupid App.dc.html" \
  --out=<scratch> --screen=gallery --platform=android --theme=dark --lang=vi \
  --click='deliberately-bad-first-selector-xyz' \
  --click='[data-plat="md"] div:has(> span[data-icon]:text-is("fingerprint"))'
```

- stderr: `click: 'deliberately-bad-first-selector-xyz' matched 0 element(s)`
- stdout/stderr: `DESIGN_CANVAS_CLICK_TARGET_MISSING: no element matched 'deliberately-bad-first-selector-xyz'`
- Exit code: **1**

This proves both `--click` values were retained (the tool died on the
**first** one instead of silently keeping only the last, which is what the
pre-fix last-wins `parseArgs` would have done — the second, valid selector
would have silently overwritten the first, and the render would have
succeeded with no error at all).

**Last-wins preserved for every other key.** `--entry` was passed twice,
first a nonexistent file, second the real one:

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js --location=cupid-app-design-system --entry="wrong-file.dc.html" --entry="Cupid App.dc.html" --list-screens
```

- Exit code: **0** — used `"Cupid App.dc.html"` (the last value), no
  `DESIGN_CANVAS_ENTRY_MISSING` for `wrong-file.dc.html`. Confirms
  `MULTI_VALUE_KEYS` is scoped to `click` only; `--screen`/`--theme`/`--lang`/
  `--hide`/`--platform`/`--out`/`--label`/`--max-edge`/`--entry`/the
  `*-settle-ms` family are unaffected.

## 4. AC2 — non-matching selector fails cleanly

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=cupid-app-design-system --entry="Cupid App.dc.html" \
  --screen=gallery --platform=android --theme=dark --lang=vi \
  --click='[data-plat="md"] div.this-selector-does-not-exist-anywhere' \
  --out=<scratch-ac2>
```

- stderr: `click: '[data-plat="md"] div.this-selector-does-not-exist-anywhere' matched 0 element(s)`
- stderr/exit message: `DESIGN_CANVAS_CLICK_TARGET_MISSING: no element matched '[data-plat="md"] div.this-selector-does-not-exist-anywhere'`
- Exit code: **1**
- `<scratch-ac2>` directory contents after the run: **empty** (`find <scratch-ac2> -type f` returned nothing) —
  no new, partial, or truncated PNG was written. `fs.mkdirSync(out)` had
  already created the directory before the click pass ran; the directory's
  continued emptiness is the proof, not just the absence of a specific
  filename.

AC2 satisfied: typed error, non-zero exit, no output file.

## 5. AC3 — no regression to existing screen captures

Two screens with existing committed `design-reference-*` PNGs from the
STORY-035..043 hardening set were re-rendered with **no** `--click` argument
and compared byte-for-byte (SHA-256) against the committed references.

### welcome (STORY-035)

Command (from `STORY-035.../coding-plan/test-results.md` section 5, the
literal command already used to produce the committed reference):

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js --location=cupid-app-design-system --entry="Cupid App.dc.html" --screen=welcome --platform=android --theme=dark --lang=vi --label=welcome --out=<scratch>
```

- Exit code: **0** — `DESIGN_CANVAS: OK <scratch>/design-reference-welcome-android.png 406x900`
- SHA-256 of fresh render:
  `1b803c71385ba57d1214a6060105f880666fc5f6f821d627bf7fddd894aa95d7`
- SHA-256 of committed
  `STORY-035_welcome_design_fidelity_hardening/visual-fidelity/design-reference-welcome-android.png`:
  `1b803c71385ba57d1214a6060105f880666fc5f6f821d627bf7fddd894aa95d7`
- **Match: identical.**

### register (STORY-036)

Command (same flag pattern; `register` confirmed in the `--list-screens`
inventory in section 2):

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js --location=cupid-app-design-system --entry="Cupid App.dc.html" --screen=register --platform=android --theme=dark --lang=vi --label=register --out=<scratch>
```

- Exit code: **0** — `DESIGN_CANVAS: OK <scratch>/design-reference-register-android.png 406x900`
- SHA-256 of fresh render:
  `0858a9a915f08fbbfeb011c043e752037b7b5e5bb50174b5430afa5a74a482ed`
- SHA-256 of committed
  `STORY-036_register_design_fidelity_hardening/visual-fidelity/design-reference-register-android.png`:
  `0858a9a915f08fbbfeb011c043e752037b7b5e5bb50174b5430afa5a74a482ed`
- **Match: identical.**

AC3 satisfied for both screens: the `--click` addition (parser change +
new pass gated on `clicks.length`) produces zero behavior change when no
`--click` is passed.

## 6. AC1/AC4-readiness — `galleryOpen` render, and R1

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=cupid-app-design-system --entry="Cupid App.dc.html" \
  --out=<scratch> --screen=gallery --platform=android \
  --theme=dark --lang=vi \
  --click='[data-plat="md"] div:has(> span[data-icon]:text-is("fingerprint"))'
```

- stderr: `click: '[data-plat="md"] div:has(> span[data-icon]:text-is("fingerprint"))' matched 1 element(s)`
- Exit code: **0** — `DESIGN_CANVAS: OK <scratch>/design-reference-gallery-android.png 406x900`
- Visual inspection of the rendered PNG confirms the `galleryOpen` `<sc-if>`
  block (actual L744-759, KD1): the mint "Đã mở · tự khoá lại sau 60 giây"
  banner with the `00:58` countdown, the 2-column photo grid (3 photo tiles
  with date/location captions), and the dashed "Thêm ảnh" add tile. This is
  **not** the `galleryLocked` block — confirmed by contrast against the
  baseline render below.
- The candidate selector from solution.md section 1 (KD2) matched exactly
  **one** element with no adjustment needed; recorded verbatim in
  `tool-contract-click-flag.md`.

**R1 (prototype FAB reappearing after re-render) — verified, not reproduced.**
A second render of the same screen with no `--click` (the `galleryLocked`
baseline state) was captured for comparison:

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=cupid-app-design-system --entry="Cupid App.dc.html" \
  --out=<scratch-baseline> --screen=gallery --platform=android --theme=dark --lang=vi
```

- Exit code: **0**. Rendered image shows the `galleryLocked` block ("Chỉ mình
  bạn mở được", fingerprint-icon "Mở bằng vân tay" CTA — the exact element
  `--click` targets).
- Neither the `galleryOpen` (post-click) render nor the `galleryLocked`
  (pre-click) baseline shows the screen-index FAB
  (`design-fidelity-config.json` `hide_selectors`,
  `[data-plat] [style*="z-index: 95"]`) anywhere in the frame. The FAB is
  hidden before the click (the existing unconditional hide pass, L317-347)
  and stays hidden after the click's re-render.
- Per task 10 / R1 handling ("verify, do not pre-emptively code"): the FAB
  did **not** reappear, so no re-run-hide-after-click code was added. The
  click pass is exactly the block in
  `coding-plan/render-design-canvas-click.patch`, with no additional gated
  hide logic.

AC1 and AC4-readiness satisfied: the click runs after `--screen` navigation
and before the shutter (see `tool-contract-click-flag.md` for the AC1 wording
reconciliation), and the `galleryOpen` state renders successfully, unblocking
P1.

## 7. Patch artifact verification

`coding-plan/render-design-canvas-click.patch` was dry-run and then applied
with `patch -p1` against a saved copy of the pre-change file, and the result
was diffed against the actual working tool file:

- `patch -p1 --dry-run`: applied cleanly, no `.rej`, no fuzz.
- `patch -p1` (real apply) then `diff` against
  `.ai-team-bundle/runtime/tools/render-design-canvas.js`: **zero-byte diff**
  (exit 0) — the patch reproduces the working change exactly.

## 8. Summary

| AC | Result |
| --- | --- |
| AC1 | PASS — click pass runs after `--screen`, before the shutter; wording reconciliation recorded in `tool-contract-click-flag.md` |
| AC2 | PASS — typed `DESIGN_CANVAS_CLICK_TARGET_MISSING`, exit 1, no PNG written |
| AC3 | PASS — `welcome` and `register` re-render byte-identical (SHA-256) to committed references |
| galleryOpen render (task 10) | PASS — real `galleryOpen` PNG produced, P1 unblocked |
| R1 | Verified not reproduced; no code added |
| Durability boundary (task 1) | Resolved — tool file confirmed gitignored; patch + contract note are the durable artifacts |

---

# Phase P1 — Gallery rendered-fidelity evidence

Plan: `coding-plan/phase-P1-gallery-rendered-fidelity-evidence.md`.
Evidence report: `visual-fidelity/visual-fidelity-report.md`.

## P1.1 This phase is evidence-only — no Dart source changed

P1's Write Scope makes the gallery grid/tile widget and test files
*conditional*: they are touched only if the rendered comparison surfaces an
in-scope deviation. **It did not.** Every measured difference resolved into an
already-adjudicated bucket (AC1-as-amended token snaps, the disclosed E1/E2/E3
app extensions, or a design-system-token observation on a prohibited path).

The phase therefore produced evidence artifacts only. Proof that no Dart
changed, against the story's declared `BaseHead`:

```
$ git diff --stat db413549e2d0c877e1ce3a01f1d7b1b3e8394a6f -- mobile/
<no output>
```

`gallery_grid_view.dart`, `gallery_tile.dart`, `gallery_capture_entry.dart`,
and `gallery_design_fidelity_test.dart` are byte-identical to `BaseHead`.

## P1.2 Gates run anyway

Because no Dart changed, the plan's task 12 does not require the gates. They
were run regardless, as this lane's mandatory build evidence, and to prove the
tree is green at the point the evidence was produced.

Flutter SDK is not on `PATH` in this environment (see the runtime registry
note); every gate was prefixed with
`export PATH="/Users/alantravala/flutter/bin:$PATH"`.

```
Flutter 3.44.1 • channel stable • revision 924134a44c
Tools • Dart 3.12.1 • DevTools 2.57.0
```

### Static analysis

```
$ flutter analyze lib/features/gallery test/features/gallery
Analyzing 2 items...
   info • Use the null-aware marker '?' rather than a null check via an 'if'.
        • lib/features/gallery/data/gallery_api.dart:88:36 • use_null_aware_elements
1 issue found. (ran in 1.0s)
ANALYZE_EXIT=1
```

One `info`-severity lint, pre-existing and unrelated: it sits in
`gallery_api.dart`, which is neither in this phase's Write Scope nor changed by
it (see P1.1). `flutter analyze` returns a non-zero exit for any issue
including `info`, so the exit code is not a failure signal here. No error or
warning severity issue exists in the gallery lib or test trees. A repo-wide
`flutter analyze` was deliberately not used as the gate: it reports ~11,000
pre-existing `unused_import` warnings from the generated `openapi/cupid_api/**`
client, which would bury any real signal.

### Unit and widget tests

```
$ flutter test test/features/gallery
00:01 +45: All tests passed!
TEST_EXIT=0
```

45/45 passing, including the design-fidelity suite
(`gallery_design_fidelity_test.dart`), the add-tile-pinned-last assertion, and
the `memCacheWidth <= 640` R4 guard.

### Build

```
$ flutter build apk --debug
Running Gradle task 'assembleDebug'...   4.4s
✓ Built build/app/outputs/flutter-apk/app-debug.apk
BUILD_EXIT=0
```

Registry command for `mobile-app` (`buildCommand`), run verbatim. The Gradle
KGP deprecation warning about `sign_in_with_apple` and the JDK native-access
warning are both pre-existing and non-fatal.

## P1.3 Evidence artifacts produced

| Artifact | Detail |
| --- | --- |
| `visual-fidelity/design-reference-gallery-android.png` | 406x900, 149926 B, SHA-256 `82277b90885e120bd1ec8a66e997f6f713733fd8fe32b1cbdcdbca3a15bd2141` |
| `visual-fidelity/implemented-gallery-emulator-5560.png` | 1080x2400, SHA-256 `c9fbce3cb1150013eeb4f14a37b10854766eaf39b0dbc50d7c34979d41b90e08`, copied unmodified from STORY-026 |
| `visual-fidelity/visual-fidelity-report.md` | `VISUAL_FIDELITY: PASS`, `Design-Reference-Render: OK` |

Reference render command (the `--click` contract from P0, `--platform=android`
only per KD3):

```bash
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=cupid-app-design-system --entry="Cupid App.dc.html" \
  --out=<clean dir> --screen=gallery --platform=android --theme=dark --lang=vi \
  --click='[data-plat="md"] div:has(> span[data-icon]:text-is("fingerprint"))'
# click: '...' matched 1 element(s)
# DESIGN_CANVAS: OK .../design-reference-gallery-android.png 406x900
# exit 0
```

## P1.4 Summary

| AC | Result |
| --- | --- |
| AC4 | PASS — real `galleryOpen` Android reference rendered, command + selector + SHA-256 recorded; STORY-026's `DESIGN_CANVAS_STATE_FORCE_UNSUPPORTED` block cleared |
| AC5 | PASS — paired against the committed STORY-026 capture; equivalence of platform/theme/locale/state/content proven from `gallery_capture_entry.dart` |
| AC6 | PASS — all ten STORY-026 section-2 findings (D1-D10) confirmed against the rendered pair, none corrected; section-3 items re-verified; E2's open composite width question settled |
| AC7 | PASS — zero in-scope deviations surfaced; no R3 escalation raised; conditional Write Scope not exercised |
| Analyze | PASS — 1 pre-existing `info` lint outside this phase's files |
| Test | PASS — 45/45, exit 0 |
| Build | PASS — `app-debug.apk` built, exit 0 |
