
# UI/UX Specification - About & Press Kit Page (REQ-006 / STORY-006)

## 1. Metadata

- Related Story: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-006/story_master.md`
- Source Requirement Paths: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/req_master.md`, `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-006/requirements/requirements.md`
- Target Directory: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-006/ux/`
- Mode: Extend (new page content; reuses the global header/footer shell, theme/language system, and framework foundation built by STORY-001 unmodified)
- Status: Draft
- System UX Memory Path: `data/ux/system/ui_ux_system_memory.md`
- System UX Memory Action: Read Only — this file still documents `Cupid Mobile (REQ-001)` only; the web shell/pattern record lives in `STORY-001/ux/uiux-spec.md` (queried directly, see below), not yet promoted to system memory (deferred there too).

## 2. Context Summary

- User goal: a visitor, press contact, or partner reaches the About page (via header nav or footer "Press kit" link) and comes away trusting the company is real and considered, and — if press/partner — can self-serve brand assets without contacting anyone.
- Primary user mode: First-time (trust-building) and Returning/task-focused (press contact who came specifically for the kit).
- Business outcome: builds credibility for general visitors; gives press/partners self-serve brand-asset access, per story context summary.
- Existing specs reviewed: `STORY-001/ux/uiux-spec.md` (this requirement's only prior UX spec) — reused verbatim for global shell, theme/language behavior, and visual-direction rules (three-typeface split, `--surf` card treatment, fluid `auto-fit` grids). Not redesigned here.
- Existing UI patterns found and reused: the STORY-001 "feature card" pattern (`background:var(--surf); border:1px solid var(--c09); border-radius:26px`) is the direct ancestor of this page's principle cards, stat cards, and team cards — same visual family, different content shape. STORY-001 §6.5 flags this pattern as reusable; this story follows that guidance rather than inventing new card shapes.
- Existing components reused or extended: Header, Footer, theme toggle, language toggle (all STORY-001, unmodified — the "About" nav item and footer "Press kit" link already route here per STORY-001 §6.3 Route Map).
- Current UX debt or consistency risks: none new. Carries forward STORY-001 review finding **DEF-2** (no per-page `<title>`, every route currently falls back to `SiteLayout`'s shared "Cupid" default) — resolved for this page by §6.9 below, per `AC-9`.
- Current organization or hierarchy issues in the affected area: N/A (first content pass for this route).
- Stable shared patterns vs local debt: stable — shell, tokens, typography rules, and card pattern all inherited from STORY-001 without modification.
- Open Question Impact source: `STORY-006/requirements/requirements.md` `## Open Question Impact`.
- Open assumptions: none — the design source (`cupid-app-design-system/Cupid Web.dc.html`, `isAbout` block, lines 511-611) is a complete static prototype for every section on this page; every element below is sourced directly from it (exact line numbers cited), not inferred.

## 3. Open Question Impact

- **OQ-REQ006-1** (frontend framework/stack — RESOLVED by STORY-001 Tech Lead: Astro static site):
  - Status: RESOLVED, inherited.
  - UX Scope Blocked: none. This spec is markup/CSS/content structure only, independent of the already-chosen stack.
  - UX Decision: proceed with full UX design against the STORY-001 shell contract.
- **OQ-REQ006-2** (backend API dependency — RESOLVED at requirement level: static/informational site, no `api.cupidus.app` calls):
  - Status: RESOLVED.
  - UX Scope Blocked: none. Confirmed again at this page's own scope: the "Download kit" CTA is a static presentational link (`href="#"` placeholder in source, line 589) to a downloadable asset, not an API call.
  - UX Decision: no loading/error/empty states are designed for this page — every element below is static content or a plain link.

## 4. Requirement-To-Design Traceability

