# UI/UX Specification - Support FAQ Page (REQ-006 / STORY-007)

## 1. Metadata

- Requirement: REQ-006 Web frontend implementation from design system &
  production deploy
- Story: STORY-007 Support FAQ Page
- Depends on: STORY-001 (DONE / MERGE_COMPLETE) — shared header/footer shell,
  nav routing, theme toggle, language toggle, chosen frontend framework. This
  story reuses all of it unmodified; no new chrome is designed here.
- Design source of truth: `cupid-app-design-system/Cupid Web.dc.html`,
  `isSupport` section (lines 614-637) and the `faq` seed data array (lines
  814-821).

## 2. Context Summary

- Route: `support` (already wired into header/footer nav by STORY-001; see
  STORY-001 `ux/uiux-spec.md` §6.1 and §6.3 Route Map — this story only fills
  in the previously-empty page body).
- Page purpose: let a visitor self-serve an answer via a 6-entry FAQ list,
  with a static human-contact fallback (`mailto:hi@cupid.app`) for anything
  the FAQ doesn't cover.
- Open assumptions: none — the design source's `isSupport` section is a
  complete, working interactive prototype for this page; every element below
  is sourced directly from it with exact line numbers cited.

## 3. Open Question Impact

- OQ-REQ006-1 (frontend framework/stack): RESOLVED by STORY-001's Tech Lead.
  Not re-litigated here.
- OQ-REQ006-2 (static site, no live API): RESOLVED. This page's only
  "action" is a static `mailto:` link — no form, no ticketing backend, no
  loading/error/empty states to design.
- No scope item in this story is BLOCKED.

## 4. Requirement-To-Design Traceability

- **AC-1 (nav to Support)**: satisfied by STORY-001's existing `support`
  route; no new UX decision needed. Affected: header desktop nav / mobile
  `<select>`, footer Company column (both already wired).
- **AC-2, AC-5 (heading + 6 FAQ entries, VI/EN)**: UX Response §6.1 below.
  Design anchor: `Cupid Web.dc.html:614-628` (markup) + `:814-821` (content).
- **AC-3, BR-3 (independent expand/collapse)**: UX Response §6.2 below.
  Design anchor: `Cupid Web.dc.html:620-626` (native `<details>`/`<summary>`).
- **AC-4, BR-2 (contact block, `mailto:`)**: UX Response §6.3 below. Design
  anchor: `Cupid Web.dc.html:629-635`.
- **AC-6 (UI-Fidelity-AC)**: UX Response §6.4-6.6 below (layout, spacing,
  typography, color tokens, component states) — full UI-lane review gate
  applies, per `req_master.md` Technical Constraints.
- **AC-7 (per-page `<title>`, carried-forward DEF-2)**: UX Response §6.7
  below. Not present in the design comp markup (comp has no per-page
  `<title>` mechanism) — this is an implementation-level requirement with no
  visual design anchor.

## 5. Critical User Tasks And Success Criteria

- Primary task: visitor with a question scans FAQ questions, opens the one(s)
  relevant to them, reads the answer, and either is satisfied or falls
  through to the contact block.
  - Success Signal: visitor expands an FAQ entry and reads the answer, or
    clicks the `hi@cupid.app` mailto link.
  - What would make the task feel unfinished or broken: an FAQ entry that
    doesn't expand/collapse independently of the others (explicitly covered
    by AC-3); a contact link that isn't a real `mailto:` href (AC-4).

### 5.1 System Entry And Discoverability

- Entry point: header "Support"/"Hỗ trợ" nav item or footer Company-column
  "Support" link, both already wired by STORY-001. No new discovery path
  needed in this story.

## 6. UX Design

### 6.1 Page Header (`Cupid Web.dc.html:614-617`)

- Section container: `max-width: 860px`, centered (`margin: 0 auto`),
  `padding: 70px 32px 90px`.
- Eyebrow label: `Roboto Mono` 11px, `letter-spacing: .14em`,
  `text-transform: uppercase`, `color: var(--acc-mint)`. Copy: "Support"
  (both languages — the eyebrow itself is not translated in the source; only
  the `<h1>` and body copy use `data-vi`/`data-en` spans).
