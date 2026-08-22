
# UI/UX Specification - Pet Universe Showcase Page (REQ-006 / STORY-002)

## 1. Metadata

- Related Story: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-002/story_master.md`
- Source Requirement Paths: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/req_master.md`, `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-002/requirements/requirements.md`
- Target Directory: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-002/ux/`
- Mode: Extension (reuses STORY-001's shared shell verbatim; adds one new page body)
- Status: Draft
- System UX Memory Path: `data/ux/system/ui_ux_system_memory.md`
- System UX Memory Action: Read Only (this run) — that memory file documents `Cupid Mobile (REQ-001)` only (Flutter app, different design source); not applicable to this web page beyond the shared brand tokens already carried into STORY-001's spec. No update needed from this story.

## 2. Context Summary

- User goal: a visitor evaluating the app opens the Pets page to see what the 6 pet characters are like and how they grow, before deciding to download.
- Primary user mode: First-time or returning-exploring (reached via header/footer nav or the Home "Meet them all" CTA from STORY-001).
- Business outcome: emotional connection to the "raise a pet together" mechanic, supporting download conversion.
- Existing specs reviewed: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-001/ux/uiux-spec.md` (shared shell, tokens, typography system, route map).
- Existing UI patterns found: STORY-001 §6.1 Global Shell (header/footer, sticky nav, theme/language toggle) — reused unmodified. STORY-001 §6.2.3 "Pet-cast teaser" card pattern (sprite + name + trait label, no description) exists on Home but is explicitly a *different, smaller* variant — STORY-001 §6.5 flagged that this story must confirm whether to extend that card or define a richer one. Decision below: **new "Pet Detail card" variant** (see §6.2.2) — the design source's Pets-page card is a distinct horizontal layout with a description line the Home teaser card does not have; reusing the teaser's compact vertical shape would drop content and deviate from the design source.
- Existing components reused or extended: Header, footer, theme toggle, language toggle, page-shell background (nebula/stars) — all reused unmodified from STORY-001 §6.1/§6.2. New: Pet Detail card, Growth Stage card (see §6.5).
- Current UX debt or consistency risks: none — this story stays inside the established shell and typography system.
- Current organization or hierarchy issues in the affected area: N/A.
- Stable shared patterns vs local debt: the three-typeface split (Nunito/Roboto/Roboto Mono) and fluid `auto-fit`/`minmax` grid convention from STORY-001 §6.7 apply here unchanged.
- Open Question Impact source: `STORY-002/requirements/requirements.md` `## Open Question Impact`.
- Open assumptions: none — the design source (`cupid-app-design-system/Cupid Web.dc.html`, `isPets` block, lines ~213-283) is a complete static block; `pets` data array (lines 741-747) and `stages` data array (lines 756-760) are read directly and quoted verbatim below.

## 3. Open Question Impact

- **OQ-REQ006-1** (frontend framework/stack — RESOLVED by STORY-001 Tech Lead, Astro static site): no UX impact; this spec is framework-agnostic markup/CSS/state, same as STORY-001.
- **OQ-REQ006-2** (backend API dependency — RESOLVED, static/marketing site): no UX impact; this page has zero interactive/API-bound state — see Business Rule BR-1 in requirements.md (no client-side persistence of a "selected" pet).
- No scope item on this page is BLOCKED (confirmed in requirements.md `## Open Question Impact` — both requirement-level OQs resolved, story scope depends only on already-DONE STORY-001 shell).

## 4. Requirement-To-Design Traceability

