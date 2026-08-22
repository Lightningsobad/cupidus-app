
# UI/UX Specification - Cupid Journal Blog Page (REQ-006 / STORY-005)

## 1. Metadata

- Related Story: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-005/story_master.md`
- Source Requirement Paths: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/req_master.md`, `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-005/requirements/requirements.md`
- Target Directory: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-005/ux/`
- Mode: Extension (new page content on top of STORY-001's shared shell; no new global component)
- Status: Draft
- System UX Memory Path: `data/ux/system/ui_ux_system_memory.md`
- System UX Memory Action: Read Only (this run) — that file documents `Cupid Mobile (REQ-001)` only; the applicable web shared-shell/token reference for this story is STORY-001's own `ux/uiux-spec.md` (§6.1, §6.4, §6.7), queried directly.

## 2. Context Summary

- User goal: a content-marketing visitor lands on the Blog page from the shared header nav, scans a featured article and the article grid, and either reads further (external to this story's scope — no article detail route exists) or subscribes to the newsletter.
- Primary user mode: First-time or returning-browsing (not necessarily an app-shopper yet, per story Context Summary).
- Business outcome: SEO/content-marketing surface that builds trust and funnels back to the app-download surfaces built in STORY-001 (via the shared header "Get the app" CTA and footer, both out of this story's scope to modify).
- Existing specs reviewed: `STORY-001/ux/uiux-spec.md` — reused §6.1 (Global Shell: header/nav/footer, breakpoint, tokens), §6.4 (Theme & Language states), §6.7 (Visual Direction Notes: three-typeface split, surface/border treatment, no status-semantic colors).
- Existing UI patterns found: the STORY-001 "feature card" pattern (icon/tag + title + description, `var(--surf)` panel, `border-radius:26px`, hover lift) is closely related to but not identical to this story's article card (which adds an author row and no icon tile) — treated as a sibling pattern, not reused verbatim; see §6.3.
- Existing components reused or extended: Header, Footer, theme toggle, language toggle — all reused unmodified from STORY-001 (§6.1 of that spec). This story adds page-local components only (topic pill, featured panel, article card, newsletter block).
- Current UX debt or consistency risks: none new. The topic pills carry a `cursor:pointer` + hover style in the design source despite having no click handler (per AC-3/`OQ-REQ006-2` resolution) — flagged as an implementation judgment call in §6.3, not left implicit.
- Current organization or hierarchy issues in the affected area: N/A (new page).
- Stable shared patterns vs local debt: shell chrome (header/footer/theme/lang) is stable per STORY-001; this story's own patterns (topic pill, article card, newsletter block) are new and page-local, not yet promoted to System UX Memory (see §7).
- Open Question Impact source: `STORY-005/requirements/requirements.md` `## Open Question Impact`.
- Open assumptions: none — the design source's `isBlog` block (`Cupid Web.dc.html:453-509`, seed data `:780-792`) is a complete, static rendering of every element this story needs; every string and value below is sourced directly from it, not inferred.

## 3. Open Question Impact

- **OQ-REQ006-1** (frontend framework/stack) — RESOLVED by STORY-001 (Astro static site), already DONE/MERGE_COMPLETE. UX Scope Blocked: none. This spec is framework-independent (markup structure, CSS tokens, states).
- **OQ-REQ006-2** (backend API dependency) — RESOLVED at requirement level: no `api.cupidus.app` dependency in v1. UX Scope Blocked: none. UX Decision: topic pills and the newsletter input/button are designed as presentational-only — no loading/error/success states are designed for either, because none exist in the design source (no `onClick` filter handler on pills, no form-submit wiring on the newsletter block).

## 4. Requirement-To-Design Traceability

