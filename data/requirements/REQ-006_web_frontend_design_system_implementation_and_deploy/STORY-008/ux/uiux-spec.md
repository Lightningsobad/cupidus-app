
# UI/UX Specification - Privacy & Terms Page (REQ-006 / STORY-008)

## 1. Metadata

- Related Story: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-008/story_master.md`
- Source Requirement Paths: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/req_master.md`, `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-008/requirements/requirements.md`
- Target Directory: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-008/ux/`
- Mode: Extension of the shared shell (STORY-001, DONE, MERGE_COMPLETE) with one new page body behind the existing `legal` route.
- Status: Draft
- System UX Memory Path: `data/ux/system/ui_ux_system_memory.md`
- System UX Memory Action: Read Only (this run) — memory documents `Cupid Mobile (REQ-001)` only, an unrelated product surface; no update needed for this story.

## 2. Context Summary

- User goal: a visitor, or a compliance/legal reviewer, reads the privacy policy and terms of service via the footer "Legal" links or a direct URL, in either language.
- Primary user mode: Direct-need (looking up a specific policy fact) or compliance-review (reading the whole page top to bottom).
- Business outcome: legal/compliance transparency required for public-consumer app-store listing and production launch; not a conversion surface.
- Existing specs reviewed: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-001/ux/uiux-spec.md` (§6.1 Global Shell, §6.3 Route Map, §6.4 Theme & Language States) — this story reuses that shell and those states unmodified; no redesign of header/footer/toggles here.
- Existing UI patterns found: STORY-001 established the header/footer shell, the three-typeface split (Nunito/Roboto/Roboto Mono), the `--surf`/`--c*` translucent-panel token scale, and the fluid `auto-fit` grid convention. This story introduces one new pattern not yet in the system: a **single-column long-form text page** (no grid, no cards) — see §6.7.
- Existing components reused or extended: Header, Footer, theme toggle, language toggle (all reused unmodified from STORY-001).
- Current UX debt or consistency risks: none — this story adds body content behind an already-wired, already-linked route (STORY-001 §6.3 confirms the footer "Legal" column already targets `legal`).
- Current organization or hierarchy issues in the affected area: N/A.
- Stable shared patterns vs local debt: the section-divider list pattern below (§6.2) is new; flag for future stories needing similar long-form content (e.g., a future dedicated FAQ detail page) to reuse rather than reinvent.
- Open Question Impact source: `STORY-008/requirements/requirements.md` `## Open Question Impact`.
- Open assumptions: none — the design source (`cupid-app-design-system/Cupid Web.dc.html:639-653`) is a complete, working `isLegal` render for this page; every element below is sourced directly from it (exact line numbers cited), not inferred. Footer link wiring already exists from STORY-001 (`:844-847`).

## 3. Open Question Impact

- **OQ-REQ006-1** (frontend framework/stack) — RESOLVED by STORY-001 Tech Lead: Astro static site. No impact: this spec is expressed as markup structure, CSS tokens, and interaction states, independent of framework.
- **OQ-REQ006-2** (backend API dependency) — RESOLVED: static/marketing site, no `api.cupidus.app` calls. Directly applicable: the Legal page is 100% static content, no forms, no async states.
- UX Decision: proceed with full UX design for both; neither blocks any part of this story.

## 4. Requirement-To-Design Traceability

- **AC-1 (Route & discoverability)**: UX Response: §6.1 (reused, unmodified) confirms the footer "Pháp lý"/"Legal" column's two links ("Quyền riêng tư"/"Privacy", "Điều khoản"/"Terms") both already route to `legal` (`Cupid Web.dc.html:844-847`, wired in STORY-001). Affected: footer Legal column (no change needed), new `legal` route body (this story).
- **AC-2 (Header content)**: UX Response: §6.2 "Page Header" block. Affected: eyebrow, H1, updated-date line.
- **AC-3 (Legal sections — verbatim content)**: UX Response: §6.2 "Legal Sections List". Affected: the 5-item `legal` array content, source order preserved.
- **AC-4 (Locale and theme parity)**: UX Response: reuses STORY-001 §6.4 unmodified — no page-local toggle is introduced. Affected: none (shell-level state only).
- **AC-5 (Per-page `<title>`)**: UX Response: §6.5 Component Changes, "Page `<title>`" entry. Affected: document head, per locale.
- **UI-Fidelity-AC (visual parity)**: UX Response: §6.2 + §6.8 Visual Acceptance Criteria, sourced from `Cupid Web.dc.html:639-653`. Affected: `legal` route body.

