# STORY-060 UX Disposition: Contract Decorative Particle Dots

Answers OQ-060 in `requirements/requirements.md`. Covers AC1 only (this
disposition is "ship it", so AC2 is also addressed via the append described
below; AC3 does not apply).

## Disposition: SHIP IT (option a — static, unconditional design element)

## Direct canvas-source inspection (not PNG-only)

Source file: `cupid-app-design-system/project/Cupid Screens.dc.html`.

First, I read the `contract` screen's own template in full
(`<sc-if value="{{ isContract }}" ...>` block, lines 129-168: header band
lines 132-136, clause-row loop lines 137-151, sign CTA lines 152-167). It
contains **zero** dot/particle markup of its own — the header band, clause
rows, and CTA have no decorative dot elements authored inside them.

The three dots instead live at lines 44-47, at the very top of the shared
root app-shell wrapper, **before** the `showHeader` conditional (line 49) and
structurally outside/above every screen's own `sc-if` block, including
`isContract` (line 129):

```html
<div data-plat="{{ platAttr }}" style="height:100%;...;position:relative;overflow:hidden">
<div style="position:absolute;top:14%;left:8%;width:6px;height:6px;border-radius:50%;background:#fff;opacity:.5;animation:twinkle 3.4s ease-in-out infinite;pointer-events:none"></div>
<div style="position:absolute;top:9%;right:16%;width:4px;height:4px;border-radius:50%;background:#FFD9EA;animation:twinkle 4.6s ease-in-out .8s infinite;pointer-events:none"></div>
<div style="position:absolute;top:26%;right:7%;width:5px;height:5px;border-radius:50%;background:#CEB4FF;animation:twinkle 5.2s ease-in-out 1.6s infinite;pointer-events:none"></div>

<sc-if value="{{ showHeader }}" hint-placeholder-val="{{ true }}">
...
```

Each dot references `@keyframes twinkle{0%,100%{opacity:.25;transform:scale(.85)}50%{opacity:1;transform:scale(1.15)}}`
(line 35) — a continuous opacity/scale pulse — and `pointer-events:none`.
Grep for `twinkle` across the whole file returns only these four lines (the
keyframe definition plus the three usages); there is no plat-specific or
screen-specific override that hides them.

### Position match against the finding

Using a standard mobile viewport (~375x812, `--safe-top:54px` on iOS):

- `top:14% left:8%` (`#fff`, pure white) ≈ y=114px, x=30px — matches "above
  the `L` of the display title" (`contract` header title `Love Contract`
  sits at ~x=36px [16px screen padding + 20px card padding], y≈116-146px
  [54 safe-top + 18 outer padding + 22 card padding + label line + margin]).
- `top:9% right:16%` (`#FFD9EA`) ≈ y=73px — matches "header band top-right"
  (header band top edge = 54+18=72px ≈ 8.9%).
- `top:26% right:7%` (`#CEB4FF`) ≈ y=211px — matches "right of the `§1`
  marker" (first clause row, after the header block).

Only the first dot is literally `#fff`; the other two are pale pastel tints
(`#FFD9EA`, `#CEB4FF`) at 4-5px size. The `twinkle` animation drives opacity
up to `1.0` and scale up to `1.15` at its peak frame, so a static screenshot
captured near peak-opacity reads these small pale dots as "white" — this is
consistent with the reviewer's "three small white decorative particle dots"
description of the static PNG (RWB-20260816-028 / STORY-056 finding DEF-1),
without requiring all three to be literally `#fff` in source.

## Reasoning

These divs are **not** gated behind an interactive-canvas-only rendering
path, and are **not** injected by the `.dc.html` authoring harness outside
the screen-content tree (e.g. ruler marks, artboard chrome) — they are
literal sibling `<div>` markup inside the same `data-plat` container that
holds every screen's rendered content, unconditional (no `sc-if` wraps
them), so they are present in the DOM for every screen state and every
capture. That is exactly the option-(a) test in `requirements.md`: "a static
design element the design canvas author intended to render in every
state/capture." Using a continuous CSS keyframe animation as the rendering
technique does not make an element "canvas-only" (option b) — option (b)
requires the layer to exist only in the interactive authoring tool, never as
a fixed part of the screen's own markup. Here the dots are a fixed part of
the markup; only their opacity/scale animate.

**Important scope correction:** these dots are not `contract`-local. They
are authored once, at the shared root app-shell level, structurally above
and outside every individual screen's `sc-if` block (`isContract` included).
Per the design canvas source, they render on literally every screen in the
app as a persistent ambient background decoration, not as `contract`-specific
content. This confirms requirements.md's Generalization-note hypothesis at
the source level — not merely "possibly recurring elsewhere," but
structurally shared by construction across every screen this canvas
renders.

## Generalized rule (per requirements.md Generalization note)

When a design canvas source (`.dc.html`) renders decorative particle/dot
markup as literal, unconditional sibling elements of the shared app-shell
root — i.e., positioned outside any screen-specific `sc-if`/conditional
block — that markup is a static, always-on design element intended to ship
on every screen, even when implemented with a continuous CSS keyframe
animation (e.g., a twinkle/pulse effect) rather than a fixed opacity value.
CSS animation alone does not make an element "canvas-only" or an authoring-
tool artifact; only markup that is genuinely outside the screen's rendered
content tree (harness/tool chrome layered around the interactive canvas,
not inside the same container the screen content lives in) qualifies as a
canvas-only artifact under OQ-060 option (b). Decorative elements that ARE
scoped inside an `sc-if`-gated screen block, or driven by canvas-tool-only
interaction state, still need this same source-level check on their own
terms before assuming ship parity — do not assume presence-in-PNG alone
settles it either way.

