# Test Results — STORY-054 (`--scroll` + post-screen `--hide` re-apply)

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-054_render_design_canvas_scroll_capture_hardening
- Lane: devops (single lane)
- Date: 2026-08-18
- Tool: `.ai-team-bundle/runtime/tools/render-design-canvas.js`, invoked from
  `/Users/alantravala/workspace/snapsofts/cupid-apps`
- BaseHead: `251336d562c0eb91a458eb795a18f318ae7f273a`

Every result below is from executing the patched tool. Scratch output dirs are
abbreviated `<scratch>/...`; the full paths were under the session scratchpad.

## 1. Durability boundary and patch chain (AC5)

```
git check-ignore -v .ai-team-bundle/runtime/tools/render-design-canvas.js
.gitignore:5:.ai-team-bundle/	.ai-team-bundle/runtime/tools/render-design-canvas.js
```

Ignored, as STORY-044 recorded. `.gitignore` was not edited and the tool file
was not force-added. The durable deliverables are
`coding-plan/render-design-canvas-scroll.patch` and
`coding-plan/tool-contract-scroll-flag.md`.

**The baseline is exactly the STORY-044-applied state.** Proven by reverse-applying
STORY-044's landed patch to the pre-change copy:

```
patch -R --dry-run <pre-change copy> < STORY-044.../coding-plan/render-design-canvas-click.patch
patching file '<pre-change copy>'
exit 0
```

A clean reverse means the `--click` change is present verbatim, so STORY-054's
patch is generated against — and applies on top of — STORY-044's output.

**The patch reproduces the working change exactly:**

```
patch --dry-run <copy of pre-change file> < coding-plan/render-design-canvas-scroll.patch   # exit 0, no fuzz, no .rej
patch           <copy of pre-change file> < coding-plan/render-design-canvas-scroll.patch   # exit 0
diff <patched copy> .ai-team-bundle/runtime/tools/render-design-canvas.js                   # exit 0, zero-byte diff
```

## 2. Playwright provisioning

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js --location=cupid-app-design-system --entry="Cupid App.dc.html" --list-screens
```

Exit **0**. Full inventory printed: 38 screens (including `timeline` and
`gallery`), toggles `dark/light/vi/en`, platforms `ios/android`. No
`VISUAL_RUNTIME_MISSING`.

## 3. AC1 — below-the-fold content becomes capturable

### 3a. `--scroll=end` (no magic number)

```bash
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=cupid-app-design-system --entry="Cupid App.dc.html" \
  --out=<scratch>/tl-end --screen=timeline --platform=android \
  --theme=dark --lang=vi --scroll=end
# hide: re-applied after --screen=timeline, matched 2x '[data-plat] [style*="z-index: 95"]'
# scroll: android frame at 207px of 207px on <div>
# DESIGN_CANVAS: OK <scratch>/tl-end/design-reference-timeline-android.png 406x900
# exit 0
```

### 3b. Explicit pixel offset

```bash
... --scroll=100
# scroll: android frame at 100px of 207px on <div>
# DESIGN_CANVAS: OK <scratch>/tl-px/design-reference-timeline-android.png 406x900
# exit 0
```

### 3c. Offset past the bottom clamps, visibly

```bash
... --scroll=5000
# scroll: android frame at 207px of 207px on <div> (requested 5000px, clamped to the bottom)
# DESIGN_CANVAS: OK <scratch>/tl-clamp/design-reference-timeline-android.png 406x900
# exit 0
```

### 3d. Frame chrome, bezel, and dimensions unchanged

Unscrolled baseline of the same screen, same command minus `--scroll`:

```
# DESIGN_CANVAS: OK <scratch>/tl-base/design-reference-timeline-android.png 406x900
```

Both renders are **406x900**. Visual comparison of the committed pair
(`ac6-timeline-unscrolled-android.png` vs `ac6-timeline-scrolled-android.png`):
the Android status bar (`9:30`, wifi/signal/battery), the camera notch, the
`Love Timeline` header with its back arrow, the bottom nav
(`Nhà / Trò chuyện / Pet / Ví chung / Tôi` with `Pet` active), the home
indicator, and the device bezel are pixel-for-pixel in the same place. Only the
scrollable entry list moved.

### 3e. `--platform=all` scrolls each frame independently

```bash
... --platform=all --scroll=end
# scroll: ios frame at 260px of 260px on <div>
# scroll: android frame at 207px of 207px on <div>
# DESIGN_CANVAS: OK <scratch>/tl-all/design-reference-timeline-ios.png 416x900
# DESIGN_CANVAS: OK <scratch>/tl-all/design-reference-timeline-android.png 406x900
# exit 0
```

Different offsets because the frames have different viewport heights. Unlike
`--click` (KD3), `--scroll` is not selector-scoped, so `--platform=all` does not
leave one frame behind.

**AC1: PASS.**

## 4. AC2 — `--hide` selectors survive the screen change

The hide target is the canvas's own screen-index FAB
(`design-fidelity-config.json` `design_source.hide_selectors`,
`[data-plat] [style*="z-index: 95"]`).

**With hide (the normal path), scrolled** — `ac6-timeline-scrolled-android.png`:
the bottom-right corner above the nav bar is empty.

**Without hide, scrolled** — `ac2-timeline-scrolled-nohide-android.png`,
produced by pointing `CLAUDE_PROJECT_DIR` at a config-less scratch root so no
`hide_selectors` are contributed:

```bash
CLAUDE_PROJECT_DIR=<scratch>/fakeroot node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=/Users/alantravala/workspace/snapsofts/cupid-apps/cupid-app-design-system \
  --entry="Cupid App.dc.html" --out=<scratch>/ac2-nohide --screen=timeline \
  --platform=android --theme=dark --lang=vi --scroll=end --label=nohide