- **AC-1 (Page reachable)**: UX Response: N/A design-wise (nav route already exists per STORY-001 §6.3 Route Map, `blog` row). Affected: header "Blog" nav item — this story's page must render under it without error.
- **AC-2 (Page intro)**: UX Response: §6.2.1 Page Intro. Affected: page `<section>` top block.
- **AC-3 (Topic pills, presentational)**: UX Response: §6.2.2 Topic Pills. Affected: pill row directly under the intro block.
- **AC-4 (Featured article panel)**: UX Response: §6.2.3 Featured Article Panel. Affected: gradient-bordered two-column panel.
- **AC-5 (Article grid)**: UX Response: §6.2.4 Article Grid. Affected: 6-card responsive grid.
- **AC-6 (Newsletter block, presentational)**: UX Response: §6.2.5 Newsletter Block. Affected: bottom-of-page signup panel.
- **UI-Fidelity-AC-7 (Visual fidelity)**: UX Response: §6.2 (all subsections) + §6.6 Visual Acceptance Criteria / Design Anchor. Affected: entire Blog page body.
- **AC-8 (Copy fidelity)**: UX Response: every VI/EN string quoted in §6.2 is copy-pasted verbatim from `Cupid Web.dc.html:453-509` (`data-vi`/`data-en` spans) and the `topics`/`posts` seed arrays (`:780-792`) — do not paraphrase at implementation time.
- **AC-9 (Per-page title tag — DEF-2 carry-forward)**: UX Response: §6.5 Component Changes, page `<title>` note. Affected: document head, Blog route only.

## 5. Critical User Tasks And Success Criteria

- **Scan recent relationship-editorial content and either keep reading or subscribe**:
  - User Mode: First-time or returning-browsing.
  - Entry Point: header "Blog" nav item (desktop pill or mobile `<select>`, both from STORY-001's shared shell), from any other REQ-006 page.
  - Success Signal: user reads the featured article panel and/or scans article-grid cards (title/excerpt/category tag are legible and scannable without a detail page to click into), or fills and submits the newsletter email field.
  - Primary Risk: because this story has no article-detail route (design source has none — confirmed in Out of Scope), the featured panel and article cards must carry enough excerpt/title/category context on this single page for the visitor to get value without a "read more" destination; do not let the card design imply a working link if implementation doesn't wire one (see §6.3 anti-pattern note).

- First-use guidance or discoverability needs: none — static content page, no onboarding.
- Completion or post-completion state: N/A for article cards (no detail route to land on). For the newsletter input/button: presentational only per AC-6 — no success/confirmation state is designed, since no submit handler exists in the design source.
- Retry, edit, undo, or next-action behavior: N/A (no forms with real submission, no destructive actions).
- What would make the task feel unfinished or unsafe to the user: topic pills or article cards that visually promise interactivity (hover states, pointer cursor) but do nothing when activated — this is an intentional design-source behavior (§6.3), not a bug, but implementation must not silently "fix" it by wiring a fake destination, and must not make these elements keyboard-focusable dead stops (see §6.3 accessibility note).

### 5.1 System Entry And Discoverability

- Existing surface, workflow, or state where the actor starts: any other REQ-006 page (Home, Pets, Zodiac, etc.), via the shared header "Blog" nav item — already wired to route here by STORY-001 (not this story's scope to build).
- Required entry point, navigation item, CTA, or in-flow discovery path: header desktop nav pill "Blog"/"Blog", header mobile `<select>` option, and footer "Product" column "Blog" link (all three already exist per STORY-001 §6.1/§6.3) — this story only supplies what those already-wired routes point to.
- Entry point states: default only. No empty/loading/disabled/permission-limited states (static content, no auth, no data fetch).
- Surfaces intentionally not updated: header/footer/theme/language shell — unchanged from STORY-001.

## 6. UX Design

### 6.1 Global Shell (reused, unchanged)

Reused verbatim from STORY-001 `ux/uiux-spec.md` §6.1 (Header/Nav, Footer), §6.4 (Theme & Language States), §6.7 (Visual Direction Notes). This story does not modify shell behavior. The one shell-level state this story activates: the header desktop nav's "Blog" pill and the mobile `<select>`'s "Blog" option must show the **active** treatment while this page is mounted — `background: rgba(255,127,182,.16); color: var(--acc-pink)` and `aria-current="page"` (per STORY-001 §6.1's stated active-item rule, which every other REQ-006 page story also activates for its own nav item).

### 6.2 Blog Page (single page state; no separate article-detail template)

Source: `Cupid Web.dc.html:453-509` (`isBlog` block), seed data `:780-792` (`topics`, `posts` arrays). **The design source has exactly one Blog page state** — there is no per-article detail/reader template anywhere in the design source, confirmed by the story's Out of Scope note ("Individual article detail/reader pages — the design source has no per-article route or content, only this single listing page"). This spec therefore covers only the listing state; do not design or scaffold a second "article detail" template, since none exists to be visually faithful to.

Page container: `max-width:1200px; margin:0 auto; padding:70px 32px 90px` — consistent with the other REQ-006 pages' shared content-column width (`max-width:1200px`), matching STORY-001 §6.8's stated page-container pattern.

**6.2.1 Page Intro** (`:454-459`)
- Wrapper: `max-width:660px`.
- Eyebrow: "Cupid Journal" (both locales, not translated — literal string in source), Roboto Mono, 11px, `letter-spacing:.14em`, uppercase, `color:var(--acc-pink)`.
- H1: Nunito 900, 52px, `letter-spacing:-.03em`, `margin:10px 0 0`, `color:var(--ink)`. VI: "Viết về chuyện yêu nhau lâu dài". EN: "Notes on loving someone for a long time".
- Intro paragraph: 16px, `line-height:1.65`, `color:var(--c64)`, `margin:16px 0 0`. VI: "Không có mẹo giữ người yêu trong bảy ngày. Chỉ là những gì chúng mình học được khi ngồi nghe hàng nghìn cặp đôi kể chuyện." EN: "No seven-day tricks to keep someone. Just what we learned listening to thousands of couples."

**6.2.2 Topic Pills** (`:460-464`, data `:780-783`)
- Layout: `display:flex; gap:9px; flex-wrap:wrap; margin-top:26px`, directly under the intro wrapper.
- Exactly 4 pills, in source order: 1) "Yêu xa" / "Long distance", 2) "Giải quyết xung đột" / "Conflict", 3) "Ngôn ngữ tình yêu" / "Love languages", 4) "Hoàng đạo" / "Zodiac".
- Pill style: `background:var(--c06); border:1px solid var(--c14); border-radius:999px; padding:8px 16px`, label Nunito 700 13px `color:var(--c78)`; hover `border-color:rgba(255,127,182,.5); color:var(--ink)`.
- Presentational only per AC-3: no click/filter handler. See §6.3 for the accessibility treatment of the source's `cursor:pointer` styling.