## 5. Critical User Tasks And Success Criteria

- **Find a specific policy fact (e.g. "do you sell my data?") or read the whole policy**:
  - User Mode: Direct-need or compliance-review.
  - Entry Point: footer "Legal" column link (Privacy or Terms — both land on the same page), or a direct URL to the `legal` route.
  - Success Signal: user locates the relevant of the 5 sections and reads its answer; a compliance reviewer can scan all 5 section titles quickly without reading every body paragraph first.
  - Primary Risk: long-form legal text becomes hard to scan if titles don't stand out from body copy, or if sections aren't clearly delimited — the design source's border-top divider + bold section title pattern exists specifically to solve this (§6.2).

- First-use guidance or discoverability needs: none — page is self-contained; the "Updated <date>" line signals currency without extra UI.
- Completion or post-completion state: N/A — reading is the complete task; no action to confirm.
- Retry, edit, undo, or next-action behavior: N/A — no forms, no destructive actions.
- What would make the task feel unfinished or unsafe to the user: a legal page that looks unfinished or inconsistent with the rest of the site (undermines trust in the policy itself); any section missing, reordered, or paraphrased from the source (explicitly covered by AC-3).

### 5.1 System Entry And Discoverability

- Existing surface, workflow, or state where the actor starts: the shared footer, "Pháp lý"/"Legal" column (built in STORY-001, unmodified here).
- Required entry point, navigation item, CTA, or in-flow discovery path: footer links only (both "Privacy" and "Terms" labels point at this single page) plus direct URL. Per STORY-001 §6.3, this route is intentionally **not** in the header's 7-item primary/mobile nav — do not add it there; that would be a fidelity deviation from the design source, not a fix.
- Direct URL only acceptable per PO scope: YES, in addition to the footer links — matches the design source's own routing (`Cupid Web.dc.html:845-846`, both labels call the same `nav("legal")`).
- If direct URL only is acceptable, UX treatment: the page must be self-explanatory with no assumed prior navigation context — the eyebrow "Legal" + H1 + updated-date line establish what the page is immediately (see §6.2).
- Entry point states: default only. No empty/loading/disabled/permission-limited states apply.
- Surfaces intentionally not updated: header primary nav (7 items) stays unchanged — Legal remains footer-only, per STORY-001 Route Map.

## 6. UX Design

### 6.1 Global Shell (reused, unmodified — see STORY-001 §6.1)

- Header and footer are structurally identical to every other REQ-006 page; this story makes no shell changes. Full spec: `STORY-001/ux/uiux-spec.md` §6.1.
- Footer "Pháp lý"/"Legal" column (`Cupid Web.dc.html:844-847`) already targets this page's route from both its links — no footer change needed, only the route's page body (below) is new.

### 6.2 Legal Page (`isLegal` state, `Cupid Web.dc.html:639-653`)

**Page wrapper**
- `<section style="max-width:820px;margin:0 auto;padding:70px 32px 90px">` — note this page uses an **820px** content max-width, narrower than Home's 1200px or Support's 860px (`Cupid Web.dc.html:615` for comparison) — this narrower measure is deliberate for long-form-text readability and must not be widened to match other pages.
- Single column throughout; no grid, no cards, no illustration — the page is content-first by design.