- Page heading (`<h1>`): `Nunito` 900, `font-size: 50px`,
  `letter-spacing: -.03em`, `margin: 10px 0 26px`, `color: var(--ink)`.
  Copy: "Câu hỏi thường gặp" (VI) / "Frequently asked" (EN). This satisfies
  AC-2's page-heading requirement.
- No responsive downscale is defined in the source for this heading (no
  `@media` rule touches it) — keep it at 50px across all viewports; do not
  invent a mobile-only font-size reduction, that would be a fidelity
  deviation from the source.

### 6.2 FAQ List (AC-2, AC-3, BR-3 — `Cupid Web.dc.html:618-628, 814-821`)

- List container: `display: flex; flex-direction: column; gap: 10px`, one
  entry per FAQ item, exactly 6 entries.
- Each entry is a native `<details>` element:
  `background: var(--surf); border: 1px solid var(--c09); border-radius:
  20px; padding: 20px 24px`.
- `<summary>` (the always-visible question row): `cursor: pointer;
  list-style: none` (hide the native disclosure triangle —
  `summary::-webkit-details-marker{display:none}` in source, replicate as
  `list-style: none` cross-browser plus the WebKit marker suppression);
  `font-family: Nunito; font-weight: 800; font-size: 16.5px; color:
  var(--ink)`; row layout `display: flex; justify-content: space-between;
  gap: 14px` so the question text sits left and the icon sits right.
  - Question text span: the question, VI/EN per language toggle.
  - Trailing icon: Material Symbols Rounded `expand_more`, `font-size: 20px;
    color: var(--acc-pink)`.
  - Component-state note: the source defines no `details[open]` style
    override for this icon (no rotation, no color/size change on open) — do
    not add an open-state icon rotation or any other invented open/closed
    icon treatment; that would be a fidelity deviation from the source.
    Rely on the browser's native `<details>` open/closed behavior only.
- Answer body (revealed when `<details>` is open): `font-size: 14px;
  line-height: 1.65; color: var(--c64); margin-top: 12px`. VI/EN per
  language toggle.
- Behavior (AC-3, BR-3): each `<details>` is independently
  open/closed-stateful — this is native HTML behavior, not JS-managed state;
  opening one entry must never affect any other entry's open/closed state.
  Do not implement this as a single-open accordion (BR-3 explicitly
  forbids it) and do not introduce a JS accordion library — plain
  `<details>`/`<summary>` is sufficient and is what the source uses.
- Content (AC-2, AC-5, BR-1): all 6 entries render verbatim from the design
  source's `faq` array (`Cupid Web.dc.html:814-821`) — static seed content,
  no CMS/API. VI/EN copy pairs:
  1. "Cupid miễn phí không?" / "Is Cupid free?"
  2. "Nếu chia tay thì bé pet thế nào?" / "What happens to the pet if we
     break up?"
  3. "Đối phương đọc được tin nhắn riêng của tôi không?" / "Can my partner
     read my private notes?"
  4. "Có bản web không?" / "Is there a web version?"
  5. "Yêu xa dùng được không?" / "Does it work long-distance?"
  6. "Xoá dữ liệu thế nào?" / "How do I delete my data?"
  Full question+answer text for all 6 entries is in the design source at
  the cited line range; implementer must copy it verbatim (do not
  paraphrase), matching AC-5's fidelity requirement.

### 6.3 Contact Block (AC-4, BR-2 — `Cupid Web.dc.html:629-635`)

- Container: `margin-top: 34px`, `background: linear-gradient(140deg,
  rgba(255,127,182,.16), rgba(183,140,245,.14))`, `border: 1px solid
  var(--c11)`, `border-radius: 26px`, `padding: 30px`, `display: flex;
  align-items: center; justify-content: space-between; gap: 20px;
  flex-wrap: wrap` (wraps to stacked layout on narrow widths — no explicit
  breakpoint, fluid via `flex-wrap`).