**6.2.3 Featured Article Panel** (`:466-481`)
- Outer wrapper: `margin-top:34px; background:linear-gradient(140deg,rgba(255,127,182,.2),rgba(183,140,245,.16)); border:1px solid var(--c12); border-radius:34px; padding:8px`, inner grid `repeat(auto-fit,minmax(min(320px,100%),1fr)); gap:8px` — two cells that stack to one column below ~320+320px combined width (fluid `auto-fit`, not a fixed breakpoint).
- Left cell (illustration): `border-radius:28px; background:linear-gradient(160deg,rgba(183,140,245,.28),var(--inner)),var(--screen); min-height:300px; display:flex; align-items:end; padding:30px; position:relative; overflow:hidden`. Contains the "Sua" pet sprite (`dc-import`, 180×180px, positioned `top:24px; right:24px; opacity:.9`) and an eyebrow label pinned bottom-left: "Bài nổi bật" / "Featured", Roboto Mono 10px, `letter-spacing:.14em`, uppercase, `color:var(--acc-butter)`.
- Right cell (content): `padding:34px 30px`, vertically centered column.
  - Category tag: "Xung đột" / "Conflict", Roboto Mono 10px, `letter-spacing:.12em`, uppercase, `color:var(--acc-pink)`.
  - Title (H2): Nunito 900, 32px, `line-height:1.15`, `letter-spacing:-.02em`, `color:var(--ink)`, `margin:12px 0 0`, `text-wrap:pretty`. VI: "Cách dỗi mà không làm người kia sợ". EN: "How to sulk without scaring them".
  - Excerpt: 14.5px, `line-height:1.65`, `color:var(--c66)`, `margin:14px 0 0`. VI: "Dỗi không phải là im lặng. Dỗi là nói ra rằng mình đang cần gì, chỉ là bằng giọng nhỏ hơn. Bài này chỉ cách biến ba ngày không nói chuyện thành ba câu nói." EN: "Sulking isn't silence. It's saying what you need in a smaller voice. This piece turns three silent days into three sentences."
  - Author row (`margin-top:22px`, `gap:10px`): 32×32px circular avatar (`background:linear-gradient(140deg,#FF7FB6,#B78CF5)`, no image asset — solid gradient swatch), author name "Linh Đàm" (Nunito 700, 13px, `color:var(--c8)`, not localized — literal name in both VI and EN per copy fidelity), read time "· 8 phút đọc" / "· 8 min read" (Roboto Mono 11px, `color:var(--c42)`).
- This panel is hardcoded per AC-4 — do not generate it from the `posts` array; it is a distinct data object in the source, not `posts[0]`.