## AC2 text (appended to `requirements/requirements.md`)

See the concrete AC2 bullet added to that file's Acceptance Criteria list.
It names the `contract` screen id explicitly per AC2's requirement, and
flags the confirmed cross-screen/shared-root scope for Tech Lead so
implementation is not misscoped as a `contract`-only widget.

## Addendum: particle container box disposition (answers `review/review-report.md` B-1)

Does not reopen the SHIP IT disposition above. This addendum answers a
narrower question the original spec did not cover: which box the particle
layer's percentage coordinates should be measured/positioned against.

### Disposition: Route 2 — ACCEPTED DIFFERENCE

The full-screen mount (`CupidAppBackground` at `MaterialApp.builder`,
`StackFit.expand` over the physical `0..900` screen) is the faithful reading
of the canvas source. The design reference renderer's phone-chassis inset
(`y ∈ [47.5, 867]`, a ~47px top / ~33px bottom band matching a mockup status
bar + gesture bar) is a rendering-harness artifact, not design intent. No
mobile code change is required for this finding; the current shell-level
mount stands as-is.

### Evidence

`cupid-app-design-system/project/Cupid Screens.dc.html:44-50`:

```html
<div data-plat="{{ platAttr }}" style="height:100%;...;position:relative;overflow:hidden">
<div style="position:absolute;top:14%;left:8%;...background:#fff;..."></div>
<div style="position:absolute;top:9%;right:16%;...background:#FFD9EA;..."></div>
<div style="position:absolute;top:26%;right:7%;...background:#CEB4FF;..."></div>

<sc-if value="{{ showHeader }}" hint-placeholder-val="{{ true }}">
<div style="flex:none;padding:var(--safe-top) 16px 12px;...">
```

The source defines exactly one box for this subtree: the root `height:100%`
div. The three particle divs are direct siblings of that root, positioned by
percentage against it, unconditional and above the header's own `sc-if`
block. Critically, the source's own idiom for expressing the safe area is
`padding: var(--safe-top) ...` applied locally on the header element (line
50) — not an inset, margin, or reduced height applied to the shared root
box the particles read their percentages from. If the canvas author had
intended the particle layer's coordinate space to exclude the status bar and
gesture bar, the safe-area accommodation would have been expressed at the
root-box level (where the particles, and everything else, would inherit it),
not scoped to the header alone. It is not: only the header pads itself,
because only the header renders visible content that must clear the status
bar. The particle layer has no such accommodation in source, and there is no
second, inset box definition anywhere in this subtree for it to read
against.

This reading is corroborated by the reviewer's own content-alignment check
in B-1: elements that ARE positioned below the header's `var(--safe-top)`
padding (app-bar title, display title) measure aligned within 3px between
reference and implementation, while only the percentage-based particle layer
— which reads directly off the un-padded root box — shows the 27-41px
offset. That is the signature of a renderer overlaying phone-mockup chrome
(status bar, gesture bar) on top of a flat HTML canvas that itself defines
no such inset, not the signature of a second coordinate space authored into
the source. This is the same category of artifact previously dispositioned
in STORY-010/STORY-047 (`profile` avatar dashed-ring — Claude Design
authoring-tool chrome, not product UI): a difference introduced by the
design tool's rendering/mockup layer, external to the `.dc.html` markup
itself.

### Measured deltas (from `review/review-report.md` B-1, restated per the reviewer's request)

| Particle | Reference centre | Implementation centre | Δx | Δy |
|---|---|---|---|---|
| `#FFD9EA` (`right 16%`, `top 9%`) | `(332.7, 123.3)` | `(337.5, 82.5)` | `+4.8` | `−40.8` |
| `#CEB4FF` (`right 7%`, `top 26%`) | `(367.8, 263.2)` | `(373.5, 236.1)` | `+5.7` | `−27.1` |
| `#FFFFFF` (`left 8%`, `top 14%`) | `(42, 165)` | `(36, 130)` | `−6` | `−35` |

Δx is within measurement tolerance on all three (≤6px); Δy (27-41px) is
fully explained by the reference renderer's ~47px top / ~33px bottom
chassis inset applied to a box the source itself defines as full-height.

### Required follow-up (not performed here, forbidden by this handoff's scope)

`mobile-dev` must correct `visual-fidelity/visual-fidelity-report.md`:
replace its `VISUAL_FIDELITY: PASS` verdict's false justification (the
claim that this inset is "equally present in STORY-039's, STORY-049's,
STORY-056's, and STORY-057's approved pairs" — B-1 shows this precedent
claim does not transfer, since this is the first story with
percentage-of-container-positioned elements) with an explicit ACCEPTED
DIFFERENCE entry in the `Deviations` section, in the same format as
`STORY-047_pairing_chain_deviation_triage/visual-fidelity/visual-fidelity-report.md`
Deviation items 1-5: one-line bolded summary, citation to this addendum as
the governing disposition, and the measured deltas table above.