- **AC-1 (Route reachability)**: UX Response: N/A for new wiring — the "About" nav item and footer "Press kit" link already route to this page's URL per STORY-001 §6.3 Route Map (both point at the same `about` route, `Cupid Web.dc.html:98,151`). This spec designs only the page body that route now needs to render. Affected: `about` route body.
- **AC-2 (Mission section)**: UX Response: §6.2.1 Mission. Source: `Cupid Web.dc.html:512-517`.
- **AC-3 (Product principles grid)**: UX Response: §6.2.2 Product Principles Grid. Source: `:518-525`, data `:800-805`.
- **AC-4 (Usage stat counters)**: UX Response: §6.2.3 Usage Stat Counters. Source: `:526-536`. See the copy-fidelity flag in §6.2.3 — the big numbers are **not** localized in the source, only their labels are.
- **AC-5 ("Why a pet?" callout)**: UX Response: §6.2.4 Why A Pet Callout. Source: `:537-543`.
- **AC-6 (Company timeline)**: UX Response: §6.2.5 Company Timeline. Source: `:544-566`.
- **AC-7 (Team section)**: UX Response: §6.2.6 Team Section. Source: `:567-581`.
- **AC-8 (Press kit section, always visible)**: UX Response: §6.2.7 Press Kit Section. Source: `:582-610`, palette data `:807-812`. `showPressKit` defaults `true` in the source and no toggle surface exists in this project — this spec designs it as permanently rendered, matching Scope Decision.
- **AC-9 (Per-page title tag)**: UX Response: §6.9 Per-Page Title (resolves carried-forward `DEF-2`).
- **UI-Fidelity-AC-10 (About page visual fidelity)**: UX Response: §6.2 (all subsections) + §6.8 Visual Acceptance Criteria / Design Anchor. Affected: the entire `about` route body.
- **AC-11 (Copy fidelity)**: UX Response: every VI/EN string quoted in §6.2 is copied verbatim from the design source's `data-vi`/`data-en` spans and the `principles`/`palette` data arrays — do not paraphrase at implementation. See §6.2.3 and §6.2.5 for two non-obvious localization-format traps to preserve exactly, not "fix."

## 5. Critical User Tasks And Success Criteria