**6.2.4 Article Grid** (`:483-496`, data `:785-792`)
- Layout: `display:grid; grid-template-columns:repeat(auto-fit,minmax(min(300px,100%),1fr)); gap:18px; margin-top:22px`.
- Card shell: `background:var(--surf); border:1px solid var(--c1); border-radius:26px; padding:26px; display:flex; flex-direction:column; gap:12px`; hover: `border-color:rgba(255,127,182,.36); transform:translateY(-4px)`.
- Card anatomy, top to bottom: category tag pill → title → excerpt (flexes to fill remaining height so footer rows align across the row) → divider-topped author/read-time row.
  - Category tag: `display:inline-flex; align-self:start; background:{tint}; border-radius:999px; padding:5px 12px`, Roboto Mono 9.5px, `letter-spacing:.12em`, uppercase, `color:{accent}`.
  - Title: Nunito 800, 20px, `line-height:1.25`, `color:var(--ink)`, `text-wrap:pretty`.
  - Excerpt: 13.5px, `line-height:1.6`, `color:var(--c6)`, `flex:1`.
  - Footer row: `border-top:1px solid var(--c09); padding-top:13px; display:flex; align-items:center; gap:9px`. 26×26px circular avatar (gradient swatch, per-card color, no image asset), author name (Nunito 700, 12.5px, `color:var(--c76)`), read time pushed right (`margin-left:auto`), Roboto Mono 10.5px, `color:var(--c4)`, format "`{n}` phút" / "`{n}` min".
- Exactly 6 cards, in source order (category · accent color/tint token · title VI/EN · excerpt VI/EN · author · read min):
  1. Yêu xa / Long distance · `--acc-lilac` · "Hai múi giờ, một buổi tối" / "Two time zones, one evening" · "Bảy cặp đôi yêu xa kể cách họ tạo ra một giờ chung mỗi ngày, dù lệch nhau nửa vòng trái đất." / "Seven long-distance couples on carving out one shared hour a day, half a world apart." · Minh Khôi · 6.
  2. Thói quen / Habits · `--acc-mint` · "Vì sao việc nhỏ giữ được người ta lâu hơn việc lớn" / "Why small things outlast grand gestures" · "Một chuyến du lịch không bù được ba mươi ngày không hỏi nhau hôm nay thế nào." / "A holiday can't repay thirty days of not asking how today went." · Linh Đàm · 5.
  3. Xung đột / Conflict · `--acc-pink` · "Câu hỏi nên hỏi trước khi nói \"mình cần nói chuyện\"" / "Ask this before saying \"we need to talk\"" · "Một câu đơn giản làm hạ nhiệt gần như mọi cuộc tranh luận lúc nửa đêm." / "One simple line that cools almost every midnight argument." · Thu Hà · 4.
  4. Hoàng đạo / Zodiac · `--acc-butter` · "Đọc hoàng đạo kiểu không mê tín" / "Reading zodiac without the superstition" · "Xem nó như một cái cớ để hỏi nhau, không phải một bản án về tính cách." / "Treat it as an excuse to ask questions, not a verdict on character." · Bảo An · 7.
  5. Ngôn ngữ tình yêu / Love languages · `--acc-peach` · "Khi hai người thương nhau bằng hai thứ tiếng" / "When two people love in different languages" · "Bạn tặng quà, người kia chỉ cần bạn ngồi yên đó. Không ai sai cả." / "You give gifts; they just want you sitting there. Neither of you is wrong." · Minh Khôi · 6.
  6. Hậu trường / Behind Cupid · `--acc-lilac` · "Chúng mình bỏ tính năng xếp hạng cặp đôi" / "We deleted couple leaderboards" · "Nó làm hai người thi nhau thay vì hiểu nhau. Đây là lý do nó bị xoá." / "It made partners compete instead of connect. Here's why it's gone." · Đội Cupid · 3.
- Tint = `color-mix(in oklab, {accent} <14-16%>, transparent)` per card in source (14% for lilac/mint/pink/peach, 16% for butter) — implement each card's tag background at its own source-specified mix percentage, not one shared value; avatar swatch gradients differ per card (see source `:786-791` for exact gradient stops if implementation needs the literal values beyond the named accent).

