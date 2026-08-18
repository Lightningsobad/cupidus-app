# Tool Contract — `--scroll` Below-The-Fold Capture, and the Post-Screen `--hide` Re-Apply

- Tool: `.ai-team-bundle/runtime/tools/render-design-canvas.js`
- Story: STORY-054 (RWB-20260816-020)
- Lane: devops
- Durability: this file and `render-design-canvas-scroll.patch` are the durable,
  reviewable deliverables. The tool file is gitignored (`.gitignore:5`,
  confirmed by `git check-ignore -v`), so the working change is applied in place
  and uncommitted — same boundary STORY-044 established
  (`STORY-044.../coding-plan/tool-contract-click-flag.md`).

## Flag signature

```
--scroll=<px>          scroll the frame's body to an explicit pixel offset
--scroll=end           scroll to the bottom of the frame's scrollable content
--scroll-settle-ms=<ms>  optional, default 300
```

One flag, two value forms, rather than a separate `--scroll-to-end`: both modes
address the same element and differ only in the target offset, so a second flag
would add a mutually-exclusive pair for callers to get wrong. `end` is spelled
as a value, case-insensitive.

`--scroll` is **last-wins**, not repeatable. It is deliberately absent from
`MULTI_VALUE_KEYS` (which still contains only `click`): a frame has one scroll
position, so accumulating values would have no meaning.

### Accepted values

| Value | Behavior |
| --- | --- |
| `end` (any case) | scroll to `scrollHeight - clientHeight` |
| a non-negative number | scroll to that offset, clamped to the bottom |
| a negative number, non-numeric text, or bare `--scroll` | `DESIGN_CANVAS_SCROLL_VALUE_INVALID` |

Clamping is intentional and **not** an error: `--scroll=5000` on a screen with
207px of overflow lands at 207px and prints
`scroll: android frame at 207px of 207px on <div> (requested 5000px, clamped to the bottom)`.
That is what a real scroll gesture does, and the stderr line makes the
difference between requested and applied visible rather than silent.

## Ordering guarantee

```
theme/lang toggles
  -> freeze-animations
  -> hide (pass 1)
  -> --screen click
  -> hide (pass 2, re-apply + strict check)      <- new
  -> --click pass
  -> --scroll pass                               <- new
  -> shutter (platform screenshot loop)
```

`--scroll` is the **last** step before the shutter. That placement is load-bearing
three times over:

1. It is after the `[data-screen-btn]` click, so the scroll is not discarded by
   the screen re-render.
2. It is after the `--click` pass, so a click that expands in-frame content is
   included in the scrollable height.
3. It is after both hide passes, because hiding elements changes `scrollHeight` —
   scrolling first would compute `end` against a height that includes chrome the
   image will not contain.

The scroll pass runs for **every** wanted platform frame up front, before the
screenshot loop writes anything. A frame that cannot be scrolled therefore fails
with no PNG on disk, including under `--platform=all` where the first frame
would otherwise already have been written.

## What gets scrolled

The canvas does not advertise which node scrolls, so the tool discovers it per
frame: every descendant of `[data-plat="ios"]` / `[data-plat="md"]` whose
`scrollHeight - clientHeight > 1` and whose computed `overflow-y` is not
`visible` or `clip`, ranked by overflow, largest first.

Each candidate is then **proven by assignment** rather than trusted on its
computed style: the tool sets `scrollTop` to the overflow and reads it back, and
takes the first node that actually moves. A clipped decoration can report
overflow and ignore `scrollTop`; ranking alone would pick it and produce an
unscrolled image with a success exit code.

Because the scroll target is inside the device frame and the shutter captures the
frame element, the bezel, the frame chrome, and the PNG dimensions are identical
to an unscrolled render — verified in `test-results.md` section 3.

Under `--platform=all` each frame is discovered and scrolled independently, so
the two frames may land at different offsets (`timeline`: ios 260px, android
207px). This is correct — the frames have different viewport heights — and it is
**not** the one-frame caveat that applies to `--click` (KD3 in
`tool-contract-click-flag.md`), because `--scroll` is not selector-scoped.

## `--hide` re-apply after the screen change

`--hide` values plus `design_source.hide_selectors` are now applied twice: once
where they always were, and again immediately after the `[data-screen-btn]`
click. Pass 1 is unchanged in placement, matching, and messaging.

**On the 2026-08-11 export the re-apply hides nothing new.** The `[data-screen-btn]`
click does not resurrect the hidden node — proven by DOM identity, not inferred:
the nodes matched after the click are the *same* nodes pass 1 hid, still
`display: none` (`test-results.md` section 5). RWB-20260816-020's claim that
`--hide` selectors "do not survive the screen re-render" does not reproduce on
this export.

The pass is kept anyway for a reason that is not defensive coding: **it is the
only truthful place to run AC4's hide check.** Whether the shutter will capture
prototype chrome is a question about post-click state. Asking it before the
click, as pass 1 does, answers a different question, and would keep answering
"fine" on the export where the claim finally does reproduce. The hiding action
is currently redundant; the verification action is not.

## Typed failure codes

All follow the `DESIGN_CANVAS_CLICK_TARGET_MISSING` precedent: named cause,
exit 1, **no PNG written**.

| Code | Raised when |
| --- | --- |
| `DESIGN_CANVAS_SCROLL_VALUE_INVALID` | `--scroll` is not `end` and not a non-negative number |
| `DESIGN_CANVAS_SCROLL_TARGET_MISSING` | no node inside a wanted frame both overflows and responds to `scrollTop` |
| `DESIGN_CANVAS_HIDE_TARGET_MISSING` | a hide selector matched zero elements in the post-screen-click pass |

`DESIGN_CANVAS_HIDE_SELECTOR_INVALID` (pre-existing) is now also raised from the
re-apply pass, with unchanged wording.

### Hide strictness is per selector, not per total

`applyHides` returns one match count per selector rather than a sum. A stale
selector hides behind a working one in a total: the sum stays positive and the
chrome that selector was meant to remove ships anyway. The failure message names
only the selectors that matched nothing.

This is the one place STORY-054 makes an existing command stricter. A render that
today passes `--hide=<stale>` alongside a selector that still matches gets a PNG
with a warning; after this change it exits 1. That is exactly the case AC4 names
("a `--hide` selector matching nothing") and the outcome AC4 exists to force — a
chrome-bearing reference that a later story records `VISUAL_FIDELITY: PASS`
against is worse than no reference. Pass 1 keeps its warning-only behavior, so a
render with no `--screen` is unaffected.

## Known-stale note elsewhere in the repo

`data/devops/system/design-fidelity-config.json` `hide_selectors_note` ends with
"if a future export moves it, render-design-canvas.js **warns** that the selector
matched nothing". After this story that is a hard failure for any render that
passes `--screen`. The config was left untouched (out of this story's scope and
the design source is `locked: true`); correcting that sentence is a follow-up.

## Not implemented

- No per-screen scroll-target selector override. Discovery-by-proof has not
  needed one on any screen tested; adding a `--scroll-selector` before a screen
  defeats discovery would be speculative.
- No horizontal scroll. Nothing in RWB-20260816-020 or the canvas needs it.
- No re-hide after the `--click` pass. STORY-044's R1 already verified the FAB
  does not return after a click, and this story's probe re-confirms the node
  survives re-renders intact.