# scroll: android frame at 207px of 207px on <div>
# exit 0
```

That render shows the rounded purple grid-icon FAB at bottom-right, directly
above the nav bar. It is **absent** from every hide-enabled render.

**Without the scroll control:** the AC3 renders in section 6 are all
`--screen` + hide with no `--scroll`, and all three are byte-identical to their
committed references — references whose own acceptance already established the
FAB is absent.

**AC2: PASS**, both with and without `--scroll`.

## 5. Is the re-apply pass load-bearing? — measured, not assumed

RWB-20260816-020 asserts `--hide` selectors "do not survive the screen
re-render". **That does not reproduce on the 2026-08-11 export.**

A development probe (`probe-rehide.js`, scratch-only, not part of the AC6
evidence) tagged each node hidden by the pre-click pass, clicked
`[data-screen-btn="timeline"]`, then re-queried:

```json
{
  "pass1Hidden": 2,
  "afterScreenClick": { "matched": 2, "tagged": 2, "stillHidden": 2, "visible": 0 }
}
```

`tagged: 2` is the decisive field: the nodes present after the click are the
*same* DOM nodes pass 1 hid, not fresh ones that merely match the selector, and
all 2 are still `display: none`. Match counts alone could not have distinguished
those two cases.

Consequence, stated plainly for the review gate: **the re-apply pass currently
hides nothing new.** It is retained because it is the only truthful place to run
AC4's hide check — whether the shutter will capture chrome is a question about
post-click state, and pass 1 answers a different question. Rationale in
`tool-contract-scroll-flag.md`. This also explains *why* section 6 comes back
byte-identical rather than merely reporting that it does.

## 6. AC3 — no regression for existing callers

Each screen re-rendered with the command line that produced its committed
reference, then compared by SHA-256.

### welcome (STORY-035)

```bash
node .ai-team-bundle/runtime/tools/render-design-canvas.js --location=cupid-app-design-system --entry="Cupid App.dc.html" --screen=welcome --platform=android --theme=dark --lang=vi --label=welcome --out=<scratch>
```

- exit **0**, `406x900`
- fresh: `1b803c71385ba57d1214a6060105f880666fc5f6f821d627bf7fddd894aa95d7`
- committed `STORY-035.../visual-fidelity/design-reference-welcome-android.png`:
  `1b803c71385ba57d1214a6060105f880666fc5f6f821d627bf7fddd894aa95d7`
- **identical**

### register (STORY-036)

```bash
... --screen=register --label=register
```

- exit **0**, `406x900`
- fresh: `0858a9a915f08fbbfeb011c043e752037b7b5e5bb50174b5430afa5a74a482ed`
- committed `STORY-036.../visual-fidelity/design-reference-register-android.png`:
  `0858a9a915f08fbbfeb011c043e752037b7b5e5bb50174b5430afa5a74a482ed`
- **identical**

### gallery (STORY-044) — exercises the `--click` path

```bash
... --screen=gallery --platform=android --theme=dark --lang=vi \
  --click='[data-plat="md"] div:has(> span[data-icon]:text-is("fingerprint"))'