**Page Header** (`:641-643`)
- Eyebrow: "Legal" — literal, unlocalized string in the source (no `data-vi`/`data-en` span), Roboto Mono 11px, `letter-spacing:.14em`, uppercase, `color:var(--c5)`. Ships as "Legal" in both VI and EN.
- H1: Nunito 900, 48px, `letter-spacing:-.03em`, `margin:10px 0 0`, `color:var(--ink)`. VI: "Quyền riêng tư & Điều khoản". EN: "Privacy & Terms".
- Updated-date line: Roboto Mono 11.5px, `color:var(--c45)`, `margin:12px 0 0`. VI: "Cập nhật 29.07.2026". EN: "Updated 29 Jul 2026". Static string in the source, not a computed date — reproduce literally, do not wire to a live "last modified" value.

**Legal Sections List** (`:644-650`, data `:823-829`)
- Container: `display:flex; flex-direction:column; gap:26px; margin-top:34px`.
- Each of the 5 sections, in source order, identical structure:
  - `border-top:1px solid var(--c1); padding-top:22px` (this divider is the only visual separator between sections — no card background, no shadow).
  - Title: Nunito 800, 19px, `color:var(--ink)`, `margin-bottom:9px`.
  - Body: 14.5px, `line-height:1.7`, `color:var(--c64)`.
- Content, verbatim, in source order (VI / EN — do not paraphrase, do not add or remove sections):
  1. "Chúng mình lưu gì" / "What we store" — "Tên hiển thị, ngày sinh (để tính hoàng đạo), tâm trạng check-in, ảnh bạn tự tải lên. Không danh bạ, không vị trí liên tục." / "Display name, birthday (for zodiac), mood check-ins, and photos you upload. No contacts, no continuous location."
  2. "Ai xem được" / "Who can see it" — "Chỉ bạn và người ghép đôi với bạn. Nhân sự của chúng mình không đọc nội dung riêng tư trừ khi bạn gửi báo lỗi kèm ảnh." / "Only you and your partner. Our staff never read private content unless you attach it to a bug report."
  3. "Không bán dữ liệu" / "No data sales" — "Chúng mình không bán, không cho thuê, không dùng dữ liệu của bạn để huấn luyện mô hình quảng cáo." / "We do not sell, rent, or use your data to train advertising models."
  4. "Tài khoản đôi" / "Paired accounts" — "Một số dữ liệu thuộc về cả hai (bé pet, album chung). Xoá tài khoản của bạn không xoá phần của người kia." / "Some data belongs to both of you (the pet, the shared album). Deleting your account does not delete their half."
  5. "Điều khoản ngắn gọn" / "Terms, briefly" — "Từ 16 tuổi. Đừng dùng Cupid để làm tổn thương người khác. Chúng mình có thể đóng tài khoản vi phạm." / "16 and over. Don't use Cupid to hurt anyone. We may close accounts that break this."