- Left side (text stack):
  - Title: `Nunito` 800, `font-size: 19px`, `color: var(--ink)`. Copy: "Vẫn
    cần người thật?" (VI) / "Still need a human?" (EN).
  - Subtext: `font-size: 14px; color: var(--c62); margin-top: 5px`. Copy:
    "Trả lời trong 24 giờ, tiếng Việt và tiếng Anh." (VI) / "We reply within
    24 hours, in Vietnamese or English." (EN).
- Right side: `<a href="mailto:hi@cupid.app">` styled as a solid pill —
  `background: var(--ink90); color: var(--bg); padding: 13px 24px;
  border-radius: 999px; font-family: Nunito; font-weight: 800; font-size:
  14px`. Visible label text is the literal email address `hi@cupid.app`
  (same in both languages — the source does not localize this string).
- This is a plain static anchor tag, per BR-2/OQ-REQ006-2 — no form, no
  client-side validation, no submit handler.

### 6.4 Theme & Language States

- Reuses STORY-001's global theme/language mechanism unmodified
  (`document.body.dataset.theme`, `document.body.dataset.lang`, persisted
  theme via `localStorage["cupid-web-theme"]`). No new toggle UI in this
  story — the header's existing theme/language controls apply globally,
  including on this page.
- All colors above are CSS custom properties (`var(--ink)`, `var(--c64)`,
  `var(--surf)`, `var(--acc-mint)`, `var(--acc-pink)`, `var(--c09)`,
  `var(--c11)`, `var(--c62)`, `var(--ink90)`, `var(--bg)`) that already flip
  between dark/light theme values via the token table established in
  STORY-001 (`Cupid Web.dc.html:16-17`) — verify this page in both themes,
  no per-page theme overrides are introduced.

### 6.5 Component Changes

- **FAQ disclosure item** (New, this story): native `<details>`/`<summary>`
  pattern per §6.2. No new reusable design-system component beyond this
  page's own markup — the design source does not define a shared
  "accordion" component used elsewhere on the site.
- **Contact CTA block** (New, this story): static content block with one
  `mailto:` anchor per §6.3, not a reusable button/component beyond this
  page.
- Accessibility addition beyond the raw source (source has no ARIA on
  `<details>`, which is fine — native `<details>`/`<summary>` already expose
  correct implicit semantics, `aria-expanded` state, and keyboard toggling
  via Enter/Space with no extra ARIA needed). Implementer should NOT add
  redundant `role="button"`/`aria-expanded` on `<summary>` — that would
  fight the native semantics native `<details>` already provides.

### 6.6 Responsive And Accessibility Notes

- Layout is inherently fluid: the FAQ list is a single-column flex stack at
  all widths (no grid, no breakpoint-specific column count), and the
  contact block uses `flex-wrap: wrap` to stack on narrow viewports. No
  named breakpoints apply within this page's own section — the only
  sitewide breakpoint is STORY-001's 1024/1025px header nav swap, which is
  unaffected by this page.
- Verify at common widths (375, 768, 1024, 1440) that: the FAQ entries never
  overflow horizontally, the summary row's question/icon `justify-content:
  space-between` holds without the icon wrapping under the question text on
  narrow widths (question text should wrap within its own flex item, not
  push the icon down — if source doesn't constrain this explicitly, let the
  question `<span>` take remaining width via normal flex sizing), and the
  contact block's title/subtext stack cleanly above the mailto pill once it
  wraps.
- Keyboard and focus expectations: each `<summary>` must be reachable via
  Tab (native `<details>` behavior) and toggle via Enter/Space (native); the
  `mailto:` link must be reachable via Tab and activatable via Enter. Add
  visible focus rings on both (not present in the raw prototype's inline
  styles — same a11y gap STORY-001 already flagged sitewide; close it here
  too, consistent with that established pattern).
- Screen reader / semantics: wrap the page content in the shared `<main>`
  landmark already established by STORY-001; each FAQ `<details>` exposes
  its own implicit expanded/collapsed state to assistive tech with no extra
  markup needed. The `expand_more` icon is decorative (redundant with native
  disclosure semantics) — mark it `aria-hidden="true"`.
- Component states to verify (default / hover / active / disabled / loading
  / error / empty): FAQ entry closed / open (native `<details>` toggle);
  `mailto:` link hover (`a:hover { color: #FFA9CD }` global anchor hover
  rule per `Cupid Web.dc.html:18` — note this global link-hover color rule
  would apply unless the pill's own inline `color: var(--bg)` on the
  `mailto:` anchor takes precedence via specificity/inline-style order;
  implementer should confirm the pill text stays `var(--bg)`-colored on
  hover, matching the static solid-pill look, not the sitewide pink link
  hover). No loading/error/empty states apply — fully static content.

