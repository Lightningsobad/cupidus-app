# Cross-Story Contract — REQ-006 Per-Page Title And Page Content Modules

Authoritative source: `web/` (STORY-002).
Consumers: `web/` STORY-003…STORY-008 — every remaining page story needs a
per-page `<title>` (the DEF-2 carry-forward applies to all of them, not only to
Pets) and every one of them adds page content data.

This extends, and does not replace, STORY-001's
`../../STORY-001/architecture/contract-summary.md`. Where the two overlap, the
STORY-001 shell contract wins.

## 1. Envelope

```astro
---
// web/src/pages/<route>.astro
import SiteLayout from "../layouts/SiteLayout.astro";
---
<SiteLayout page="<routeKey>" title="<EN page label> — Cupid">
  <!-- page body only -->
</SiteLayout>
```

`SiteLayout` already declares `title?: string` (default `'Cupid'`) and
`description?: string`. No shell change is needed to set a page title, and none
is permitted.

## 2. Per-page `<title>` — copy the shape exactly

| Route key | `title` value |
|-----------|---------------|
| `pets` | `Pets — Cupid` |
| `<other>` | `<EN header-nav label for that route> — Cupid` |

Rules:

- The label is the route's **EN header-nav label**, so the title matches what a
  visitor clicked. Separator is an em dash with a space on each side.
- The title is **EN only, in both language states**. `<title>` is a plain string
  in the static HTML, while VI/EN switching is CSS-only over paired
  `data-vi`/`data-en` spans. A bilingual title would require adding JS to the
  shell boot script, which STORY-001's contract forbids. Do not invent a
  workaround; do not file it as a per-page defect.
- Omitting `title` is a silent defect, not a build error: the page renders the
  site-wide `Cupid` default and fails its own DEF-2 acceptance criterion.
- `description` is optional and unscoped. If you pass it, it is EN-only for the
  same reason.

## 3. Page content data modules

| Module | Owner story | Exports | Consumable by other pages |
|--------|-------------|---------|---------------------------|
| `web/src/data/home-content.ts` | STORY-001 | `features`, `pets`, `steps` | `pets` — YES |
| `web/src/data/pets-content.ts` | STORY-002 | `stages` | YES |

- `pets` in `home-content.ts` carries all six pets with `bg`, `color`,
  `tvi`/`ten`, and `dvi`/`den` transcribed from `Cupid Web.dc.html:741-747`.
  Any page needing pet data **imports it**. Copying the array into a second
  module means BR-2 verbatim copy now has two sources that can drift.
- One data module per page story, named `<route>-content.ts`. Add your own
  exports there; do not append page-specific arrays to another story's module.
- `home-content.ts` is a misnomer once `pets` is shared. Renaming it edits Home's
  components and invalidates STORY-001's fidelity evidence, so it is deliberately
  deferred — do not rename it opportunistically inside a page story.

## 4. What the consumer must NOT do

- Add, rename, or remove a prop on `SiteLayout` to serve one page's title need.
- Emit a `<title>` from inside a page body or a component `<head>` fragment.
- Duplicate another story's content array instead of importing it.
