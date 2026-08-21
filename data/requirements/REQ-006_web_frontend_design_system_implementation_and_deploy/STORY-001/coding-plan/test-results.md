# STORY-001 Test Results

## Phase P1 — App Scaffold And Design Token Foundation

- Date: 2026-08-21
- Lane: Frontend
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-001`
- Result: PASS

### Runtime note (input for P6 / DevOps)

The scaffold resolved `astro@6.0.5`, which enforces `node >=22.12.0`. The
machine default `node` is `v20.20.2`, and Astro refuses to run on it:

```
$ npm run build          # under node v20.20.2
> astro build
Node.js v20.20.2 is not supported by Astro!
Please upgrade Node.js to a supported version: ">=22.12.0"
EXIT=1
```

All gates below were therefore run under `node v22.17.1` (already installed at
`~/.nvm/versions/node/v22.17.1`). The floor is recorded as `engines.node:
">=22.12.0"` in `web/package.json`, taken from Astro's own error message rather
than asserted from memory. P6 must pin the same floor in the CI workflow and the
runtime registry entry for `web-frontend`.

### Gate 1 — frontend build (`cd web && npm run build`)

```
> astro build
17:25:55 [types] Generated 16ms
17:25:55 [build] output: "static"
17:25:55 [build] mode: "static"
17:25:55 [build] directory: .../web/dist/
17:25:55 [build] Collecting build info...
17:25:55 [build] ✓ Completed in 19ms.
17:25:55 [build] Building static entrypoints...
17:25:55 [WARN] [vite] "matchHostname", "matchPathname", "matchPort" and "matchProtocol" are imported from external module "@astrojs/internal-helpers/remote" but never used in "node_modules/astro/dist/assets/utils/index.js".
17:25:56 [vite] ✓ built in 403ms
17:25:56 [vite] ✓ built in 3ms
17:25:56 [build] Rearranging server assets...
17:25:56 [build] ✓ Completed in 431ms.
17:25:56 [build] 0 page(s) built in 451ms
17:25:56 [build] Complete!
BUILD_EXIT=0
```

Exit code 0. `output: "static"` / `mode: "static"` confirmed. `0 page(s) built`
and an empty `dist/` are expected at P1: route files are P3's write scope, so no
HTML entrypoint exists yet. The one `[WARN]` is an unused-export notice emitted
from inside `node_modules/astro`, not from this workspace.

### Gate 2 — type check (`npx astro check`)

```
17:25:57 [types] Generated 19ms
17:25:57 [check] Getting diagnostics for Astro files in .../web...
Result (2 files):
- 0 errors
- 0 warnings
- 0 hints
CHECK_EXIT=0
```

Exit code 0.

### Gate 3 — token-parity diff (risk surface: Design token parity)

Method: split each rule body on top-level `;` (parenthesis-aware, so the
multi-stop `--nebula` gradients stay intact), then `diff` the source
declaration list against the ported one in order.

| Block | Source | Ported | Src decls | Ported decls | Order-sensitive diff |
|-------|--------|--------|-----------|--------------|----------------------|
| Dark base | `Cupid Web.dc.html:16` | `tokens.css` `body{}` | 58 | 58 | IDENTICAL |
| Light override | `Cupid Web.dc.html:17` | `tokens.css` `body[data-theme="light"]{}` | 52 | 52 | IDENTICAL |

```
== diff dark (order-sensitive, name+value) ==
IDENTICAL
== diff light (order-sensitive, name+value) ==
IDENTICAL
```

Zero missing, zero added, zero altered, zero reordered declarations in either
block. The dark block's 58 declarations are 52 custom properties plus the 6
non-custom declarations the source's `body` rule carries (`margin`,
`background`, `color`, `font-family`, `-webkit-font-smoothing`, `transition`).

Light-vs-dark custom-property name sets:

```
custom props dark: 52  light: 52
-- names in light but NOT in dark (must be empty):
-- names in dark but NOT overridden in light:
```

Both comparisons are empty: the light block overrides exactly the property-name
set the dark block defines — no more, no fewer.

### Gate 4 — no `:root` indirection, exact selectors

```
== tokens.css selectors ==
body
body[data-theme="light"]
== grep ':root' in tokens.css (must be empty) ==
grep-exit=1 (1 = no match, expected)
```

`tokens.css` contains exactly the two required selectors and no `:root` rule, so
a page with no JavaScript renders the dark theme from the bare `body` rule
(AC-2, and Key Discovery #3 in `architecture/solution.md`).

### Gate 5 — `global.css` port (risk surface: Nav breakpoint hard swap)

Byte-diff of source lines 18–27 against `global.css` (excluding the one-line
provenance comment):

```
== global.css byte-diff vs source lines 18-27 (skip provenance comment) ==
IDENTICAL
== nav media queries verbatim ==
@media (max-width:1024px)  -> 1 occurrence
@media (min-width:1025px)  -> 1 occurrence
== bilingual rules ==
3 [data-vi]/[data-en] rules
```

Both nav media queries carry the exact 1024px/1025px boundaries with no extra
breakpoint, and the three bilingual visibility rules are unchanged (AC-4,
`architecture/contract-summary.md` §3).

### Gate 6 — no client framework / CSS framework in the dependency tree

```
== direct deps ==
cupid-web@0.0.1 .../web
├── @astrojs/check@0.9.10
├── astro@6.0.5
└── typescript@5.9.3

== client/CSS framework scan over the full installed tree (expect 'not found') ==
cupid-web@0.0.1 .../web
└── (empty)
```

`npm ls react react-dom vue svelte solid-js preact tailwindcss bootstrap --all`
returned `(empty)`: none of them is present anywhere in the installed tree, not
just absent from direct dependencies. Direct dependencies are Astro and its
TypeScript tooling only. All three versions were resolved by the installer and
recorded in `web/package-lock.json`; none was hand-pinned (AC-1,
`architecture/solution.md` §6).

### Acceptance criteria status

| AC | Statement | Evidence | Status |
|----|-----------|----------|--------|
| AC-1 | `web/` builds to static HTML with no client framework in the dependency tree | Gate 1, Gate 6 | PASS |
| AC-2 | `tokens.css` selectors are exactly `body` and `body[data-theme="light"]` | Gate 4 | PASS |
| AC-3 | Every custom property in `Cupid Web.dc.html:16` exists in `tokens.css`, identical value, none added/renamed/reordered | Gate 3 | PASS |
| AC-4 | `global.css` has both nav media queries at exact boundaries and the three `[data-vi]`/`[data-en]` rules unchanged | Gate 5 | PASS |

No blockers. `DESIGN_TOKEN_PARITY_UNVERIFIABLE` did not trigger.