- **AC-1 (Navigation & routing)**: UX Response: reuse STORY-001 §6.1 Header/Nav "Pets" item — active-state styling (`background: rgba(255,127,182,.16)`, `color: var(--acc-pink)`, plus `aria-current="page"`) applies when the current route is `pets`, identical mechanism to Home's active state. Affected: header desktop nav, mobile `<select>`.
- **AC-2 (Hero content)**: UX Response: §6.2.1 Hero. Affected: new page body, top section.
- **AC-3 (Pet roster)**: UX Response: §6.2.2 Pet Roster Grid. Affected: new page body, 6-card grid.
- **AC-4 (Growth stages)**: UX Response: §6.2.3 Growth Stages Block. Affected: new page body, stage panel.
- **AC-5 (Theme & language parity)**: UX Response: no new logic — page content uses the same `[data-vi]`/`[data-en]` span pattern and inherits shell-level `document.body.dataset.theme`/`dataset.lang` from STORY-001 §6.4; every string below is quoted in both languages already. Affected: page body only (toggles themselves are shell-owned, unchanged).
- **AC-6 (Per-page title, DEF-2 carry-forward)**: UX Response: §6.6 Responsive And Accessibility Notes, document-title sub-note. Affected: `<title>` tag, not visually rendered.
- **AC-7 (Responsive layout)**: UX Response: §6.2.2/§6.2.3 grid rules + §6.6. Affected: pet-card grid, stage grid.
- **UI-Fidelity-AC (visual parity)**: UX Response: §6.2 (full page) + §6.7 Visual Acceptance Criteria / Design Anchor, sourced from `Cupid Web.dc.html:213-283`. Affected: entire Pets page body.

## 5. Critical User Tasks And Success Criteria

- **Learn what each pet is like and decide the app looks worth downloading for**:
  - User Mode: First-time or exploring.
  - Entry Point: header/mobile-select "Pets" nav item, footer "Pets" link (Product column), or Home's "Meet them all" CTA (all from STORY-001 shell — this story only needs to render the destination correctly).
  - Success Signal: visitor reads through multiple pet cards and the growth-stage explainer, then either uses the header "Get the app" CTA (routes to Home per STORY-001 §6.1) or navigates to another page instead of bouncing.
  - Primary Risk: if pet personalities read as generic or copy is truncated/paraphrased, the emotional hook (BR-2/BR-3 verbatim-copy rules) is lost and the page fails its only job — this is a copy-fidelity page, not an interaction-design one.

- First-use guidance or discoverability needs: none — page is self-explanatory (hero states the premise: "pick one pet, it grows through four stages").
- Completion or post-completion state: N/A — no selection/completion flow, page is presentational only (BR-1).
- Retry, edit, undo, or next-action behavior: N/A — no forms, no destructive actions.
- What would make the task feel unfinished or unsafe to the user: a missing/reordered/omitted pet card, placeholder copy, or a stage panel with fewer than 4 stages — all explicitly forbidden by AC-3/AC-4.

### 5.1 System Entry And Discoverability

- Existing surface, workflow, or state where the actor starts: any page on the site (shared header/footer nav is present everywhere) or an external link to `cupidus.app/pets` (or equivalent route).
- Required entry point, navigation item, CTA, or in-flow discovery path: header "Pets" nav item, mobile `<select>` "Pets" option, footer "Pets" link, Home's "Meet them all" CTA — all four already exist structurally from STORY-001; this story's only job is to make the `pets` route resolve to real content instead of an empty stub.
- Direct URL only acceptable per PO scope: YES — same treatment as Home; this is a public static page.
- If direct URL only is acceptable, UX treatment: the page must be self-explanatory without requiring the visitor to have seen Home first — hero copy (§6.2.1) carries that context on its own, matching the design source (no page assumes prior-page context).
- Entry point states: default only. No empty/loading/disabled state — content is always fully populated (6 pets, 4 stages), per requirements.md Edge Cases.
- Surfaces intentionally not updated: N/A.

## 6. UX Design

### 6.1 Global Shell (reused, no changes)

Reuse STORY-001 §6.1 Header and Footer verbatim — sticky header, desktop pill nav / mobile `<select>` swap at 1024/1025px, theme toggle, language toggle, "Get the app" CTA, and the full footer link grid. The only shell-level change this story introduces is which nav item renders as active: the "Pets" item (desktop pill and mobile `<select>` option) must carry the active treatment (`background: rgba(255,127,182,.16)`, `color: var(--acc-pink)`, `aria-current="page"`) whenever the current route is `pets`, exactly the same active-state mechanism STORY-001 built for Home. Do not duplicate header/footer markup or restyle them for this page.

### 6.2 Pets Page (`isPets` state, `Cupid Web.dc.html:213-283`)