# hide: re-applied after --screen=gallery, matched 2x '[data-plat] [style*="z-index: 95"]'
# click: '...' matched 1 element(s)
# exit 0, 406x900
```

- fresh: `82277b90885e120bd1ec8a66e997f6f713733fd8fe32b1cbdcdbca3a15bd2141`
- committed `STORY-044.../visual-fidelity/design-reference-gallery-android.png`:
  `82277b90885e120bd1ec8a66e997f6f713733fd8fe32b1cbdcdbca3a15bd2141`
- **identical**

This third case matters: it proves the new hide pass does not perturb the
`--click` pipeline, which is the only other post-`--screen` stage.

### Flag surface unchanged

No existing flag changed spelling, value type, or repeat semantics.
`MULTI_VALUE_KEYS` still contains only `click`; `--scroll` and
`--scroll-settle-ms` are new keys and are last-wins. The `--list-screens`
inventory in section 2 is unchanged from STORY-044's.

**AC3: PASS** on three screens, one of which covers `--click`.

## 7. AC4 — unsatisfiable requests fail loudly, with no PNG

### 7a. No scrollable element

```bash
... --screen=welcome --platform=android --theme=dark --lang=vi --scroll=end --out=<scratch>/ac4-noscroll
# hide: re-applied after --screen=welcome, matched 2x '[data-plat] [style*="z-index: 95"]'
# DESIGN_CANVAS_SCROLL_TARGET_MISSING: nothing inside the android frame scrolls
#   (0 overflowing candidate(s) examined); --scroll=end cannot be honoured
# exit 1
```

`find <scratch>/ac4-noscroll -type f` → **no files**. The directory had already
been created by `fs.mkdirSync` before the scroll pass ran, so its continued
emptiness is the proof, not the absence of one expected filename.

### 7b. No scrollable element, on a real screen with `--click` in the pipeline

```bash
... --screen=gallery --platform=android --theme=dark --lang=vi \
  --click='[data-plat="md"] div:has(> span[data-icon]:text-is("fingerprint"))' \
  --scroll=end --label=gallery-scrolled
# click: '...' matched 1 element(s)
# DESIGN_CANVAS_SCROLL_TARGET_MISSING: nothing inside the android frame scrolls
#   (0 overflowing candidate(s) examined); --scroll=end cannot be honoured
# exit 1
```

The opened `galleryOpen` state fits its frame, so there is nothing to scroll and
the tool refuses rather than silently emitting an unscrolled image labelled as
scrolled. No PNG written.

### 7c. A `--hide` selector matching nothing

Run against a config-less `CLAUDE_PROJECT_DIR` (with `.ai-team-bundle` symlinked
in so Playwright still resolves) so the stale selector is the only one in play —
the shape of a real export drift:

```bash
CLAUDE_PROJECT_DIR=<scratch>/fakeroot node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=/Users/alantravala/workspace/snapsofts/cupid-apps/cupid-app-design-system \
  --entry="Cupid App.dc.html" --out=<scratch>/ac4-hide --screen=timeline \
  --platform=android --theme=dark --lang=vi \
  --hide='.stale-selector-from-an-old-export' --scroll=end