**6.2.5 Newsletter Block** (`:498-506`)
- Layout: `margin-top:34px; background:var(--surf); border:1px solid var(--c11); border-radius:30px; padding:36px; display:flex; align-items:center; justify-content:space-between; gap:24px; flex-wrap:wrap`.
- Left: `max-width:420px`. Heading: Nunito 900, 24px, `color:var(--ink)`. VI: "Một bài mỗi thứ Năm". EN: "One letter, every Thursday". Subcopy (`margin-top:7px`): 14px, `line-height:1.6`, `color:var(--c62)`. VI: "Không quảng cáo, không bán khoá học. Huỷ đăng ký bằng một cú bấm." EN: "No ads, no courses. Unsubscribe in one click."
- Right: `display:flex; gap:10px; flex-wrap:wrap`. Email input: placeholder `email@cupid.app` (literal, not localized), `background:var(--c06); border:1px solid var(--c18); border-radius:999px; padding:14px 20px`, Roboto 14px, `color:var(--ink90)`, `min-width:230px`, `outline:none`. Button: `background:linear-gradient(140deg,#FF7FB6,#F0609E); border:none; color:#fff`, Nunito 800, 14.5px, `padding:14px 26px; border-radius:999px; white-space:nowrap`. VI: "Đăng ký". EN: "Subscribe".
- Presentational only per AC-6: no submit handler, no backend call. See §6.3 for the implementation note on preventing native form submission/reload.

### 6.3 Accessibility And Interaction Notes (design-source gaps to close, per AC-3/AC-6)