- Key Behavior / State Notes: this list has no interactive elements (no accordion/expand — unlike the Support FAQ page's `<details>` pattern at `:619-628`, do not borrow that pattern here; the source renders all 5 sections fully expanded, always visible, no collapse). No hover/active states apply to section content itself.

### 6.3 Route Map (reused — see STORY-001 §6.3)

No change to the route table. `legal` remains footer-only (Legal column, both links), absent from the header's 7-item primary/mobile nav, per STORY-001's explicit "do not add an 8th header nav item" rule. This story fills in the previously-empty `legal` route body only.

### 6.4 Theme & Language States (reused, unmodified — see STORY-001 §6.4)

- All 4 combinations (dark×vi, dark×en, light×vi, light×en) must render correctly on this page using the existing shell-level `document.body.dataset.theme`/`dataset.lang` state — no page-local toggle, no page-local persistence. `--ink`, `--c1`, `--c45`, `--c5`, `--c64` all resolve from the existing dark/light token blocks (`Cupid Web.dc.html:16-17`); verify body-text contrast (`--c64`) holds up over long paragraphs in both themes, not just at a glance.

### 6.5 Component Changes

- **Legal section item** (New): title + body pair separated by a top border, no card chrome. See §6.2. This is a new pattern for the system — a plain, undecorated long-form content block, distinct from every other REQ-006 page's card-based patterns (feature card, pet-cast card, step card, FAQ `<details>`). Future long-form-text pages (if any) should reuse this pattern rather than forcing content into a card shape.
- **Page `<title>`** (New, per AC-5, DEF-2 carry-forward from STORY-001 review): distinct per-page title, localized:
  - VI: "Quyền riêng tư & Điều khoản — Cupid"
  - EN: "Privacy & Terms — Cupid"
  - Must update when the language toggle changes, consistent with how the rest of the page's `data-vi`/`data-en` content responds to the toggle (the design source itself doesn't model `<title>` since it's a component preview, not a full document — this is an implementation-level addition required by AC-5, not sourced from the `.dc.html` file).
- Header, footer, theme toggle, language toggle: no changes (reused from STORY-001, see §6.1/§6.4).

### 6.6 Responsive And Accessibility Notes

- Responsive behavior for affected screens: single-column, no grid — the 820px `max-width` with `32px` side padding and the page's own fluid centering (`margin:0 auto`) already handles all viewport widths without a breakpoint; do not add one. On narrow viewports the effective content width simply shrinks toward `100vw - 64px`, same as the source's plain block layout.
- Content or action reprioritization on smaller surfaces: none needed — there is only one content stream (header block, then 5 sections in fixed order); nothing reflows or reprioritizes.
- Keyboard and focus expectations: this page has no interactive content of its own; keyboard/focus requirements are fully covered by the reused header/footer (STORY-001 §6.6) — verify Tab order simply passes through this page's content without a focus trap (there's nothing here to trap it, but confirm at implementation since it's a new route).
- Screen reader / semantics notes: use a real `<main>` landmark for the page body (consistent with STORY-001's landmark requirement); mark each of the 5 legal sections with a heading element (`<h2>` for the section title, not just a styled `<div>`) so screen-reader users can navigate the policy by heading the same way sighted users scan by the bold title + divider — this is an accessibility improvement over the raw prototype markup (which uses plain `<div>`s throughout, being template markup, not semantic HTML), required at implementation, not present verbatim in the source. The page H1 remains the single top-level heading; the 5 section titles are `<h2>` siblings beneath it.
- Error / status communication expectations: N/A — no forms, no async operations.

### 6.7 Visual Direction Notes

- Typography, density, or spacing posture: same three-typeface split as every other REQ-006 page (Nunito for the H1/section titles, Roboto-family body for section text, Roboto Mono for the eyebrow/updated-date). This page is the system's first pure long-form-text layout — no card surfaces, no icon tiles, no illustration; density comes from generous `26px` inter-section gaps and `1.7` line-height, not from panels.
- Surface and container treatment: **deliberately no `--surf` panel, no border-radius container, no card background** anywhere in the content body — the only visual structure is the `1px solid var(--c1)` top-border divider between sections. This is a conscious contrast with every other REQ-006 page (which universally uses `--surf` cards) and must not be "fixed" into a card layout at implementation — that would be a fidelity deviation from `Cupid Web.dc.html:646`.
- Color or status-semantics treatment: no status/semantic colors — purely the existing neutral ink/opacity-scale tokens (`--ink`, `--c1`, `--c45`, `--c5`, `--c64`); no brand accent colors (pink/lilac/mint/butter/peach) appear anywhere in this page's content body, consistent with the source (accents are reserved for marketing/product pages, not the legal page).
- Anti-patterns explicitly avoided: do not add an accordion/collapse interaction (that's the Support FAQ page's pattern, `:619-628`, a different page); do not add a sticky in-page table-of-contents or jump links — not present in the source and out of this story's scope; do not widen the content column to match other pages' 860–1200px measures — 820px is intentional for reading comfort.

### 6.8 Visual Acceptance Criteria / Design Anchor

- Visual reference(s): not yet rendered as image files. This story inherits the same design-reference-rendering blocker STORY-001 recorded (no Bash-capable tool available in this run to execute `render-design-canvas.js`; see STORY-001 §7 Handoff Notes items 2–3 for the full status of the `design_source` lock/render pipeline, which is outside UX scope to resolve). In their absence, this section's measurable rules, pulled directly from `Cupid Web.dc.html:639-653` with exact line citations throughout §6.2, are the interim visual anchor.
- Layout & spacing: page section `padding:70px 32px 90px`, `max-width:820px`; H1 `margin:10px 0 0`; updated-date `margin:12px 0 0`; sections container `margin-top:34px`, `gap:26px`; each section `padding-top:22px` (after its `1px` top border); section title `margin-bottom:9px`.
- Color & status semantics: eyebrow `--c5`; H1 `--ink`; updated-date `--c45`; section divider `--c1`; section title `--ink`; section body `--c64`. Full dark/light values at `Cupid Web.dc.html:16-17` (same tokens as every other page — no new tokens introduced).
- Typography: eyebrow Roboto Mono 11px uppercase `letter-spacing:.14em`; H1 Nunito 900 48px `letter-spacing:-.03em`; updated-date Roboto Mono 11.5px; section title Nunito 800 19px; section body 14.5px `line-height:1.7`.
- Component states to verify (default / hover / active / disabled / loading / error / empty): default only — no interactive elements in the content body; verify only that the reused header/footer's existing hover/active states (STORY-001 §6.8) are unaffected on this route.
- Responsive checkpoints to verify: no breakpoint-driven layout change exists on this page (§6.6) — verify at common widths (375, 768, 1024, 1440) that the 820px column simply centers and the 32px side padding holds at every width, with no horizontal scroll or content clipping at 375px.

### 6.9 Usability Readiness Gate

- Can the target user complete the critical task without outside explanation? Yes — eyebrow + H1 + updated-date immediately orient the reader; each section's bold title lets a scanning reader find the fact they need without reading every paragraph.
- Is the first action clear for the expected user mode? N/A in the CTA sense — there is no primary action on this page; "first action" for this user mode is reading, and the divider + title pattern makes the reading structure clear at a glance.
- Is success, failure, and partial progress visible in user language? N/A — no transaction, no progress to track.
- Are recovery, retry, edit, undo, or next-action paths explicit where needed? N/A — no destructive or multi-step actions in scope.
- Remaining usability risks: none beyond the standard reused-shell risks already flagged in STORY-001 (mobile nav `<select>` / toggle a11y gaps, closed there, not reopened here).

## 7. Handoff Notes

- Important implementation constraints: this story adds exactly one new page body (the `legal` route content) behind the shell STORY-001 already built; do not touch header, footer, theme toggle, or language toggle implementation. Use a real `<main>` landmark and `<h2>` section headings per §6.6 — the raw design-source markup is template-only and does not model this semantic structure.
- OQ-driven blocked UX sections, if any: none (see §3).
- Shared pattern changes requiring System UX Memory update: no — `data/ux/system/ui_ux_system_memory.md` covers only the unrelated mobile app (REQ-001); the REQ-006 web shared-pattern record lives in STORY-001's own spec, not in that file, and this story doesn't change any shared pattern (it only adds one new page-local content pattern, §6.5/§6.7).
- Design-coherence checks downstream should preserve: the deliberate absence of card/`--surf` chrome on this page (§6.7) — do not "improve" it into a card layout; the 820px reading-width measure (§6.2); the footer-only (no header-nav) discoverability path (§6.3/§5.1).
- Usability checks downstream should preserve: all 5 sections present, in source order, verbatim copy (AC-3); per-page `<title>` updates with the language toggle (§6.5).
- Questions or blockers: none for UX. The design-reference-rendering and `design_source` re-lock status inherited from STORY-001 (§7 items 2–3 there) remain open at the requirement level but do not block this story's UX design, per the same reasoning STORY-001 recorded — this UX spec proceeds on cited exact source line numbers and literal measurable values instead of a rendered reference image.

## Optional Expansion

Not needed — this is a compact single-page spec reusing an already-specified shell; no multi-step flow, no new reusable component beyond the one long-form-text pattern covered in §6.5/§6.7.