# warning: --hide/hide_selectors matched nothing (.stale-selector-from-an-old-export); ...
# hide: re-applied after --screen=timeline, matched 0x '.stale-selector-from-an-old-export'
# DESIGN_CANVAS_HIDE_TARGET_MISSING: nothing matched .stale-selector-from-an-old-export
#   after the 'timeline' screen change; the reference would carry prototype chrome
# exit 1
```

`find <scratch>/ac4-hide -type f` → **no files**. Pass 1's warning is preserved
verbatim; the new pass turns it into a blocker.

### 7d. Invalid `--scroll` value

```bash
... --screen=timeline --scroll=bottom
# DESIGN_CANVAS_SCROLL_VALUE_INVALID: --scroll takes a non-negative pixel offset or 'end', got 'bottom'
# exit 1
```

`find <scratch>/ac4-badval -type f` → **no files**.

**AC4: PASS** — four cases, each a typed `DESIGN_CANVAS_*` code, exit 1, and an
empty output directory.

## 8. AC5 — durable delivery

| Artifact | Status |
| --- | --- |
| `coding-plan/render-design-canvas-scroll.patch` | committed, 207 lines, applies cleanly on STORY-044's output (section 1) |
| `coding-plan/tool-contract-scroll-flag.md` | committed — flag spelling, accepted values, ordering guarantee, typed failure codes |
| `coding-plan/test-results.md` | this file |

**AC5: PASS.**

## 9. AC6 — the original discovery case is closed

Exact command, `render-design-canvas.js` alone, no diagnostic or throwaway
script anywhere in it:

```bash
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=cupid-app-design-system \
  --entry="Cupid App.dc.html" \
  --out=<out dir> \
  --screen=timeline \
  --platform=android \
  --theme=dark \
  --lang=vi \
  --scroll=end
```

```
hide: re-applied after --screen=timeline, matched 2x '[data-plat] [style*="z-index: 95"]'
scroll: android frame at 207px of 207px on <div>
DESIGN_CANVAS: OK <out dir>/design-reference-timeline-android.png 406x900
exit 0
```

| Committed evidence | SHA-256 |
| --- | --- |
| `coding-plan/ac6-timeline-scrolled-android.png` | `68973230151a4989218b0950a093a459679b8b596945d5a95ca22b12de91851d` |
| `coding-plan/ac6-timeline-unscrolled-android.png` | `a548d54fa7f25216466cf43b9707b7ece2487c880094e9aa101f481f62fcff44` |
| `coding-plan/ac2-timeline-scrolled-nohide-android.png` | `13a9a526e5f821b6ca869b658005dc5c6adfeadfe4b86ab24d763aa9c89543b0` |

Content RWB-20260816-020 names as uncapturable, now present in the scrolled
render and verifiably **absent** from the unscrolled baseline:

- **The last entry row** — `Ký Love Contract`, `25/11/25`, "Ngày thứ 1. Bốn điều
  khoản, hai dấu vân tay.", with its violet timeline dot and `tự động thêm` chip.
- **The "Thêm kỷ niệm" dashed button** — full-width dashed-border pill with the
  pink `+` badge, below the last entry.

The unscrolled baseline ends at `Nhận nuôi Bún` (26/11/25), clipped mid-card by
the nav bar. Neither the `Ký Love Contract` row nor the `Thêm kỷ niệm` button
appears anywhere in it.

The render was produced twice — once before and once after the final
per-selector hide refactor — and both are SHA-256
`68973230151a4989218b0950a093a459679b8b596945d5a95ca22b12de91851d`, so the
committed PNG matches the committed patch.

**AC6: PASS.**

## 10. Summary

| AC | Result |
| --- | --- |
| AC1 | PASS — `end` and pixel modes, clamping, dimensions/bezel unchanged (406x900 both), per-frame under `--platform=all` |
| AC2 | PASS — FAB absent with hide, present without, verified under `--scroll` and without it |
| AC3 | PASS — `welcome`, `register`, `gallery` all byte-identical (SHA-256) to committed references; `gallery` covers `--click` |
| AC4 | PASS — 4 typed failures, exit 1, empty output dir in every case |
| AC5 | PASS — patch + contract note committed; patch chain onto STORY-044 proven both directions |
| AC6 | PASS — `timeline` last entry row and "Thêm kỷ niệm" captured by the sanctioned tool alone |

### Gates

No `mobile/`, `backend/`, or `frontend/` path was touched, so no Flutter
analyze/test/build gate applies. `git diff --stat 251336d5 -- mobile/ backend/
frontend/` is empty. The tool is a headless Node CLI with no test harness of its
own; sections 3-7 are its execution gate, and they exercise every new code path
including all four failure branches.

### Runtime-Smoke recommendation

**WAIVE.** Zero app-code delta, and no service or app runtime is involved. The
14 tool executions above are a stronger gate for a headless Node CLI than an app
startup smoke would be: they cover both success modes, all four typed failures,
both device frames, and three byte-identical no-regression renders. Same shape
STORY-044's devops phase closed with `Runtime-Smoke: WAIVED`. Scrum Master's
call at the DONE gate.