- **Build trust in the company (general visitor)**:
  - User Mode: First-time.
  - Entry Point: header "About" nav item, or direct URL.
  - Success Signal: visitor reads mission + principles + stats + timeline and perceives Cupid as a considered, real product (not a form-fill or CTA-click event to measure — a qualitative trust outcome, matching the story's "builds trust/credibility" business outcome).
  - Primary Risk: the mission headline/subcopy must land the "for two people, not a crowd" positioning in the first viewport, same self-explanatory bar STORY-001 set for Home.

- **Self-serve brand assets (press/partner)**:
  - User Mode: Returning/task-focused (came specifically for the kit).
  - Entry Point: footer "Press kit" link (jumps to the same `about` route — the press-kit section is the bottom of this page, not a separate page/anchor per current source markup; note the in-page scroll-to-section behavior, if any, is a Tech Lead implementation decision, not specified by the design source, which has no anchor/id on this section).
  - Success Signal: user locates the press-kit section, previews dark/light lockups and the palette, and successfully uses the "Download kit" CTA.
  - Primary Risk: if the press-kit section isn't discoverable without reading the whole page top-to-bottom, a time-pressed press contact may bounce — see §6.6 for the discoverability note this raises for Tech Lead.

- First-use guidance or discoverability needs: none beyond in-page section headers — this is a static content page, no onboarding flow.
- Completion or post-completion state: N/A for reading sections; for the "Download kit" CTA, completion is the browser's native file-download UI (no in-page confirmation state exists in the source).
- Retry, edit, undo, or next-action behavior: N/A (no forms, no destructive actions).
- What would make the task feel unfinished or unsafe to the user: a "Download kit" CTA that is visually a link but has no working `href` at ship time (source uses `href="#"` as a prototype placeholder — implementation must replace it with a real asset URL, per AC-8's delivery-mechanism note); team member cards with no name/role legible.

### 5.1 System Entry And Discoverability

- Existing surface, workflow, or state where the actor starts: header "About" nav item (desktop pill / mobile `<select>`, both from STORY-001) and footer "Company" column "Press kit" link — both already wired to this route.
- Required entry point, navigation item, CTA, or in-flow discovery path: both of the above, plus direct URL entry (AC-1) — no new nav wiring needed, this story only supplies the page body those existing links now render.
- Entry point states: default only. No empty/loading/disabled/permission-limited states apply.
- Surfaces intentionally not updated: N/A.

## 6. UX Design

### 6.1 Global Shell (reused, not redesigned)

Header and footer are unchanged from `STORY-001/ux/uiux-spec.md` §6.1 — sticky header (nav, theme toggle, language toggle, "Get the app" CTA) and footer (brand block + 3 link columns + copyright) render identically on this route. Do not re-specify or modify them here; implementation should reuse the STORY-001 shell components as-is. The "About" nav item shows `aria-current="page"` state (STORY-001 §6.1 accessibility rule) when this route is active, and the footer's "Press kit" link (Company column) points at this same route (STORY-001 §6.1 footer note, `story_master.md`/`requirements.md` scope confirmed).

### 6.2 About Page (`isAbout` state, `Cupid Web.dc.html:511-611`)

Container: `max-width:1200px; margin:0 auto; padding:70px 32px 90px`. Seven sections render in this order, all part of one continuous page (mission block is `max-width:660px` inside the wider container; every section below it spans the full 1200px width).

**6.2.1 Mission** (`:512-517`)
- Wrapper: `max-width:660px`.
- Eyebrow: Roboto Mono 11px, `letter-spacing:.14em`, uppercase, `color:var(--acc-pink)`. VI "Về Cupid" / EN "About".
- H1: Nunito 900, 52px, `letter-spacing:-.03em`, `margin:10px 0 0`, `color:var(--ink)`. VI "Chúng mình làm app cho hai người, không phải cho đám đông" / EN "We build for two people, not for a crowd".
- Subcopy: 16px, `line-height:1.7`, `color:var(--c64)`, `margin:18px 0 0`. VI "Không feed, không lượt thích, không người lạ. Cupid chỉ có hai tài khoản và một bé pet ở giữa. Mọi việc quan trọng đều cần cả hai đồng ý — kể cả việc rời đi." / EN "No feed, no likes, no strangers. Cupid holds two accounts and one pet between them. Everything that matters needs both of you to agree — including leaving."

**6.2.2 Product Principles Grid** (`:518-525`, data `:800-805`)
- Layout: `display:grid; grid-template-columns:repeat(auto-fit,minmax(240px,1fr)); gap:18px; margin-top:40px`.
- Card: `background:var(--surf); border:1px solid var(--c09); border-radius:24px; padding:24px` (same family as the STORY-001 feature card, no hover-lift specified for this variant in the source — do not add one implementation was not asked to add).
- Title: Nunito 800 17px, `color:var(--ink)`, `margin-bottom:8px`. Description: 13.5px, `line-height:1.6`, `color:var(--c6)`.
- Exactly 4 cards, verbatim (AC-3):
  1. "Couple-first" (identical VI/EN) — VI "Mọi màn hình đều có dấu vết của người kia. Không có chế độ một mình." / EN "Every screen carries a trace of the other person. There is no solo mode."
  2. "Dual-confirmation" (identical VI/EN) — VI "Đổi pet, xoá ảnh, rời đi — đều cần cả hai bấm đồng ý." / EN "Changing the pet, deleting a memory, leaving — all need both taps."
  3. VI "Dỗi cho đáng yêu" / EN "Sulk, sweetly" — VI "Cảm xúc xấu vẫn được nói ra, chỉ là bằng ngôn ngữ dễ thương hơn." / EN "Hard feelings still get said — just in a softer language."
  4. VI "Không quảng cáo" / EN "No ads" — VI "Không bán dữ liệu, không feed. Kiếm tiền bằng phụ kiện cho pet." / EN "No data selling, no feed. We earn from pet accessories."

**6.2.3 Usage Stat Counters** (`:526-536`)
- Layout: `display:grid; grid-template-columns:repeat(auto-fit,minmax(min(200px,100%),1fr)); gap:16px; margin-top:44px`.
- Card: `background:var(--surf); border:1px solid var(--c1); border-radius:26px; padding:28px`.
- Big number: Nunito 900 40px, `letter-spacing:-.03em`, `color:var(--ink)`. Label below: Roboto Mono 10px, `letter-spacing:.12em`, uppercase, `color:var(--c5)`, `margin-top:6px`.
- **Copy-fidelity flag (non-obvious, do not "fix")**: the three big numbers — `48.000+`, `31.500`, `2,1 triệu` — are **plain literal text in the source, not wrapped in `data-vi`/`data-en` spans**. They render identically regardless of the active language toggle; only the label underneath is localized. Implementation must reproduce this exactly (e.g. the number stays `2,1 triệu` even when the page is in English mode) — do not translate the number to `"2.1 million"` when the source doesn't.
  1. `48.000+` — label VI "cặp đôi đang dùng" / EN "couples on Cupid".
  2. `31.500` — label VI "bé pet đã nở" / EN "pets hatched".
  3. `2,1 triệu` — label VI "thẻ kỷ niệm đã tạo" / EN "keepsake cards minted".

**6.2.4 "Why A Pet?" Callout** (`:537-543`)
- Container: `margin-top:52px; background:var(--surf); border:1px solid var(--c1); border-radius:30px; padding:34px; display:grid; grid-template-columns:repeat(auto-fit,minmax(min(280px,100%),1fr)); gap:30px`.
- Left column: eyebrow Roboto Mono 10px, `letter-spacing:.12em`, uppercase, `color:var(--acc-mint)` — VI "Tại sao là pet?" / EN "Why a pet?". Headline below: Nunito 900 26px, `color:var(--ink)`, `margin-top:10px`, `line-height:1.2` — VI "Vì không ai muốn thấy một sinh vật vô tội bị bỏ quên" / EN "Because nobody wants to watch something innocent go hungry".
- Right column: body copy, 14.5px, `line-height:1.7`, `color:var(--c66)`. VI "Nhắc nhau \"nhớ quan tâm anh/em\" thì khó nói. Nhưng \"Bo đang buồn kìa\" thì dễ. Bé pet là chỗ để cả hai đặt trách nhiệm mà không ai phải làm người đòi hỏi — và cũng là chỗ để cả hai cùng tự hào khi nó lớn." / EN "Saying \"pay attention to me\" is hard. Saying \"Bo looks sad\" is easy. The pet is where you both put the responsibility, so neither has to be the demanding one — and where you both get to be proud when it grows."

**6.2.5 Company Timeline** (`:544-566`)
- H2: Nunito 900 28px, `letter-spacing:-.02em`, `color:var(--ink)`, `margin:52px 0 4px`. VI "Chặng đường" / EN "The road so far".
- List wrapper: `margin-top:14px`. Each entry: `display:flex; gap:20px; padding:20px 0; border-top:1px solid var(--c09)`.
- Year column: Roboto Mono 12px, `color:var(--acc-pink)`, `flex:0 0 60px`, `padding-top:3px`. Title: Nunito 800 17px, `color:var(--ink)`. Description: 13.5px, `line-height:1.6`, `color:var(--c6)`, `margin-top:5px`.
- Exactly 5 entries, chronological order (AC-6):
  1. 2024 — VI "Một cái bảng trắng" / EN "A whiteboard" — VI "Hai người trong nhóm đang yêu xa, và không app nào giúp được họ." / EN "Two of us were long-distance, and no app was helping."
  2. 2025 — VI "Bản thử đầu tiên" / EN "First build" — VI "Ba trăm cặp đôi thử. Bé pet đầu tiên tên Bo, và nó chết vì không ai cho ăn." / EN "Three hundred couples tried it. The first pet was Bo, and it died unfed."
  3. 2025 — "Dual-confirmation" (identical VI/EN) — VI "Chúng mình bỏ mọi hành động một người có thể làm thay hai người." / EN "We removed every action one person could take on behalf of two."
  4. 2026 — VI "Ra mắt Việt Nam" / EN "Vietnam launch" — VI "48.000 cặp đôi trong bốn tháng, gần như hoàn toàn nhờ thẻ kỷ niệm được chia sẻ." / EN "48,000 couples in four months, almost entirely through shared keepsake cards."
  5. 2026 — VI "Sắp tới" / EN "Next" — VI "Album chung có in ảnh thật, và một chế độ dành cho những cặp mới quen." / EN "A printable shared album, and a mode for couples who just met."
- **Contrast with §6.2.3, worth calling out at implementation**: entry 4's number here (VI `48.000` / EN `48,000`) **is** inside a translated `data-vi`/`data-en` pair, so its thousands-separator legitimately differs by language (dot vs. comma) — unlike the unlocalized stat-counter numbers in §6.2.3. Reproduce both behaviors exactly as the source has them; they are not inconsistent, they are two different content types (raw stat display vs. translated prose).

**6.2.6 Team Section** (`:567-581`)
- H2: same style as timeline H2, `margin:52px 0 18px`. VI "Đội ngũ" / EN "The team".
- Layout: `display:grid; grid-template-columns:repeat(auto-fit,minmax(min(200px,100%),1fr)); gap:16px`.
- Card: `background:var(--surf); border:1px solid var(--c1); border-radius:26px; padding:26px; text-align:center`.
- Avatar: 72×72px circle, `margin:0 auto`, gradient placeholder per member (design source ships no photography — do not source or fabricate real photos, keep the gradient tile). Name: Nunito 900 18px, `color:var(--ink)`, `margin-top:14px` (plain text, not localized). Role label below: Roboto Mono 9.5px, `letter-spacing:.12em`, uppercase, `color:var(--c5)`, `margin-top:5px`.
- Exactly 3 cards (AC-7):
  1. Minh Khôi — avatar gradient `linear-gradient(140deg,#FF7FB6,#B78CF5)` — role VI "Sản phẩm" / EN "Product".
  2. Linh Đàm — avatar gradient `linear-gradient(140deg,#B78CF5,#79E2CD)` — role VI "Thiết kế" / EN "Design".
  3. Thu Hà — avatar gradient `linear-gradient(140deg,#FFC97E,#FF7FB6)` — role VI "Kỹ thuật" / EN "Engineering".

**6.2.7 Press Kit Section** (`:582-610`, always rendered per Scope Decision — no toggle)
- Container: `margin-top:56px; background:var(--surf); border:1px solid var(--c09); border-radius:30px; padding:34px`.
- Header row: `display:flex; align-items:end; justify-content:space-between; gap:18px; flex-wrap:wrap`.
  - Left: eyebrow "Press kit" — Roboto Mono 11px, `letter-spacing:.14em`, uppercase, `color:var(--acc-lilac)` (plain text, not localized — same string both languages, unlike the page's other eyebrow labels; do not translate). Headline below: Nunito 900 30px, `color:var(--ink)`, `margin-top:6px` — VI "Tài sản thương hiệu" / EN "Brand assets".
  - Right: "Download kit" CTA — pill link, `background:var(--ink90); color:var(--bg); padding:13px 22px; border-radius:999px`, Nunito 800 14px. VI "Tải bộ kit" / EN "Download kit". **Implementation note (AC-8)**: source `href="#"` is a prototype placeholder, not a real target — must be replaced with an actual downloadable asset URL; the delivery mechanism (e.g. static zip served from the built site) is a Tech Lead/DevOps decision, not specified here.
- Swatch row: `display:grid; grid-template-columns:repeat(auto-fit,minmax(200px,1fr)); gap:16px; margin-top:24px`. Three items:
  1. **Dark lockup**: `background:#171129; border:1px solid rgba(247,238,251,.1); border-radius:22px; padding:24px`, centered column, `gap:12px`, `min-height:150px`. Logo row: 38×38px tile, `border-radius:13px`, `background:linear-gradient(140deg,#FF7FB6,#B78CF5)`, centered `favorite` icon (22px, white), `box-shadow:0 6px 20px rgba(255,127,182,.4)` + wordmark "Cupid" (Nunito 900 24px, `letter-spacing:-.02em`, `color:#fff`). Caption below: Roboto Mono 9.5px, `letter-spacing:.12em`, uppercase, `color:rgba(247,238,251,.4)` — "Dark lockup" (plain text, not localized).
  2. **Light lockup**: same layout, `background:#FFF6FB`, **no border** (deliberate contrast with the dark swatch's border — do not add one for "consistency", that would be a fidelity deviation). Same logo tile, no `box-shadow` on this variant, wordmark `color:#3E2645`. Caption `color:rgba(62,38,69,.45)` — "Light lockup" (plain text, not localized).
  3. **Palette**: `background:var(--c05); border:1px solid var(--c09); border-radius:22px; padding:20px`. Label "Palette" (Roboto Mono 10px, `letter-spacing:.12em`, uppercase, `color:var(--c5)`, `margin-bottom:12px`, plain text not localized). Grid: `display:grid; grid-template-columns:repeat(4,1fr); gap:8px`. Exactly 8 swatches (AC-8), each a color block (`height:38px; border-radius:12px; background:{hex}; border:1px solid var(--c12)`) with a name label below (Roboto Mono 8.5px, `color:var(--c5)`, `margin-top:5px`, plain text not localized):
     `#FF7FB6` Pink · `#B78CF5` Lilac · `#79E2CD` Mint · `#FFC97E` Butter · `#FFAB93` Peach · `#171129` Nebula · `#241B42` Surface · `#FFF6FB` Cotton.

### 6.3 Route Map (reused, no changes)

No changes to `STORY-001/ux/uiux-spec.md` §6.3 — the `about` route entry already exists there with both the header nav ("About") and footer ("Press kit", same route) reachability rows. This story fills that route's previously-empty body.

### 6.4 Theme & Language States (reused, no changes)

No changes to `STORY-001/ux/uiux-spec.md` §6.4 — theme/language are shell-level state, not per-page. This page's every localized element above must correctly show all 4 combinations (dark×vi, dark×en, light×vi, light×en); the non-localized numbers/labels flagged in §6.2.3 and §6.2.7 stay literal across all 4.

### 6.5 Component Changes

- **Principle card** (New, extends the STORY-001 feature-card pattern — same `--surf`/border/radius shell, no icon tile and no hover-lift specified for this variant): see §6.2.2.
- **Stat card** (New, distinct radius/border/padding from STORY-001's hero inline stat counters — this is a boxed card variant, not the plain number-over-label pair from Home): see §6.2.3.
- **Callout card** (New, two-column info block): see §6.2.4. Reusable pattern for future single-highlight sections if a later story needs one.
- **Timeline entry** (New, horizontal year+content row): see §6.2.5.
- **Team card** (New, centered avatar+name+role): see §6.2.6.
- **Press-kit swatch** (New, 3 sub-variants — dark lockup, light lockup, palette grid): see §6.2.7. The dark/light lockup pair is a fixed-color component (does not respond to the page's own theme toggle — it always shows both a literal-dark and a literal-light brand rendering side by side, regardless of which site theme is active); do not wire it to `document.body.dataset.theme`.

### 6.6 Responsive And Accessibility Notes

- Responsive behavior: every grid on this page (principles, stats, team, press-kit swatches, palette) uses CSS `auto-fit`/`minmax` fluid reflow, matching STORY-001's established rule (§6.7) — implement as real fluid grids, not fixed breakpoint overrides. The "Why a pet?" callout and press-kit header row use the same fluid `auto-fit`/flex-wrap pattern, collapsing to a single stacked column/row on narrow viewports naturally.
- Content or action reprioritization on smaller surfaces: the press-kit header row (`justify-content:space-between; flex-wrap:wrap`) stacks the "Download kit" CTA below the headline once the row can't fit both — verify at implementation that the CTA remains reachable and doesn't get visually orphaned.
- Keyboard and focus expectations: the "Download kit" link must be reachable via Tab and activatable via Enter, with a visible focus ring (same hard requirement as STORY-001 §6.6 — not present in the raw prototype's inline styles, close this gap at implementation same as every other interactive element on the site).
- Screen reader / semantics notes: use a real `<main>` region for this page's content (landmarks already established at shell level per STORY-001 §6.6); the timeline should use a semantic list (`<ol>`/`<li>` or an equivalent ARIA list role) since it is inherently ordered chronological content, not just visually stacked divs; team-card avatars are decorative gradient placeholders (no real photography) and should be `aria-hidden="true"` or have empty `alt` — unlike STORY-001's pet sprites (which needed meaningful alt text for pet identity), these gradient avatars carry no information beyond the adjacent name/role text, so decorative-image treatment is correct here, not an oversight.
- Error / status communication expectations: N/A — no forms, no async operations. If the "Download kit" asset is ever unavailable, that is a DevOps/infra concern (broken static asset), not a UX state this spec needs to design a fallback for.
- **Discoverability flag for Tech Lead/DevOps (raised in §5, not resolved here)**: a time-pressed press contact using the footer "Press kit" link lands at the top of a long page (mission → principles → stats → callout → timeline → team → press kit) with no in-page anchor/scroll-to-section in the design source. Recommend Tech Lead consider an in-page anchor (`#press-kit`) so the footer link can jump straight to §6.2.7 instead of the page top — this is a recommendation, not an AC, since the source itself doesn't do it and the story's ACs don't require it; flagging so it isn't silently dropped or silently added without a decision.

### 6.7 Visual Direction Notes

- Typography, density, or spacing posture: unchanged from STORY-001 §6.7 — Nunito 900/800 for display/headline/CTA, Roboto for body, Roboto Mono uppercase-tracked for eyebrows/captions/mono-numerals. This page adds no new typeface or weight.
- Surface and container treatment: unchanged — soft `--surf` translucent panels, 22-30px radii, thin low-opacity borders, no hard drop shadows except the press-kit dark-lockup swatch's brand-glow shadow on its logo tile (an intentional, scoped exception, not a rule change).
- Color or status-semantics treatment: no status/semantic colors on this page (no forms, no error states) — palette usage is purely brand-expressive, same as STORY-001. The 8-swatch palette grid in §6.2.7 is content (documenting the brand palette), not a UI color-semantics system.
- Anti-patterns explicitly avoided: no bottom tab bar, no platform-adaptive chrome (STORY-001 rule, still applies); do not add a hover-lift to the principle/stat/team cards unless the source specifies one for that exact card (it doesn't — only STORY-001's feature/pet-cast cards have documented hover-lift; don't over-generalize that rule onto this page's card variants).

### 6.8 Visual Acceptance Criteria / Design Anchor

- Visual reference(s): not yet rendered as image files — same outstanding "Design Reference Rendering" gap STORY-001 flagged (this role has no Bash tool; `design-reference-*.png` generation requires a Bash-capable agent running `render-design-canvas.js`). `req_master.md` now shows the design-source lock was updated 2026-08-21T10:18:35Z to point at `Cupid Web.dc.html` (applied) — whoever renders references next should confirm that lock resolves cleanly for the `about` screen before assuming the STORY-001-era blocker is fully closed. In the interim, this section's exact line-cited values in §6.2 are the authoritative visual anchor.
- Layout & spacing: page container `padding:70px 32px 90px`, `max-width:1200px`; mission wrapper `max-width:660px`; principles grid `gap:18px, margin-top:40px`; stat grid `gap:16px, margin-top:44px`; callout `padding:34px, gap:30px, margin-top:52px`; timeline entries `padding:20px 0`, `gap:20px`; team grid `gap:16px`; press-kit container `padding:34px, margin-top:56px`; swatch row `gap:16px, margin-top:24px`. All grids `auto-fit`/`minmax` per §6.6.
- Color & status semantics: brand tokens shared with STORY-001 (`--acc-pink #FF7FB6`, `--acc-mint #79E2CD`, `--acc-lilac #B78CF5`); this page's unique literal (non-token) colors are the press-kit dark-lockup `#171129`, light-lockup `#FFF6FB`, and the 8 palette hexes listed in §6.2.7 verbatim — these must render as the exact literal values, not theme-token substitutes, since they are documenting the brand palette itself.
- Typography: mission H1 Nunito 900 52px/`-.03em`; section H2 (timeline/team) Nunito 900 28px/`-.02em`; press-kit headline Nunito 900 30px; principle/team-card title Nunito 800 17-18px; stat number Nunito 900 40px; body/description 13.5-16px; eyebrow/caption Roboto Mono 9.5-11px uppercase tracked `.12em`-`.14em`.
- Component states to verify: "Download kit" CTA default/hover/focus (hover treatment not specified in source beyond the standard pill-link pattern — implement a subtle brightness/opacity hover consistent with the header "Get the app" CTA, since no explicit hover rule exists for this specific link); no other interactive states on this page (no disabled/loading/error/empty — static content only, per §3).
- Responsive checkpoints to verify: 375, 768, 1024, 1440px — confirm no grid column drops below its `minmax` floor (240px principle cards, 200px stat/team cards, 200px press-kit swatches) and the press-kit header row wraps cleanly per §6.6.

### 6.9 Per-Page Title (AC-9, resolves carried-forward DEF-2)

The design source has no `<title>` element anywhere (it's a component canvas, not a full document) — STORY-001's review flagged this as a PO/UX decision, still open. Resolving it here for this page only, following the same "descriptive, distinguishable per route" intent DEF-2 asked for:
- VI: "Giới thiệu & Bộ nhận diện thương hiệu — Cupid"
- EN: "About & Press Kit — Cupid"
Follow whatever language state drives the rest of the page if the chosen framework supports per-route localized `<title>`; if not, default to the site's default language and flag that gap back rather than silently shipping one hardcoded language. This is this story's title only — STORY-002 through STORY-008 still need their own PO/UX per-page title decisions; do not treat this section as resolving DEF-2 site-wide.

### 6.10 Usability Readiness Gate

- Can the target user complete the critical task without outside explanation? Yes — mission headline/subcopy (§6.2.1) explains the "for two, not a crowd" positioning immediately; press-kit section (§6.2.7) is self-explanatory (labeled swatches + one clear CTA).
- Is the first action clear for the expected user mode? Yes for the general-visitor mode (this is a read-heavy trust page, not an action page — "action" here is continued browsing/eventual download, already covered by the header CTA from STORY-001). Partially for the press-contact mode — see the §6.6 discoverability flag; the "Download kit" CTA itself is clear once the section is reached, but reaching it requires scrolling the full page from either entry point.
- Are all interactive elements reachable and their states distinguishable? Yes — one interactive element on this page (the "Download kit" link); default/hover/focus specified in §6.8.

## 7. Handoff Notes

- Important implementation constraints: build all seven subsections of §6.2 as one continuous page body inside the existing `about` route/layout established by STORY-001; do not introduce new header/footer/theme/language logic — reuse the STORY-001 shell components unmodified (§6.1, §6.3, §6.4).
- OQ-driven blocked UX sections, if any: none (see §3; both requirement-level OQs resolved before this story's scope began).
- Shared pattern changes requiring System UX Memory update: no new shared pattern introduced beyond what STORY-001 already flagged as reusable (feature-card family); this story's new components (stat card, timeline entry, team card, press-kit swatch) are page-local, not yet confirmed reusable elsewhere — do not promote them to System UX Memory until a second story needs the same shape.
- Design-coherence checks downstream should preserve: the two non-obvious localization-format facts flagged in §6.2.3 and §6.2.5 (raw stat numbers stay unlocalized; timeline prose numbers do localize their thousands-separator) — these are easy to "fix" by accident into false consistency, and doing so would be a fidelity deviation, not an improvement.
- Usability checks downstream should preserve: press-kit section must remain always-visible (no admin toggle, per AC-8/Scope Decision); "Download kit" CTA must point at a real asset before ship (source `href="#"` is a placeholder, flagged in §6.2.7 for Tech Lead/DevOps).
- Questions or blockers:
  1. **Design Reference Rendering — same outstanding gap as STORY-001, not this role's action item.** No Bash tool available in this run to execute `render-design-canvas.js`; §6.2's exact line-cited values stand in as the interim visual anchor per §6.8. A Bash-capable agent should render the `about` screen once the design-source lock (now updated 2026-08-21 per `req_master.md`) is confirmed to resolve `Cupid Web.dc.html` correctly for this screen.
  2. **Per-page `<title>` decision (§6.9) is scoped to this story only** — flagging explicitly so Scrum Master/PO don't assume DEF-2 is fully closed site-wide after this one page ships.
  3. **In-page anchor for the press-kit section (§6.6)** is a recommendation for Tech Lead to accept or explicitly decline, not a UX-mandated AC — the design source itself has no anchor, and no story AC requires one.