**6.2.1 Hero** (`:214-219`)
- Layout: single column, `max-width: 640px`, section padding `70px 32px 90px` (note: taller top padding than Home's hero — this page has no two-column split, it is a simple stacked intro).
- Eyebrow label: plain text "Pet Universe" (Roboto Mono 11px, `letter-spacing:.14em`, uppercase, `color: var(--acc-lilac)`). **Not wrapped in `data-vi`/`data-en` spans in the design source — ships as the literal string "Pet Universe" in both VI and EN, same treatment as Home's un-localized download-badge lines (STORY-001 §6.2.1). Do not translate it.**
- H1: Nunito 900, 52px, `letter-spacing:-.03em`, `color: var(--ink)`, `margin: 10px 0 0`. VI: "Bé nào là bé của hai bạn?" EN: "Which one is yours?"
- Subcopy: 16px, `line-height:1.65`, `color: var(--c64)`, `margin: 16px 0 0`. VI: "Mỗi bé pet có tính cách, cách dỗi và cách đòi quan tâm riêng. Chọn một bé khi bắt đầu — bé sẽ lớn lên qua bốn giai đoạn theo cách hai bạn chăm nhau." EN: "Every pet has its own temper, its own sulk, its own way of asking for attention. Pick one at the start — it grows through four stages based on how you care for each other."

**6.2.2 Pet Roster Grid** (`:220-269`, data verbatim from `Cupid Web.dc.html:741-747`)
- Layout: `margin-top: 40px`, grid `grid-template-columns: repeat(auto-fit, minmax(330px, 1fr)); gap: 20px` — fluid reflow, no fixed breakpoint (same convention as STORY-001's grids).
- Card anatomy (**new "Pet Detail card" component** — distinct from Home's compact teaser card, see §6.5): `border: 1px solid var(--c11); border-radius: 30px; padding: 28px; display: flex; gap: 22px; align-items: center` — horizontal layout, sprite left (130×130px, `flex: 0 0 130px`), text block right (name, trait tag, description stacked).
  - Sprite: `dc-import`, **130×130px fixed — resolved design decision, re-verified 2026-08-22 against the composed `/pets` render (closes BLK-VF-1, supersedes the 2026-08-22 viewBox/`$preview`-only citation)**. `Cupid Web.dc.html:222` declares `<dc-import name="Bo Sprite" hint-size="130px,130px" style="width:130px;height:130px;flex:0 0 130px">`, identically repeated for all 6 pet sprites (`:222,230,238,246,254,262`) — three redundant declarations of the same 130px intent (`width`, `height`, `flex-basis`) plus an explicit `flex-shrink:0` to prevent exactly the shrink now in question; this redundancy is strong authorial signal, not an accident.
    Composed-context evidence (not the isolated component file): the committed `visual-fidelity/design-reference/design-reference-pets-1280.png` capture shows the "Bo" card's sprite occupying only ~73–74px of the 386.7px-wide grid column (3-up `auto-fit,minmax(330px,1fr)` at 1200px max-width, gap 20 → `(1200-40)/3`), even though the card's content box (330.7px after 28px padding) has ~178px of slack after a 130px sprite + 22px gap — i.e. there is no container-width pressure that would force a *legitimate* CSS flex-shrink here. This matches the 74.3px figure measured directly in-browser.
    Root cause (traced in `cupid-app-design-system/support.js`, the runtime `render-design-canvas.js` loads to resolve `<dc-import>`): `walk()` builds each `dc-import`'s host props via `__hostStyle: hostPositionStyle(styleGet(vals))` (support.js:676), and `hostPositionStyle()` (support.js:457-466) filters the inline `style` attribute down to an allowlist `HOST_STYLE_PROPS` (support.js:445-456) = `{position, left, right, top, bottom, inset, width, height, z-index, transform}`. `flex`/`flex-shrink`/`flex-basis`/`flex-grow` are **not** in that allowlist. Result: `width:130px;height:130px` survives onto the rendered `.sc-host` div (this is exactly why DevTools shows `sc-host` still declaring `width:130px` — the style is genuinely not dropped), but `flex:0 0 130px` is silently stripped, so the host's `flex-shrink` reverts to the CSS initial value `1`. With that default restored, the sibling text block's `flex:0 1 auto` content-based basis (no `min-width:0`) pulls the negative free space, and — because the sprite is no longer shrink-proof — the flex algorithm shrinks it down alongside the text, landing at the observed ~74px.
    **Conclusion: this is a `support.js` preview-tooling defect (its `HOST_STYLE_PROPS` allowlist is missing the `flex-*` properties), not a design-source flex-row bug and not a `PetRoster.astro` bug.** Neither `Cupid Web.dc.html`'s card CSS nor `PetRoster.astro:30`'s 130px sprite implementation should change — they already agree with each other and with the design's redundant 130px/flex-shrink:0 intent. The concrete tooling fix (out of scope for this UX spec and for `PetRoster.astro`; flag to DevOps/tooling owner) is to add `"flex"`, `"flex-shrink"`, `"flex-basis"`, `"flex-grow"` to `HOST_STYLE_PROPS` in `cupid-app-design-system/support.js:445-456` so `hostPositionStyle()` preserves authored flex-shrink intent on `dc-import` host nodes.
  - Recurrence note: any REQ-006 `dc-import` placed inside a real flex row that relies on an inline `flex`/`flex-shrink` declaration to stay unshrinkable is exposed to this same `support.js` `HOST_STYLE_PROPS` gap — e.g. this Pets-page pattern. `dc-import` usages inside a `display:grid;place-items:center` wrapper (Home's pattern, STORY-001 §6.2.3) are **not** exposed, since that layout never relies on flex-shrink to hold sprite size. Treat any future flex-row `dc-import` sprite/icon finding (including STORY-003's zodiac icons, if placed in a flex row rather than a grid wrapper) as the same root-cause family and re-check against this mechanism rather than assuming an aspect-ratio cause.
  - Name: Nunito 900, 26px, `color: var(--ink)`.
  - Trait tag: Roboto Mono 10px, `letter-spacing:.1em`, uppercase, `margin: 4px 0 10px`, color = that pet's accent color (see per-pet table below).
  - Description: 13.5px, `line-height:1.6`, `color: var(--c66)`.
  - Card background: a translucent tint unique per pet (see table) — this is the one visual property that differs card-to-card; everything else (border, radius, padding, layout) is identical across all 6 cards.
- Content, in exact design order (do not reorder, omit, or paraphrase — BR-2):

| # | Name | Card bg | Trait color | Trait VI / EN | Description VI | Description EN |
|---|------|---------|-------------|----------------|-----------------|-----------------|
| 1 | Bo | `rgba(255,127,182,.12)` | `var(--acc-pink)` | Trung thành / Loyal | "Vui là quẫy cả người. Bạn bỏ quên một ngày là Bo ngồi ngóng ở cửa." | "Wags with its whole body. Skip a day and Bo waits by the door." |
| 2 | Bun | `rgba(183,140,245,.13)` | `var(--acc-lilac)` | Nhút nhát / Shy | "Cần dỗ mới ra. Nhưng đã thân thì dính suốt ngày." | "Needs coaxing to come out. Once it trusts you, it never leaves." |
| 3 | Kem | `rgba(121,226,205,.12)` | `var(--acc-mint)` | Bình tĩnh / Calm | "Không bao giờ hoảng. Là bé phù hợp cho cặp hay cãi nhau lúc nửa đêm." | "Never panics. The right pet for couples who argue at midnight." |
| 4 | Mochi | `rgba(255,201,126,.13)` | `var(--acc-butter)` | Nghịch ngợm / Playful | "Đòi chơi cả ngày. Bỏ mặc là tự nghĩ ra thử thách cho hai bạn." | "Wants to play all day. Ignore it and it invents quests for you." |
| 5 | Sua | `rgba(255,171,147,.13)` | `var(--acc-peach)` | Nhõng nhẽo / Clingy | "Dỗi rất nghệ thuật. Dỗ đúng cách thì thương gấp đôi." | "Sulks artistically. Comfort it right and it loves you double." |
| 6 | Xoài | `rgba(255,127,182,.1)` | `var(--acc-pink)` | Lì lợm / Stubborn | "Không dễ hài lòng, nhưng lớn nhanh nhất khi hai bạn đều đặn." | "Hard to please, but grows fastest when you two stay consistent." |

  Note: Bo (#1) and Xoài (#6) both use pink as trait color but with different background tint opacities (`.12` vs `.1`) — preserve this exact distinction, it is intentional in the source, not a duplication error to "fix."
- Key Behavior / State Notes: static, non-interactive — no hover-triggered state change beyond the shell's default card treatment (no elevation/lift is defined for these cards in the source, unlike Home's feature/pet-cast teaser cards which do lift on hover — do not add a hover lift here, that would be a fidelity deviation).

**6.2.3 Growth Stages Block** (`:270-281`, data verbatim from `Cupid Web.dc.html:756-760`)
- Outer panel: `margin-top: 40px`, `background: var(--surf)`, `border: 1px solid var(--c09)`, `border-radius: 30px`, `padding: 34px`.
- Panel header: "Bốn giai đoạn lớn lên" / "Four stages of growth" — Nunito 800, 22px, `color: var(--ink)`.
- Stage grid: `margin-top: 22px`, `grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px`.
- Each stage cell: `background: var(--c05); border: 1px solid var(--c09); border-radius: 20px; padding: 18px` — stage number (Roboto Mono 10px, `color: var(--acc-pink)`), stage title (Nunito 800 16px, `color: var(--ink)`, `margin: 6px 0 6px`), stage description (12.5px, `line-height:1.55`, `color: var(--c58)`).
- Content, in exact order (do not reorder or omit — BR-3):

| # | Number | Title VI / EN | Description VI | Description EN |
|---|--------|----------------|-----------------|-----------------|
| 1 | 01 | Trứng / Egg | "Ba ngày đầu. Cần cả hai check-in mới nở." | "First three days. Hatches only when both check in." |
| 2 | 02 | Bé con / Baby | "Học tên hai bạn, bắt đầu đòi ăn và đòi chơi." | "Learns both names, starts asking for food and play." |
| 3 | 03 | Trưởng thành / Grown | "Mở nhật ký chung, album ảnh và thử thách khó." | "Unlocks the shared journal, album, and harder quests." |
| 4 | 04 | Linh thú / Spirit | "Sau 365 ngày. Có hào quang riêng và thẻ kỷ niệm giới hạn." | "After 365 days. Gains an aura and a limited keepsake card." |

- Key Behavior / State Notes: static, non-interactive, always shows all 4 stages — this is an explainer, not a per-pet progress tracker (no live "which stage is my pet at" state; BR-1 confirms no persistence).

### 6.3 Route Map (no changes)

No route-map changes — this story fills in the `pets` route body that STORY-001 §6.3 already reserved (`In desktop/mobile primary nav? Yes`, `In footer? Yes (Product col)`). No new routes are added.

### 6.4 Theme & Language States (no changes)

No new state — page content uses the existing shell-level `document.body.dataset.theme`/`dataset.lang` mechanism and the same `[data-vi]`/`[data-en]` paired-span pattern from STORY-001 §6.4. Every string in §6.2 above already has both VI and EN values; there is no partial/placeholder combination. No new persistence logic needed.

### 6.5 Component Changes

- **Pet Detail card** (New): horizontal sprite+text layout with description, per-pet tinted background — see §6.2.2. Distinct from Home's compact "Pet-cast teaser" card (STORY-001 §6.2.3, vertical sprite-over-name-over-trait, no description). Do not reuse the teaser card component for this page; do not retrofit the teaser card to add a description (Home's teaser must stay compact per STORY-001 fidelity — these are two separate card shapes in the design source).
- **Growth Stage card** (New): numeral + title + description in a 4-up grid inside a bordered panel — see §6.2.3. Reusable pattern: the panel/cell shape resembles STORY-001's "How it works" step card (§6.5 there) but is visually distinct (no big 44px numeral, smaller compact cell) — do not merge these two into one shared component, they read at different scales in the design source.
- **Header/Footer/Theme toggle/Language toggle/Mobile nav select**: reused unmodified from STORY-001 §6.5, only the "Pets" item's active-state binding is new (see §6.1 above).

### 6.6 Responsive And Accessibility Notes

- Responsive behavior for affected screens: pet-card grid and stage grid both use CSS `auto-fit`/`minmax` fluid reflow (330px floor for pet cards, 180px floor for stage cells) — same fluid-grid convention as STORY-001, not fixed breakpoints. Verify at 375/768/1024/1440px that no column drops below its `minmax` floor and no horizontal overflow occurs (AC-7).
- Content or action reprioritization on smaller surfaces: none needed — pet cards stack to a single column naturally once viewport can't fit a 330px card beside another; stage cells reflow similarly at 180px. No content is hidden or reordered at any breakpoint.
- Keyboard and focus expectations: this page has no new interactive elements (cards are static, non-clickable, non-focusable) — only the inherited shell controls (nav items, theme/language toggle, "Get the app" CTA) need focus handling, already covered by STORY-001 §6.6. Do not add `tabindex` or button semantics to the pet/stage cards — they are not actionable.
- Screen reader / semantics notes: wrap page content in the shared `<main>` landmark (per STORY-001 §6.6). Pet sprite images need meaningful `alt` text carrying the pet's name (e.g. `alt="Bo"`), matching STORY-001's pet-sprite a11y rule — not empty/decorative alt, since pet identity is core content here (more so than the Home teaser, since this is the page whose entire purpose is introducing each pet). Growth-stage numerals ("01"–"04") are decorative/redundant with the stage title text order — do not require them to be separately announced beyond normal reading order (a semantic ordered list or ordinary DOM order is sufficient; no ARIA numbering needed).
- Document title (AC-6, DEF-2 carry-forward): this page must set a distinct `<title>` referencing its content — e.g. "Pets — Cupid" / "Pet — Cupid" (or equivalent per whatever per-page title convention Tech Lead establishes for the site) — not the site-wide default/Home title. Apply the same convention every other REQ-006 page story will need; if Tech Lead has not yet defined a shared title-templating pattern, flag it there rather than inventing a one-off scheme for this page alone.
- Error / status communication expectations: N/A — no forms, no async operations, no empty state (content is always fully populated per requirements.md Edge Cases).

### 6.7 Visual Direction Notes

- Typography, density, or spacing posture: same three-typeface split as STORY-001 (Nunito display/headline, Roboto body — though this page's card descriptions use Roboto at 13.5px/12.5px, smaller than Home's, matching the design source), Roboto Mono for eyebrow/caption/trait-tag/stage-numeral accents.
- Surface and container treatment: same soft `--surf`/tinted-translucent panel language as STORY-001 — 20-30px border radii, 1px low-opacity borders, no hard drop shadows. The growth-stages panel nests a lighter `--c05` grid inside a `--surf` outer panel — a two-level surface nesting not present elsewhere yet in REQ-006; implement exactly, do not flatten to one surface level.
- Color or status-semantics treatment: no status/semantic colors on this page (no forms, no error states) — all six accent colors (pink/lilac/mint/butter/peach, pink reused twice) are purely per-pet decorative identity, not meaning-bearing.
- Anti-patterns explicitly avoided: no hover-lift interaction on pet/stage cards (unlike Home's feature/pet-cast teaser cards which do lift) — do not copy that hover behavior onto this page's cards, the design source does not define it here.

### 6.8 Visual Acceptance Criteria / Design Anchor

- Visual reference(s): not yet rendered as image files (same gap as STORY-001 — see that story's §7 Handoff Notes for the rendering-command note). In their absence, this section's measurable rules and §6.2's exact copy/color/layout tables are the interim visual anchor, pulled directly from `cupid-app-design-system/Cupid Web.dc.html:213-283` and its bound data at `:741-747` (pets) and `:756-760` (stages).
- Layout & spacing (key paddings, gaps, sizes): hero section `padding: 70px 32px 90px`, hero max-width `640px`; pet grid `margin-top: 40px; gap: 20px`, card `padding: 28px; gap: 22px` (sprite-to-text), sprite **`130×130px` fixed — resolved BLK-VF-1, re-verified 2026-08-22 against the composed `visual-fidelity/design-reference/design-reference-pets-1280.png` render: the ~73–74px width visible there is not a legitimate flex-shrink (the column has ~178px of slack, no container pressure) but a traced `support.js` `HOST_STYLE_PROPS` allowlist gap (support.js:445-466,676) that drops the inline `flex:0 0 130px`/`flex-shrink:0` while still preserving `width:130px` — 130px remains the design-intended, implementation-correct value; do not treat the design-reference render's ~74px as a visual anchor (see §6.2.2)**; growth panel `margin-top: 40px; padding: 34px`, stage grid `margin-top: 22px; gap: 16px`, stage cell `padding: 18px`. All content constrained to `max-width: 1200px; margin: 0 auto` at the section level (inherited from shell content-width convention).
- Color & status semantics (hex/token names): pet trait/background tints per §6.2.2 table (all `rgba()` literals from the source, not theme tokens — these do not flip with dark/light theme the way `--c*` tokens do; verify at implementation that the raw `rgba()` values render correctly against both dark and light `--bg`/`--surf` backgrounds, since they are theme-independent literals layered on top of theme-dependent page background). Stage-cell background uses theme token `--c05` (theme-dependent, unlike the pet-card tints).
- Typography (sizes, weights, line-height): hero H1 Nunito 900 52px; hero subcopy Roboto 16px/1.65; pet name Nunito 900 26px; pet trait tag Roboto Mono 10px uppercase tracked `.1em`; pet description Roboto 13.5px/1.6; stages panel header Nunito 800 22px; stage title Nunito 800 16px; stage description Roboto 12.5px/1.55; stage numeral Roboto Mono 10px.
- Component states to verify (default/hover/active/disabled/loading/error/empty): pet cards and stage cells — default only, no other state applies (no hover-lift, per §6.7 anti-pattern note). Header "Pets" nav item — default/active/hover, inherited from STORY-001 §6.1 (verify active state triggers correctly on this route). No disabled/loading/error/empty states apply anywhere on this page.
- Responsive checkpoints to verify: pet-card grid never drops a card below 330px width; stage-cell grid never drops a cell below 180px width; verify at 375, 768, 1024, 1440px (same checkpoint set as STORY-001) with no horizontal overflow and no overlapping content (AC-7).

### 6.9 Usability Readiness Gate

- Can the target user complete the critical task without outside explanation? Yes — hero copy states the premise plainly ("pick a pet, it grows through four stages"), and all 6 pet cards plus the 4-stage explainer are self-contained, no prior-page context assumed.
- Is the first action clear for the expected user mode? N/A in the strict sense — this page has no primary CTA of its own (it's an explainer/showcase); the "next action" is implicit continued exploration or the shell's "Get the app" CTA, both already established by STORY-001.
- Is success, failure, and partial progress visible in user language? N/A — no transaction or progress state on this page.
- Are recovery, retry, edit, undo, or next-action paths explicit where needed? N/A — no destructive or multi-step actions.
- Remaining usability risks: none beyond the general a11y gaps already flagged and closed at the shell level in STORY-001 (§6.1/§6.6) — this story adds no new interactive controls that could introduce new gaps.

## 7. Handoff Notes

- Important implementation constraints: build the Hero, Pet Roster Grid, and Growth Stages Block as one page body mounted under the existing `pets` route/shell — do not alter header/footer/theme/language logic. The Pet Detail card (§6.2.2) is a new component, distinct from Home's Pet-cast teaser card; do not conflate them.
- OQ-driven blocked UX sections, if any: none (see §3).
- Shared pattern changes requiring System UX Memory update: no — `data/ux/system/ui_ux_system_memory.md` remains mobile-app-only (REQ-001) and this story's patterns (Pet Detail card, Growth Stage card) are page-local to REQ-006 web, already captured in STORY-001's spec precedent of deferring a REQ-006-specific memory update. If a later REQ-006 story reuses the Pet Detail card or Growth Stage card shape, cross-reference this spec directly rather than waiting on a memory update.
- Copy-fidelity reminder for implementation: every VI/EN string in §6.2 is copied verbatim from `Cupid Web.dc.html:213-283` and its data arrays (`:741-747`, `:756-760`) — do not paraphrase, summarize, or "clean up" wording at implementation time (BR-2, BR-3).