### 6.7 `<title>` Tag (AC-7, carried-forward DEF-2)

- Distinct, descriptive per-page `<title>` for the Support route — not the
  generic/shared title reused unchanged from another page (the defect this
  AC exists to close). No design-source anchor since the comp has no title
  mechanism; suggested content direction only, exact copy/format is an
  implementation decision: something naming both the product and this
  page's purpose, e.g. "Support & FAQ" as the page-identifying portion,
  localized per the active language the same way other page titles in this
  story set are expected to be (consistent with whatever `<title>` pattern
  the implementer establishes across STORY-002 through STORY-008 for this
  same carried-forward AC).

### 6.8 Visual Acceptance Criteria / Design Anchor

- Design source: `cupid-app-design-system/Cupid Web.dc.html`, `isSupport`
  section, lines 614-637 (markup) and 814-821 (FAQ content data).
- Fidelity scope (AC-6): layout (860px max-width centered container, 70/32/90
  padding), spacing (10px FAQ list gap, 20px/24px details padding, 34px
  margin above contact block), typography (Nunito 900/50px heading, Nunito
  800/16.5px questions, 14px/1.65 answers, Nunito 800/19px contact title,
  14px contact subtext, Nunito 800/14px mailto pill), and color tokens
  (`--acc-mint` eyebrow, `--ink`/`--c64`/`--c62` text tones, `--surf`
  details background, `--ink90`/`--bg` mailto pill) must match the source
  exactly in both dark and light theme, both VI and EN.
- Component states to verify: FAQ entry closed state (all 6, default
  visual), at least one FAQ entry open state (verify layout doesn't break
  when an answer is revealed and other entries remain closed), mailto pill
  hover.
- Responsive checkpoints to verify: 375, 768, 1024, 1440px — confirm the
  single-column FAQ stack and the contact block's `flex-wrap` stacking both
  hold cleanly with no horizontal overflow or overlapping text at any of
  these widths.

### 6.9 Usability Readiness Gate

- All 7 UX design principles considered: fidelity to source (§6.1-6.3, 6.8),
  independent FAQ state (§6.2, AC-3/BR-3), accessible native disclosure
  (§6.5, §6.6), theme/language reuse with no new toggle surface (§6.4),
  responsive fluid stacking with no invented breakpoints (§6.6), static
  no-backend contact affordance consistent with OQ-REQ006-2 (§6.3), and the
  carried-forward `<title>` defect closed (§6.7).
- Remaining usability risks: none new beyond STORY-001's already-flagged
  sitewide gaps (visible focus rings, theme/language toggle a11y), which
  this page inherits and does not need to re-solve — implementer closes
  those once, sitewide, not per-page.

## 7. Handoff Notes

- To Tech Lead / Frontend Developer: this story is UI-lane with strict
  visual-fidelity (AC-6) — implement `<details>`/`<summary>` exactly as
  specified in §6.2, do not substitute a JS accordion library, and do not
  add an icon-rotation or other open-state visual treatment not present in
  the design source (§6.2's explicit non-goal). Reuse STORY-001's shared
  shell, theme/language mechanism, and route wiring unmodified — this story
  adds only the page body content.
- Design-coherence checks downstream should preserve: exact FAQ copy (6
  entries, VI/EN, verbatim from `Cupid Web.dc.html:814-821`), the flat
  (non-nested) single-open-per-item disclosure behavior (BR-3), and the
  static `mailto:hi@cupid.app` contact affordance with no backend
  dependency (BR-2).

## Status

UX_COMPLETE: YES
Output: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-007/ux/uiux-spec.md`
