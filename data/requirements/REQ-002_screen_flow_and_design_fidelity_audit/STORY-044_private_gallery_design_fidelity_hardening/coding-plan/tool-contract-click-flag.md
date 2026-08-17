# Tool Contract — `--click` Pre-Shutter Interaction Flag

- Tool: `.ai-team-bundle/runtime/tools/render-design-canvas.js`
- Phase: STORY-044 P0
- Durability: this file and `render-design-canvas-click.patch` are the durable,
  reviewable deliverables. The tool file itself is gitignored
  (`.gitignore:5`, confirmed by `git check-ignore -v`) and the working change
  is applied in place only, uncommitted — see `test-results.md` section 1.

## Flag signature

```
--click=<selector>     repeatable; each occurrence clicks one element
--click-settle-ms=<ms> optional, default 400 (band: 300-500ms, matches
                        --screen-settle-ms's default of 500)
```

`<selector>` is resolved through Playwright's selector engine
(`page.locator()`), a strict superset of CSS with `:has()`, `:text-is()`, and
`text=` support — not `page.evaluate` + `document.querySelectorAll` (that is
how `--hide` works, and it cannot reach this story's target; see KD2 below).

## Insertion point

Immediately after the `--screen` block and before the `label` assignment /
platform screenshot loop, in the order:

```
theme/lang toggles -> freeze-animations -> hide -> --screen click -> --click pass -> screenshot loop
```

### AC1 wording reconciliation

`requirements.md` AC1 says the click runs "after the `--screen` navigation
and before the hide/freeze/shutter capture sequence." In the tool's actual
control flow, hide and freeze already run **before** the `--screen` click, so
that literal phrase cannot be satisfied — it was written against STORY-026's
original proposal, before anyone read the real ordering (solution.md section
3, `P0 tool contract`). The reconciled reading, and the one this
implementation follows: the click pass runs after the `--screen` block and
before the shutter (the platform screenshot loop). Hide and freeze still run
once, before everything, exactly as they did before this change — nothing
about their ordering moved.

## Behavior

- **Repeatable.** `--click=a --click=b` runs both clicks, in argv order.
  `parseArgs`'s `MULTI_VALUE_KEYS` allowlist accumulates only `click` into an
  array; every other flag (`--screen`, `--theme`, `--lang`, `--hide`,
  `--platform`, `--out`, `--label`, `--max-edge`, `--entry`, the
  `*-settle-ms` family) keeps last-wins, unchanged.
- **No `--click` passed → zero behavior change.** The whole pass is gated on
  `clicks.length`; with no `--click`, nothing new runs. Verified in
  `test-results.md` section 5 by byte-identical (SHA-256) re-renders of two
  already-committed STORY-035/036 screens.
- **Zero matches → typed failure, no output file.** Before clicking, the tool
  runs `page.locator(sel).count()` and echoes the match count to stderr
  (`click: '<sel>' matched N element(s)`) for every selector, so an ambiguous
  selector (N > 1) is visible without failing — no strict-mode enforcement was
  added, per phase-P0 task 5. On `N === 0` the tool calls
  `die('DESIGN_CANVAS_CLICK_TARGET_MISSING: no element matched '<sel>'')` and
  exits 1 before any PNG is written. Verified in `test-results.md` section 4.
- **Ambiguous match (N > 1) → clicks the first.** `locator.first().click()`,
  consistent with "echo the count, do not enforce strict mode" (phase-P0 task
  5). Not exercised in this story (the verified selector matches exactly one
  element) but is the documented behavior for future callers.
- **Settles after each click**, not just the last one, via
  `page.waitForTimeout(clickSettleMs)`, default 400ms.

## Verified selector (task 11)

```
[data-plat="md"] div:has(> span[data-icon]:text-is("fingerprint"))
```

This is the candidate from `solution.md` section 1 (KD2), run exactly
as-is with no adjustment. It matched exactly **one** element on the
`gallery` screen (android/`[data-plat="md"]` frame, dark theme, `vi` locale)
and successfully opened the `galleryOpen` `<sc-if>` state
(`Cupid Screens.dc.html` actual L744-759 per KD1's corrected line table).
See `test-results.md` section 6 for the full command and visual confirmation.

Do not key this selector on `unlockLabel` text — it differs by platform and
locale (`Cupid Screens.dc.html:2289`); the `fingerprint` icon glyph and the
`[data-plat="md"]` frame prefix are what make it stable and unambiguous.

## One-frame caveat (KD3)

A click is scoped to whatever frame its selector matched. This canvas mounts
independent component state per frame (`Cupid App.dc.html:239` `side="a"
platform="ios"`, L251 `side="b" platform="md"`); `unlock(side)` only opens
the side that was clicked. Consequence for callers: `--platform=all` with a
single frame-scoped `--click` (e.g. the `[data-plat="md"]`-prefixed selector
above) leaves the other frame in its unclicked state — one PNG will show
`galleryOpen`, the other `galleryLocked`, with no error. Callers that need
both frames open must pass one selector per frame. This is documented in the
tool's own usage block, not special-cased in code — the flag stays generic.

## R1 outcome — prototype FAB after re-render

Handling per phase-P0 task 10 / solution.md section 4 (R1): verify before
coding, don't pre-emptively add a re-hide pass. Verified: the screen-index FAB
(`design-fidelity-config.json` `design_source.hide_selectors`,
`[data-plat] [style*="z-index: 95"]`) does not appear in either the pre-click
(`galleryLocked`) or post-click (`galleryOpen`) render of the `gallery`
screen — full corner-by-corner visual inspection in `test-results.md` section
6. **No additional code was added.** The existing unconditional hide pass
(runs once, before the `--screen` click) is sufficient; `doUnlock`'s
re-render does not recreate the FAB node in this bundle export.

## Not implemented

- No strict-mode ambiguity enforcement (explicitly out of scope per phase-P0
  task 5 — echoing the match count is enough).
- No gated re-hide-after-click pass (R1 verified unnecessary; adding it
  without reproducing the failure would be exactly the "pre-emptively code"
  phase-P0 task 10 forbids).