- **Topic pills** (§6.2.2): the source styles these with `cursor:pointer` and a hover state but wires no click handler — a purely visual affordance with no behavior. To avoid a false interactive promise: do not implement these as `<button>`/`<a>` elements with `tabindex`/focus rings (which would create keyboard-reachable dead stops); render as non-interactive elements (e.g. `<span>`/`<li>`) that keep the identical visual hover styling (mouse-only affordance is acceptable here since it mirrors the source's own non-committal behavior) but are not part of the Tab order and carry no ARIA interactive role. If a future story adds real filtering, this is the point to promote them to real toggle buttons.
- **Newsletter input/button** (§6.2.5): implement as real semantic `<input type="email">` and `<button>` elements (so native email keyboard/autofill/validation still work for the visitor), but the button must not trigger a page navigation or reload — if the implementation wraps these in a `<form>`, the submit handler must call `preventDefault()` and do nothing further, since AC-6 requires no backend/API call and the design source has no submit wiring to reference for "correct" behavior beyond "nothing happens."
- **Article cards / featured panel** (§6.2.3, §6.2.4): purely presentational content tiles — no per-article route exists (§6.2 note), so do not wrap card titles in `<a href="#">` placeholder links or otherwise imply a working destination; render as non-link containers. This matches the story's explicit Out-of-Scope note that individual article pages don't exist yet.
- **Author avatar swatches**: solid CSS gradients, not photos — mark as `aria-hidden="true"` (decorative), since the author's name text already carries the meaningful content.
- **Category tag pills** (grid cards + featured panel): decorative-but-informative color coding; the visible text label (e.g. "Conflict") already carries the category meaning, so the tag's background tint is presentation only and needs no additional ARIA beyond normal text contrast.

### 6.4 Visual Direction Notes

- Typography posture: unchanged from STORY-001's three-typeface system (Nunito display/CTA, Roboto body, Roboto Mono eyebrow/mono-numeral/caption) — this page adds no new typeface usage.
- Surface and container treatment: consistent with STORY-001 §6.7 — `var(--surf)` translucent panels, 26-34px border radii, thin low-opacity borders, hover-lift (`translateY(-4px)`) on content cards, no hard drop shadows. The featured panel's gradient border (`padding:8px` gutter around two inner cells) is this story's one new container shape — not present elsewhere in STORY-001, must be implemented pixel-accurate to `:466-481` since it is the page's most visually distinct element.
- Color usage: category tags and card accents cycle through the full brand palette (pink/lilac/mint/butter/peach) as content taxonomy, not status/semantic meaning — same "brand-expressive, not meaning-bearing" rule as STORY-001 §6.7.
- Anti-patterns explicitly avoided: do not add pagination controls, a "load more" button, or a filter-result-count indicator for the topic pills — none exist in the design source, and AC-3 explicitly forbids wiring real filter behavior in this story.

### 6.5 Component Changes

- **Topic pill** (New, page-local): static label chip, see §6.2.2 + §6.3 accessibility note.
- **Featured article panel** (New, page-local, not reused elsewhere in REQ-006 so far): illustration + content two-cell gradient-bordered panel, see §6.2.3.
- **Article card** (New, page-local): category tag + title + excerpt + author/read-time footer row, see §6.2.4. Visually adjacent to but not identical to STORY-001's "feature card" pattern (no icon tile here; adds an author row) — implementation should not collapse the two into one shared component without confirming the anatomy difference first.
- **Newsletter signup block** (New, page-local): heading/subcopy + email input + button, presentational only, see §6.2.5 + §6.3.
- Page `<title>` (AC-9, DEF-2 carry-forward): set a Blog-specific descriptive `<title>` (e.g. "Cupid Journal — Cupid" pattern, VI/EN as the framework's i18n approach dictates) instead of the shared-shell default title used by unbuilt stub routes. Exact string is an implementation-naming detail, not a design-source-sourced string (the design source is a component prototype with no `<title>` tag), but it must be page-specific and descriptive, not a bare "Cupid" repeat of the shell default.

### 6.6 Responsive And Accessibility Notes

- Responsive behavior: this page has no fixed-breakpoint layout of its own — every grid here (featured panel's two cells, article grid) uses CSS `auto-fit`/`minmax` fluid reflow, same posture as STORY-001 §6.6. Featured panel cells stack to one column once combined width can't fit two ≥320px cells; article grid reflows continuously (`minmax(min(300px,100%),1fr)`) down to one column on narrow viewports. The only fixed breakpoint on this page is the inherited shell header swap at 1024/1025px (STORY-001 §6.1) — verify at 375, 768, 1024, 1440px that neither the featured panel nor the grid ever drops a column below its `minmax` floor.
- Keyboard and focus expectations: newsletter email input and Subscribe button must be reachable via Tab in visual order and activatable via Enter/Space, with visible focus rings (same hard requirement as STORY-001 §6.6 — not present in the raw prototype's inline styles). Topic pills, article cards, and the featured panel are intentionally excluded from the Tab order per §6.3 (no interactive behavior exists for them).
- Screen reader / semantics notes: wrap the page body in `<main>` under the shared `<header>`/`<footer>` landmarks (STORY-001 §6.6 pattern). Use a real `<h1>` for the page headline and `<h2>` for the featured article title (article-grid card titles should be a lower heading level, e.g. `<h3>`, or non-heading emphasized text — implementation's call, but must not skip levels past `<h2>`). Author avatar swatches `aria-hidden="true"` per §6.3. Category tag color alone must not be the only way a card's topic is conveyed — the text label already satisfies this; do not remove it in favor of color-only tagging.
- Error / status communication expectations: N/A — no forms with real submission, no async operations in this story's scope (matches STORY-001 §6.6 and this story's AC-6/`OQ-REQ006-2` resolution).

### 6.7 Visual Acceptance Criteria / Design Anchor

- Visual reference: not yet rendered as image files for this story (same open item as STORY-001 §7 item 2/3 — `design_source` re-lock to `Cupid Web.dc.html` and the Bash-capable render step for `design-reference-*.png`; `req_master.md` now shows `Design-Source: UPDATED 2026-08-21T10:18:35Z (applied)`, so the re-lock trigger itself appears resolved since STORY-001's spec was written — confirming the render step actually ran, and producing this story's own `design-reference-blog-*.png`, is downstream tooling/DevOps work, not this role's action item). In the interim, the measurable rules in §6.2 (exact line-cited layout, spacing, color, and typography values) are the authoritative visual anchor.
- Layout & spacing: page container `padding:70px 32px 90px`; intro wrapper `max-width:660px`; pill row `gap:9px, margin-top:26px`; featured panel outer `padding:8px, border-radius:34px`, inner grid `gap:8px`; featured content cell `padding:34px 30px`; article grid `gap:18px, margin-top:22px`; article card `padding:26px, gap:12px, border-radius:26px`; newsletter block `padding:36px, border-radius:30px, gap:24px`.
- Color & status semantics: brand accent tokens (`--acc-pink #FF7FB6`, `--acc-lilac #B78CF5`, `--acc-mint #79E2CD`, `--acc-butter #FFC97E`, `--acc-peach #FFAB93`) per STORY-001 §6.8's full token table (`Cupid Web.dc.html:16-17`) — this story introduces no new tokens, only new per-card usage of the existing 5-color cycle.
- Typography: H1 Nunito 900 52px/1 (`letter-spacing:-.03em`); featured H2 Nunito 900 32px/1.15; card title Nunito 800 20px/1.25; body/excerpt Roboto 16px/1.65 (intro), 14.5px/1.65 (featured), 13.5px/1.6 (card); eyebrow/caption Roboto Mono 10-11px uppercase tracked `.12em`-`.14em`.
- Component states to verify (default / hover / active / disabled / loading / error / empty): topic pill default/hover (non-focus, per §6.3); article card default/hover (border + lift); featured panel has no hover state in source (static); newsletter input/button default/focus (no loading/error/success states — none exist). No empty state applies (fixed static content, not data-driven at runtime).
- Responsive checkpoints to verify: 375, 768, 1024, 1440px — confirm featured-panel two-cell stack and article-grid reflow never drop below their `minmax` floors (per §6.6), and that the inherited 1024/1025px header nav swap does not clip or overlap this page's intro block.

### 6.8 Usability Readiness Gate

- Can the target user complete the critical task without outside explanation? Yes — featured panel + article grid + category tags are self-explanatory scannable content, no prior context needed.
- Is the first action clear for the expected user mode? Yes — reading the featured article or scanning grid cards is the obvious first action; the newsletter block is a clear secondary action at the bottom.
- Is success, failure, and partial progress visible in user language? N/A — no in-page transaction exists (newsletter has no real submission per AC-6; no article-detail navigation exists per §6.2).
- Are recovery, retry, edit, undo, or next-action paths explicit where needed? N/A — no destructive or multi-step actions in scope.
- Remaining usability risks: topic pills and article-card hover styling could mislead a visitor into expecting a filter or a "read more" destination that doesn't exist in v1 — flagged explicitly in §6.3/§5, not left implicit; if user testing post-launch shows this is a real friction point, that is a candidate for a future story (real filtering, real article-detail routes), not a fix to sneak into this one.

## 7. Handoff Notes

- Important implementation constraints: this story has exactly one page state (§6.2) — implementation should not scaffold routing or data structures for a second "article detail" template, since AC-1/Out-of-Scope confirm none exists in the design source.
- OQ-driven blocked UX sections, if any: none (see §3).
- Shared pattern changes requiring System UX Memory update: yes, deferred — the featured-panel gradient-border two-cell pattern (§6.2.3) and the article-card anatomy (§6.2.4) are new page-local patterns not yet promoted to `data/ux/system/ui_ux_system_memory.md` (which currently only documents the mobile REQ-001 surface). Recommend a future consolidation pass across REQ-006's stories writes a web-specific system memory section once more page stories land, rather than each story writing a partial update in isolation.
- Design-coherence checks downstream should preserve: the inherited three-typeface split and surface/border treatment (§6.4, from STORY-001 §6.7); the fluid `auto-fit`/`minmax` grid pattern with no page-local fixed breakpoints (§6.6).
- Usability checks downstream should preserve: topic pills and article cards must stay visually non-committal to match their actual (non-)behavior (§6.3, §6.8) — do not silently add real interactivity as a "nice to have."
- Questions or blockers:
  1. **Design reference rendering — same outstanding item as STORY-001 §7 item 2/3, now one step further along**: `req_master.md` Technical Constraints (read this run) shows `Design-Source: UPDATED 2026-08-21T10:18:35Z (applied)`, suggesting the `Cupid Web.dc.html` re-lock STORY-001 flagged as blocked has since been applied. This role has no Bash tool this run and did not re-verify the live `design-fidelity-config.json` state or attempt the render command — recommend Tech Lead/DevOps confirm the lock state and run the `render-design-canvas.js --screen=blog` (or equivalent per-story screen key) command to produce `design-reference-blog-*.png` before the UI-lane review gate, since AC-7 requires the full gate with `design_source`/`ui_surface` configured.
  2. **Featured-panel per-card gradient/tint exact values**: §6.2.4 cites the accent-token names and the general `color-mix` formula per card; the six cards' individual avatar-gradient CSS stops and exact `tint` percentages are recorded verbatim in `Cupid Web.dc.html:786-791` if implementation needs literal copy-paste values beyond the named tokens in this spec — cross-reference that line range directly rather than re-deriving them.

## Optional Expansion

Not needed — this is a single-page story reusing STORY-001's shell; no multi-step flow, no new reusable global component beyond the page-local patterns covered in §6.5.
