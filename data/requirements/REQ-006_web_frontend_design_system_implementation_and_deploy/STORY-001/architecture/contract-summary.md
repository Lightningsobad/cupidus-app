# Cross-Lane Contract — REQ-006 Web Shell, Routes, and Design Tokens

Authoritative source: `web/` (STORY-001).
Consumers: `web/` STORY-002…STORY-008 (each builds one page body inside this
shell and must not modify it).

## 1. Envelope

The contract is the file layout and the DOM/CSS conventions of the `web/` Astro
workspace, not a wire format. A consumer story adds **one** page body and
nothing else.

```astro
---
// web/src/pages/pets.astro  (STORY-002)
import SiteLayout from "../layouts/SiteLayout.astro";
---
<SiteLayout page="pets">
  <!-- page body only: sections copied verbatim from Cupid Web.dc.html -->
</SiteLayout>
```

- `SiteLayout` renders `<html>`, `<head>` (both Google Fonts links), `<body>`
  with `data-theme="dark" data-lang="vi"`, the theme/lang boot script, the
  nebula backdrop, `<SiteHeader>`, `<main><slot/></main>`, and `<SiteFooter>`.
- The `page` prop is the route key. It drives the header's active-pill styling
  and the mobile `<select>`'s selected option.
- Mismatch behavior: an unknown `page` value is a **build-time** TypeScript
  error (the prop is a string-literal union), not a silent no-highlight page.

## 2. Identifiers — copy exactly

| Purpose | Identifier | Bound config key / route |
|---------|------------|--------------------------|
| Home | `home` | `/` (`web/src/pages/index.astro`) |
| Pet universe | `pets` | `/pets` |
| Zodiac | `zodiac` | `/zodiac` |
| Pairing invite | `share` | `/share` |
| Blog | `blog` | `/blog` |
| About + press kit | `about` | `/about` |
| Support | `support` | `/support` |
| Privacy + Terms | `legal` | `/legal` |
| Theme storage | `cupid-web-theme` | `localStorage`, values `dark` \| `light` |
| Language storage | `cupid-web-lang` | `localStorage`, values `vi` \| `en` |
| Theme attribute | `data-theme` | on `<body>` |
| Language attribute | `data-lang` | on `<body>` |

Rules for the consumer side:

- Route keys are the design source's own `startPage` enum values. `share` is the
  Invite page — do not rename the route to `/invite` to match the English label.
- `about` serves both the About nav item and the footer "Press kit" link. Do not
  add an `/press-kit` route.
- `legal` serves both footer "Privacy" and "Terms" links. Do not split it.
- Do not add a new `localStorage` key. Do not rename `data-theme`/`data-lang`;
  the whole token system and every bilingual span selector are bound to them.

## 3. Bilingual text — the only supported mechanism

| Order | Key | Rendered/exposed as | Value contract |
|-------|-----|---------------------|----------------|
| 1 | `data-vi` | `<span data-vi>Tiếng Việt</span>` | visible only when `body[data-lang="vi"]` |
| 2 | `data-en` | `<span data-en>English</span>` | visible only when `body[data-lang="en"]` |

- Both strings ship in every page's HTML; CSS in `global.css` toggles them
  (`[data-vi],[data-en]{display:none}` plus the two `body[data-lang=...]`
  rules). This is the design source's own mechanism, copied verbatim.
- Every user-visible string needs **both** spans. A string with only `data-vi`
  disappears entirely in EN — no fallback, no build error, silent blank.
- Strings are copied verbatim from the design source. Do not paraphrase,
  re-translate, fix typography, or normalize quotes or dashes.
- Do not introduce an i18n library, a JSON message catalog, or locale-prefixed
  routes.

## 4. Design tokens and styling

- `web/src/styles/tokens.css` holds the full custom-property set, copied from
  `Cupid Web.dc.html:16` (`body{}`, dark) and `:17`
  (`body[data-theme="light"]{}`, light). Consumers **read** tokens
  (`var(--acc-pink)`, `var(--surf)`, `var(--c68)`, …); consumers never add,
  rename, or redefine one. A page needing a color the token set lacks is a
  finding to report, not a token to invent.
- Page bodies use verbatim inline `style="..."` attributes from the design
  source. Hover states become one scoped CSS `:hover` rule per element, in that
  component's own `<style>` block.
- Reusable components already built by STORY-001 and available to consumers:
  `web/src/components/sprites/{Bo,Bun,Kem,Mochi,Sua,Xoai}Sprite.astro`.
  STORY-002 must check whether these cover its needs before authoring new SVG.

## 5. Deploy / rollout order

STORY-001 must be merged before any consumer story starts: it creates the
workspace, the layout, the tokens, and all 8 route files. A consumer story
started first has no `SiteLayout` to import — a loud build failure, not a silent
one. Consumer stories replace the body of a route file that already exists; none
of them creates a route.

## 6. What the consumer must NOT do

- Modify `SiteLayout.astro`, `SiteHeader.astro`, `SiteFooter.astro`,
  `tokens.css`, `global.css`, or the theme/lang boot script. A shell change
  needed by one page is a finding for Tech Lead, because it silently re-renders
  the other seven pages and invalidates their fidelity evidence.
- Add a header nav item, a footer column, or a footer link.
- Add a `localStorage` key, a cookie, a service worker, or any `fetch`/API call
  — REQ-006 is static (OQ-REQ006-2 RESOLVED).
- Introduce a second styling system (Tailwind, CSS modules with rewritten
  values, a UI kit) alongside the verbatim inline styles.
